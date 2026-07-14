# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  module Output
    # StopFailure is purely a logging event — output/exit is ignored by Claude Code.
    class StopFailure < Base
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
