# TaskCreated API

Available when inheriting from `ClaudeHooks::TaskCreated`:

Runs when a teammate task is created. Block task creation via `block!` (top-level `decision: "block"`) or exit 2. Claude Code **ignores** `continue: false` for this event, so `prevent_continue!` alone no longer blocks unless it results in exit 2.

## Input Helpers

[📚 Shared input helpers](COMMON.md#input-helpers)

| Method | Description |
|--------|-------------|
| `task_id` | The unique task ID |
| `task_subject` | Short title of the task |
| `task_description` | Optional longer description |
| `teammate_name` | The teammate assigned to the task |
| `team_name` | The team name |

## Hook State Helpers

[📚 Shared hook state methods](COMMON.md#hook-state-methods)

| Method | Description |
|--------|-------------|
| `block!(reason)` | Block task creation via top-level `decision: "block"`; `reason` is returned to Claude as the task-creation error |
| `allow!` / `unblock!` | Clear a previously set block |

Block via `block!` (top-level `decision`) or exit 2. `continue: false` is ignored for this event.

## Output Helpers

[📚 Shared output helpers](COMMON.md#output-helpers)

| Method | Description |
|--------|-------------|
| `output.decision` | The decision (`'block'` or `nil`) |
| `output.reason` | The block reason returned to Claude |
| `output.blocked?` | Whether task creation was blocked (`decision == 'block'`) |

## Hook Exit Codes

| Exit Code | Behavior |
|-----------|----------|
| `exit 0` | Task creation proceeds (unless `decision: "block"` is set) |
| `exit 2` | Blocks task creation |
