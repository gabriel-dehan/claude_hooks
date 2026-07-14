# PostToolUseFailure API

Available when inheriting from `ClaudeHooks::PostToolUseFailure`:

Runs when a tool call fails. Non-blocking — output and exit code are ignored except for `additionalContext`.

## Input Helpers

[📚 Shared input helpers](COMMON.md#input-helpers)

| Method | Description |
|--------|-------------|
| `tool_name` | The name of the tool that failed |
| `tool_input` | The input data for the tool |
| `tool_use_id` | The unique identifier for this tool use |
| `error` | The error message |
| `is_interrupt` | Whether the failure was caused by an interrupt (`true`/`false`) |
| `interrupt?` | Alias for `is_interrupt` |
| `duration_ms` | How long the tool ran before failing (milliseconds) |

## Hook State Helpers

[📚 Shared hook state methods](COMMON.md#hook-state-methods)

| Method | Description |
|--------|-------------|
| `add_additional_context!(context)` | Add additional context visible to Claude about the failure |

## Hook Exit Codes

Non-blocking. Exit code and output are ignored by Claude Code; only `additionalContext` is consumed.
