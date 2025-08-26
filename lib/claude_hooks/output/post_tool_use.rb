# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  module Output
    class PostToolUse < Base
      # === DECISION ACCESSORS ===

      def decision
        @data['decision']
      end

      def reason
        @data['reason'] || ''
      end

      # === SEMANTIC HELPERS ===

      def blocked?
        decision == 'block'
      end

      # === EXIT CODE LOGIC ===

      def exit_code
        return 1 unless continue?
        return 1 if blocked?

        0
      end

      # === MERGE HELPER ===

      def self.merge(*outputs)
        merged = super(*outputs)
        merged_data = merged.data

        outputs.each do |output|
          output_data = output.respond_to?(:data) ? output.data : output
          merged_data['decision'] = 'block' if output_data['decision'] == 'block'
          merged_data['reason'] = [merged_data['reason'], output['reason']].compact.reject(&:empty?).join('; ')
        end

        new(merged_data)
      end
    end
  end
end