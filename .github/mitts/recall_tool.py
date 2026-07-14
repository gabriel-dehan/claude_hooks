"""
Custom OpenHands SDK tool: `recall_prior_reasoning`.

Gives the agent ON-DEMAND access to its OWN reasoning from PRIOR runs on the same
PR/issue thread. We deliberately do NOT auto-replay persisted state into the live
conversation (that would inflate every prompt); instead each run writes its events
to a fresh subdir, and this tool reads the *other* (prior) subdirs when the model
asks — e.g. on a "why did you…" follow-up.

Persisted layout (written by agent_task.py, bridged across runs via artifacts):

    <OPENHANDS_PERSIST_DIR>/<thread-key>/<conversation-id>/
        base_state.json
        events/event-*.json

The tool scans every `<conversation-id>/events/` under the thread key EXCEPT the
current run's, so it only ever returns history, never the in-progress run.
"""

from __future__ import annotations

import os
from collections.abc import Sequence
from pathlib import Path

from pydantic import Field

from openhands.sdk import (
    Action,
    Event,
    LLMConvertibleEvent,
    Observation,
    TextContent,
    ToolDefinition,
    get_logger,
)
from openhands.sdk.tool import ToolExecutor

logger = get_logger(__name__)

# Env the executor reads (set by agent_task.py / the workflow).
PERSIST_DIR_ENV = "OPENHANDS_PERSIST_DIR"
THREAD_KEY_ENV = "OPENHANDS_CONVERSATION_KEY"
# agent_task.py exports the current run's conversation id here so we can exclude it.
CURRENT_ID_ENV = "OPENHANDS_CURRENT_CONVERSATION_ID"

_STALE_BANNER = (
    "[PRIOR-RUN REASONING — this is history from earlier runs on this same "
    "thread and MAY BE OUTDATED. The code/diff may have changed since. Always "
    "verify against the CURRENT diff/thread in your task before relying on it.]"
)

_DESCRIPTION = (
    "Retrieve the assistant's OWN private reasoning and messages from PRIOR runs "
    "on this same PR/issue thread. Use this when a maintainer asks 'why did you…', "
    "references an earlier decision, or when continuity with a previous run matters. "
    "Returns nothing useful on the first run of a thread. This is historical and may "
    "be outdated — the CURRENT diff/code always wins on any conflict."
)


class RecallPriorReasoningAction(Action):
    max_messages: int = Field(
        default=20,
        description="Maximum number of most-recent prior assistant messages to return.",
    )
    query: str | None = Field(
        default=None,
        description="Optional case-insensitive substring to filter prior messages.",
    )


class RecallPriorReasoningObservation(Observation):
    # NB: don't name this "text" — Observation already defines that and Pydantic
    # would shadow it, silently dropping our value.
    recalled: str = Field(default="")

    @property
    def to_llm_content(self) -> Sequence[TextContent]:
        return [TextContent(text=self.recalled)]


def _current_id() -> str | None:
    return os.getenv(CURRENT_ID_ENV)


def _thread_dir() -> Path | None:
    persist = os.getenv(PERSIST_DIR_ENV)
    key = os.getenv(THREAD_KEY_ENV)
    if not persist or not key:
        return None
    # agent_task.py sets persistence_dir to "<persist>/<thread-key>", so run
    # subdirs live directly under it.
    d = Path(persist) / key
    return d if d.is_dir() else None


def _load_prior_messages(max_messages: int, query: str | None) -> list[str]:
    """Load assistant/LLM messages from all prior run subdirs (newest-first).

    Ordering is derived from the SDK's zero-padded, monotonically-increasing
    `event-*.json` filenames — NOT filesystem mtime, which is unreliable after an
    artifact upload/download round-trip (archive extraction doesn't preserve
    original mtimes). Runs are ordered by their newest event filename, and
    messages within a run keep filename order; the two form a stable
    (run, event) sort key that reflects true chronology across restored runs.
    """
    thread_dir = _thread_dir()
    if thread_dir is None:
        return []

    current = _current_id()
    # (sort_key, text): sort_key = (run's newest event name, event name) so runs
    # order by recency and messages order within a run — all newest-first.
    rendered: list[tuple[tuple[str, str], str]] = []

    for run_dir in thread_dir.iterdir():
        if not run_dir.is_dir() or run_dir.name == current:
            continue
        events_dir = run_dir / "events"
        if not events_dir.is_dir():
            continue

        event_files = sorted(events_dir.glob("event-*.json"), key=lambda p: p.name)
        if not event_files:
            continue
        run_key = event_files[-1].name  # newest event in this run

        for event_file in event_files:
            try:
                event = Event.model_validate_json(event_file.read_text())
            except Exception as exc:  # tolerate schema drift / partial writes
                logger.warning("Skipping unreadable event %s: %s", event_file, exc)
                continue
            if not isinstance(event, LLMConvertibleEvent):
                continue
            try:
                message = event.to_llm_message()
            except Exception:
                continue
            if getattr(message, "role", None) != "assistant":
                continue
            text = _message_text(message)
            if not text:
                continue
            if query and query.lower() not in text.lower():
                continue
            rendered.append(((run_key, event_file.name), f"(run {run_dir.name[:8]})\n{text}"))

    rendered.sort(key=lambda pair: pair[0], reverse=True)
    return [text for _, text in rendered[:max_messages]]


def _message_text(message) -> str:
    """Extract plain text from an LLM message whose content may be str or blocks."""
    content = getattr(message, "content", None)
    if isinstance(content, str):
        return content.strip()
    if isinstance(content, (list, tuple)):
        parts = [getattr(block, "text", "") for block in content]
        return "\n".join(p for p in parts if p).strip()
    return ""


class RecallPriorReasoningExecutor(
    ToolExecutor[RecallPriorReasoningAction, RecallPriorReasoningObservation]
):
    def __call__(
        self, action: RecallPriorReasoningAction, conversation=None
    ) -> RecallPriorReasoningObservation:  # noqa: ARG002
        messages = _load_prior_messages(action.max_messages, action.query)
        if not messages:
            return RecallPriorReasoningObservation(
                recalled="No prior reasoning available for this thread (this is likely "
                "the first run, or nothing matched your query)."
            )
        body = "\n\n---\n\n".join(messages)
        return RecallPriorReasoningObservation(recalled=f"{_STALE_BANNER}\n\n{body}")


class RecallPriorReasoningTool(
    ToolDefinition[RecallPriorReasoningAction, RecallPriorReasoningObservation]
):
    """Read the agent's own reasoning from prior runs on this PR/issue thread."""

    @classmethod
    def create(cls, conv_state=None, **params) -> Sequence[ToolDefinition]:  # noqa: ARG003
        return [
            cls(
                description=_DESCRIPTION,
                action_type=RecallPriorReasoningAction,
                observation_type=RecallPriorReasoningObservation,
                executor=RecallPriorReasoningExecutor(),
            )
        ]
