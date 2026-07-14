# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  module Output
    class CwdChanged < Base
      def watch_paths
        hook_specific_output['watchPaths'] || []
      end

      def exit_code
        default_exit_code
      end

      def self.merge(*outputs)
        compacted_outputs = outputs.compact
        return compacted_outputs.first if compacted_outputs.length == 1
        return super(*outputs) if compacted_outputs.empty?

        merged = super(*outputs)
        merged_data = merged.data
        all_paths = []

        compacted_outputs.each do |output|
          output_data = output.respond_to?(:data) ? output.data : output
          paths = output_data.dig('hookSpecificOutput', 'watchPaths')
          all_paths.concat(paths) if paths&.any?
        end

        unless all_paths.empty?
          merged_data['hookSpecificOutput'] = {
            'hookEventName' => 'CwdChanged',
            'watchPaths' => all_paths.uniq
          }
        end

        new(merged_data)
      end
    end
  end
end
