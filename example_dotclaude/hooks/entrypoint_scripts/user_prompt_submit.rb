#!/usr/bin/env ruby

require 'json'
require 'claude_hooks'
require_relative 'examples/user_prompt_submit_scripts/append_rules'
require_relative 'examples/user_prompt_submit_scripts/log_user_prompt'

begin
  # Read input from stdin
  input_data = JSON.parse(STDIN.read)

  # Execute all hook scripts
  append_rules = AppendRules.new(input_data)
  appended_rules_result = append_rules.call

  log_user_prompt = LogUserPrompt.new(input_data)
  log_user_prompt_result = log_user_prompt.call

  # Merge all hook results intelligently using the UserPromptSubmit class method
  hook_output = ClaudeHooks::UserPromptSubmit.merge_outputs(appended_rules_result, log_user_prompt_result)

  # Output final merged result to Claude Code
  puts JSON.generate(hook_output)

  exit 0
rescue JSON::ParserError => e
  STDERR.puts "Error parsing JSON: #{e.message}"

  puts JSON.generate({
    continue: false,
    stopReason: "Hook JSON parsing error: #{e.message}",
    suppressOutput: false
  })
  exit 1
rescue StandardError => e
  STDERR.puts "Error in UserPromptSubmit hook: #{e.message} #{e.backtrace.join("\n")}"

  puts JSON.generate({
    continue: false,
    stopReason: "Hook execution error: #{e.message} #{e.backtrace.join("\n")}",
    suppressOutput: false
  })
  exit 1
end
