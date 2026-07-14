# TaskCreated API

Available when inheriting from `ClaudeHooks::TaskCreated`:

Runs when a teammate task is created. Can block Claude from continuing via `prevent_continue!` or exit 2.

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
| `prevent_continue!(reason)` | Block Claude from continuing (`continue: false` + `stopReason`) |

There is no top-level `decision` field for this event — block via `prevent_continue!` or exit 2.

## Output Helpers

[📚 Shared output helpers](COMMON.md#output-helpers)

| Method | Description |
|--------|-------------|
| `output.continue?` | Whether Claude will continue |
| `output.stop_reason` | The reason Claude was stopped |

## Hook Exit Codes

| Exit Code | Behavior |
|-----------|----------|
| `exit 0` | Claude continues |
| `exit 2` | Blocks Claude (`continue: false`) |
