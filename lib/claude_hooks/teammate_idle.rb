# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  class TeammateIdle < Base
    def self.hook_type
      'TeammateIdle'
    end

    def self.input_fields
      %w[teammate_name team_name]
    end

    def teammate_name
      @input_data['teammate_name'] || @input_data['teammateName']
    end

    def team_name
      @input_data['team_name'] || @input_data['teamName']
    end
  end
end
