# DirectoryAdded API

Available when inheriting from `ClaudeHooks::DirectoryAdded`:

Runs after a working directory is added mid-session via `/add-dir` or the SDK `register_repo_root` control request. Non-blocking — the directory is already added when the hook runs.

## Input Helpers

[📚 Shared input helpers](COMMON.md#input-helpers)

| Method | Description |
|--------|-------------|
| `directory` | Absolute path of the directory that was added |
| `source` | How the directory was added: `'slash_command'` for `/add-dir` or `'register_repo_root'` for the SDK control request |

## Hook State Helpers

[📚 Shared hook state methods](COMMON.md#hook-state-methods)

| Method | Description |
|--------|-------------|
| `system_message!` | Set a message delivered to Claude as context on the next turn (`slash_command`) or written to the debug log (`register_repo_root`) |

## Output Helpers

[📚 Shared output helpers](COMMON.md#output-helpers)

| Method | Description |
|--------|-------------|
| `output.system_message` | The configured system message |

## Hook Exit Codes

Non-blocking. Exit code is ignored; only `systemMessage` is consumed.
