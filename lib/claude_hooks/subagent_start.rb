# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  class SubagentStart < Base
    def self.hook_type
      'SubagentStart'
    end

    def self.input_fields
      %w[agent_id agent_type]
    end

    # agent_id and agent_type readers come from Base (Part A)

    def add_additional_context!(context)
      @output_data['hookSpecificOutput'] ||= { 'hookEventName' => hook_event_name }
      @output_data['hookSpecificOutput']['additionalContext'] = context
    end
    alias_method :add_context!, :add_additional_context!
  end
end
