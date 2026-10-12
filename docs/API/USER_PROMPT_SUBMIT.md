# UserPromptSubmit API

Available when inheriting from `ClaudeHooks::UserPromptSubmit`:

## Input Helpers
Input helpers to access the data provided by Claude Code through `STDIN`.

[📚 Shared input helpers](COMMON.md#input-helpers)

| Method | Description |
|--------|-------------|
| `prompt` | Get the user's prompt text |
| `user_prompt` | Alias for `prompt` |
| `current_prompt` | Alias for `prompt` |
| `session_title` | The session's custom title, when one is set (same meaning as SessionStart's `session_title`) |

> [!NOTE]
> `UserPromptSubmit` also fires on turns Claude Code starts on its own — a scheduled task or `/loop` iteration, a background subagent reporting back, or a message another session sends — so `prompt` isn't always text the user typed.

> [!NOTE]
> Pasted content that collapsed to a `[Pasted text #N]` placeholder arrives expanded in `prompt`. When Claude Code marks pasted text for Claude, it sits between `<pasted_content id="…">` and `</pasted_content id="…">` lines — account for them if you parse the prompt.

## Hook State Helpers
Hook state methods are helpers to modify the hook's internal state (`output_data`) before yielding back to Claude Code.

[📚 Shared hook state methods](COMMON.md#hook-state-methods)

| Method | Description |
|--------|-------------|
| `add_additional_context!(context)` | Add context to the prompt |
| `add_context!(context)` | Alias for `add_additional_context!` |
| `empty_additional_context!` | Remove additional context |
| `block_prompt!(reason)` | Block the prompt from processing |
| `unblock_prompt!` | Unblock a previously blocked prompt |
| `session_title!(title)` | Set the session title (e.g. name sessions from the prompt content) |
| `suppress_original_prompt!(value = true)` | When the prompt is blocked (`block_prompt!` or exit 2), leave the prompt text out of the block message |

> [!WARNING]
> By default the block message ends with `Original prompt:` and the submitted text, and is written to the session transcript on disk. `suppress_original_prompt!` removes it from that message only — the text can still appear in other local files such as prompt history, so a blocking hook isn't a way to keep a secret off disk.

## Output Helpers
Output helpers provide access to the hook's output data and helper methods for working with the output state.

[📚 Shared output helpers](COMMON.md#output-helpers)

| Method | Description |
|--------|-------------|
| `output.decision` | Get the decision: "block" or nil (default) |
| `output.reason` | Get the reason for the decision |
| `output.blocked?` | Check if the prompt has been blocked (decision == 'block') |
| `output.additional_context` | Get the additional context that was added |
| `output.session_title` | Get the session title that was set (if any) |
| `output.suppress_original_prompt?` | Whether the prompt text is left out of the block message |

## Hook Exit Codes

| Exit Code | Behavior |
|-----------|----------|
| `exit 0` | Operation continues<br/>**`STDOUT` added as context to Claude** |
| `exit 1` | Non-blocking error<br/>`STDERR` shown to user |
| `exit 2` | **Blocks prompt processing**<br/>**Erases prompt**<br/>`STDERR` shown to user only |