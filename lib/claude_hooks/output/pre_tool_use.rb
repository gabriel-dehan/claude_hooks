# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  module Output
    class PreToolUse < Base
      # === PERMISSION DECISION ACCESSORS ===

      def permission_decision
        hook_specific_output['permissionDecision']
      end

      def permission_reason
        hook_specific_output['permissionDecisionReason'] || ''
      end

      # === SEMANTIC HELPERS ===

      def allowed?
        permission_decision == 'allow'
      end

      def denied?
        permission_decision == 'deny'
      end
      alias_method :blocked?, :denied?

      def should_ask_permission?
        permission_decision == 'ask'
      end

      # === EXIT CODE LOGIC ===

      # Priority: continue false > permission decision
      def exit_code
        # If continue is explicitly false, exit with error
        return 2 unless continue?

        # Otherwise, use permission decision
        case permission_decision
        when 'deny'
          2  # Block the tool
        when 'ask'
          0  # Ask for permission
        else 
          0  # Allow the tool
        end
      end

      # === MERGE HELPER ===

      def self.merge(*outputs)
        compacted_outputs = outputs.compact
        return compacted_outputs.first if compacted_outputs.length == 1
        return super(*outputs) if compacted_outputs.empty?
        
        merged = super(*outputs)
        merged_data = merged.data

        # PreToolUse specific merge: deny > ask > allow (most restrictive wins)
        permission_decision = 'allow'
        permission_reasons = []

        compacted_outputs.each do |output|
          output_data = output.respond_to?(:data) ? output.data : output
          
          if output_data.dig('hookSpecificOutput', 'permissionDecision')
            current_decision = output_data['hookSpecificOutput']['permissionDecision']
            case current_decision
            when 'deny'
              permission_decision = 'deny'
            when 'ask'
              permission_decision = 'ask' unless permission_decision == 'deny'
            end

            reason = output_data.dig('hookSpecificOutput', 'permissionDecisionReason')
            permission_reasons << reason if reason && !reason.empty?
          end
        end

        merged_data['hookSpecificOutput'] ||= { 'hookEventName' => 'PreToolUse' }
        merged_data['hookSpecificOutput']['permissionDecision'] = permission_decision
        if permission_reasons.any?
          merged_data['hookSpecificOutput']['permissionDecisionReason'] = permission_reasons.join('; ')
        else
          merged_data['hookSpecificOutput']['permissionDecisionReason'] = ''
        end

        new(merged_data)
      end
    end
  end
end