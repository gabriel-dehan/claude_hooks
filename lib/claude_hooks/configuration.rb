# frozen_string_literal: true

require 'json'

module ClaudeHooks
  class Configuration
    ENV_PREFIX = 'RUBY_CLAUDE_HOOKS_'

    class << self
      # Load the entire config as a hash (from ENV and optional config file)
      def config
        @config ||= load_config
      end

      # Unmemoize config
      def reload!
        @config = nil
        @base_dir = nil
        @config_file_path = nil
      end

      # Get the base directory from ENV or default
      def base_dir
        @base_dir ||= begin
          env_base_dir = ENV["#{ENV_PREFIX}BASE_DIR"]
          File.expand_path(env_base_dir || '~/.claude')
        end
      end

      # Get the full path for a file/directory relative to base_dir
      def path_for(relative_path)
        File.join(base_dir, relative_path)
      end

      # Get the log directory path
      def logs_directory
        log_dir = ENV["#{ENV_PREFIX}LOG_DIR"] || config.dig('logDirectory') || 'logs'
        if log_dir.start_with?('/')
          log_dir  # Absolute path
        else
          path_for(log_dir)  # Relative to base_dir
        end
      end

      # Get user name from ENV or config
      def user_name
        ENV["#{ENV_PREFIX}USER_NAME"] || config.dig('userName') || 'unknown'
      end

      private

      def config_file_path
        @config_file_path ||= path_for('config/config.json')
      end

      def load_config
        config_file = config_file_path

        if File.exist?(config_file)
          begin
            JSON.parse(File.read(config_file))
          rescue JSON::ParserError => e
            warn "Warning: Error parsing config file #{config_file}: #{e.message}"
            {}
          end
        else
          # No config file is fine - we'll use ENV vars and defaults
          {}
        end
      end
    end
  end
end
