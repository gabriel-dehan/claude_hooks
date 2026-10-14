# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  class TaskCreated < Base
    def self.hook_type
      'TaskCreated'
    end

    def self.input_fields
      %w[task_id task_subject]
    end

    def task_id
      @input_data['task_id'] || @input_data['taskId']
    end

    def task_subject
      @input_data['task_subject'] || @input_data['taskSubject']
    end

    def task_description
      @input_data['task_description'] || @input_data['taskDescription']
    end

    def teammate_name
      @input_data['teammate_name'] || @input_data['teammateName']
    end

    def team_name
      @input_data['team_name'] || @input_data['teamName']
    end

    # === OUTPUT DATA HELPERS ===
    #
    # Claude Code ignores `continue: false` for TaskCreated. Block task creation
    # either by exiting 2 or with a top-level decision:block; `reason` is returned
    # to Claude as the task-creation error.

    def block!(reason = '')
      @output_data['decision'] = 'block'
      @output_data['reason'] = reason
    end

    def allow!
      @output_data['decision'] = nil
      @output_data['reason'] = nil
    end
    alias_method :unblock!, :allow!
  end
end
