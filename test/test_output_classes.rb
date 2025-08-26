#!/usr/bin/env ruby

require_relative '../lib/claude_hooks'
require_relative '../lib/claude_hooks/output/base'
require_relative '../lib/claude_hooks/output/pre_tool_use'
require_relative '../lib/claude_hooks/output/user_prompt_submit'
require_relative '../lib/claude_hooks/output/post_tool_use'
require_relative '../lib/claude_hooks/output/stop'
require_relative '../lib/claude_hooks/output/subagent_stop'
require_relative '../lib/claude_hooks/output/notification'
require_relative '../lib/claude_hooks/output/session_start'
require_relative '../lib/claude_hooks/output/pre_compact'

def test(description)
  print "Testing: #{description}... "
  begin
    yield
    puts "✓ PASSED"
  rescue => e
    puts "✗ FAILED: #{e.message}"
    puts e.backtrace.first if e.backtrace
  end
end

def assert(condition, message = "Assertion failed")
  raise message unless condition
end

def assert_equal(expected, actual, message = nil)
  message ||= "Expected #{expected.inspect}, got #{actual.inspect}"
  assert(expected == actual, message)
end

puts "=== Testing Output Classes ==="

# Test PreToolUse Output
test "PreToolUse output with allow permission" do
  data = {
    'continue' => true,
    'hookSpecificOutput' => {
      'permissionDecision' => 'allow',
      'permissionDecisionReason' => 'Safe tool'
    }
  }
  
  output = ClaudeHooks::Output::PreToolUse.new(data)
  
  assert_equal('allow', output.permission_decision)
  assert_equal('Safe tool', output.permission_reason)
  assert(output.allowed?)
  assert(!output.denied?)
  assert(!output.should_ask_permission?)
  assert_equal(0, output.exit_code)
  assert_equal(:stdout, output.output_stream)
end

test "PreToolUse output with deny permission" do
  data = {
    'continue' => true,
    'hookSpecificOutput' => {
      'permissionDecision' => 'deny',
      'permissionDecisionReason' => 'Dangerous tool'
    }
  }
  
  output = ClaudeHooks::Output::PreToolUse.new(data)
  
  assert_equal('deny', output.permission_decision)
  assert(output.denied?)
  assert_equal(1, output.exit_code)
  assert_equal(:stderr, output.output_stream)
end

test "PreToolUse output with ask permission" do
  data = {
    'continue' => true,
    'hookSpecificOutput' => {
      'permissionDecision' => 'ask',
      'permissionDecisionReason' => 'Need user approval'
    }
  }
  
  output = ClaudeHooks::Output::PreToolUse.new(data)
  
  assert(output.should_ask_permission?)
  assert_equal(2, output.exit_code)
  assert_equal(:stderr, output.output_stream)
end

test "PreToolUse output with continue false overrides permission" do
  data = {
    'continue' => false,
    'stopReason' => 'Error occurred',
    'hookSpecificOutput' => {
      'permissionDecision' => 'allow'
    }
  }
  
  output = ClaudeHooks::Output::PreToolUse.new(data)
  
  assert_equal(1, output.exit_code) # continue false wins
  assert_equal(:stderr, output.output_stream)
end

# Test UserPromptSubmit Output
test "UserPromptSubmit output with normal behavior" do
  data = {
    'continue' => true,
    'hookSpecificOutput' => {
      'additionalContext' => 'Some context'
    }
  }
  
  output = ClaudeHooks::Output::UserPromptSubmit.new(data)
  
  assert_equal('Some context', output.additional_context)
  assert(!output.blocked?)
  assert_equal(0, output.exit_code)
  assert_equal(:stdout, output.output_stream)
end

test "UserPromptSubmit output with blocked decision" do
  data = {
    'continue' => true,
    'decision' => 'block',
    'reason' => 'Bad content detected'
  }
  
  output = ClaudeHooks::Output::UserPromptSubmit.new(data)
  
  assert_equal('block', output.decision)
  assert_equal('Bad content detected', output.reason)
  assert(output.blocked?)
  assert_equal(2, output.exit_code)
  assert_equal(:stderr, output.output_stream)
end

# Test Stop Output
test "Stop output with normal stopping" do
  data = {
    'continue' => true
  }
  
  output = ClaudeHooks::Output::Stop.new(data)
  
  assert(output.should_stop?)
  assert(!output.should_continue?)
  assert_equal(0, output.exit_code)
  assert_equal(:stdout, output.output_stream)
end

test "Stop output with force continue (decision: block)" do
  data = {
    'continue' => true,
    'decision' => 'block',
    'reason' => 'Continue with more tasks'
  }
  
  output = ClaudeHooks::Output::Stop.new(data)
  
  assert_equal('block', output.decision)
  assert_equal('Continue with more tasks', output.reason)
  assert_equal('Continue with more tasks', output.continue_instructions)
  assert(output.should_continue?)
  assert(!output.should_stop?)
  assert_equal(2, output.exit_code) # Force continue
  assert_equal(:stderr, output.output_stream)
end

# Test simple outputs
test "Notification output basic behavior" do
  data = { 'continue' => true }
  output = ClaudeHooks::Output::Notification.new(data)
  
  assert_equal(0, output.exit_code)
  assert_equal(:stdout, output.output_stream)
end

# Test Factory Method
test "Factory method creates correct output classes" do
  data = { 'continue' => true }
  
  pre_tool_output = ClaudeHooks::Output::Base.for_hook_type('PreToolUse', data)
  assert(pre_tool_output.is_a?(ClaudeHooks::Output::PreToolUse))
  
  user_prompt_output = ClaudeHooks::Output::Base.for_hook_type('UserPromptSubmit', data)
  assert(user_prompt_output.is_a?(ClaudeHooks::Output::UserPromptSubmit))
  
  stop_output = ClaudeHooks::Output::Base.for_hook_type('Stop', data)
  assert(stop_output.is_a?(ClaudeHooks::Output::Stop))
end

# Test Merging
test "PreToolUse merge with deny winning over allow" do
  data1 = {
    'continue' => true,
    'hookSpecificOutput' => {
      'permissionDecision' => 'allow',
      'permissionDecisionReason' => 'Safe'
    }
  }
  
  data2 = {
    'continue' => true,
    'hookSpecificOutput' => {
      'permissionDecision' => 'deny',
      'permissionDecisionReason' => 'Dangerous'
    }
  }
  
  output1 = ClaudeHooks::Output::PreToolUse.new(data1)
  output2 = ClaudeHooks::Output::PreToolUse.new(data2)
  
  merged = ClaudeHooks::Output::PreToolUse.merge(output1, output2)
  
  assert_equal('deny', merged.permission_decision)
  assert(merged.permission_reason.include?('Safe'))
  assert(merged.permission_reason.include?('Dangerous'))
  assert_equal(1, merged.exit_code)
end

test "UserPromptSubmit merge with context joining" do
  data1 = {
    'continue' => true,
    'hookSpecificOutput' => {
      'additionalContext' => 'Context 1'
    }
  }
  
  data2 = {
    'continue' => true,
    'hookSpecificOutput' => {
      'additionalContext' => 'Context 2'
    }
  }
  
  output1 = ClaudeHooks::Output::UserPromptSubmit.new(data1)
  output2 = ClaudeHooks::Output::UserPromptSubmit.new(data2)
  
  merged = ClaudeHooks::Output::UserPromptSubmit.merge(output1, output2)
  
  assert(merged.additional_context.include?('Context 1'))
  assert(merged.additional_context.include?('Context 2'))
end

puts "\n=== All Tests Completed ==="