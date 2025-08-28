#!/usr/bin/env ruby

require 'minitest/autorun'
require 'stringio'
require 'tempfile'
require 'fileutils'
require_relative '../lib/claude_hooks'

class TestErrorHandlingSimple < Minitest::Test
  def assert_nothing_raised
    yield
  rescue StandardError => e
    flunk("Expected no exception, but got #{e.class}: #{e.message}")
  end

  def setup
    @error_hook = Class.new(ClaudeHooks::Notification) do
      def call
        raise StandardError, 'Intentional error'
      end
    end
    
    @valid_hook = Class.new(ClaudeHooks::Notification) do
      def call
        @output_data
      end
    end
  end

  # === Basic Error Handling Tests ===
  
  def test_hook_execution_error_in_call_method
    input_data = {
      'session_id' => 'error-test',
      'transcript_path' => '/tmp/test.md',
      'cwd' => '/test',
      'hook_event_name' => 'Notification',
      'message' => 'test message'
    }
    
    hook = @error_hook.new(input_data)
    assert_raises(StandardError) { hook.call }
  end

  def test_cli_handles_hook_execution_error
    input_data = {
      'session_id' => 'error-test',
      'message' => 'test message'
    }
    
    # Should exit with status 1 on hook execution error
    assert_raises(SystemExit) do
      ClaudeHooks::CLI.run_hook(@error_hook, input_data)
    end
  end

  def test_missing_required_common_fields
    # Missing session_id and transcript_path
    incomplete_data = {
      'cwd' => '/test',
      'hook_event_name' => 'Test'
    }
    
    # Should create hook but log warning (not raise error)
    hook = @valid_hook.new(incomplete_data)
    assert_instance_of(@valid_hook, hook)
  end

  def test_completely_empty_input_data
    hook = @valid_hook.new({})
    assert_instance_of(@valid_hook, hook)
    assert_equal('claude-default-session', hook.session_id)
  end

  def test_nil_values_in_input_data
    input_with_nils = {
      'session_id' => nil,
      'transcript_path' => nil,
      'cwd' => nil,
      'hook_event_name' => nil
    }
    
    hook = @valid_hook.new(input_with_nils)
    assert_equal('claude-default-session', hook.session_id)
    assert_nil(hook.transcript_path)
    assert_nil(hook.cwd)
    assert_equal('Notification', hook.hook_event_name) # Falls back to hook_type
  end

  def test_empty_string_values_in_input_data
    input_with_empty = {
      'session_id' => '',
      'transcript_path' => '',
      'cwd' => '',
      'hook_event_name' => ''
    }
    
    hook = @valid_hook.new(input_with_empty)
    assert_equal('', hook.session_id) # Empty string doesn't fall back to default
    assert_equal('', hook.transcript_path)
    assert_equal('', hook.cwd)
    assert_equal('', hook.hook_event_name) # Empty string is returned as-is
  end

  def test_invalid_hook_type_for_output_factory
    invalid_data = { 'continue' => true }
    
    # Should raise error for unknown hook type
    assert_raises(ArgumentError) do
      ClaudeHooks::Output::Base.for_hook_type('UnknownHookType', invalid_data)
    end
  end

  def test_base_class_abstract_methods_raise_errors
    assert_raises(NotImplementedError) do
      ClaudeHooks::Base.hook_type
    end
    
    assert_raises(NotImplementedError) do
      ClaudeHooks::Base.input_fields
    end
  end

  def test_output_and_exit_with_error_exit_code
    hook_with_error = Class.new(ClaudeHooks::Notification) do
      def call
        prevent_continue!('Error occurred')
        @output_data
      end
    end
    
    input_data = { 'session_id' => 'test' }
    hook = hook_with_error.new(input_data)
    hook.call
    
    # Test that the output contains error information
    output = hook.output
    refute(output.continue?)
    assert_equal('Error occurred', output.stop_reason)
    assert_equal(2, output.exit_code)
  end

  def test_wrong_data_type_for_hook_input
    # Pass array instead of hash should raise TypeError when accessing with string keys
    assert_raises(TypeError) do
      @valid_hook.new([])
    end
    
    # Pass string instead of hash should raise NoMethodError when calling hash methods  
    assert_raises(NoMethodError) do
      @valid_hook.new('not a hash')
    end
  end

  def test_output_merge_with_incompatible_types
    output1 = ClaudeHooks::Output::PreToolUse.new({ 'continue' => true })
    output2 = ClaudeHooks::Output::UserPromptSubmit.new({ 'continue' => true })
    
    # Merging different output types should work but may have unexpected results
    # The merge method should handle this gracefully
    assert_nothing_raised do
      ClaudeHooks::Output::PreToolUse.merge(output1, output2)
    end
  end
end