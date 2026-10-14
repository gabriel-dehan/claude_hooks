# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  module Output
    class Notification < Base
      # === EXIT CODE LOGIC ===
      #
      # Claude Code ignores Notification's exit code and stderr, and discards
      # `systemMessage`/`continue`, while still emitting `terminalSequence`.
      # So always exit 0 and write JSON to stdout, keeping the desktop-notification
      # (`terminal_sequence!`) pattern working even when a handler set continue:false.

      def exit_code
        0
      end

      def output_stream
        :stdout
      end

      # === MERGE HELPER ===
      
      def self.merge(*outputs)
        merged = super(*outputs)
        new(merged.data)
      end 
    end
  end
end