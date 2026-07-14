# StopFailure API

Available when inheriting from `ClaudeHooks::StopFailure`:

Runs when the stop phase itself errors. Purely a logging event — output and exit code are completely ignored by Claude Code.

## Input Helpers

[📚 Shared input helpers](COMMON.md#input-helpers)

| Method | Description |
|--------|-------------|
| `error` | The error message |
| `error_details` | Additional error detail (stack trace, etc.) |
| `last_assistant_message` | The last message Claude produced before the failure |

## Hook Exit Codes

Exit code and all output are ignored. Use this hook only for logging or alerting.
