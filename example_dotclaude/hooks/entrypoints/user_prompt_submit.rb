#!/usr/bin/env ruby

require 'claude_hooks'
require_relative '../handlers/user_prompt_submit/append_rules'
require_relative '../handlers/user_prompt_submit/log_user_prompt'

ClaudeHooks::CLI.run_hook do |input_data|
  append_rules = AppendRules.new(input_data)
  append_rules.call

  log_user_prompt = LogUserPrompt.new(input_data)
  log_user_prompt.call

  ClaudeHooks::Output::UserPromptSubmit.merge(
    append_rules.output,
    log_user_prompt.output
  ).output_and_exit
end
