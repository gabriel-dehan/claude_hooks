# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  class PostToolBatch < Base
    def self.hook_type
      'PostToolBatch'
    end

    def self.input_fields
      %w[tool_calls]
    end

    def tool_calls
      @input_data['tool_calls'] || @input_data['toolCalls'] || []
    end

    # Convenience partitions over tool_calls. Entries carry a `tool_response`
    # rather than an explicit success flag, so success is derived from the
    # presence of a response that isn't flagged as an error. When your payload
    # shape differs, use the raw `tool_calls` array instead.
    def succeeded_calls
      tool_calls.reject { |call| failed_call?(call) }
    end

    def failed_calls
      tool_calls.select { |call| failed_call?(call) }
    end

    def block!(reason = '')
      @output_data['decision'] = 'block'
      @output_data['reason'] = reason
    end

    def add_additional_context!(context)
      @output_data['hookSpecificOutput'] ||= { 'hookEventName' => hook_event_name }
      @output_data['hookSpecificOutput']['additionalContext'] = context
    end

    private

    # A call is considered failed when its response is missing or carries an
    # error marker (`is_error`/`isError` true, or an `error` key).
    def failed_call?(call)
      return true unless call.is_a?(Hash)

      response = call['tool_response'] || call['toolResponse']
      return true if response.nil?

      if response.is_a?(Hash)
        return true if response['is_error'] == true || response['isError'] == true
        return true if response.key?('error') && !response['error'].nil?
      end

      false
    end
  end
end
