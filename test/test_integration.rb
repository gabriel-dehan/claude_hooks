#!/usr/bin/env ruby

require 'stringio'
require_relative '../lib/claude_hooks'
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

puts "\n=== Testing New Entrypoint Helper ==="

# Test the new CLI.entrypoint helper
begin
  puts "Testing ClaudeHooks::CLI.entrypoint with AppendRules..."
  # This would normally exit, so we can't easily test it in this context
  # But we can test that the method exists and accepts the right parameters
  
  # Create a simple test that doesn't exit
  test_input = StringIO.new('{"session_id":"test","prompt":"test"}')
  original_stdin = $stdin
  $stdin = test_input
  
  # We can't actually run entrypoint because it would exit, but we can test its existence
  puts "CLI.entrypoint method exists: #{ClaudeHooks::CLI.respond_to?(:entrypoint)}"
  
  $stdin = original_stdin
rescue => e
  puts "Error: #{e.message}"
  $stdin = original_stdin if original_stdin
end

puts "\n=== Integration Tests Complete ==="