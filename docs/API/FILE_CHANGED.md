# FileChanged API

Available when inheriting from `ClaudeHooks::FileChanged`:

Runs when a watched file is created, modified, or deleted. Can update the watch paths list.

## Input Helpers

[📚 Shared input helpers](COMMON.md#input-helpers)

| Method | Description |
|--------|-------------|
| `file_path` | The path of the changed file |
| `event` | The type of change: `'change'`, `'add'`, or `'unlink'` |
| `modified?` | Convenience: `event == 'change'` |
| `created?` | Convenience: `event == 'add'` |
| `deleted?` | Convenience: `event == 'unlink'` |

## Hook State Helpers

[📚 Shared hook state methods](COMMON.md#hook-state-methods)

| Method | Description |
|--------|-------------|
| `watch_paths!(paths)` | Update the list of paths Claude Code should watch |

## Output Helpers

[📚 Shared output helpers](COMMON.md#output-helpers)

| Method | Description |
|--------|-------------|
| `output.watch_paths` | Get the configured watch paths |

## Hook Exit Codes

Non-blocking. Only `watchPaths` output is consumed.
