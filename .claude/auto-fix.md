Context: This gem is a wrapper around Claude Code Hooks system, providing a Ruby DSL to define hooks. The github repository has an automated system through github actions that automatically (weekly) creates a diff of the last known state of Claude Code's hook documentation vs the current (online) Claude Code's hooks documentation. It then generates a diff between those and create an issue with the diff.

Intended goal: Take all those issues and all those diffs and evaluate if the gem / code needs to be updated to match the changes made by anthropic to their Claude Code Hooks system.

First step: Retrieve all the issues at: https://github.com/gabriel-dehan/claude_hooks/issues
And assess which issues may implement things that need to be changed (a lot of issues contain useless diff, with wording changes, link changes, etc that are not relevant).
Second step: Take those relevant issues and look at the diff, then compare it with the current codebase / readme / documentation to see if there is a mismatch Third step: Create a plan to tackle those changes
