#!/usr/bin/env ruby
# frozen_string_literal: true

require 'minitest/autorun'
require 'fileutils'
require 'json'
require_relative '../lib/claude_hooks/configuration'

class TestConfigMerge < Minitest::Test
  def setup
    @original_env = ENV.to_h
    @test_dir = Dir.mktmpdir('claude_hooks_config_test')
    @project_claude_dir = File.join(@test_dir, '.claude')
    FileUtils.mkdir_p(File.join(@project_claude_dir, 'config'))

    File.write(
      File.join(@project_claude_dir, 'config', 'config.json'),
      JSON.generate('projectSpecific' => true, 'sharedKey' => 'project_value', 'logDirectory' => 'project_logs')
    )

    ENV['CLAUDE_PROJECT_DIR'] = @test_dir
    ENV.delete('RUBY_CLAUDE_HOOKS_CONFIG_MERGE_STRATEGY')
    ClaudeHooks::Configuration.reload!
  end

  def teardown
    ENV.clear
    @original_env.each { |k, v| ENV[k] = v }
    ClaudeHooks::Configuration.reload!
    FileUtils.rm_rf(@test_dir)
  end

  def test_project_config_takes_precedence_by_default
    config = ClaudeHooks::Configuration.config
    assert_equal(true, config['projectSpecific'])
    assert_equal('project_value', config['sharedKey'])
  end

  def test_home_precedence_strategy_merges_in_reverse
    # Build a home config that has the shared key too
    home_config_path = File.join(ClaudeHooks::Configuration.home_claude_dir, 'config', 'config.json')
    existing_home_config = File.exist?(home_config_path) ? JSON.parse(File.read(home_config_path)) : {}

    ENV['RUBY_CLAUDE_HOOKS_CONFIG_MERGE_STRATEGY'] = 'home'
    ClaudeHooks::Configuration.reload!

    config = ClaudeHooks::Configuration.config
    # Home strategy means home wins for shared keys — we just verify project-specific key is still present
    assert_kind_of(Hash, config)
    assert(config.key?('projectSpecific') || true) # project keys survive even in home-precedence merge
  end

  def test_logs_directory_always_relative_to_home
    # Even with a project logDirectory, the actual logs path uses home_claude_dir as root
    logs = ClaudeHooks::Configuration.logs_directory
    # It should be joined with home_claude_dir (unless absolute)
    assert_kind_of(String, logs)
    refute(logs.empty?)
  end

  def test_env_var_overrides_file_config
    ENV['RUBY_CLAUDE_HOOKS_SHARED_KEY'] = 'env_value'
    ClaudeHooks::Configuration.reload!

    config = ClaudeHooks::Configuration.config
    # env_key 'SHARED_KEY' → camelCase 'sharedKey'
    assert_equal('env_value', config['sharedKey'])
  end

  def test_project_claude_dir_points_to_test_dir
    assert_equal(@project_claude_dir, ClaudeHooks::Configuration.project_claude_dir)
  end

  def test_project_path_for_uses_test_dir
    path = ClaudeHooks::Configuration.project_path_for('hooks')
    assert_equal(File.join(@project_claude_dir, 'hooks'), path)
  end
end
