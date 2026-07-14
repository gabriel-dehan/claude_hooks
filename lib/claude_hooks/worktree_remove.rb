# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  class WorktreeRemove < Base
    def self.hook_type
      'WorktreeRemove'
    end

    def self.input_fields
      %w[worktree_path]
    end

    def worktree_path
      @input_data['worktree_path'] || @input_data['worktreePath']
    end
  end
end
