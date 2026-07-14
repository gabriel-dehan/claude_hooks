#!/usr/bin/env ruby
# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/claude_hooks'

class TestNewOutputClasses < Minitest::Test

  # === Output::Base terminal_sequence merge (A2) ===

  def test_terminal_sequence_last_wins_in_merge
    o1 = ClaudeHooks::Output::UserPromptSubmit.new({ 'continue' => true, 'terminalSequence' => 'seq1' })
    o2 = ClaudeHooks::Output::UserPromptSubmit.new({ 'continue' => true, 'terminalSequence' => 'seq2' })
    merged = ClaudeHooks::Output::UserPromptSubmit.merge(o1, o2)
    assert_equal('seq2', merged.terminal_sequence)
  end

  def test_terminal_sequence_nil_does_not_overwrite
    o1 = ClaudeHooks::Output::UserPromptSubmit.new({ 'continue' => true, 'terminalSequence' => 'seq1' })
    o2 = ClaudeHooks::Output::UserPromptSubmit.new({ 'continue' => true })
    merged = ClaudeHooks::Output::UserPromptSubmit.merge(o1, o2)
    assert_equal('seq1', merged.terminal_sequence)
  end

  # === PermissionRequest nested decision (B3) ===

  def test_permission_request_nested_allow
    data = { 'hookSpecificOutput' => { 'decision' => { 'behavior' => 'allow' } } }
    out = ClaudeHooks::Output::PermissionRequest.new(data)
    assert_equal('allow', out.permission_decision)
    assert(out.allowed?)
    refute(out.denied?)
  end

  def test_permission_request_nested_deny
    data = { 'hookSpecificOutput' => { 'decision' => { 'behavior' => 'deny', 'message' => 'no' } } }
    out = ClaudeHooks::Output::PermissionRequest.new(data)
    assert_equal('deny', out.permission_decision)
    assert(out.denied?)
    assert_equal('no', out.permission_reason)
  end

  def test_permission_request_legacy_flat_fallback
    data = { 'hookSpecificOutput' => { 'permissionDecision' => 'allow', 'permissionDecisionReason' => 'ok' } }
    out = ClaudeHooks::Output::PermissionRequest.new(data)
    assert_equal('allow', out.permission_decision)
    assert_equal('ok', out.permission_reason)
  end

  def test_permission_request_updated_input_nested
    data = { 'hookSpecificOutput' => { 'decision' => { 'behavior' => 'allow', 'updatedInput' => { 'x' => 1 } } } }
    out = ClaudeHooks::Output::PermissionRequest.new(data)
    assert_equal({ 'x' => 1 }, out.updated_input)
    assert(out.input_updated?)
  end

  def test_permission_request_interrupt_accessor
    data = { 'hookSpecificOutput' => { 'decision' => { 'behavior' => 'deny', 'interrupt' => true } } }
    out = ClaudeHooks::Output::PermissionRequest.new(data)
    assert(out.interrupt?)
  end

  def test_permission_request_merge_deny_wins
    o1 = ClaudeHooks::Output::PermissionRequest.new({ 'hookSpecificOutput' => { 'decision' => { 'behavior' => 'allow' } } })
    o2 = ClaudeHooks::Output::PermissionRequest.new({ 'hookSpecificOutput' => { 'decision' => { 'behavior' => 'deny', 'message' => 'no' } } })
    merged = ClaudeHooks::Output::PermissionRequest.merge(o1, o2)
    assert_equal('deny', merged.permission_decision)
    assert_equal('no', merged.permission_reason)
  end

  def test_permission_request_exit_code_and_stream
    out = ClaudeHooks::Output::PermissionRequest.new({})
    assert_equal(0, out.exit_code)
    assert_equal(:stdout, out.output_stream)
  end

  def test_permission_request_merge_propagates_interrupt
    o1 = ClaudeHooks::Output::PermissionRequest.new({ 'hookSpecificOutput' => { 'decision' => { 'behavior' => 'deny', 'interrupt' => true } } })
    o2 = ClaudeHooks::Output::PermissionRequest.new({ 'hookSpecificOutput' => { 'decision' => { 'behavior' => 'allow' } } })
    merged = ClaudeHooks::Output::PermissionRequest.merge(o1, o2)
    assert(merged.interrupt?)
  end

  def test_permission_request_merge_interrupt_false_by_default
    o1 = ClaudeHooks::Output::PermissionRequest.new({ 'hookSpecificOutput' => { 'decision' => { 'behavior' => 'allow' } } })
    o2 = ClaudeHooks::Output::PermissionRequest.new({ 'hookSpecificOutput' => { 'decision' => { 'behavior' => 'deny' } } })
    merged = ClaudeHooks::Output::PermissionRequest.merge(o1, o2)
    refute(merged.interrupt?)
  end

  def test_permission_request_merge_updated_permissions_last_wins
    o1 = ClaudeHooks::Output::PermissionRequest.new({ 'hookSpecificOutput' => { 'decision' => { 'behavior' => 'allow', 'updatedPermissions' => { 'a' => true } } } })
    o2 = ClaudeHooks::Output::PermissionRequest.new({ 'hookSpecificOutput' => { 'decision' => { 'behavior' => 'allow', 'updatedPermissions' => { 'b' => true } } } })
    merged = ClaudeHooks::Output::PermissionRequest.merge(o1, o2)
    assert_equal({ 'b' => true }, merged.updated_permissions)
  end

  def test_permission_request_merge_updated_permissions_nil_does_not_overwrite
    o1 = ClaudeHooks::Output::PermissionRequest.new({ 'hookSpecificOutput' => { 'decision' => { 'behavior' => 'allow', 'updatedPermissions' => { 'a' => true } } } })
    o2 = ClaudeHooks::Output::PermissionRequest.new({ 'hookSpecificOutput' => { 'decision' => { 'behavior' => 'allow' } } })
    merged = ClaudeHooks::Output::PermissionRequest.merge(o1, o2)
    assert_equal({ 'a' => true }, merged.updated_permissions)
  end

  # === PreToolUse defer + merge precedence (B1) ===

  def test_pre_tool_use_deferred_accessor
    data = { 'hookSpecificOutput' => { 'permissionDecision' => 'defer' } }
    out = ClaudeHooks::Output::PreToolUse.new(data)
    assert(out.deferred?)
    refute(out.allowed?)
    refute(out.denied?)
  end

  def test_pre_tool_use_merge_deny_beats_defer
    o_deny  = ClaudeHooks::Output::PreToolUse.new({ 'hookSpecificOutput' => { 'permissionDecision' => 'deny' } })
    o_defer = ClaudeHooks::Output::PreToolUse.new({ 'hookSpecificOutput' => { 'permissionDecision' => 'defer' } })
    merged = ClaudeHooks::Output::PreToolUse.merge(o_deny, o_defer)
    assert_equal('deny', merged.permission_decision)
  end

  def test_pre_tool_use_merge_defer_beats_ask
    o_defer = ClaudeHooks::Output::PreToolUse.new({ 'hookSpecificOutput' => { 'permissionDecision' => 'defer' } })
    o_ask   = ClaudeHooks::Output::PreToolUse.new({ 'hookSpecificOutput' => { 'permissionDecision' => 'ask' } })
    merged = ClaudeHooks::Output::PreToolUse.merge(o_defer, o_ask)
    assert_equal('defer', merged.permission_decision)
  end

  def test_pre_tool_use_merge_ask_beats_allow
    o_ask   = ClaudeHooks::Output::PreToolUse.new({ 'hookSpecificOutput' => { 'permissionDecision' => 'ask' } })
    o_allow = ClaudeHooks::Output::PreToolUse.new({ 'hookSpecificOutput' => { 'permissionDecision' => 'allow' } })
    merged = ClaudeHooks::Output::PreToolUse.merge(o_ask, o_allow)
    assert_equal('ask', merged.permission_decision)
  end

  # === PostToolUse update_tool_output (B2) ===

  def test_post_tool_use_updated_tool_output_accessor
    data = { 'hookSpecificOutput' => { 'updatedToolOutput' => 'new value' } }
    out = ClaudeHooks::Output::PostToolUse.new(data)
    assert_equal('new value', out.updated_tool_output)
    assert(out.output_updated?)
  end

  def test_post_tool_use_updated_mcp_tool_output_accessor
    data = { 'hookSpecificOutput' => { 'updatedMCPToolOutput' => 'mcp value' } }
    out = ClaudeHooks::Output::PostToolUse.new(data)
    assert_equal('mcp value', out.updated_mcp_tool_output)
    assert(out.output_updated?)
  end

  def test_post_tool_use_output_not_updated_by_default
    out = ClaudeHooks::Output::PostToolUse.new({})
    refute(out.output_updated?)
  end

  # === PreCompact block! (B6) ===

  def test_pre_compact_decision_accessors
    data = { 'decision' => 'block', 'reason' => 'too big' }
    out = ClaudeHooks::Output::PreCompact.new(data)
    assert_equal('block', out.decision)
    assert_equal('too big', out.reason)
    assert(out.blocked?)
  end

  def test_pre_compact_not_blocked_by_default
    out = ClaudeHooks::Output::PreCompact.new({})
    refute(out.blocked?)
  end

  def test_pre_compact_merge_block_wins
    o1 = ClaudeHooks::Output::PreCompact.new({ 'decision' => 'block', 'reason' => 'r1' })
    o2 = ClaudeHooks::Output::PreCompact.new({})
    merged = ClaudeHooks::Output::PreCompact.merge(o1, o2)
    assert(merged.blocked?)
    assert_equal('r1', merged.reason)
  end

  # === Setup / SubagentStart exit codes ===

  def test_setup_exit_code_continue
    out = ClaudeHooks::Output::Setup.new({ 'continue' => true })
    assert_equal(0, out.exit_code)
  end

  def test_setup_exit_code_stop
    out = ClaudeHooks::Output::Setup.new({ 'continue' => false })
    assert_equal(2, out.exit_code)
  end

  def test_subagent_start_additional_context_accessor
    data = { 'hookSpecificOutput' => { 'additionalContext' => 'ctx' } }
    out = ClaudeHooks::Output::SubagentStart.new(data)
    assert_equal('ctx', out.additional_context)
  end

  # === SessionStart new output accessors (B4) ===

  def test_session_start_new_accessors
    data = { 'hookSpecificOutput' => {
      'sessionTitle' => 'My session',
      'initialUserMessage' => 'hi there',
      'watchPaths' => ['/a', '/b'],
      'reloadSkills' => true
    } }
    out = ClaudeHooks::Output::SessionStart.new(data)
    assert_equal('My session', out.session_title)
    assert_equal('hi there', out.initial_user_message)
    assert_equal(['/a', '/b'], out.watch_paths)
    assert(out.reload_skills?)
  end

  def test_session_start_new_accessors_defaults
    out = ClaudeHooks::Output::SessionStart.new({})
    assert_nil(out.session_title)
    assert_nil(out.initial_user_message)
    assert_equal([], out.watch_paths)
    refute(out.reload_skills?)
  end

  def test_session_start_merge_carries_new_fields
    o1 = ClaudeHooks::Output::SessionStart.new({ 'hookSpecificOutput' => { 'additionalContext' => 'a', 'sessionTitle' => 'T1' } })
    o2 = ClaudeHooks::Output::SessionStart.new({ 'hookSpecificOutput' => { 'additionalContext' => 'b', 'watchPaths' => ['/w'], 'reloadSkills' => true } })
    merged = ClaudeHooks::Output::SessionStart.merge(o1, o2)
    assert_equal("a\n\nb", merged.additional_context)
    assert_equal('T1', merged.session_title)
    assert_equal(['/w'], merged.watch_paths)
    assert(merged.reload_skills?)
  end

  # === Stop / SubagentStop additional_context accessor (B5) ===

  def test_stop_additional_context_accessor
    out = ClaudeHooks::Output::Stop.new({ 'hookSpecificOutput' => { 'additionalContext' => 'note' } })
    assert_equal('note', out.additional_context)
    assert_equal('', ClaudeHooks::Output::Stop.new({}).additional_context)
  end

  def test_stop_merge_carries_additional_context
    o1 = ClaudeHooks::Output::Stop.new({ 'hookSpecificOutput' => { 'additionalContext' => 'x' } })
    o2 = ClaudeHooks::Output::Stop.new({ 'hookSpecificOutput' => { 'additionalContext' => 'y' } })
    merged = ClaudeHooks::Output::Stop.merge(o1, o2)
    assert_equal("x\n\ny", merged.additional_context)
  end

  def test_subagent_stop_inherits_additional_context
    out = ClaudeHooks::Output::SubagentStop.new({ 'hookSpecificOutput' => { 'additionalContext' => 'sub' } })
    assert_equal('sub', out.additional_context)
  end

  # === UserPromptExpansion / PostToolBatch / ConfigChange ===

  def test_user_prompt_expansion_blocked
    data = { 'continue' => false, 'decision' => 'block', 'reason' => 'bad' }
    out = ClaudeHooks::Output::UserPromptExpansion.new(data)
    assert(out.blocked?)
    assert_equal('bad', out.reason)
    assert_equal(2, out.exit_code)
  end

  def test_post_tool_batch_blocked
    data = { 'continue' => false, 'decision' => 'block', 'reason' => 'batch issue' }
    out = ClaudeHooks::Output::PostToolBatch.new(data)
    assert(out.blocked?)
    assert_equal(2, out.exit_code)
  end

  def test_config_change_blocked
    data = { 'continue' => false, 'decision' => 'block' }
    out = ClaudeHooks::Output::ConfigChange.new(data)
    assert(out.blocked?)
    assert_equal(2, out.exit_code)
  end

  # === TaskCreated / TaskCompleted / TeammateIdle exit codes ===

  def test_task_created_exit_code_continue
    out = ClaudeHooks::Output::TaskCreated.new({ 'continue' => true })
    assert_equal(0, out.exit_code)
  end

  def test_task_created_exit_code_stop
    out = ClaudeHooks::Output::TaskCreated.new({ 'continue' => false })
    assert_equal(2, out.exit_code)
  end

  def test_teammate_idle_exit_code_stop
    out = ClaudeHooks::Output::TeammateIdle.new({ 'continue' => false })
    assert_equal(2, out.exit_code)
  end

  # === StopFailure always exits 0 ===

  def test_stop_failure_exit_code_always_zero
    out = ClaudeHooks::Output::StopFailure.new({ 'continue' => false })
    assert_equal(0, out.exit_code)
  end

  # === InstructionsLoaded always exits 0 ===

  def test_instructions_loaded_exit_code_always_zero
    out = ClaudeHooks::Output::InstructionsLoaded.new({ 'continue' => false })
    assert_equal(0, out.exit_code)
  end

  # === WorktreeRemove always exits 0 ===

  def test_worktree_remove_exit_code_always_zero
    out = ClaudeHooks::Output::WorktreeRemove.new({ 'continue' => false })
    assert_equal(0, out.exit_code)
  end

  # === PermissionDenied retry accessor ===

  def test_permission_denied_retry_true
    data = { 'hookSpecificOutput' => { 'retry' => true } }
    out = ClaudeHooks::Output::PermissionDenied.new(data)
    assert(out.retry?)
    assert_equal(0, out.exit_code)
    assert_equal(:stdout, out.output_stream)
  end

  def test_permission_denied_retry_false_by_default
    out = ClaudeHooks::Output::PermissionDenied.new({})
    refute(out.retry?)
  end

  def test_permission_denied_merge_any_retry_wins
    o1 = ClaudeHooks::Output::PermissionDenied.new({ 'hookSpecificOutput' => { 'retry' => false } })
    o2 = ClaudeHooks::Output::PermissionDenied.new({ 'hookSpecificOutput' => { 'retry' => true } })
    merged = ClaudeHooks::Output::PermissionDenied.merge(o1, o2)
    assert(merged.retry?)
  end

  # === Elicitation action accessors ===

  def test_elicitation_accepted
    data = { 'hookSpecificOutput' => { 'action' => 'accept', 'content' => { 'k' => 'v' } } }
    out = ClaudeHooks::Output::Elicitation.new(data)
    assert(out.accepted?)
    refute(out.declined?)
    assert_equal({ 'k' => 'v' }, out.content)
    assert_equal(0, out.exit_code)
    assert_equal(:stdout, out.output_stream)
  end

  def test_elicitation_declined
    data = { 'hookSpecificOutput' => { 'action' => 'decline' } }
    out = ClaudeHooks::Output::Elicitation.new(data)
    assert(out.declined?)
  end

  def test_elicitation_cancelled
    data = { 'hookSpecificOutput' => { 'action' => 'cancel' } }
    out = ClaudeHooks::Output::Elicitation.new(data)
    assert(out.cancelled?)
  end

  def test_elicitation_merge_last_action_wins
    o1 = ClaudeHooks::Output::Elicitation.new({ 'hookSpecificOutput' => { 'action' => 'decline' } })
    o2 = ClaudeHooks::Output::Elicitation.new({ 'hookSpecificOutput' => { 'action' => 'accept', 'content' => { 'x' => 1 } } })
    merged = ClaudeHooks::Output::Elicitation.merge(o1, o2)
    assert(merged.accepted?)
    assert_equal({ 'x' => 1 }, merged.content)
  end

  # === ElicitationResult ===

  def test_elicitation_result_accepted
    data = { 'hookSpecificOutput' => { 'action' => 'accept' } }
    out = ClaudeHooks::Output::ElicitationResult.new(data)
    assert(out.accepted?)
    assert_equal(0, out.exit_code)
  end

  # === WorktreeCreate bare-path contract ===

  def test_worktree_create_path_set_exits_0
    data = { 'hookSpecificOutput' => { 'worktreePath' => '/tmp/wt/feat' } }
    out = ClaudeHooks::Output::WorktreeCreate.new(data)
    assert_equal('/tmp/wt/feat', out.worktree_path)
    assert_equal(0, out.exit_code)
    assert_equal(:stdout, out.output_stream)
  end

  def test_worktree_create_empty_path_exits_1
    out = ClaudeHooks::Output::WorktreeCreate.new({})
    assert_equal(1, out.exit_code)
  end

  def test_worktree_create_output_and_exit_prints_bare_path
    data = { 'hookSpecificOutput' => { 'worktreePath' => '/tmp/wt/feat' } }
    out = ClaudeHooks::Output::WorktreeCreate.new(data)
    captured = capture_io { begin; out.output_and_exit; rescue SystemExit; end }
    assert_equal("/tmp/wt/feat\n", captured[0])
  end

  def test_worktree_create_merge_last_path_wins
    o1 = ClaudeHooks::Output::WorktreeCreate.new({ 'hookSpecificOutput' => { 'worktreePath' => '/tmp/a' } })
    o2 = ClaudeHooks::Output::WorktreeCreate.new({ 'hookSpecificOutput' => { 'worktreePath' => '/tmp/b' } })
    merged = ClaudeHooks::Output::WorktreeCreate.merge(o1, o2)
    assert_equal('/tmp/b', merged.worktree_path)
  end

  # === CwdChanged / FileChanged watchPaths merge ===

  def test_cwd_changed_merge_paths_unified
    o1 = ClaudeHooks::Output::CwdChanged.new({ 'hookSpecificOutput' => { 'watchPaths' => ['/a'] } })
    o2 = ClaudeHooks::Output::CwdChanged.new({ 'hookSpecificOutput' => { 'watchPaths' => ['/b'] } })
    merged = ClaudeHooks::Output::CwdChanged.merge(o1, o2)
    assert_equal(['/a', '/b'], merged.watch_paths)
  end

  def test_file_changed_merge_deduplicates_paths
    o1 = ClaudeHooks::Output::FileChanged.new({ 'hookSpecificOutput' => { 'watchPaths' => ['/a', '/b'] } })
    o2 = ClaudeHooks::Output::FileChanged.new({ 'hookSpecificOutput' => { 'watchPaths' => ['/b', '/c'] } })
    merged = ClaudeHooks::Output::FileChanged.merge(o1, o2)
    assert_equal(['/a', '/b', '/c'], merged.watch_paths)
  end

  # === PostToolUseFailure additionalContext merge ===

  def test_post_tool_use_failure_merge_contexts
    o1 = ClaudeHooks::Output::PostToolUseFailure.new({ 'hookSpecificOutput' => { 'additionalContext' => 'a' } })
    o2 = ClaudeHooks::Output::PostToolUseFailure.new({ 'hookSpecificOutput' => { 'additionalContext' => 'b' } })
    merged = ClaudeHooks::Output::PostToolUseFailure.merge(o1, o2)
    assert_equal("a\n\nb", merged.additional_context)
  end

  # === MessageDisplay (C6) — display-only, exit ignored ===

  def test_message_display_display_content_accessor
    out = ClaudeHooks::Output::MessageDisplay.new({ 'hookSpecificOutput' => { 'displayContent' => 'x' } })
    assert_equal('x', out.display_content)
  end

  def test_message_display_exit_code_and_stream
    out = ClaudeHooks::Output::MessageDisplay.new({})
    assert_equal(0, out.exit_code)
    assert_equal(:stdout, out.output_stream)
  end

  def test_message_display_merge_last_content_wins
    o1 = ClaudeHooks::Output::MessageDisplay.new({ 'hookSpecificOutput' => { 'displayContent' => 'first' } })
    o2 = ClaudeHooks::Output::MessageDisplay.new({ 'hookSpecificOutput' => { 'displayContent' => 'second' } })
    merged = ClaudeHooks::Output::MessageDisplay.merge(o1, o2)
    assert_equal('second', merged.display_content)
  end
end
