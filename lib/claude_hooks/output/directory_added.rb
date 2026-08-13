# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  module Output
    # DirectoryAdded is non-blocking — the directory is already added.
    # Only `systemMessage` is consumed (as Claude context for `slash_command`,
    # debug log for `register_repo_root`).
    class DirectoryAdded < Base
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
