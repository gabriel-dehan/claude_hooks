# Stop API

Available when inheriting from `ClaudeHooks::Stop`:

## Input Methods
Input methods are helpers to access data parsed from STDIN.

| Method | Description |
|--------|-------------|
| `stop_hook_active` | Check if Claude Code is already continuing as a result of a stop hook |

## Output Methods
Output methods are helpers to modify the hook's internal state (`output_data`) before yielding back to Claude Code.

| Method | Description |
|--------|-------------|
| `continue_with_instructions!(instructions)` | Block Claude from stopping and provide instructions to continue |
| `block!(instructions)` | Alias for `continue_with_instructions!` |
| `ensure_stopping!` | Allow Claude to stop normally (default behavior) |

## Hook Exit Codes

| Exit Code | Behavior |
|-----------|----------|
| `exit 0` | Operation continues<br/>`STDOUT` shown to user in transcript mode |
| `exit 1` | Non-blocking error<br/>`STDERR` shown to user |
| `exit 2` | **Blocks stoppage**<br/>`STDERR` shown to Claude |

## Input Fields

| Field | Description |
|-------|-------------|
| `stop_hook_active` | Whether Claude Code is already continuing as a result of a stop hook |

Along with the [common input fields](COMMON.md#input-methods).