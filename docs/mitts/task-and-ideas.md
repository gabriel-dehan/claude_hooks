
## TODO:
- [x] Add an AGENTS.md — done (repo root; loaded by all bots via `load_available_skills`)
- [ ] Use OpenHandsAgentSettings
- [x] Idea: persistence but hybrid with a custom tool where it can fetch its own history if it needs to.
      — done. Deterministic context injection (context_builder.py) + on-demand cross-run
      memory via the recall_prior_reasoning custom tool (recall_tool.py) reading prior-run
      event dirs bridged across runs as GitHub artifacts. No auto-replay (fresh
      conversation_id each run). See docs/mitts/mitts-bots.md → "Hybrid context system".

## Done (harness feature additions)
- [x] Load AGENTS.md + project skills in agent_task.py via `load_available_skills`
      (issue/PR bots now load AGENTS.md + .agents/skills/ on every run)
- [x] AgentSkills: added `.agents/skills/run-tests/SKILL.md` as a progressive-disclosure example
- [x] Sub-agent delegation: `enable_sub_agents=True` + `register_builtins_agents()` wired
- [x] Guardrail hook: `.github/mitts/hooks/block_dangerous.sh` (force-push, CI, secrets)
- [x] Cost/status reporting: metrics to $GITHUB_STEP_SUMMARY; ERROR/STUCK → exit 1
- [x] Plan intent: `@mitts plan` branch in context_builder.py templates

## Tools

- Are there existing tools that we can use? 
https://github.com/OpenHands/software-agent-sdk/tree/main/openhands-tools/openhands/tools

- Do we need any custom tools? 
https://docs.openhands.dev/sdk/guides/custom-tools
  - [x] Yes — built `recall_prior_reasoning` (.github/mitts/recall_tool.py). Chosen over a skill.

## Skills

https://docs.openhands.dev/sdk/guides/skill
  - [x] AGENTS.md loaded via load_available_skills → load_project_skills (all bots)
  - [x] .agents/skills/ directory wired; run-tests SKILL.md added as example
  - Optional public skills via OPENHANDS_LOAD_PUBLIC_SKILLS=1

## Going further 

https://docs.openhands.dev/sdk/guides/iterative-refinement

### Subagents

- [x] Built-in subagents registered via register_builtins_agents()
- [x] TaskToolSet enabled (enable_sub_agents=True)
- Source: https://github.com/OpenHands/software-agent-sdk/tree/main/openhands-tools/openhands/tools/preset/subagents

### Triage

#### Issue triage on issues: opened

We have no automatic triage. max-sixty/tend auto-labels, checks duplicates, attempts reproduction, and may even open a fix PR for obvious bugs. A simpler version would just be: classify + look for duplicates + ask clarifying questions.

#### Meta review

review-reviewers — meta-quality loop

max-sixty/tend operates a hourly job that reviews the bot's own behavior on adopter repos, accumulating evidence in a gist over a month before acting. This is an interesting quality-assurance
layer we have nothing equivalent to.