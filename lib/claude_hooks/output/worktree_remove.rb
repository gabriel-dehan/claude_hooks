# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  module Output
    # WorktreeRemove is non-blocking — only suppressOutput is honored.
    class WorktreeRemove < Base
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
