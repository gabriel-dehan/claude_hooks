#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = [
#   # Pinned for reproducibility. `load_available_skills` is a real, exported
#   # SDK API but is under-documented, so pin to guard against a rename.
#   "openhands-sdk==1.36.0",
#   "openhands-tools==1.36.0",
# ]
# ///
"""
Generic Mitts agent runner for GitHub Actions.

Runs an OpenHands SDK agent inside the Actions runner with full repo access,
using YOUR OpenAI-compatible LLM endpoint (LLM_BASE_URL / LLM_MODEL / LLM_API_KEY).
The agent uses bash + the `gh` CLI (authenticated via GITHUB_TOKEN) to read
issues/PRs, make code changes, commit, push a branch, and open/update PRs.

Dependencies are declared inline and resolved by `uv run` — the
workflows invoke this via `uv run .github/mitts/agent_task.py`.

This is intentionally a single generic script: the WORKFLOW decides the task by
setting AGENT_PROMPT. See the workflows in .github/workflows/mitts-*.yml.

Required env:
    LLM_API_KEY    API key for your OpenAI-compatible endpoint
    LLM_MODEL      LiteLLM model id, e.g. "openai/<your-model-name>"
    LLM_BASE_URL   Base URL of your OpenAI-compatible endpoint
    GITHUB_TOKEN   Token with contents:write + pull-requests:write + issues:write
    GITHUB_REPOSITORY  owner/repo (provided automatically by Actions)
    AGENT_PROMPT   The full task instruction for the agent (set by the workflow)

Optional env (cross-run memory — see recall_tool.py):
    OPENHANDS_PERSIST_DIR        When set, events are written under
                                 <dir>/<thread-key>/<conversation-id>/ so a later
                                 run (restored from a GitHub artifact) can recall
                                 this run's reasoning via the recall_prior_reasoning
                                 tool. Absent => fully stateless (today's behavior).
    OPENHANDS_CONVERSATION_KEY   Thread key, e.g. "pr-42" / "issue-7".
    OPENHANDS_KEEP_RUNS          How many prior run subdirs to retain per thread
                                 before a run (default 5). Older ones are pruned so
                                 the per-thread artifact can't grow unbounded.

Optional env (skills):
    OPENHANDS_LOAD_PUBLIC_SKILLS  Set to "1"/"true" to also load skills from the
                                  OpenHands/extensions public registry (does a git
                                  clone on first run; adds ~1-2s). Default: off.
    EXTENSIONS_REF                Branch/tag/SHA for the public extensions repo.
                                  Default: "main". Pin to a tag for reproducibility.

Optional env (iterations):
    LLM_MAX_ITER   Max agent iterations (default 60).
"""

from __future__ import annotations

import os
import shutil
import sys
import uuid
from pathlib import Path

from openhands.sdk import (
    AgentContext,
    LLM,
    Agent,
    Conversation,
    Tool,
    get_logger,
    register_tool,
)
from openhands.sdk.conversation import get_agent_final_response
from openhands.sdk.conversation.state import ConversationExecutionStatus
from openhands.sdk.hooks import HookConfig, HookDefinition, HookMatcher
from openhands.sdk.skills import load_available_skills
from openhands.tools.preset.default import (
    get_default_condenser,
    get_default_tools,
    register_builtins_agents,
)

# Local module (same directory) — the custom cross-run memory tool.
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from recall_tool import RecallPriorReasoningTool  # noqa: E402

logger = get_logger(__name__)

_HOOK_SCRIPT = Path(__file__).parent / "hooks" / "block_dangerous.sh"

def require(name: str) -> str:
    val = os.getenv(name)
    if not val:
        print(f"::error::Missing required environment variable: {name}")
        sys.exit(1)
    return val


def _prune_prior_runs(thread_dir: str, keep: int) -> None:
    """Keep only the `keep` most-recent prior run subdirs under thread_dir.

    Every run writes a fresh <conversation-id>/ subdir and the whole tree is
    re-uploaded as one artifact each run, so without pruning a busy PR's artifact
    grows unbounded (and every restore/persist gets slower). Recency is derived
    from each run's newest zero-padded `event-*.json` filename — NOT mtime, which
    an artifact round-trip doesn't preserve. Best-effort: never fatal.
    """
    root = Path(thread_dir)
    if not root.is_dir():
        return

    def _run_key(run_dir: Path) -> str:
        events = sorted((run_dir / "events").glob("event-*.json"), key=lambda p: p.name)
        return events[-1].name if events else ""

    try:
        run_dirs = sorted(
            (d for d in root.iterdir() if d.is_dir()),
            key=_run_key,
            reverse=True,  # newest first
        )
    except OSError as exc:
        logger.warning("Could not scan prior runs for pruning: %s", exc)
        return

    for stale in run_dirs[keep:]:
        try:
            shutil.rmtree(stale)
            logger.info("Pruned stale run dir: %s", stale.name)
        except OSError as exc:
            logger.warning("Could not prune %s: %s", stale, exc)


def _write_step_summary(text: str) -> None:
    """Append text to the GitHub Actions step summary (no-op outside Actions)."""
    summary_file = os.getenv("GITHUB_STEP_SUMMARY")
    if not summary_file:
        return
    try:
        with open(summary_file, "a") as fh:
            fh.write(text + "\n")
    except OSError as exc:
        logger.warning("Could not write to GITHUB_STEP_SUMMARY: %s", exc)


def main() -> None:
    api_key = require("LLM_API_KEY")
    model = require("LLM_MODEL")           # e.g. openai/<your-model>
    base_url = os.getenv("LLM_BASE_URL")   # your OpenAI-compatible endpoint
    prompt_file = os.getenv("AGENT_PROMPT_FILE")
    if prompt_file:
        prompt = Path(prompt_file).read_text(encoding="utf-8")
    else:
        prompt = require("AGENT_PROMPT")
    require("GITHUB_TOKEN")
    repo = require("GITHUB_REPOSITORY")

    try:
        max_iterations = int(os.getenv("LLM_MAX_ITER", "60"))
    except ValueError:
        max_iterations = 60

    logger.info("Repository: %s", repo)
    logger.info("Model: %s", model)
    if base_url:
        logger.info("LLM base URL: %s", base_url)

    # --- Build the LLM against YOUR OpenAI-compatible endpoint ---
    llm_config: dict = {
        "model": model,
        "api_key": api_key,
        "usage_id": "gha_agent",
        # drop_params lets LiteLLM strip params your endpoint doesn't accept,
        # which keeps OpenAI-compatible-but-not-identical backends working.
        "drop_params": True,
    }
    if base_url:
        llm_config["base_url"] = base_url
    llm = LLM(**llm_config)

    # --- Load skills: AGENTS.md + .agents/skills/ + optional public registry ---
    load_public = os.getenv("OPENHANDS_LOAD_PUBLIC_SKILLS", "").lower() in ("1", "true", "yes")
    try:
        skills_map = load_available_skills(
            work_dir=os.getcwd(),
            include_project=True,
            include_public=load_public,
        )
        if skills_map:
            logger.info("Loaded %d skill(s): %s", len(skills_map), list(skills_map.keys()))
        else:
            logger.info("No project skills found (AGENTS.md or .agents/skills/ missing?)")
    except Exception as exc:
        logger.warning("Skill loading failed, continuing without skills: %s", exc)
        skills_map = {}

    agent_context = AgentContext(skills=list(skills_map.values()))

    # --- Tools: default set + sub-agent delegation ---
    # register_builtins_agents makes built-in delegation targets (code-reviewer,
    # web-researcher, etc.) available to the TaskToolSet.
    register_builtins_agents(enable_browser=True)
    tools = get_default_tools(enable_browser=True, enable_sub_agents=True)

    # Cross-run memory: only when a persistence dir + thread key are configured
    # (i.e. not on fork PRs, where artifacts/secrets are unavailable). When absent
    # this whole block is skipped and behavior is identical to a stateless run.
    persist_root = os.getenv("OPENHANDS_PERSIST_DIR")
    thread_key = os.getenv("OPENHANDS_CONVERSATION_KEY")
    persistence_dir = None
    conversation_id = None
    if persist_root and thread_key:
        # Each run gets its OWN conversation_id (fresh uuid4) so the SDK never
        # resumes/replays prior events into this prompt — prior reasoning is
        # reachable only on demand via the recall_prior_reasoning tool. Runs share
        # the per-thread dir so the tool can read sibling (prior-run) subdirs.
        persistence_dir = os.path.join(persist_root, thread_key)
        # Prune old run subdirs BEFORE this run adds its own, so restored artifacts
        # stay bounded. keep-1 leaves room for the fresh run created just below.
        try:
            keep = max(1, int(os.getenv("OPENHANDS_KEEP_RUNS", "5")))
        except ValueError:
            keep = 5
        _prune_prior_runs(persistence_dir, keep=keep - 1)
        conversation_id = uuid.uuid4()
        # Let the recall tool exclude the current run when scanning prior subdirs.
        os.environ["OPENHANDS_CURRENT_CONVERSATION_ID"] = str(conversation_id)
        register_tool("RecallPriorReasoningTool", RecallPriorReasoningTool)
        tools = [*tools, Tool(name="RecallPriorReasoningTool")]
        logger.info(
            "Cross-run memory enabled: persistence_dir=%s conversation_id=%s",
            persistence_dir,
            conversation_id,
        )

    # --- Agent ---
    agent = Agent(
        llm=llm,
        tools=tools,
        agent_context=agent_context,
        system_prompt_kwargs={"cli_mode": True},
        condenser=get_default_condenser(
            llm=llm.model_copy(update={"usage_id": "condenser"})
        ),
    )

    # --- Guardrail hooks (PreToolUse on terminal commands) ---
    hook_config: HookConfig | None = None
    if _HOOK_SCRIPT.is_file():
        hook_config = HookConfig(
            pre_tool_use=[
                HookMatcher(
                    matcher="terminal",
                    hooks=[HookDefinition(command=str(_HOOK_SCRIPT), timeout=10)],
                )
            ]
        )
        logger.info("Guardrail hook enabled: %s", _HOOK_SCRIPT)
    else:
        logger.warning(
            "Guardrail hook script not found at %s — running without PreToolUse guardrails",
            _HOOK_SCRIPT,
        )

    # Secrets passed to the workspace are masked in logs AND exported into the
    # agent's shell env, so `gh` and `git` are authenticated automatically.
    secrets = {
        "GITHUB_TOKEN": os.environ["GITHUB_TOKEN"],
        "GH_TOKEN": os.environ["GITHUB_TOKEN"],
    }

    conv_kwargs: dict = {
        "agent": agent,
        "workspace": os.getcwd(),
        "secrets": secrets,
        "max_iteration_per_run": max_iterations,
    }
    if hook_config is not None:
        conv_kwargs["hook_config"] = hook_config
    if persistence_dir:
        conv_kwargs["persistence_dir"] = persistence_dir
        conv_kwargs["conversation_id"] = conversation_id

    conversation = Conversation(**conv_kwargs)

    logger.info("Sending task to agent...")
    conversation.send_message(prompt)
    conversation.run()

    final = get_agent_final_response(conversation.state.events)
    print("\n===== AGENT FINAL RESPONSE =====\n")
    print(final or "(no final response)")

    # --- Cost / token metrics ---
    try:
        m = conversation.conversation_stats.get_combined_metrics()
        cost = m.accumulated_cost or 0.0
        usage = m.accumulated_token_usage
        prompt_tok = getattr(usage, "prompt_tokens", 0) if usage else 0
        completion_tok = getattr(usage, "completion_tokens", 0) if usage else 0
        summary = (
            "\n## Mitts Agent Run\n\n"
            "| Metric | Value |\n"
            "| --- | --- |\n"
            f"| Model | `{model}` |\n"
            f"| Cost | ${cost:.4f} |\n"
            f"| Prompt tokens | {prompt_tok:,} |\n"
            f"| Completion tokens | {completion_tok:,} |\n"
            f"| Skills loaded | {len(skills_map)} |\n"
        )
        print(summary)
        _write_step_summary(summary)
    except Exception as exc:
        logger.warning("Could not read conversation metrics: %s", exc)

    # --- Exit non-zero on ERROR or STUCK so the workflow failure comment fires ---
    status = conversation.state.execution_status
    if status in (ConversationExecutionStatus.ERROR, ConversationExecutionStatus.STUCK):
        print(
            f"::error::Agent run ended with status: {status.value}",
            file=sys.stderr,
        )
        sys.exit(1)


if __name__ == "__main__":
    main()
