# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  # MessageDisplay runs while assistant message text is displayed on screen.
  # Display-only: exit code and decision fields are ignored. The only effect is
  # replacing the on-screen text via hookSpecificOutput.displayContent — the
  # transcript and what Claude sees keep the original text.
  class MessageDisplay < Base
    def self.hook_type
      'MessageDisplay'
    end

    def self.input_fields
      %w[turn_id message_id index final delta]
    end

    # === INPUT DATA ACCESS ===

    def turn_id
      @input_data['turn_id'] || @input_data['turnId']
    end

    def message_id
      @input_data['message_id'] || @input_data['messageId']
    end

    def index
      @input_data['index']
    end

    def final
      @input_data.key?('final') ? @input_data['final'] : @input_data['isFinal']
    end
    alias_method :final?, :final

    # The streamed assistant text delta for this event.
    def delta
      @input_data['delta']
    end

    # Some payloads expose the full text so far; kept as a convenience reader.
    def message_text
      @input_data['message_text'] || @input_data['messageText']
    end

    # === OUTPUT DATA HELPERS ===

    # Replace the text shown on screen (display-only).
    def display_content!(content)
      @output_data['hookSpecificOutput'] = {
        'hookEventName' => hook_event_name,
        'displayContent' => content
      }
    end
  end
end
