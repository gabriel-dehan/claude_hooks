#!/usr/bin/env ruby

require 'minitest/autorun'
require 'tempfile'
require 'fileutils'
require_relative '../lib/claude_hooks/logger'
require_relative '../lib/claude_hooks/configuration'

class TestLogger < Minitest::Test
  def setup
    @test_session_id = 'logger-test-session-789'
    @test_source = 'TestLogger'
    
    # Save original stderr
    @original_stderr = $stderr
    
    # Create a temporary logs directory for testing
    @temp_dir = Dir.mktmpdir('claude_hooks_test')
    @logs_dir = File.join(@temp_dir, 'logs')
    FileUtils.mkdir_p(@logs_dir)
    
    # Mock the configuration to use our temp directory
    ClaudeHooks::Configuration.stub(:logs_directory, @logs_dir) do
      @logger = ClaudeHooks::Logger.new(@test_session_id, @test_source)
    end
  end

  def teardown
    $stderr = @original_stderr
    FileUtils.rm_rf(@temp_dir) if @temp_dir && File.exist?(@temp_dir)
  end

  # === Basic Logging Tests ===
  
  def test_logger_initialization
    ClaudeHooks::Configuration.stub(:logs_directory, @logs_dir) do
      logger = ClaudeHooks::Logger.new(@test_session_id, @test_source)
      assert_instance_of(ClaudeHooks::Logger, logger)
    end
  end

  def test_simple_log_message
    ClaudeHooks::Configuration.stub(:logs_directory, @logs_dir) do
      logger = ClaudeHooks::Logger.new(@test_session_id, @test_source)
      logger.log('Test message')
      
      log_file = File.join(@logs_dir, 'hooks', 'session-logger-test-session-789.log')
      assert(File.exist?(log_file), 'Log file should be created')
      
      content = File.read(log_file)
      assert_match(/Test message/, content)
      assert_match(/\[INFO\]/, content)
      assert_match(/\[TestLogger\]/, content)
    end
  end

  def test_log_with_different_levels
    ClaudeHooks::Configuration.stub(:logs_directory, @logs_dir) do
      logger = ClaudeHooks::Logger.new(@test_session_id, @test_source)
      
      logger.log('Info message', level: :info)
      logger.log('Debug message', level: :debug)
      logger.log('Warning message', level: :warn)
      logger.log('Error message', level: :error)
      
      log_file = File.join(@logs_dir, 'hooks', 'session-logger-test-session-789.log')
      content = File.read(log_file)
      
      assert_match(/\[INFO\].*Info message/, content)
      assert_match(/\[DEBUG\].*Debug message/, content)
      assert_match(/\[WARN\].*Warning message/, content)
      assert_match(/\[ERROR\].*Error message/, content)
    end
  end

  # === Multiline Logging Tests ===
  
  def test_multiline_log_message
    ClaudeHooks::Configuration.stub(:logs_directory, @logs_dir) do
      logger = ClaudeHooks::Logger.new(@test_session_id, @test_source)
      
      multiline_message = "Line 1\nLine 2\nLine 3"
      logger.log(multiline_message)
      
      log_file = File.join(@logs_dir, 'hooks', 'session-logger-test-session-789.log')
      content = File.read(log_file)
      
      # Multiline messages should have newline before the content
      assert_match(/\[INFO\].*\[TestLogger\]\nLine 1\nLine 2\nLine 3/, content)
    end
  end

  def test_single_line_vs_multiline_formatting
    ClaudeHooks::Configuration.stub(:logs_directory, @logs_dir) do
      logger = ClaudeHooks::Logger.new(@test_session_id, @test_source)
      
      logger.log('Single line')
      logger.log("Multi\nline")
      
      log_file = File.join(@logs_dir, 'hooks', 'session-logger-test-session-789.log')
      content = File.read(log_file)
      
      # Single line should have space after prefix
      assert_match(/\[INFO\].*\[TestLogger\] Single line/, content)
      # Multiline should have newline after prefix
      assert_match(/\[INFO\].*\[TestLogger\]\nMulti\nline/, content)
    end
  end

  # === Session ID Sanitization Tests ===
  
  def test_session_id_sanitization
    ClaudeHooks::Configuration.stub(:logs_directory, @logs_dir) do
      # Session ID with special characters
      unsafe_session_id = 'test/session:with*special<chars>'
      logger = ClaudeHooks::Logger.new(unsafe_session_id, @test_source)
      logger.log('Test')
      
      # Check that the file was created with sanitized name
      expected_file = File.join(@logs_dir, 'hooks', 'session-test_session_with_special_chars_.log')
      assert(File.exist?(expected_file), 'Should create log file with sanitized name')
    end
  end

  def test_nil_session_id_handling
    ClaudeHooks::Configuration.stub(:logs_directory, @logs_dir) do
      logger = ClaudeHooks::Logger.new(nil, @test_source)
      logger.log('Test with nil session')
      
      expected_file = File.join(@logs_dir, 'hooks', 'session-unknown.log')
      assert(File.exist?(expected_file), 'Should create log file with "unknown" session')
    end
  end

  # === File Creation Tests ===
  
  def test_log_file_creation
    ClaudeHooks::Configuration.stub(:logs_directory, @logs_dir) do
      logger = ClaudeHooks::Logger.new(@test_session_id, @test_source)
      
      expected_file = File.join(@logs_dir, 'hooks', 'session-logger-test-session-789.log')
      
      # No file should exist yet
      refute(File.exist?(expected_file))
      
      # Log a message
      logger.log('First message')
      
      # File should now exist
      assert(File.exist?(expected_file))
    end
  end

  def test_log_file_naming_pattern
    ClaudeHooks::Configuration.stub(:logs_directory, @logs_dir) do
      logger = ClaudeHooks::Logger.new(@test_session_id, @test_source)
      logger.log('Test')
      
      expected_file = File.join(@logs_dir, 'hooks', 'session-logger-test-session-789.log')
      assert(File.exist?(expected_file), 'Log file should exist at expected path')
      
      # Check the filename follows the expected pattern
      filename = File.basename(expected_file)
      assert_match(/^session-logger-test-session-789\.log$/, filename)
    end
  end

  def test_append_to_existing_log_file
    ClaudeHooks::Configuration.stub(:logs_directory, @logs_dir) do
      logger1 = ClaudeHooks::Logger.new(@test_session_id, @test_source)
      logger1.log('First message')
      
      # Create another logger with same session ID
      logger2 = ClaudeHooks::Logger.new(@test_session_id, 'AnotherSource')
      logger2.log('Second message')
      
      expected_file = File.join(@logs_dir, 'hooks', 'session-logger-test-session-789.log')
      assert(File.exist?(expected_file), 'Should use same log file')
      
      content = File.read(expected_file)
      assert_match(/First message/, content)
      assert_match(/Second message/, content)
      assert_match(/\[TestLogger\]/, content)
      assert_match(/\[AnotherSource\]/, content)
    end
  end

  # === Error Handling Tests ===
  
  def test_fallback_to_stderr_on_write_failure
    # Create a logger but make the logs directory unwritable
    ClaudeHooks::Configuration.stub(:logs_directory, '/nonexistent/path') do
      logger = ClaudeHooks::Logger.new(@test_session_id, @test_source)
      
      # Capture stderr output
      stderr_output = StringIO.new
      $stderr = stderr_output
      
      logger.log('Test message that should go to stderr')
      
      stderr_content = stderr_output.string
      assert_match(/Test message that should go to stderr/, stderr_content)
      assert_match(/Warning: Failed to write to session log/, stderr_content)
    end
  end

  def test_handles_permission_errors
    ClaudeHooks::Configuration.stub(:logs_directory, @logs_dir) do
      # Create the log file first
      logger = ClaudeHooks::Logger.new(@test_session_id, @test_source)
      logger.log('Initial message')
      
      log_file = File.join(@logs_dir, 'hooks', 'session-logger-test-session-789.log')
      
      # Make the file unwritable
      FileUtils.chmod(0444, log_file)
      
      # Try to log again (should fail but handle gracefully)
      stderr_output = StringIO.new
      $stderr = stderr_output
      
      logger.log('This should fail')
      
      stderr_content = stderr_output.string
      assert_match(/This should fail/, stderr_content)
      
      # Clean up permissions
      FileUtils.chmod(0644, log_file)
    end
  end

  # === Timestamp Tests ===
  
  def test_timestamp_format
    ClaudeHooks::Configuration.stub(:logs_directory, @logs_dir) do
      logger = ClaudeHooks::Logger.new(@test_session_id, @test_source)
      
      # Mock Time.now to get predictable timestamp
      mock_time = Time.new(2024, 12, 15, 14, 30, 45)
      Time.stub(:now, mock_time) do
        logger.log('Timestamp test')
      end
      
      log_file = File.join(@logs_dir, 'hooks', 'session-logger-test-session-789.log')
      content = File.read(log_file)
      
      assert_match(/\[2024-12-15 14:30:45\]/, content)
    end
  end

  # === Empty/Nil Message Tests ===
  
  def test_log_empty_message
    ClaudeHooks::Configuration.stub(:logs_directory, @logs_dir) do
      logger = ClaudeHooks::Logger.new(@test_session_id, @test_source)
      logger.log('')
      
      log_file = File.join(@logs_dir, 'hooks', 'session-logger-test-session-789.log')
      content = File.read(log_file)
      
      # Should still create entry with timestamp and source
      assert_match(/\[INFO\].*\[TestLogger\] $/, content)
    end
  end

  def test_log_nil_message
    ClaudeHooks::Configuration.stub(:logs_directory, @logs_dir) do
      logger = ClaudeHooks::Logger.new(@test_session_id, @test_source)
      
      # The current logger implementation will fail with nil message
      # This test documents the current behavior - it should be fixed in the logger
      assert_raises(NoMethodError) do
        logger.log(nil)
      end
    end
  end

  # === Multiple Loggers Tests ===
  
  def test_multiple_loggers_same_session
    ClaudeHooks::Configuration.stub(:logs_directory, @logs_dir) do
      logger1 = ClaudeHooks::Logger.new(@test_session_id, 'Source1')
      logger2 = ClaudeHooks::Logger.new(@test_session_id, 'Source2')
      
      logger1.log('Message from source 1')
      logger2.log('Message from source 2')
      logger1.log('Another from source 1')
      
      expected_file = File.join(@logs_dir, 'hooks', 'session-logger-test-session-789.log')
      assert(File.exist?(expected_file), 'Should share same log file')
      
      content = File.read(expected_file)
      assert_match(/\[Source1\].*Message from source 1/, content)
      assert_match(/\[Source2\].*Message from source 2/, content)
      assert_match(/\[Source1\].*Another from source 1/, content)
    end
  end

  def test_multiple_loggers_different_sessions
    ClaudeHooks::Configuration.stub(:logs_directory, @logs_dir) do
      logger1 = ClaudeHooks::Logger.new('session-1', @test_source)
      logger2 = ClaudeHooks::Logger.new('session-2', @test_source)
      
      logger1.log('Session 1 message')
      logger2.log('Session 2 message')
      
      session1_file = File.join(@logs_dir, 'hooks', 'session-session-1.log')
      session2_file = File.join(@logs_dir, 'hooks', 'session-session-2.log')
      
      assert(File.exist?(session1_file), 'Session 1 log file should exist')
      assert(File.exist?(session2_file), 'Session 2 log file should exist')
      
      assert_match(/Session 1 message/, File.read(session1_file))
      assert_match(/Session 2 message/, File.read(session2_file))
    end
  end

  # === Special Characters in Messages ===
  
  def test_log_message_with_special_characters
    ClaudeHooks::Configuration.stub(:logs_directory, @logs_dir) do
      logger = ClaudeHooks::Logger.new(@test_session_id, @test_source)
      
      special_message = "Message with 'quotes' and \"double quotes\" and \ttabs\n and newlines"
      logger.log(special_message)
      
      log_file = File.join(@logs_dir, 'hooks', 'session-logger-test-session-789.log')
      content = File.read(log_file)
      
      # Should preserve all special characters in the message
      assert_match(/Message with 'quotes' and "double quotes" and \ttabs\n and newlines/, content)
    end
  end
end