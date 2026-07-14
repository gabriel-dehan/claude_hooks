# ConfigChange API

Available when inheriting from `ClaudeHooks::ConfigChange`:

Runs when Claude Code configuration changes. Can block the change for most sources (note: `policy_settings` changes cannot be blocked).

## Input Helpers

[📚 Shared input helpers](COMMON.md#input-helpers)

| Method | Description |
|--------|-------------|
| `source` | The source of the config change (e.g. `'project'`, `'user'`, `'policy_settings'`) |
| `file_path` | Path to the changed config file (optional) |

## Hook State Helpers

[📚 Shared hook state methods](COMMON.md#hook-state-methods)

| Method | Description |
|--------|-------------|
| `block!(reason)` | Block the config change (ineffective for `policy_settings`) |

## Output Helpers

[📚 Shared output helpers](COMMON.md#output-helpers)

| Method | Description |
|--------|-------------|
| `output.blocked?` | Check if the change was blocked |
| `output.decision` | Get the decision (`'block'` or nil) |
| `output.reason` | Get the block reason |

## Hook Exit Codes

| Exit Code | Behavior |
|-----------|----------|
| `exit 0` | Config change proceeds |
| `exit 2` | Blocks the change; `STDERR` shown to Claude |
