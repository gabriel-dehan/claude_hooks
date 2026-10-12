# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  module Output
    class UserPromptSubmit < Base
      # === DECISION ACCESSORS ===

      def decision
        @data['decision']
      end

      def reason
        @data['reason'] || ''
      end

      def additional_context
        hook_specific_output['additionalContext'] || ''
      end

      def session_title
        hook_specific_output['sessionTitle']
      end

      def suppress_original_prompt?
        hook_specific_output['suppressOriginalPrompt'] == true
      end

      # === SEMANTIC HELPERS ===

      def blocked?
        decision == 'block'
      end

      # === EXIT CODE LOGIC ===
      #
      # UserPromptSubmit hooks use the advanced JSON API with exit code 0.
      # Per Anthropic guidance: when using structured JSON with decision/reason fields,
      # always output to stdout with exit 0 (not stderr with exit 2).
      # Reference: https://github.com/anthropics/claude-code/issues/10875
      def exit_code
        0
      end

      # === OUTPUT STREAM LOGIC ===
      #
      # UserPromptSubmit hooks always output to stdout when using the JSON API.
      def output_stream
        :stdout
      end

      # === MERGE HELPER ===

      def self.merge(*outputs)
        compacted_outputs = outputs.compact
        return compacted_outputs.first if compacted_outputs.length == 1
        return super(*outputs) if compacted_outputs.empty?

        merged = super(*outputs)
        merged_data = merged.data

        contexts = []
        specific = {}

        compacted_outputs.each do |output|
          output_data = output.respond_to?(:data) ? output.data : output
          hso = output_data['hookSpecificOutput'] || {}

          merged_data['decision'] = 'block' if output_data['decision'] == 'block'
          merged_data['reason'] = [merged_data['reason'], output_data['reason']].compact.reject(&:empty?).join('; ')

          context = hso['additionalContext']
          contexts << context if context && !context.empty?

          # Last non-nil title wins; suppressing the prompt wins if any hook asks for it.
          specific['sessionTitle'] = hso['sessionTitle'] unless hso['sessionTitle'].nil?
          specific['suppressOriginalPrompt'] = true if hso['suppressOriginalPrompt'] == true
        end

        specific['additionalContext'] = contexts.join("\n\n") unless contexts.empty?

        unless specific.empty?
          merged_data['hookSpecificOutput'] = { 'hookEventName' => 'UserPromptSubmit' }.merge(specific)
        end

        new(merged_data)
      end
    end
  end
end
