#!/usr/bin/env ruby

require 'minitest/autorun'
require 'stringio'
require 'tempfile'
require 'fileutils'
require_relative '../lib/claude_hooks'

class TestErrorHandling < Minitest::Test
  def assert_nothing_raised
    yield
  rescue StandardError => e
    flunk("Expected no exception, but got #{e.class}: #{e.message}")
  end

  def setup
    @original_stdin = $stdin
    @original_stdout = $stdout
    @original_stderr = $stderr
    
    # Use real hook classes for error scenarios
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

  def teardown
    $stdin = @original_stdin
    $stdout = @original_stdout
    $stderr = @original_stderr
  end

  # === JSON Parsing Errors ===
  
  def test_cli_entrypoint_malformed_json
    $stdin = StringIO.new('{ invalid json }')
    
    # Should exit with status 1 on JSON parsing error
    assert_raises(SystemExit) do
      ClaudeHooks::CLI.entrypoint(@valid_hook)
    end
  end

  def test_cli_entrypoint_empty_json
    $stdin = StringIO.new('{}')
    
    # Empty JSON is valid, should not raise error
    assert_nothing_raised do
      mock_hook = Minitest::Mock.new
      mock_hook.expect(:call, {})
      mock_hook.expect(:output_and_exit, nil)
      
      @valid_hook.stub(:new, mock_hook) do
        ClaudeHooks::CLI.entrypoint(@valid_hook)
      end
    end
  end

  def test_cli_run_hook_invalid_json_stdin
    # Test with invalid JSON should raise an error when parsing
    assert_raises(RuntimeError) do
      ClaudeHooks::CLI.run_hook(@valid_hook, nil) # This will try to read from STDIN
    end
  end

  # === Missing Required Fields ===
  
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

  def test_missing_hook_specific_fields
    incomplete_data = {
      'session_id' => 'test',
      'transcript_path' => '/tmp/test.md',
      'cwd' => '/test',
      'hook_event_name' => 'Notification'
      # Missing 'message' field
    }
    
    # Should create hook but log warning
    hook = @error_hook.new(incomplete_data)
    assert_instance_of(@error_hook, hook)
  end

  def test_completely_empty_input_data
    hook = @valid_hook.new({})
    assert_instance_of(@valid_hook, hook)
    assert_equal('claude-default-session', hook.session_id)
  end

  # === Hook Execution Errors ===
  
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

  def test_cli_entrypoint_block_error
    input_json = JSON.generate({ 'session_id' => 'test' })
    $stdin = StringIO.new(input_json)
    
    stdout, stderr = capture_io do
      begin
        ClaudeHooks::CLI.entrypoint do |input_data|
          raise RuntimeError, 'Block execution error'
        end
      rescue SystemExit => e
        assert_equal(1, e.status)
      end
    end
    
    assert_match(/Hook execution error.*Block execution error/, stderr)
  end

  # === File Permission Errors ===
  
  def test_transcript_file_permission_denied
    # Create a file that can't be read
    temp_file = Tempfile.new('transcript')
    temp_file.write('content')
    temp_file.close
    FileUtils.chmod(0000, temp_file.path)
    
    input_data = {
      'session_id' => 'test',
      'transcript_path' => temp_file.path
    }
    
    hook = @valid_hook.new(input_data)
    content = hook.read_transcript
    assert_equal('', content) # Should return empty string on error
    
    # Clean up
    FileUtils.chmod(0644, temp_file.path)
    temp_file.unlink
  end

  def test_logger_handles_unwritable_directory
    # Use a directory that doesn't exist and can't be created
    ClaudeHooks::Configuration.stub(:logs_directory, '/root/impossible/path') do
      stderr_output = StringIO.new
      $stderr = stderr_output
      
      logger = ClaudeHooks::Logger.new('test-session', 'TestSource')
      logger.log('Test message')
      
      stderr_content = stderr_output.string
      assert_match(/Test message/, stderr_content)
      assert_match(/Warning: Failed to write to session log/, stderr_content)
    end
  end

  # === Invalid Hook Types ===
  
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

  # === Configuration Errors ===
  
  def test_config_file_json_parse_error
    temp_dir = Dir.mktmpdir
    config_dir = File.join(temp_dir, '.claude', 'config')
    FileUtils.mkdir_p(config_dir)
    
    # Write invalid JSON to config file
    File.write(File.join(config_dir, 'config.json'), '{ invalid json }')
    
    original_home = ENV['HOME']
    ENV['HOME'] = temp_dir
    
    ClaudeHooks::Configuration.stub(:home_claude_dir, File.join(temp_dir, '.claude')) do
      ClaudeHooks::Configuration.reload!
      
      # Should handle parse error gracefully and return empty config
      config = ClaudeHooks::Configuration.config
      assert_kind_of(Hash, config)
    end
    
    ENV['HOME'] = original_home
    FileUtils.rm_rf(temp_dir)
  end

  # === Output Errors ===
  
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
    
    # Mock exit to prevent actual exit
    exit_code = nil
    hook.output.stub(:exit, ->(code) { exit_code = code }) do
      stdout, stderr = capture_io do
        hook.output_and_exit
      end
      
      assert_equal(2, exit_code) # Should exit with error code
      parsed = JSON.parse(stdout)
      refute(parsed['continue'])
      assert_equal('Error occurred', parsed['stopReason'])
    end
  end

  # === Nil and Empty Value Handling ===
  
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
    assert_equal('claude-default-session', hook.session_id) # Empty string is falsy, falls back to default
    assert_equal('', hook.transcript_path)
    assert_equal('', hook.cwd)
    assert_equal('Notification', hook.hook_event_name) # Empty string is falsy
  end

  # === Concurrent Access Errors ===
  
  def test_multiple_hooks_writing_simultaneously
    # This tests that the logger handles concurrent writes properly
    temp_dir = Dir.mktmpdir
    ClaudeHooks::Configuration.stub(:logs_directory, temp_dir) do
      threads = []
      10.times do |i|
        threads << Thread.new do
          logger = ClaudeHooks::Logger.new('concurrent-test', "Thread#{i}")
          5.times do |j|
            logger.log("Message #{j} from thread #{i}")
          end
        end
      end
      
      threads.each(&:join)
      
      # Check that all messages were logged
      log_file = Dir.glob(File.join(temp_dir, '**/*.log')).first
      assert(log_file, 'Log file should be created')
      
      content = File.read(log_file)
      # Should have 50 log entries (10 threads * 5 messages)
      log_lines = content.lines.select { |l| l.include?('Message') }
      assert_equal(50, log_lines.length)
    end
    
    FileUtils.rm_rf(temp_dir)
  end

  # === Type Errors ===
  
  def test_wrong_data_type_for_hook_input
    # Pass array instead of hash
    assert_raises(NoMethodError) do
      @valid_hook.new([])
    end
    
    # Pass string instead of hash
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

  # === Environment Variable Errors ===
  
  def test_invalid_environment_variables
    # Set invalid merge strategy
    ENV['RUBY_CLAUDE_HOOKS_CONFIG_MERGE_STRATEGY'] = 'invalid_strategy'
    ClaudeHooks::Configuration.reload!
    
    # Should fall back to default behavior
    assert_nothing_raised do
      config = ClaudeHooks::Configuration.config
      assert_kind_of(Hash, config)
    end
    
    ENV.delete('RUBY_CLAUDE_HOOKS_CONFIG_MERGE_STRATEGY')
  end

  def test_malformed_claude_project_dir
    ENV['CLAUDE_PROJECT_DIR'] = "path\nwith\nnewlines"
    ClaudeHooks::Configuration.reload!
    
    # Should handle malformed paths gracefully
    assert_nothing_raised do
      project_dir = ClaudeHooks::Configuration.project_claude_dir
      # Path will be expanded, which should handle the newlines
    end
    
    ENV.delete('CLAUDE_PROJECT_DIR')
  end
end