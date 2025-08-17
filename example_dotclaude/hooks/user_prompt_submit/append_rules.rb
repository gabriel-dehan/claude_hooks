#!/usr/bin/env ruby

require 'claude_hooks'

# Hook script that appends rules to user prompt
class AppendRules < ClaudeHooks::UserPromptSubmit

  def call
    log "Executing AppendRules hook"

    # Read the rule content
    rule_content = read_rule_content

    if rule_content
      add_additional_context!(rule_content)
      log "Successfully added rule content as additional context (#{rule_content.length} characters)"
    else
      log "No rule content found", level: :warn
    end

    output_data
  end

  private

  def read_rule_content
    rule_file_path = path_for('rules/post-user-prompt.rule.md')

    if File.exist?(rule_file_path)
      content = File.read(rule_file_path).strip
      return content unless content.empty?
    end

    log "Rule file not found or empty at: #{rule_file_path}", level: :warn
    log "Base directory: #{base_dir}"
    nil
  end
end

# If this file is run directly (for testing), call the hook script
if __FILE__ == $0
  begin
    require 'json'

    input_data = JSON.parse(STDIN.read)
    hook = AppendRules.new(input_data)
    hook.call
    puts hook.output_string
  rescue JSON::ParserError => e
    STDERR.puts "Error parsing JSON: #{e.message}"
    puts JSON.generate({
      continue: false,
      stopReason: "JSON parsing error in AppendRules: #{e.message}",
      suppressOutput: false
    })
    exit 0
  rescue StandardError => e
    STDERR.puts "Error in AppendRules hook: #{e.message}, #{e.backtrace.join("\n")}"
    puts JSON.generate({
      continue: false,
      stopReason: "AppendRules execution error: #{e.message}",
      suppressOutput: false
    })
    exit 0
  end
end
