# SessionStart API

Available when inheriting from `ClaudeHooks::SessionStart`:

## Input Methods
Input methods are helpers to access data parsed from STDIN.

| Method | Description |
|--------|-------------|
| `source` | Get the session start source: `'startup'`, `'resume'`, or `'clear'` |

## Output Methods
Output methods are helpers to modify the hook's internal state (`output_data`) before yielding back to Claude Code.

| Method | Description |
|--------|-------------|
| `add_additional_context!(context)` | Add contextual information for Claude's session |
| `add_context!(context)` | Alias for `add_additional_context!` |
| `empty_additional_context!` | Clear additional context |

## Hook Exit Codes

| Exit Code | Behavior |
|-----------|----------|
| `exit 0` | Operation continues<br/>**`STDOUT` added as context to Claude** |
| `exit 1` | Non-blocking error<br/>`STDERR` shown to user |
| `exit 2` | N/A<br/>`STDERR` shown to user only |

## Input Fields

| Field | Description |
|-------|-------------|
| `source` | The session start source: `'startup'`, `'resume'`, or `'clear'` |

Along with the [common input fields](COMMON.md#input-methods).