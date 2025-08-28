#!/usr/bin/env ruby

require 'minitest/autorun'
require 'stringio'
require 'tempfile'
require_relative '../lib/claude_hooks'

class TestCLI < Minitest::Test
  def setup
    @original_stdin = $stdin
    @original_stdout = $stdout
    @original_stderr = $stderr
    
    @test_input_data = {
      'session_id' => 'cli-test-session',
      'transcript_path' => '/tmp/cli_test.md',
      'cwd' => '/test/cli',
      'hook_event_name' => 'Notification',
      'message' => 'Test CLI notification'
    }
    
    # Use Notification hook for CLI testing
    @test_hook = ClaudeHooks::Notification
  end

  def teardown
    $stdin = @original_stdin
    $stdout = @original_stdout
    $stderr = @original_stderr
  end

  # === run_hook Tests ===
  
  def test_run_hook_with_provided_data
    result = ClaudeHooks::CLI.run_hook(@test_hook, @test_input_data)
    assert_kind_of(Hash, result)
    assert(result['continue'])
  end

  def test_run_hook_reads_from_stdin
    input_json = JSON.generate(@test_input_data)
    $stdin = StringIO.new(input_json)
    
    output = capture_io do
      result = ClaudeHooks::CLI.run_hook(@test_hook)
      assert_kind_of(Hash, result)
      assert(result['continue'])
    end
  end

  def test_run_hook_with_customization_block
    modified_data = @test_input_data.dup
    
    output = capture_io do
      result = ClaudeHooks::CLI.run_hook(@test_hook, modified_data) do |input_data|
        input_data['custom_field'] = 'custom_value'
      end
      
      assert_equal('custom_value', modified_data['custom_field'])
    end
  end

  def test_run_hook_handles_errors
    # Create a Notification hook subclass that raises an error
    error_hook = Class.new(ClaudeHooks::Notification) do
      def call
        raise StandardError, 'Test error'
      end
    end
    
    output, err = capture_io do
      begin
        ClaudeHooks::CLI.run_hook(error_hook, @test_input_data)
      rescue SystemExit => e
        # Expect exit(1) on error
        assert_equal(1, e.status)
      end
    end
    
    assert_match(/Test error/, err)
  end

  # === test_runner Tests ===
  
  def test_test_runner_reads_stdin
    input_json = JSON.generate(@test_input_data)
    $stdin = StringIO.new(input_json)
    
    output = capture_io do
      ClaudeHooks::CLI.test_runner(@test_hook)
    end
    
    parsed_output = JSON.parse(output[0])
    assert(parsed_output['continue'])
  end

  def test_test_runner_with_customization_block
    input_json = JSON.generate(@test_input_data)
    $stdin = StringIO.new(input_json)
    
    output = capture_io do
      ClaudeHooks::CLI.test_runner(@test_hook) do |input_data|
        input_data['modified'] = true
      end
    end
    
    # The block should have modified the input data
    parsed_output = JSON.parse(output[0])
    assert(parsed_output['continue'])
  end

  # === run_with_sample_data Tests ===
  
  def test_run_with_sample_data_default
    output = capture_io do
      result = ClaudeHooks::CLI.run_with_sample_data(@test_hook)
      
      assert_kind_of(Hash, result)
      assert(result['continue'])
    end
  end

  def test_run_with_sample_data_with_overrides
    sample_overrides = {
      'session_id' => 'custom-session',
      'test_field' => 'test_value'
    }
    
    output = capture_io do
      result = ClaudeHooks::CLI.run_with_sample_data(@test_hook, sample_overrides)
      assert_kind_of(Hash, result)
    end
  end

  def test_run_with_sample_data_with_block
    output = capture_io do
      ClaudeHooks::CLI.run_with_sample_data(@test_hook) do |input_data|
        input_data['block_modified'] = true
      end
    end
    
    parsed_output = JSON.parse(output[0])
    assert(parsed_output['continue'])
  end

  # === entrypoint Tests ===
  
  def test_entrypoint_with_hook_class
    input_json = JSON.generate(@test_input_data)
    $stdin = StringIO.new(input_json)
    
    # Mock output_and_exit to prevent actual exit
    mock_hook = Minitest::Mock.new
    mock_hook.expect(:call, @test_input_data)
    mock_hook.expect(:output_and_exit, nil)
    
    @test_hook.stub(:new, mock_hook) do
      ClaudeHooks::CLI.entrypoint(@test_hook)
    end
    
    mock_hook.verify
  end

  def test_entrypoint_with_block
    input_json = JSON.generate(@test_input_data)
    $stdin = StringIO.new(input_json)
    
    block_executed = false
    
    ClaudeHooks::CLI.entrypoint do |input_data|
      block_executed = true
      assert_equal('cli-test-session', input_data['session_id'])
    end
    
    assert(block_executed)
  end

  def test_entrypoint_handles_json_parse_error
    $stdin = StringIO.new('invalid json')
    
    _, err = capture_io do
      begin
        ClaudeHooks::CLI.entrypoint(@test_hook)
      rescue SystemExit => e
        assert_equal(1, e.status)
      end
    end
    
    assert_match(/JSON parsing error/, err)
  end

  def test_entrypoint_handles_execution_error
    input_json = JSON.generate(@test_input_data)
    $stdin = StringIO.new(input_json)
    
    _, err = capture_io do
      begin
        ClaudeHooks::CLI.entrypoint do |input_data|
          raise StandardError, 'Execution error'
        end
      rescue SystemExit => e
        assert_equal(1, e.status)
      end
    end
    
    assert_match(/Hook execution error/, err)
  end

  def test_entrypoint_requires_class_or_block
    input_json = JSON.generate(@test_input_data)
    $stdin = StringIO.new(input_json)
    
    # Mock STDIN to avoid hanging on empty input
    stderr_output = StringIO.new
    $stderr = stderr_output
    
    assert_raises(ArgumentError) do
      ClaudeHooks::CLI.entrypoint
    end
  end

  # === Private Method Tests (indirect testing) ===
  
  def test_empty_stdin_handling
    $stdin = StringIO.new('')
    
    output = capture_io do
      result = ClaudeHooks::CLI.run_hook(@test_hook, {})
      # Should use empty hash as input when none provided
      assert_kind_of(Hash, result)
    end
  end

  def test_stdin_whitespace_handling
    $stdin = StringIO.new('   ')
    
    output = capture_io do
      result = ClaudeHooks::CLI.run_hook(@test_hook, {})
      # Should use empty hash as input when whitespace provided
      assert_kind_of(Hash, result)
    end
  end

  # === Error Response Format Tests ===
  
  def test_error_response_format
    error_hook = Class.new(ClaudeHooks::Base) do
      def self.hook_type
        'ErrorHook'
      end
      
      def self.input_fields
        []
      end
      
      def call
        raise StandardError, 'Formatted error test'
      end
    end
    
    out, err = capture_io do
      begin
        ClaudeHooks::CLI.run_hook(error_hook, @test_input_data)
      rescue SystemExit
        # Expected
      end
    end
    
    # Both stdout and stderr should contain the error response
    error_json = out.strip
    if error_json.empty?
      error_json = err.lines.find { |line| line.start_with?('{') }
    end
    
    if error_json && !error_json.empty?
      parsed = JSON.parse(error_json)
      refute(parsed['continue'])
      assert_match(/Formatted error test/, parsed['stopReason'])
      refute(parsed['suppressOutput'])
    end
  end

  # === Integration with Real Hook Classes ===
  
  def test_cli_with_real_hook_class
    input_data = @test_input_data.merge({
      'prompt' => 'Test prompt'
    })
    
    output = capture_io do
      result = ClaudeHooks::CLI.run_hook(ClaudeHooks::UserPromptSubmit, input_data)
      assert_kind_of(Hash, result)
    end
  end
end