# WorktreeRemove API

Available when inheriting from `ClaudeHooks::WorktreeRemove`:

Runs when a git worktree is removed. Can block the removal: a non-zero exit now **fails** the worktree removal when the directory still exists.

## Input Helpers

[📚 Shared input helpers](COMMON.md#input-helpers)

| Method | Description |
|--------|-------------|
| `worktree_path` | The path of the worktree being removed |

## Hook State Helpers

[📚 Shared hook state methods](COMMON.md#hook-state-methods)

| Method | Description |
|--------|-------------|
| `prevent_continue!(reason)` | Block the worktree removal (results in exit 2) |

## Output Helpers

[📚 Shared output helpers](COMMON.md#output-helpers)

| Method | Description |
|--------|-------------|
| `output.continue?` | Whether the removal is allowed to proceed |
| `output.stop_reason` | The reason the removal was blocked |

## Hook Exit Codes

| Exit Code | Behavior |
|-----------|----------|
| `exit 0` | Worktree removal proceeds |
| `exit 2` | **Fails the worktree removal** (when the directory still exists) |
