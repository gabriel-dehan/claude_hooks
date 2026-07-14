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

    def model
      @input_data['model']
    end

    def session_title
      @input_data['session_title'] || @input_data['sessionTitle']
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

    def session_title!(title)
      @output_data['hookSpecificOutput'] ||= { 'hookEventName' => hook_event_name }
      @output_data['hookSpecificOutput']['sessionTitle'] = title
    end

    def initial_user_message!(message)
      @output_data['hookSpecificOutput'] ||= { 'hookEventName' => hook_event_name }
      @output_data['hookSpecificOutput']['initialUserMessage'] = message
    end

    def watch_paths!(paths)
      @output_data['hookSpecificOutput'] ||= { 'hookEventName' => hook_event_name }
      @output_data['hookSpecificOutput']['watchPaths'] = Array(paths)
    end

    def reload_skills!(value = true)
      @output_data['hookSpecificOutput'] ||= { 'hookEventName' => hook_event_name }
      @output_data['hookSpecificOutput']['reloadSkills'] = value
    end
  end
end