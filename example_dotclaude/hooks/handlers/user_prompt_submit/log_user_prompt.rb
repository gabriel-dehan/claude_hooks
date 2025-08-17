#!/usr/bin/env ruby

require 'fileutils'
require 'claude_hooks'

# Example hook module that logs user prompts to a file
class LogUserPrompt < ClaudeHooks::UserPromptSubmit

  def call
    log "Executing LogUserPrompt hook"

    # Log the prompt to a file (just as an example)
    log_file_path = path_for('logs/user_prompts.log')
    ensure_log_directory_exists

    timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')

    log <<~TEXT
      Prompt: #{current_prompt}
      Logged user prompt to #{log_file_path}
    TEXT

    nil
  end

  private

  def ensure_log_directory_exists
    log_dir = path_for('logs')
    FileUtils.mkdir_p(log_dir) unless Dir.exist?(log_dir)
  end
end

# If this file is run directly (for testing), call the hook
if __FILE__ == $0
  ClaudeHooks::CLI.test_runner(LogUserPrompt)
end
