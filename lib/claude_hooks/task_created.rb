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
  end
end
