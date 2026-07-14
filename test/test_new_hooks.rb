#!/usr/bin/env ruby
# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/claude_hooks'

class TestNewHooks < Minitest::Test
  def setup
    @common = {
      'session_id' => 'test-session',
      'transcript_path' => '/tmp/transcript.md',
      'cwd' => '/test',
      'hook_event_name' => 'TestEvent'
    }
  end

  # === C1: Setup ===

  def test_setup_hook_type
    assert_equal('Setup', ClaudeHooks::Setup.hook_type)
  end

  def test_setup_input_fields
    assert_equal(%w[source], ClaudeHooks::Setup.input_fields)
  end

  def test_setup_source_reader
    hook = ClaudeHooks::Setup.new(@common.merge('source' => 'init'))
    assert_equal('init', hook.source)
  end

  def test_setup_add_context
    hook = ClaudeHooks::Setup.new(@common)
    hook.add_additional_context!('hello')
    data = JSON.parse(hook.stringify_output)
    assert_equal('hello', data['hookSpecificOutput']['additionalContext'])
  end

  def test_setup_output_class
    assert_instance_of(ClaudeHooks::Output::Setup, ClaudeHooks::Setup.new(@common).output)
  end

  def test_setup_for_hook_type
    assert_instance_of(ClaudeHooks::Output::Setup, ClaudeHooks::Output::Base.for_hook_type('Setup', {}))
  end

  # === C1: SubagentStart ===

  def test_subagent_start_hook_type
    assert_equal('SubagentStart', ClaudeHooks::SubagentStart.hook_type)
  end

  def test_subagent_start_input_fields
    assert_equal(%w[agent_id agent_type], ClaudeHooks::SubagentStart.input_fields)
  end

  def test_subagent_start_uses_base_agent_id
    hook = ClaudeHooks::SubagentStart.new(@common.merge('agent_id' => 'a1'))
    assert_equal('a1', hook.agent_id)
  end

  def test_subagent_start_uses_base_agent_type
    hook = ClaudeHooks::SubagentStart.new(@common.merge('agent_type' => 'worker'))
    assert_equal('worker', hook.agent_type)
  end

  def test_subagent_start_add_context
    hook = ClaudeHooks::SubagentStart.new(@common)
    hook.add_additional_context!('ctx')
    data = JSON.parse(hook.stringify_output)
    assert_equal('ctx', data['hookSpecificOutput']['additionalContext'])
  end

  def test_subagent_start_for_hook_type
    assert_instance_of(ClaudeHooks::Output::SubagentStart, ClaudeHooks::Output::Base.for_hook_type('SubagentStart', {}))
  end

  # === C2: UserPromptExpansion ===

  def test_user_prompt_expansion_hook_type
    assert_equal('UserPromptExpansion', ClaudeHooks::UserPromptExpansion.hook_type)
  end

  def test_user_prompt_expansion_input_fields
    assert_equal(%w[expansion_type command_name command_args command_source prompt],
                 ClaudeHooks::UserPromptExpansion.input_fields)
  end

  def test_user_prompt_expansion_readers
    input = @common.merge(
      'expansion_type' => 'slash_command',
      'command_name' => 'foo',
      'command_args' => 'bar',
      'command_source' => 'user',
      'prompt' => 'expanded prompt'
    )
    hook = ClaudeHooks::UserPromptExpansion.new(input)
    assert_equal('slash_command', hook.expansion_type)
    assert_equal('foo', hook.command_name)
    assert_equal('bar', hook.command_args)
    assert_equal('user', hook.command_source)
    assert_equal('expanded prompt', hook.prompt)
  end

  def test_user_prompt_expansion_block
    hook = ClaudeHooks::UserPromptExpansion.new(@common)
    hook.block!('stop it')
    data = JSON.parse(hook.stringify_output)
    assert_equal('block', data['decision'])
    assert_equal('stop it', data['reason'])
  end

  def test_user_prompt_expansion_for_hook_type
    assert_instance_of(ClaudeHooks::Output::UserPromptExpansion,
                       ClaudeHooks::Output::Base.for_hook_type('UserPromptExpansion', {}))
  end

  # === C2: PostToolBatch ===

  def test_post_tool_batch_hook_type
    assert_equal('PostToolBatch', ClaudeHooks::PostToolBatch.hook_type)
  end

  def test_post_tool_batch_tool_calls_reader
    calls = [{ 'tool_name' => 'Bash', 'tool_input' => {}, 'tool_use_id' => 'u1', 'tool_response' => 'ok' }]
    hook = ClaudeHooks::PostToolBatch.new(@common.merge('tool_calls' => calls))
    assert_equal(calls, hook.tool_calls)
  end

  def test_post_tool_batch_tool_calls_default_empty
    hook = ClaudeHooks::PostToolBatch.new(@common)
    assert_equal([], hook.tool_calls)
  end

  def test_post_tool_batch_block
    hook = ClaudeHooks::PostToolBatch.new(@common)
    hook.block!('bad batch')
    data = JSON.parse(hook.stringify_output)
    assert_equal('block', data['decision'])
    assert_equal('bad batch', data['reason'])
  end

  def test_post_tool_batch_succeeded_and_failed_calls
    calls = [
      { 'tool_name' => 'Bash', 'tool_response' => 'ok' },
      { 'tool_name' => 'Bash', 'tool_response' => { 'is_error' => true } },
      { 'tool_name' => 'Read', 'tool_response' => { 'error' => 'boom' } },
      { 'tool_name' => 'Grep' } # no response => failed
    ]
    hook = ClaudeHooks::PostToolBatch.new(@common.merge('tool_calls' => calls))
    assert_equal(['Bash'], hook.succeeded_calls.map { |c| c['tool_name'] })
    assert_equal(%w[Bash Read Grep], hook.failed_calls.map { |c| c['tool_name'] })
  end

  def test_post_tool_batch_partitions_empty_by_default
    hook = ClaudeHooks::PostToolBatch.new(@common)
    assert_equal([], hook.succeeded_calls)
    assert_equal([], hook.failed_calls)
  end

  def test_post_tool_batch_for_hook_type
    assert_instance_of(ClaudeHooks::Output::PostToolBatch,
                       ClaudeHooks::Output::Base.for_hook_type('PostToolBatch', {}))
  end

  # === C2: ConfigChange ===

  def test_config_change_hook_type
    assert_equal('ConfigChange', ClaudeHooks::ConfigChange.hook_type)
  end

  def test_config_change_readers
    hook = ClaudeHooks::ConfigChange.new(@common.merge('source' => 'project', 'file_path' => '/a/.claude/settings.json'))
    assert_equal('project', hook.source)
    assert_equal('/a/.claude/settings.json', hook.file_path)
  end

  def test_config_change_block
    hook = ClaudeHooks::ConfigChange.new(@common)
    hook.block!('nope')
    data = JSON.parse(hook.stringify_output)
    assert_equal('block', data['decision'])
  end

  def test_config_change_for_hook_type
    assert_instance_of(ClaudeHooks::Output::ConfigChange,
                       ClaudeHooks::Output::Base.for_hook_type('ConfigChange', {}))
  end

  # === C3: TaskCreated ===

  def test_task_created_hook_type
    assert_equal('TaskCreated', ClaudeHooks::TaskCreated.hook_type)
  end

  def test_task_created_readers
    hook = ClaudeHooks::TaskCreated.new(@common.merge(
      'task_id' => 't1',
      'task_subject' => 'Do something',
      'task_description' => 'Details',
      'teammate_name' => 'Alice',
      'team_name' => 'alpha'
    ))
    assert_equal('t1', hook.task_id)
    assert_equal('Do something', hook.task_subject)
    assert_equal('Details', hook.task_description)
    assert_equal('Alice', hook.teammate_name)
    assert_equal('alpha', hook.team_name)
  end

  def test_task_created_prevent_continue
    hook = ClaudeHooks::TaskCreated.new(@common)
    hook.prevent_continue!('blocked')
    data = JSON.parse(hook.stringify_output)
    refute(data['continue'])
  end

  def test_task_created_for_hook_type
    assert_instance_of(ClaudeHooks::Output::TaskCreated,
                       ClaudeHooks::Output::Base.for_hook_type('TaskCreated', {}))
  end

  # === C3: TaskCompleted ===

  def test_task_completed_hook_type
    assert_equal('TaskCompleted', ClaudeHooks::TaskCompleted.hook_type)
  end

  def test_task_completed_readers
    hook = ClaudeHooks::TaskCompleted.new(@common.merge('task_id' => 't2', 'task_subject' => 'Done'))
    assert_equal('t2', hook.task_id)
    assert_equal('Done', hook.task_subject)
  end

  def test_task_completed_for_hook_type
    assert_instance_of(ClaudeHooks::Output::TaskCompleted,
                       ClaudeHooks::Output::Base.for_hook_type('TaskCompleted', {}))
  end

  # === C3: TeammateIdle ===

  def test_teammate_idle_hook_type
    assert_equal('TeammateIdle', ClaudeHooks::TeammateIdle.hook_type)
  end

  def test_teammate_idle_readers
    hook = ClaudeHooks::TeammateIdle.new(@common.merge('teammate_name' => 'Bob', 'team_name' => 'beta'))
    assert_equal('Bob', hook.teammate_name)
    assert_equal('beta', hook.team_name)
  end

  def test_teammate_idle_for_hook_type
    assert_instance_of(ClaudeHooks::Output::TeammateIdle,
                       ClaudeHooks::Output::Base.for_hook_type('TeammateIdle', {}))
  end

  # === C4: PostToolUseFailure ===

  def test_post_tool_use_failure_hook_type
    assert_equal('PostToolUseFailure', ClaudeHooks::PostToolUseFailure.hook_type)
  end

  def test_post_tool_use_failure_readers
    hook = ClaudeHooks::PostToolUseFailure.new(@common.merge(
      'tool_name' => 'Bash',
      'tool_input' => { 'command' => 'ls' },
      'tool_use_id' => 'uid1',
      'error' => 'exit 1',
      'is_interrupt' => false,
      'duration_ms' => 42
    ))
    assert_equal('Bash', hook.tool_name)
    assert_equal({ 'command' => 'ls' }, hook.tool_input)
    assert_equal('uid1', hook.tool_use_id)
    assert_equal('exit 1', hook.error)
    assert_equal(false, hook.is_interrupt)
    assert_equal(42, hook.duration_ms)
  end

  def test_post_tool_use_failure_add_context
    hook = ClaudeHooks::PostToolUseFailure.new(@common)
    hook.add_additional_context!('log this')
    data = JSON.parse(hook.stringify_output)
    assert_equal('log this', data['hookSpecificOutput']['additionalContext'])
  end

  def test_post_tool_use_failure_for_hook_type
    assert_instance_of(ClaudeHooks::Output::PostToolUseFailure,
                       ClaudeHooks::Output::Base.for_hook_type('PostToolUseFailure', {}))
  end

  # === C4: StopFailure ===

  def test_stop_failure_hook_type
    assert_equal('StopFailure', ClaudeHooks::StopFailure.hook_type)
  end

  def test_stop_failure_readers
    hook = ClaudeHooks::StopFailure.new(@common.merge(
      'error' => 'crash',
      'error_details' => 'stack trace',
      'last_assistant_message' => 'goodbye'
    ))
    assert_equal('crash', hook.error)
    assert_equal('stack trace', hook.error_details)
    assert_equal('goodbye', hook.last_assistant_message)
  end

  def test_stop_failure_for_hook_type
    assert_instance_of(ClaudeHooks::Output::StopFailure,
                       ClaudeHooks::Output::Base.for_hook_type('StopFailure', {}))
  end

  # === C4: PostCompact ===

  def test_post_compact_hook_type
    assert_equal('PostCompact', ClaudeHooks::PostCompact.hook_type)
  end

  def test_post_compact_readers
    hook = ClaudeHooks::PostCompact.new(@common.merge('trigger' => 'auto', 'compact_summary' => 'summary text'))
    assert_equal('auto', hook.trigger)
    assert_equal('summary text', hook.compact_summary)
  end

  def test_post_compact_for_hook_type
    assert_instance_of(ClaudeHooks::Output::PostCompact,
                       ClaudeHooks::Output::Base.for_hook_type('PostCompact', {}))
  end

  # === C4: CwdChanged ===

  def test_cwd_changed_hook_type
    assert_equal('CwdChanged', ClaudeHooks::CwdChanged.hook_type)
  end

  def test_cwd_changed_readers
    hook = ClaudeHooks::CwdChanged.new(@common.merge('old_cwd' => '/a', 'new_cwd' => '/b'))
    assert_equal('/a', hook.old_cwd)
    assert_equal('/b', hook.new_cwd)
  end

  def test_cwd_changed_watch_paths_builder
    hook = ClaudeHooks::CwdChanged.new(@common)
    hook.watch_paths!(['/watch/this'])
    data = JSON.parse(hook.stringify_output)
    assert_equal(['/watch/this'], data['hookSpecificOutput']['watchPaths'])
  end

  def test_cwd_changed_for_hook_type
    assert_instance_of(ClaudeHooks::Output::CwdChanged,
                       ClaudeHooks::Output::Base.for_hook_type('CwdChanged', {}))
  end

  # === C4: FileChanged ===

  def test_file_changed_hook_type
    assert_equal('FileChanged', ClaudeHooks::FileChanged.hook_type)
  end

  def test_file_changed_readers
    hook = ClaudeHooks::FileChanged.new(@common.merge('file_path' => '/a/b.rb', 'event' => 'change'))
    assert_equal('/a/b.rb', hook.file_path)
    assert_equal('change', hook.event)
  end

  def test_file_changed_convenience_predicates
    assert(ClaudeHooks::FileChanged.new(@common.merge('event' => 'add')).created?)
    assert(ClaudeHooks::FileChanged.new(@common.merge('event' => 'change')).modified?)
    assert(ClaudeHooks::FileChanged.new(@common.merge('event' => 'unlink')).deleted?)
    refute(ClaudeHooks::FileChanged.new(@common.merge('event' => 'change')).created?)
  end

  def test_file_changed_watch_paths_builder
    hook = ClaudeHooks::FileChanged.new(@common)
    hook.watch_paths!(['/x', '/y'])
    data = JSON.parse(hook.stringify_output)
    assert_equal(['/x', '/y'], data['hookSpecificOutput']['watchPaths'])
  end

  def test_file_changed_for_hook_type
    assert_instance_of(ClaudeHooks::Output::FileChanged,
                       ClaudeHooks::Output::Base.for_hook_type('FileChanged', {}))
  end

  # === C4: InstructionsLoaded ===

  def test_instructions_loaded_hook_type
    assert_equal('InstructionsLoaded', ClaudeHooks::InstructionsLoaded.hook_type)
  end

  def test_instructions_loaded_readers
    hook = ClaudeHooks::InstructionsLoaded.new(@common.merge('file_path' => '/p/CLAUDE.md', 'load_reason' => 'startup'))
    assert_equal('/p/CLAUDE.md', hook.file_path)
    assert_equal('startup', hook.load_reason)
  end

  def test_instructions_loaded_for_hook_type
    assert_instance_of(ClaudeHooks::Output::InstructionsLoaded,
                       ClaudeHooks::Output::Base.for_hook_type('InstructionsLoaded', {}))
  end

  # === C4: WorktreeRemove ===

  def test_worktree_remove_hook_type
    assert_equal('WorktreeRemove', ClaudeHooks::WorktreeRemove.hook_type)
  end

  def test_worktree_remove_reader
    hook = ClaudeHooks::WorktreeRemove.new(@common.merge('worktree_path' => '/tmp/wt'))
    assert_equal('/tmp/wt', hook.worktree_path)
  end

  def test_worktree_remove_for_hook_type
    assert_instance_of(ClaudeHooks::Output::WorktreeRemove,
                       ClaudeHooks::Output::Base.for_hook_type('WorktreeRemove', {}))
  end

  # === C5: PermissionDenied ===

  def test_permission_denied_hook_type
    assert_equal('PermissionDenied', ClaudeHooks::PermissionDenied.hook_type)
  end

  def test_permission_denied_readers
    hook = ClaudeHooks::PermissionDenied.new(@common.merge(
      'tool_name' => 'Bash', 'tool_input' => {}, 'tool_use_id' => 'u1', 'reason' => 'policy'
    ))
    assert_equal('Bash', hook.tool_name)
    assert_equal('policy', hook.reason)
  end

  def test_permission_denied_retry_builder
    hook = ClaudeHooks::PermissionDenied.new(@common)
    hook.retry!
    data = JSON.parse(hook.stringify_output)
    assert_equal(true, data['hookSpecificOutput']['retry'])
  end

  def test_permission_denied_no_retry_builder
    hook = ClaudeHooks::PermissionDenied.new(@common)
    hook.no_retry!
    data = JSON.parse(hook.stringify_output)
    assert_equal(false, data['hookSpecificOutput']['retry'])
  end

  def test_permission_denied_for_hook_type
    assert_instance_of(ClaudeHooks::Output::PermissionDenied,
                       ClaudeHooks::Output::Base.for_hook_type('PermissionDenied', {}))
  end

  # === C5: Elicitation ===

  def test_elicitation_hook_type
    assert_equal('Elicitation', ClaudeHooks::Elicitation.hook_type)
  end

  def test_elicitation_readers
    hook = ClaudeHooks::Elicitation.new(@common.merge(
      'mcp_server_name' => 'my-server',
      'message' => 'Please provide your token',
      'mode' => 'form',
      'url' => 'https://example.com',
      'elicitation_id' => 'eid1',
      'requested_schema' => { 'type' => 'object' }
    ))
    assert_equal('my-server', hook.mcp_server_name)
    assert_equal('Please provide your token', hook.message)
    assert_equal('form', hook.mode)
    assert_equal('https://example.com', hook.url)
    assert_equal('eid1', hook.elicitation_id)
    assert_equal({ 'type' => 'object' }, hook.requested_schema)
  end

  def test_elicitation_accept_builder
    hook = ClaudeHooks::Elicitation.new(@common)
    hook.accept!({ 'token' => 'abc' })
    data = JSON.parse(hook.stringify_output)
    assert_equal('accept', data['hookSpecificOutput']['action'])
    assert_equal({ 'token' => 'abc' }, data['hookSpecificOutput']['content'])
  end

  def test_elicitation_decline_builder
    hook = ClaudeHooks::Elicitation.new(@common)
    hook.decline!
    data = JSON.parse(hook.stringify_output)
    assert_equal('decline', data['hookSpecificOutput']['action'])
  end

  def test_elicitation_cancel_builder
    hook = ClaudeHooks::Elicitation.new(@common)
    hook.cancel!
    data = JSON.parse(hook.stringify_output)
    assert_equal('cancel', data['hookSpecificOutput']['action'])
  end

  def test_elicitation_for_hook_type
    assert_instance_of(ClaudeHooks::Output::Elicitation,
                       ClaudeHooks::Output::Base.for_hook_type('Elicitation', {}))
  end

  # === C5: ElicitationResult ===

  def test_elicitation_result_hook_type
    assert_equal('ElicitationResult', ClaudeHooks::ElicitationResult.hook_type)
  end

  def test_elicitation_result_readers
    hook = ClaudeHooks::ElicitationResult.new(@common.merge(
      'mcp_server_name' => 'srv',
      'action' => 'accept',
      'content' => { 'val' => 1 }
    ))
    assert_equal('srv', hook.mcp_server_name)
    assert_equal('accept', hook.action)
    assert_equal({ 'val' => 1 }, hook.content)
  end

  def test_elicitation_result_for_hook_type
    assert_instance_of(ClaudeHooks::Output::ElicitationResult,
                       ClaudeHooks::Output::Base.for_hook_type('ElicitationResult', {}))
  end

  # === C5: WorktreeCreate ===

  def test_worktree_create_hook_type
    assert_equal('WorktreeCreate', ClaudeHooks::WorktreeCreate.hook_type)
  end

  def test_worktree_create_name_reader
    hook = ClaudeHooks::WorktreeCreate.new(@common.merge('name' => 'feature-x'))
    assert_equal('feature-x', hook.name)
  end

  def test_worktree_create_path_builder
    hook = ClaudeHooks::WorktreeCreate.new(@common)
    hook.worktree_path!('/tmp/wt/feature-x')
    data = JSON.parse(hook.stringify_output)
    assert_equal('/tmp/wt/feature-x', data['hookSpecificOutput']['worktreePath'])
  end

  def test_worktree_create_for_hook_type
    assert_instance_of(ClaudeHooks::Output::WorktreeCreate,
                       ClaudeHooks::Output::Base.for_hook_type('WorktreeCreate', {}))
  end

  # === C6: MessageDisplay ===

  def test_message_display_hook_type
    assert_equal('MessageDisplay', ClaudeHooks::MessageDisplay.hook_type)
  end

  def test_message_display_input_fields
    assert_equal(%w[turn_id message_id index final delta], ClaudeHooks::MessageDisplay.input_fields)
  end

  def test_message_display_readers
    hook = ClaudeHooks::MessageDisplay.new(@common.merge(
      'turn_id' => 't1',
      'message_id' => 'm1',
      'index' => 3,
      'final' => true,
      'delta' => 'hello'
    ))
    assert_equal('t1', hook.turn_id)
    assert_equal('m1', hook.message_id)
    assert_equal(3, hook.index)
    assert_equal(true, hook.final)
    assert(hook.final?)
    assert_equal('hello', hook.delta)
  end

  def test_message_display_camel_fallback
    hook = ClaudeHooks::MessageDisplay.new(@common.merge('turnId' => 'tc', 'messageId' => 'mc'))
    assert_equal('tc', hook.turn_id)
    assert_equal('mc', hook.message_id)
  end

  def test_message_display_display_content_builder
    hook = ClaudeHooks::MessageDisplay.new(@common)
    hook.display_content!('redacted')
    data = JSON.parse(hook.stringify_output)
    assert_equal('redacted', data['hookSpecificOutput']['displayContent'])
  end

  def test_message_display_output_class
    assert_instance_of(ClaudeHooks::Output::MessageDisplay, ClaudeHooks::MessageDisplay.new(@common).output)
  end

  def test_message_display_for_hook_type
    assert_instance_of(ClaudeHooks::Output::MessageDisplay,
                       ClaudeHooks::Output::Base.for_hook_type('MessageDisplay', {}))
  end
end
