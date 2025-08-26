#!/usr/bin/env ruby

# Example of the NEW simplified entrypoint pattern using output objects
# Compare this to the existing user_prompt_submit.rb to see the difference!

require 'claude_hooks'
require 'json'
# Require the output classes
require_relative '../../../lib/claude_hooks/output/base'
require_relative '../../../lib/claude_hooks/output/user_prompt_submit'
require_relative '../handlers/user_prompt_submit/append_rules'
require_relative '../handlers/user_prompt_submit/log_user_prompt'

begin
  # Read input from stdin
  input_data = JSON.parse(STDIN.read)

  # Execute all hook scripts
  append_rules = AppendRules.new(input_data)
  append_rules.call

  log_user_prompt = LogUserPrompt.new(input_data)
  log_user_prompt.call

  # NEW: Use the output objects for intelligent merging and execution
  merged_output = ClaudeHooks::Output::UserPromptSubmit.merge(
    append_rules.output,
    log_user_prompt.output
  )

  # NEW: Let the output object handle all the exit logic!
  merged_output.exit_with_output  # This handles JSON output, streams, and exit codes automatically

rescue JSON::ParserError => e
  # Error handling becomes simpler too
  error_output = ClaudeHooks::Output::UserPromptSubmit.new({
    'continue' => false,
    'stopReason' => "JSON parsing error: #{e.message}",
    'suppressOutput' => false
  })
  error_output.exit_with_output  # Automatically uses STDERR and exit 1

rescue StandardError => e
  # Same simple error pattern
  error_output = ClaudeHooks::Output::UserPromptSubmit.new({
    'continue' => false,
    'stopReason' => "Hook execution error: #{e.message} #{e.backtrace.join("\n")}",
    'suppressOutput' => false
  })
  error_output.exit_with_output  # Automatically uses STDERR and exit 1
end

# No need for manual exit codes, stream selection, or JSON generation!
# The output object handles everything based on the hook type's semantics.