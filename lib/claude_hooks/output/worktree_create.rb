# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  module Output
    # WorktreeCreate has a special bare-stdout contract:
    # the last non-empty stdout line is interpreted as the worktree path.
    # An empty/missing path causes Claude Code to treat creation as failed.
    class WorktreeCreate < Base
      def worktree_path
        @data['hookSpecificOutput']&.dig('worktreePath') || @data['_worktree_path']
      end

      def exit_code
        worktree_path && !worktree_path.empty? ? 0 : 1
      end

      def output_stream
        :stdout
      end

      # Overrides the default JSON output — prints the bare path instead.
      def output_and_exit
        path = worktree_path
        if path && !path.empty?
          $stdout.puts path
          exit 0
        else
          exit 1
        end
      end

      def self.merge(*outputs)
        compacted_outputs = outputs.compact
        return compacted_outputs.first if compacted_outputs.length == 1
        return super(*outputs) if compacted_outputs.empty?

        # Last set path wins
        merged = super(*outputs)
        merged_data = merged.data
        last_path = nil

        compacted_outputs.each do |output|
          output_data = output.respond_to?(:data) ? output.data : output
          p = output_data.dig('hookSpecificOutput', 'worktreePath') || output_data['_worktree_path']
          last_path = p if p && !p.empty?
        end

        if last_path
          merged_data['hookSpecificOutput'] ||= { 'hookEventName' => 'WorktreeCreate' }
          merged_data['hookSpecificOutput']['worktreePath'] = last_path
          merged_data['_worktree_path'] = last_path
        end

        new(merged_data)
      end
    end
  end
end
