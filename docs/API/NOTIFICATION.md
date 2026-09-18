# Notification API

Available when inheriting from `ClaudeHooks::Notification`:

## Input Helpers
Input helpers to access the data provided by Claude Code through `STDIN`.

[📚 Shared input helpers](COMMON.md#input-helpers)

| Method | Description |
|--------|-------------|
| `message` | Get the notification message content |
| `notification_message` | Alias for `message` |
| `notification_type` | Get the notification type: `'permission_prompt'`, `'idle_prompt'`, `'auth_success'`, `'elicitation_dialog'`, `'elicitation_url_dialog'`, `'elicitation_complete'`, `'elicitation_response'`, `'agent_needs_input'`, `'agent_completed'`, `'quota_auto_resume_fired'`, `'quota_auto_resume_stale'`, `'quota_auto_resume_disabled'` |

## Hook State Helpers
Notifications are outside facing and do not have any specific state to modify.

[📚 Shared hook state methods](COMMON.md#hook-state-methods)

## Output Helpers
Output helpers provide access to the hook's output data and helper methods for working with the output state.
Notifications don't have any specific hook state and thus doesn't have any specific output helpers.

[📚 Shared output helpers](COMMON.md#output-helpers)

## Hook Exit Codes

Claude Code **ignores** a Notification hook's exit code and stderr, and discards `systemMessage`/`continue`, while still emitting `terminalSequence`. `ClaudeHooks::Output::Notification` therefore always exits `0` and writes JSON to stdout — even after `prevent_continue!` — so the `terminal_sequence!` (desktop-notification) pattern keeps working.

| Exit Code | Behavior |
|-----------|----------|
| `exit 0` | Ignored — always the effective exit code |
| any other | Ignored (exit code and stderr are discarded) |
