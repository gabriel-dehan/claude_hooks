# frozen_string_literal: true

require 'json'
require_relative 'configuration'
require_relative 'logger'

module ClaudeHooks
  # Base class for Claude Code hook scripts
  class Base
    # Common input fields for all hook types
    COMMON_INPUT_FIELDS = %w[session_id transcript_path cwd hook_event_name].freeze

    # Override in subclasses to specify hook type
    def self.hook_type
      raise NotImplementedError, "Subclasses must define hook_type"
    end

    # Override in subclasses to specify hook-specific input fields
    def self.input_fields
      raise NotImplementedError, "Subclasses must define input_fields"
    end

    def hook_type
      self.class.hook_type
    end

    attr_reader :config, :input_data, :output_data, :logger
    def initialize(input_data = {})
      @config = Configuration.config
      @input_data = input_data
      @output_data = {
        'continue' => true,
        'stopReason' => '',
        'suppressOutput' => false
      }
      @logger = Logger.new(session_id, self.class.name)

      validate_input!
    end

    # Main execution method - override in subclasses
    def call
      raise NotImplementedError, "Subclasses must implement the call method"
    end

    def output_string
      JSON.generate(@output_data)
    end

    # === COMMON INPUT DATA ACCESS ===

    def session_id
      @input_data['session_id'] || Configuration.session_id
    end

    def transcript_path
      @input_data['transcript_path']
    end

    def cwd
      @input_data['cwd']
    end

    def hook_event_name
      @input_data['hook_event_name'] || @input_data['hookEventName'] || hook_type
    end

    def read_transcript
      unless transcript_path && File.exist?(transcript_path)
        log "Transcript file not found at #{transcript_path}", level: :warn
        return ''
      end

      begin
        File.read(transcript_path)
      rescue => e
        log "Error reading transcript file at #{transcript_path}: #{e.message}", level: :error
        ''
      end
    end
    alias_method :transcript, :read_transcript

    # === COMMON OUTPUT HELPERS ===

    # Allow Claude to continue (default: true)
    def allow_continue!
      @output_data['continue'] = true
    end

    def prevent_continue!(reason)
      @output_data['continue'] = false
      @output_data['stopReason'] = reason
    end

    # Hide stdout from transcript mode (default: false)
    def suppress_output!
      @output_data['suppressOutput'] = true
    end

    def show_output!
      @output_data['suppressOutput'] = false
    end

    def clear_specifics!
      @output_data['hookSpecificOutput'] = nil
    end

    # === CONFIG AND UTILITY METHODS ===

    def base_dir
      Configuration.base_dir
    end

    def path_for(relative_path)
      Configuration.path_for(relative_path)
    end

    # Supports both single messages and blocks for multiline logging
    def log(message = nil, level: :info, &block)
      @logger.log(message, level: level, &block)
    end

    protected

    # === MERGE HELPER BASE ===

    # Handles common merging logic for all hook types
    # Subclasses should call super and add their specific logic
    def self.merge_outputs(*outputs_data)
      compacted_outputs_data = outputs_data.compact
      return { 'continue' => true, 'stopReason' => '', 'suppressOutput' => false } if compacted_outputs_data.empty?

      # Initialize merged result with defaults
      merged = { 'continue' => true, 'stopReason' => '', 'suppressOutput' => false }

      # Apply common merge logic
      compacted_outputs_data.each do |output|
        merged['continue'] = false if output['continue'] == false
        merged['stopReason'] = [merged['stopReason'], output['stopReason']].compact.reject(&:empty?).join('; ')
        merged['suppressOutput'] = true if output['suppressOutput'] == true
      end

      merged
    end

    private

    def validate_input!
      expected_fields = COMMON_INPUT_FIELDS + self.class.input_fields
      missing_fields = expected_fields - @input_data.keys

      unless missing_fields.empty?
        log "Missing required input fields for #{hook_type}: #{missing_fields.join(', ')}", level: :warn
      end
    end
  end
end