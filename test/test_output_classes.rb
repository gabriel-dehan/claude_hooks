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
require_relative '../lib/claude_hooks/output/session_end'
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
    assert_equal(2, output.exit_code)
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
    assert_equal(0, output.exit_code)
    assert_equal(:stdout, output.output_stream)
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
    
    assert_equal(2, output.exit_code) # continue false wins
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
    assert_equal(2, merged.exit_code)
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
    assert_equal(2, merged.exit_code) # PostToolUse uses exit code 2 when blocked
  end

  # === STOP OUTPUT MERGE TESTS ===

  def test_stop_merge_with_multiple_continue_instructions
    data1 = {
      'continue' => true,
      'decision' => 'block',
      'reason' => 'Continue with task A'
    }
    
    data2 = {
      'continue' => true,
      'decision' => 'block', 
      'reason' => 'Continue with task B'
    }
    
    output1 = ClaudeHooks::Output::Stop.new(data1)
    output2 = ClaudeHooks::Output::Stop.new(data2)
    
    merged = ClaudeHooks::Output::Stop.merge(output1, output2)
    
    assert_equal('block', merged.decision)
    assert_includes(merged.reason, 'Continue with task A')
    assert_includes(merged.reason, 'Continue with task B')
    assert(merged.should_continue?)
    assert_equal(2, merged.exit_code)
  end

  def test_stop_merge_normal_with_block_decision
    data1 = {
      'continue' => true
    }
    
    data2 = {
      'continue' => true,
      'decision' => 'block',
      'reason' => 'Force continue'
    }
    
    output1 = ClaudeHooks::Output::Stop.new(data1)
    output2 = ClaudeHooks::Output::Stop.new(data2)
    
    merged = ClaudeHooks::Output::Stop.merge(output1, output2)
    
    assert_equal('block', merged.decision)
    assert_equal('Force continue', merged.reason)
    assert(merged.should_continue?)
    assert_equal(2, merged.exit_code)
  end

  # === SUBAGENT STOP MERGE TESTS ===

  def test_subagent_stop_merge_inherits_stop_behavior
    data1 = {
      'continue' => true,
      'decision' => 'block',
      'reason' => 'Subagent continue instruction'
    }
    
    data2 = {
      'continue' => true,
      'decision' => 'block',
      'reason' => 'Another instruction'
    }
    
    output1 = ClaudeHooks::Output::SubagentStop.new(data1)
    output2 = ClaudeHooks::Output::SubagentStop.new(data2)
    
    merged = ClaudeHooks::Output::SubagentStop.merge(output1, output2)
    
    assert_instance_of(ClaudeHooks::Output::SubagentStop, merged)
    assert_equal('block', merged.decision)
    assert_includes(merged.reason, 'Subagent continue instruction')
    assert_includes(merged.reason, 'Another instruction')
    assert_equal(2, merged.exit_code)
  end

  # === SESSION START MERGE TESTS ===

  def test_session_start_merge_with_context_joining
    data1 = {
      'continue' => true,
      'hookSpecificOutput' => {
        'additionalContext' => 'Session context 1'
      }
    }
    
    data2 = {
      'continue' => true,
      'hookSpecificOutput' => {
        'additionalContext' => 'Session context 2'
      }
    }
    
    output1 = ClaudeHooks::Output::SessionStart.new(data1)
    output2 = ClaudeHooks::Output::SessionStart.new(data2)
    
    merged = ClaudeHooks::Output::SessionStart.merge(output1, output2)
    
    assert_includes(merged.additional_context, 'Session context 1')
    assert_includes(merged.additional_context, 'Session context 2')
    assert_equal('SessionStart', merged.hook_specific_output['hookEventName'])
    assert_equal(0, merged.exit_code)
  end

  def test_session_start_merge_with_empty_context
    data1 = {
      'continue' => true,
      'hookSpecificOutput' => {
        'additionalContext' => 'Only context'
      }
    }
    
    data2 = {
      'continue' => true
    }
    
    output1 = ClaudeHooks::Output::SessionStart.new(data1)
    output2 = ClaudeHooks::Output::SessionStart.new(data2)
    
    merged = ClaudeHooks::Output::SessionStart.merge(output1, output2)
    
    assert_equal('Only context', merged.additional_context)
  end

  # === NOTIFICATION MERGE TESTS ===

  def test_notification_merge_basic_behavior
    data1 = {
      'continue' => true,
      'suppressOutput' => false
    }
    
    data2 = {
      'continue' => false,
      'stopReason' => 'Notification error',
      'suppressOutput' => true
    }
    
    output1 = ClaudeHooks::Output::Notification.new(data1)
    output2 = ClaudeHooks::Output::Notification.new(data2)
    
    merged = ClaudeHooks::Output::Notification.merge(output1, output2)
    
    refute(merged.continue?)
    assert(merged.suppress_output?)
    assert_equal('Notification error', merged.stop_reason)
    assert_equal(1, merged.exit_code)
  end

  # === PRE COMPACT MERGE TESTS ===

  def test_pre_compact_merge_basic_behavior
    data1 = {
      'continue' => true,
      'suppressOutput' => false
    }
    
    data2 = {
      'continue' => false,
      'stopReason' => 'Compaction error'
    }
    
    output1 = ClaudeHooks::Output::PreCompact.new(data1)
    output2 = ClaudeHooks::Output::PreCompact.new(data2)
    
    merged = ClaudeHooks::Output::PreCompact.merge(output1, output2)
    
    refute(merged.continue?)
    assert_equal('Compaction error', merged.stop_reason)
    assert_equal(1, merged.exit_code)
  end

  # === EDGE CASE MERGE TESTS ===

  def test_merge_with_empty_array
    merged = ClaudeHooks::Output::UserPromptSubmit.merge()
    
    # Empty merge should return a default instance (handled by base class)
    assert_instance_of(ClaudeHooks::Output::UserPromptSubmit, merged)
    assert(merged.continue?)
    refute(merged.suppress_output?)
    assert_equal('', merged.stop_reason)
    assert_equal(0, merged.exit_code)
  end

  def test_merge_with_single_output
    data = {
      'continue' => true,
      'decision' => 'block',
      'reason' => 'Single reason'
    }
    
    output = ClaudeHooks::Output::UserPromptSubmit.new(data)
    merged = ClaudeHooks::Output::UserPromptSubmit.merge(output)
    
    # Single input should return the same object
    assert_equal(output, merged)
    assert_equal('block', merged.decision)
    assert_equal('Single reason', merged.reason)
  end

  def test_merge_with_nil_outputs
    data = {
      'continue' => true,
      'hookSpecificOutput' => {
        'permissionDecision' => 'deny',
        'permissionDecisionReason' => 'Blocked'
      }
    }
    
    output = ClaudeHooks::Output::PreToolUse.new(data)
    merged = ClaudeHooks::Output::PreToolUse.merge(output, nil, output)
    
    # Should handle nil inputs gracefully
    assert_equal('deny', merged.permission_decision)
    assert_includes(merged.permission_reason, 'Blocked')
  end

  def test_base_merge_continue_false_wins
    data1 = {
      'continue' => true,
      'suppressOutput' => false
    }
    
    data2 = {
      'continue' => false,
      'stopReason' => 'Error occurred',
      'suppressOutput' => true
    }
    
    output1 = ClaudeHooks::Output::Notification.new(data1)
    output2 = ClaudeHooks::Output::Notification.new(data2)
    
    merged = ClaudeHooks::Output::Notification.merge(output1, output2)
    
    refute(merged.continue?) # continue: false wins
    assert(merged.suppress_output?) # suppressOutput: true wins
    assert_equal('Error occurred', merged.stop_reason)
  end

  def test_pre_tool_use_merge_ask_over_allow
    data1 = {
      'continue' => true,
      'hookSpecificOutput' => {
        'permissionDecision' => 'allow',
        'permissionDecisionReason' => 'Safe tool'
      }
    }
    
    data2 = {
      'continue' => true,
      'hookSpecificOutput' => {
        'permissionDecision' => 'ask',
        'permissionDecisionReason' => 'Needs approval'
      }
    }
    
    output1 = ClaudeHooks::Output::PreToolUse.new(data1)
    output2 = ClaudeHooks::Output::PreToolUse.new(data2)
    
    merged = ClaudeHooks::Output::PreToolUse.merge(output1, output2)
    
    assert_equal('ask', merged.permission_decision) # ask wins over allow
    assert_includes(merged.permission_reason, 'Safe tool')
    assert_includes(merged.permission_reason, 'Needs approval')
    assert_equal(0, merged.exit_code)
  end

  # === SESSION END TESTS ===

  def test_session_end_output_basic_behavior
    data = { 'continue' => true }
    output = ClaudeHooks::Output::SessionEnd.new(data)
    
    assert_equal(0, output.exit_code) # SessionEnd always returns 0
    assert_equal(:stdout, output.output_stream)
    assert(output.continue?)
    refute(output.suppress_output?)
  end

  def test_session_end_output_with_continue_false
    data = { 'continue' => false, 'stopReason' => 'Some error' }
    output = ClaudeHooks::Output::SessionEnd.new(data)
    
    assert_equal(0, output.exit_code) # SessionEnd always returns 0 regardless
    assert_equal(:stdout, output.output_stream)
    refute(output.continue?)
    assert_equal('Some error', output.stop_reason)
  end

  def test_session_end_merge_basic_behavior
    data1 = {
      'continue' => true,
      'suppressOutput' => false
    }
    
    data2 = {
      'continue' => false,
      'stopReason' => 'Session error',
      'suppressOutput' => true
    }
    
    output1 = ClaudeHooks::Output::SessionEnd.new(data1)
    output2 = ClaudeHooks::Output::SessionEnd.new(data2)
    
    merged = ClaudeHooks::Output::SessionEnd.merge(output1, output2)
    
    refute(merged.continue?) # Base merge logic applies
    assert(merged.suppress_output?)
    assert_equal('Session error', merged.stop_reason)
    assert_equal(0, merged.exit_code) # SessionEnd always 0
  end

  def test_session_end_merge_empty_outputs
    merged = ClaudeHooks::Output::SessionEnd.merge()
    
    assert_instance_of(ClaudeHooks::Output::SessionEnd, merged)
    assert(merged.continue?)
    refute(merged.suppress_output?)
    assert_equal('', merged.stop_reason)
    assert_equal(0, merged.exit_code)
  end

  def test_session_end_merge_single_output
    data = {
      'continue' => true,
      'stopReason' => 'Single session end'
    }
    
    output = ClaudeHooks::Output::SessionEnd.new(data)
    merged = ClaudeHooks::Output::SessionEnd.merge(output)
    
    # Single input should return equivalent data
    assert_equal(output.data, merged.data)
    assert_equal('Single session end', merged.stop_reason)
    assert_equal(0, merged.exit_code)
  end
end