#!/usr/bin/env python3
"""
Deterministic context assembler for the OpenHands GitHub-Actions bots.

Emits the ENTIRE AGENT_PROMPT body to stdout: a per-surface task template plus a
"CURRENT STATE (authoritative)" block gathered from GitHub via `gh`/`git`. The
workflow does one unquoted capture:

    AGENT_PROMPT="$(python .github/openhands/context_builder.py --surface pr)"

Emitting the whole prompt here (instead of a bash heredoc) removes shell-escaping
hazards and kills the drift between workflows.

Pure stdlib + `gh`/`git` — NO OpenHands SDK import, so it runs without `uv`.

Env read (set by the workflow):
    GITHUB_REPOSITORY   owner/repo
    GH_TOKEN/GITHUB_TOKEN   for `gh`
    NUMBER              PR or issue number
    COMMENT_BODY        the triggering comment (may be empty for pull_request events)
    COMMENT_AUTHOR      login of the commenter
    PR_TITLE / ISSUE_TITLE, HEAD_REF, BASE_REF (best-effort; re-fetched if absent)
"""

from __future__ import annotations

import argparse
import json
import os
import pathlib
import re
import subprocess
import sys

# --- Budgets (mirror the pr-review plugin's caps) ---
TOTAL_BUDGET_CHARS = 100_000
PER_FILE_DIFF_CAP = 12_000

REPO = os.getenv("GITHUB_REPOSITORY", "")
_INSTRUCTIONS_DIR = pathlib.Path(__file__).parent / "instructions"


def _load_instruction(name: str) -> str:
    path = _INSTRUCTIONS_DIR / name
    try:
        return path.read_text(encoding="utf-8").strip()
    except OSError as exc:
        print(f"context_builder: could not read {path}: {exc}", file=sys.stderr)
        sys.exit(1)


def _run(cmd: list[str]) -> str:
    """Run a command, returning stdout; empty string on failure (best-effort)."""
    try:
        out = subprocess.run(
            cmd, capture_output=True, text=True, timeout=120, check=False
        )
    except Exception as exc:  # noqa: BLE001
        print(f"context_builder: command failed {cmd!r}: {exc}", file=sys.stderr)
        return ""
    if out.returncode != 0:
        print(
            f"context_builder: {' '.join(cmd)} exited {out.returncode}: "
            f"{out.stderr.strip()[:300]}",
            file=sys.stderr,
        )
    return out.stdout


def _gh_json(args: list[str]) -> dict | list | None:
    raw = _run(["gh", *args])
    if not raw.strip():
        return None
    try:
        return json.loads(raw)
    except json.JSONDecodeError:
        return None


def _truncate(text: str, cap: int, label: str) -> str:
    if len(text) <= cap:
        return text
    keep = cap // 2
    head, tail = text[:keep], text[-keep:]
    omitted = len(text) - 2 * keep
    return f"{head}\n… [{label}: {omitted} chars truncated] …\n{tail}"


def _comment_thread(number: str) -> str:
    data = _gh_json(
        ["api", f"repos/{REPO}/issues/{number}/comments", "--paginate",
         "--jq", "[.[] | {user: .user.login, body: .body}]"]
    )
    if not data:
        return "(no comments yet)"
    lines = [f"@{c.get('user', '?')}: {c.get('body', '').strip()}" for c in data]
    return "\n\n".join(lines)


def _review_comments(number: str) -> str:
    data = _gh_json(
        ["api", f"repos/{REPO}/pulls/{number}/comments", "--paginate",
         "--jq", "[.[] | {user: .user.login, path: .path, body: .body}]"]
    )
    if not data:
        return ""
    lines = [
        f"@{c.get('user', '?')} on {c.get('path', '?')}: {c.get('body', '').strip()}"
        for c in data
    ]
    return "\n\n".join(lines)


def _linked_issue(pr_body: str) -> str:
    # Match GitHub's own closing-keyword grammar: the keyword must directly
    # precede "#<num>" (optionally with a colon), so prose like "closed #99 last
    # week" or "fixes #5's root cause" doesn't pull in an unrelated issue.
    m = re.search(
        r"(?:^|[\s(])(?:close[sd]?|fix(?:e[sd])?|resolve[sd]?):?\s+#(\d+)\b",
        pr_body,
        re.I,
    )
    if not m:
        return ""
    num = m.group(1)
    data = _gh_json(["issue", "view", num, "--repo", REPO, "--json", "title,body"])
    if not data:
        return ""
    return f"### Linked issue #{num}: {data.get('title', '')}\n\n{data.get('body', '')}"


# --------------------------------------------------------------------------- #
# Surface builders
# --------------------------------------------------------------------------- #

def build_pr() -> str:
    number = os.environ["NUMBER"]
    comment_author = os.getenv("COMMENT_AUTHOR", "a maintainer")
    comment_body = os.getenv("COMMENT_BODY", "").strip()

    pr = _gh_json(
        ["pr", "view", number, "--repo", REPO, "--json",
         "title,body,headRefName,baseRefName,author,state,labels"]
    ) or {}
    title = pr.get("title", os.getenv("PR_TITLE", ""))
    body = pr.get("body", "") or "(no description)"
    head = pr.get("headRefName", os.getenv("HEAD_REF", ""))
    base = pr.get("baseRefName", os.getenv("BASE_REF", "main"))

    thread = _comment_thread(number)
    inline = _review_comments(number)
    linked = _linked_issue(body)

    # Diff vs merge-base (three-dot), per-file capped.
    diff = _run(["git", "diff", f"origin/{base}...HEAD"]) or _run(
        ["git", "diff", f"{base}...HEAD"]
    )
    diff = _cap_diff(diff)

    task = _load_instruction("prs.md").format(number=number, head=head, author=comment_author)
    context = _CONTEXT_TEMPLATE.format(
        header=f"PR #{number}: {title}",
        body=body,
        thread=thread,
        extra=(f"\n### Inline review comments\n{inline}" if inline else "")
        + (f"\n\n{linked}" if linked else ""),
        diff=diff or "(no diff available — run `git diff` yourself)",
    )
    instruction = _INSTRUCTION.format(author=comment_author, comment=comment_body
                                      or "(no explicit comment — see thread above)")
    return _assemble(task, context, instruction)


def build_issue() -> str:
    number = os.environ["NUMBER"]
    comment_author = os.getenv("COMMENT_AUTHOR", "a maintainer")
    comment_body = os.getenv("COMMENT_BODY", "").strip()

    issue = _gh_json(
        ["issue", "view", number, "--repo", REPO, "--json", "title,body"]
    ) or {}
    title = issue.get("title", os.getenv("ISSUE_TITLE", ""))
    body = issue.get("body", "") or "(no description)"

    thread = _comment_thread(number)
    related = _gh_json(
        ["pr", "list", "--repo", REPO, "--search", f"{number} in:body",
         "--state", "all", "--json", "number,title,state,headRefName"]
    ) or []
    related_txt = "\n".join(
        f"- #{p['number']} ({p['state']}): {p['title']} [{p['headRefName']}]"
        for p in related
    ) or "(none)"

    task = _load_instruction("issues.md").format(number=number)
    context = _CONTEXT_TEMPLATE.format(
        header=f"Issue #{number}: {title}",
        body=body,
        thread=thread,
        extra=f"\n### Related pull requests\n{related_txt}",
        diff="(n/a for an issue)",
    )
    instruction = _INSTRUCTION.format(author=comment_author, comment=comment_body
                                      or "(no explicit comment — see thread above)")
    return _assemble(task, context, instruction)


def _cap_diff(diff: str) -> str:
    if not diff:
        return ""
    # Split on file boundaries, cap each file, then respect the total budget.
    chunks = re.split(r"(?=^diff --git )", diff, flags=re.M)
    capped = [_truncate(c, PER_FILE_DIFF_CAP, "file diff") for c in chunks if c.strip()]
    out = "\n".join(capped)
    return _truncate(out, TOTAL_BUDGET_CHARS // 2, "total diff")


def _assemble(task: str, context: str, instruction: str) -> str:
    prompt = f"{task}\n\n{context}\n\n{instruction}\n{_FOOTER}"
    # Final safety net: never exceed the overall budget.
    return _truncate(prompt, TOTAL_BUDGET_CHARS, "prompt")


# --------------------------------------------------------------------------- #
# Templates
# --------------------------------------------------------------------------- #

_CONTEXT_TEMPLATE = """\
================ CURRENT STATE (authoritative — this reflects reality NOW) ================
## {header}

### Description
{body}

### Conversation thread (oldest → newest)
{thread}
{extra}

### Current diff
```diff
{diff}
```
=========================================================================================="""

_INSTRUCTION = """\
---------------- TRIGGERING INSTRUCTION (by @{author}) ----------------
{comment}"""

_FOOTER = """
NOTE: The context above is a snapshot assembled at run start and may be truncated.
Use bash / `gh` / `git` to fetch anything not shown. On any conflict, the CURRENT
diff/code wins over recalled prior reasoning."""


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--surface", choices=["pr", "issue"], required=True)
    args = parser.parse_args()
    if not REPO:
        print("context_builder: GITHUB_REPOSITORY not set", file=sys.stderr)
        sys.exit(1)
    sys.stdout.write(build_pr() if args.surface == "pr" else build_issue())


if __name__ == "__main__":
    main()
