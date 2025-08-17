# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  class PostToolUse < Base
    def self.hook_type
      'PostToolUse'
    end

    def self.input_fields
      %w[tool_name tool_input tool_response]
    end

    # === INPUT DATA ACCESS ===

    def tool_name
      @input_data['tool_name']
    end

    def tool_input
      @input_data['tool_input']
    end

    def tool_response
      @input_data['tool_response']
    end

    # === OUTPUT DATA HELPERS ===

    def block_tool!(reason = '')
      @output_data['decision'] = 'block'
      @output_data['reason'] = reason
    end

    def approve_tool!(reason = '')
      @output_data['decision'] = nil
      @output_data['reason'] = nil
    end

    # === MERGE HELPER ===

    # Merge multiple PostToolUse hook results intelligently
    def self.merge_outputs(*outputs_data)
      merged = super(*outputs_data)

      outputs_data.compact.each do |output|
        merged['decision'] = 'block' if output['decision'] == 'block'
        merged['reason'] = [merged['reason'], output['reason']].compact.reject(&:empty?).join('; ')
      end

      merged
    end
  end
end