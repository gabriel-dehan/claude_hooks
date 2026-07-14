---
name: ci-monitoring
description: >
  How to wait for GitHub Actions CI to finish on a PR after pushing commits,
  without hanging forever or giving up too early. Use this skill whenever you
  have pushed to a PR branch and need to confirm the checks pass before
  reporting back or approving.
triggers:
  - ci
  - checks
  - status check
  - wait for ci
  - green
  - pipeline
---

# Waiting for CI on a PR

After you push commits to a PR branch, the PR's checks (`test.yml`, `ruby-gem.yml`)
re-run. You often need to confirm they pass before you comment "done" or before a
review approves. This is easy to get wrong in two opposite ways — hanging forever,
or declaring success while checks are still pending. Follow this pattern.

## Do NOT use the blocking watchers

These hang until completion with no timeout and will burn the whole run's time
budget (the agent's bash step is capped at ~10 minutes):

```bash
gh run watch          # ❌ blocks indefinitely
gh pr checks --watch  # ❌ blocks indefinitely
```

## Poll `statusCheckRollup` in a bounded foreground loop

Query the PR's aggregated check state and sleep between polls. Use
`statusCheckRollup`, **not** `gh pr checks --required`: the latter only returns
contexts that are *already registered*, so a check that registers late (a matrix
job, or a summary job with a long `needs:` list) can make it exit green early and
miss a failure.

```bash
PR=<pr-number>
for i in $(seq 1 9); do
  # One JSON blob with every check's name, status, and conclusion.
  rollup=$(gh pr view "$PR" --json statusCheckRollup \
    --jq '.statusCheckRollup[] | {name: .name, status: .status, conclusion: .conclusion}')

  # Are any checks still running / queued?
  pending=$(echo "$rollup" | jq -sr '[.[] | select(.status != "COMPLETED")] | length')

  if [ "$pending" -eq 0 ]; then
    echo "All checks completed."
    break
  fi
  echo "Attempt $i/9: $pending check(s) still running; sleeping 60s…"
  sleep 60
done
```

That is 9 × 60s = ~9 minutes, which fits inside the bash step cap. If checks are
still pending after the loop, say so explicitly ("CI was still running when I
checked — see the PR checks tab") rather than claiming success.

## Decide pass/fail from the final rollup

A check passed only when `status == "COMPLETED"` **and**
`conclusion == "SUCCESS"` (or `NEUTRAL`/`SKIPPED`). Treat `FAILURE`,
`TIMED_OUT`, `CANCELLED`, `ACTION_REQUIRED`, or `STALE` as failing.

```bash
failed=$(gh pr view "$PR" --json statusCheckRollup \
  --jq '[.statusCheckRollup[]
         | select(.conclusion != null and .conclusion != "SUCCESS"
                  and .conclusion != "NEUTRAL" and .conclusion != "SKIPPED")]
        | length')
if [ "$failed" -gt 0 ]; then
  echo "CI failed — inspect the failing job before reporting done."
fi
```

Do **not** treat `mergeStateStatus == BLOCKED` as a CI failure — it's a catch-all
(branch protection, pending review, etc.), not a check result.

## When a check fails

- Read the failing job's logs (`gh run view <run-id> --log-failed`) and fix the
  cause. For this Ruby gem, most failures are the test suite — see the
  `run-tests` skill.
- Re-run only the failed jobs if the failure looks transient (rare here):
  `gh run rerun <run-id> --failed`.
- Never mark a PR done or approve over red CI. If you approve, the empty-body
  approval reads as endorsing a broken build.

## Notes specific to this repo

- Relevant workflows on a PR: **`test.yml`** (Ruby 3.2 + 3.3 matrix — the one that
  matters for correctness) and **`ruby-gem.yml`** (its publish job is gated on
  `push` to `main`, so on a PR it only builds — a failure there is still worth
  reading).
- A PR the bot opened may **not** auto-run these workflows: the built-in
  `GITHUB_TOKEN` does not retrigger other workflows. If the checks tab is empty on
  a bot-opened PR, that's expected, not a hang — note it and move on.
