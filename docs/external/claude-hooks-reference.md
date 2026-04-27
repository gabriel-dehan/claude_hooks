[Skip to main content](https://code.claude.com/docs/en/hooks#content-area)

[Claude Code Docs home page![light logo](https://mintcdn.com/claude-code/c5r9_6tjPMzFdDDT/logo/light.svg?fit=max&auto=format&n=c5r9_6tjPMzFdDDT&q=85&s=78fd01ff4f4340295a4f66e2ea54903c)![dark logo](https://mintcdn.com/claude-code/c5r9_6tjPMzFdDDT/logo/dark.svg?fit=max&auto=format&n=c5r9_6tjPMzFdDDT&q=85&s=1298a0c3b3a1da603b190d0de0e31712)](https://code.claude.com/docs/en/overview)

![US](https://d3gk2c5xim1je2.cloudfront.net/flags/US.svg)

English

Search...

Ctrl KAsk AI

Search...

Navigation

Reference

Hooks reference

[Getting started](https://code.claude.com/docs/en/overview) [Build with Claude Code](https://code.claude.com/docs/en/sub-agents) [Deployment](https://code.claude.com/docs/en/third-party-integrations) [Administration](https://code.claude.com/docs/en/admin-setup) [Configuration](https://code.claude.com/docs/en/settings) [Reference](https://code.claude.com/docs/en/cli-reference) [Agent SDK](https://code.claude.com/docs/en/agent-sdk/overview) [What's New](https://code.claude.com/docs/en/whats-new) [Resources](https://code.claude.com/docs/en/legal-and-compliance)

On this page

- [Hook lifecycle](https://code.claude.com/docs/en/hooks#hook-lifecycle)
- [How a hook resolves](https://code.claude.com/docs/en/hooks#how-a-hook-resolves)
- [Configuration](https://code.claude.com/docs/en/hooks#configuration)
- [Hook locations](https://code.claude.com/docs/en/hooks#hook-locations)
- [Matcher patterns](https://code.claude.com/docs/en/hooks#matcher-patterns)
- [Match MCP tools](https://code.claude.com/docs/en/hooks#match-mcp-tools)
- [Hook handler fields](https://code.claude.com/docs/en/hooks#hook-handler-fields)
- [Common fields](https://code.claude.com/docs/en/hooks#common-fields)
- [Command hook fields](https://code.claude.com/docs/en/hooks#command-hook-fields)
- [HTTP hook fields](https://code.claude.com/docs/en/hooks#http-hook-fields)
- [MCP tool hook fields](https://code.claude.com/docs/en/hooks#mcp-tool-hook-fields)
- [Prompt and agent hook fields](https://code.claude.com/docs/en/hooks#prompt-and-agent-hook-fields)
- [Reference scripts by path](https://code.claude.com/docs/en/hooks#reference-scripts-by-path)
- [Hooks in skills and agents](https://code.claude.com/docs/en/hooks#hooks-in-skills-and-agents)
- [The /hooks menu](https://code.claude.com/docs/en/hooks#the-%2Fhooks-menu)
- [Disable or remove hooks](https://code.claude.com/docs/en/hooks#disable-or-remove-hooks)
- [Hook input and output](https://code.claude.com/docs/en/hooks#hook-input-and-output)
- [Common input fields](https://code.claude.com/docs/en/hooks#common-input-fields)
- [Exit code output](https://code.claude.com/docs/en/hooks#exit-code-output)
- [Exit code 2 behavior per event](https://code.claude.com/docs/en/hooks#exit-code-2-behavior-per-event)
- [HTTP response handling](https://code.claude.com/docs/en/hooks#http-response-handling)
- [JSON output](https://code.claude.com/docs/en/hooks#json-output)
- [Decision control](https://code.claude.com/docs/en/hooks#decision-control)
- [Hook events](https://code.claude.com/docs/en/hooks#hook-events)
- [SessionStart](https://code.claude.com/docs/en/hooks#sessionstart)
- [SessionStart input](https://code.claude.com/docs/en/hooks#sessionstart-input)
- [SessionStart decision control](https://code.claude.com/docs/en/hooks#sessionstart-decision-control)
- [Persist environment variables](https://code.claude.com/docs/en/hooks#persist-environment-variables)
- [InstructionsLoaded](https://code.claude.com/docs/en/hooks#instructionsloaded)
- [InstructionsLoaded input](https://code.claude.com/docs/en/hooks#instructionsloaded-input)
- [InstructionsLoaded decision control](https://code.claude.com/docs/en/hooks#instructionsloaded-decision-control)
- [UserPromptSubmit](https://code.claude.com/docs/en/hooks#userpromptsubmit)
- [UserPromptSubmit input](https://code.claude.com/docs/en/hooks#userpromptsubmit-input)
- [UserPromptSubmit decision control](https://code.claude.com/docs/en/hooks#userpromptsubmit-decision-control)
- [UserPromptExpansion](https://code.claude.com/docs/en/hooks#userpromptexpansion)
- [UserPromptExpansion input](https://code.claude.com/docs/en/hooks#userpromptexpansion-input)
- [UserPromptExpansion decision control](https://code.claude.com/docs/en/hooks#userpromptexpansion-decision-control)
- [PreToolUse](https://code.claude.com/docs/en/hooks#pretooluse)
- [PreToolUse input](https://code.claude.com/docs/en/hooks#pretooluse-input)
- [PreToolUse decision control](https://code.claude.com/docs/en/hooks#pretooluse-decision-control)
- [Defer a tool call for later](https://code.claude.com/docs/en/hooks#defer-a-tool-call-for-later)
- [PermissionRequest](https://code.claude.com/docs/en/hooks#permissionrequest)
- [PermissionRequest input](https://code.claude.com/docs/en/hooks#permissionrequest-input)
- [PermissionRequest decision control](https://code.claude.com/docs/en/hooks#permissionrequest-decision-control)
- [Permission update entries](https://code.claude.com/docs/en/hooks#permission-update-entries)
- [PostToolUse](https://code.claude.com/docs/en/hooks#posttooluse)
- [PostToolUse input](https://code.claude.com/docs/en/hooks#posttooluse-input)
- [PostToolUse decision control](https://code.claude.com/docs/en/hooks#posttooluse-decision-control)
- [PostToolUseFailure](https://code.claude.com/docs/en/hooks#posttoolusefailure)
- [PostToolUseFailure input](https://code.claude.com/docs/en/hooks#posttoolusefailure-input)
- [PostToolUseFailure decision control](https://code.claude.com/docs/en/hooks#posttoolusefailure-decision-control)
- [PostToolBatch](https://code.claude.com/docs/en/hooks#posttoolbatch)
- [PostToolBatch input](https://code.claude.com/docs/en/hooks#posttoolbatch-input)
- [PostToolBatch decision control](https://code.claude.com/docs/en/hooks#posttoolbatch-decision-control)
- [PermissionDenied](https://code.claude.com/docs/en/hooks#permissiondenied)
- [PermissionDenied input](https://code.claude.com/docs/en/hooks#permissiondenied-input)
- [PermissionDenied decision control](https://code.claude.com/docs/en/hooks#permissiondenied-decision-control)
- [Notification](https://code.claude.com/docs/en/hooks#notification)
- [Notification input](https://code.claude.com/docs/en/hooks#notification-input)
- [SubagentStart](https://code.claude.com/docs/en/hooks#subagentstart)
- [SubagentStart input](https://code.claude.com/docs/en/hooks#subagentstart-input)
- [SubagentStop](https://code.claude.com/docs/en/hooks#subagentstop)
- [SubagentStop input](https://code.claude.com/docs/en/hooks#subagentstop-input)
- [TaskCreated](https://code.claude.com/docs/en/hooks#taskcreated)
- [TaskCreated input](https://code.claude.com/docs/en/hooks#taskcreated-input)
- [TaskCreated decision control](https://code.claude.com/docs/en/hooks#taskcreated-decision-control)
- [TaskCompleted](https://code.claude.com/docs/en/hooks#taskcompleted)
- [TaskCompleted input](https://code.claude.com/docs/en/hooks#taskcompleted-input)
- [TaskCompleted decision control](https://code.claude.com/docs/en/hooks#taskcompleted-decision-control)
- [Stop](https://code.claude.com/docs/en/hooks#stop)
- [Stop input](https://code.claude.com/docs/en/hooks#stop-input)
- [Stop decision control](https://code.claude.com/docs/en/hooks#stop-decision-control)
- [StopFailure](https://code.claude.com/docs/en/hooks#stopfailure)
- [StopFailure input](https://code.claude.com/docs/en/hooks#stopfailure-input)
- [TeammateIdle](https://code.claude.com/docs/en/hooks#teammateidle)
- [TeammateIdle input](https://code.claude.com/docs/en/hooks#teammateidle-input)
- [TeammateIdle decision control](https://code.claude.com/docs/en/hooks#teammateidle-decision-control)
- [ConfigChange](https://code.claude.com/docs/en/hooks#configchange)
- [ConfigChange input](https://code.claude.com/docs/en/hooks#configchange-input)
- [ConfigChange decision control](https://code.claude.com/docs/en/hooks#configchange-decision-control)
- [CwdChanged](https://code.claude.com/docs/en/hooks#cwdchanged)
- [CwdChanged input](https://code.claude.com/docs/en/hooks#cwdchanged-input)
- [CwdChanged output](https://code.claude.com/docs/en/hooks#cwdchanged-output)
- [FileChanged](https://code.claude.com/docs/en/hooks#filechanged)
- [FileChanged input](https://code.claude.com/docs/en/hooks#filechanged-input)
- [FileChanged output](https://code.claude.com/docs/en/hooks#filechanged-output)
- [WorktreeCreate](https://code.claude.com/docs/en/hooks#worktreecreate)
- [WorktreeCreate input](https://code.claude.com/docs/en/hooks#worktreecreate-input)
- [WorktreeCreate output](https://code.claude.com/docs/en/hooks#worktreecreate-output)
- [WorktreeRemove](https://code.claude.com/docs/en/hooks#worktreeremove)
- [WorktreeRemove input](https://code.claude.com/docs/en/hooks#worktreeremove-input)
- [PreCompact](https://code.claude.com/docs/en/hooks#precompact)
- [PreCompact input](https://code.claude.com/docs/en/hooks#precompact-input)
- [PostCompact](https://code.claude.com/docs/en/hooks#postcompact)
- [PostCompact input](https://code.claude.com/docs/en/hooks#postcompact-input)
- [SessionEnd](https://code.claude.com/docs/en/hooks#sessionend)
- [SessionEnd input](https://code.claude.com/docs/en/hooks#sessionend-input)
- [Elicitation](https://code.claude.com/docs/en/hooks#elicitation)
- [Elicitation input](https://code.claude.com/docs/en/hooks#elicitation-input)
- [Elicitation output](https://code.claude.com/docs/en/hooks#elicitation-output)
- [ElicitationResult](https://code.claude.com/docs/en/hooks#elicitationresult)
- [ElicitationResult input](https://code.claude.com/docs/en/hooks#elicitationresult-input)
- [ElicitationResult output](https://code.claude.com/docs/en/hooks#elicitationresult-output)
- [Prompt-based hooks](https://code.claude.com/docs/en/hooks#prompt-based-hooks)
- [How prompt-based hooks work](https://code.claude.com/docs/en/hooks#how-prompt-based-hooks-work)
- [Prompt hook configuration](https://code.claude.com/docs/en/hooks#prompt-hook-configuration)
- [Response schema](https://code.claude.com/docs/en/hooks#response-schema)
- [Example: Multi-criteria Stop hook](https://code.claude.com/docs/en/hooks#example-multi-criteria-stop-hook)
- [Agent-based hooks](https://code.claude.com/docs/en/hooks#agent-based-hooks)
- [How agent hooks work](https://code.claude.com/docs/en/hooks#how-agent-hooks-work)
- [Agent hook configuration](https://code.claude.com/docs/en/hooks#agent-hook-configuration)
- [Run hooks in the background](https://code.claude.com/docs/en/hooks#run-hooks-in-the-background)
- [Configure an async hook](https://code.claude.com/docs/en/hooks#configure-an-async-hook)
- [How async hooks execute](https://code.claude.com/docs/en/hooks#how-async-hooks-execute)
- [Example: run tests after file changes](https://code.claude.com/docs/en/hooks#example-run-tests-after-file-changes)
- [Limitations](https://code.claude.com/docs/en/hooks#limitations)
- [Security considerations](https://code.claude.com/docs/en/hooks#security-considerations)
- [Disclaimer](https://code.claude.com/docs/en/hooks#disclaimer)
- [Security best practices](https://code.claude.com/docs/en/hooks#security-best-practices)
- [Windows PowerShell tool](https://code.claude.com/docs/en/hooks#windows-powershell-tool)
- [Debug hooks](https://code.claude.com/docs/en/hooks#debug-hooks)

For a quickstart guide with examples, see [Automate workflows with hooks](https://code.claude.com/docs/en/hooks-guide).

Hooks are user-defined shell commands, HTTP endpoints, or LLM prompts that execute automatically at specific points in Claude Code’s lifecycle. Use this reference to look up event schemas, configuration options, JSON input/output formats, and advanced features like async hooks, HTTP hooks, and MCP tool hooks. If you’re setting up hooks for the first time, start with the [guide](https://code.claude.com/docs/en/hooks-guide) instead.

## [​](https://code.claude.com/docs/en/hooks\#hook-lifecycle)  Hook lifecycle

Hooks fire at specific points during a Claude Code session. When an event fires and a matcher matches, Claude Code passes JSON context about the event to your hook handler. For command hooks, input arrives on stdin. For HTTP hooks, it arrives as the POST request body. Your handler can then inspect the input, take action, and optionally return a decision. Events fall into three cadences: once per session (`SessionStart`, `SessionEnd`), once per turn (`UserPromptSubmit`, `Stop`, `StopFailure`), and on every tool call inside the agentic loop (`PreToolUse`, `PostToolUse`):

![Hook lifecycle diagram showing SessionStart, then a per-turn loop containing UserPromptSubmit, UserPromptExpansion for slash commands, the nested agentic loop (PreToolUse, PermissionRequest, PostToolUse, PostToolUseFailure, PostToolBatch, SubagentStart/Stop, TaskCreated, TaskCompleted), and Stop or StopFailure, followed by TeammateIdle, PreCompact, PostCompact, and SessionEnd, with Elicitation and ElicitationResult nested inside MCP tool execution, PermissionDenied as a side branch from PermissionRequest for auto-mode denials, and WorktreeCreate, WorktreeRemove, Notification, ConfigChange, InstructionsLoaded, CwdChanged, and FileChanged as standalone async events](https://mintcdn.com/claude-code/_SQ1BnFTP0QUrae-/images/hooks-lifecycle.svg?fit=max&auto=format&n=_SQ1BnFTP0QUrae-&q=85&s=75bd3d4bdefd4f08a7d736167243fd78)

The table below summarizes when each event fires. The [Hook events](https://code.claude.com/docs/en/hooks#hook-events) section documents the full input schema and decision control options for each one.

| Event | When it fires |
| --- | --- |
| `SessionStart` | When a session begins or resumes |
| `UserPromptSubmit` | When you submit a prompt, before Claude processes it |
| `UserPromptExpansion` | When a user-typed command expands into a prompt, before it reaches Claude. Can block the expansion |
| `PreToolUse` | Before a tool call executes. Can block it |
| `PermissionRequest` | When a permission dialog appears |
| `PermissionDenied` | When a tool call is denied by the auto mode classifier. Return `{retry: true}` to tell the model it may retry the denied tool call |
| `PostToolUse` | After a tool call succeeds |
| `PostToolUseFailure` | After a tool call fails |
| `PostToolBatch` | After a full batch of parallel tool calls resolves, before the next model call |
| `Notification` | When Claude Code sends a notification |
| `SubagentStart` | When a subagent is spawned |
| `SubagentStop` | When a subagent finishes |
| `TaskCreated` | When a task is being created via `TaskCreate` |
| `TaskCompleted` | When a task is being marked as completed |
| `Stop` | When Claude finishes responding |
| `StopFailure` | When the turn ends due to an API error. Output and exit code are ignored |
| `TeammateIdle` | When an [agent team](https://code.claude.com/docs/en/agent-teams) teammate is about to go idle |
| `InstructionsLoaded` | When a CLAUDE.md or `.claude/rules/*.md` file is loaded into context. Fires at session start and when files are lazily loaded during a session |
| `ConfigChange` | When a configuration file changes during a session |
| `CwdChanged` | When the working directory changes, for example when Claude executes a `cd` command. Useful for reactive environment management with tools like direnv |
| `FileChanged` | When a watched file changes on disk. The `matcher` field specifies which filenames to watch |
| `WorktreeCreate` | When a worktree is being created via `--worktree` or `isolation: "worktree"`. Replaces default git behavior |
| `WorktreeRemove` | When a worktree is being removed, either at session exit or when a subagent finishes |
| `PreCompact` | Before context compaction |
| `PostCompact` | After context compaction completes |
| `Elicitation` | When an MCP server requests user input during a tool call |
| `ElicitationResult` | After a user responds to an MCP elicitation, before the response is sent back to the server |
| `SessionEnd` | When a session terminates |

### [​](https://code.claude.com/docs/en/hooks\#how-a-hook-resolves)  How a hook resolves

To see how these pieces fit together, consider this `PreToolUse` hook that blocks destructive shell commands. The `matcher` narrows to Bash tool calls and the `if` condition narrows further to Bash subcommands matching `rm *`, so `block-rm.sh` only spawns when both filters match:

```
{
  "hooks": {
    "PreToolUse": [\
      {\
        "matcher": "Bash",\
        "hooks": [\
          {\
            "type": "command",\
            "if": "Bash(rm *)",\
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/block-rm.sh"\
          }\
        ]\
      }\
    ]
  }
}
```

The script reads the JSON input from stdin, extracts the command, and returns a `permissionDecision` of `"deny"` if it contains `rm -rf`:

```
#!/bin/bash
# .claude/hooks/block-rm.sh
COMMAND=$(jq -r '.tool_input.command')

if echo "$COMMAND" | grep -q 'rm -rf'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Destructive command blocked by hook"
    }
  }'
else
  exit 0  # allow the command
fi
```

Now suppose Claude Code decides to run `Bash "rm -rf /tmp/build"`. Here’s what happens:

![Hook resolution flow: PreToolUse event fires, matcher checks for Bash match, if condition checks for Bash(rm *) match, hook handler runs, result returns to Claude Code](https://mintcdn.com/claude-code/-tYw1BD_DEqfyyOZ/images/hook-resolution.svg?fit=max&auto=format&n=-tYw1BD_DEqfyyOZ&q=85&s=c73ebc1eeda2037570427d7af1e0a891)

1

[Navigate to header](https://code.claude.com/docs/en/hooks#)

Event fires

The `PreToolUse` event fires. Claude Code sends the tool input as JSON on stdin to the hook:

```
{ "tool_name": "Bash", "tool_input": { "command": "rm -rf /tmp/build" }, ... }
```

2

[Navigate to header](https://code.claude.com/docs/en/hooks#)

Matcher checks

The matcher `"Bash"` matches the tool name, so this hook group activates. If you omit the matcher or use `"*"`, the group activates on every occurrence of the event.

3

[Navigate to header](https://code.claude.com/docs/en/hooks#)

If condition checks

The `if` condition `"Bash(rm *)"` matches because `rm -rf /tmp/build` is a subcommand matching `rm *`, so this handler spawns. If the command had been `npm test`, the `if` check would fail and `block-rm.sh` would never run, avoiding the process spawn overhead. The `if` field is optional; without it, every handler in the matched group runs.

4

[Navigate to header](https://code.claude.com/docs/en/hooks#)

Hook handler runs

The script inspects the full command and finds `rm -rf`, so it prints a decision to stdout:

```
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Destructive command blocked by hook"
  }
}
```

If the command had been a safer `rm` variant like `rm file.txt`, the script would hit `exit 0` instead, which tells Claude Code to allow the tool call with no further action.

5

[Navigate to header](https://code.claude.com/docs/en/hooks#)

Claude Code acts on the result

Claude Code reads the JSON decision, blocks the tool call, and shows Claude the reason.

The [Configuration](https://code.claude.com/docs/en/hooks#configuration) section below documents the full schema, and each [hook event](https://code.claude.com/docs/en/hooks#hook-events) section documents what input your command receives and what output it can return.

## [​](https://code.claude.com/docs/en/hooks\#configuration)  Configuration

Hooks are defined in JSON settings files. The configuration has three levels of nesting:

1. Choose a [hook event](https://code.claude.com/docs/en/hooks#hook-events) to respond to, like `PreToolUse` or `Stop`
2. Add a [matcher group](https://code.claude.com/docs/en/hooks#matcher-patterns) to filter when it fires, like “only for the Bash tool”
3. Define one or more [hook handlers](https://code.claude.com/docs/en/hooks#hook-handler-fields) to run when matched

See [How a hook resolves](https://code.claude.com/docs/en/hooks#how-a-hook-resolves) above for a complete walkthrough with an annotated example.

This page uses specific terms for each level: **hook event** for the lifecycle point, **matcher group** for the filter, and **hook handler** for the shell command, HTTP endpoint, MCP tool, prompt, or agent that runs. “Hook” on its own refers to the general feature.

### [​](https://code.claude.com/docs/en/hooks\#hook-locations)  Hook locations

Where you define a hook determines its scope:

| Location | Scope | Shareable |
| --- | --- | --- |
| `~/.claude/settings.json` | All your projects | No, local to your machine |
| `.claude/settings.json` | Single project | Yes, can be committed to the repo |
| `.claude/settings.local.json` | Single project | No, gitignored |
| Managed policy settings | Organization-wide | Yes, admin-controlled |
| [Plugin](https://code.claude.com/docs/en/plugins)`hooks/hooks.json` | When plugin is enabled | Yes, bundled with the plugin |
| [Skill](https://code.claude.com/docs/en/skills) or [agent](https://code.claude.com/docs/en/sub-agents) frontmatter | While the component is active | Yes, defined in the component file |

For details on settings file resolution, see [settings](https://code.claude.com/docs/en/settings). Enterprise administrators can use `allowManagedHooksOnly` to block user, project, and plugin hooks. Hooks from plugins force-enabled in managed settings `enabledPlugins` are exempt, so administrators can distribute vetted hooks through an organization marketplace. See [Hook configuration](https://code.claude.com/docs/en/settings#hook-configuration).

### [​](https://code.claude.com/docs/en/hooks\#matcher-patterns)  Matcher patterns

The `matcher` field filters when hooks fire. How a matcher is evaluated depends on the characters it contains:

| Matcher value | Evaluated as | Example |
| --- | --- | --- |
| `"*"`, `""`, or omitted | Match all | fires on every occurrence of the event |
| Only letters, digits, `_`, and `|` | Exact string, or `|`-separated list of exact strings | `Bash` matches only the Bash tool; `Edit|Write` matches either tool exactly |
| Contains any other character | JavaScript regular expression | `^Notebook` matches any tool starting with Notebook; `mcp__memory__.*` matches every tool from the `memory` server |

The `FileChanged` event does not follow these rules when building its watch list. See [FileChanged](https://code.claude.com/docs/en/hooks#filechanged).Each event type matches on a different field:

| Event | What the matcher filters | Example matcher values |
| --- | --- | --- |
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied` | tool name | `Bash`, `Edit|Write`, `mcp__.*` |
| `SessionStart` | how the session started | `startup`, `resume`, `clear`, `compact` |
| `SessionEnd` | why the session ended | `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |
| `Notification` | notification type | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog` |
| `SubagentStart` | agent type | `Bash`, `Explore`, `Plan`, or custom agent names |
| `PreCompact`, `PostCompact` | what triggered compaction | `manual`, `auto` |
| `SubagentStop` | agent type | same values as `SubagentStart` |
| `ConfigChange` | configuration source | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `CwdChanged` | no matcher support | always fires on every directory change |
| `FileChanged` | literal filenames to watch (see [FileChanged](https://code.claude.com/docs/en/hooks#filechanged)) | `.envrc|.env` |
| `StopFailure` | error type | `rate_limit`, `authentication_failed`, `billing_error`, `invalid_request`, `server_error`, `max_output_tokens`, `unknown` |
| `InstructionsLoaded` | load reason | `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `UserPromptExpansion` | command name | your skill or command names |
| `Elicitation` | MCP server name | your configured MCP server names |
| `ElicitationResult` | MCP server name | same values as `Elicitation` |
| `UserPromptSubmit`, `PostToolBatch`, `Stop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `WorktreeCreate`, `WorktreeRemove` | no matcher support | always fires on every occurrence |

The matcher runs against a field from the [JSON input](https://code.claude.com/docs/en/hooks#hook-input-and-output) that Claude Code sends to your hook on stdin. For tool events, that field is `tool_name`. Each [hook event](https://code.claude.com/docs/en/hooks#hook-events) section lists the full set of matcher values and the input schema for that event.This example runs a linting script only when Claude writes or edits a file:

```
{
  "hooks": {
    "PostToolUse": [\
      {\
        "matcher": "Edit|Write",\
        "hooks": [\
          {\
            "type": "command",\
            "command": "/path/to/lint-check.sh"\
          }\
        ]\
      }\
    ]
  }
}
```

`UserPromptSubmit`, `PostToolBatch`, `Stop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `WorktreeCreate`, `WorktreeRemove`, and `CwdChanged` don’t support matchers and always fire on every occurrence. If you add a `matcher` field to these events, it is silently ignored.For tool events, you can filter more narrowly by setting the [`if` field](https://code.claude.com/docs/en/hooks#common-fields) on individual hook handlers. `if` uses [permission rule syntax](https://code.claude.com/docs/en/permissions) to match against the tool name and arguments together, so `"Bash(git *)"` runs when any subcommand of the Bash input matches `git *` and `"Edit(*.ts)"` runs only for TypeScript files.

#### [​](https://code.claude.com/docs/en/hooks\#match-mcp-tools)  Match MCP tools

[MCP](https://code.claude.com/docs/en/mcp) server tools appear as regular tools in tool events (`PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied`), so you can match them the same way you match any other tool name.MCP tools follow the naming pattern `mcp__<server>__<tool>`, for example:

- `mcp__memory__create_entities`: Memory server’s create entities tool
- `mcp__filesystem__read_file`: Filesystem server’s read file tool
- `mcp__github__search_repositories`: GitHub server’s search tool

To match every tool from a server, append `.*` to the server prefix. The `.*` is required: a matcher like `mcp__memory` contains only letters and underscores, so it is compared as an exact string and matches no tool.

- `mcp__memory__.*` matches all tools from the `memory` server
- `mcp__.*__write.*` matches any tool whose name starts with `write` from any server

This example logs all memory server operations and validates write operations from any MCP server:

```
{
  "hooks": {
    "PreToolUse": [\
      {\
        "matcher": "mcp__memory__.*",\
        "hooks": [\
          {\
            "type": "command",\
            "command": "echo 'Memory operation initiated' >> ~/mcp-operations.log"\
          }\
        ]\
      },\
      {\
        "matcher": "mcp__.*__write.*",\
        "hooks": [\
          {\
            "type": "command",\
            "command": "/home/user/scripts/validate-mcp-write.py"\
          }\
        ]\
      }\
    ]
  }
}
```

### [​](https://code.claude.com/docs/en/hooks\#hook-handler-fields)  Hook handler fields

Each object in the inner `hooks` array is a hook handler: the shell command, HTTP endpoint, MCP tool, LLM prompt, or agent that runs when the matcher matches. There are five types:

- **[Command hooks](https://code.claude.com/docs/en/hooks#command-hook-fields)** (`type: "command"`): run a shell command. Your script receives the event’s [JSON input](https://code.claude.com/docs/en/hooks#hook-input-and-output) on stdin and communicates results back through exit codes and stdout.
- **[HTTP hooks](https://code.claude.com/docs/en/hooks#http-hook-fields)** (`type: "http"`): send the event’s JSON input as an HTTP POST request to a URL. The endpoint communicates results back through the response body using the same [JSON output format](https://code.claude.com/docs/en/hooks#json-output) as command hooks.
- **[MCP tool hooks](https://code.claude.com/docs/en/hooks#mcp-tool-hook-fields)** (`type: "mcp_tool"`): call a tool on an already-connected [MCP server](https://code.claude.com/docs/en/mcp). The tool’s text output is treated like command-hook stdout.
- **[Prompt hooks](https://code.claude.com/docs/en/hooks#prompt-and-agent-hook-fields)** (`type: "prompt"`): send a prompt to a Claude model for single-turn evaluation. The model returns a yes/no decision as JSON. See [Prompt-based hooks](https://code.claude.com/docs/en/hooks#prompt-based-hooks).
- **[Agent hooks](https://code.claude.com/docs/en/hooks#prompt-and-agent-hook-fields)** (`type: "agent"`): spawn a subagent that can use tools like Read, Grep, and Glob to verify conditions before returning a decision. Agent hooks are experimental and may change. See [Agent-based hooks](https://code.claude.com/docs/en/hooks#agent-based-hooks).

#### [​](https://code.claude.com/docs/en/hooks\#common-fields)  Common fields

These fields apply to all hook types:

| Field | Required | Description |
| --- | --- | --- |
| `type` | yes | `"command"`, `"http"`, `"mcp_tool"`, `"prompt"`, or `"agent"` |
| `if` | no | Permission rule syntax to filter when this hook runs, such as `"Bash(git *)"` or `"Edit(*.ts)"`. The hook only spawns if the tool call matches the pattern, or if a Bash command is too complex to parse. Only evaluated on tool events: `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, and `PermissionDenied`. On other events, a hook with `if` set never runs. Uses the same syntax as [permission rules](https://code.claude.com/docs/en/permissions) |
| `timeout` | no | Seconds before canceling. Defaults: 600 for command, 30 for prompt, 60 for agent |
| `statusMessage` | no | Custom spinner message displayed while the hook runs |
| `once` | no | If `true`, runs once per session then is removed. Only honored for hooks declared in [skill frontmatter](https://code.claude.com/docs/en/hooks#hooks-in-skills-and-agents); ignored in settings files and agent frontmatter |

The `if` field holds exactly one permission rule. There is no `&&`, `||`, or list syntax for combining rules; to apply multiple conditions, define a separate hook handler for each. For Bash, the rule is matched against each subcommand of the tool input after leading `VAR=value` assignments are stripped, so `if: "Bash(git push *)"` matches both `FOO=bar git push` and `npm test && git push`. The hook runs if any subcommand matches, and always runs when the command is too complex to parse.

#### [​](https://code.claude.com/docs/en/hooks\#command-hook-fields)  Command hook fields

In addition to the [common fields](https://code.claude.com/docs/en/hooks#common-fields), command hooks accept these fields:

| Field | Required | Description |
| --- | --- | --- |
| `command` | yes | Shell command to execute |
| `async` | no | If `true`, runs in the background without blocking. See [Run hooks in the background](https://code.claude.com/docs/en/hooks#run-hooks-in-the-background) |
| `asyncRewake` | no | If `true`, runs in the background and wakes Claude on exit code 2. Implies `async`. The hook’s stderr, or stdout if stderr is empty, is shown to Claude as a system reminder so it can react to a long-running background failure |
| `shell` | no | Shell to use for this hook. Accepts `"bash"` (default) or `"powershell"`. Setting `"powershell"` runs the command via PowerShell on Windows. Does not require `CLAUDE_CODE_USE_POWERSHELL_TOOL` since hooks spawn PowerShell directly |

#### [​](https://code.claude.com/docs/en/hooks\#http-hook-fields)  HTTP hook fields

In addition to the [common fields](https://code.claude.com/docs/en/hooks#common-fields), HTTP hooks accept these fields:

| Field | Required | Description |
| --- | --- | --- |
| `url` | yes | URL to send the POST request to |
| `headers` | no | Additional HTTP headers as key-value pairs. Values support environment variable interpolation using `$VAR_NAME` or `${VAR_NAME}` syntax. Only variables listed in `allowedEnvVars` are resolved |
| `allowedEnvVars` | no | List of environment variable names that may be interpolated into header values. References to unlisted variables are replaced with empty strings. Required for any env var interpolation to work |

Claude Code sends the hook’s [JSON input](https://code.claude.com/docs/en/hooks#hook-input-and-output) as the POST request body with `Content-Type: application/json`. The response body uses the same [JSON output format](https://code.claude.com/docs/en/hooks#json-output) as command hooks.Error handling differs from command hooks: non-2xx responses, connection failures, and timeouts all produce non-blocking errors that allow execution to continue. To block a tool call or deny a permission, return a 2xx response with a JSON body containing `decision: "block"` or a `hookSpecificOutput` with `permissionDecision: "deny"`.This example sends `PreToolUse` events to a local validation service, authenticating with a token from the `MY_TOKEN` environment variable:

```
{
  "hooks": {
    "PreToolUse": [\
      {\
        "matcher": "Bash",\
        "hooks": [\
          {\
            "type": "http",\
            "url": "http://localhost:8080/hooks/pre-tool-use",\
            "timeout": 30,\
            "headers": {\
              "Authorization": "Bearer $MY_TOKEN"\
            },\
            "allowedEnvVars": ["MY_TOKEN"]\
          }\
        ]\
      }\
    ]
  }
}
```

#### [​](https://code.claude.com/docs/en/hooks\#mcp-tool-hook-fields)  MCP tool hook fields

In addition to the [common fields](https://code.claude.com/docs/en/hooks#common-fields), MCP tool hooks accept these fields:

| Field | Required | Description |
| --- | --- | --- |
| `server` | yes | Name of a configured MCP server. The server must already be connected; the hook never triggers an OAuth or connection flow |
| `tool` | yes | Name of the tool to call on that server |
| `input` | no | Arguments passed to the tool. String values support `${path}` substitution from the hook’s [JSON input](https://code.claude.com/docs/en/hooks#hook-input-and-output), such as `"${tool_input.file_path}"` |

The tool’s text content is treated like command-hook stdout: if it parses as valid [JSON output](https://code.claude.com/docs/en/hooks#json-output) it is processed as a decision, otherwise it is shown as plain text. If the named server is not connected, or the tool returns `isError: true`, the hook produces a non-blocking error and execution continues.MCP tool hooks are available on every hook event once Claude Code has connected to your MCP servers. `SessionStart` and `Setup` typically fire before servers finish connecting, so hooks on those events should expect the “not connected” error on first run.This example calls the `security_scan` tool on the `my_server` MCP server after each `Write` or `Edit`, passing the edited file’s path:

```
{
  "hooks": {
    "PostToolUse": [\
      {\
        "matcher": "Write|Edit",\
        "hooks": [\
          {\
            "type": "mcp_tool",\
            "server": "my_server",\
            "tool": "security_scan",\
            "input": { "file_path": "${tool_input.file_path}" }\
          }\
        ]\
      }\
    ]
  }
}
```

#### [​](https://code.claude.com/docs/en/hooks\#prompt-and-agent-hook-fields)  Prompt and agent hook fields

In addition to the [common fields](https://code.claude.com/docs/en/hooks#common-fields), prompt and agent hooks accept these fields:

| Field | Required | Description |
| --- | --- | --- |
| `prompt` | yes | Prompt text to send to the model. Use `$ARGUMENTS` as a placeholder for the hook input JSON |
| `model` | no | Model to use for evaluation. Defaults to a fast model |

All matching hooks run in parallel, and identical handlers are deduplicated automatically. Command hooks are deduplicated by command string, and HTTP hooks are deduplicated by URL. Handlers run in the current directory with Claude Code’s environment. The `$CLAUDE_CODE_REMOTE` environment variable is set to `"true"` in remote web environments and not set in the local CLI.

### [​](https://code.claude.com/docs/en/hooks\#reference-scripts-by-path)  Reference scripts by path

Use environment variables to reference hook scripts relative to the project or plugin root, regardless of the working directory when the hook runs:

- `$CLAUDE_PROJECT_DIR`: the project root. Wrap in quotes to handle paths with spaces.
- `${CLAUDE_PLUGIN_ROOT}`: the plugin’s installation directory, for scripts bundled with a [plugin](https://code.claude.com/docs/en/plugins). Changes on each plugin update.
- `${CLAUDE_PLUGIN_DATA}`: the plugin’s [persistent data directory](https://code.claude.com/docs/en/plugins-reference#persistent-data-directory), for dependencies and state that should survive plugin updates.

- Project scripts

- Plugin scripts


This example uses `$CLAUDE_PROJECT_DIR` to run a style checker from the project’s `.claude/hooks/` directory after any `Write` or `Edit` tool call:

```
{
  "hooks": {
    "PostToolUse": [\
      {\
        "matcher": "Write|Edit",\
        "hooks": [\
          {\
            "type": "command",\
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/check-style.sh"\
          }\
        ]\
      }\
    ]
  }
}
```

Define plugin hooks in `hooks/hooks.json` with an optional top-level `description` field. When a plugin is enabled, its hooks merge with your user and project hooks.This example runs a formatting script bundled with the plugin:

```
{
  "description": "Automatic code formatting",
  "hooks": {
    "PostToolUse": [\
      {\
        "matcher": "Write|Edit",\
        "hooks": [\
          {\
            "type": "command",\
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/format.sh",\
            "timeout": 30\
          }\
        ]\
      }\
    ]
  }
}
```

See the [plugin components reference](https://code.claude.com/docs/en/plugins-reference#hooks) for details on creating plugin hooks.

### [​](https://code.claude.com/docs/en/hooks\#hooks-in-skills-and-agents)  Hooks in skills and agents

In addition to settings files and plugins, hooks can be defined directly in [skills](https://code.claude.com/docs/en/skills) and [subagents](https://code.claude.com/docs/en/sub-agents) using frontmatter. These hooks are scoped to the component’s lifecycle and only run when that component is active.All hook events are supported. For subagents, `Stop` hooks are automatically converted to `SubagentStop` since that is the event that fires when a subagent completes.Hooks use the same configuration format as settings-based hooks but are scoped to the component’s lifetime and cleaned up when it finishes.This skill defines a `PreToolUse` hook that runs a security validation script before each `Bash` command:

```
---
name: secure-operations
description: Perform operations with security checks
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/security-check.sh"
---
```

Agents use the same format in their YAML frontmatter.

### [​](https://code.claude.com/docs/en/hooks\#the-/hooks-menu)  The `/hooks` menu

Type `/hooks` in Claude Code to open a read-only browser for your configured hooks. The menu shows every hook event with a count of configured hooks, lets you drill into matchers, and shows the full details of each hook handler. Use it to verify configuration, check which settings file a hook came from, or inspect a hook’s command, prompt, or URL.The menu displays all five hook types: `command`, `prompt`, `agent`, `http`, and `mcp_tool`. Each hook is labeled with a `[type]` prefix and a source indicating where it was defined:

- `User`: from `~/.claude/settings.json`
- `Project`: from `.claude/settings.json`
- `Local`: from `.claude/settings.local.json`
- `Plugin`: from a plugin’s `hooks/hooks.json`
- `Session`: registered in memory for the current session
- `Built-in`: registered internally by Claude Code

Selecting a hook opens a detail view showing its event, matcher, type, source file, and the full command, prompt, or URL. The menu is read-only: to add, modify, or remove hooks, edit the settings JSON directly or ask Claude to make the change.

### [​](https://code.claude.com/docs/en/hooks\#disable-or-remove-hooks)  Disable or remove hooks

To remove a hook, delete its entry from the settings JSON file.To temporarily disable all hooks without removing them, set `"disableAllHooks": true` in your settings file. There is no way to disable an individual hook while keeping it in the configuration.The `disableAllHooks` setting respects the managed settings hierarchy. If an administrator has configured hooks through managed policy settings, `disableAllHooks` set in user, project, or local settings cannot disable those managed hooks. Only `disableAllHooks` set at the managed settings level can disable managed hooks.Direct edits to hooks in settings files are normally picked up automatically by the file watcher.

## [​](https://code.claude.com/docs/en/hooks\#hook-input-and-output)  Hook input and output

Command hooks receive JSON data via stdin and communicate results through exit codes, stdout, and stderr. HTTP hooks receive the same JSON as the POST request body and communicate results through the HTTP response body. This section covers fields and behavior common to all events. Each event’s section under [Hook events](https://code.claude.com/docs/en/hooks#hook-events) includes its specific input schema and decision control options.

### [​](https://code.claude.com/docs/en/hooks\#common-input-fields)  Common input fields

Hook events receive these fields as JSON, in addition to event-specific fields documented in each [hook event](https://code.claude.com/docs/en/hooks#hook-events) section. For command hooks, this JSON arrives via stdin. For HTTP hooks, it arrives as the POST request body.

| Field | Description |
| --- | --- |
| `session_id` | Current session identifier |
| `transcript_path` | Path to conversation JSON |
| `cwd` | Current working directory when the hook is invoked |
| `permission_mode` | Current [permission mode](https://code.claude.com/docs/en/permissions#permission-modes): `"default"`, `"plan"`, `"acceptEdits"`, `"auto"`, `"dontAsk"`, or `"bypassPermissions"`. Not all events receive this field: see each event’s JSON example below to check |
| `hook_event_name` | Name of the event that fired |

When running with `--agent` or inside a subagent, two additional fields are included:

| Field | Description |
| --- | --- |
| `agent_id` | Unique identifier for the subagent. Present only when the hook fires inside a subagent call. Use this to distinguish subagent hook calls from main-thread calls. |
| `agent_type` | Agent name (for example, `"Explore"` or `"security-reviewer"`). Present when the session uses `--agent` or the hook fires inside a subagent. For subagents, the subagent’s type takes precedence over the session’s `--agent` value. |

For example, a `PreToolUse` hook for a Bash command receives this on stdin:

```
{
  "session_id": "abc123",
  "transcript_path": "/home/user/.claude/projects/.../transcript.jsonl",
  "cwd": "/home/user/my-project",
  "permission_mode": "default",
  "hook_event_name": "PreToolUse",
  "tool_name": "Bash",
  "tool_input": {
    "command": "npm test"
  }
}
```

The `tool_name` and `tool_input` fields are event-specific. Each [hook event](https://code.claude.com/docs/en/hooks#hook-events) section documents the additional fields for that event.

### [​](https://code.claude.com/docs/en/hooks\#exit-code-output)  Exit code output

The exit code from your hook command tells Claude Code whether the action should proceed, be blocked, or be ignored.**Exit 0** means success. Claude Code parses stdout for [JSON output fields](https://code.claude.com/docs/en/hooks#json-output). JSON output is only processed on exit 0. For most events, stdout is written to the debug log but not shown in the transcript. The exceptions are `UserPromptSubmit`, `UserPromptExpansion`, and `SessionStart`, where stdout is added as context that Claude can see and act on.**Exit 2** means a blocking error. Claude Code ignores stdout and any JSON in it. Instead, stderr text is fed back to Claude as an error message. The effect depends on the event: `PreToolUse` blocks the tool call, `UserPromptSubmit` rejects the prompt, and so on. See [exit code 2 behavior](https://code.claude.com/docs/en/hooks#exit-code-2-behavior-per-event) for the full list.**Any other exit code** is a non-blocking error for most hook events. The transcript shows a `<hook name> hook error` notice followed by the first line of stderr, so you can identify the cause without `--debug`. Execution continues and the full stderr is written to the debug log.For example, a hook command script that blocks dangerous Bash commands:

```
#!/bin/bash
# Reads JSON input from stdin, checks the command
command=$(jq -r '.tool_input.command' < /dev/stdin)

if [[ "$command" == rm* ]]; then
  echo "Blocked: rm commands are not allowed" >&2
  exit 2  # Blocking error: tool call is prevented
fi

exit 0  # Success: tool call proceeds
```

For most hook events, only exit code 2 blocks the action. Claude Code treats exit code 1 as a non-blocking error and proceeds with the action, even though 1 is the conventional Unix failure code. If your hook is meant to enforce a policy, use `exit 2`. The exception is `WorktreeCreate`, where any non-zero exit code aborts worktree creation.

#### [​](https://code.claude.com/docs/en/hooks\#exit-code-2-behavior-per-event)  Exit code 2 behavior per event

Exit code 2 is the way a hook signals “stop, don’t do this.” The effect depends on the event, because some events represent actions that can be blocked (like a tool call that hasn’t happened yet) and others represent things that already happened or can’t be prevented.

| Hook event | Can block? | What happens on exit 2 |
| --- | --- | --- |
| `PreToolUse` | Yes | Blocks the tool call |
| `PermissionRequest` | Yes | Denies the permission |
| `UserPromptSubmit` | Yes | Blocks prompt processing and erases the prompt |
| `UserPromptExpansion` | Yes | Blocks the expansion |
| `Stop` | Yes | Prevents Claude from stopping, continues the conversation |
| `SubagentStop` | Yes | Prevents the subagent from stopping |
| `TeammateIdle` | Yes | Prevents the teammate from going idle (teammate continues working) |
| `TaskCreated` | Yes | Rolls back the task creation |
| `TaskCompleted` | Yes | Prevents the task from being marked as completed |
| `ConfigChange` | Yes | Blocks the configuration change from taking effect (except `policy_settings`) |
| `StopFailure` | No | Output and exit code are ignored |
| `PostToolUse` | No | Shows stderr to Claude (tool already ran) |
| `PostToolUseFailure` | No | Shows stderr to Claude (tool already failed) |
| `PostToolBatch` | Yes | Stops the agentic loop before the next model call |
| `PermissionDenied` | No | Exit code and stderr are ignored (denial already occurred). Use JSON `hookSpecificOutput.retry: true` to tell the model it may retry |
| `Notification` | No | Shows stderr to user only |
| `SubagentStart` | No | Shows stderr to user only |
| `SessionStart` | No | Shows stderr to user only |
| `SessionEnd` | No | Shows stderr to user only |
| `CwdChanged` | No | Shows stderr to user only |
| `FileChanged` | No | Shows stderr to user only |
| `PreCompact` | Yes | Blocks compaction |
| `PostCompact` | No | Shows stderr to user only |
| `Elicitation` | Yes | Denies the elicitation |
| `ElicitationResult` | Yes | Blocks the response (action becomes decline) |
| `WorktreeCreate` | Yes | Any non-zero exit code causes worktree creation to fail |
| `WorktreeRemove` | No | Failures are logged in debug mode only |
| `InstructionsLoaded` | No | Exit code is ignored |

### [​](https://code.claude.com/docs/en/hooks\#http-response-handling)  HTTP response handling

HTTP hooks use HTTP status codes and response bodies instead of exit codes and stdout:

- **2xx with an empty body**: success, equivalent to exit code 0 with no output
- **2xx with a plain text body**: success, the text is added as context
- **2xx with a JSON body**: success, parsed using the same [JSON output](https://code.claude.com/docs/en/hooks#json-output) schema as command hooks
- **Non-2xx status**: non-blocking error, execution continues
- **Connection failure or timeout**: non-blocking error, execution continues

Unlike command hooks, HTTP hooks cannot signal a blocking error through status codes alone. To block a tool call or deny a permission, return a 2xx response with a JSON body containing the appropriate decision fields.

### [​](https://code.claude.com/docs/en/hooks\#json-output)  JSON output

Exit codes let you allow or block, but JSON output gives you finer-grained control. Instead of exiting with code 2 to block, exit 0 and print a JSON object to stdout. Claude Code reads specific fields from that JSON to control behavior, including [decision control](https://code.claude.com/docs/en/hooks#decision-control) for blocking, allowing, or escalating to the user.

You must choose one approach per hook, not both: either use exit codes alone for signaling, or exit 0 and print JSON for structured control. Claude Code only processes JSON on exit 0. If you exit 2, any JSON is ignored.

Your hook’s stdout must contain only the JSON object. If your shell profile prints text on startup, it can interfere with JSON parsing. See [JSON validation failed](https://code.claude.com/docs/en/hooks-guide#json-validation-failed) in the troubleshooting guide.Hook output injected into context (`additionalContext`, `systemMessage`, or plain stdout) is capped at 10,000 characters. Output that exceeds this limit is saved to a file and replaced with a preview and file path, the same way large tool results are handled.The JSON object supports three kinds of fields:

- **Universal fields** like `continue` work across all events. These are listed in the table below.
- **Top-level `decision` and `reason`** are used by some events to block or provide feedback.
- **`hookSpecificOutput`** is a nested object for events that need richer control. It requires a `hookEventName` field set to the event name.

| Field | Default | Description |
| --- | --- | --- |
| `continue` | `true` | If `false`, Claude stops processing entirely after the hook runs. Takes precedence over any event-specific decision fields |
| `stopReason` | none | Message shown to the user when `continue` is `false`. Not shown to Claude |
| `suppressOutput` | `false` | If `true`, omits stdout from the debug log |
| `systemMessage` | none | Warning message shown to the user |

To stop Claude entirely regardless of event type:

```
{ "continue": false, "stopReason": "Build failed, fix errors before continuing" }
```

#### [​](https://code.claude.com/docs/en/hooks\#decision-control)  Decision control

Not every event supports blocking or controlling behavior through JSON. The events that do each use a different set of fields to express that decision. Use this table as a quick reference before writing a hook:

| Events | Decision pattern | Key fields |
| --- | --- | --- |
| UserPromptSubmit, UserPromptExpansion, PostToolUse, PostToolUseFailure, PostToolBatch, Stop, SubagentStop, ConfigChange, PreCompact | Top-level `decision` | `decision: "block"`, `reason` |
| TeammateIdle, TaskCreated, TaskCompleted | Exit code or `continue: false` | Exit code 2 blocks the action with stderr feedback. JSON `{"continue": false, "stopReason": "..."}` also stops the teammate entirely, matching `Stop` hook behavior |
| PreToolUse | `hookSpecificOutput` | `permissionDecision` (allow/deny/ask/defer), `permissionDecisionReason` |
| PermissionRequest | `hookSpecificOutput` | `decision.behavior` (allow/deny) |
| PermissionDenied | `hookSpecificOutput` | `retry: true` tells the model it may retry the denied tool call |
| WorktreeCreate | path return | Command hook prints path on stdout; HTTP hook returns `hookSpecificOutput.worktreePath`. Hook failure or missing path fails creation |
| Elicitation | `hookSpecificOutput` | `action` (accept/decline/cancel), `content` (form field values for accept) |
| ElicitationResult | `hookSpecificOutput` | `action` (accept/decline/cancel), `content` (form field values override) |
| WorktreeRemove, Notification, SessionEnd, PostCompact, InstructionsLoaded, StopFailure, CwdChanged, FileChanged | None | No decision control. Used for side effects like logging or cleanup |

Here are examples of each pattern in action:

- Top-level decision

- PreToolUse

- PermissionRequest


Used by `UserPromptSubmit`, `UserPromptExpansion`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `Stop`, `SubagentStop`, `ConfigChange`, and `PreCompact`. The only value is `"block"`. To allow the action to proceed, omit `decision` from your JSON, or exit 0 without any JSON at all:

```
{
  "decision": "block",
  "reason": "Test suite must pass before proceeding"
}
```

Uses `hookSpecificOutput` for richer control: allow, deny, or escalate to the user. You can also modify tool input before it runs or inject additional context for Claude. See [PreToolUse decision control](https://code.claude.com/docs/en/hooks#pretooluse-decision-control) for the full set of options.

```
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Database writes are not allowed"
  }
}
```

Uses `hookSpecificOutput` to allow or deny a permission request on behalf of the user. When allowing, you can also modify the tool’s input or apply permission rules so the user isn’t prompted again. See [PermissionRequest decision control](https://code.claude.com/docs/en/hooks#permissionrequest-decision-control) for the full set of options.

```
{
  "hookSpecificOutput": {
    "hookEventName": "PermissionRequest",
    "decision": {
      "behavior": "allow",
      "updatedInput": {
        "command": "npm run lint"
      }
    }
  }
}
```

For extended examples including Bash command validation, prompt filtering, and auto-approval scripts, see [What you can automate](https://code.claude.com/docs/en/hooks-guide#what-you-can-automate) in the guide and the [Bash command validator reference implementation](https://github.com/anthropics/claude-code/blob/main/examples/hooks/bash_command_validator_example.py).

## [​](https://code.claude.com/docs/en/hooks\#hook-events)  Hook events

Each event corresponds to a point in Claude Code’s lifecycle where hooks can run. The sections below are ordered to match the lifecycle: from session setup through the agentic loop to session end. Each section describes when the event fires, what matchers it supports, the JSON input it receives, and how to control behavior through output.

### [​](https://code.claude.com/docs/en/hooks\#sessionstart)  SessionStart

Runs when Claude Code starts a new session or resumes an existing session. Useful for loading development context like existing issues or recent changes to your codebase, or setting up environment variables. For static context that does not require a script, use [CLAUDE.md](https://code.claude.com/docs/en/memory) instead.SessionStart runs on every session, so keep these hooks fast. Only `type: "command"` and `type: "mcp_tool"` hooks are supported.The matcher value corresponds to how the session was initiated:

| Matcher | When it fires |
| --- | --- |
| `startup` | New session |
| `resume` | `--resume`, `--continue`, or `/resume` |
| `clear` | `/clear` |
| `compact` | Auto or manual compaction |

#### [​](https://code.claude.com/docs/en/hooks\#sessionstart-input)  SessionStart input

In addition to the [common input fields](https://code.claude.com/docs/en/hooks#common-input-fields), SessionStart hooks receive `source`, `model`, and optionally `agent_type`. The `source` field indicates how the session started: `"startup"` for new sessions, `"resume"` for resumed sessions, `"clear"` after `/clear`, or `"compact"` after compaction. The `model` field contains the model identifier. If you start Claude Code with `claude --agent <name>`, an `agent_type` field contains the agent name.

```
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "hook_event_name": "SessionStart",
  "source": "startup",
  "model": "claude-sonnet-4-6"
}
```

#### [​](https://code.claude.com/docs/en/hooks\#sessionstart-decision-control)  SessionStart decision control

Any text your hook script prints to stdout is added as context for Claude. In addition to the [JSON output fields](https://code.claude.com/docs/en/hooks#json-output) available to all hooks, you can return these event-specific fields:

| Field | Description |
| --- | --- |
| `additionalContext` | String added to Claude’s context. Multiple hooks’ values are concatenated |

```
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "My additional context here"
  }
}
```

#### [​](https://code.claude.com/docs/en/hooks\#persist-environment-variables)  Persist environment variables

SessionStart hooks have access to the `CLAUDE_ENV_FILE` environment variable, which provides a file path where you can persist environment variables for subsequent Bash commands.To set individual environment variables, write `export` statements to `CLAUDE_ENV_FILE`. Use append (`>>`) to preserve variables set by other hooks:

```
#!/bin/bash

if [ -n "$CLAUDE_ENV_FILE" ]; then
  echo 'export NODE_ENV=production' >> "$CLAUDE_ENV_FILE"
  echo 'export DEBUG_LOG=true' >> "$CLAUDE_ENV_FILE"
  echo 'export PATH="$PATH:./node_modules/.bin"' >> "$CLAUDE_ENV_FILE"
fi

exit 0
```

To capture all environment changes from setup commands, compare the exported variables before and after:

```
#!/bin/bash

ENV_BEFORE=$(export -p | sort)

# Run your setup commands that modify the environment
source ~/.nvm/nvm.sh
nvm use 20

if [ -n "$CLAUDE_ENV_FILE" ]; then
  ENV_AFTER=$(export -p | sort)
  comm -13 <(echo "$ENV_BEFORE") <(echo "$ENV_AFTER") >> "$CLAUDE_ENV_FILE"
fi

exit 0
```

Any variables written to this file will be available in all subsequent Bash commands that Claude Code executes during the session.

`CLAUDE_ENV_FILE` is available for SessionStart, [CwdChanged](https://code.claude.com/docs/en/hooks#cwdchanged), and [FileChanged](https://code.claude.com/docs/en/hooks#filechanged) hooks. Other hook types do not have access to this variable.

### [​](https://code.claude.com/docs/en/hooks\#instructionsloaded)  InstructionsLoaded

Fires when a `CLAUDE.md` or `.claude/rules/*.md` file is loaded into context. This event fires at session start for eagerly-loaded files and again later when files are lazily loaded, for example when Claude accesses a subdirectory that contains a nested `CLAUDE.md` or when conditional rules with `paths:` frontmatter match. The hook does not support blocking or decision control. It runs asynchronously for observability purposes.The matcher runs against `load_reason`. For example, use `"matcher": "session_start"` to fire only for files loaded at session start, or `"matcher": "path_glob_match|nested_traversal"` to fire only for lazy loads.

#### [​](https://code.claude.com/docs/en/hooks\#instructionsloaded-input)  InstructionsLoaded input

In addition to the [common input fields](https://code.claude.com/docs/en/hooks#common-input-fields), InstructionsLoaded hooks receive these fields:

| Field | Description |
| --- | --- |
| `file_path` | Absolute path to the instruction file that was loaded |
| `memory_type` | Scope of the file: `"User"`, `"Project"`, `"Local"`, or `"Managed"` |
| `load_reason` | Why the file was loaded: `"session_start"`, `"nested_traversal"`, `"path_glob_match"`, `"include"`, or `"compact"`. The `"compact"` value fires when instruction files are re-loaded after a compaction event |
| `globs` | Path glob patterns from the file’s `paths:` frontmatter, if any. Present only for `path_glob_match` loads |
| `trigger_file_path` | Path to the file whose access triggered this load, for lazy loads |
| `parent_file_path` | Path to the parent instruction file that included this one, for `include` loads |

```
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../transcript.jsonl",
  "cwd": "/Users/my-project",
  "hook_event_name": "InstructionsLoaded",
  "file_path": "/Users/my-project/CLAUDE.md",
  "memory_type": "Project",
  "load_reason": "session_start"
}
```

#### [​](https://code.claude.com/docs/en/hooks\#instructionsloaded-decision-control)  InstructionsLoaded decision control

InstructionsLoaded hooks have no decision control. They cannot block or modify instruction loading. Use this event for audit logging, compliance tracking, or observability.

### [​](https://code.claude.com/docs/en/hooks\#userpromptsubmit)  UserPromptSubmit

Runs when the user submits a prompt, before Claude processes it. This allows you
to add additional context based on the prompt/conversation, validate prompts, or
block certain types of prompts.

#### [​](https://code.claude.com/docs/en/hooks\#userpromptsubmit-input)  UserPromptSubmit input

In addition to the [common input fields](https://code.claude.com/docs/en/hooks#common-input-fields), UserPromptSubmit hooks receive the `prompt` field containing the text the user submitted.

```
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "UserPromptSubmit",
  "prompt": "Write a function to calculate the factorial of a number"
}
```

#### [​](https://code.claude.com/docs/en/hooks\#userpromptsubmit-decision-control)  UserPromptSubmit decision control

`UserPromptSubmit` hooks can control whether a user prompt is processed and add context. All [JSON output fields](https://code.claude.com/docs/en/hooks#json-output) are available.There are two ways to add context to the conversation on exit code 0:

- **Plain text stdout**: any non-JSON text written to stdout is added as context
- **JSON with `additionalContext`**: use the JSON format below for more control. The `additionalContext` field is added as context

Plain stdout is shown as hook output in the transcript. The `additionalContext` field is added more discretely.To block a prompt, return a JSON object with `decision` set to `"block"`:

| Field | Description |
| --- | --- |
| `decision` | `"block"` prevents the prompt from being processed and erases it from context. Omit to allow the prompt to proceed |
| `reason` | Shown to the user when `decision` is `"block"`. Not added to context |
| `additionalContext` | String added to Claude’s context |
| `sessionTitle` | Sets the session title, same effect as `/rename`. Use to name sessions automatically based on the prompt content |

```
{
  "decision": "block",
  "reason": "Explanation for decision",
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "My additional context here",
    "sessionTitle": "My session title"
  }
}
```

The JSON format isn’t required for simple use cases. To add context, you can print plain text to stdout with exit code 0. Use JSON when you need to
block prompts or want more structured control.

### [​](https://code.claude.com/docs/en/hooks\#userpromptexpansion)  UserPromptExpansion

Runs when a user-typed slash command expands into a prompt before reaching Claude. Use this to block specific commands from direct invocation, inject context for a particular skill, or log which commands users invoke. For example, a hook matching `deploy` can block `/deploy` unless an approval file is present, or a hook matching a review skill can append the team’s review checklist as `additionalContext`.This event covers the path `PreToolUse` does not: a `PreToolUse` hook matching the `Skill` tool fires only when Claude calls the tool, but typing `/skillname` directly bypasses `PreToolUse`. `UserPromptExpansion` fires on that direct path.Matches on `command_name`. Leave the matcher empty to fire on every prompt-type slash command.

#### [​](https://code.claude.com/docs/en/hooks\#userpromptexpansion-input)  UserPromptExpansion input

In addition to the [common input fields](https://code.claude.com/docs/en/hooks#common-input-fields), UserPromptExpansion hooks receive `expansion_type`, `command_name`, `command_args`, `command_source`, and the original `prompt` string. The `expansion_type` field is `slash_command` for skill and custom commands, or `mcp_prompt` for MCP server prompts.

```
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../00893aaf.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "UserPromptExpansion",
  "expansion_type": "slash_command",
  "command_name": "example-skill",
  "command_args": "arg1 arg2",
  "command_source": "plugin",
  "prompt": "/example-skill arg1 arg2"
}
```

#### [​](https://code.claude.com/docs/en/hooks\#userpromptexpansion-decision-control)  UserPromptExpansion decision control

`UserPromptExpansion` hooks can block the expansion or add context. All [JSON output fields](https://code.claude.com/docs/en/hooks#json-output) are available.

| Field | Description |
| --- | --- |
| `decision` | `"block"` prevents the slash command from expanding. Omit to allow it to proceed |
| `reason` | Shown to the user when `decision` is `"block"` |
| `additionalContext` | String added to Claude’s context alongside the expanded prompt |

```
{
  "decision": "block",
  "reason": "This slash command is not available",
  "hookSpecificOutput": {
    "hookEventName": "UserPromptExpansion",
    "additionalContext": "Additional context for this expansion"
  }
}
```

### [​](https://code.claude.com/docs/en/hooks\#pretooluse)  PreToolUse

Runs after Claude creates tool parameters and before processing the tool call. Matches on tool name: `Bash`, `Edit`, `Write`, `Read`, `Glob`, `Grep`, `Agent`, `WebFetch`, `WebSearch`, `AskUserQuestion`, `ExitPlanMode`, and any [MCP tool names](https://code.claude.com/docs/en/hooks#match-mcp-tools).Use [PreToolUse decision control](https://code.claude.com/docs/en/hooks#pretooluse-decision-control) to allow, deny, ask, or defer the tool call.

#### [​](https://code.claude.com/docs/en/hooks\#pretooluse-input)  PreToolUse input

In addition to the [common input fields](https://code.claude.com/docs/en/hooks#common-input-fields), PreToolUse hooks receive `tool_name`, `tool_input`, and `tool_use_id`. The `tool_input` fields depend on the tool:

##### Bash

Executes shell commands.

| Field | Type | Example | Description |
| --- | --- | --- | --- |
| `command` | string | `"npm test"` | The shell command to execute |
| `description` | string | `"Run test suite"` | Optional description of what the command does |
| `timeout` | number | `120000` | Optional timeout in milliseconds |
| `run_in_background` | boolean | `false` | Whether to run the command in background |

##### Write

Creates or overwrites a file.

| Field | Type | Example | Description |
| --- | --- | --- | --- |
| `file_path` | string | `"/path/to/file.txt"` | Absolute path to the file to write |
| `content` | string | `"file content"` | Content to write to the file |

##### Edit

Replaces a string in an existing file.

| Field | Type | Example | Description |
| --- | --- | --- | --- |
| `file_path` | string | `"/path/to/file.txt"` | Absolute path to the file to edit |
| `old_string` | string | `"original text"` | Text to find and replace |
| `new_string` | string | `"replacement text"` | Replacement text |
| `replace_all` | boolean | `false` | Whether to replace all occurrences |

##### Read

Reads file contents.

| Field | Type | Example | Description |
| --- | --- | --- | --- |
| `file_path` | string | `"/path/to/file.txt"` | Absolute path to the file to read |
| `offset` | number | `10` | Optional line number to start reading from |
| `limit` | number | `50` | Optional number of lines to read |

##### Glob

Finds files matching a glob pattern.

| Field | Type | Example | Description |
| --- | --- | --- | --- |
| `pattern` | string | `"**/*.ts"` | Glob pattern to match files against |
| `path` | string | `"/path/to/dir"` | Optional directory to search in. Defaults to current working directory |

##### Grep

Searches file contents with regular expressions.

| Field | Type | Example | Description |
| --- | --- | --- | --- |
| `pattern` | string | `"TODO.*fix"` | Regular expression pattern to search for |
| `path` | string | `"/path/to/dir"` | Optional file or directory to search in |
| `glob` | string | `"*.ts"` | Optional glob pattern to filter files |
| `output_mode` | string | `"content"` | `"content"`, `"files_with_matches"`, or `"count"`. Defaults to `"files_with_matches"` |
| `-i` | boolean | `true` | Case insensitive search |
| `multiline` | boolean | `false` | Enable multiline matching |

##### WebFetch

Fetches and processes web content.

| Field | Type | Example | Description |
| --- | --- | --- | --- |
| `url` | string | `"https://example.com/api"` | URL to fetch content from |
| `prompt` | string | `"Extract the API endpoints"` | Prompt to run on the fetched content |

##### WebSearch

Searches the web.

| Field | Type | Example | Description |
| --- | --- | --- | --- |
| `query` | string | `"react hooks best practices"` | Search query |
| `allowed_domains` | array | `["docs.example.com"]` | Optional: only include results from these domains |
| `blocked_domains` | array | `["spam.example.com"]` | Optional: exclude results from these domains |

##### Agent

Spawns a [subagent](https://code.claude.com/docs/en/sub-agents).

| Field | Type | Example | Description |
| --- | --- | --- | --- |
| `prompt` | string | `"Find all API endpoints"` | The task for the agent to perform |
| `description` | string | `"Find API endpoints"` | Short description of the task |
| `subagent_type` | string | `"Explore"` | Type of specialized agent to use |
| `model` | string | `"sonnet"` | Optional model alias to override the default |

##### AskUserQuestion

Asks the user one to four multiple-choice questions.

| Field | Type | Example | Description |
| --- | --- | --- | --- |
| `questions` | array | `[{"question": "Which framework?", "header": "Framework", "options": [{"label": "React"}], "multiSelect": false}]` | Questions to present, each with a `question` string, short `header`, `options` array, and optional `multiSelect` flag |
| `answers` | object | `{"Which framework?": "React"}` | Optional. Maps question text to the selected option label. Multi-select answers join labels with commas. Claude does not set this field; supply it via `updatedInput` to answer programmatically |

#### [​](https://code.claude.com/docs/en/hooks\#pretooluse-decision-control)  PreToolUse decision control

`PreToolUse` hooks can control whether a tool call proceeds. Unlike other hooks that use a top-level `decision` field, PreToolUse returns its decision inside a `hookSpecificOutput` object. This gives it richer control: four outcomes (allow, deny, ask, or defer) plus the ability to modify tool input before execution.

| Field | Description |
| --- | --- |
| `permissionDecision` | `"allow"` skips the permission prompt. `"deny"` prevents the tool call. `"ask"` prompts the user to confirm. `"defer"` exits gracefully so the tool can be resumed later. [Deny and ask rules](https://code.claude.com/docs/en/permissions#manage-permissions) are still evaluated regardless of what the hook returns |
| `permissionDecisionReason` | For `"allow"` and `"ask"`, shown to the user but not Claude. For `"deny"`, shown to Claude. For `"defer"`, ignored |
| `updatedInput` | Modifies the tool’s input parameters before execution. Replaces the entire input object, so include unchanged fields alongside modified ones. Combine with `"allow"` to auto-approve, or `"ask"` to show the modified input to the user. For `"defer"`, ignored |
| `additionalContext` | String added to Claude’s context before the tool executes. For `"defer"`, ignored |

When multiple PreToolUse hooks return different decisions, precedence is `deny` \> `defer` \> `ask` \> `allow`.When a hook returns `"ask"`, the permission prompt displayed to the user includes a label identifying where the hook came from: for example, `[User]`, `[Project]`, `[Plugin]`, or `[Local]`. This helps users understand which configuration source is requesting confirmation.

```
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "permissionDecisionReason": "My reason here",
    "updatedInput": {
      "field_to_modify": "new value"
    },
    "additionalContext": "Current environment: production. Proceed with caution."
  }
}
```

`AskUserQuestion` and `ExitPlanMode` require user interaction and normally block in [non-interactive mode](https://code.claude.com/docs/en/headless) with the `-p` flag. Returning `permissionDecision: "allow"` together with `updatedInput` satisfies that requirement: the hook reads the tool’s input from stdin, collects the answer through your own UI, and returns it in `updatedInput` so the tool runs without prompting. Returning `"allow"` alone is not sufficient for these tools. For `AskUserQuestion`, echo back the original `questions` array and add an [`answers`](https://code.claude.com/docs/en/hooks#askuserquestion) object mapping each question’s text to the chosen answer.

PreToolUse previously used top-level `decision` and `reason` fields, but these are deprecated for this event. Use `hookSpecificOutput.permissionDecision` and `hookSpecificOutput.permissionDecisionReason` instead. The deprecated values `"approve"` and `"block"` map to `"allow"` and `"deny"` respectively. Other events like PostToolUse and Stop continue to use top-level `decision` and `reason` as their current format.

#### [​](https://code.claude.com/docs/en/hooks\#defer-a-tool-call-for-later)  Defer a tool call for later

`"defer"` is for integrations that run `claude -p` as a subprocess and read its JSON output, such as an Agent SDK app or a custom UI built on top of Claude Code. It lets that calling process pause Claude at a tool call, collect input through its own interface, and resume where it left off. Claude Code honors this value only in [non-interactive mode](https://code.claude.com/docs/en/headless) with the `-p` flag. In interactive sessions it logs a warning and ignores the hook result.

The `defer` value requires Claude Code v2.1.89 or later. Earlier versions do not recognize it and the tool proceeds through the normal permission flow.

The `AskUserQuestion` tool is the typical case: Claude wants to ask the user something, but there is no terminal to answer in. The round trip works like this:

1. Claude calls `AskUserQuestion`. The `PreToolUse` hook fires.
2. The hook returns `permissionDecision: "defer"`. The tool does not execute. The process exits with `stop_reason: "tool_deferred"` and the pending tool call preserved in the transcript.
3. The calling process reads `deferred_tool_use` from the SDK result, surfaces the question in its own UI, and waits for an answer.
4. The calling process runs `claude -p --resume <session-id>`. The same tool call fires `PreToolUse` again.
5. The hook returns `permissionDecision: "allow"` with the answer in `updatedInput`. The tool executes and Claude continues.

The `deferred_tool_use` field carries the tool’s `id`, `name`, and `input`. The `input` is the parameters Claude generated for the tool call, captured before execution:

```
{
  "type": "result",
  "subtype": "success",
  "stop_reason": "tool_deferred",
  "session_id": "abc123",
  "deferred_tool_use": {
    "id": "toolu_01abc",
    "name": "AskUserQuestion",
    "input": { "questions": [{ "question": "Which framework?", "header": "Framework", "options": [{"label": "React"}, {"label": "Vue"}], "multiSelect": false }] }
  }
}
```

There is no timeout or retry limit. The session remains on disk until you resume it, subject to the [`cleanupPeriodDays`](https://code.claude.com/docs/en/settings#available-settings) retention sweep that deletes session files after 30 days by default. If the answer is not ready when you resume, the hook can return `"defer"` again and the process exits the same way. The calling process controls when to break the loop by eventually returning `"allow"` or `"deny"` from the hook.`"defer"` only works when Claude makes a single tool call in the turn. If Claude makes several tool calls at once, `"defer"` is ignored with a warning and the tool proceeds through the normal permission flow. The constraint exists because resume can only re-run one tool: there is no way to defer one call from a batch without leaving the others unresolved.If the deferred tool is no longer available when you resume, the process exits with `stop_reason: "tool_deferred_unavailable"` and `is_error: true` before the hook fires. This happens when an MCP server that provided the tool is not connected for the resumed session. The `deferred_tool_use` payload is still included so you can identify which tool went missing.

`--resume` does not restore the permission mode from the prior session. Pass the same `--permission-mode` flag on resume that was active when the tool was deferred. Claude Code logs a warning if the modes differ.

### [​](https://code.claude.com/docs/en/hooks\#permissionrequest)  PermissionRequest

Runs when the user is shown a permission dialog.
Use [PermissionRequest decision control](https://code.claude.com/docs/en/hooks#permissionrequest-decision-control) to allow or deny on behalf of the user.Matches on tool name, same values as PreToolUse.

#### [​](https://code.claude.com/docs/en/hooks\#permissionrequest-input)  PermissionRequest input

PermissionRequest hooks receive `tool_name` and `tool_input` fields like PreToolUse hooks, but without `tool_use_id`. An optional `permission_suggestions` array contains the “always allow” options the user would normally see in the permission dialog. The difference is when the hook fires: PermissionRequest hooks run when a permission dialog is about to be shown to the user, while PreToolUse hooks run before tool execution regardless of permission status.

```
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "PermissionRequest",
  "tool_name": "Bash",
  "tool_input": {
    "command": "rm -rf node_modules",
    "description": "Remove node_modules directory"
  },
  "permission_suggestions": [\
    {\
      "type": "addRules",\
      "rules": [{ "toolName": "Bash", "ruleContent": "rm -rf node_modules" }],\
      "behavior": "allow",\
      "destination": "localSettings"\
    }\
  ]
}
```

#### [​](https://code.claude.com/docs/en/hooks\#permissionrequest-decision-control)  PermissionRequest decision control

`PermissionRequest` hooks can allow or deny permission requests. In addition to the [JSON output fields](https://code.claude.com/docs/en/hooks#json-output) available to all hooks, your hook script can return a `decision` object with these event-specific fields:

| Field | Description |
| --- | --- |
| `behavior` | `"allow"` grants the permission, `"deny"` denies it. [Deny and ask rules](https://code.claude.com/docs/en/permissions#manage-permissions) are still evaluated, so a hook returning `"allow"` does not override a matching deny rule |
| `updatedInput` | For `"allow"` only: modifies the tool’s input parameters before execution. Replaces the entire input object, so include unchanged fields alongside modified ones. The modified input is re-evaluated against deny and ask rules |
| `updatedPermissions` | For `"allow"` only: array of [permission update entries](https://code.claude.com/docs/en/hooks#permission-update-entries) to apply, such as adding an allow rule or changing the session permission mode |
| `message` | For `"deny"` only: tells Claude why the permission was denied |
| `interrupt` | For `"deny"` only: if `true`, stops Claude |

```
{
  "hookSpecificOutput": {
    "hookEventName": "PermissionRequest",
    "decision": {
      "behavior": "allow",
      "updatedInput": {
        "command": "npm run lint"
      }
    }
  }
}
```

#### [​](https://code.claude.com/docs/en/hooks\#permission-update-entries)  Permission update entries

The `updatedPermissions` output field and the [`permission_suggestions` input field](https://code.claude.com/docs/en/hooks#permissionrequest-input) both use the same array of entry objects. Each entry has a `type` that determines its other fields, and a `destination` that controls where the change is written.

| `type` | Fields | Effect |
| --- | --- | --- |
| `addRules` | `rules`, `behavior`, `destination` | Adds permission rules. `rules` is an array of `{toolName, ruleContent?}` objects. Omit `ruleContent` to match the whole tool. `behavior` is `"allow"`, `"deny"`, or `"ask"` |
| `replaceRules` | `rules`, `behavior`, `destination` | Replaces all rules of the given `behavior` at the `destination` with the provided `rules` |
| `removeRules` | `rules`, `behavior`, `destination` | Removes matching rules of the given `behavior` |
| `setMode` | `mode`, `destination` | Changes the permission mode. Valid modes are `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, and `plan` |
| `addDirectories` | `directories`, `destination` | Adds working directories. `directories` is an array of path strings |
| `removeDirectories` | `directories`, `destination` | Removes working directories |

`setMode` with `bypassPermissions` only takes effect if the session was launched with bypass mode already available: `--dangerously-skip-permissions`, `--permission-mode bypassPermissions`, `--allow-dangerously-skip-permissions`, or `permissions.defaultMode: "bypassPermissions"` in settings, and the mode is not disabled by [`permissions.disableBypassPermissionsMode`](https://code.claude.com/docs/en/permissions#managed-settings). Otherwise the update is a no-op. `bypassPermissions` is never persisted as `defaultMode` regardless of `destination`.

The `destination` field on every entry determines whether the change stays in memory or persists to a settings file.

| `destination` | Writes to |
| --- | --- |
| `session` | in-memory only, discarded when the session ends |
| `localSettings` | `.claude/settings.local.json` |
| `projectSettings` | `.claude/settings.json` |
| `userSettings` | `~/.claude/settings.json` |

A hook can echo one of the `permission_suggestions` it received as its own `updatedPermissions` output, which is equivalent to the user selecting that “always allow” option in the dialog.

### [​](https://code.claude.com/docs/en/hooks\#posttooluse)  PostToolUse

Runs immediately after a tool completes successfully.Matches on tool name, same values as PreToolUse.

#### [​](https://code.claude.com/docs/en/hooks\#posttooluse-input)  PostToolUse input

`PostToolUse` hooks fire after a tool has already executed successfully. The input includes both `tool_input`, the arguments sent to the tool, and `tool_response`, the result it returned. The exact schema for both depends on the tool.

```
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "PostToolUse",
  "tool_name": "Write",
  "tool_input": {
    "file_path": "/path/to/file.txt",
    "content": "file content"
  },
  "tool_response": {
    "filePath": "/path/to/file.txt",
    "success": true
  },
  "tool_use_id": "toolu_01ABC123...",
  "duration_ms": 12
}
```

| Field | Description |
| --- | --- |
| `duration_ms` | Optional. Tool execution time in milliseconds. Excludes time spent in permission prompts and PreToolUse hooks |

#### [​](https://code.claude.com/docs/en/hooks\#posttooluse-decision-control)  PostToolUse decision control

`PostToolUse` hooks can provide feedback to Claude after tool execution. In addition to the [JSON output fields](https://code.claude.com/docs/en/hooks#json-output) available to all hooks, your hook script can return these event-specific fields:

| Field | Description |
| --- | --- |
| `decision` | `"block"` prompts Claude with the `reason`. Omit to allow the action to proceed |
| `reason` | Explanation shown to Claude when `decision` is `"block"` |
| `additionalContext` | Additional context for Claude to consider |
| `updatedMCPToolOutput` | For [MCP tools](https://code.claude.com/docs/en/hooks#match-mcp-tools) only: replaces the tool’s output with the provided value |

```
{
  "decision": "block",
  "reason": "Explanation for decision",
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "Additional information for Claude"
  }
}
```

### [​](https://code.claude.com/docs/en/hooks\#posttoolusefailure)  PostToolUseFailure

Runs when a tool execution fails. This event fires for tool calls that throw errors or return failure results. Use this to log failures, send alerts, or provide corrective feedback to Claude.Matches on tool name, same values as PreToolUse.

#### [​](https://code.claude.com/docs/en/hooks\#posttoolusefailure-input)  PostToolUseFailure input

PostToolUseFailure hooks receive the same `tool_name` and `tool_input` fields as PostToolUse, along with error information as top-level fields:

```
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "PostToolUseFailure",
  "tool_name": "Bash",
  "tool_input": {
    "command": "npm test",
    "description": "Run test suite"
  },
  "tool_use_id": "toolu_01ABC123...",
  "error": "Command exited with non-zero status code 1",
  "is_interrupt": false,
  "duration_ms": 4187
}
```

| Field | Description |
| --- | --- |
| `error` | String describing what went wrong |
| `is_interrupt` | Optional boolean indicating whether the failure was caused by user interruption |
| `duration_ms` | Optional. Tool execution time in milliseconds. Excludes time spent in permission prompts and PreToolUse hooks |

#### [​](https://code.claude.com/docs/en/hooks\#posttoolusefailure-decision-control)  PostToolUseFailure decision control

`PostToolUseFailure` hooks can provide context to Claude after a tool failure. In addition to the [JSON output fields](https://code.claude.com/docs/en/hooks#json-output) available to all hooks, your hook script can return these event-specific fields:

| Field | Description |
| --- | --- |
| `additionalContext` | Additional context for Claude to consider alongside the error |

```
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUseFailure",
    "additionalContext": "Additional information about the failure for Claude"
  }
}
```

### [​](https://code.claude.com/docs/en/hooks\#posttoolbatch)  PostToolBatch

Runs once after every tool call in a batch has resolved, before Claude Code sends the next request to the model. `PostToolUse` fires once per tool, which means it fires concurrently when Claude makes parallel tool calls. `PostToolBatch` fires exactly once with the full batch, so it is the right place to inject context that depends on the set of tools that ran rather than on any single tool. There is no matcher for this event.

#### [​](https://code.claude.com/docs/en/hooks\#posttoolbatch-input)  PostToolBatch input

In addition to the [common input fields](https://code.claude.com/docs/en/hooks#common-input-fields), PostToolBatch hooks receive `tool_calls`, an array describing every tool call in the batch:

```
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "PostToolBatch",
  "tool_calls": [\
    {\
      "tool_name": "Read",\
      "tool_input": {"file_path": "/.../ledger/accounts.py"},\
      "tool_use_id": "toolu_01...",\
      "tool_response": "     1\tfrom __future__ import annotations\n     2\t..."\
    },\
    {\
      "tool_name": "Read",\
      "tool_input": {"file_path": "/.../ledger/transactions.py"},\
      "tool_use_id": "toolu_02...",\
      "tool_response": "     1\tfrom __future__ import annotations\n     2\t..."\
    }\
  ]
}
```

`tool_response` contains the same content the model receives in the corresponding `tool_result` block. The value is a serialized string or content-block array, exactly as the tool emitted it. For `Read`, that means line-number-prefixed text rather than raw file contents. Responses can be large, so parse only the fields you need.

The `tool_response` shape differs from `PostToolUse`’s. `PostToolUse` passes the tool’s structured `Output` object, such as `{filePath: "...", success: true}` for `Write`; `PostToolBatch` passes the serialized `tool_result` content the model sees.

#### [​](https://code.claude.com/docs/en/hooks\#posttoolbatch-decision-control)  PostToolBatch decision control

`PostToolBatch` hooks can inject context for Claude. In addition to the [JSON output fields](https://code.claude.com/docs/en/hooks#json-output) available to all hooks, your hook script can return these event-specific fields:

| Field | Description |
| --- | --- |
| `additionalContext` | Context string injected once before the next model call |

```
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolBatch",
    "additionalContext": "These files are part of the ledger module. Run pytest before marking the task complete."
  }
}
```

Injected `additionalContext` is persisted to the session transcript. On `--continue` or `--resume`, the saved text is replayed from disk and the hook does not re-run for past turns. Prefer static context such as conventions or file-type guidance over dynamic values like timestamps or the current commit SHA, since those become stale on resume.Frame the context as factual information rather than imperative system instructions. Text written as out-of-band system commands can trigger Claude’s prompt-injection defenses, which surfaces the injection to the user instead of acting on it.

Returning `decision: "block"` or `continue: false` stops the agentic loop before the next model call.

### [​](https://code.claude.com/docs/en/hooks\#permissiondenied)  PermissionDenied

Runs when the [auto mode](https://code.claude.com/docs/en/permission-modes#eliminate-prompts-with-auto-mode) classifier denies a tool call. This hook only fires in auto mode: it does not run when you manually deny a permission dialog, when a `PreToolUse` hook blocks a call, or when a `deny` rule matches. Use it to log classifier denials, adjust configuration, or tell the model it may retry the tool call.Matches on tool name, same values as PreToolUse.

#### [​](https://code.claude.com/docs/en/hooks\#permissiondenied-input)  PermissionDenied input

In addition to the [common input fields](https://code.claude.com/docs/en/hooks#common-input-fields), PermissionDenied hooks receive `tool_name`, `tool_input`, `tool_use_id`, and `reason`.

```
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "auto",
  "hook_event_name": "PermissionDenied",
  "tool_name": "Bash",
  "tool_input": {
    "command": "rm -rf /tmp/build",
    "description": "Clean build directory"
  },
  "tool_use_id": "toolu_01ABC123...",
  "reason": "Auto mode denied: command targets a path outside the project"
}
```

| Field | Description |
| --- | --- |
| `reason` | The classifier’s explanation for why the tool call was denied |

#### [​](https://code.claude.com/docs/en/hooks\#permissiondenied-decision-control)  PermissionDenied decision control

PermissionDenied hooks can tell the model it may retry the denied tool call. Return a JSON object with `hookSpecificOutput.retry` set to `true`:

```
{
  "hookSpecificOutput": {
    "hookEventName": "PermissionDenied",
    "retry": true
  }
}
```

When `retry` is `true`, Claude Code adds a message to the conversation telling the model it may retry the tool call. The denial itself is not reversed. If your hook does not return JSON, or returns `retry: false`, the denial stands and the model receives the original rejection message.

### [​](https://code.claude.com/docs/en/hooks\#notification)  Notification

Runs when Claude Code sends notifications. Matches on notification type: `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`. Omit the matcher to run hooks for all notification types.Use separate matchers to run different handlers depending on the notification type. This configuration triggers a permission-specific alert script when Claude needs permission approval and a different notification when Claude has been idle:

```
{
  "hooks": {
    "Notification": [\
      {\
        "matcher": "permission_prompt",\
        "hooks": [\
          {\
            "type": "command",\
            "command": "/path/to/permission-alert.sh"\
          }\
        ]\
      },\
      {\
        "matcher": "idle_prompt",\
        "hooks": [\
          {\
            "type": "command",\
            "command": "/path/to/idle-notification.sh"\
          }\
        ]\
      }\
    ]
  }
}
```

#### [​](https://code.claude.com/docs/en/hooks\#notification-input)  Notification input

In addition to the [common input fields](https://code.claude.com/docs/en/hooks#common-input-fields), Notification hooks receive `message` with the notification text, an optional `title`, and `notification_type` indicating which type fired.

```
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "hook_event_name": "Notification",
  "message": "Claude needs your permission to use Bash",
  "title": "Permission needed",
  "notification_type": "permission_prompt"
}
```

Notification hooks cannot block or modify notifications. In addition to the [JSON output fields](https://code.claude.com/docs/en/hooks#json-output) available to all hooks, you can return `additionalContext` to add context to the conversation:

| Field | Description |
| --- | --- |
| `additionalContext` | String added to Claude’s context |

### [​](https://code.claude.com/docs/en/hooks\#subagentstart)  SubagentStart

Runs when a Claude Code subagent is spawned via the Agent tool. Supports matchers to filter by agent type name (built-in agents like `Bash`, `Explore`, `Plan`, or custom agent names from `.claude/agents/`).

#### [​](https://code.claude.com/docs/en/hooks\#subagentstart-input)  SubagentStart input

In addition to the [common input fields](https://code.claude.com/docs/en/hooks#common-input-fields), SubagentStart hooks receive `agent_id` with the unique identifier for the subagent and `agent_type` with the agent name (built-in agents like `"Bash"`, `"Explore"`, `"Plan"`, or custom agent names).

```
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "hook_event_name": "SubagentStart",
  "agent_id": "agent-abc123",
  "agent_type": "Explore"
}
```

SubagentStart hooks cannot block subagent creation, but they can inject context into the subagent. In addition to the [JSON output fields](https://code.claude.com/docs/en/hooks#json-output) available to all hooks, you can return:

| Field | Description |
| --- | --- |
| `additionalContext` | String added to the subagent’s context |

```
{
  "hookSpecificOutput": {
    "hookEventName": "SubagentStart",
    "additionalContext": "Follow security guidelines for this task"
  }
}
```

### [​](https://code.claude.com/docs/en/hooks\#subagentstop)  SubagentStop

Runs when a Claude Code subagent has finished responding. Matches on agent type, same values as SubagentStart.

#### [​](https://code.claude.com/docs/en/hooks\#subagentstop-input)  SubagentStop input

In addition to the [common input fields](https://code.claude.com/docs/en/hooks#common-input-fields), SubagentStop hooks receive `stop_hook_active`, `agent_id`, `agent_type`, `agent_transcript_path`, and `last_assistant_message`. The `agent_type` field is the value used for matcher filtering. The `transcript_path` is the main session’s transcript, while `agent_transcript_path` is the subagent’s own transcript stored in a nested `subagents/` folder. The `last_assistant_message` field contains the text content of the subagent’s final response, so hooks can access it without parsing the transcript file.

```
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../abc123.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "SubagentStop",
  "stop_hook_active": false,
  "agent_id": "def456",
  "agent_type": "Explore",
  "agent_transcript_path": "~/.claude/projects/.../abc123/subagents/agent-def456.jsonl",
  "last_assistant_message": "Analysis complete. Found 3 potential issues..."
}
```

SubagentStop hooks use the same decision control format as [Stop hooks](https://code.claude.com/docs/en/hooks#stop-decision-control).

### [​](https://code.claude.com/docs/en/hooks\#taskcreated)  TaskCreated

Runs when a task is being created via the `TaskCreate` tool. Use this to enforce naming conventions, require task descriptions, or prevent certain tasks from being created.When a `TaskCreated` hook exits with code 2, the task is not created and the stderr message is fed back to the model as feedback. To stop the teammate entirely instead of re-running it, return JSON with `{"continue": false, "stopReason": "..."}`. TaskCreated hooks do not support matchers and fire on every occurrence.

#### [​](https://code.claude.com/docs/en/hooks\#taskcreated-input)  TaskCreated input

In addition to the [common input fields](https://code.claude.com/docs/en/hooks#common-input-fields), TaskCreated hooks receive `task_id`, `task_subject`, and optionally `task_description`, `teammate_name`, and `team_name`.

```
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "TaskCreated",
  "task_id": "task-001",
  "task_subject": "Implement user authentication",
  "task_description": "Add login and signup endpoints",
  "teammate_name": "implementer",
  "team_name": "my-project"
}
```

| Field | Description |
| --- | --- |
| `task_id` | Identifier of the task being created |
| `task_subject` | Title of the task |
| `task_description` | Detailed description of the task. May be absent |
| `teammate_name` | Name of the teammate creating the task. May be absent |
| `team_name` | Name of the team. May be absent |

#### [​](https://code.claude.com/docs/en/hooks\#taskcreated-decision-control)  TaskCreated decision control

TaskCreated hooks support two ways to control task creation:

- **Exit code 2**: the task is not created and the stderr message is fed back to the model as feedback.
- **JSON `{"continue": false, "stopReason": "..."}`**: stops the teammate entirely, matching `Stop` hook behavior. The `stopReason` is shown to the user.

This example blocks tasks whose subjects don’t follow the required format:

```
#!/bin/bash
INPUT=$(cat)
TASK_SUBJECT=$(echo "$INPUT" | jq -r '.task_subject')

if [[ ! "$TASK_SUBJECT" =~ ^\[TICKET-[0-9]+\] ]]; then
  echo "Task subject must start with a ticket number, e.g. '[TICKET-123] Add feature'" >&2
  exit 2
fi

exit 0
```

### [​](https://code.claude.com/docs/en/hooks\#taskcompleted)  TaskCompleted

Runs when a task is being marked as completed. This fires in two situations: when any agent explicitly marks a task as completed through the TaskUpdate tool, or when an [agent team](https://code.claude.com/docs/en/agent-teams) teammate finishes its turn with in-progress tasks. Use this to enforce completion criteria like passing tests or lint checks before a task can close.When a `TaskCompleted` hook exits with code 2, the task is not marked as completed and the stderr message is fed back to the model as feedback. To stop the teammate entirely instead of re-running it, return JSON with `{"continue": false, "stopReason": "..."}`. TaskCompleted hooks do not support matchers and fire on every occurrence.

#### [​](https://code.claude.com/docs/en/hooks\#taskcompleted-input)  TaskCompleted input

In addition to the [common input fields](https://code.claude.com/docs/en/hooks#common-input-fields), TaskCompleted hooks receive `task_id`, `task_subject`, and optionally `task_description`, `teammate_name`, and `team_name`.

```
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "TaskCompleted",
  "task_id": "task-001",
  "task_subject": "Implement user authentication",
  "task_description": "Add login and signup endpoints",
  "teammate_name": "implementer",
  "team_name": "my-project"
}
```

| Field | Description |
| --- | --- |
| `task_id` | Identifier of the task being completed |
| `task_subject` | Title of the task |
| `task_description` | Detailed description of the task. May be absent |
| `teammate_name` | Name of the teammate completing the task. May be absent |
| `team_name` | Name of the team. May be absent |

#### [​](https://code.claude.com/docs/en/hooks\#taskcompleted-decision-control)  TaskCompleted decision control

TaskCompleted hooks support two ways to control task completion:

- **Exit code 2**: the task is not marked as completed and the stderr message is fed back to the model as feedback.
- **JSON `{"continue": false, "stopReason": "..."}`**: stops the teammate entirely, matching `Stop` hook behavior. The `stopReason` is shown to the user.

This example runs tests and blocks task completion if they fail:

```
#!/bin/bash
INPUT=$(cat)
TASK_SUBJECT=$(echo "$INPUT" | jq -r '.task_subject')

# Run the test suite
if ! npm test 2>&1; then
  echo "Tests not passing. Fix failing tests before completing: $TASK_SUBJECT" >&2
  exit 2
fi

exit 0
```

### [​](https://code.claude.com/docs/en/hooks\#stop)  Stop

Runs when the main Claude Code agent has finished responding. Does not run if
the stoppage occurred due to a user interrupt. API errors fire
[StopFailure](https://code.claude.com/docs/en/hooks#stopfailure) instead.

#### [​](https://code.claude.com/docs/en/hooks\#stop-input)  Stop input

In addition to the [common input fields](https://code.claude.com/docs/en/hooks#common-input-fields), Stop hooks receive `stop_hook_active` and `last_assistant_message`. The `stop_hook_active` field is `true` when Claude Code is already continuing as a result of a stop hook. Check this value or process the transcript to prevent Claude Code from running indefinitely. The `last_assistant_message` field contains the text content of Claude’s final response, so hooks can access it without parsing the transcript file.

```
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "Stop",
  "stop_hook_active": true,
  "last_assistant_message": "I've completed the refactoring. Here's a summary..."
}
```

#### [​](https://code.claude.com/docs/en/hooks\#stop-decision-control)  Stop decision control

`Stop` and `SubagentStop` hooks can control whether Claude continues. In addition to the [JSON output fields](https://code.claude.com/docs/en/hooks#json-output) available to all hooks, your hook script can return these event-specific fields:

| Field | Description |
| --- | --- |
| `decision` | `"block"` prevents Claude from stopping. Omit to allow Claude to stop |
| `reason` | Required when `decision` is `"block"`. Tells Claude why it should continue |

```
{
  "decision": "block",
  "reason": "Must be provided when Claude is blocked from stopping"
}
```

### [​](https://code.claude.com/docs/en/hooks\#stopfailure)  StopFailure

Runs instead of [Stop](https://code.claude.com/docs/en/hooks#stop) when the turn ends due to an API error. Output and exit code are ignored. Use this to log failures, send alerts, or take recovery actions when Claude cannot complete a response due to rate limits, authentication problems, or other API errors.

#### [​](https://code.claude.com/docs/en/hooks\#stopfailure-input)  StopFailure input

In addition to the [common input fields](https://code.claude.com/docs/en/hooks#common-input-fields), StopFailure hooks receive `error`, optional `error_details`, and optional `last_assistant_message`. The `error` field identifies the error type and is used for matcher filtering.

| Field | Description |
| --- | --- |
| `error` | Error type: `rate_limit`, `authentication_failed`, `billing_error`, `invalid_request`, `server_error`, `max_output_tokens`, or `unknown` |
| `error_details` | Additional details about the error, when available |
| `last_assistant_message` | The rendered error text shown in the conversation. Unlike `Stop` and `SubagentStop`, where this field holds Claude’s conversational output, for `StopFailure` it contains the API error string itself, such as `"API Error: Rate limit reached"` |

```
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "hook_event_name": "StopFailure",
  "error": "rate_limit",
  "error_details": "429 Too Many Requests",
  "last_assistant_message": "API Error: Rate limit reached"
}
```

StopFailure hooks have no decision control. They run for notification and logging purposes only.

### [​](https://code.claude.com/docs/en/hooks\#teammateidle)  TeammateIdle

Runs when an [agent team](https://code.claude.com/docs/en/agent-teams) teammate is about to go idle after finishing its turn. Use this to enforce quality gates before a teammate stops working, such as requiring passing lint checks or verifying that output files exist.When a `TeammateIdle` hook exits with code 2, the teammate receives the stderr message as feedback and continues working instead of going idle. To stop the teammate entirely instead of re-running it, return JSON with `{"continue": false, "stopReason": "..."}`. TeammateIdle hooks do not support matchers and fire on every occurrence.

#### [​](https://code.claude.com/docs/en/hooks\#teammateidle-input)  TeammateIdle input

In addition to the [common input fields](https://code.claude.com/docs/en/hooks#common-input-fields), TeammateIdle hooks receive `teammate_name` and `team_name`.

```
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "TeammateIdle",
  "teammate_name": "researcher",
  "team_name": "my-project"
}
```

| Field | Description |
| --- | --- |
| `teammate_name` | Name of the teammate that is about to go idle |
| `team_name` | Name of the team |

#### [​](https://code.claude.com/docs/en/hooks\#teammateidle-decision-control)  TeammateIdle decision control

TeammateIdle hooks support two ways to control teammate behavior:

- **Exit code 2**: the teammate receives the stderr message as feedback and continues working instead of going idle.
- **JSON `{"continue": false, "stopReason": "..."}`**: stops the teammate entirely, matching `Stop` hook behavior. The `stopReason` is shown to the user.

This example checks that a build artifact exists before allowing a teammate to go idle:

```
#!/bin/bash

if [ ! -f "./dist/output.js" ]; then
  echo "Build artifact missing. Run the build before stopping." >&2
  exit 2
fi

exit 0
```

### [​](https://code.claude.com/docs/en/hooks\#configchange)  ConfigChange

Runs when a configuration file changes during a session. Use this to audit settings changes, enforce security policies, or block unauthorized modifications to configuration files.ConfigChange hooks fire for changes to settings files, managed policy settings, and skill files. The `source` field in the input tells you which type of configuration changed, and the optional `file_path` field provides the path to the changed file.The matcher filters on the configuration source:

| Matcher | When it fires |
| --- | --- |
| `user_settings` | `~/.claude/settings.json` changes |
| `project_settings` | `.claude/settings.json` changes |
| `local_settings` | `.claude/settings.local.json` changes |
| `policy_settings` | Managed policy settings change |
| `skills` | A skill file in `.claude/skills/` changes |

This example logs all configuration changes for security auditing:

```
{
  "hooks": {
    "ConfigChange": [\
      {\
        "hooks": [\
          {\
            "type": "command",\
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/audit-config-change.sh"\
          }\
        ]\
      }\
    ]
  }
}
```

#### [​](https://code.claude.com/docs/en/hooks\#configchange-input)  ConfigChange input

In addition to the [common input fields](https://code.claude.com/docs/en/hooks#common-input-fields), ConfigChange hooks receive `source` and optionally `file_path`. The `source` field indicates which configuration type changed, and `file_path` provides the path to the specific file that was modified.

```
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "hook_event_name": "ConfigChange",
  "source": "project_settings",
  "file_path": "/Users/.../my-project/.claude/settings.json"
}
```

#### [​](https://code.claude.com/docs/en/hooks\#configchange-decision-control)  ConfigChange decision control

ConfigChange hooks can block configuration changes from taking effect. Use exit code 2 or a JSON `decision` to prevent the change. When blocked, the new settings are not applied to the running session.

| Field | Description |
| --- | --- |
| `decision` | `"block"` prevents the configuration change from being applied. Omit to allow the change |
| `reason` | Explanation shown to the user when `decision` is `"block"` |

```
{
  "decision": "block",
  "reason": "Configuration changes to project settings require admin approval"
}
```

`policy_settings` changes cannot be blocked. Hooks still fire for `policy_settings` sources, so you can use them for audit logging, but any blocking decision is ignored. This ensures enterprise-managed settings always take effect.

### [​](https://code.claude.com/docs/en/hooks\#cwdchanged)  CwdChanged

Runs when the working directory changes during a session, for example when Claude executes a `cd` command. Use this to react to directory changes: reload environment variables, activate project-specific toolchains, or run setup scripts automatically. Pairs with [FileChanged](https://code.claude.com/docs/en/hooks#filechanged) for tools like [direnv](https://direnv.net/) that manage per-directory environment.CwdChanged hooks have access to `CLAUDE_ENV_FILE`. Variables written to that file persist into subsequent Bash commands for the session, just as in [SessionStart hooks](https://code.claude.com/docs/en/hooks#persist-environment-variables).CwdChanged does not support matchers and fires on every directory change.

#### [​](https://code.claude.com/docs/en/hooks\#cwdchanged-input)  CwdChanged input

In addition to the [common input fields](https://code.claude.com/docs/en/hooks#common-input-fields), CwdChanged hooks receive `old_cwd` and `new_cwd`.

```
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../transcript.jsonl",
  "cwd": "/Users/my-project/src",
  "hook_event_name": "CwdChanged",
  "old_cwd": "/Users/my-project",
  "new_cwd": "/Users/my-project/src"
}
```

#### [​](https://code.claude.com/docs/en/hooks\#cwdchanged-output)  CwdChanged output

In addition to the [JSON output fields](https://code.claude.com/docs/en/hooks#json-output) available to all hooks, CwdChanged hooks can return `watchPaths` to dynamically set which file paths [FileChanged](https://code.claude.com/docs/en/hooks#filechanged) watches:

| Field | Description |
| --- | --- |
| `watchPaths` | Array of absolute paths. Replaces the current dynamic watch list (paths from your `matcher` configuration are always watched). Returning an empty array clears the dynamic list, which is typical when entering a new directory |

CwdChanged hooks have no decision control. They cannot block the directory change.

### [​](https://code.claude.com/docs/en/hooks\#filechanged)  FileChanged

Runs when a watched file changes on disk. Useful for reloading environment variables when project configuration files are modified.The `matcher` for this event serves two roles:

- **Build the watch list**: the value is split on `|` and each segment is registered as a literal filename in the working directory, so `".envrc|.env"` watches exactly those two files. Regex patterns are not useful here: a value like `^\.env` would watch a file literally named `^\.env`.
- **Filter which hooks run**: when a watched file changes, the same value filters which hook groups run using the standard [matcher rules](https://code.claude.com/docs/en/hooks#matcher-patterns) against the changed file’s basename.

FileChanged hooks have access to `CLAUDE_ENV_FILE`. Variables written to that file persist into subsequent Bash commands for the session, just as in [SessionStart hooks](https://code.claude.com/docs/en/hooks#persist-environment-variables).

#### [​](https://code.claude.com/docs/en/hooks\#filechanged-input)  FileChanged input

In addition to the [common input fields](https://code.claude.com/docs/en/hooks#common-input-fields), FileChanged hooks receive `file_path` and `event`.

| Field | Description |
| --- | --- |
| `file_path` | Absolute path to the file that changed |
| `event` | What happened: `"change"` (file modified), `"add"` (file created), or `"unlink"` (file deleted) |

```
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../transcript.jsonl",
  "cwd": "/Users/my-project",
  "hook_event_name": "FileChanged",
  "file_path": "/Users/my-project/.envrc",
  "event": "change"
}
```

#### [​](https://code.claude.com/docs/en/hooks\#filechanged-output)  FileChanged output

In addition to the [JSON output fields](https://code.claude.com/docs/en/hooks#json-output) available to all hooks, FileChanged hooks can return `watchPaths` to dynamically update which file paths are watched:

| Field | Description |
| --- | --- |
| `watchPaths` | Array of absolute paths. Replaces the current dynamic watch list (paths from your `matcher` configuration are always watched). Use this when your hook script discovers additional files to watch based on the changed file |

FileChanged hooks have no decision control. They cannot block the file change from occurring.

### [​](https://code.claude.com/docs/en/hooks\#worktreecreate)  WorktreeCreate

When you run `claude --worktree` or a [subagent uses `isolation: "worktree"`](https://code.claude.com/docs/en/sub-agents#choose-the-subagent-scope), Claude Code creates an isolated working copy using `git worktree`. If you configure a WorktreeCreate hook, it replaces the default git behavior, letting you use a different version control system like SVN, Perforce, or Mercurial.Because the hook replaces the default behavior entirely, [`.worktreeinclude`](https://code.claude.com/docs/en/common-workflows#copy-gitignored-files-to-worktrees) is not processed. If you need to copy local configuration files like `.env` into the new worktree, do it inside your hook script.The hook must return the absolute path to the created worktree directory. Claude Code uses this path as the working directory for the isolated session. Command hooks print it on stdout; HTTP hooks return it via `hookSpecificOutput.worktreePath`.This example creates an SVN working copy and prints the path for Claude Code to use. Replace the repository URL with your own:

```
{
  "hooks": {
    "WorktreeCreate": [\
      {\
        "hooks": [\
          {\
            "type": "command",\
            "command": "bash -c 'NAME=$(jq -r .name); DIR=\"$HOME/.claude/worktrees/$NAME\"; svn checkout https://svn.example.com/repo/trunk \"$DIR\" >&2 && echo \"$DIR\"'"\
          }\
        ]\
      }\
    ]
  }
}
```

The hook reads the worktree `name` from the JSON input on stdin, checks out a fresh copy into a new directory, and prints the directory path. The `echo` on the last line is what Claude Code reads as the worktree path. Redirect any other output to stderr so it doesn’t interfere with the path.

#### [​](https://code.claude.com/docs/en/hooks\#worktreecreate-input)  WorktreeCreate input

In addition to the [common input fields](https://code.claude.com/docs/en/hooks#common-input-fields), WorktreeCreate hooks receive the `name` field. This is a slug identifier for the new worktree, either specified by the user or auto-generated (for example, `bold-oak-a3f2`).

```
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "hook_event_name": "WorktreeCreate",
  "name": "feature-auth"
}
```

#### [​](https://code.claude.com/docs/en/hooks\#worktreecreate-output)  WorktreeCreate output

WorktreeCreate hooks do not use the standard allow/block decision model. Instead, the hook’s success or failure determines the outcome. The hook must return the absolute path to the created worktree directory:

- **Command hooks** (`type: "command"`): print the path on stdout.
- **HTTP hooks** (`type: "http"`): return `{ "hookSpecificOutput": { "hookEventName": "WorktreeCreate", "worktreePath": "/absolute/path" } }` in the response body.

If the hook fails or produces no path, worktree creation fails with an error.

### [​](https://code.claude.com/docs/en/hooks\#worktreeremove)  WorktreeRemove

The cleanup counterpart to [WorktreeCreate](https://code.claude.com/docs/en/hooks#worktreecreate). This hook fires when a worktree is being removed, either when you exit a `--worktree` session and choose to remove it, or when a subagent with `isolation: "worktree"` finishes. For git-based worktrees, Claude handles cleanup automatically with `git worktree remove`. If you configured a WorktreeCreate hook for a non-git version control system, pair it with a WorktreeRemove hook to handle cleanup. Without one, the worktree directory is left on disk.Claude Code passes the path returned by WorktreeCreate as `worktree_path` in the hook input. This example reads that path and removes the directory:

```
{
  "hooks": {
    "WorktreeRemove": [\
      {\
        "hooks": [\
          {\
            "type": "command",\
            "command": "bash -c 'jq -r .worktree_path | xargs rm -rf'"\
          }\
        ]\
      }\
    ]
  }
}
```

#### [​](https://code.claude.com/docs/en/hooks\#worktreeremove-input)  WorktreeRemove input

In addition to the [common input fields](https://code.claude.com/docs/en/hooks#common-input-fields), WorktreeRemove hooks receive the `worktree_path` field, which is the absolute path to the worktree being removed.

```
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "hook_event_name": "WorktreeRemove",
  "worktree_path": "/Users/.../my-project/.claude/worktrees/feature-auth"
}
```

WorktreeRemove hooks have no decision control. They cannot block worktree removal but can perform cleanup tasks like removing version control state or archiving changes. Hook failures are logged in debug mode only.

### [​](https://code.claude.com/docs/en/hooks\#precompact)  PreCompact

Runs before Claude Code is about to run a compact operation.The matcher value indicates whether compaction was triggered manually or automatically:

| Matcher | When it fires |
| --- | --- |
| `manual` | `/compact` |
| `auto` | Auto-compact when the context window is full |

Exit with code 2 to block compaction. For a manual `/compact`, the stderr message is shown to the user. You can also block by returning JSON with `"decision": "block"`.Blocking automatic compaction has different effects depending on when it fires. If compaction was triggered proactively before the context limit, Claude Code skips it and the conversation continues uncompacted. If compaction was triggered to recover from a context-limit error already returned by the API, the underlying error surfaces and the current request fails.

#### [​](https://code.claude.com/docs/en/hooks\#precompact-input)  PreCompact input

In addition to the [common input fields](https://code.claude.com/docs/en/hooks#common-input-fields), PreCompact hooks receive `trigger` and `custom_instructions`. For `manual`, `custom_instructions` contains what the user passes into `/compact`. For `auto`, `custom_instructions` is empty.

```
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "hook_event_name": "PreCompact",
  "trigger": "manual",
  "custom_instructions": ""
}
```

### [​](https://code.claude.com/docs/en/hooks\#postcompact)  PostCompact

Runs after Claude Code completes a compact operation. Use this event to react to the new compacted state, for example to log the generated summary or update external state.The same matcher values apply as for `PreCompact`:

| Matcher | When it fires |
| --- | --- |
| `manual` | After `/compact` |
| `auto` | After auto-compact when the context window is full |

#### [​](https://code.claude.com/docs/en/hooks\#postcompact-input)  PostCompact input

In addition to the [common input fields](https://code.claude.com/docs/en/hooks#common-input-fields), PostCompact hooks receive `trigger` and `compact_summary`. The `compact_summary` field contains the conversation summary generated by the compact operation.

```
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "hook_event_name": "PostCompact",
  "trigger": "manual",
  "compact_summary": "Summary of the compacted conversation..."
}
```

PostCompact hooks have no decision control. They cannot affect the compaction result but can perform follow-up tasks.

### [​](https://code.claude.com/docs/en/hooks\#sessionend)  SessionEnd

Runs when a Claude Code session ends. Useful for cleanup tasks, logging session
statistics, or saving session state. Supports matchers to filter by exit reason.The `reason` field in the hook input indicates why the session ended:

| Reason | Description |
| --- | --- |
| `clear` | Session cleared with `/clear` command |
| `resume` | Session switched via interactive `/resume` |
| `logout` | User logged out |
| `prompt_input_exit` | User exited while prompt input was visible |
| `bypass_permissions_disabled` | Bypass permissions mode was disabled |
| `other` | Other exit reasons |

#### [​](https://code.claude.com/docs/en/hooks\#sessionend-input)  SessionEnd input

In addition to the [common input fields](https://code.claude.com/docs/en/hooks#common-input-fields), SessionEnd hooks receive a `reason` field indicating why the session ended. See the [reason table](https://code.claude.com/docs/en/hooks#sessionend) above for all values.

```
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "hook_event_name": "SessionEnd",
  "reason": "other"
}
```

SessionEnd hooks have no decision control. They cannot block session termination but can perform cleanup tasks.SessionEnd hooks have a default timeout of 1.5 seconds. This applies to session exit, `/clear`, and switching sessions via interactive `/resume`. If a hook needs more time, set a per-hook `timeout` in the hook configuration. The overall budget is automatically raised to the highest per-hook timeout configured in settings files, up to 60 seconds. Timeouts set on plugin-provided hooks do not raise the budget. To override the budget explicitly, set the `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS` environment variable in milliseconds.

```
CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS=5000 claude
```

### [​](https://code.claude.com/docs/en/hooks\#elicitation)  Elicitation

Runs when an MCP server requests user input mid-task. By default, Claude Code shows an interactive dialog for the user to respond. Hooks can intercept this request and respond programmatically, skipping the dialog entirely.The matcher field matches against the MCP server name.

#### [​](https://code.claude.com/docs/en/hooks\#elicitation-input)  Elicitation input

In addition to the [common input fields](https://code.claude.com/docs/en/hooks#common-input-fields), Elicitation hooks receive `mcp_server_name`, `message`, and optional `mode`, `url`, `elicitation_id`, and `requested_schema` fields.For form-mode elicitation (the most common case):

```
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "Elicitation",
  "mcp_server_name": "my-mcp-server",
  "message": "Please provide your credentials",
  "mode": "form",
  "requested_schema": {
    "type": "object",
    "properties": {
      "username": { "type": "string", "title": "Username" }
    }
  }
}
```

For URL-mode elicitation (browser-based authentication):

```
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "Elicitation",
  "mcp_server_name": "my-mcp-server",
  "message": "Please authenticate",
  "mode": "url",
  "url": "https://auth.example.com/login"
}
```

#### [​](https://code.claude.com/docs/en/hooks\#elicitation-output)  Elicitation output

To respond programmatically without showing the dialog, return a JSON object with `hookSpecificOutput`:

```
{
  "hookSpecificOutput": {
    "hookEventName": "Elicitation",
    "action": "accept",
    "content": {
      "username": "alice"
    }
  }
}
```

| Field | Values | Description |
| --- | --- | --- |
| `action` | `accept`, `decline`, `cancel` | Whether to accept, decline, or cancel the request |
| `content` | object | Form field values to submit. Only used when `action` is `accept` |

Exit code 2 denies the elicitation and shows stderr to the user.

### [​](https://code.claude.com/docs/en/hooks\#elicitationresult)  ElicitationResult

Runs after a user responds to an MCP elicitation. Hooks can observe, modify, or block the response before it is sent back to the MCP server.The matcher field matches against the MCP server name.

#### [​](https://code.claude.com/docs/en/hooks\#elicitationresult-input)  ElicitationResult input

In addition to the [common input fields](https://code.claude.com/docs/en/hooks#common-input-fields), ElicitationResult hooks receive `mcp_server_name`, `action`, and optional `mode`, `elicitation_id`, and `content` fields.

```
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "ElicitationResult",
  "mcp_server_name": "my-mcp-server",
  "action": "accept",
  "content": { "username": "alice" },
  "mode": "form",
  "elicitation_id": "elicit-123"
}
```

#### [​](https://code.claude.com/docs/en/hooks\#elicitationresult-output)  ElicitationResult output

To override the user’s response, return a JSON object with `hookSpecificOutput`:

```
{
  "hookSpecificOutput": {
    "hookEventName": "ElicitationResult",
    "action": "decline",
    "content": {}
  }
}
```

| Field | Values | Description |
| --- | --- | --- |
| `action` | `accept`, `decline`, `cancel` | Overrides the user’s action |
| `content` | object | Overrides form field values. Only meaningful when `action` is `accept` |

Exit code 2 blocks the response, changing the effective action to `decline`.

## [​](https://code.claude.com/docs/en/hooks\#prompt-based-hooks)  Prompt-based hooks

In addition to command, HTTP, and MCP tool hooks, Claude Code supports prompt-based hooks (`type: "prompt"`) that use an LLM to evaluate whether to allow or block an action, and agent hooks (`type: "agent"`) that spawn an agentic verifier with tool access. Not all events support every hook type.Events that support all five hook types (`command`, `http`, `mcp_tool`, `prompt`, and `agent`):

- `PermissionRequest`
- `PostToolBatch`
- `PostToolUse`
- `PostToolUseFailure`
- `PreToolUse`
- `Stop`
- `SubagentStop`
- `TaskCompleted`
- `TaskCreated`
- `UserPromptExpansion`
- `UserPromptSubmit`

Events that support `command`, `http`, and `mcp_tool` hooks but not `prompt` or `agent`:

- `ConfigChange`
- `CwdChanged`
- `Elicitation`
- `ElicitationResult`
- `FileChanged`
- `InstructionsLoaded`
- `Notification`
- `PermissionDenied`
- `PostCompact`
- `PreCompact`
- `SessionEnd`
- `StopFailure`
- `SubagentStart`
- `TeammateIdle`
- `WorktreeCreate`
- `WorktreeRemove`

`SessionStart` and `Setup` support `command` and `mcp_tool` hooks. They do not support `http`, `prompt`, or `agent` hooks.

### [​](https://code.claude.com/docs/en/hooks\#how-prompt-based-hooks-work)  How prompt-based hooks work

Instead of executing a Bash command, prompt-based hooks:

1. Send the hook input and your prompt to a Claude model, Haiku by default
2. The LLM responds with structured JSON containing a decision
3. Claude Code processes the decision automatically

### [​](https://code.claude.com/docs/en/hooks\#prompt-hook-configuration)  Prompt hook configuration

Set `type` to `"prompt"` and provide a `prompt` string instead of a `command`. Use the `$ARGUMENTS` placeholder to inject the hook’s JSON input data into your prompt text. Claude Code sends the combined prompt and input to a fast Claude model, which returns a JSON decision.This `Stop` hook asks the LLM to evaluate whether all tasks are complete before allowing Claude to finish:

```
{
  "hooks": {
    "Stop": [\
      {\
        "hooks": [\
          {\
            "type": "prompt",\
            "prompt": "Evaluate if Claude should stop: $ARGUMENTS. Check if all tasks are complete."\
          }\
        ]\
      }\
    ]
  }
}
```

| Field | Required | Description |
| --- | --- | --- |
| `type` | yes | Must be `"prompt"` |
| `prompt` | yes | The prompt text to send to the LLM. Use `$ARGUMENTS` as a placeholder for the hook input JSON. If `$ARGUMENTS` is not present, input JSON is appended to the prompt |
| `model` | no | Model to use for evaluation. Defaults to a fast model |
| `timeout` | no | Timeout in seconds. Default: 30 |

### [​](https://code.claude.com/docs/en/hooks\#response-schema)  Response schema

The LLM must respond with JSON containing:

```
{
  "ok": true | false,
  "reason": "Explanation for the decision"
}
```

| Field | Description |
| --- | --- |
| `ok` | `true` allows the action, `false` prevents it |
| `reason` | Required when `ok` is `false`. Explanation shown to Claude |

### [​](https://code.claude.com/docs/en/hooks\#example-multi-criteria-stop-hook)  Example: Multi-criteria Stop hook

This `Stop` hook uses a detailed prompt to check three conditions before allowing Claude to stop. If `"ok"` is `false`, Claude continues working with the provided reason as its next instruction. `SubagentStop` hooks use the same format to evaluate whether a [subagent](https://code.claude.com/docs/en/sub-agents) should stop:

```
{
  "hooks": {
    "Stop": [\
      {\
        "hooks": [\
          {\
            "type": "prompt",\
            "prompt": "You are evaluating whether Claude should stop working. Context: $ARGUMENTS\n\nAnalyze the conversation and determine if:\n1. All user-requested tasks are complete\n2. Any errors need to be addressed\n3. Follow-up work is needed\n\nRespond with JSON: {\"ok\": true} to allow stopping, or {\"ok\": false, \"reason\": \"your explanation\"} to continue working.",\
            "timeout": 30\
          }\
        ]\
      }\
    ]
  }
}
```

## [​](https://code.claude.com/docs/en/hooks\#agent-based-hooks)  Agent-based hooks

Agent hooks are experimental. Behavior and configuration may change in future releases. For production workflows, prefer [command hooks](https://code.claude.com/docs/en/hooks#command-hook-fields).

Agent-based hooks (`type: "agent"`) are like prompt-based hooks but with multi-turn tool access. Instead of a single LLM call, an agent hook spawns a subagent that can read files, search code, and inspect the codebase to verify conditions. Agent hooks support the same events as prompt-based hooks.

### [​](https://code.claude.com/docs/en/hooks\#how-agent-hooks-work)  How agent hooks work

When an agent hook fires:

1. Claude Code spawns a subagent with your prompt and the hook’s JSON input
2. The subagent can use tools like Read, Grep, and Glob to investigate
3. After up to 50 turns, the subagent returns a structured `{ "ok": true/false }` decision
4. Claude Code processes the decision the same way as a prompt hook

Agent hooks are useful when verification requires inspecting actual files or test output, not just evaluating the hook input data alone.

### [​](https://code.claude.com/docs/en/hooks\#agent-hook-configuration)  Agent hook configuration

Set `type` to `"agent"` and provide a `prompt` string. The configuration fields are the same as [prompt hooks](https://code.claude.com/docs/en/hooks#prompt-hook-configuration), with a longer default timeout:

| Field | Required | Description |
| --- | --- | --- |
| `type` | yes | Must be `"agent"` |
| `prompt` | yes | Prompt describing what to verify. Use `$ARGUMENTS` as a placeholder for the hook input JSON |
| `model` | no | Model to use. Defaults to a fast model |
| `timeout` | no | Timeout in seconds. Default: 60 |

The response schema is the same as prompt hooks: `{ "ok": true }` to allow or `{ "ok": false, "reason": "..." }` to block.This `Stop` hook verifies that all unit tests pass before allowing Claude to finish:

```
{
  "hooks": {
    "Stop": [\
      {\
        "hooks": [\
          {\
            "type": "agent",\
            "prompt": "Verify that all unit tests pass. Run the test suite and check the results. $ARGUMENTS",\
            "timeout": 120\
          }\
        ]\
      }\
    ]
  }
}
```

## [​](https://code.claude.com/docs/en/hooks\#run-hooks-in-the-background)  Run hooks in the background

By default, hooks block Claude’s execution until they complete. For long-running tasks like deployments, test suites, or external API calls, set `"async": true` to run the hook in the background while Claude continues working. Async hooks cannot block or control Claude’s behavior: response fields like `decision`, `permissionDecision`, and `continue` have no effect, because the action they would have controlled has already completed.

### [​](https://code.claude.com/docs/en/hooks\#configure-an-async-hook)  Configure an async hook

Add `"async": true` to a command hook’s configuration to run it in the background without blocking Claude. This field is only available on `type: "command"` hooks.This hook runs a test script after every `Write` tool call. Claude continues working immediately while `run-tests.sh` executes for up to 120 seconds. When the script finishes, its output is delivered on the next conversation turn:

```
{
  "hooks": {
    "PostToolUse": [\
      {\
        "matcher": "Write",\
        "hooks": [\
          {\
            "type": "command",\
            "command": "/path/to/run-tests.sh",\
            "async": true,\
            "timeout": 120\
          }\
        ]\
      }\
    ]
  }
}
```

The `timeout` field sets the maximum time in seconds for the background process. If not specified, async hooks use the same 10-minute default as sync hooks.

### [​](https://code.claude.com/docs/en/hooks\#how-async-hooks-execute)  How async hooks execute

When an async hook fires, Claude Code starts the hook process and immediately continues without waiting for it to finish. The hook receives the same JSON input via stdin as a synchronous hook.After the background process exits, if the hook produced a JSON response with a `systemMessage` or `additionalContext` field, that content is delivered to Claude as context on the next conversation turn.Async hook completion notifications are suppressed by default. To see them, enable verbose mode with `Ctrl+O` or start Claude Code with `--verbose`.

### [​](https://code.claude.com/docs/en/hooks\#example-run-tests-after-file-changes)  Example: run tests after file changes

This hook starts a test suite in the background whenever Claude writes a file, then reports the results back to Claude when the tests finish. Save this script to `.claude/hooks/run-tests-async.sh` in your project and make it executable with `chmod +x`:

```
#!/bin/bash
# run-tests-async.sh

# Read hook input from stdin
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only run tests for source files
if [[ "$FILE_PATH" != *.ts && "$FILE_PATH" != *.js ]]; then
  exit 0
fi

# Run tests and report results via systemMessage
RESULT=$(npm test 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
  echo "{\"systemMessage\": \"Tests passed after editing $FILE_PATH\"}"
else
  echo "{\"systemMessage\": \"Tests failed after editing $FILE_PATH: $RESULT\"}"
fi
```

Then add this configuration to `.claude/settings.json` in your project root. The `async: true` flag lets Claude keep working while tests run:

```
{
  "hooks": {
    "PostToolUse": [\
      {\
        "matcher": "Write|Edit",\
        "hooks": [\
          {\
            "type": "command",\
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/run-tests-async.sh",\
            "async": true,\
            "timeout": 300\
          }\
        ]\
      }\
    ]
  }
}
```

### [​](https://code.claude.com/docs/en/hooks\#limitations)  Limitations

Async hooks have several constraints compared to synchronous hooks:

- Only `type: "command"` hooks support `async`. Prompt-based hooks cannot run asynchronously.
- Async hooks cannot block tool calls or return decisions. By the time the hook completes, the triggering action has already proceeded.
- Hook output is delivered on the next conversation turn. If the session is idle, the response waits until the next user interaction. Exception: an `asyncRewake` hook that exits with code 2 wakes Claude immediately even when the session is idle.
- Each execution creates a separate background process. There is no deduplication across multiple firings of the same async hook.

## [​](https://code.claude.com/docs/en/hooks\#security-considerations)  Security considerations

### [​](https://code.claude.com/docs/en/hooks\#disclaimer)  Disclaimer

Command hooks run with your system user’s full permissions.

Command hooks execute shell commands with your full user permissions. They can modify, delete, or access any files your user account can access. Review and test all hook commands before adding them to your configuration.

### [​](https://code.claude.com/docs/en/hooks\#security-best-practices)  Security best practices

Keep these practices in mind when writing hooks:

- **Validate and sanitize inputs**: never trust input data blindly
- **Always quote shell variables**: use `"$VAR"` not `$VAR`
- **Block path traversal**: check for `..` in file paths
- **Use absolute paths**: specify full paths for scripts, using `"$CLAUDE_PROJECT_DIR"` for the project root
- **Skip sensitive files**: avoid `.env`, `.git/`, keys, etc.

## [​](https://code.claude.com/docs/en/hooks\#windows-powershell-tool)  Windows PowerShell tool

On Windows, you can run individual hooks in PowerShell by setting `"shell": "powershell"` on a command hook. Hooks spawn PowerShell directly, so this works regardless of whether `CLAUDE_CODE_USE_POWERSHELL_TOOL` is set. Claude Code auto-detects `pwsh.exe` (PowerShell 7+) with a fallback to `powershell.exe` (5.1).

```
{
  "hooks": {
    "PostToolUse": [\
      {\
        "matcher": "Write",\
        "hooks": [\
          {\
            "type": "command",\
            "shell": "powershell",\
            "command": "Write-Host 'File written'"\
          }\
        ]\
      }\
    ]
  }
}
```

## [​](https://code.claude.com/docs/en/hooks\#debug-hooks)  Debug hooks

Hook execution details, including which hooks matched, their exit codes, and full stdout and stderr, are written to the debug log file. Start Claude Code with `claude --debug-file <path>` to write the log to a known location, or run `claude --debug` and read the log at `~/.claude/debug/<session-id>.txt`. The `--debug` flag does not print to the terminal.

```
[DEBUG] Executing hooks for PostToolUse:Write
[DEBUG] Found 1 hook commands to execute
[DEBUG] Executing hook command: <Your command> with timeout 600000ms
[DEBUG] Hook command completed with status 0: <Your stdout>
```

For more granular hook matching details, set `CLAUDE_CODE_DEBUG_LOG_LEVEL=verbose` to see additional log lines such as hook matcher counts and query matching.For troubleshooting common issues like hooks not firing, infinite Stop hook loops, or configuration errors, see [Limitations and troubleshooting](https://code.claude.com/docs/en/hooks-guide#limitations-and-troubleshooting) in the guide. For a broader diagnostic walkthrough covering `/context`, `/doctor`, and settings precedence, see [Debug your config](https://code.claude.com/docs/en/debug-your-config).

Was this page helpful?

YesNo

[Checkpointing](https://code.claude.com/docs/en/checkpointing) [Plugins reference](https://code.claude.com/docs/en/plugins-reference)

Ctrl+I

Assistant

Responses are generated using AI and may contain mistakes.

![Hook lifecycle diagram showing SessionStart, then a per-turn loop containing UserPromptSubmit, UserPromptExpansion for slash commands, the nested agentic loop (PreToolUse, PermissionRequest, PostToolUse, PostToolUseFailure, PostToolBatch, SubagentStart/Stop, TaskCreated, TaskCompleted), and Stop or StopFailure, followed by TeammateIdle, PreCompact, PostCompact, and SessionEnd, with Elicitation and ElicitationResult nested inside MCP tool execution, PermissionDenied as a side branch from PermissionRequest for auto-mode denials, and WorktreeCreate, WorktreeRemove, Notification, ConfigChange, InstructionsLoaded, CwdChanged, and FileChanged as standalone async events](https://mintcdn.com/claude-code/_SQ1BnFTP0QUrae-/images/hooks-lifecycle.svg?w=1100&fit=max&auto=format&n=_SQ1BnFTP0QUrae-&q=85&s=f4db868c79fc1abd8a6706162f9fd69b)

![Hook resolution flow: PreToolUse event fires, matcher checks for Bash match, if condition checks for Bash(rm *) match, hook handler runs, result returns to Claude Code](https://mintcdn.com/claude-code/-tYw1BD_DEqfyyOZ/images/hook-resolution.svg?w=1100&fit=max&auto=format&n=-tYw1BD_DEqfyyOZ&q=85&s=b36199aacf96f29991228cf68b7f0e3a)