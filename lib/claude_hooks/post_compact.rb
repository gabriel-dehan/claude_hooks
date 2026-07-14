# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  class PostCompact < Base
    def self.hook_type
      'PostCompact'
    end

    def self.input_fields
      %w[trigger compact_summary]
    end

    def trigger
      @input_data['trigger']
    end

    def compact_summary
      @input_data['compact_summary'] || @input_data['compactSummary']
    end
  end
end
