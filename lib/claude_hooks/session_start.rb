# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  class SessionStart < Base
    def self.hook_type
      'SessionStart'
    end

    def self.input_fields
      %w[source]
    end

    # === INPUT DATA ACCESS ===

    def source
      @input_data['source']
    end

    # === OUTPUT DATA HELPERS ===

    def add_additional_context!(context)
      @output_data['hookSpecificOutput'] = {
        'hookEventName' => hook_event_name,
        'additionalContext' => context
      }
    end
    alias_method :add_context!, :add_additional_context!

    def empty_additional_context!
      @output_data['hookSpecificOutput'] = nil
    end

    # === MERGE HELPER ===

    # Merge multiple SessionStart hook results intelligently
    def self.merge_outputs(*outputs_data)
      merged = super(*outputs_data)
      contexts = []

      outputs_data.compact.each do |output|
        if output.dig('hookSpecificOutput', 'additionalContext')
          contexts << output['hookSpecificOutput']['additionalContext']
        end
      end

      unless contexts.empty?
        merged['hookSpecificOutput'] = {
          'hookEventName' => hook_type,
          'additionalContext' => contexts.join("\n\n")
        }
      end

      merged
    end
  end
end