#!/usr/bin/env ruby

# Ensure we load the local version, not the gem
$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))

require 'minitest/autorun'
require 'open3'
require 'claude_hooks'

# The guard looks up the current GitHub user when loaded; stub it so tests don't need gh credentials
Open3.stub(:capture2, ['{}', nil]) do
  require_relative '../example_dotclaude/hooks/github_guard'
end

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

  def test_remote_branch_deletion_with_quoted_flag_is_denied
    assert_equal 'deny', decision_for("git push origin '--delete' feat/123-api")
  end

  def test_remote_branch_deletion_with_abbreviated_flag_is_denied
    assert_equal 'deny', decision_for('git push origin --del feat/123-api')
  end

  def test_remote_branch_deletion_with_bundled_short_flags_is_denied
    assert_equal 'deny', decision_for('git push -ud origin feat/123-api')
  end

  def test_unparseable_push_asks_for_permission
    assert_equal 'ask', decision_for("git push origin '--delete feat/123-api")
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
