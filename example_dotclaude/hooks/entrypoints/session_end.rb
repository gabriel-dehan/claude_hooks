#!/usr/bin/env ruby

require 'claude_hooks'
require_relative '../handlers/session_end/cleanup_handler'
require_relative '../handlers/session_end/log_session_stats'

ClaudeHooks::CLI.run_hook do |input_data|
  cleanup_handler = CleanupHandler.new(input_data)
  log_handler = LogSessionStats.new(input_data)

  cleanup_handler.call
  log_handler.call

  ClaudeHooks::Output::SessionEnd.merge(
    cleanup_handler.output,
    log_handler.output
  ).output_and_exit
end
