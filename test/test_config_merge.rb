#!/usr/bin/env ruby

require_relative '../lib/claude_hooks/configuration'
require 'fileutils'
require 'json'

# Test configuration merging functionality
class TestConfigMerging
  TEST_PROJECT_DIR = '/tmp/test_claude_project'
  
  def self.run
    setup_test_environment
    
    puts "=== Testing Config Merging ==="
    test_config_existence
    test_default_merge_strategy
    test_home_precedence_strategy
    test_logs_directory
    
    cleanup_test_environment
    puts "\n=== Merge test completed! ==="
  end

  private

  def self.setup_test_environment
    # Create test project structure
    FileUtils.mkdir_p("#{TEST_PROJECT_DIR}/.claude/config")
    
    # Create test project config
    project_config = {
      "projectSpecific" => true,
      "logDirectory" => "project_logs",
      "userName" => "project_user"
    }
    File.write("#{TEST_PROJECT_DIR}/.claude/config/config.json", JSON.pretty_generate(project_config))
    
    # Set environment
    ENV['CLAUDE_PROJECT_DIR'] = TEST_PROJECT_DIR
    ClaudeHooks::Configuration.reload!
  end

  def self.cleanup_test_environment
    ENV.delete('CLAUDE_PROJECT_DIR')
    ENV.delete('CLAUDE_HOOKS_CONFIG_MERGE_STRATEGY')
    ClaudeHooks::Configuration.reload!
    FileUtils.rm_rf(TEST_PROJECT_DIR)
  end

  def self.test_config_existence
    puts "Home config exists: #{File.exist?(ClaudeHooks::Configuration.send(:home_config_file_path))}"
    puts "Project config exists: #{File.exist?(ClaudeHooks::Configuration.send(:project_config_file_path))}"
  end

  def self.test_default_merge_strategy
    puts "\n--- Default merge strategy (project takes precedence) ---"
    config = ClaudeHooks::Configuration.config
    puts "Merged config:"
    config.each { |k, v| puts "  #{k}: #{v}" }
  end

  def self.test_home_precedence_strategy
    puts "\n--- Home precedence strategy ---"
    ENV['CLAUDE_HOOKS_CONFIG_MERGE_STRATEGY'] = 'home'
    ClaudeHooks::Configuration.reload!
    config = ClaudeHooks::Configuration.config
    puts "Merged config with home precedence:"
    config.each { |k, v| puts "  #{k}: #{v}" }
  end

  def self.test_logs_directory
    puts "\n--- Logs directory (should always use home base) ---"
    ENV['CLAUDE_HOOKS_CONFIG_MERGE_STRATEGY'] = 'project'
    ClaudeHooks::Configuration.reload!
    puts "Logs directory: #{ClaudeHooks::Configuration.logs_directory}"
  end
end

TestConfigMerging.run if __FILE__ == $0