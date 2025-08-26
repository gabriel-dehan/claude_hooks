#!/usr/bin/env ruby

require 'minitest/autorun'
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

class TestOutputClasses < Minitest::Test

  # Test PreToolUse Output
  def test_pre_tool_use_output_with_allow_permission
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
    refute(output.denied?)
    refute(output.should_ask_permission?)
    assert_equal(0, output.exit_code)
    assert_equal(:stdout, output.output_stream)
  end

  def test_pre_tool_use_output_with_deny_permission
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

  def test_pre_tool_use_output_with_ask_permission
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

  def test_pre_tool_use_output_with_continue_false_overrides_permission
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
  def test_user_prompt_submit_output_with_normal_behavior
    data = {
      'continue' => true,
      'hookSpecificOutput' => {
        'additionalContext' => 'Some context'
      }
    }
    
    output = ClaudeHooks::Output::UserPromptSubmit.new(data)
    
    assert_equal('Some context', output.additional_context)
    refute(output.blocked?)
    assert_equal(0, output.exit_code)
    assert_equal(:stdout, output.output_stream)
  end

  def test_user_prompt_submit_output_with_blocked_decision
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
  def test_stop_output_with_normal_stopping
    data = {
      'continue' => true
    }
    
    output = ClaudeHooks::Output::Stop.new(data)
    
    assert(output.should_stop?)
    refute(output.should_continue?)
    assert_equal(0, output.exit_code)
    assert_equal(:stdout, output.output_stream)
  end

  def test_stop_output_with_force_continue_decision_block
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
    refute(output.should_stop?)
    assert_equal(2, output.exit_code) # Force continue
    assert_equal(:stderr, output.output_stream)
  end

  # Test simple outputs
  def test_notification_output_basic_behavior
    data = { 'continue' => true }
    output = ClaudeHooks::Output::Notification.new(data)
    
    assert_equal(0, output.exit_code)
    assert_equal(:stdout, output.output_stream)
  end

  # Test Factory Method
  def test_factory_method_creates_correct_output_classes
    data = { 'continue' => true }
    
    pre_tool_output = ClaudeHooks::Output::Base.for_hook_type('PreToolUse', data)
    assert_instance_of(ClaudeHooks::Output::PreToolUse, pre_tool_output)
    
    user_prompt_output = ClaudeHooks::Output::Base.for_hook_type('UserPromptSubmit', data)
    assert_instance_of(ClaudeHooks::Output::UserPromptSubmit, user_prompt_output)
    
    stop_output = ClaudeHooks::Output::Base.for_hook_type('Stop', data)
    assert_instance_of(ClaudeHooks::Output::Stop, stop_output)
  end

  # Test Merging
  def test_pre_tool_use_merge_with_deny_winning_over_allow
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
    assert_includes(merged.permission_reason, 'Safe')
    assert_includes(merged.permission_reason, 'Dangerous')
    assert_equal(1, merged.exit_code)
  end

  def test_user_prompt_submit_merge_with_context_joining
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
    
    assert_includes(merged.additional_context, 'Context 1')
    assert_includes(merged.additional_context, 'Context 2')
  end

  def test_post_tool_use_merge_with_reason_joining
    data1 = {
      'continue' => true,
      'decision' => 'block',
      'reason' => 'First reason'
    }
    
    data2 = {
      'continue' => true,
      'decision' => 'block',
      'reason' => 'Second reason'
    }
    
    output1 = ClaudeHooks::Output::PostToolUse.new(data1)
    output2 = ClaudeHooks::Output::PostToolUse.new(data2)
    
    merged = ClaudeHooks::Output::PostToolUse.merge(output1, output2)
    
    assert_equal('block', merged.decision)
    assert_includes(merged.reason, 'First reason')
    assert_includes(merged.reason, 'Second reason')
    assert_equal(1, merged.exit_code) # PostToolUse uses exit code 1 when blocked
  end
end