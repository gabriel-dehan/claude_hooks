# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  module Output
    # MessageDisplay is display-only — exit code and decision fields are ignored.
    # Only hookSpecificOutput.displayContent has an effect (replaces on-screen text).
    class MessageDisplay < Base
      def display_content
        hook_specific_output['displayContent']
      end

      def exit_code
        0
      end

      def output_stream
        :stdout
      end

      # Last non-nil displayContent wins.
      def self.merge(*outputs)
        compacted_outputs = outputs.compact
        return compacted_outputs.first if compacted_outputs.length == 1
        return super(*outputs) if compacted_outputs.empty?

        merged = super(*outputs)
        merged_data = merged.data
        last_content = nil

        compacted_outputs.each do |output|
          output_data = output.respond_to?(:data) ? output.data : output
          content = output_data.dig('hookSpecificOutput', 'displayContent')
          last_content = content unless content.nil?
        end

        unless last_content.nil?
          merged_data['hookSpecificOutput'] = {
            'hookEventName' => 'MessageDisplay',
            'displayContent' => last_content
          }
        end

        new(merged_data)
      end
    end
  end
end
