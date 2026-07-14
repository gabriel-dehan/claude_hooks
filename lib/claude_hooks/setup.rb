# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  class Setup < Base
    def self.hook_type
      'Setup'
    end

    def self.input_fields
      %w[source]
    end

    def source
      @input_data['source']
    end

    def add_additional_context!(context)
      @output_data['hookSpecificOutput'] ||= { 'hookEventName' => hook_event_name }
      @output_data['hookSpecificOutput']['additionalContext'] = context
    end
    alias_method :add_context!, :add_additional_context!
  end
end
