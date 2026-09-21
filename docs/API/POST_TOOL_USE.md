# PostToolUse API

Available when inheriting from `ClaudeHooks::PostToolUse`:

## Input Helpers
Input helpers to access the data provided by Claude Code through `STDIN`.

[📚 Shared input helpers](COMMON.md#input-helpers)

| Method | Description |
|--------|-------------|
| `tool_name` | Get the name of the tool that was used |
| `tool_input` | Get the input that was passed to the tool |
| `tool_response` | Get the tool's response/output |
| `tool_use_id` | Get the unique identifier for this tool use (e.g., `"toolu_01ABC123..."`) |

## Hook State Helpers
Hook state methods are helpers to modify the hook's internal state (`output_data`) before yielding back to Claude Code.

[📚 Shared hook state methods](COMMON.md#hook-state-methods)

| Method | Description |
|--------|-------------|
| `block_tool!(reason)` | Block the tool result from being used |
| `approve_tool!(reason)` | Clear any previous block decision (default behavior) |
| `add_additional_context!(context)` | Add context for Claude to consider after tool use |
| `update_tool_output!(value)` | Rewrite the tool output shown to Claude |
| `update_mcp_tool_output!(value)` | Rewrite an MCP tool's output |
| `classifier_context!(note)` | Add a short note about this call's result for the auto-mode classifier, not for Claude (Claude Code v2.1.236+) |

## Output Helpers
Output helpers provide access to the hook's output data and helper methods for working with the output state.

[📚 Shared output helpers](COMMON.md#output-helpers)

| Method | Description |
|--------|-------------|
| `output.decision` | Get the decision: "block" or nil (default) |
| `output.reason` | Get the reason that was set for the decision |
| `output.blocked?` | Check if the tool result has been blocked |
| `output.additional_context` | Get the additional context that was added |
| `output.classifier_context` | Get the note sent to the auto-mode classifier |
| `output.updated_tool_output` | Get the rewritten tool output (if any) |
| `output.updated_mcp_tool_output` | Get the rewritten MCP tool output (if any) |

## Hook Exit Codes

| Exit Code | Behavior |
|-----------|----------|
| `exit 0` | Operation continues<br/>`STDOUT` shown to user in transcript mode |
| `exit 1` | Non-blocking error<br/>`STDERR` shown to user |
| `exit 2` | N/A<br/>`STDERR` shown to Claude *(tool already ran)* |