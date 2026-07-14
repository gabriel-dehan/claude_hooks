# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  class UserPromptExpansion < Base
    def self.hook_type
      'UserPromptExpansion'
    end

    def self.input_fields
      %w[expansion_type command_name command_args command_source prompt]
    end

    def expansion_type
      @input_data['expansion_type'] || @input_data['expansionType']
    end

    def command_name
      @input_data['command_name'] || @input_data['commandName']
    end

    def command_args
      @input_data['command_args'] || @input_data['commandArgs']
    end

    def command_source
      @input_data['command_source'] || @input_data['commandSource']
    end

    def prompt
      @input_data['prompt']
    end

    def block!(reason = '')
      @output_data['decision'] = 'block'
      @output_data['reason'] = reason
    end

    def add_additional_context!(context)
      @output_data['hookSpecificOutput'] ||= { 'hookEventName' => hook_event_name }
      @output_data['hookSpecificOutput']['additionalContext'] = context
    end
  end
end
