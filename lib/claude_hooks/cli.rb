# frozen_string_literal: true

require 'json'

module ClaudeHooks
  # CLI utility for testing hook handlers in isolation
  # This module provides a standardized way to run hooks directly from the command line
  # for testing and debugging purposes.
  module CLI
    class << self
      # Run a hook class directly from command line
      # Usage: 
      #   ClaudeHooks::CLI.run_hook(YourHookClass)
      #   ClaudeHooks::CLI.run_hook(YourHookClass, custom_input_data)
      #   
      #   # With customization block:
      #   ClaudeHooks::CLI.run_hook(YourHookClass) do |input_data|
      #     input_data['debug_mode'] = true
      #   end
      def run_hook(hook_class, input_data = nil, &block)
        # If no input data provided, read from STDIN
        input_data ||= read_stdin_input
        
        # Apply customization block if provided
        if block_given?
          yield(input_data)
        end
        
        # Create and execute the hook
        hook = hook_class.new(input_data)
        result = hook.call
        
        # Output the result as JSON (same format as production hooks)
        puts JSON.generate(result) if result
        
        result
      rescue StandardError => e
        handle_error(e, hook_class)
      end

      # Create a test runner block for a hook class
      # This generates the common if __FILE__ == $0 block content
      # 
      # Usage: 
      #   ClaudeHooks::CLI.test_runner(YourHookClass)
      #   
      #   # With customization block:
      #   ClaudeHooks::CLI.test_runner(YourHookClass) do |input_data|
      #     input_data['custom_field'] = 'test_value'
      #     input_data['user_name'] = 'TestUser'
      #   end
      def test_runner(hook_class, &block)
        input_data = read_stdin_input
        
        # Apply customization block if provided
        if block_given?
          yield(input_data)
        end
        
        run_hook(hook_class, input_data)
      end

      # Run hook with sample data (useful for development)
      # Usage:
      #   ClaudeHooks::CLI.run_with_sample_data(YourHookClass)
      #   ClaudeHooks::CLI.run_with_sample_data(YourHookClass, { 'prompt' => 'test prompt' })
      #   
      #   # With customization block:
      #   ClaudeHooks::CLI.run_with_sample_data(YourHookClass) do |input_data|
      #     input_data['prompt'] = 'Custom test prompt'
      #     input_data['debug'] = true
      #   end
      def run_with_sample_data(hook_class, sample_data = {}, &block)
        default_sample = {
          'session_id' => 'test-session',
          'transcript_path' => '/tmp/test_transcript.md',
          'cwd' => Dir.pwd,
          'hook_event_name' => hook_class.hook_type
        }

        # Merge with hook-specific sample data
        merged_data = default_sample.merge(sample_data)
        
        # Apply customization block if provided
        if block_given?
          yield(merged_data)
        end
        
        run_hook(hook_class, merged_data)
      end

      private

      def read_stdin_input
        stdin_content = STDIN.read.strip
        return {} if stdin_content.empty?
        
        JSON.parse(stdin_content)
      rescue JSON::ParserError => e
        raise "Invalid JSON input: #{e.message}"
      end

      def handle_error(error, hook_class)
        STDERR.puts "Error in #{hook_class.name} hook: #{error.message}"
        STDERR.puts error.backtrace.join("\n") if error.backtrace

        # Output error response in Claude Code format
        error_response = {
          continue: false,
          stopReason: "#{hook_class.name} execution error: #{error.message}",
          suppressOutput: false
        }

        puts JSON.generate(error_response)
        exit 1
      end
    end
  end
end