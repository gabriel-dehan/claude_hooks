#!/usr/bin/env ruby

require 'claude_hooks'

class CleanupHandler < ClaudeHooks::SessionEnd
  def call
    log "Session ended with reason: #{reason}"
    
    case reason
    when 'clear'
      log "Performing cleanup after /clear command"
      add_cleanup_message!("Session cleared - temporary files cleaned up")
      cleanup_temp_files
    when 'logout'
      log "Performing cleanup after logout"
      add_cleanup_message!("User logged out - session state saved")
      save_session_state
    when 'prompt_input_exit'
      log "User exited during prompt input"
      add_cleanup_message!("Prompt input interrupted - partial state saved")
      save_partial_state
    else
      log "General session cleanup"
      add_cleanup_message!("Session ended normally - basic cleanup performed")
      general_cleanup
    end
    
    output
  end

  private

  def cleanup_temp_files
    log "Cleaning up temporary files for session #{session_id}"
    # Example cleanup logic
  end

  def save_session_state
    log "Saving session state for session #{session_id}"
    # Example state saving logic
  end

  def save_partial_state
    log "Saving partial state for session #{session_id}"
    # Example partial state saving logic
  end

  def general_cleanup
    log "Performing general cleanup for session #{session_id}"
    # Example general cleanup logic
  end
end

# CLI testing support
if __FILE__ == $0
  ClaudeHooks::CLI.test_runner(CleanupHandler) do |input_data|
    input_data['reason'] ||= 'other'
  end
end