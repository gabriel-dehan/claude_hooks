# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  class CwdChanged < Base
    def self.hook_type
      'CwdChanged'
    end

    def self.input_fields
      %w[old_cwd new_cwd]
    end

    def old_cwd
      @input_data['old_cwd'] || @input_data['oldCwd']
    end

    def new_cwd
      @input_data['new_cwd'] || @input_data['newCwd']
    end

    def watch_paths!(paths)
      @output_data['hookSpecificOutput'] ||= { 'hookEventName' => hook_event_name }
      @output_data['hookSpecificOutput']['watchPaths'] = Array(paths)
    end
  end
end
