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

    @test_hook = Class.new(ClaudeHooks::Notification) do
      def call
        @output_data
      end
    end
  end

  # === CLI.run_hook Tests ===
  # run_hook reads from STDIN. We swap it with a StringIO for the duration.

  def test_run_hook_simple_hook_form_calls_output_and_exit
    with_stdin(JSON.generate(@test_input_data)) do
      assert_raises(SystemExit) do
        ClaudeHooks::CLI.run_hook(@test_hook)
      end
    end
  end

  def test_run_hook_block_form_receives_parsed_input
    received = nil
    with_stdin(JSON.generate(@test_input_data)) do
      ClaudeHooks::CLI.run_hook do |input_data|
        received = input_data
      end
    end

    assert_equal('cli-test-session', received['session_id'])
    assert_equal('Notification', received['hook_event_name'])
  end

  def test_run_hook_invalid_json_exits_1
    exit_status = nil
    with_stdin('not valid json{') do
      begin
        ClaudeHooks::CLI.run_hook(@test_hook)
      rescue SystemExit => e
        exit_status = e.status
      end
    end
    assert_equal(1, exit_status)
  end

  def test_run_hook_error_exits_1
    error_hook = Class.new(ClaudeHooks::Notification) do
      def call
        raise StandardError, 'boom'
      end
    end

    with_stdin(JSON.generate(@test_input_data)) do
      assert_raises(SystemExit) do
        ClaudeHooks::CLI.run_hook(error_hook)
      end
    end
  end

  def test_run_hook_no_args_no_block_exits_1
    with_stdin(JSON.generate(@test_input_data)) do
      assert_raises(SystemExit) do
        ClaudeHooks::CLI.run_hook
      end
    end
  end

  def test_run_hook_on_error_block_hook_error_exits_2
    error_hook = Class.new(ClaudeHooks::Notification) do
      def call
        raise StandardError, 'boom'
      end
    end

    exit_status = nil
    with_stdin(JSON.generate(@test_input_data)) do
      begin
        ClaudeHooks::CLI.run_hook(error_hook, on_error: :block)
      rescue SystemExit => e
        exit_status = e.status
      end
    end
    assert_equal(2, exit_status)
  end

  def test_run_hook_on_error_block_writes_plain_text_not_json
    error_hook = Class.new(ClaudeHooks::Notification) do
      def call
        raise StandardError, 'boom'
      end
    end

    stderr = capture_stderr do
      with_stdin(JSON.generate(@test_input_data)) do
        begin
          ClaudeHooks::CLI.run_hook(error_hook, on_error: :block)
        rescue SystemExit
          # expected
        end
      end
    end

    # Exit-2 stderr is shown to Claude as plain text, so it must not be JSON.
    assert_match(/Hook execution error: boom/, stderr)
    refute_match(/"continue"/, stderr)
    refute_match(/"suppressOutput"/, stderr)
  end

  def test_run_hook_on_error_block_invalid_json_exits_2
    exit_status = nil
    with_stdin('not valid json{') do
      begin
        ClaudeHooks::CLI.run_hook(@test_hook, on_error: :block)
      rescue SystemExit => e
        exit_status = e.status
      end
    end
    assert_equal(2, exit_status)
  end

  def test_run_hook_on_error_allow_hook_error_exits_1
    error_hook = Class.new(ClaudeHooks::Notification) do
      def call
        raise StandardError, 'boom'
      end
    end

    exit_status = nil
    with_stdin(JSON.generate(@test_input_data)) do
      begin
        ClaudeHooks::CLI.run_hook(error_hook, on_error: :allow)
      rescue SystemExit => e
        exit_status = e.status
      end
    end
    assert_equal(1, exit_status)
  end

  # === CLI.entrypoint deprecation ===

  def test_entrypoint_emits_deprecation_warning
    warning = nil
    with_stdin(JSON.generate(@test_input_data)) do
      original_warn = method(:warn)
      ClaudeHooks::CLI.stub(:warn, ->(msg) { warning = msg }) do
        begin
          ClaudeHooks::CLI.entrypoint(@test_hook)
        rescue SystemExit
          # expected
        end
      end
    end
    assert_match(/deprecated/, warning)
    assert_match(/run_hook/, warning)
  end

  # === CLI.test_runner and run_with_sample_data ===

  def test_run_with_sample_data
    result = ClaudeHooks::CLI.run_with_sample_data(@test_hook)
    assert_kind_of(Hash, result)
    assert(result['continue'])
  end

  def test_run_with_sample_data_with_overrides
    result = ClaudeHooks::CLI.run_with_sample_data(@test_hook, { 'message' => 'Custom message' })
    assert_kind_of(Hash, result)
    assert(result['continue'])
  end

  def test_test_runner_reads_stdin
    result = nil
    with_stdin(JSON.generate(@test_input_data)) do
      result = ClaudeHooks::CLI.test_runner(@test_hook)
    end
    assert_kind_of(Hash, result)
    assert(result['continue'])
  end

  private

  def with_stdin(content)
    fake = StringIO.new(content)
    old = Object.send(:remove_const, :STDIN)
    Object.const_set(:STDIN, fake)
    yield
  ensure
    Object.send(:remove_const, :STDIN)
    Object.const_set(:STDIN, old)
  end

  def capture_stderr
    fake = StringIO.new
    old = Object.send(:remove_const, :STDERR)
    Object.const_set(:STDERR, fake)
    yield
    fake.string
  ensure
    Object.send(:remove_const, :STDERR)
    Object.const_set(:STDERR, old)
  end
end
