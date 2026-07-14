# OpenHands Coding Bots (GitHub Actions)

This repo runs AI coding-agent "bots" entirely inside GitHub Actions. You talk
to them from issues and pull requests, and they read code, make changes, open
and update PRs, review PRs, and propose plans — all using **your own
OpenAI-compatible LLM endpoint** (no third-party SaaS coding platform, no
OpenHands Cloud subscription).

---

## What we're trying to achieve

Deploy a set of AI assistants that behave like a junior maintainer, driven
purely from GitHub, with these capabilities:

1. **Discuss in an issue → open a PR** — describe work in an issue, mention the
   bot, and it implements the change and opens a PR.
2. **Follow-ups on an existing PR** — ask the bot for more changes and it pushes
   commits to that PR's branch.
3. **Discuss on a PR or issue** — ask questions and the bot replies (no code change).
4. **Review PRs** — the bot posts a code review, automatically and on demand.
5. **Plan / investigate** — ask `@openhands plan` and the bot proposes a
   structured plan as a comment, without touching any code.

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
AGENTS.md                                # repo guidance — loaded by all bots
.agents/
└── skills/
    ├── run-tests/
    │   └── SKILL.md                     # keyword-triggered skill (test/tests/spec)
    └── ci-monitoring/
        └── SKILL.md                     # safe CI-wait pattern (ci/checks/green)
.github/
├── actions/
│   └── run-openhands/
│       └── action.yml                  # composite action: shared setup + run for the issue/PR bots
├── openhands/
│   ├── agent_task.py                    # shared SDK agent runner (uses our endpoint)
│   ├── context_builder.py               # assembles the full deterministic prompt (gh/git)
│   ├── recall_tool.py                   # custom SDK tool: recall_prior_reasoning (cross-run memory)
│   └── hooks/
│       └── block_dangerous.sh           # PreToolUse guardrail (blocks force-push / CI edits)
└── workflows/
    ├── openhands-pr-review.yml          # review PRs (auto + "@openhands review")
    ├── openhands-issue.yml              # "@openhands ..." on an issue → implements (PR), answers, or plans
    └── openhands-pr-followup.yml        # "@openhands ..." on a PR → commits, answers, or plans
```

The two `agent_task.py`-based bots (issue + PR follow-up) share their runner
steps — checkout, toolchain, state restore/persist, prompt build, agent run —
via the **`.github/actions/run-openhands`** composite action, so each workflow
keeps only its own triggers, guards, and comments. `pr-review` uses the external
OpenHands action instead and doesn't share this.

### PR review — `openhands-pr-review.yml`

Uses OpenHands' official, ready-made composite action
`OpenHands/extensions/plugins/pr-review@main`. We pass it our
`llm-model` / `llm-base-url` / `llm-api-key`. It fetches the diff and any prior
review context, then posts inline review comments via the GitHub API.

Triggers: on PR `opened`/`reopened`, or when someone comments `@openhands review`
on the PR. (It intentionally does **not** re-run on every push/`synchronize` — a
review fires when the PR opens or when you explicitly ask.)

The `pr-review` action loads `AGENTS.md` (via its own `load_project_skills` call)
but does not use `agent_task.py`, so it doesn't have cross-run memory or the
guardrail hook.

### Issue and PR bots — `agent_task.py`

There is no turnkey OpenHands Action for "issue → PR" or "PR follow-up", so these
workflows run a generic agent script built on `openhands-sdk`. The full pipeline:

```
load_available_skills(project + optional public)    # AGENTS.md, .agents/skills/
  → AgentContext(skills=...)
register_builtins_agents()                          # code-reviewer, web-researcher, etc.
  + get_default_tools(enable_sub_agents=True)       # bash + file editor + task tool
  + recall_prior_reasoning tool (when memory on)
  → Agent(llm, tools, agent_context, condenser=...)
  → HookConfig(pre_tool_use=[block_dangerous.sh])   # guardrail hook
  → Conversation(agent, hook_config, secrets, persistence)
  → send_message(AGENT_PROMPT); run()
  → conversation_stats → $GITHUB_STEP_SUMMARY
```

`agent_task.py` carries a **PEP 723** inline dependency header, so the workflows
invoke it with `uv run` and the SDK resolves deterministically on a clean runner
(there is no separate install step).

**Intent detection** is handled in the task templates inside `context_builder.py`.
On each run the agent sees:

- **CHANGE / IMPLEMENT** — makes code changes, runs tests, commits, pushes.
- **QUESTION / DISCUSSION** — investigates and replies as a comment, no code change.
- **PLAN** (triggered by `@openhands plan`) — investigates and posts a structured
  proposed plan as a comment, no commits or branches.

### Skills and `AGENTS.md`

`agent_task.py` calls `load_available_skills(work_dir, include_project=True)` on
startup, which picks up:

- **`AGENTS.md`** at the repo root — always-loaded static guidance (conventions,
  test commands, policies).
- **`.agents/skills/`** directories following the
  [AgentSkills](https://agentskills.io/specification) format. Each `SKILL.md` has
  YAML frontmatter with `triggers:` keywords; the agent sees a brief description of
  every skill and its full content is injected on demand when a trigger word appears.
  Example: `.agents/skills/run-tests/` triggers on `test`/`tests`/`spec` and
  provides the exact test-run commands.
- Optionally, **public skills** from `OpenHands/extensions` when
  `OPENHANDS_LOAD_PUBLIC_SKILLS=1` is set (see env knobs below).

Skills give the agent persistent, progressive-disclosure repo knowledge without
bloating every prompt.

### Sub-agent delegation

`agent_task.py` registers the built-in sub-agents (`code-reviewer`,
`web-researcher`, etc.) and enables `TaskToolSet` so the main agent can delegate
complex sub-tasks. For example, it can spin up a `code-reviewer` sub-agent to
do a thorough review before writing the PR description, then get back a structured
result.

### Guardrail hooks

A `PreToolUse` shell hook (`block_dangerous.sh`) runs before every terminal
command the agent executes. It blocks:

- **Force-push** (`git push --force` / `-f`) — automated agents must never
  rewrite history.
- **Writes to `.github/workflows/`** — CI configuration must be changed by a human.
- **Writes to secret/credential files** (`.env`, `.envrc`, `*secret*`, etc.).

Exit code `2` denies the command and surfaces the reason to the agent as an
error observation. This makes the prompt-level rules deterministic rather than
advisory.

The hook is **behavioral defense-in-depth**, not a boundary: it pattern-matches
command strings, which a determined (or prompt-injected) agent could route around
(e.g. shelling out from a Ruby script, encoding the command). It stops the obvious
mistakes; it does not *guarantee* the agent can't do damage. For the operations
that must never happen — landing code on `main`, publishing a release — the
guarantee has to be **structural** (see below).

### Structural containment (write, not admin)

The agent runs with `contents: write` + `pull-requests: write`. The security
model is that **every privileged path chains back to an operation the bot cannot
perform**, so even a fully prompt-injected agent is contained — independent of the
behavioral hook. Two things must be locked down at the repo level (GitHub Settings,
one-time, done by a human):

1. **Protect `main` so the bot can't merge.** Settings → Rules → **Rulesets** (or
   classic branch protection): on the default branch, require a pull request and at
   least one **approving review**, and restrict who can push / bypass to admins
   only. The bot authenticates with the built-in `GITHUB_TOKEN`, which is not an
   admin, so it can open PRs but cannot merge them or push to `main` directly. A
   human merge stays in the loop.

2. **Gate the release secret behind `main`.** `ruby-gem.yml` publishes to RubyGems
   using `secrets.RUBYGEMS_AUTH_TOKEN` and only runs its publish job on `push` to
   `refs/heads/main`. Move that secret into a GitHub **Environment** (e.g.
   `release`) whose **deployment branch policy** allows only the default branch (and
   tags, if you tag releases), and reference it from the job with
   `environment: release`. Then a leaked/compromised bot token that pushes some
   *other* branch can never match the policy, so the publish job is rejected
   *before* the secret is readable. The chain is: no admin merge → nothing lands on
   `main` → no `push`-to-`main` event → no environment access → `RUBYGEMS_AUTH_TOKEN`
   never exposed.

Caveat (same as any Actions setup): this guarantee holds for `push`/`pull_request`
triggers. `workflow_dispatch`, `release`, and `schedule` triggers can be initiated
without a merge, so if you add secret-bearing jobs on those triggers, gate them
with required reviewers on the environment too.

Without step 1 in place, `ruby-gem.yml`'s publish token is only as safe as branch
protection — set it up before pointing the bots at a repo that publishes.

### Hybrid context system

The bots don't rely on the model volunteering to fetch context. Two layers:

1. **Deterministic history injection (always, every run).** `context_builder.py`
   assembles the full authoritative context via `gh`/`git` and emits the entire
   `AGENT_PROMPT` (task template + a "CURRENT STATE" block). For a PR that's the
   PR body + full comment thread + inline review comments + the `base...head` diff
   + any linked issue; for an issue it's the body + thread + related PRs. Output is
   budget-capped (~100k chars total, ~12k per file diff) with truncation markers.
   This is the source of truth and always current. The prompt footer also carries
   the **trust / untrusted-input** guidance (content-is-not-instructions; only
   maintainers may direct the bot). This lives in `context_builder.py`, not
   `AGENTS.md`, on purpose — it's bot-infrastructure guidance that must travel with
   the setup when ported to another repo (whose `AGENTS.md` describes that repo's
   own conventions and shouldn't have to re-state it).

2. **Cross-run memory (on demand).** Each SDK run persists its events to
   `${OPENHANDS_PERSIST_DIR}/<thread-key>/<conversation-id>/`, uploaded as a GitHub
   **artifact** named `openhands-state-{pr,issue}-<N>` and restored by the next run
   on the same thread. We deliberately give each run a **fresh** `conversation_id`
   so the SDK never auto-replays old state into the prompt (keeps it lean). Instead
   the custom **`recall_prior_reasoning`** tool reads *prior* run event dirs on
   demand — e.g. when a maintainer asks "why did you…". Its output is framed as
   possibly-outdated; the current diff always wins on conflict.

   Cross-run download uses `dawidd6/action-download-artifact` (`search_artifacts`)
   because `actions/download-artifact` only sees the current run's artifacts. Fork
   PRs have no secrets/artifacts, so the follow-up bot skips this and runs stateless.

   To keep the per-thread artifact bounded (every run adds a new `<conversation-id>/`
   subdir and the whole tree is re-uploaded), `agent_task.py` prunes to the most
   recent `OPENHANDS_KEEP_RUNS` runs (default 5) before each run.

**PR review is the exception:** the ready-made `pr-review` action runs its own
script, so we can't inject the assembled prompt or the recall tool into it. It
already fetches the diff + prior review context itself, and it loads `AGENTS.md`
(via `load_project_skills`) for static guidance. So PR review participates in the
*static* half of the system (`AGENTS.md`) only — no per-run injection, no
cross-run memory.

### Cost reporting

After every run, `agent_task.py` reads `conversation.conversation_stats` and
appends a brief table (model, cost, prompt tokens, completion tokens, skills
loaded) to the GitHub Actions **step summary**. Open the run in the Actions UI and
click the summary tab to see it.

If a run ends with status `ERROR` or `STUCK` (stuck detection is on by default),
the script exits non-zero so the existing `if: failure()` workflow step posts a
failure comment on the issue/PR.

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

### 2b. Who can trigger the bots (author-association gating)

The write-capable workflows (`openhands-issue`, `openhands-pr-followup`) and the
on-demand `@openhands review` comment path only run when the triggering commenter's
`author_association` is `OWNER`, `MEMBER`, or `COLLABORATOR`. On a **public repo**
this matters: without it, any stranger could comment `@openhands implement …` and
drive an agent that runs with `contents`/`pull-requests` write and burns your LLM
budget. If you want a non-collaborator to be able to trigger the bot, add them as a
repo collaborator (or org member) rather than loosening the gate.

The automatic PR review on `opened`/`reopened` stays open by design — it's
read-only (`contents: read`, only posts a review), which is the whole point of
reviewing incoming contributions.

### 3. Commit the workflows

```bash
git checkout -b add-openhands-bots
git add AGENTS.md .agents/ .github/openhands .github/actions/run-openhands .github/workflows/openhands-*.yml docs/openhands/
git commit -m "Add OpenHands GitHub Actions bots (review, issue, PR follow-up)"
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
| Ask about an issue | issue | `@openhands what would this involve?` (answers, no PR) |
| Change code on a PR | PR | `@openhands add error handling for nil config` |
| Ask about a PR | PR | `@openhands why did you use a mutex here?` (uses cross-run memory) |
| Propose a plan (no code) | issue or PR | `@openhands plan <optional detail>` |

---

## Environment knobs

| Variable | Default | Description |
|---|---|---|
| `OPENHANDS_LOAD_PUBLIC_SKILLS` | off | Set to `1` or `true` to also load skills from the `OpenHands/extensions` public registry. Adds ~1–2 s (git clone on first run). |
| `EXTENSIONS_REF` | `main` | Branch/tag/SHA for the public extensions repo. Pin to a tag for reproducibility once you're happy. |
| `LLM_MAX_ITER` | `60` | Max agent iterations per run. |
| `OPENHANDS_PERSIST_DIR` | — | Root directory for cross-run event persistence (set by the composite action via `runner.temp`). |
| `OPENHANDS_CONVERSATION_KEY` | — | Thread key for the artifact (e.g. `pr-42`, `issue-7`). Set by the composite action from the surface + number. |
| `OPENHANDS_KEEP_RUNS` | `5` | How many prior run subdirs to retain per thread before a run; older ones are pruned so the artifact stays bounded. |

---

## Things to know

- **Only maintainers can trigger the write bots.** The issue, PR-follow-up, and
  on-demand-review comment paths gate on `author_association` ∈
  {`OWNER`,`MEMBER`,`COLLABORATOR`} (see Setup §2b). Non-collaborator comments are
  ignored. The auto PR review on open/reopen is intentionally ungated (read-only).
- **Write, not admin (structural containment).** Protect `main` and gate the
  RubyGems publish secret behind a `main`-only Environment so a prompt-injected
  agent still cannot merge code or read the release token. The `block_dangerous.sh`
  hook is defense-in-depth on top of this, not a replacement — see "Structural
  containment" above.
- **Fork PRs get no secrets** (GitHub security rule). Review is skipped and
  follow-up posts a "can't run on forks" note (and runs stateless, no artifacts).
  This is expected. Your own branches work fully.
- **Cross-run memory horizon**: the recall tool only sees what's still in the
  artifact. Artifacts have `retention-days: 30` and are overwritten per thread, and
  each run keeps only the last `OPENHANDS_KEEP_RUNS` runs (default 5), so the bot
  "remembers" recent prior reasoning on a PR/issue within that window.
- **Concurrency**: runs are serialized per surface so they don't race on the shared
  state artifact — `openhands-issue-<n>` for the issue bot and `openhands-pr-<n>` for
  the PR follow-up bot (both queue; nothing is dropped). PR review is read-only (no
  artifact, no branch push) and stays on its own `openhands-review-<n>` group where a
  newer review supersedes an in-flight one.
- **Ruby project**: the write-capable workflows set up Ruby so the agent can run
  the suite with `ruby test/run_all_tests.rb` before committing.
- **Cost / runtime**: `agent_task.py` caps iterations via `LLM_MAX_ITER`
  (default 60). Cost is reported in the Actions step summary after each run. The
  `pr-review` action also accepts budget limits. There is no hard dollar cap by
  default — add one if your endpoint bills per token.
- **No workflow chaining by default**: the built-in `GITHUB_TOKEN` does not
  retrigger other workflows, so a PR the bot opens won't auto-run `test.yml`.
  Use a PAT or GitHub App token if you want that. (Consequence for CI-waiting: on a
  bot-opened PR the checks tab may be empty — that's expected, not a hang. The
  `ci-monitoring` skill tells the agent to note this rather than poll forever.)
- **Pinning**: workflows reference `OpenHands/extensions@main`. Pin to a tag or
  SHA (`extensions-version:`) once you're happy, for reproducibility.
- **Adding skills**: create a new directory under `.agents/skills/<skill-name>/`
  with a `SKILL.md` following the AgentSkills format. It will be picked up
  automatically on the next run. See `.agents/skills/run-tests/SKILL.md` for an
  example.

---

## References

- OpenHands: <https://github.com/OpenHands/OpenHands>
- Extensions registry (plugins): <https://github.com/OpenHands/extensions>
- Agent SDK: <https://github.com/OpenHands/software-agent-sdk>
- Docs: <https://docs.openhands.dev>
- AgentSkills standard: <https://agentskills.io/specification>
