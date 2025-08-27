# PreCompact API

Available when inheriting from `ClaudeHooks::PreCompact`:

## Input Methods
Input methods are helpers to access data parsed from STDIN.

| Method | Description |
|--------|-------------|
| `trigger` | Get the compaction trigger: `'manual'` or `'auto'` |
| `custom_instructions` | Get custom instructions (only available for manual trigger) |

## Output Methods
No specific output methods are available to alter compaction behavior.

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

## Input Fields

| Field | Description |
|-------|-------------|
| `trigger` | The compaction trigger: `'manual'` or `'auto'` |
| `custom_instructions` | Custom instructions (only available for manual trigger) |

Along with the [common input fields](COMMON.md#input-methods).