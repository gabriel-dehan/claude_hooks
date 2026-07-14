# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  module Output
    # InstructionsLoaded is non-blocking — exit code is ignored by Claude Code.
    class InstructionsLoaded < Base
      def exit_code
        0
      end

      def self.merge(*outputs)
        merged = super(*outputs)
        new(merged.data)
      end
    end
  end
end
