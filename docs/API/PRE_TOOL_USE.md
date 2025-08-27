# PreToolUse API

Available when inheriting from `ClaudeHooks::PreToolUse`:

## Input Methods
Input methods are helpers to access data parsed from STDIN.

| Method | Description |
|--------|-------------|
| `tool_name` | Get the name of the tool being used |
| `tool_input` | Get the input data for the tool |

## Output Methods
Output methods are helpers to modify the hook's internal state (`output_data`) before yielding back to Claude Code.

| Method | Description |
|--------|-------------|
| `approve_tool!(reason)` | Explicitly approve tool usage |
| `block_tool!(reason)` | Block tool usage with feedback |
| `ask_for_permission!(reason)` | Request user permission |

## Hook Exit Codes

| Exit Code | Behavior |
|-----------|----------|
| `exit 0` | Operation continues<br/>`STDOUT` shown to user in transcript mode |
| `exit 1` | Non-blocking error<br/>`STDERR` shown to user |
| `exit 2` | **Blocks the tool call**<br/>`STDERR` shown to Claude |

## Input Fields

| Field | Description |
|-------|-------------|
| `tool_name` | Name of the tool being used |
| `tool_input` | Input data for the tool |

Along with the [common input fields](COMMON.md#input-methods).