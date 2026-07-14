# UserPromptExpansion API

Available when inheriting from `ClaudeHooks::UserPromptExpansion`:

Runs when a slash command or other prompt-expansion mechanism is triggered. Can block the expansion.

## Input Helpers

[📚 Shared input helpers](COMMON.md#input-helpers)

| Method | Description |
|--------|-------------|
| `expansion_type` | Type of expansion (e.g. `'slash_command'`) |
| `command_name` | The command name (without the `/`) |
| `command_args` | The arguments passed to the command |
| `command_source` | Where the command was defined (`'user'`, `'project'`, etc.) |
| `prompt` | The expanded prompt text |

## Hook State Helpers

[📚 Shared hook state methods](COMMON.md#hook-state-methods)

| Method | Description |
|--------|-------------|
| `block!(reason)` | Block the expansion with a reason |
| `add_additional_context!(context)` | Add additional context visible to Claude |

## Output Helpers

[📚 Shared output helpers](COMMON.md#output-helpers)

| Method | Description |
|--------|-------------|
| `output.blocked?` | Check if the expansion was blocked |
| `output.decision` | Get the decision (`'block'` or nil) |
| `output.reason` | Get the block reason |

## Hook Exit Codes

| Exit Code | Behavior |
|-----------|----------|
| `exit 0` | Expansion proceeds |
| `exit 2` | Blocks the expansion; `STDERR` shown to Claude |
