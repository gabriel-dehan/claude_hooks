# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  module Output
    class UserPromptSubmit < Base
      # === DECISION ACCESSORS ===

      def decision
        @data['decision']
      end

      def reason
        @data['reason'] || ''
      end

      def additional_context
        hook_specific_output['additionalContext'] || ''
      end

      # === SEMANTIC HELPERS ===

      def blocked?
        decision == 'block'
      end

      # === EXIT CODE LOGIC ===

      def exit_code
        return 2 unless continue?
        return 2 if blocked?

        0
      end

      # === MERGE HELPER ===

      def self.merge(*outputs)
        compacted_outputs = outputs.compact
        return compacted_outputs.first if compacted_outputs.length == 1
        return super(*outputs) if compacted_outputs.empty?
        
        merged = super(*outputs)
        merged_data = merged.data

        contexts = []
        reasons = []

        compacted_outputs.each do |output|
          output_data = output.respond_to?(:data) ? output.data : output

          merged_data['decision'] = 'block' if output_data['decision'] == 'block'
          merged_data['reason'] = [merged_data['reason'], output_data['reason']].compact.reject(&:empty?).join('; ')

          context = output_data.dig('hookSpecificOutput', 'additionalContext')
          contexts << context if context && !context.empty?
        end

        unless contexts.empty?
          merged_data['hookSpecificOutput'] = {
            'hookEventName' => 'UserPromptSubmit',
            'additionalContext' => contexts.join("\n\n")
          }
        end

        new(merged_data)
      end
    end
  end
end