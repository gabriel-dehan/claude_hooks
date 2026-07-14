#!/usr/bin/env ruby
# frozen_string_literal: true

# Backward-compatibility regression tests (plan D2 / Verification step 2).
#
# Existing users (e.g. ~/Work/pennylane/jeancaisse/.claude) rely only on
# ClaudeHooks::UserPromptSubmit + ClaudeHooks::SessionStart via add_context!,
# source, output, output_and_exit and the path helpers. The 1.2.0 additive
# changes must not alter the JSON these hooks emit vs. 1.1.0. These tests pin
# the exact emitted shape so a future change can't silently break it.

require 'minitest/autorun'
require_relative '../lib/claude_hooks'

class TestBackwardCompat < Minitest::Test
  # --- SessionStart: add_context! + source (jeancaisse usage) ---

  def test_session_start_add_context_emits_1_1_0_shape
    hook = ClaudeHooks::SessionStart.new(
      'session_id' => 'sess-1',
      'transcript_path' => '/tmp/t.md',
      'cwd' => '/proj',
      'hook_event_name' => 'SessionStart',
      'source' => 'startup'
    )
    hook.add_context!('Injected context')

    assert_equal('startup', hook.source)
    assert_equal(
      {
        'continue' => true,
        'stopReason' => '',
        'suppressOutput' => false,
        'hookSpecificOutput' => {
          'hookEventName' => 'SessionStart',
          'additionalContext' => 'Injected context'
        }
      },
      JSON.parse(hook.stringify_output)
    )
  end

  # --- UserPromptSubmit: add_context! + prevent_continue! (jeancaisse usage) ---

  def test_user_prompt_submit_add_context_emits_1_1_0_shape
    hook = ClaudeHooks::UserPromptSubmit.new(
      'session_id' => 'sess-1',
      'transcript_path' => '/tmp/t.md',
      'cwd' => '/proj',
      'hook_event_name' => 'UserPromptSubmit',
      'prompt' => 'hi'
    )
    hook.add_context!('Extra guidance')

    assert_equal(
      {
        'continue' => true,
        'stopReason' => '',
        'suppressOutput' => false,
        'hookSpecificOutput' => {
          'hookEventName' => 'UserPromptSubmit',
          'additionalContext' => 'Extra guidance'
        }
      },
      JSON.parse(hook.stringify_output)
    )
  end

  def test_user_prompt_submit_prevent_continue_emits_1_1_0_shape
    hook = ClaudeHooks::UserPromptSubmit.new(
      'session_id' => 'sess-1',
      'hook_event_name' => 'UserPromptSubmit',
      'prompt' => 'hi'
    )
    hook.prevent_continue!('blocked')

    data = JSON.parse(hook.stringify_output)
    assert_equal(false, data['continue'])
    assert_equal('blocked', data['stopReason'])
    assert_equal(false, data['suppressOutput'])
  end

  # --- output object round-trips unchanged ---

  def test_user_prompt_submit_output_accessors_unchanged
    hook = ClaudeHooks::UserPromptSubmit.new(
      'session_id' => 'sess-1',
      'hook_event_name' => 'UserPromptSubmit',
      'prompt' => 'hi'
    )
    hook.add_context!('ctx')
    assert_instance_of(ClaudeHooks::Output::UserPromptSubmit, hook.output)
    assert(hook.output.continue?)
  end

  # --- PreToolUse merge precedence: deny > defer > ask > allow (plan-required) ---

  def test_pre_tool_use_full_precedence_order
    allow = ClaudeHooks::Output::PreToolUse.new(
      'hookSpecificOutput' => { 'permissionDecision' => 'allow' }
    )
    ask = ClaudeHooks::Output::PreToolUse.new(
      'hookSpecificOutput' => { 'permissionDecision' => 'ask' }
    )
    defer = ClaudeHooks::Output::PreToolUse.new(
      'hookSpecificOutput' => { 'permissionDecision' => 'defer' }
    )
    deny = ClaudeHooks::Output::PreToolUse.new(
      'hookSpecificOutput' => { 'permissionDecision' => 'deny' }
    )

    # deny beats everything
    assert_equal('deny', ClaudeHooks::Output::PreToolUse.merge(allow, ask, defer, deny).permission_decision)
    # defer beats ask and allow
    assert_equal('defer', ClaudeHooks::Output::PreToolUse.merge(allow, ask, defer).permission_decision)
    # ask beats allow
    assert_equal('ask', ClaudeHooks::Output::PreToolUse.merge(allow, ask).permission_decision)
    # allow alone stays allow
    assert_equal('allow', ClaudeHooks::Output::PreToolUse.merge(allow, allow).permission_decision)
  end
end
