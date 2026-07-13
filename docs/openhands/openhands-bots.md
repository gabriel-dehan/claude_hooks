# OpenHands Coding Bots (GitHub Actions)

This repo runs AI coding-agent "bots" entirely inside GitHub Actions. You talk
to them from issues and pull requests, and they read code, make changes, open
and update PRs, and review PRs — all using **your own OpenAI-compatible LLM
endpoint** (no third-party SaaS coding platform, no OpenHands Cloud
subscription).

---

## What we're trying to achieve

Deploy a set of AI assistants that behave like a junior maintainer, driven
purely from GitHub, with these capabilities:

1. **Discuss in an issue → open a PR** — describe work in an issue, mention the
   bot, and it implements the change and opens a PR.
2. **Follow-ups on an existing PR** — ask the bot for more changes and it pushes
   commits to that PR's branch.
3. **Discuss on a PR** — ask the bot questions about the PR and it replies
   (without changing code).
4. **Review PRs** — the bot posts a code review, automatically and on demand.

Two hard constraints shaped the design:

- **Runs only in GitHub Actions** — no separate always-on server, no hosted
  agent service. The agent process lives and dies inside each Actions run.
- **Uses our own inference** — an OpenAI-compatible API key + HTTP endpoint,
  not a vendor-locked coding product.

---

## Why OpenHands (and what we ruled out)

| Option | Runs fully in Actions | Custom OpenAI-compatible endpoint | Verdict |
|---|---|---|---|
| **OpenHands** (extensions plugins + SDK) | ✅ | ✅ explicit `llm-base-url`, routes via LiteLLM | **Chosen** |
| `anthropic/claude-code-action` | ✅ | ❌ Anthropic / Bedrock / Vertex / Foundry only | Rejected (endpoint constraint) |
| `max-sixty/tend` | ✅ | ❌ no base-URL config surface | Rejected (would need patching) |
| Aider in a workflow | ✅ | ✅ | Viable, but no built-in bot/trigger UX — more glue |

Also note the distinction that made OpenHands confusing at first:

- `OpenHands/openhands-github-action` (the repo) is a **thin cloud client** — it
  needs an `OPENHANDS_API_KEY` and talks to `app.all-hands.dev`; the agent runs
  on *their* infrastructure. **We do not use this.**
- The **`OpenHands/extensions` plugins** and the **`openhands-sdk`** run the
  agent **inside our runner**. Because everything goes through
  [LiteLLM](https://github.com/BerriAI/litellm), any OpenAI-compatible endpoint
  works via `LLM_BASE_URL` + an `openai/<model>` model id. **This is what we
  use.**

---

## How it works

### The pieces

```
.github/
├── openhands/
│   └── agent_task.py                    # shared SDK agent runner (uses our endpoint)
└── workflows/
    ├── openhands-pr-review.yml          # review PRs (auto + "@openhands review")
    ├── openhands-issue-to-pr.yml        # "@openhands implement" on an issue → opens a PR
    └── openhands-pr-followup.yml        # "@openhands ..." on a PR → commits or answers
```

### PR review — `openhands-pr-review.yml`

Uses OpenHands' official, ready-made composite action
`OpenHands/extensions/plugins/pr-review@main`. We pass it our
`llm-model` / `llm-base-url` / `llm-api-key`. It fetches the diff and any prior
review context, then posts inline review comments via the GitHub API.

Triggers: on PR `opened`/`reopened`, or when someone comments `@openhands review`
on the PR. (It intentionally does **not** re-run on every push/`synchronize` — a
review fires when the PR opens or when you explicitly ask.)

### Issue→PR, follow-ups, discussion — `agent_task.py`

There is no turnkey OpenHands Action for "issue → PR", so these workflows run a
small generic agent script built on `openhands-sdk`. It follows the exact
pattern the official actions use internally:

```
LLM(model, api_key, base_url, drop_params=True)   # our endpoint, via LiteLLM
  → get_default_tools(enable_browser=False)        # bash + file editor + task tools
  → Agent(llm, tools, condenser=...)
  → Conversation(agent, workspace=cwd, secrets={GITHUB_TOKEN, GH_TOKEN})
  → send_message(AGENT_PROMPT); run()
```

The workflow decides the *task* by setting the `AGENT_PROMPT` env var; the script
is otherwise generic. The agent has full repo access and uses the `gh` CLI
(authenticated via the injected `GITHUB_TOKEN`) to branch, commit, push, open
PRs, and comment.

- **`openhands-issue-to-pr.yml`** — on an issue comment containing `@openhands`,
  the agent creates branch `openhands/issue-<N>`, implements the change, runs the
  tests, opens a PR that closes the issue, and comments back on the issue.
- **`openhands-pr-followup.yml`** — on a PR comment containing `@openhands` (but
  not `@openhands review`), the agent decides intent:
  - a **change request** → it works on the PR's own head branch, runs tests,
    commits, and pushes (the PR updates automatically);
  - a **question** → it investigates and replies as a PR comment, no code change.

`drop_params=True` lets LiteLLM strip request params your backend doesn't accept,
which keeps "OpenAI-compatible-but-not-identical" endpoints working.

---

## Setup

### 1. Configure the endpoint

Non-secret config goes in **Actions variables**; the key goes in an **Actions
secret**:

```bash
cd /path/to/claude_hooks

gh variable set OPENHANDS_LLM_MODEL    --body "openai/<your-model-name>"
gh variable set OPENHANDS_LLM_BASE_URL --body "https://<your-endpoint>/v1"
gh secret   set OPENHANDS_LLM_API_KEY  --body "<your-api-key>"
```

- Use the `openai/` prefix so LiteLLM treats it as an OpenAI-compatible backend
  (e.g. `openai/gpt-oss-120b`).
- The base URL usually needs the `/v1` suffix — confirm with your provider.
- Do **not** create `GITHUB_TOKEN`; Actions injects it automatically per run.

### 2. Allow Actions to open PRs

Repo **Settings → Actions → General → Workflow permissions**:

- Select **Read and write permissions**.
- Check **Allow GitHub Actions to create and approve pull requests**.

Without the second box, the issue→PR bot can push a branch but can't open the PR.

### 3. Commit the workflows

```bash
git checkout -b add-openhands-bots
git add .github/openhands .github/workflows/openhands-*.yml docs/openhands-bots.md
git commit -m "Add OpenHands GitHub Actions bots (review, issue→PR, PR follow-up)"
git push -u origin add-openhands-bots
gh pr create --fill
```

> ⚠️ `issue_comment` triggers only fire once the workflow file exists **on the
> default branch (`main`)**. The bots go live only after this PR is merged. This
> is a GitHub rule, not a config choice.

### 4. First run

Trigger one (e.g. comment `@openhands review` on a PR) and watch it:

```bash
gh run watch
```

Most likely first-run issue is the model string / base URL. If the LLM call
errors, adjust `OPENHANDS_LLM_MODEL` (with/without `openai/`) or the `/v1` on the
base URL, then re-trigger.

---

## Usage

| You want to… | Where | Comment |
|---|---|---|
| Review a PR | PR | automatic on open/reopen, or `@openhands review` |
| Turn an issue into a PR | issue | `@openhands implement <optional detail>` |
| Change code on a PR | PR | `@openhands add error handling for nil config` |
| Ask about a PR | PR | `@openhands why did you use a mutex here?` |

---

## Things to know

- **Fork PRs get no secrets** (GitHub security rule). Review is skipped and
  follow-up posts a "can't run on forks" note. This is expected. Your own
  branches work fully.
- **Ruby project**: the write-capable workflows set up Ruby so the agent can run
  the suite with `ruby test/run_all_tests.rb` before committing.
- **Cost / runtime**: `agent_task.py` caps iterations via `LLM_MAX_ITER`
  (default 60). The `pr-review` action also accepts budget limits. There is no
  hard dollar cap by default — add one if your endpoint bills per token.
- **No workflow chaining by default**: the built-in `GITHUB_TOKEN` does not
  retrigger other workflows, so a PR the bot opens won't auto-run `test.yml`.
  Use a PAT or GitHub App token if you want that.
- **Pinning**: workflows reference `OpenHands/extensions@main`. Pin to a tag or
  SHA (`extensions-version:`) once you're happy, for reproducibility.

---

## References

- OpenHands: <https://github.com/OpenHands/OpenHands>
- Extensions registry (plugins): <https://github.com/OpenHands/extensions>
- Agent SDK: <https://github.com/OpenHands/software-agent-sdk>
- Docs: <https://docs.openhands.dev>
