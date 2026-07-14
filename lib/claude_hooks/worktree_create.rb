# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  class WorktreeCreate < Base
    def self.hook_type
      'WorktreeCreate'
    end

    def self.input_fields
      %w[name]
    end

    def name
      @input_data['name']
    end

    # Emit the worktree path as bare stdout (last non-empty line).
    # Also sets hookSpecificOutput.worktreePath for programmatic access.
    def worktree_path!(path)
      @output_data['_worktree_path'] = path
      @output_data['hookSpecificOutput'] ||= { 'hookEventName' => hook_event_name }
      @output_data['hookSpecificOutput']['worktreePath'] = path
    end
  end
end
