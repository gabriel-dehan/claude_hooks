#!/usr/bin/env ruby

require 'minitest/autorun'
require_relative '../lib/claude_hooks'

class TestHookClasses < Minitest::Test
  def setup
    @common_input_data = {
      'session_id' => 'test-session-123',
      'transcript_path' => '/tmp/test_transcript.md',
      'cwd' => '/test/directory',
      'hook_event_name' => 'TestEvent'
    }
  end

  # === PreToolUse Tests ===
  
  def test_pre_tool_use_hook_type
    assert_equal('PreToolUse', ClaudeHooks::PreToolUse.hook_type)
  end

  def test_pre_tool_use_input_fields
    expected_fields = %w[tool_name tool_input]
    assert_equal(expected_fields, ClaudeHooks::PreToolUse.input_fields)
  end

  def test_pre_tool_use_accessors
    input_data = @common_input_data.merge({
      'tool_name' => 'TestTool',
      'tool_input' => { 'param' => 'value' }
    })
    
    hook = ClaudeHooks::PreToolUse.new(input_data)
    
    assert_equal('TestTool', hook.tool_name)
    assert_equal({ 'param' => 'value' }, hook.tool_input)
  end

  def test_pre_tool_use_approve_tool
    hook = ClaudeHooks::PreToolUse.new(@common_input_data)
    hook.approve_tool!('Safe to use')
    
    output_data = JSON.parse(hook.stringify_output)
    assert_equal('allow', output_data['hookSpecificOutput']['permissionDecision'])
    assert_equal('Safe to use', output_data['hookSpecificOutput']['permissionDecisionReason'])
  end

  def test_pre_tool_use_block_tool
    hook = ClaudeHooks::PreToolUse.new(@common_input_data)
    hook.block_tool!('Dangerous operation')
    
    output_data = JSON.parse(hook.stringify_output)
    assert_equal('deny', output_data['hookSpecificOutput']['permissionDecision'])
    assert_equal('Dangerous operation', output_data['hookSpecificOutput']['permissionDecisionReason'])
  end

  def test_pre_tool_use_ask_for_permission
    hook = ClaudeHooks::PreToolUse.new(@common_input_data)
    hook.ask_for_permission!('Need user confirmation')
    
    output_data = JSON.parse(hook.stringify_output)
    assert_equal('ask', output_data['hookSpecificOutput']['permissionDecision'])
    assert_equal('Need user confirmation', output_data['hookSpecificOutput']['permissionDecisionReason'])
  end

  # === PostToolUse Tests ===
  
  def test_post_tool_use_hook_type
    assert_equal('PostToolUse', ClaudeHooks::PostToolUse.hook_type)
  end

  def test_post_tool_use_input_fields
    expected_fields = %w[tool_name tool_input tool_response]
    assert_equal(expected_fields, ClaudeHooks::PostToolUse.input_fields)
  end

  def test_post_tool_use_accessors
    input_data = @common_input_data.merge({
      'tool_name' => 'TestTool',
      'tool_input' => { 'param' => 'value' },
      'tool_response' => 'Success'
    })
    
    hook = ClaudeHooks::PostToolUse.new(input_data)
    
    assert_equal('TestTool', hook.tool_name)
    assert_equal({ 'param' => 'value' }, hook.tool_input)
    assert_equal('Success', hook.tool_response)
  end

  def test_post_tool_use_block_decision
    hook = ClaudeHooks::PostToolUse.new(@common_input_data)
    hook.block_tool!('Detected issue')
    
    output_data = JSON.parse(hook.stringify_output)
    assert_equal('block', output_data['decision'])
    assert_equal('Detected issue', output_data['reason'])
  end

  # === UserPromptSubmit Tests ===
  
  def test_user_prompt_submit_hook_type
    assert_equal('UserPromptSubmit', ClaudeHooks::UserPromptSubmit.hook_type)
  end

  def test_user_prompt_submit_input_fields
    expected_fields = %w[prompt]
    assert_equal(expected_fields, ClaudeHooks::UserPromptSubmit.input_fields)
  end

  def test_user_prompt_submit_accessor
    input_data = @common_input_data.merge({
      'prompt' => 'Test prompt message'
    })
    
    hook = ClaudeHooks::UserPromptSubmit.new(input_data)
    assert_equal('Test prompt message', hook.prompt)
  end

  def test_user_prompt_submit_add_additional_context
    hook = ClaudeHooks::UserPromptSubmit.new(@common_input_data)
    hook.add_additional_context!('Extra context information')
    
    output_data = JSON.parse(hook.stringify_output)
    assert_equal('Extra context information', output_data['hookSpecificOutput']['additionalContext'])
  end

  def test_user_prompt_submit_block_decision
    hook = ClaudeHooks::UserPromptSubmit.new(@common_input_data)
    hook.block_prompt!('Inappropriate content')
    
    output_data = JSON.parse(hook.stringify_output)
    assert_equal('block', output_data['decision'])
    assert_equal('Inappropriate content', output_data['reason'])
  end

  # === Stop Tests ===
  
  def test_stop_hook_type
    assert_equal('Stop', ClaudeHooks::Stop.hook_type)
  end

  def test_stop_input_fields
    expected_fields = %w[stop_hook_active]
    assert_equal(expected_fields, ClaudeHooks::Stop.input_fields)
  end

  def test_stop_accessor
    input_data = @common_input_data.merge({
      'stop_hook_active' => true
    })
    
    hook = ClaudeHooks::Stop.new(input_data)
    assert_equal(true, hook.stop_hook_active)
  end

  def test_stop_block_decision
    hook = ClaudeHooks::Stop.new(@common_input_data)
    hook.continue_with_instructions!('Continue with more tasks')
    
    output_data = JSON.parse(hook.stringify_output)
    assert_equal('block', output_data['decision'])
    assert_equal('Continue with more tasks', output_data['reason'])
  end

  # === SubagentStop Tests ===
  
  def test_subagent_stop_hook_type
    assert_equal('SubagentStop', ClaudeHooks::SubagentStop.hook_type)
  end

  def test_subagent_stop_input_fields
    expected_fields = %w[stop_hook_active]
    assert_equal(expected_fields, ClaudeHooks::SubagentStop.input_fields)
  end

  def test_subagent_stop_accessor
    input_data = @common_input_data.merge({
      'stop_hook_active' => true
    })
    
    hook = ClaudeHooks::SubagentStop.new(input_data)
    assert_equal(true, hook.stop_hook_active)
  end

  # === SessionStart Tests ===
  
  def test_session_start_hook_type
    assert_equal('SessionStart', ClaudeHooks::SessionStart.hook_type)
  end

  def test_session_start_input_fields
    expected_fields = %w[source]
    assert_equal(expected_fields, ClaudeHooks::SessionStart.input_fields)
  end

  def test_session_start_add_additional_context
    hook = ClaudeHooks::SessionStart.new(@common_input_data)
    hook.add_additional_context!('Session startup context')
    
    output_data = JSON.parse(hook.stringify_output)
    assert_equal('Session startup context', output_data['hookSpecificOutput']['additionalContext'])
  end

  # === SessionEnd Tests ===
  
  def test_session_end_hook_type
    assert_equal('SessionEnd', ClaudeHooks::SessionEnd.hook_type)
  end

  def test_session_end_input_fields
    expected_fields = %w[reason]
    assert_equal(expected_fields, ClaudeHooks::SessionEnd.input_fields)
  end

  def test_session_end_basic_functionality
    hook = ClaudeHooks::SessionEnd.new(@common_input_data)
    output_data = JSON.parse(hook.stringify_output)
    
    assert(output_data['continue'])
    refute(output_data['suppressOutput'])
  end

  # === Notification Tests ===
  
  def test_notification_hook_type
    assert_equal('Notification', ClaudeHooks::Notification.hook_type)
  end

  def test_notification_input_fields
    expected_fields = %w[message]
    assert_equal(expected_fields, ClaudeHooks::Notification.input_fields)
  end

  def test_notification_accessors
    input_data = @common_input_data.merge({
      'message' => 'Notification message'
    })
    
    hook = ClaudeHooks::Notification.new(input_data)
    
    assert_equal('Notification message', hook.message)
  end

  # === PreCompact Tests ===
  
  def test_pre_compact_hook_type
    assert_equal('PreCompact', ClaudeHooks::PreCompact.hook_type)
  end

  def test_pre_compact_input_fields
    expected_fields = %w[trigger custom_instructions]
    assert_equal(expected_fields, ClaudeHooks::PreCompact.input_fields)
  end

  def test_pre_compact_accessors
    input_data = @common_input_data.merge({
      'trigger' => 'manual',
      'custom_instructions' => 'Custom compaction instructions'
    })
    
    hook = ClaudeHooks::PreCompact.new(input_data)
    assert_equal('manual', hook.trigger)
    assert_equal('Custom compaction instructions', hook.custom_instructions)
  end

  def test_pre_compact_custom_instructions_only_for_manual
    input_data = @common_input_data.merge({
      'trigger' => 'automatic',
      'custom_instructions' => 'Should be ignored'
    })
    
    hook = ClaudeHooks::PreCompact.new(input_data)
    assert_equal('automatic', hook.trigger)
    assert_equal('', hook.custom_instructions)
  end

  # === Common Hook Functionality Tests ===
  
  def test_all_hooks_have_output_method
    hook_classes = [
      ClaudeHooks::PreToolUse,
      ClaudeHooks::PostToolUse,
      ClaudeHooks::UserPromptSubmit,
      ClaudeHooks::Stop,
      ClaudeHooks::SubagentStop,
      ClaudeHooks::SessionStart,
      ClaudeHooks::SessionEnd,
      ClaudeHooks::Notification,
      ClaudeHooks::PreCompact
    ]
    
    hook_classes.each do |hook_class|
      hook = hook_class.new(@common_input_data)
      assert_respond_to(hook, :output)
      assert_kind_of(ClaudeHooks::Output::Base, hook.output)
    end
  end

  def test_all_hooks_inherit_from_base
    hook_classes = [
      ClaudeHooks::PreToolUse,
      ClaudeHooks::PostToolUse,
      ClaudeHooks::UserPromptSubmit,
      ClaudeHooks::Stop,
      ClaudeHooks::SubagentStop,
      ClaudeHooks::SessionStart,
      ClaudeHooks::SessionEnd,
      ClaudeHooks::Notification,
      ClaudeHooks::PreCompact
    ]
    
    hook_classes.each do |hook_class|
      hook = hook_class.new(@common_input_data)
      assert_kind_of(ClaudeHooks::Base, hook)
    end
  end

  def test_hook_call_method_not_implemented_in_base
    # Create a real hook instance but don't call its implemented call method
    hook = ClaudeHooks::Notification.new(@common_input_data)
    
    # Access the base class call method directly to test the NotImplementedError
    base_instance = ClaudeHooks::Base.allocate
    base_instance.instance_variable_set(:@input_data, @common_input_data)
    base_instance.instance_variable_set(:@output_data, {})
    
    assert_raises(NotImplementedError) { base_instance.call }
  end
end