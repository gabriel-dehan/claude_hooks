# Notification API

Available when inheriting from `ClaudeHooks::Notification`:

## Input Fields
[📚 Shared input fields](README.md#input-fields)

| Field | Description |
|-------|-------------|
| `message` | The notification message content |


## Input Methods
[📚 Shared input methods](COMMON.md#input-methods)

Input methods are helpers to access data parsed from STDIN.

| Method | Description |
|--------|-------------|
| `message` | Get the notification message content |
| `notification_message` | Alias for `message` |

## Hook State Methods
[📚 Shared hook state methods](COMMON.md#hook-state-methods)

Notifications are outside facing and do not have any specific state to modify.

## Hook Exit Codes

| Exit Code | Behavior |
|-----------|----------|
| `exit 0` | Operation continues<br/>`STDOUT` shown to user in transcript mode |
| `exit 1` | Non-blocking error<br/>`STDERR` shown to user |
| `exit 2` | N/A<br/>`STDERR` shown to user only |
