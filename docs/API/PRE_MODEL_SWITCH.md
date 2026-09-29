# PreModelSwitch API

Available when inheriting from `ClaudeHooks::PreModelSwitch`:

Runs before Claude Code applies a model switch that you or a client requested (Claude Code v2.1.251+). Use it to block a switch, require confirmation, or show what the switch will cost before it happens. Claude Code doesn't run this hook for switches it makes on its own (automatic fallback, resume) — those reach [PostModelSwitch](POST_MODEL_SWITCH.md) only.

## Input Helpers
Input helpers to access the data provided by Claude Code through `STDIN`.

[📚 Shared input helpers](COMMON.md#input-helpers)

| Method | Description |
|--------|-------------|
| `from_model` | Model ID the switch changes from |
| `to_model` | Model ID the switch changes to (the matcher compares against its canonical name) |
| `requested_model` | The model the request named (an alias, a full ID, or `nil` for the default model) |
| `source` | Where the request came from: `'command'`, `'picker'`, or `'sdk'` |
| `context_tokens` | Tokens the next request re-sends as its prompt (`0` before the first response) |
| `prompt_cache_warm` | Whether the current model's prompt cache is likely still warm |
| `cache_ttl` | Prompt cache lifetime requested for this session: `'5m'` or `'1h'` |
| `estimated_cache_write_usd` | Estimated cost (USD) of re-caching `context_tokens` on `to_model` |
| `pricing` | How `estimated_cache_write_usd` was priced: `'configured'`, `'catalog'`, or `'default'` |

## Hook State Helpers
Hook state methods are helpers to modify the hook's internal state (`output_data`) before yielding back to Claude Code.

[📚 Shared hook state methods](COMMON.md#hook-state-methods)

| Method | Description |
|--------|-------------|
| `approve!(reason)` / `allow!(reason)` | Let the switch proceed (skips the warm-cache confirmation) |
| `deny!(reason)` / `block_switch!(reason)` | Cancel the switch (`permissionDecision: 'deny'`) |
| `ask!(reason)` | Prompt the user to confirm the switch (`permissionDecision: 'ask'`) |
| `block!(reason)` | Cancel the switch via a top-level `decision: "block"` (equivalent to exit 2) |

`PreModelSwitch` does not accept `defer`, `updatedInput`, or `additionalContext`. Only `/model` in an interactive session can show the `'ask'` prompt; elsewhere `'ask'` is treated as a refusal.

## Output Helpers
Output helpers provide access to the hook's output data and helper methods for working with the output state.

[📚 Shared output helpers](COMMON.md#output-helpers)

| Method | Description |
|--------|-------------|
| `output.allowed?` | Whether the switch was allowed (`permission_decision == 'allow'`) |
| `output.denied?` | Whether the switch was denied (`permission_decision == 'deny'`) |
| `output.blocked?` | Whether the switch was blocked (via `deny` **or** top-level `decision: "block"`) |
| `output.should_ask?` | Whether the user is asked to confirm (`permission_decision == 'ask'`) |
| `output.permission_decision` | The permission decision: `'allow'`, `'deny'`, or `'ask'` |
| `output.permission_reason` | The reason for the permission decision |
| `output.decision` | The top-level decision (`'block'` or `nil`) |
| `output.reason` | The top-level block reason |

When multiple hooks return different decisions, precedence is `deny > ask > allow`.

## Hook Exit Codes

`PreModelSwitch` uses the JSON API with exit code 0; the `permissionDecision` (or top-level `decision`) controls whether the switch proceeds.

| Exit Code | Behavior |
|-----------|----------|
| `exit 0` | Decision processed<br/>`STDOUT` contains JSON with the decision |
| `exit 1` | Non-blocking error<br/>`STDERR` shown to user; the switch applies |
| `exit 2` | **Cancels the switch**<br/>`STDERR` shown to user |

> [!NOTE]
> A `PreModelSwitch` hook that doesn't respond before its timeout **blocks** the switch (unlike `PreToolUse`). The default timeout for this event is 30 seconds.
