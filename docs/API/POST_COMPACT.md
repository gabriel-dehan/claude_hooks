# PostCompact API

Available when inheriting from `ClaudeHooks::PostCompact`:

Runs after transcript compaction completes. Non-blocking — use for logging or post-compaction side effects.

## Input Helpers

[📚 Shared input helpers](COMMON.md#input-helpers)

| Method | Description |
|--------|-------------|
| `trigger` | What triggered the compaction: `'auto'` or `'manual'` |
| `compact_summary` | The summary produced by the compaction |

## Hook State Helpers

[📚 Shared hook state methods](COMMON.md#hook-state-methods)

No event-specific state methods — this hook is non-blocking.

## Output Helpers

[📚 Shared output helpers](COMMON.md#output-helpers)

No event-specific output helpers.

## Hook Exit Codes

Non-blocking. Exit code is ignored.
