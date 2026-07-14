# Elicitation API

Available when inheriting from `ClaudeHooks::Elicitation`:

Runs when an MCP server requests user input (an elicitation dialog). Can accept, decline, or cancel the request.

## Input Helpers

[📚 Shared input helpers](COMMON.md#input-helpers)

| Method | Description |
|--------|-------------|
| `mcp_server_name` | The MCP server requesting input |
| `message` | The message / prompt shown to the user |
| `mode` | Optional interaction mode |
| `url` | Optional URL associated with the request |
| `elicitation_id` | Optional unique ID for this elicitation |
| `requested_schema` | Optional JSON schema describing the expected response |

## Hook State Helpers

[📚 Shared hook state methods](COMMON.md#hook-state-methods)

| Method | Description |
|--------|-------------|
| `accept!(content = {})` | Accept the elicitation with optional content hash |
| `decline!` | Decline the elicitation |
| `cancel!` | Cancel the elicitation |

## Output Helpers

[📚 Shared output helpers](COMMON.md#output-helpers)

| Method | Description |
|--------|-------------|
| `output.action` | Get the chosen action: `'accept'`, `'decline'`, or `'cancel'` |
| `output.content` | Get the accepted content hash |
| `output.accepted?` | Check if the elicitation was accepted |
| `output.declined?` | Check if the elicitation was declined |
| `output.cancelled?` | Check if the elicitation was cancelled |

## Hook Exit Codes

Uses the JSON API (exit 0 / stdout). The `hookSpecificOutput.action` field controls the response.
