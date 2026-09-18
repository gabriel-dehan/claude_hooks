# PostModelSwitch API

Available when inheriting from `ClaudeHooks::PostModelSwitch`:

Runs after the session's model changes (Claude Code v2.1.251+), including changes Claude Code makes on its own (automatic fallback, restoring the model on resume). Use it to give Claude model-specific guidance. It **can't block** — the model has already changed. Its `STDOUT` is added as context for Claude.

## Input Helpers
Input helpers to access the data provided by Claude Code through `STDIN`.

[📚 Shared input helpers](COMMON.md#input-helpers)

`PostModelSwitch` receives the same fields as [PreModelSwitch](PRE_MODEL_SWITCH.md#input-helpers), with two extra `source` values: `'auto'` (a change Claude Code made on its own) and `'resume'` (the model restored when resuming a session). `requested_model` is `nil` when `source` is `'auto'`.

| Method | Description |
|--------|-------------|
| `from_model` | Model ID the switch changes from |
| `to_model` | Model ID the session switched to |
| `requested_model` | The model the request named (`nil` for `'auto'`; the restored setting for `'resume'`) |
| `source` | `'command'`, `'picker'`, `'sdk'`, `'auto'`, or `'resume'` |
| `context_tokens` | Tokens the next request re-sends as its prompt |
| `prompt_cache_warm` | Whether the prompt cache is likely still warm |
| `cache_ttl` | Prompt cache lifetime: `'5m'` or `'1h'` |
| `estimated_cache_write_usd` | Estimated cost (USD) of re-caching `context_tokens` |
| `pricing` | How `estimated_cache_write_usd` was priced |

## Hook State Helpers
Hook state methods are helpers to modify the hook's internal state (`output_data`) before yielding back to Claude Code.

[📚 Shared hook state methods](COMMON.md#hook-state-methods)

| Method | Description |
|--------|-------------|
| `add_additional_context!(context)` | Add context for Claude after the model changes |
| `add_context!(context)` | Alias for `add_additional_context!` |

## Output Helpers
Output helpers provide access to the hook's output data and helper methods for working with the output state.

[📚 Shared output helpers](COMMON.md#output-helpers)

| Method | Description |
|--------|-------------|
| `output.additional_context` | Get the additional context that was added |

## Hook Exit Codes

Context-only — `PostModelSwitch` can't block.

| Exit Code | Behavior |
|-----------|----------|
| `exit 0` | Operation continues<br/>**`STDOUT` added as context to Claude** |
| `exit 1` | Non-blocking error<br/>`STDERR` shown to user |
| `exit 2` | N/A — rendered as a `<hook name> hook error` notice; the session proceeds |
