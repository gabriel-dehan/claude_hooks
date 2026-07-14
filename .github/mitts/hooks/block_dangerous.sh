#!/usr/bin/env bash
# PreToolUse hook — blocks dangerous terminal commands before the agent runs them.
#
# Called by the OpenHands SDK before every terminal tool execution. Receives the
# tool-call JSON on stdin (same contract as Claude Code hooks). Exit code semantics:
#   0  — allow the command to proceed
#   2  — DENY (SDK blocks the action and surfaces the reason to the agent)
#   1  — non-blocking error (logged but command still proceeds)
#
# Blocks:
#   • git push --force / -f          (never force-push from an automated agent)
#   • writes to .github/workflows/   (don't let the agent modify CI permissions)
#   • writes to .env, .envrc, or     (don't let the agent touch secret files)
#     files named *secret* / *credentials* / *api_key*

set -euo pipefail

# Read the full tool-call JSON from stdin.
input="$(cat)"

# Extract the shell command string.  The field is .tool_input.command for the
# OpenHands terminal tool; fall back to empty string if jq is unavailable or the
# field is absent (non-terminal tools should not reach this hook, but be safe).
if command -v jq &>/dev/null; then
    command_str="$(echo "$input" | jq -r '.tool_input.command // ""' 2>/dev/null || echo "")"
else
    # jq not available — do a best-effort grep extraction
    command_str="$(echo "$input" | grep -oP '(?<="command":")[^"]*' | head -1 || echo "")"
fi

# --- Rule 1: no force-push ---
if echo "$command_str" | grep -qE 'git\s+push\s+.*(-f|--force)\b|git\s+push\s+--force'; then
    printf '{"decision":"deny","reason":"Force-push is not allowed from automated agents. Use a normal push instead."}\n'
    exit 2
fi

# --- Rule 2: no writes to .github/workflows/ ---
# Matches: >, >>, tee, cp, mv, cat >, write_file, sed -i on paths under .github/workflows
if echo "$command_str" | grep -qE '\.github/workflows/'; then
    # Allow read-only access (cat, less, head, tail, grep, diff without redirect)
    if echo "$command_str" | grep -qE '(>|>>|\btee\b|\bcp\b|\bmv\b|\bsed\s+-i|\binstall\b).*\.github/workflows/|\.github/workflows/.*(\bcp\b|\bmv\b|>|>>|\btee\b)'; then
        printf '{"decision":"deny","reason":"Modifying .github/workflows/ files is not allowed. CI configuration must be changed by a human."}\n'
        exit 2
    fi
fi

# --- Rule 3: no writes to secret/credential files ---
if echo "$command_str" | grep -qiE '(>|>>|\btee\b|\bcp\b|\bmv\b)\s*(.*\s+)?(\.(env|envrc)|.*secret.*|.*credential.*|.*api[_-]?key.*)(\s|$)'; then
    printf '{"decision":"deny","reason":"Writing to secret or credential files is not allowed."}\n'
    exit 2
fi

# All checks passed — allow.
exit 0
