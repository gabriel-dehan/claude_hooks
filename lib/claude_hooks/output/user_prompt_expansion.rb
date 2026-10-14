# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  module Output
    class UserPromptExpansion < Base
      def decision
        @data['decision']
      end

      def reason
        @data['reason'] || ''
      end

      def blocked?
        decision == 'block'
      end

      def additional_context
        hook_specific_output['additionalContext'] || ''
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
        reasons = []
        contexts = []

        compacted_outputs.each do |output|
          output_data = output.respond_to?(:data) ? output.data : output
          if output_data['decision'] == 'block'
            merged_data['decision'] = 'block'
            r = output_data['reason']
            reasons << r if r && !r.empty?
          end

          context = output_data.dig('hookSpecificOutput', 'additionalContext')
          contexts << context if context && !context.empty?
        end

        merged_data['reason'] = reasons.join('; ') if reasons.any?
        unless contexts.empty?
          merged_data['hookSpecificOutput'] = {
            'hookEventName' => 'UserPromptExpansion',
            'additionalContext' => contexts.join("\n\n")
          }
        end
        new(merged_data)
      end
    end
  end
end
