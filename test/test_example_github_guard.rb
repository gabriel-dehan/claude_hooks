#!/usr/bin/env ruby

# Ensure we load the local version, not the gem
$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))

require 'minitest/autorun'
require 'claude_hooks'
require_relative '../example_dotclaude/hooks/github_guard'

class TestExampleGithubGuard < Minitest::Test
  def test_push_of_branch_containing_dash_d_is_allowed
    assert_equal 'allow', decision_for('git push -u origin feat/123-document-api')
  end

  def test_remote_branch_deletion_with_long_flag_is_denied
    assert_equal 'deny', decision_for('git push origin --delete feat/123-api')
  end

  def test_remote_branch_deletion_with_short_flag_is_denied
    assert_equal 'deny', decision_for('git push origin -d feat/123-api')
  end

  private

  def decision_for(command)
    input = {
      'session_id' => 'test-session',
      'transcript_path' => '/tmp/test_transcript.md',
      'cwd' => '/test/directory',
      'hook_event_name' => 'PreToolUse',
      'tool_name' => 'Bash',
      'tool_input' => { 'command' => command }
    }

    GithubGuard.new(input).call.dig('hookSpecificOutput', 'permissionDecision')
  end
end
