# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  class ElicitationResult < Base
    def self.hook_type
      'ElicitationResult'
    end

    def self.input_fields
      %w[mcp_server_name action]
    end

    def mcp_server_name
      @input_data['mcp_server_name'] || @input_data['mcpServerName']
    end

    def action
      @input_data['action']
    end

    def mode
      @input_data['mode']
    end

    def elicitation_id
      @input_data['elicitation_id'] || @input_data['elicitationId']
    end

    def content
      @input_data['content']
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
