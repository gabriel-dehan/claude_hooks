# PreCompact API

Available when inheriting from `ClaudeHooks::PreCompact`:

## Input Helpers
Input helpers to access the data provided by Claude Code through `STDIN`.

[📚 Shared input helpers](COMMON.md#input-helpers)

| Method | Description |
|--------|-------------|
| `trigger` | Get the compaction trigger: `'manual'` or `'auto'` |
| `custom_instructions` | Get custom instructions (only available for manual trigger) |

## Hook State Helpers
No specific hook state methods are available to alter compaction behavior.

[📚 Shared hook state methods](COMMON.md#hook-state-methods)

## Utility Methods
Utility methods for transcript management.

| Method | Description |
|--------|-------------|
| `backup_transcript!(backup_file_path)` | Create a backup of the transcript at the specified path |

## Hook Exit Codes

| Exit Code | Behavior |
|-----------|----------|
| `exit 0` | Operation continues<br/>`STDOUT` shown to user in transcript mode |
| `exit 1` | Non-blocking error<br/>`STDERR` shown to user |
| `exit 2` | N/A<br/>`STDERR` shown to user only |