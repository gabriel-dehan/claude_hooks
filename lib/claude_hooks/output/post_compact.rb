# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  module Output
    class PostCompact < Base
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
