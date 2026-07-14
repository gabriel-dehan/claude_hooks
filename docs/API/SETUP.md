# Setup API

Available when inheriting from `ClaudeHooks::Setup`:

Runs once during Claude Code startup (before any session begins). Use it to inject global context or perform one-time initialization.

## Input Helpers

[📚 Shared input helpers](COMMON.md#input-helpers)

| Method | Description |
|--------|-------------|
| `source` | Startup reason: `'init'` (first launch) or `'maintenance'` |

## Hook State Helpers

[📚 Shared hook state methods](COMMON.md#hook-state-methods)

| Method | Description |
|--------|-------------|
| `add_additional_context!(context)` | Add contextual information for Claude |
| `add_context!(context)` | Alias for `add_additional_context!` |

## Output Helpers

[📚 Shared output helpers](COMMON.md#output-helpers)

| Method | Description |
|--------|-------------|
| `output.additional_context` | Get the additional context that was added |

## Hook Exit Codes

| Exit Code | Behavior |
|-----------|----------|
| `exit 0` | Continues normally; `STDOUT` added as context |
| `exit 2` | N/A — non-blocking event |
