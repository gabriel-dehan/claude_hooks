# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  module Output
    class PermissionRequest < Base
      # === PERMISSION DECISION ACCESSORS ===

      def behavior
        hook_specific_output.dig('decision', 'behavior')
      end

      # Read nested decision.behavior with flat legacy fallback
      def permission_decision
        behavior || hook_specific_output['permissionDecision']
      end

      # Read decision.message with legacy permissionDecisionReason fallback
      def permission_reason
        hook_specific_output.dig('decision', 'message') ||
          hook_specific_output['permissionDecisionReason'] || ''
      end

      # Read decision.updatedInput with flat legacy fallback
      def updated_input
        hook_specific_output.dig('decision', 'updatedInput') ||
          hook_specific_output['updatedInput']
      end

      def updated_permissions
        hook_specific_output.dig('decision', 'updatedPermissions')
      end

      def interrupt?
        hook_specific_output.dig('decision', 'interrupt') == true
      end

      # === SEMANTIC HELPERS ===

      def allowed?
        permission_decision == 'allow'
      end

      def denied?
        permission_decision == 'deny'
      end

      def input_updated?
        !updated_input.nil?
      end

      # === EXIT CODE LOGIC ===

      def exit_code
        0
      end

      # === OUTPUT STREAM LOGIC ===

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

        # deny > allow (most restrictive wins)
        behavior = 'allow'
        messages = []
        updated_inputs = []
        interrupt = false
        updated_permissions = nil

        compacted_outputs.each do |output|
          output_data = output.respond_to?(:data) ? output.data : output

          # Support both nested and legacy flat shapes
          current_behavior = output_data.dig('hookSpecificOutput', 'decision', 'behavior') ||
                             output_data.dig('hookSpecificOutput', 'permissionDecision')
          next unless current_behavior

          behavior = 'deny' if current_behavior == 'deny'

          msg = output_data.dig('hookSpecificOutput', 'decision', 'message') ||
                output_data.dig('hookSpecificOutput', 'permissionDecisionReason')
          messages << msg if msg && !msg.empty?

          updated = output_data.dig('hookSpecificOutput', 'decision', 'updatedInput') ||
                    output_data.dig('hookSpecificOutput', 'updatedInput')
          updated_inputs << updated if updated

          # Propagate interrupt (OR logic — if any output has it, merged should too)
          interrupt = true if output_data.dig('hookSpecificOutput', 'decision', 'interrupt') == true

          # Propagate updatedPermissions (last writer wins)
          perms = output_data.dig('hookSpecificOutput', 'decision', 'updatedPermissions')
          updated_permissions = perms unless perms.nil?
        end

        merged_data['hookSpecificOutput'] ||= { 'hookEventName' => 'PermissionRequest' }
        decision = { 'behavior' => behavior }
        decision['message'] = messages.join('; ') if messages.any?
        decision['updatedInput'] = updated_inputs.last if updated_inputs.any?
        decision['interrupt'] = interrupt
        decision['updatedPermissions'] = updated_permissions unless updated_permissions.nil?
        merged_data['hookSpecificOutput']['decision'] = decision

        new(merged_data)
      end
    end
  end
end
