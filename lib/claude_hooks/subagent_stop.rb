# frozen_string_literal: true

require_relative 'stop'

module ClaudeHooks
  class SubagentStop < Stop
    def self.hook_type
      'SubagentStop'
    end

    def agent_transcript_path
      @input_data['agent_transcript_path'] || @input_data['agentTranscriptPath']
    end
  end
end
