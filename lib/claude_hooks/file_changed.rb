# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  class FileChanged < Base
    def self.hook_type
      'FileChanged'
    end

    def self.input_fields
      %w[file_path event]
    end

    def file_path
      @input_data['file_path'] || @input_data['filePath']
    end

    # Values: change | add | unlink
    def event
      @input_data['event']
    end

    def created?
      event == 'add'
    end

    def modified?
      event == 'change'
    end

    def deleted?
      event == 'unlink'
    end

    def watch_paths!(paths)
      @output_data['hookSpecificOutput'] ||= { 'hookEventName' => hook_event_name }
      @output_data['hookSpecificOutput']['watchPaths'] = Array(paths)
    end
  end
end
