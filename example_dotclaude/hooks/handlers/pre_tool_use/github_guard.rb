#!/usr/bin/env ruby
# frozen_string_literal: true

require 'claude_hooks'
require 'json'
require 'open3'

# GitHub Guard hook to prevent unauthorized or dangerous GitHub/Git actions
class GithubGuard < ClaudeHooks::PreToolUse
  BLOCKED_TOOL_TIP = 'If they are sure they want to proceed, the user should run the command themselves using `!` (e.g. `!gh pr merge`, `!git push --force`, etc...)'

  RULES = {
    # MCP GitHub tools
    mcp_tools: {
      always_blocked: %w[
        mcp__github__delete_repository
        mcp__github__delete_file
      ],
      owner_restricted_pr: %w[
        mcp__github__merge_pull_request
        mcp__github__update_pull_request
      ],
      pr_draft_required: %w[
        mcp__github__create_pull_request
      ],
    },

    # Bash command patterns (gh & github)
    bash_patterns: {
      always_blocked: [
        /\Agh\s+pr\s+merge.*--rebase/,
        /\Agh\s+repo\s+delete/,
        /\Agh\s+secret\s+(set|delete)/,
        /\Agit\s+push\s+.*--force/,
        /\Agit\s+reset\s+--hard/,
        /\Agit\s+reset\s+--hard\s+HEAD~[0-9]+/,
        /\Agit\s+clean\s+-[fd]/,
        /\Agit\s+reflog\s+expire/,
        /\Agit\s+filter-branch/,
        /\Agit\s+checkout\s+--\s+\./,
      ],
      requires_permission: [
        /\Agh\s+api/,
        /\Agit\s+branch\s+(-D|-d|--delete)/,
        /\Agit\s+rebase\s+(master|main)/,
        /\Agit\s+commit\s+--amend/,
        /\Agit\s+rebase\s+-i/,
      ],
      owner_restricted_pr: [
        'gh pr merge',
        'gh pr edit',
        'gh pr close',
        'gh pr ready',
        'gh pr lock',
      ],
      pr_draft_required: [
        'gh pr create',
      ],
    },
  }.freeze

  CURRENT_USER = begin
    github_user_data = Open3.capture2('gh api user').then { |data, _| JSON.parse(data) }
    git_user, = Open3.capture2('git config user.name')

    {
      name: github_user_data['name'] || git_user.strip,
      login: github_user_data['login'] || '',
    }
  rescue StandardError => e
    log "Error fetching github user data, #{e.message}, make sure Github CLI is installed and you are logged in.",
        :error
    { name: '', login: '' }
  end

  def call
    log "Input data: #{input_data.inspect}"

    case tool_name
    when /\Amcp__github__/
      log "Checking MCP tool: #{tool_name}"
      validate_mcp_github_tool!
    when 'Bash'
      log "Checking tool: #{tool_name}(#{command})"
      validate_bash_command!
    else
      approve_tool!("Tool #{tool_name} is allowed")
    end

    output_data
  end

  private

  # Main validation methods
  def validate_mcp_github_tool!
    return block_with_tip!("#{tool_name} is dangerous and not allowed.") if always_blocked_mcp_tool?
    return validate_pr_ownership!(tool_name, extract_pr_number_from_input) if owner_restricted_mcp_tool?
    return validate_mcp_pr_draft_mode! if pr_draft_required_mcp_tool?

    approve_tool!('Safe github MCP call')
  end

  def validate_bash_command!
    return block_with_tip!("Command blocked: #{command} - dangerous pattern.") if always_blocked_command?
    return ask_for_permission!("Command requires permission: #{command}") if requires_permission_command?
    return validate_pr_ownership!(command, extract_pr_number_from_command) if owner_restricted_pr_command?
    return prevent_remote_branch_deletion! if remote_branch_deletion_command?
    return validate_bash_pr_draft_mode! if pr_draft_required_command?

    approve_tool!('Safe bash command')
  end

  # Helper validation methods
  def validate_pr_ownership!(context, pr_number)
    return ask_for_permission!("Could not determine PR number from #{context}") unless pr_number

    pr_owner = get_pr_owner(pr_number)
    return ask_for_permission!("Could not determine owner of PR ##{pr_number}") unless pr_owner

    if user_owns_pr?(pr_owner)
      approve_tool!("PR ##{pr_number} belongs to current user (#{pr_owner})")
    else
      block_with_tip!("Cannot execute '#{context}' - PR ##{pr_number} belongs to #{pr_owner}, you are #{CURRENT_USER[:login]}") # rubocop:disable Layout/LineLength
    end
  end

  def validate_mcp_pr_draft_mode!
    if tool_input&.dig('draft') == true
      approve_tool!('PR creation allowed (draft mode)')
    else
      block_with_tip!('PR creation must use draft: true. All PRs should be created as drafts.')
    end
  end

  def validate_bash_pr_draft_mode!
    if command.include?('--draft')
      approve_tool!('PR creation allowed (draft mode)')
    else
      block_with_tip!('gh pr create must use --draft flag. All PRs should be created as drafts.')
    end
  end

  def prevent_remote_branch_deletion!
    branch = extract_branch_from_deletion
    return ask_for_permission!('Could not determine branch name') unless branch

    if remote_branch_deletion?
      block_with_tip!("Cannot delete remote branch '#{branch}'")
    else
      approve_tool!('Branch deletion allowed')
    end
  end

  # Rule matching methods
  def always_blocked_mcp_tool?
    RULES[:mcp_tools][:always_blocked].include?(tool_name)
  end

  def owner_restricted_mcp_tool?
    RULES[:mcp_tools][:owner_restricted_pr].include?(tool_name)
  end

  def pr_draft_required_mcp_tool?
    RULES[:mcp_tools][:pr_draft_required].include?(tool_name)
  end

  def always_blocked_command?
    RULES[:bash_patterns][:always_blocked].any? { |pattern| command.match?(pattern) }
  end

  def requires_permission_command?
    RULES[:bash_patterns][:requires_permission].any? { |pattern| command.match?(pattern) }
  end

  def owner_restricted_pr_command?
    RULES[:bash_patterns][:owner_restricted_pr].any? { |cmd| command.start_with?(cmd) }
  end

  def pr_draft_required_command?
    RULES[:bash_patterns][:pr_draft_required].any? { |cmd| command.start_with?(cmd) }
  end

  def remote_branch_deletion_command?
    command.match?(/\Agit\s+push.*(--delete|-d|-D)/)
  end

  def remote_branch_deletion?
    command.include?('origin') || command.include?('upstream')
  end

  # Utility methods
  def user_owns_pr?(pr_owner)
    pr_owner == CURRENT_USER[:login] || pr_owner == CURRENT_USER[:name]
  end

  # Extraction methods
  def command
    @command ||= tool_input&.dig('command') || ''
  end

  def extract_pr_number_from_input
    params = tool_input || {}
    params['pullNumber'] || params['pull_number'] || params['number']
  end

  def extract_pr_number_from_command
    command.match(/\s+(\d+)/)&.[](1)&.to_i
  end

  def extract_branch_from_deletion
    command.match(/(?:--delete|-d|-D)\s+(\S+)/)&.[](1)
  end

  def get_pr_owner(pr_number)
    return nil unless pr_number

    begin
      # Try to get PR info using gh CLI
      pr_info, status = Open3.capture2e("gh pr view #{pr_number} --json author")

      if status.success?
        data = JSON.parse(pr_info)
        data.dig('author', 'login')
      else
        log "Could not fetch PR info: #{pr_info}", :warn
        nil
      end
    rescue StandardError => e
      log "Error fetching PR owner: #{e.message}", :error
      nil
    end
  end

  # Utility methods
  def block_with_tip!(message)
    block_tool!("#{message}\n#{BLOCKED_TOOL_TIP}")
  end
end

# When running this file directly (for debugging)
if __FILE__ == $PROGRAM_NAME
  ClaudeHooks::CLI.run_with_sample_data(GithubGuard) do |data|
    data.merge!(
      'session_id' => 'GithubGuardTest',
      'transcript_path' => '',
      'cwd' => Dir.pwd,
      'hook_event_name' => 'PreToolUse',
      'tool_name' => 'mcp__github__create_pull_request',
      'tool_input' => { 'draft' => false },
    )
  end
end
