# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  class PreToolUse < Base
    def self.hook_type
      'PreToolUse'
    end

    def self.input_fields
      %w[tool_name tool_input tool_use_id]
    end

    # === INPUT DATA ACCESS ===

    def tool_name
      @input_data['tool_name']
    end

    def tool_input
      @input_data['tool_input']
    end

    def tool_use_id
      @input_data['tool_use_id'] || @input_data['toolUseId']
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

    def update_tool_input!(updated_input)
      @output_data['hookSpecificOutput'] ||= {
        'hookEventName' => hook_event_name,
        'permissionDecision' => 'allow'
      }
      @output_data['hookSpecificOutput']['updatedInput'] = updated_input
      @output_data['hookSpecificOutput']['permissionDecision'] = 'allow'
    end

    def defer_permission!
      @output_data['hookSpecificOutput'] = {
        'hookEventName' => hook_event_name,
        'permissionDecision' => 'defer'
      }
    end

    def update_input!(updated_input)
      @output_data['hookSpecificOutput'] ||= {
        'hookEventName' => hook_event_name,
        'permissionDecision' => 'allow'
      }
      @output_data['hookSpecificOutput']['updatedInput'] = updated_input
    end

    def add_additional_context!(context)
      @output_data['hookSpecificOutput'] ||= { 'hookEventName' => hook_event_name }
      @output_data['hookSpecificOutput']['additionalContext'] = context
    end
  end
end