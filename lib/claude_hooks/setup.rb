# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  class Setup < Base
    def self.hook_type
      'Setup'
    end

    def self.input_fields
      %w[source]
    end

    def source
      @input_data['source']
    end

    # DEPRECATED: Claude Code now discards all Setup JSON output, including
    # hookSpecificOutput.additionalContext. Kept for backward compatibility, but
    # this no longer adds context — use a SessionStart hook to inject context instead.
    def add_additional_context!(context)
      @output_data['hookSpecificOutput'] ||= { 'hookEventName' => hook_event_name }
      @output_data['hookSpecificOutput']['additionalContext'] = context
    end
    alias_method :add_context!, :add_additional_context!
  end
end
