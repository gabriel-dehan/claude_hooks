# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  module Output
    class PreModelSwitch < Base
      # === PERMISSION DECISION ACCESSORS ===

      def permission_decision
        hook_specific_output['permissionDecision']
      end

      def permission_reason
        hook_specific_output['permissionDecisionReason'] || ''
      end

      # === TOP-LEVEL DECISION ACCESSORS ===

      def decision
        @data['decision']
      end

      def reason
        @data['reason'] || ''
      end

      # === SEMANTIC HELPERS ===

      def allowed?
        permission_decision == 'allow'
      end

      def denied?
        permission_decision == 'deny'
      end

      # Blocked when denied via permissionDecision OR via top-level decision:block.
      def blocked?
        denied? || decision == 'block'
      end

      def should_ask?
        permission_decision == 'ask'
      end
      alias should_ask_permission? should_ask?

      # === EXIT CODE LOGIC ===
      #
      # PreModelSwitch uses the advanced JSON API with exit code 0.
      # As on PreToolUse, structured JSON with permissionDecision always goes to
      # stdout with exit 0; the decision fields control whether the switch proceeds.
      def exit_code
        0
      end

      def output_stream
        :stdout
      end

      # === MERGE HELPER ===

      def self.merge(*outputs)
        compacted_outputs = outputs.compact
        return compacted_outputs.first if compacted_outputs.length == 1
        return super(*outputs) if compacted_outputs.empty?

        merged = super(*outputs)
        merged_data = merged.data

        # PreModelSwitch precedence: deny > ask > allow (most restrictive wins).
        permission_decision = 'allow'
        permission_reasons = []
        block_reasons = []
        any_block = false

        compacted_outputs.each do |output|
          output_data = output.respond_to?(:data) ? output.data : output

          if output_data['decision'] == 'block'
            any_block = true
            block_reasons << output_data['reason'] if output_data['reason'] && !output_data['reason'].empty?
          end

          current_decision = output_data.dig('hookSpecificOutput', 'permissionDecision')
          case current_decision
          when 'deny'
            permission_decision = 'deny'
          when 'ask'
            permission_decision = 'ask' unless permission_decision == 'deny'
          end

          reason = output_data.dig('hookSpecificOutput', 'permissionDecisionReason')
          permission_reasons << reason if reason && !reason.empty?
        end

        merged_data['hookSpecificOutput'] ||= { 'hookEventName' => 'PreModelSwitch' }
        merged_data['hookSpecificOutput']['permissionDecision'] = permission_decision
        merged_data['hookSpecificOutput']['permissionDecisionReason'] = permission_reasons.any? ? permission_reasons.join('; ') : ''

        if any_block
          merged_data['decision'] = 'block'
          merged_data['reason'] = block_reasons.join('; ') unless block_reasons.empty?
        end

        new(merged_data)
      end
    end
  end
end
