# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  module Output
    class TaskCreated < Base
      # === DECISION ACCESSORS ===
      #
      # Claude Code ignores `continue: false` for TaskCreated; block via exit 2 or
      # a top-level decision:block.

      def decision
        @data['decision']
      end

      def reason
        @data['reason'] || ''
      end

      def blocked?
        decision == 'block'
      end

      def exit_code
        default_exit_code
      end

      def self.merge(*outputs)
        compacted_outputs = outputs.compact
        return compacted_outputs.first if compacted_outputs.length == 1
        return super(*outputs) if compacted_outputs.empty?

        merged = super(*outputs)
        merged_data = merged.data
        reasons = []

        compacted_outputs.each do |output|
          output_data = output.respond_to?(:data) ? output.data : output
          merged_data['decision'] = 'block' if output_data['decision'] == 'block'
          reason = output_data['reason']
          reasons << reason if reason && !reason.empty?
        end

        merged_data['reason'] = reasons.join('; ') unless reasons.empty?

        new(merged_data)
      end
    end
  end
end
