# WorktreeRemove API

Available when inheriting from `ClaudeHooks::WorktreeRemove`:

Runs when a git worktree is removed. Non-blocking — only `suppressOutput` is honored.

## Input Helpers

[📚 Shared input helpers](COMMON.md#input-helpers)

| Method | Description |
|--------|-------------|
| `worktree_path` | The path of the worktree being removed |

## Hook State Helpers

[📚 Shared hook state methods](COMMON.md#hook-state-methods)

| Method | Description |
|--------|-------------|
| `suppress_output!` | Hide this hook's `STDOUT` from transcript mode (the only honored output control) |

## Output Helpers

[📚 Shared output helpers](COMMON.md#output-helpers)

| Method | Description |
|--------|-------------|
| `output.suppress_output?` | Whether output is suppressed |

## Hook Exit Codes

Non-blocking. Exit code is ignored; only `suppressOutput` affects behavior.
