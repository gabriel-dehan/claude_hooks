# Setting up Mitts in your repository

This guide walks you through everything needed to get the Mitts coding bots running in a GitHub repository, from zero to a first successful run. It assumes **the Mitts files are already present in your repo** (workflows, the composite action, the `.github/mitts/` scripts, `.agents/skills/`, and `AGENTS.md`) — extracting/copying them into a fresh repo is covered separately.

For *how the system works* (architecture, the hybrid context system, the
security model), see [`mitts-bots.md`](./mitts-bots.md). This document is the
operational checklist.

> **Time:** ~10 minutes of clicking + CLI. Most of it is one-time GitHub config.
> You need **admin** on the repo (some steps touch repo Settings and secrets).

---

## At a glance

| Step | Where | One-time? | Required? |
|---|---|---|---|
| 1. Files present | repo | — | ✅ |
| 2. LLM endpoint config (vars + secret) | Actions vars/secrets | ✅ | ✅ |
| 3. Allow Actions to open PRs | Settings → Actions | ✅ | ✅ |
| 4. Protect `main` (no bot merges) | Settings → Rules | ✅ | ✅ strongly |
| 5. Gate the release secret behind `main` | Settings → Environments | ✅ | ✅ if you publish |
| 6. Decide who can trigger the bots | collaborators / org | ongoing | ✅ |
| 7. Land the workflows on `main` | git | ✅ | ✅ |
| 8. First run | issue / PR comment | — | ✅ |
| 9. Optional knobs | Actions vars | anytime | optional |

---

## 1. Confirm the files are in place

You should have this tree in the repo (see `mitts-bots.md` → "The pieces" for
what each does):

```
AGENTS.md
.agents/skills/…                       # keyword-triggered skills
.github/
├── actions/run-mitts/action.yml       # shared setup + run (issue + PR bots)
├── mitts/
│   ├── agent_task.py                   # SDK agent runner
│   ├── context_builder.py              # deterministic prompt builder
│   ├── recall_tool.py                  # cross-run memory tool
│   ├── instructions/{issues,prs}.md    # per-surface task templates
│   └── hooks/block_dangerous.sh        # guardrail hook
└── workflows/
    ├── mitts-pr-review.yml
    ├── mitts-issue.yml
    └── mitts-pr-followup.yml
```

Nothing here needs editing to run — the scripts locate their siblings and the
hook relative to their own path, and the workflows reference the composite
action by path. If your default branch is not `main`, note it — a few steps
below refer to "the default branch".

---

## 2. Configure your LLM endpoint

Mitts talks to **your own OpenAI-compatible endpoint** via LiteLLM. Three values
are needed. Two are non-secret (**Actions variables**) and one is secret (an
**Actions secret**).

The names below are the exact identifiers the workflows read — don't rename them
unless you also change the workflows:

| Name | Kind | Example | Read by |
|---|---|---|---|
| `OPENHANDS_LLM_MODEL` | variable | `openai/gpt-oss-120b` | `mitts-*.yml` → `llm-model` → `LLM_MODEL` |
| `OPENHANDS_LLM_BASE_URL` | variable | `https://your-endpoint.example/v1` | → `llm-base-url` → `LLM_BASE_URL` |
| `OPENHANDS_LLM_API_KEY` | **secret** | `sk-…` | → `llm-api-key` → `LLM_API_KEY` |

> These keep the `OPENHANDS_` prefix on purpose: they configure the underlying
> OpenHands SDK / LiteLLM layer, which Mitts wraps but does not rename. All three
> Mitts workflows read the same three names.

Set them with the `gh` CLI (from the repo directory):

```bash
gh variable set OPENHANDS_LLM_MODEL    --body "openai/<your-model-name>"
gh variable set OPENHANDS_LLM_BASE_URL --body "https://<your-endpoint>/v1"
gh secret   set OPENHANDS_LLM_API_KEY  --body "<your-api-key>"
```

Or in the UI: **Settings → Secrets and variables → Actions** → the **Variables**
tab for the first two, the **Secrets** tab for the key.

Two gotchas that cause almost every first-run failure:

- **Use the `openai/` prefix on the model** so LiteLLM treats it as an
  OpenAI-compatible backend (e.g. `openai/gpt-oss-120b`, `openai/llama-3.3-70b`).
- **The base URL usually needs the `/v1` suffix.** Confirm with your provider —
  some expose the OpenAI-compatible routes at the root, most at `/v1`.

Do **not** create a `GITHUB_TOKEN` secret — GitHub Actions injects it
automatically for every run. The bots authenticate to GitHub with it.

---

## 3. Allow Actions to open pull requests

By default a workflow's `GITHUB_TOKEN` can push a branch but **cannot open a
PR**. The issue → PR bot needs both.

**Settings → Actions → General → Workflow permissions:**

- Select **Read and write permissions**.
- Check **Allow GitHub Actions to create and approve pull requests**.

Without the checkbox, the issue bot pushes a `mitts/issue-<n>` branch but the
`gh pr create` step fails.

---

## 4. Protect `main` so the bot can't merge (structural containment)

This is the core of the Mitts security model: the agent runs with `contents:
write` + `pull-requests: write`, and the guarantee that **it can never land code
on `main` by itself** comes from branch protection, not from trusting the agent.

**Settings → Rules → Rulesets** (or classic **Branch protection rules**), on the
default branch:

- **Require a pull request before merging**, with at least **one approving
  review**.
- **Restrict who can push / bypass** to admins only.

The bot uses the built-in `GITHUB_TOKEN`, which is not an admin, so it can open
PRs but cannot merge them or push to `main` directly. A human approval stays in
the loop. See `mitts-bots.md` → "Structural containment" for the full reasoning
(why the behavioral hook is defense-in-depth, not the boundary).

> Skipping this is only acceptable on a throwaway/private repo you fully control.
> Do **not** point the bots at a repo that publishes releases without it — see
> the next step.

---

## 5. Gate the release secret behind `main` (if you publish)

This repo's `ruby-gem.yml` publishes to RubyGems using
`secrets.RUBYGEMS_AUTH_TOKEN`, and its publish job runs on `push` to
`refs/heads/main`. To make that secret unreachable to a prompt-injected agent,
move it behind a branch-scoped **Environment** so it's only readable from the
default branch.

**Settings → Environments → New environment** (e.g. `release`):

1. Add `RUBYGEMS_AUTH_TOKEN` as an **environment secret** (remove it as a plain
   repo secret so it's *only* available via the environment).
2. Under **Deployment branches and tags**, choose **Selected branches and tags**
   and allow only the default branch (add a tag pattern too if you tag releases).
3. Reference it from the publish job:

   ```yaml
   jobs:
     publish:
       environment: release
       # …
   ```

The chain this creates: no admin merge → nothing lands on `main` → no
`push`-to-`main` event → no `release` environment access → `RUBYGEMS_AUTH_TOKEN`
is never exposed. A compromised bot token pushing some *other* branch can't match
the deployment-branch policy, so the publish job is rejected before the secret is
readable.

> **If you don't publish anything**, you can skip this step — but still do step 4.
> **Caveat:** this guarantee holds for `push`/`pull_request` triggers. If you add
> secret-bearing jobs on `workflow_dispatch`, `release`, or `schedule` (which can
> fire without a merge), gate those with required reviewers on the environment
> too.

---

## 6. Decide who can trigger the bots

The write-capable paths — `mitts-issue`, `mitts-pr-followup`, and the on-demand
`@mitts review` comment — only run when the commenter's `author_association` is
`OWNER`, `MEMBER`, or `COLLABORATOR`. Everyone else (`CONTRIBUTOR`, `NONE`,
`FIRST_TIMER`) is ignored.

- **Nothing to configure to be safe** — the gate is already in the workflows.
- **To let a specific person trigger the bots**, add them as a **repo
  collaborator** (or org member) rather than loosening the gate. On a public
  repo, loosening it would let any stranger drive a write-capable agent with
  `@mitts implement <prompt injection>` and burn your LLM budget.

The **automatic** PR review on `opened`/`reopened` is intentionally *ungated* —
it's read-only (`contents: read`, only posts a review), which is the point of
reviewing incoming contributions.

---

## 7. Land the workflows on the default branch

GitHub only fires `issue_comment` triggers from workflow files that exist **on
the default branch**. The bots go live only once these are merged to `main` —
this is a GitHub rule, not a config choice.

```bash
git checkout -b add-mitts-bots
git add AGENTS.md .agents/ \
        .github/mitts .github/actions/run-mitts \
        .github/workflows/mitts-*.yml docs/mitts/
git commit -m "Add Mitts GitHub Actions bots (review, issue, PR follow-up)"
git push -u origin add-mitts-bots
gh pr create --fill
```

Merge that PR. Until it's on the default branch, commenting `@mitts …` does
nothing (the auto PR-review on `pull_request` will run from a branch, but the
comment-driven bots will not).

---

## 8. First run

Trigger one and watch it:

```bash
# e.g. comment "@mitts review" on any open PR, then:
gh run watch
```

Or open an issue and comment `@mitts what would it take to add X?` (a
question — no code change) as a low-risk first test.

**If the run fails**, the most likely cause is the model string or base URL:

- Adjust `OPENHANDS_LLM_MODEL` (try with/without the `openai/` prefix).
- Toggle the `/v1` suffix on `OPENHANDS_LLM_BASE_URL`.
- Re-trigger with a new comment.

Every run appends a cost/token summary (model, cost, prompt/completion tokens,
skills loaded) to the **Actions step summary** — open the run in the Actions UI
and click the summary tab. A run that ends `ERROR`/`STUCK` exits non-zero and the
workflow posts a failure comment on the issue/PR.

### What to expect on the first bot-opened PR

The built-in `GITHUB_TOKEN` does **not** retrigger other workflows, so a PR the
bot opens won't automatically run `test.yml` — its checks tab may look empty.
That's expected, not a hang. If you want the bot's PRs to trigger CI, use a PAT
or GitHub App token instead of the default token.

---

## 9. Optional environment knobs

All optional. Set as **Actions variables** (`gh variable set NAME --body VALUE`)
unless noted. Defaults are fine for most setups.

| Variable | Default | What it does |
|---|---|---|
| `LLM_MAX_ITER` | `60` | Max agent iterations per run. Lower to cap cost/runtime; raise for harder tasks. |
| `OPENHANDS_LOAD_PUBLIC_SKILLS` | off | `1`/`true` also loads skills from the `OpenHands/extensions` public registry (adds ~1–2 s for a git clone on first run). |
| `EXTENSIONS_REF` | `main` | Branch/tag/SHA for the public extensions repo. Pin to a tag for reproducibility once you're happy. |
| `OPENHANDS_KEEP_RUNS` | `5` | Prior-run subdirs retained per thread before each run. Older ones are pruned so the state artifact stays bounded. |

Set automatically by the composite action — **you do not set these**, listed for
reference:

- `OPENHANDS_PERSIST_DIR` — root dir for cross-run event persistence (from
  `runner.temp`).
- `OPENHANDS_CONVERSATION_KEY` — per-thread key for the artifact (e.g. `pr-42`,
  `issue-7`).

The `mitts-pr-review.yml` review action also accepts an `extensions-version:`
input (currently `main`) — pin it to a tag/SHA alongside `EXTENSIONS_REF` when
you want reproducible reviews.

---

## Verifying the setup (quick checklist)

- [ ] `gh variable list` shows `OPENHANDS_LLM_MODEL` and `OPENHANDS_LLM_BASE_URL`.
- [ ] `gh secret list` shows `OPENHANDS_LLM_API_KEY`.
- [ ] Settings → Actions → workflow permissions = **Read and write** + **create PRs** checked.
- [ ] Default branch requires a PR + 1 approval; bypass restricted to admins.
- [ ] (If publishing) `RUBYGEMS_AUTH_TOKEN` lives in a branch-scoped Environment, referenced via `environment:`.
- [ ] `mitts-*.yml` are on the default branch.
- [ ] A first `@mitts …` comment produced a run in the Actions tab.

---

## Usage reference

Once set up, drive the bots from issue/PR comments:

| You want to… | Where | Comment |
|---|---|---|
| Review a PR | PR | automatic on open/reopen, or `@mitts review` |
| Turn an issue into a PR | issue | `@mitts implement <optional detail>` |
| Ask about an issue | issue | `@mitts what would this involve?` (answers, no PR) |
| Change code on a PR | PR | `@mitts add error handling for nil config` |
| Ask about a PR | PR | `@mitts why did you use a mutex here?` (uses cross-run memory) |
| Propose a plan (no code) | issue or PR | `@mitts plan <optional detail>` |

Adding repo knowledge later: drop a new `.agents/skills/<name>/SKILL.md` (see the
`run-tests` skill for the format) — it's picked up automatically on the next run,
no config change needed.
