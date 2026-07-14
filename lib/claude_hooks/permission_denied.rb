# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  class PermissionDenied < Base
    def self.hook_type
      'PermissionDenied'
    end

    def self.input_fields
      %w[tool_name tool_input tool_use_id reason]
    end

    def tool_name
      @input_data['tool_name']
    end

    def tool_input
      @input_data['tool_input']
    end

    def tool_use_id
      @input_data['tool_use_id'] || @input_data['toolUseId']
    end

    def reason
      @input_data['reason']
    end

    def retry!
      @output_data['hookSpecificOutput'] ||= { 'hookEventName' => hook_event_name }
      @output_data['hookSpecificOutput']['retry'] = true
    end

    def no_retry!
      @output_data['hookSpecificOutput'] ||= { 'hookEventName' => hook_event_name }
      @output_data['hookSpecificOutput']['retry'] = false
    end
  end
end
