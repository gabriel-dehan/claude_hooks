# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  module Output
    class Elicitation < Base
      def action
        hook_specific_output['action']
      end

      def content
        hook_specific_output['content'] || {}
      end

      def accepted?
        action == 'accept'
      end

      def declined?
        action == 'decline'
      end

      def cancelled?
        action == 'cancel'
      end

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

        # Last non-nil action wins
        merged = super(*outputs)
        merged_data = merged.data
        last_action = nil
        last_content = nil

        compacted_outputs.each do |output|
          output_data = output.respond_to?(:data) ? output.data : output
          a = output_data.dig('hookSpecificOutput', 'action')
          next unless a
          last_action = a
          last_content = output_data.dig('hookSpecificOutput', 'content')
        end

        if last_action
          merged_data['hookSpecificOutput'] = {
            'hookEventName' => 'Elicitation',
            'action' => last_action
          }
          merged_data['hookSpecificOutput']['content'] = last_content if last_content
        end

        new(merged_data)
      end
    end
  end
end
