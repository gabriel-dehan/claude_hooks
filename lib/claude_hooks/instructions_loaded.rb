# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  class InstructionsLoaded < Base
    def self.hook_type
      'InstructionsLoaded'
    end

    def self.input_fields
      %w[file_path load_reason]
    end

    def file_path
      @input_data['file_path'] || @input_data['filePath']
    end

    def load_reason
      @input_data['load_reason'] || @input_data['loadReason']
    end
  end
end
