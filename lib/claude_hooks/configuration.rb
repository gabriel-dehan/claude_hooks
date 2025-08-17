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
        log_dir = get_config_value('LOG_DIR', 'logDirectory') || 'logs'
        if log_dir.start_with?('/')
          log_dir  # Absolute path
        else
          path_for(log_dir)  # Relative to base_dir
        end
      end


      # Get any configuration value by key
      # First checks ENV with prefix, then config file, then returns default
      def get_config_value(env_key, config_key = nil, default = nil)
        # Check environment variable first
        env_value = ENV["#{ENV_PREFIX}#{env_key}"]
        return env_value if env_value

        # Check config file using provided key or converted env_key
        file_key = config_key || env_key_to_config_key(env_key)
        config_value = config.dig(file_key)
        return config_value if config_value

        # Return default
        default
      end

      # Allow access to any config value using method_missing
      def method_missing(method_name, *args, &block)
        # Convert method name to ENV key format (e.g., my_custom_setting -> MY_CUSTOM_SETTING)
        env_key = method_name.to_s.upcase
        # Convert snake_case method name to camelCase for config file lookup
        config_key = snake_case_to_camel_case(method_name.to_s)

        value = get_config_value(env_key, config_key)
        return value unless value.nil?

        super
      end

      def respond_to_missing?(method_name, include_private = false)
        # Check if we have a config value for this method
        env_key = method_name.to_s.upcase
        config_key = snake_case_to_camel_case(method_name.to_s)
        
        !get_config_value(env_key, config_key).nil? || super
      end

      private

      def snake_case_to_camel_case(snake_str)
        # Convert snake_case to camelCase (e.g., user_name -> userName)
        parts = snake_str.split('_')
        parts.first + parts[1..-1].map(&:capitalize).join
      end

      def config_file_path
        @config_file_path ||= path_for('config/config.json')
      end

      def load_config
        # Start with config file
        file_config = load_config_file
        
        # Merge with ENV variables
        env_config = load_env_config
        
        # ENV variables take precedence
        file_config.merge(env_config)
      end

      def load_config_file
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

      def load_env_config
        env_config = {}
        
        ENV.each do |key, value|
          next unless key.start_with?(ENV_PREFIX)
          
          # Remove prefix and convert to config key format
          config_key = env_key_to_config_key(key.sub(ENV_PREFIX, ''))
          env_config[config_key] = value
        end
        
        env_config
      end

      def env_key_to_config_key(env_key)
        # Convert SCREAMING_SNAKE_CASE to camelCase
        # BASE_DIR -> baseDir, LOG_DIR -> logDirectory (with special handling)
        case env_key
        when 'LOG_DIR'
          'logDirectory'
        when 'BASE_DIR'
          'baseDir'
        else
          # Convert SCREAMING_SNAKE_CASE to camelCase
          parts = env_key.downcase.split('_')
          parts.first + parts[1..-1].map(&:capitalize).join
        end
      end
    end
  end
end
