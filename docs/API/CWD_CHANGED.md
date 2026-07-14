# CwdChanged API

Available when inheriting from `ClaudeHooks::CwdChanged`:

Runs when the working directory changes. Can update the list of watched paths.

## Input Helpers

[📚 Shared input helpers](COMMON.md#input-helpers)

| Method | Description |
|--------|-------------|
| `old_cwd` | The previous working directory |
| `new_cwd` | The new working directory |

## Hook State Helpers

[📚 Shared hook state methods](COMMON.md#hook-state-methods)

| Method | Description |
|--------|-------------|
| `watch_paths!(paths)` | Set the list of paths Claude Code should watch for changes |

## Output Helpers

[📚 Shared output helpers](COMMON.md#output-helpers)

| Method | Description |
|--------|-------------|
| `output.watch_paths` | Get the configured watch paths |

## Hook Exit Codes

Non-blocking. Only `watchPaths` output is consumed.
