# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  class ConfigChange < Base
    def self.hook_type
      'ConfigChange'
    end

    def self.input_fields
      %w[source]
    end

    def source
      @input_data['source']
    end

    def file_path
      @input_data['file_path'] || @input_data['filePath']
    end

    def block!(reason = '')
      @output_data['decision'] = 'block'
      @output_data['reason'] = reason
    end
  end
end
