# frozen_string_literal: true

require_relative 'base'

module ClaudeHooks
  class DirectoryAdded < Base
    def self.hook_type
      'DirectoryAdded'
    end

    def self.input_fields
      %w[directory source]
    end

    def directory
      @input_data['directory']
    end

    # Values: slash_command | register_repo_root
    def source
      @input_data['source']
    end
  end
end
