# Notification API

Available when inheriting from `ClaudeHooks::Notification`:

## Input Fields

| Field | Description |
|-------|-------------|
| `message` | The notification message content |

[Common input fields](README.md#input-fields)

## Input Methods
Input methods are helpers to access data parsed from STDIN.

[📚 Common input methods](COMMON.md#input-methods)

| Method | Description |
|--------|-------------|
| `message` | Get the notification message content |
| `notification_message` | Alias for `message` |

## Hook State Methods
Notifications are outside facing and do not have a specific state to modify.

[📚 Common hook state methods](COMMON.md#hook-state-methods)

## Hook Exit Codes

| Exit Code | Behavior |
|-----------|----------|
| `exit 0` | Operation continues<br/>`STDOUT` shown to user in transcript mode |
| `exit 1` | Non-blocking error<br/>`STDERR` shown to user |
| `exit 2` | N/A<br/>`STDERR` shown to user only |
