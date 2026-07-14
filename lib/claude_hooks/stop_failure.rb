# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  class StopFailure < Base
    def self.hook_type
      'StopFailure'
    end

    def self.input_fields
      %w[error]
    end

    def error
      @input_data['error']
    end

    def error_details
      @input_data['error_details'] || @input_data['errorDetails']
    end

    def last_assistant_message
      @input_data['last_assistant_message'] || @input_data['lastAssistantMessage']
    end
  end
end
