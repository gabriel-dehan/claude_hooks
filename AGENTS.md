# Agent guidance — claude_hooks

This file is loaded by the OpenHands agents that run in this repo's GitHub Actions
bots. It is picked up via `load_available_skills` (which internally calls
`load_project_skills`, the loader that ingests `AGENTS.md`) in
`agent_task.py` (issue and PR bots) and by the `pr-review` composite action.
Keep it short and factual.

## What this project is

`claude_hooks` is a **Ruby gem** — a DSL for creating [Claude Code](https://docs.claude.com/en/docs/claude-code)
hooks (logging, security checks, workflow automation) with composable hook scripts.
Pure Ruby, no Rails. Public repo: https://github.com/gabriel-dehan/claude_hooks

## Layout

- `lib/claude_hooks/` — the gem. One file per hook type (`pre_tool_use.rb`,
  `post_tool_use.rb`, `user_prompt_submit.rb`, `session_start.rb`, etc.), plus
  `base.rb`, `configuration.rb`, `cli.rb`, `logger.rb`, `version.rb`.
- `test/` — plain Ruby tests (`test_*.rb`), no RSpec.
- `docs/` — human docs, including `docs/openhands/` for the bot setup itself.

## Running tests

```bash
bundle install
ruby test/run_all_tests.rb
```

Run this before committing any code change; it must pass. Add or update tests in
`test/` when you change behavior.

## Conventions

- Match the surrounding code's style; this is a small, idiomatic Ruby gem.
- Keep changes minimal and focused on the request.
- Follow SemVer; note user-facing changes in `CHANGELOG.md`. `v1.0.0` introduced
  breaking changes — check the changelog before assuming an API.
- Never commit secrets; never modify `.github/workflows/` permissions or CI secrets
  unless the task is explicitly about the workflows.

## For PR review specifically

Verify that behavior changes come with tests and that `ruby test/run_all_tests.rb`
would still pass. Flag anything that breaks the documented DSL API without a
CHANGELOG note.
