# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  class PreToolUse < Base
    def self.hook_type
      'PreToolUse'
    end

    def self.input_fields
      %w[tool_name tool_input]
    end

    # === INPUT DATA ACCESS ===

    def tool_name
      @input_data['tool_name']
    end

    def tool_input
      @input_data['tool_input']
    end

    # === OUTPUT DATA HELPERS ===

    def approve_tool!(reason = '')
      @output_data['hookSpecificOutput'] = {
        'hookEventName' => hook_event_name,
        'permissionDecision' => 'allow',
        'permissionDecisionReason' => reason
      }
    end

    def block_tool!(reason = '')
      @output_data['hookSpecificOutput'] = {
        'hookEventName' => hook_event_name,
        'permissionDecision' => 'deny',
        'permissionDecisionReason' => reason
      }
    end

    def ask_for_permission!(reason = '')
      @output_data['hookSpecificOutput'] = {
        'hookEventName' => hook_event_name,
        'permissionDecision' => 'ask',
        'permissionDecisionReason' => reason
      }
    end

    # === MERGE HELPER ===

    # Merge multiple PreToolUse hook results intelligently
    def self.merge_outputs(*outputs_data)
      merged = super(*outputs_data)

      # For PreToolUse: deny > ask > allow (most restrictive wins)
      permission_decision = 'allow'
      permission_reasons = []

      outputs_data.compact.each do |output|
        if output.dig('hookSpecificOutput', 'permissionDecision')
          current_decision = output['hookSpecificOutput']['permissionDecision']
          case current_decision
          when 'deny'
            permission_decision = 'deny'
          when 'ask'
            permission_decision = 'ask' unless permission_decision == 'deny'
          end

          if output['hookSpecificOutput']['permissionDecisionReason']
            permission_reasons << output['hookSpecificOutput']['permissionDecisionReason']
          end
        end
      end

      unless permission_reasons.empty?
        merged['hookSpecificOutput'] = {
          'hookEventName' => hook_type,
          'permissionDecision' => permission_decision,
          'permissionDecisionReason' => permission_reasons.join('; ')
        }
      end

      merged
    end
  end
end