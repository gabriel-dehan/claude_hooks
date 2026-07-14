# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  module Output
    class SessionStart < Base
      # === CONTEXT ACCESSORS ===

      def additional_context
        hook_specific_output['additionalContext'] || ''
      end

      def session_title
        hook_specific_output['sessionTitle']
      end

      def initial_user_message
        hook_specific_output['initialUserMessage']
      end

      def watch_paths
        hook_specific_output['watchPaths'] || []
      end

      def reload_skills?
        hook_specific_output['reloadSkills'] == true
      end

      # === EXIT CODE LOGIC ===

      def exit_code
        default_exit_code
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

          context = hso['additionalContext']
          contexts << context if context && !context.empty?

          # Last-non-nil wins for the scalar/array session fields.
          %w[sessionTitle initialUserMessage watchPaths reloadSkills].each do |key|
            specific[key] = hso[key] unless hso[key].nil?
          end
        end

        specific['additionalContext'] = contexts.join("\n\n") unless contexts.empty?

        unless specific.empty?
          merged_data['hookSpecificOutput'] = { 'hookEventName' => 'SessionStart' }.merge(specific)
        end

        new(merged_data)
      end
    end
  end
end