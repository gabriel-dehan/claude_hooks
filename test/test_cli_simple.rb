#!/usr/bin/env ruby

require 'minitest/autorun'
require 'stringio'
require_relative '../lib/claude_hooks'

class TestCLISimple < Minitest::Test
  def setup
    @test_input_data = {
      'session_id' => 'cli-test-session',
      'transcript_path' => '/tmp/cli_test.md',
      'cwd' => '/test/cli',
      'hook_event_name' => 'Notification',
      'message' => 'Test CLI notification'
    }
    
    # Create a working test hook
    @test_hook = Class.new(ClaudeHooks::Notification) do
      def call
        # Simple implementation that just returns the output
        @output_data
      end
    end
  end

  # === Core Functionality Tests ===
  
  def test_run_hook_with_provided_data
    result = ClaudeHooks::CLI.run_hook(@test_hook, @test_input_data)
    assert_kind_of(Hash, result)
    assert(result['continue'])
  end

  def test_run_with_sample_data
    result = ClaudeHooks::CLI.run_with_sample_data(@test_hook)
    assert_kind_of(Hash, result)
    assert(result['continue'])
  end

  def test_run_with_sample_data_with_overrides
    overrides = { 'message' => 'Custom message' }
    result = ClaudeHooks::CLI.run_with_sample_data(@test_hook, overrides)
    assert_kind_of(Hash, result)
    assert(result['continue'])
  end

  def test_run_hook_with_customization_block
    modified = false
    result = ClaudeHooks::CLI.run_hook(@test_hook, @test_input_data) do |input_data|
      input_data['custom_field'] = 'added'
      modified = true
    end
    
    assert(modified)
    assert_kind_of(Hash, result)
  end

  # === Error Handling Tests ===
  
  def test_run_hook_handles_hook_errors
    error_hook = Class.new(ClaudeHooks::Notification) do
      def call
        raise StandardError, 'Test error'
      end
    end
    
    # Should exit with status 1 on error
    assert_raises(SystemExit) do
      ClaudeHooks::CLI.run_hook(error_hook, @test_input_data)
    end
  end
end