# MessageDisplay API

Available when inheriting from `ClaudeHooks::MessageDisplay`:

Runs when a message is about to be displayed. Can override the displayed text via `hookSpecificOutput.displayContent`.

## Input Helpers

[📚 Shared input helpers](COMMON.md#input-helpers)

| Method | Description |
|--------|-------------|
| `turn_id` | ID of the current turn |
| `message_id` | ID of this message |
| `index` | Position of this message in the turn |
| `final` | Whether this is the final message chunk (`true`/`false`) |
| `delta` | The incremental text content of this message |
| `message_text` | Alias for `delta` |

## Hook State Helpers

[📚 Shared hook state methods](COMMON.md#hook-state-methods)

| Method | Description |
|--------|-------------|
| `display_content!(text)` | Override the displayed text for this message |

## Output Helpers

[📚 Shared output helpers](COMMON.md#output-helpers)

| Method | Description |
|--------|-------------|
| `output.display_content` | Get the overridden display content (if set) |

## Hook Exit Codes

Exit code and output stream are ignored for MessageDisplay. The only honored output is `hookSpecificOutput.displayContent`.
