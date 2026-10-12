# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  class UserPromptSubmit < Base
    def self.hook_type
      'UserPromptSubmit'
    end

    def self.input_fields
      %w[prompt]
    end

    # === INPUT DATA ACCESS ===

    def prompt
      @input_data['user_prompt'] || @input_data['prompt']
    end
    alias_method :user_prompt, :prompt
    alias_method :current_prompt, :prompt

    # The session's custom title, when one is set. Requires Claude Code to send it
    # (same meaning as SessionStart's session_title).
    def session_title
      @input_data['session_title'] || @input_data['sessionTitle']
    end

    # === OUTPUT DATA HELPERS ===

    def add_additional_context!(context)
      @output_data['hookSpecificOutput'] ||= { 'hookEventName' => hook_event_name }
      @output_data['hookSpecificOutput']['additionalContext'] = context
    end
    alias_method :add_context!, :add_additional_context!

    def empty_additional_context!
      hso = @output_data['hookSpecificOutput']
      return unless hso

      hso.delete('additionalContext')
      @output_data['hookSpecificOutput'] = nil if hso.keys == ['hookEventName']
    end

    def session_title!(title)
      @output_data['hookSpecificOutput'] ||= { 'hookEventName' => hook_event_name }
      @output_data['hookSpecificOutput']['sessionTitle'] = title
    end

    # When the prompt is blocked (block_prompt! or exit 2), leave the prompt text out
    # of the block message shown to the user and written to the transcript. Doesn't
    # remove it from other local files such as prompt history.
    def suppress_original_prompt!(value = true)
      @output_data['hookSpecificOutput'] ||= { 'hookEventName' => hook_event_name }
      @output_data['hookSpecificOutput']['suppressOriginalPrompt'] = value
    end

    def block_prompt!(reason = '')
      @output_data['decision'] = 'block'
      @output_data['reason'] = reason
    end

    def unblock_prompt!
      @output_data['decision'] = nil
      @output_data['reason'] = nil
    end
  end
end