#!/usr/bin/env ruby

require_relative '../lib/claude_hooks/configuration'

# Test basic configuration functionality
class TestConfiguration
  def self.run
    puts "=== Testing Configuration with no CLAUDE_PROJECT_DIR ==="
    test_no_project_dir
    
    puts "\n=== Testing with CLAUDE_PROJECT_DIR set ==="
    test_with_project_dir
    
    puts "\n=== Test completed successfully! ==="
  end

  private

  def self.test_no_project_dir
    # Clear any existing CLAUDE_PROJECT_DIR to simulate the case where it's not set
    ENV.delete('CLAUDE_PROJECT_DIR')
    ClaudeHooks::Configuration.reload!

    puts "Home Claude dir: #{ClaudeHooks::Configuration.home_claude_dir}"
    puts "Project Claude dir: #{ClaudeHooks::Configuration.project_claude_dir.inspect}" # Use inspect to show nil clearly
    puts "Base dir (legacy): #{ClaudeHooks::Configuration.base_dir}"
    puts "Logs directory: #{ClaudeHooks::Configuration.logs_directory}"

    puts "\n--- Path Methods ---"
    puts "Home path for 'config': #{ClaudeHooks::Configuration.home_path_for('config')}"
    puts "Project path for 'config': #{ClaudeHooks::Configuration.project_path_for('config').inspect}"

    puts "\n--- Config File Paths ---"
    puts "Home config path: #{ClaudeHooks::Configuration.send(:home_config_file_path)}"
    puts "Project config path: #{ClaudeHooks::Configuration.send(:project_config_file_path).inspect}"

    puts "\n--- Config Loading Test ---"
    config = ClaudeHooks::Configuration.config
    puts "Config loaded successfully: #{!config.nil?}"
    puts "Config keys: #{config.keys.join(', ')}" if config.any?
  end

  def self.test_with_project_dir
    ENV['CLAUDE_PROJECT_DIR'] = '/tmp/test_project'
    ClaudeHooks::Configuration.reload!

    puts "Project Claude dir with env set: #{ClaudeHooks::Configuration.project_claude_dir}"
    puts "Project path for 'config': #{ClaudeHooks::Configuration.project_path_for('config')}"
    puts "Project config path: #{ClaudeHooks::Configuration.send(:project_config_file_path)}"

    # Clean up
    ENV.delete('CLAUDE_PROJECT_DIR')
    ClaudeHooks::Configuration.reload!
  end
end

TestConfiguration.run if __FILE__ == $0