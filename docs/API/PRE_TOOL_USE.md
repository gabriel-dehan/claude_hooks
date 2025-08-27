# PreToolUse API

Available when inheriting from `ClaudeHooks::PreToolUse`:

## Input Helpers
Input helpers to access the data provided by Claude Code through `STDIN`.

[📚 Shared input helpers](COMMON.md#input-helpers)

| Method | Description |
|--------|-------------|
| `tool_name` | Get the name of the tool being used |
| `tool_input` | Get the input data for the tool |

## Hook State Helpers
Hook state methods are helpers to modify the hook's internal state (`output_data`) before yielding back to Claude Code.

[📚 Shared hook state methods](COMMON.md#hook-state-methods)

| Method | Description |
|--------|-------------|
| `approve_tool!(reason)` | Explicitly approve tool usage |
| `block_tool!(reason)` | Block tool usage with feedback |
| `ask_for_permission!(reason)` | Request user permission |

## Output Helpers
Output helpers provide access to the hook's output data and helper methods for working with the output state.

[📚 Shared output helpers](COMMON.md#output-helpers)

| Method | Description |
|--------|-------------|
| `output.allowed?` | Check if the tool has been explicitly allowed (permission_decision == 'allow') |
| `output.denied?` | Check if the tool has been denied (permission_decision == 'deny') |
| `output.blocked?` | Alias for `denied?` |
| `output.should_ask_permission?` | Check if user permission is required (permission_decision == 'ask') |
| `output.permission_decision` | Get the permission decision: 'allow', 'deny', or 'ask' |
| `output.permission_reason` | Get the reason for the permission decision |

## Hook Exit Codes

| Exit Code | Behavior |
|-----------|----------|
| `exit 0` | Operation continues<br/>`STDOUT` shown to user in transcript mode |
| `exit 1` | Non-blocking error<br/>`STDERR` shown to user |
| `exit 2` | **Blocks the tool call**<br/>`STDERR` shown to Claude |