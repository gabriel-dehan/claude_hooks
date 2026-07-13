#!/usr/bin/env python3
"""
Generic OpenHands agent runner for GitHub Actions.

Runs an OpenHands SDK agent inside the Actions runner with full repo access,
using YOUR OpenAI-compatible LLM endpoint (LLM_BASE_URL / LLM_MODEL / LLM_API_KEY).
The agent uses bash + the `gh` CLI (authenticated via GITHUB_TOKEN) to read
issues/PRs, make code changes, commit, push a branch, and open/update PRs.

This is intentionally a single generic script: the WORKFLOW decides the task by
setting AGENT_PROMPT. See the workflows in .github/workflows/openhands-*.yml.

Required env:
    LLM_API_KEY    API key for your OpenAI-compatible endpoint
    LLM_MODEL      LiteLLM model id, e.g. "openai/<your-model-name>"
    LLM_BASE_URL   Base URL of your OpenAI-compatible endpoint
    GITHUB_TOKEN   Token with contents:write + pull-requests:write + issues:write
    GITHUB_REPOSITORY  owner/repo (provided automatically by Actions)
    AGENT_PROMPT   The full task instruction for the agent (set by the workflow)

Optional env:
    LLM_MAX_ITER   Max agent iterations (default 60)
"""

from __future__ import annotations

import os
import sys

from openhands.sdk import (
    LLM,
    Agent,
    Conversation,
    get_logger,
)
from openhands.sdk.conversation import get_agent_final_response
from openhands.tools.preset.default import get_default_condenser, get_default_tools

logger = get_logger(__name__)


def require(name: str) -> str:
    val = os.getenv(name)
    if not val:
        print(f"::error::Missing required environment variable: {name}")
        sys.exit(1)
    return val


def main() -> None:
    api_key = require("LLM_API_KEY")
    model = require("LLM_MODEL")           # e.g. openai/<your-model>
    base_url = os.getenv("LLM_BASE_URL")   # your OpenAI-compatible endpoint
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

    # Default toolset: terminal (bash), file editor, task tracker.
    # Browser disabled — not needed for code/PR work and keeps the runner lean.
    tools = get_default_tools(enable_browser=False)

    agent = Agent(
        llm=llm,
        tools=tools,
        system_prompt_kwargs={"cli_mode": True},
        condenser=get_default_condenser(
            llm=llm.model_copy(update={"usage_id": "condenser"})
        ),
    )

    # Secrets passed to the workspace are masked in logs AND exported into the
    # agent's shell env, so `gh` and `git` are authenticated automatically.
    secrets = {
        "GITHUB_TOKEN": os.environ["GITHUB_TOKEN"],
        "GH_TOKEN": os.environ["GITHUB_TOKEN"],
    }

    conversation = Conversation(
        agent=agent,
        workspace=os.getcwd(),
        secrets=secrets,
        max_iterations=max_iterations,
    )

    logger.info("Sending task to agent...")
    conversation.send_message(prompt)
    conversation.run()

    final = get_agent_final_response(conversation.state.events)
    print("\n===== AGENT FINAL RESPONSE =====\n")
    print(final or "(no final response)")


if __name__ == "__main__":
    main()
