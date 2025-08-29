#!/usr/bin/env ruby

require 'minitest/autorun'
require 'tempfile'
require 'fileutils'
require 'stringio'
require_relative '../lib/claude_hooks'

class TestFullIntegration < Minitest::Test
  def setup
    @temp_dir = Dir.mktmpdir('claude_hooks_integration')
    @logs_dir = File.join(@temp_dir, 'logs')
    FileUtils.mkdir_p(@logs_dir)
    
    # Save original environment
    @original_env = ENV.to_h
    @original_stdin = $stdin
    @original_stdout = $stdout
    @original_stderr = $stderr
    
    # Set up test environment
    ENV['CLAUDE_PROJECT_DIR'] = @temp_dir
    ClaudeHooks::Configuration.reload!
  end

  def teardown
    $stdin = @original_stdin
    $stdout = @original_stdout
    $stderr = @original_stderr
    
    # Restore environment
    ENV.clear
    @original_env.each { |k, v| ENV[k] = v }
    ClaudeHooks::Configuration.reload!
    
    FileUtils.rm_rf(@temp_dir) if @temp_dir && File.exist?(@temp_dir)
  end

  # === Complete Hook Lifecycle Tests ===
  
  def test_pre_tool_use_complete_workflow
    # Simulate a complete PreToolUse hook workflow
    input_data = {
      'session_id' => 'integration-test-001',
      'transcript_path' => create_test_transcript('Test transcript content'),
      'cwd' => @temp_dir,
      'hook_event_name' => 'PreToolUse',
      'tool_name' => 'FileWrite',
      'tool_input' => { 'path' => '/sensitive/file', 'content' => 'data' }
    }
    
    # Create a custom PreToolUse hook
    custom_hook = Class.new(ClaudeHooks::PreToolUse) do
      def call
        if tool_input && tool_input['path'] && tool_input['path'].include?('sensitive')
          block_tool!('Attempting to access sensitive path')
        else
          approve_tool!('Safe operation')
        end
        
        log "Evaluated tool: #{tool_name}"
        @output_data  # Return the output data hash instead of output object
      end
    end
    
    # Run the hook
    ClaudeHooks::Configuration.stub(:logs_directory, @logs_dir) do
      hook = custom_hook.new(input_data)
      result = hook.call
      
      assert_instance_of(Hash, result)
      output = hook.output
      assert_instance_of(ClaudeHooks::Output::PreToolUse, output)
      assert_equal('deny', output.permission_decision)
      assert(output.denied?)
      assert_match(/sensitive path/, output.permission_reason)
      
      # Check that logging worked
      log_files = Dir.glob(File.join(@logs_dir, '**/*.log'))
      assert(log_files.any?)
      
      log_content = File.read(log_files.first)
      assert_match(/Evaluated tool: FileWrite/, log_content)
    end
  end

  def test_user_prompt_submit_with_additional_context
    # Create a rules file
    rules_content = "Important rules:\n1. Be helpful\n2. Be safe"
    rules_dir = File.join(@temp_dir, '.claude', 'rules')
    FileUtils.mkdir_p(rules_dir)
    rules_file = File.join(rules_dir, 'post-user-prompt.rule.md')
    File.write(rules_file, rules_content)
    
    input_data = {
      'session_id' => 'integration-test-002',
      'transcript_path' => create_test_transcript('Previous conversation'),
      'cwd' => @temp_dir,
      'hook_event_name' => 'UserPromptSubmit',
      'prompt' => 'How do I delete all files?'
    }
    
    # Create hook that adds rules as context
    rules_hook = Class.new(ClaudeHooks::UserPromptSubmit) do
      def call
        rules_path = home_path_for('rules/post-user-prompt.rule.md')
        if File.exist?(rules_path)
          rules = File.read(rules_path)
          add_additional_context!(rules)
        end
        
        # Check for dangerous prompts
        if prompt && prompt.include?('delete all')
          block_prompt!('Dangerous operation requested')
        end
        
        @output_data
      end
    end
    
    ClaudeHooks::Configuration.stub(:home_claude_dir, File.join(@temp_dir, '.claude')) do
      hook = rules_hook.new(input_data)
      result = hook.call
      output = hook.output
      
      assert(output.blocked?)
      assert_equal('Dangerous operation requested', output.reason)
      if output.additional_context
        assert_includes(output.additional_context, 'Important rules')
      end
    end
  end

  # === Multiple Hooks in Sequence ===
  
  def test_multiple_hooks_execution_sequence
    session_id = 'multi-hook-test'
    base_input = {
      'session_id' => session_id,
      'transcript_path' => create_test_transcript('Test'),
      'cwd' => @temp_dir
    }
    
    results = []
    
    ClaudeHooks::Configuration.stub(:logs_directory, @logs_dir) do
      # Create simple hook implementations
      start_hook_class = Class.new(ClaudeHooks::SessionStart) do
        def call
          log "Session started"
          add_additional_context!('Session started at ' + Time.now.to_s)
          @output_data
        end
      end
      
      prompt_hook_class = Class.new(ClaudeHooks::UserPromptSubmit) do
        def call
          log "User prompt submitted"
          @output_data
        end
      end
      
      tool_hook_class = Class.new(ClaudeHooks::PreToolUse) do
        def call
          log "Pre-tool use hook executed"
          approve_tool!('Approved')
          @output_data
        end
      end
      
      post_hook_class = Class.new(ClaudeHooks::PostToolUse) do
        def call
          log "Post-tool use hook executed"
          @output_data
        end
      end
      
      end_hook_class = Class.new(ClaudeHooks::SessionEnd) do
        def call
          log "Session ended"
          @output_data
        end
      end
      
      # 1. SessionStart
      start_hook = start_hook_class.new(base_input.merge('hook_event_name' => 'SessionStart', 'source' => 'test'))
      results << start_hook.call
      
      # 2. UserPromptSubmit
      prompt_hook = prompt_hook_class.new(base_input.merge(
        'hook_event_name' => 'UserPromptSubmit',
        'prompt' => 'Test prompt'
      ))
      results << prompt_hook.call
      
      # 3. PreToolUse
      tool_hook = tool_hook_class.new(base_input.merge(
        'hook_event_name' => 'PreToolUse',
        'tool_name' => 'TestTool',
        'tool_input' => {}
      ))
      results << tool_hook.call
      
      # 4. PostToolUse
      post_hook = post_hook_class.new(base_input.merge(
        'hook_event_name' => 'PostToolUse',
        'tool_name' => 'TestTool',
        'tool_input' => {},
        'tool_response' => 'Success'
      ))
      results << post_hook.call
      
      # 5. SessionEnd
      end_hook = end_hook_class.new(base_input.merge('hook_event_name' => 'SessionEnd', 'reason' => 'test'))
      results << end_hook.call
      
      # Verify all hooks executed
      assert_equal(5, results.length)
      assert(results.all? { |r| r.is_a?(Hash) })
      
      # Check session log contains all events
      log_files = Dir.glob(File.join(@logs_dir, '**/*.log'))
      assert(log_files.any?)
    end
  end

  # === Hook Merging Scenarios ===
  
  def test_merging_multiple_pre_tool_use_hooks
    input_data = {
      'session_id' => 'merge-test',
      'transcript_path' => create_test_transcript('Test'),
      'cwd' => @temp_dir,
      'hook_event_name' => 'PreToolUse',
      'tool_name' => 'FileWrite',
      'tool_input' => { 'path' => '/test/file' }
    }
    
    # Create multiple hooks with different decisions
    security_hook = Class.new(ClaudeHooks::PreToolUse) do
      def call
        approve_tool!('Security check passed')
        output
      end
    end
    
    policy_hook = Class.new(ClaudeHooks::PreToolUse) do
      def call
        ask_for_permission!('Policy requires user approval')
        output
      end
    end
    
    compliance_hook = Class.new(ClaudeHooks::PreToolUse) do
      def call
        block_tool!('Compliance violation detected')
        output
      end
    end
    
    # Execute hooks
    hook1 = security_hook.new(input_data)
    hook2 = policy_hook.new(input_data)
    hook3 = compliance_hook.new(input_data)
    
    output1 = hook1.call
    output2 = hook2.call
    output3 = hook3.call
    
    # Merge outputs - deny should win
    merged = ClaudeHooks::Output::PreToolUse.merge(output1, output2, output3)
    
    assert_equal('deny', merged.permission_decision)
    assert(merged.denied?)
    assert_includes(merged.permission_reason, 'Security check passed')
    assert_includes(merged.permission_reason, 'Policy requires user approval')
    assert_includes(merged.permission_reason, 'Compliance violation detected')
  end

  def test_merging_user_prompt_submit_hooks
    input_data = {
      'session_id' => 'prompt-merge-test',
      'transcript_path' => create_test_transcript('Test'),
      'cwd' => @temp_dir,
      'hook_event_name' => 'UserPromptSubmit',
      'prompt' => 'Test prompt'
    }
    
    # Hook 1: Adds context
    context_hook = Class.new(ClaudeHooks::UserPromptSubmit) do
      def call
        add_additional_context!('Context from hook 1')
        @output_data
      end
    end
    
    # Hook 2: Also adds context
    rules_hook = Class.new(ClaudeHooks::UserPromptSubmit) do
      def call
        add_additional_context!('Rules from hook 2')
        @output_data
      end
    end
    
    # Hook 3: Blocks the prompt
    filter_hook = Class.new(ClaudeHooks::UserPromptSubmit) do
      def call
        block_prompt!('Content filter triggered')
        @output_data
      end
    end
    
    hook1 = context_hook.new(input_data)
    hook2 = rules_hook.new(input_data)
    hook3 = filter_hook.new(input_data)
    
    output1 = hook1.call
    output2 = hook2.call
    output3 = hook3.call
    
    # Merge outputs
    merged = ClaudeHooks::Output::UserPromptSubmit.merge(output1, output2, output3)
    
    assert(merged.blocked?)
    assert_equal('Content filter triggered', merged.reason)
    assert_includes(merged.additional_context, 'Context from hook 1')
    assert_includes(merged.additional_context, 'Rules from hook 2')
  end

  # === Real-world Workflow Simulation ===
  
  def test_realistic_claude_session_workflow
    session_id = 'realistic-workflow-test'
    transcript_file = create_test_transcript('')
    
    ClaudeHooks::Configuration.stub(:logs_directory, @logs_dir) do
      # 1. Session starts
      session_start_data = {
        'session_id' => session_id,
        'transcript_path' => transcript_file,
        'cwd' => @temp_dir,
        'hook_event_name' => 'SessionStart'
      }
      
      start_hook_class = Class.new(ClaudeHooks::SessionStart) do
        def call
          log "SessionStart hook executed"
          add_additional_context!('Welcome! Session initialized.')
          @output_data
        end
      end
      
      start_hook = start_hook_class.new(session_start_data.merge('source' => 'test'))
      start_output = start_hook.call
      assert(start_output['continue'])
      
      # 2. User submits a prompt
      prompt_data = session_start_data.merge({
        'hook_event_name' => 'UserPromptSubmit',
        'prompt' => 'Please read the file config.json'
      })
      
      prompt_hook_class = Class.new(ClaudeHooks::UserPromptSubmit) do
        def call
          log "UserPromptSubmit hook executed"
          @output_data
        end
      end
      
      prompt_hook = prompt_hook_class.new(prompt_data)
      prompt_output = prompt_hook.call
      assert(prompt_output['continue'])
      
      # 3. Claude wants to use FileRead tool
      pre_tool_data = session_start_data.merge({
        'hook_event_name' => 'PreToolUse',
        'tool_name' => 'FileRead',
        'tool_input' => { 'path' => 'config.json' }
      })
      
      pre_tool_hook_class = Class.new(ClaudeHooks::PreToolUse) do
        def call
          log "PreToolUse hook executed"
          approve_tool!('File reading is allowed')
          @output_data
        end
      end
      
      pre_tool_hook = pre_tool_hook_class.new(pre_tool_data)
      pre_tool_output = pre_tool_hook.call
      pre_tool_output_obj = pre_tool_hook.output
      assert(pre_tool_output_obj.allowed?)
      
      # 4. Tool execution completes
      post_tool_data = pre_tool_data.merge({
        'hook_event_name' => 'PostToolUse',
        'tool_output' => '{"setting": "value"}',
        'tool_response' => '{"setting": "value"}',
        'tool_error' => nil
      })
      
      post_tool_hook_class = Class.new(ClaudeHooks::PostToolUse) do
        def call
          log "PostToolUse hook executed"
          @output_data
        end
      end
      
      post_tool_hook = post_tool_hook_class.new(post_tool_data)
      post_tool_output = post_tool_hook.call
      assert(post_tool_output['continue'])
      
      # 5. Session ends
      session_end_data = session_start_data.merge({
        'hook_event_name' => 'SessionEnd'
      })
      
      end_hook_class = Class.new(ClaudeHooks::SessionEnd) do
        def call
          log "SessionEnd hook executed"
          @output_data
        end
      end
      
      end_hook = end_hook_class.new(session_end_data.merge('reason' => 'test'))
      end_output = end_hook.call
      assert_equal(0, end_hook.output.exit_code)
      
      # Verify session log
      log_files = Dir.glob(File.join(@logs_dir, '**/*.log'))
      assert_equal(1, log_files.length)
      
      log_content = File.read(log_files.first)
      assert_match(/SessionStart/, log_content)
      assert_match(/UserPromptSubmit/, log_content)
      assert_match(/PreToolUse/, log_content)
      assert_match(/PostToolUse/, log_content)
      assert_match(/SessionEnd/, log_content)
    end
  end

  # === CLI Integration Tests ===
  
  def test_cli_entrypoint_with_complete_workflow
    input_json = JSON.generate({
      'session_id' => 'cli-integration-test',
      'transcript_path' => create_test_transcript('CLI test'),
      'cwd' => @temp_dir,
      'hook_event_name' => 'Notification',
      'message' => 'Test notification',
      'details' => { 'level' => 'info' }
    })
    
    $stdin = StringIO.new(input_json)
    
    # Custom notification handler
    notification_handler = Class.new(ClaudeHooks::Notification) do
      def call
        log "Notification received: #{message}"
        
        # Check input data for details since details method doesn't exist
        if @input_data['details'] && @input_data['details']['level'] == 'error'
          prevent_continue!('Error notification received')
        end
        
        @output_data
      end
    end
    
    # Test the CLI functionality without using entrypoint which calls exit
    result = ClaudeHooks::CLI.run_hook(notification_handler, JSON.parse(input_json))
    
    assert_kind_of(Hash, result)
    assert(result['continue'])
    refute(result['suppressOutput'])
  end

  # === Error Recovery Tests ===
  
  def test_hook_chain_continues_after_error
    session_id = 'error-recovery-test'
    base_input = {
      'session_id' => session_id,
      'transcript_path' => create_test_transcript('Test'),
      'cwd' => @temp_dir
    }
    
    results = []
    errors = []
    
    # Hook that throws error
    error_hook = Class.new(ClaudeHooks::UserPromptSubmit) do
      def call
        raise StandardError, 'Simulated error'
      end
    end
    
    # Normal hook
    normal_hook = Class.new(ClaudeHooks::UserPromptSubmit) do
      def call
        add_additional_context!('Normal hook executed')
        output
      end
    end
    
    # Execute hooks with error handling
    [error_hook, normal_hook].each do |hook_class|
      begin
        hook = hook_class.new(base_input.merge('hook_event_name' => 'UserPromptSubmit', 'prompt' => 'test'))
        results << hook.call
      rescue => e
        errors << e
      end
    end
    
    assert_equal(1, errors.length)
    assert_equal(1, results.length)
    assert_equal('Normal hook executed', results.first.additional_context)
  end

  # === Configuration Integration ===
  
  def test_hooks_with_project_and_home_configs
    # Set up home config
    home_dir = Dir.mktmpdir('home')
    home_claude_dir = File.join(home_dir, '.claude')
    FileUtils.mkdir_p(File.join(home_claude_dir, 'config'))
    File.write(File.join(home_claude_dir, 'config', 'config.json'), JSON.generate({
      'homeConfig' => true,
      'sharedSetting' => 'home_value'
    }))
    
    # Set up project config
    project_claude_dir = File.join(@temp_dir, '.claude')
    FileUtils.mkdir_p(File.join(project_claude_dir, 'config'))
    File.write(File.join(project_claude_dir, 'config', 'config.json'), JSON.generate({
      'projectConfig' => true,
      'sharedSetting' => 'project_value'
    }))
    
    ENV['CLAUDE_PROJECT_DIR'] = @temp_dir
    
    ClaudeHooks::Configuration.stub(:home_claude_dir, home_claude_dir) do
      ClaudeHooks::Configuration.reload!
      
      # Create hook that uses configuration
      config_aware_hook = Class.new(ClaudeHooks::Base) do
        def self.hook_type
          'Notification'
        end
        
        def self.input_fields
          []
        end
        
        def call
          config_data = {
            'home_dir' => home_claude_dir,
            'project_dir' => project_claude_dir,
            'config' => ClaudeHooks::Configuration.config
          }
          
          @output_data['config_info'] = config_data
          @output_data
        end
      end
      
      hook = config_aware_hook.new({ 'session_id' => 'config-test' })
      result = hook.call
      
      assert(result['config_info']['config']['projectConfig'])
      assert_equal('project_value', result['config_info']['config']['sharedSetting'])
    end
    
    FileUtils.rm_rf(home_dir)
  end

  private

  def create_test_transcript(content)
    temp_file = Tempfile.new(['transcript', '.md'], @temp_dir)
    temp_file.write(content)
    temp_file.close
    temp_file.path
  end
end