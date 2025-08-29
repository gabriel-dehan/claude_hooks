#!/usr/bin/env ruby
# frozen_string_literal: true

require 'claude_hooks'
require_relative '../handlers/pre_tool_use/github_guard'

begin
  # Read Claude Code input from stdin
  input_data = JSON.parse($stdin.read)

  github_guard = GithubGuard.new(input_data)
  github_guard.call

  github_guard.output_and_exit
rescue StandardError => e
  puts JSON.generate(
    {
      continue: false,
      stopReason: "Error in PreToolUse hook, #{e.message}, #{e.backtrace.join("\n")}",
      suppressOutput: false,
    },
  )
  # Allow anyway, to not block developers if there is an issue with the hook
  exit 1
end
