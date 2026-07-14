# PermissionDenied API

Available when inheriting from `ClaudeHooks::PermissionDenied`:

Runs when a permission request is denied. Can request that Claude Code retries the request.

## Input Helpers

[📚 Shared input helpers](COMMON.md#input-helpers)

| Method | Description |
|--------|-------------|
| `tool_name` | The name of the tool whose permission was denied |
| `tool_input` | The input data for the tool |
| `tool_use_id` | The unique identifier for this tool use |
| `reason` | The reason the permission was denied |

## Hook State Helpers

[📚 Shared hook state methods](COMMON.md#hook-state-methods)

| Method | Description |
|--------|-------------|
| `retry!` | Request that Claude Code retry the permission request |
| `no_retry!` | Explicitly decline to retry (default) |

## Output Helpers

[📚 Shared output helpers](COMMON.md#output-helpers)

| Method | Description |
|--------|-------------|
| `output.retry?` | Check if a retry was requested |

## Hook Exit Codes

Exit code is ignored. Output is via `hookSpecificOutput.retry` (JSON API, exit 0 / stdout).
