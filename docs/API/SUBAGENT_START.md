# SubagentStart API

Available when inheriting from `ClaudeHooks::SubagentStart`:

Runs when a subagent task starts. Use it to inject context specific to the subagent or log the start.

## Input Helpers

[📚 Shared input helpers](COMMON.md#input-helpers)

The `agent_id` and `agent_type` common fields are populated for this event.

| Method | Description |
|--------|-------------|
| `agent_id` | The subagent's unique ID |
| `agent_type` | The subagent's type |

## Hook State Helpers

[📚 Shared hook state methods](COMMON.md#hook-state-methods)

| Method | Description |
|--------|-------------|
| `add_additional_context!(context)` | Add contextual information for the subagent |
| `add_context!(context)` | Alias for `add_additional_context!` |

## Output Helpers

[📚 Shared output helpers](COMMON.md#output-helpers)

| Method | Description |
|--------|-------------|
| `output.additional_context` | Get the additional context that was added |

## Hook Exit Codes

| Exit Code | Behavior |
|-----------|----------|
| `exit 0` | Continues normally; `STDOUT` added as context |
| `exit 2` | N/A — non-blocking event |
