# WorktreeRemove API

Available when inheriting from `ClaudeHooks::WorktreeRemove`:

Runs when a worktree is removed. Pair it with a `WorktreeCreate` hook to control cleanup of the worktrees that hook creates. For those worktrees, **the hook does the cleanup**: Claude Code reads only its exit code and doesn't fall back to `git worktree remove` (it only does that when no `WorktreeRemove` hook is configured). Claude Code discards this hook's JSON output (`systemMessage`, `continue`, …); only the exit code matters, so `prevent_continue!` is what produces the non-zero exit. Claude Code never deletes a branch belonging to a hook-created worktree — if your `WorktreeCreate` hook created a branch, delete it here.

## Input Helpers

[📚 Shared input helpers](COMMON.md#input-helpers)

| Method | Description |
|--------|-------------|
| `worktree_path` | The path of the worktree being removed |

## Hook State Helpers

[📚 Shared hook state methods](COMMON.md#hook-state-methods)

| Method | Description |
|--------|-------------|
| `prevent_continue!(reason)` | Report that removal failed (results in exit 2) |

## Output Helpers

[📚 Shared output helpers](COMMON.md#output-helpers)

| Method | Description |
|--------|-------------|
| `output.continue?` | `false` when the hook reports failure (exit 2) |
| `output.stop_reason` | The failure reason |

## Hook Exit Codes

| Exit Code | Behavior |
|-----------|----------|
| `exit 0` | The worktree **counts as removed** — make sure your hook deleted the directory |
| `exit 2` | **The removal fails** if the directory at `worktree_path` still exists; it stays on disk with no git fallback. A hook that deleted the directory before exiting non-zero still counts as removed |
