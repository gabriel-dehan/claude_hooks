#!/usr/bin/env ruby
# frozen_string_literal: true

require 'minitest/autorun'
require 'fileutils'
require_relative '../lib/claude_hooks/configuration'

class TestConfiguration < Minitest::Test
  def setup
    @original_env = ENV.to_h
    ENV.delete('CLAUDE_PROJECT_DIR')
    ENV.delete('RUBY_CLAUDE_HOOKS_BASE_DIR')
    ClaudeHooks::Configuration.reload!
  end

  def teardown
    ENV.clear
    @original_env.each { |k, v| ENV[k] = v }
    ClaudeHooks::Configuration.reload!
  end

  def test_home_claude_dir_is_dot_claude_under_home
    assert_equal(File.expand_path('~/.claude'), ClaudeHooks::Configuration.home_claude_dir)
  end

  def test_project_claude_dir_is_nil_without_env
    assert_nil(ClaudeHooks::Configuration.project_claude_dir)
  end

  def test_project_claude_dir_uses_env_var
    ENV['CLAUDE_PROJECT_DIR'] = '/tmp/test_project'
    ClaudeHooks::Configuration.reload!
    assert_equal('/tmp/test_project/.claude', ClaudeHooks::Configuration.project_claude_dir)
  end

  def test_base_dir_defaults_to_home_claude_dir
    assert_equal(ClaudeHooks::Configuration.home_claude_dir, ClaudeHooks::Configuration.base_dir)
  end

  def test_base_dir_uses_legacy_env_var
    ENV['RUBY_CLAUDE_HOOKS_BASE_DIR'] = '/custom/base'
    ClaudeHooks::Configuration.reload!
    assert_equal('/custom/base', ClaudeHooks::Configuration.base_dir)
  end

  def test_home_path_for_joins_with_home_claude_dir
    path = ClaudeHooks::Configuration.home_path_for('config')
    assert_equal(File.join(ClaudeHooks::Configuration.home_claude_dir, 'config'), path)
  end

  def test_project_path_for_returns_nil_without_env
    assert_nil(ClaudeHooks::Configuration.project_path_for('config'))
  end

  def test_project_path_for_joins_with_project_claude_dir
    ENV['CLAUDE_PROJECT_DIR'] = '/tmp/test_project'
    ClaudeHooks::Configuration.reload!
    assert_equal('/tmp/test_project/.claude/config', ClaudeHooks::Configuration.project_path_for('config'))
  end

  def test_logs_directory_defaults_to_home_logs
    expected = File.join(ClaudeHooks::Configuration.home_claude_dir, 'logs')
    assert_equal(expected, ClaudeHooks::Configuration.logs_directory)
  end

  def test_logs_directory_uses_absolute_path_from_env
    ENV['RUBY_CLAUDE_HOOKS_LOG_DIR'] = '/absolute/logs'
    ClaudeHooks::Configuration.reload!
    assert_equal('/absolute/logs', ClaudeHooks::Configuration.logs_directory)
  end

  def test_config_returns_hash
    config = ClaudeHooks::Configuration.config
    assert_kind_of(Hash, config)
  end

  def test_reload_clears_memoized_values
    original = ClaudeHooks::Configuration.home_claude_dir
    ClaudeHooks::Configuration.reload!
    assert_equal(original, ClaudeHooks::Configuration.home_claude_dir)
  end
end
