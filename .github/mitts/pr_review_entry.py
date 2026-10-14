"""
Entry point for the Mitts PR review.

The review itself is the upstream OpenHands/extensions `pr-review` script, which
builds its LLM from LLM_MODEL / LLM_API_KEY / LLM_BASE_URL only and has no way to
pass extra request headers. Our OpenCode ("Console Go") gateway rejects requests
without them, so this wrapper adds the same headers agent_task.py sends, then runs
the upstream script unchanged.

Usage (from the PR checkout, inside the workflow's `uv run` environment):
    python .github/mitts/pr_review_entry.py ../extensions/plugins/pr-review/scripts/agent_script.py

Env:
    OPENHANDS_CONVERSATION_KEY   Thread key, e.g. "pr-42" (sent as x-opencode-session)
"""
from __future__ import annotations

import os
import runpy
import sys

from openhands.sdk import LLM


def mitts_extra_headers() -> dict[str, str]:
    # The OpenCode ("Console Go") gateway rejects requests that don't identify a
    # conversation, with `400 MissingSessionID`, and expects a non-generic
    # user-agent (see https://opencode.ai/docs/go/). Send a stable per-thread
    # session id (our conversation key, e.g. "pr-42") so routing and prompt
    # caching work, plus a named agent user-agent. These headers are harmless on
    # other OpenAI-compatible backends, which ignore unknown headers.
    # Keep in sync with the llm_config in agent_task.py.
    extra_headers: dict[str, str] = {"User-Agent": "mitts-agent/1.0"}
    session_id = os.getenv("OPENHANDS_CONVERSATION_KEY")
    if session_id:
        extra_headers["x-opencode-session"] = session_id
    return extra_headers


def install_llm_headers(headers: dict[str, str]) -> None:
    """Make every LLM(...) the upstream script builds carry our headers.

    Wraps LLM.__init__ in place instead of subclassing, so the class identity (and
    its serialized `kind`) stays the one the SDK expects. Headers the caller passes
    explicitly win over ours. Copies made with model_copy keep the headers.
    """
    original_init = LLM.__init__

    def __init__(self, /, **data):
        data["extra_headers"] = {**headers, **(data.get("extra_headers") or {})}
        original_init(self, **data)

    LLM.__init__ = __init__


def main() -> None:
    if len(sys.argv) != 2:
        sys.exit("usage: pr_review_entry.py <path/to/upstream/agent_script.py>")
    script = sys.argv[1]

    install_llm_headers(mitts_extra_headers())

    # Run the upstream script as if invoked directly (it relies on __file__ and
    # the __main__ guard).
    sys.argv = [script]
    runpy.run_path(script, run_name="__main__")


if __name__ == "__main__":
    main()
