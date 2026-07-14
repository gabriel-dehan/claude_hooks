# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  module Output
    class PermissionDenied < Base
      def retry?
        hook_specific_output['retry'] == true
      end

      # Exit code is ignored by Claude Code for PermissionDenied.
      def exit_code
        0
      end

      def output_stream
        :stdout
      end

      def self.merge(*outputs)
        compacted_outputs = outputs.compact
        return compacted_outputs.first if compacted_outputs.length == 1
        return super(*outputs) if compacted_outputs.empty?

        merged = super(*outputs)
        merged_data = merged.data

        # If any hook says retry, retry
        should_retry = compacted_outputs.any? do |output|
          output_data = output.respond_to?(:data) ? output.data : output
          output_data.dig('hookSpecificOutput', 'retry') == true
        end

        merged_data['hookSpecificOutput'] ||= { 'hookEventName' => 'PermissionDenied' }
        merged_data['hookSpecificOutput']['retry'] = should_retry

        new(merged_data)
      end
    end
  end
end
