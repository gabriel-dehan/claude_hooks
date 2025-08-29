#!/usr/bin/env ruby

require 'minitest/autorun'
require 'tempfile'
require_relative '../lib/claude_hooks'

class TestBase < Minitest::Test
  def setup
    @input_data = {
      'session_id' => 'test-session-456',
      'transcript_path' => '/tmp/test_transcript.md',
      'cwd' => '/test/working/directory',
      'hook_event_name' => 'UserPromptSubmit',
      'prompt' => 'Test prompt message'
    }
    
    # Use UserPromptSubmit as our test hook class
    @test_hook_class = ClaudeHooks::UserPromptSubmit
  end

  # === Input Validation Tests ===
  
  def test_validates_input_fields
    # Test with missing prompt field
    incomplete_data = @input_data.dup
    incomplete_data.delete('prompt')
    hook = @test_hook_class.new(incomplete_data)
    # Should log warning about missing prompt but not raise error
    assert_instance_of(@test_hook_class, hook)
  end

  def test_accepts_complete_input
    # All required fields are already present in @input_data
    hook = @test_hook_class.new(@input_data)
    assert_instance_of(@test_hook_class, hook)
  end

  # === Common Field Accessor Tests ===
  
  def test_session_id_accessor
    hook = @test_hook_class.new(@input_data)
    assert_equal('test-session-456', hook.session_id)
  end

  def test_session_id_default_when_missing
    hook = @test_hook_class.new({})
    assert_equal('claude-default-session', hook.session_id)
  end

  def test_transcript_path_accessor
    hook = @test_hook_class.new(@input_data)
    assert_equal('/tmp/test_transcript.md', hook.transcript_path)
  end

  def test_cwd_accessor
    hook = @test_hook_class.new(@input_data)
    assert_equal('/test/working/directory', hook.cwd)
  end

  def test_hook_event_name_accessor
    hook = @test_hook_class.new(@input_data)
    assert_equal('UserPromptSubmit', hook.hook_event_name)
  end

  def test_hook_event_name_fallback_to_hook_type
    data_without_event = @input_data.dup
    data_without_event.delete('hook_event_name')
    hook = @test_hook_class.new(data_without_event)
    assert_equal('UserPromptSubmit', hook.hook_event_name)
  end

  # === Transcript Reading Tests ===
  
  def test_read_transcript_success
    # Create a temporary transcript file
    temp_file = Tempfile.new('transcript')
    temp_file.write("Test transcript content\nLine 2")
    temp_file.close
    
    data_with_transcript = @input_data.merge('transcript_path' => temp_file.path)
    hook = @test_hook_class.new(data_with_transcript)
    
    content = hook.read_transcript
    assert_equal("Test transcript content\nLine 2", content)
    
    temp_file.unlink
  end

  def test_read_transcript_missing_file
    data_with_missing_file = @input_data.merge('transcript_path' => '/nonexistent/file.md')
    hook = @test_hook_class.new(data_with_missing_file)
    
    content = hook.read_transcript
    assert_equal('', content)
  end

  def test_read_transcript_no_path
    data_without_path = @input_data.dup
    data_without_path.delete('transcript_path')
    hook = @test_hook_class.new(data_without_path)
    
    content = hook.read_transcript
    assert_equal('', content)
  end

  def test_transcript_alias_method
    hook = @test_hook_class.new(@input_data)
    assert_respond_to(hook, :transcript)
  end

  # === Output Helper Tests ===
  
  def test_allow_continue_default
    hook = @test_hook_class.new(@input_data)
    output_data = JSON.parse(hook.stringify_output)
    assert(output_data['continue'])
  end

  def test_prevent_continue_with_reason
    hook = @test_hook_class.new(@input_data)
    hook.prevent_continue!('Test error occurred')
    
    output_data = JSON.parse(hook.stringify_output)
    refute(output_data['continue'])
    assert_equal('Test error occurred', output_data['stopReason'])
  end

  def test_allow_continue_after_prevent
    hook = @test_hook_class.new(@input_data)
    hook.prevent_continue!('Error')
    hook.allow_continue!
    
    output_data = JSON.parse(hook.stringify_output)
    assert(output_data['continue'])
  end

  def test_suppress_output
    hook = @test_hook_class.new(@input_data)
    hook.suppress_output!
    
    output_data = JSON.parse(hook.stringify_output)
    assert(output_data['suppressOutput'])
  end

  def test_show_output_default
    hook = @test_hook_class.new(@input_data)
    output_data = JSON.parse(hook.stringify_output)
    refute(output_data['suppressOutput'])
  end

  def test_show_output_after_suppress
    hook = @test_hook_class.new(@input_data)
    hook.suppress_output!
    hook.show_output!
    
    output_data = JSON.parse(hook.stringify_output)
    refute(output_data['suppressOutput'])
  end

  def test_clear_specifics
    hook = @test_hook_class.new(@input_data)
    hook.instance_variable_get(:@output_data)['hookSpecificOutput'] = { 'test' => 'data' }
    hook.clear_specifics!
    
    output_data = JSON.parse(hook.stringify_output)
    assert_nil(output_data['hookSpecificOutput'])
  end

  def test_system_message
    hook = @test_hook_class.new(@input_data)
    hook.system_message!('Important message for user')
    
    output_data = JSON.parse(hook.stringify_output)
    assert_equal('Important message for user', output_data['systemMessage'])
  end

  def test_clear_system_message
    hook = @test_hook_class.new(@input_data)
    hook.system_message!('Message')
    hook.clear_system_message!
    
    output_data = JSON.parse(hook.stringify_output)
    assert_nil(output_data['systemMessage'])
  end

  # === Configuration Access Tests ===
  
  def test_base_dir_access
    hook = @test_hook_class.new(@input_data)
    assert_respond_to(hook, :base_dir)
    assert_kind_of(String, hook.base_dir)
  end

  def test_home_claude_dir_access
    hook = @test_hook_class.new(@input_data)
    assert_respond_to(hook, :home_claude_dir)
    assert_kind_of(String, hook.home_claude_dir)
  end

  def test_project_claude_dir_access
    hook = @test_hook_class.new(@input_data)
    assert_respond_to(hook, :project_claude_dir)
    # May be nil if CLAUDE_PROJECT_DIR is not set
  end

  def test_path_for_method
    hook = @test_hook_class.new(@input_data)
    path = hook.path_for('test/file.txt')
    assert(path.end_with?('test/file.txt'))
  end

  def test_home_path_for_method
    hook = @test_hook_class.new(@input_data)
    path = hook.home_path_for('test/file.txt')
    assert(path.include?('.claude'))
    assert(path.end_with?('test/file.txt'))
  end

  def test_project_path_for_method
    hook = @test_hook_class.new(@input_data)
    path = hook.project_path_for('test/file.txt')
    # May be nil if CLAUDE_PROJECT_DIR is not set
    if path
      assert(path.end_with?('test/file.txt'))
    end
  end

  # === Output Object Tests ===
  
  def test_output_object_creation
    hook = @test_hook_class.new(@input_data)
    assert_kind_of(ClaudeHooks::Output::Base, hook.output)
    assert_instance_of(ClaudeHooks::Output::UserPromptSubmit, hook.output)
  end

  def test_output_object_reflects_data_changes
    hook = @test_hook_class.new(@input_data)
    hook.prevent_continue!('Test')
    
    # Get a new output object that reflects current data
    output = ClaudeHooks::Output::Base.for_hook_type('UserPromptSubmit', JSON.parse(hook.stringify_output))
    refute(output.continue?)
    assert_equal('Test', output.stop_reason)
  end

  # === Logger Tests ===
  
  def test_logger_initialization
    hook = @test_hook_class.new(@input_data)
    assert_instance_of(ClaudeHooks::Logger, hook.logger)
  end

  def test_log_method_available
    hook = @test_hook_class.new(@input_data)
    assert_respond_to(hook, :log)
  end

  # === JSON Output Tests ===
  
  def test_stringify_output_returns_valid_json
    hook = @test_hook_class.new(@input_data)
    json_string = hook.stringify_output
    
    # Test that JSON parsing doesn't raise an exception
    parsed = nil
    begin
      parsed = JSON.parse(json_string)
    rescue JSON::ParserError
      flunk("Failed to parse JSON: #{json_string}")
    end
    
    assert_kind_of(Hash, parsed)
    assert(parsed.key?('continue'))
    assert(parsed.key?('stopReason'))
    assert(parsed.key?('suppressOutput'))
  end

  # === Hook Type Tests ===
  
  def test_hook_type_instance_method
    hook = @test_hook_class.new(@input_data)
    assert_equal('UserPromptSubmit', hook.hook_type)
  end

  def test_hook_type_not_implemented_error
    invalid_class = Class.new(ClaudeHooks::Base)
    assert_raises(NotImplementedError) { invalid_class.hook_type }
  end

  def test_input_fields_not_implemented_error
    invalid_class = Class.new(ClaudeHooks::Base)
    assert_raises(NotImplementedError) { invalid_class.input_fields }
  end

  def test_call_not_implemented_error
    hook = @test_hook_class.new(@input_data)
    # Our test class implements call, but base class should raise
    base_hook = ClaudeHooks::Base.allocate
    base_hook.instance_variable_set(:@input_data, @input_data)
    base_hook.instance_variable_set(:@output_data, {})
    assert_raises(NotImplementedError) { base_hook.call }
  end
end