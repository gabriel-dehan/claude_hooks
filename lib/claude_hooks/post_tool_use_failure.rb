# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  class PostToolUseFailure < Base
    def self.hook_type
      'PostToolUseFailure'
    end

    def self.input_fields
      %w[tool_name tool_input tool_use_id error]
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

    def error
      @input_data['error']
    end

    def is_interrupt
      @input_data.key?('is_interrupt') ? @input_data['is_interrupt'] : @input_data['isInterrupt']
    end
    alias_method :interrupt?, :is_interrupt

    def duration_ms
      @input_data['duration_ms'] || @input_data['durationMs']
    end

    def add_additional_context!(context)
      @output_data['hookSpecificOutput'] ||= { 'hookEventName' => hook_event_name }
      @output_data['hookSpecificOutput']['additionalContext'] = context
    end
  end
end
