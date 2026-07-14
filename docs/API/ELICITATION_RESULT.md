# ElicitationResult API

Available when inheriting from `ClaudeHooks::ElicitationResult`:

Runs after a user has responded to an elicitation dialog. Can override the action or content before it is sent back to the MCP server.

## Input Helpers

[📚 Shared input helpers](COMMON.md#input-helpers)

| Method | Description |
|--------|-------------|
| `mcp_server_name` | The MCP server that requested input |
| `action` | The user's chosen action: `'accept'`, `'decline'`, or `'cancel'` |
| `mode` | Optional interaction mode |
| `elicitation_id` | Optional unique ID for this elicitation |
| `content` | The content the user provided (for `'accept'` action) |

## Hook State Helpers

[📚 Shared hook state methods](COMMON.md#hook-state-methods)

| Method | Description |
|--------|-------------|
| `accept!(content = {})` | Override the response with an accept + content |
| `decline!` | Override the response to decline |
| `cancel!` | Override the response to cancel |

## Output Helpers

[📚 Shared output helpers](COMMON.md#output-helpers)

| Method | Description |
|--------|-------------|
| `output.action` | Get the (possibly overridden) action |
| `output.content` | Get the (possibly overridden) content |
| `output.accepted?` | Check if the action is `'accept'` |
| `output.declined?` | Check if the action is `'decline'` |
| `output.cancelled?` | Check if the action is `'cancel'` |

## Hook Exit Codes

Uses the JSON API (exit 0 / stdout).
