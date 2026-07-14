#!/usr/bin/env ruby

# Simple test runner for claude_hooks configuration tests

puts "🧪 Running Claude Hooks Configuration Tests"
puts "=" * 50

test_files = [
  'test_config.rb',
  'test_config_merge.rb',
  'test_integration.rb',
  'test_output_classes.rb',
  'test_hook_classes.rb',
  'test_base.rb',
  'test_cli_simple.rb',
  'test_full_integration.rb',
  'test_logger.rb',
  'test_error_handling_simple.rb',
  'test_new_hooks.rb',
  'test_new_output_classes.rb',
  'test_backward_compat.rb'
]

test_files.each do |test_file|
  puts "\n🔍 Running #{test_file}..."
  puts "-" * 30
  
  success = system("ruby #{File.join(__dir__, test_file)}")
  
  if success
    puts "✅ #{test_file} passed"
  else
    puts "❌ #{test_file} failed"
    exit 1
  end
end

puts "\n🎉 All tests passed!"