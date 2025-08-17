# Why is this DSL useful?

When creating fairly complex hook systems for Claude Code it is easy to end up either with:
- Fairly monolithic scripts that becomes hard to maintain and have to handle complex merging logic for the output.
- A lot of scripts set up in the `settings.json` that all use the same hook input / output logic that needs to be rewritten multiple times.

This DSL enables the creation of composable, testable scripts that can be easily maintained and reused.
It is suited for both a monolithic approach or a modular one.

```bash
# Monolithic approach
settings.json
└── [On PreToolUse Hook] -> pre_tool_use.rb
    ├── danger_check.rb
    ├── audit_logger.rb
    └── permission_guard.rb

# Modular approach
settings.json
├── [On PreToolUse Hook] -> danger_check.rb
├── [On PreToolUse Hook] -> audit_logger.rb
└── [On PreToolUse Hook] -> permission_guard.rb
```

## For both approaches it will bring

1. Normalized Input/Output handling - Automatic JSON parsing, validation, and structured output helpers (block_tool!, add_context!).

2. Hook-Specific APIs - 8 different hook types with tailored methods (e.g., ask_for_permission! vs block_tool!) and smart merge logic for combining outputs.

3. Session-Based Logging - Dedicated logger to understand the flow of what happens in Claude Code and write it out to a `session-{session_id}.log` file.

4. Configuration Management - Centralized config and helpers for use across the hook system.

5. Testing Support - Standalone execution mode for individual hook testing and CLI testing with sample JSON input.


## For a monolithic approach it will additionally bring

1. Composable Hook Scripts
For instance, `user_prompt_submit.rb` orchestrates multiple concerns in one place:
```ruby
# Add contextual rules
append_rules_result = AppendRules.new(input_data).call
# Audit logging
log_result = LogUserPrompt.new(input_data).call

# Merge outputs to Claude Code
puts UserPromptSubmitHook.merge_outputs(append_rules_result, log_result)
```

2. Intelligent Output Merging
- Each hook script can return different decisions (block, context additions, etc.)
- The framework intelligently merges conflicting decisions (e.g., any script can block)
- Combines multiple contexts cleanly

3. Individual Script Testability
Each script can run standalone for testing:
```ruby
if __FILE__ == $0
  hook = AppendRules.new(JSON.parse(STDIN.read))
  puts hook.stringify_output
end
```
