# InstructionsLoaded API

Available when inheriting from `ClaudeHooks::InstructionsLoaded`:

Runs when a `CLAUDE.md` instructions file is loaded. Non-blocking — exit code is ignored.

## Input Helpers

[📚 Shared input helpers](COMMON.md#input-helpers)

| Method | Description |
|--------|-------------|
| `file_path` | Path to the loaded instructions file |
| `load_reason` | Why the file was loaded (e.g. `'startup'`, `'cwd_change'`) |

## Hook State Helpers

[📚 Shared hook state methods](COMMON.md#hook-state-methods)

No event-specific state methods — this hook is non-blocking.

## Output Helpers

[📚 Shared output helpers](COMMON.md#output-helpers)

No event-specific output helpers.

## Hook Exit Codes

Non-blocking. Exit code is ignored by Claude Code.
