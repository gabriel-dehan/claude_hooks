# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  class Elicitation < Base
    def self.hook_type
      'Elicitation'
    end

    def self.input_fields
      %w[mcp_server_name message]
    end

    def mcp_server_name
      @input_data['mcp_server_name'] || @input_data['mcpServerName']
    end

    def message
      @input_data['message']
    end

    def mode
      @input_data['mode']
    end

    def url
      @input_data['url']
    end

    def elicitation_id
      @input_data['elicitation_id'] || @input_data['elicitationId']
    end

    def requested_schema
      @input_data['requested_schema'] || @input_data['requestedSchema']
    end

    def accept!(content = {})
      @output_data['hookSpecificOutput'] = {
        'hookEventName' => hook_event_name,
        'action' => 'accept',
        'content' => content
      }
    end

    def decline!
      @output_data['hookSpecificOutput'] = {
        'hookEventName' => hook_event_name,
        'action' => 'decline'
      }
    end

    def cancel!
      @output_data['hookSpecificOutput'] = {
        'hookEventName' => hook_event_name,
        'action' => 'cancel'
      }
    end
  end
end
