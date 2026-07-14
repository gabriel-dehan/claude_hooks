# PostToolBatch API

Available when inheriting from `ClaudeHooks::PostToolBatch`:

Runs after a full batch of tool calls completes. Can block Claude from continuing.

## Input Helpers

[📚 Shared input helpers](COMMON.md#input-helpers)

| Method | Description |
|--------|-------------|
| `tool_calls` | Array of tool call results; each entry has `tool_name`, `tool_input`, `tool_use_id`, `tool_response` |

## Hook State Helpers

[📚 Shared hook state methods](COMMON.md#hook-state-methods)

| Method | Description |
|--------|-------------|
| `block!(reason)` | Block Claude from continuing after this batch |
| `add_additional_context!(context)` | Add additional context visible to Claude |

## Output Helpers

[📚 Shared output helpers](COMMON.md#output-helpers)

| Method | Description |
|--------|-------------|
| `output.blocked?` | Check if the batch was blocked |
| `output.decision` | Get the decision (`'block'` or nil) |
| `output.reason` | Get the block reason |

## Hook Exit Codes

| Exit Code | Behavior |
|-----------|----------|
| `exit 0` | Claude continues |
| `exit 2` | Blocks Claude; `STDERR` shown to Claude |
