#!/usr/bin/env ruby

# Ensure we load the local version, not the gem
$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))

require 'stringio'
require 'claude_hooks'
require_relative '../example_dotclaude/hooks/handlers/user_prompt_submit/append_rules'

puts "=== Testing Integration with Existing Hooks ==="

# Test data
input_data = {
  'session_id' => 'test-session',
  'transcript_path' => '/tmp/test',
  'cwd' => '/tmp',
  'hook_event_name' => 'UserPromptSubmit',
  'prompt' => 'Hello Claude'
}

# Create the hook
hook = AppendRules.new(input_data)
puts "Hook class: #{hook.class}"
puts "Hook type: #{hook.hook_type}"
result = hook.call

puts "Hook result: #{result.inspect}"

# Test the new output method
begin
  output = hook.output
  puts "Output object class: #{output.class}"
  puts "Output object is UserPromptSubmit?: #{output.is_a?(ClaudeHooks::Output::UserPromptSubmit)}"
  puts "Continue?: #{output.continue?}"
  puts "Stop reason: '#{output.stop_reason}'"
  puts "Exit code: #{output.exit_code}"
  puts "Output stream: #{output.output_stream}"
  puts "Blocked?: #{output.blocked?}"
  puts "Additional context: '#{output.additional_context}'"
  puts "JSON: #{output.to_json}"
rescue => e
  puts "Error testing output: #{e.message}"
  puts e.backtrace.first if e.backtrace
end

puts "\n=== Testing CLI.run_hook Helper ==="

begin
  puts "Testing ClaudeHooks::CLI.run_hook..."
  test_input = StringIO.new('{"session_id":"test","prompt":"test"}')
  original_stdin = $stdin
  $stdin = test_input

  puts "CLI.run_hook method exists: #{ClaudeHooks::CLI.respond_to?(:run_hook)}"
  puts "CLI.entrypoint (deprecated alias) exists: #{ClaudeHooks::CLI.respond_to?(:entrypoint)}"
  puts "Available CLI public methods: #{ClaudeHooks::CLI.methods(false).sort}"

  $stdin = original_stdin
rescue => e
  puts "Error: #{e.message}"
  $stdin = original_stdin if original_stdin
end

puts "\n=== Integration Tests Complete ==="