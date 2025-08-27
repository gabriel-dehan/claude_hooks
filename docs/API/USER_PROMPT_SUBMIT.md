# UserPromptSubmit API

Available when inheriting from `ClaudeHooks::UserPromptSubmit`:

## Input Methods
Input methods are helpers to access data parsed from STDIN.

| Method | Description |
|--------|-------------|
| `prompt` | Get the user's prompt text |
| `user_prompt` | Alias for `prompt` |
| `current_prompt` | Alias for `prompt` |

## Output Methods
Output methods are helpers to modify the hook's internal state (`output_data`) before yielding back to Claude Code.

| Method | Description |
|--------|-------------|
| `add_additional_context!(context)` | Add context to the prompt |
| `add_context!(context)` | Alias for `add_additional_context!` |
| `empty_additional_context!` | Remove additional context |
| `block_prompt!(reason)` | Block the prompt from processing |
| `unblock_prompt!` | Unblock a previously blocked prompt |

## Hook Exit Codes

| Exit Code | Behavior |
|-----------|----------|
| `exit 0` | Operation continues<br/>**`STDOUT` added as context to Claude** |
| `exit 1` | Non-blocking error<br/>`STDERR` shown to user |
| `exit 2` | **Blocks prompt processing**<br/>**Erases prompt**<br/>`STDERR` shown to user only |

## Input Fields

| Field | Description |
|-------|-------------|
| `prompt` | The user's prompt text |

Along with the [common input fields](COMMON.md#input-methods).