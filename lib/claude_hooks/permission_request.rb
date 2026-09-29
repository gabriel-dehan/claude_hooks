# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  class PermissionRequest < Base
    def self.hook_type
      'PermissionRequest'
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

    # For MCP tools: { 'name' => ..., 'source' => ... } describing where the server's
    # definition came from (e.g. 'plugin', 'sdk', 'user', 'project'). Base trust
    # decisions on 'source', not on the name. nil for non-MCP tools. Requires Claude Code v2.1.274+.
    def mcp_server
      @input_data['mcp_server'] || @input_data['mcpServer']
    end

    def permission_suggestions
      @input_data['permissionSuggestions'] || @input_data['permission_suggestions'] || []
    end

    # === OUTPUT DATA HELPERS ===

    def allow_permission!(reason = '')
      @output_data['hookSpecificOutput'] = {
        'hookEventName' => hook_event_name,
        'decision' => { 'behavior' => 'allow' }
      }
      @output_data['hookSpecificOutput']['decision']['message'] = reason unless reason.empty?
    end

    def deny_permission!(reason = '', interrupt: nil)
      decision = { 'behavior' => 'deny' }
      decision['message'] = reason unless reason.empty?
      decision['interrupt'] = interrupt unless interrupt.nil?
      @output_data['hookSpecificOutput'] = {
        'hookEventName' => hook_event_name,
        'decision' => decision
      }
    end

    def update_input_and_allow!(updated_input, reason = '', updated_permissions: nil)
      decision = { 'behavior' => 'allow', 'updatedInput' => updated_input }
      decision['message'] = reason unless reason.empty?
      decision['updatedPermissions'] = updated_permissions unless updated_permissions.nil?
      @output_data['hookSpecificOutput'] = {
        'hookEventName' => hook_event_name,
        'decision' => decision
      }
    end
  end
end
