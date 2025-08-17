# frozen_string_literal: true

require_relative "claude_hooks/version"
require_relative "claude_hooks/configuration"
require_relative "claude_hooks/logger"
require_relative "claude_hooks/base"
require_relative "claude_hooks/user_prompt_submit"
require_relative "claude_hooks/pre_tool_use"
require_relative "claude_hooks/post_tool_use"
require_relative "claude_hooks/notification"
require_relative "claude_hooks/stop"
require_relative "claude_hooks/subagent_stop"
require_relative "claude_hooks/pre_compact"
require_relative "claude_hooks/session_start"

module ClaudeHooks
  class Error < StandardError; end
end