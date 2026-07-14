# WorktreeCreate API

Available when inheriting from `ClaudeHooks::WorktreeCreate`:

Runs when Claude Code is about to create a git worktree. **Special contract**: the hook must print the worktree path as the last non-empty line of stdout and exit 0. An empty or missing path is treated as failure.

## Input Helpers

[📚 Shared input helpers](COMMON.md#input-helpers)

| Method | Description |
|--------|-------------|
| `name` | The slug/name for the worktree (e.g. `'feature-x'`) |

## Hook State Helpers

[📚 Shared hook state methods](COMMON.md#hook-state-methods)

| Method | Description |
|--------|-------------|
| `worktree_path!(path)` | Set the path where the worktree will be created |

## Output Helpers

[📚 Shared output helpers](COMMON.md#output-helpers)

| Method | Description |
|--------|-------------|
| `output.worktree_path` | Get the configured worktree path |

## Hook Exit Codes

| Exit Code | Behavior |
|-----------|----------|
| `exit 0` (with path on stdout) | Worktree created at the printed path |
| `exit 1` / empty stdout | Creation fails |

> [!IMPORTANT]
> `output_and_exit` for WorktreeCreate prints the **bare path** (not JSON). Do not emit JSON for this hook type.
