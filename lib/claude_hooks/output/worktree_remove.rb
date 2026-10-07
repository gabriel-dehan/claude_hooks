# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  module Output
    # WorktreeRemove can block: a non-zero exit code now fails the worktree
    # removal when the directory still exists (Claude Code no longer ignores it).
    # Use prevent_continue!(reason) to block; exit code follows continue (0/2).
    class WorktreeRemove < Base
      def exit_code
        default_exit_code
      end

      def self.merge(*outputs)
        merged = super(*outputs)
        new(merged.data)
      end
    end
  end
end
