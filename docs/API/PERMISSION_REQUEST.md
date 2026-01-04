# PermissionRequest API

Available when inheriting from `ClaudeHooks::PermissionRequest`:

## Input Helpers
Input helpers to access the data provided by Claude Code through `STDIN`.

[📚 Shared input helpers](COMMON.md#input-helpers)

| Method | Description |
|--------|-------------|
| `tool_name` | Get the name of the tool requiring permission |
| `tool_input` | Get the input data for the tool |
| `tool_use_id` | Get the unique identifier for this tool use |

## Hook State Helpers
Hook state methods are helpers to modify the hook's internal state (`output_data`) before yielding back to Claude Code.

[📚 Shared hook state methods](COMMON.md#hook-state-methods)

| Method | Description |
|--------|-------------|
| `allow_permission!(reason = '')` | Allow the permission request with optional reason |
| `deny_permission!(reason = '')` | Deny the permission request with reason |
| `update_input_and_allow!(updated_input, reason = '')` | Update tool input and allow (convenience method) |

## Output Helpers
Output helpers provide access to the hook's output data and helper methods for working with the output state.

[📚 Shared output helpers](COMMON.md#output-helpers)

| Method | Description |
|--------|-------------|
| `output.allowed?` | Check if permission has been allowed |
| `output.denied?` | Check if permission has been denied |
| `output.input_updated?` | Check if tool input has been updated |
| `output.permission_decision` | Get the permission decision: 'allow' or 'deny' |
| `output.permission_reason` | Get the reason for the permission decision |
| `output.updated_input` | Get the updated input (if provided) |

## Hook Exit Codes

PermissionRequest hooks use the JSON API with exit code 0 for all permission decisions.

| Exit Code | Behavior |
|-----------|----------|
| `exit 0` | Permission decision processed<br/>`STDOUT` contains JSON with decision |
| `exit 1` | Non-blocking error<br/>`STDERR` shown to user |
| `exit 2` | **Not recommended for PermissionRequest**<br/>Use JSON API with exit 0 instead |

## Example: Basic Permission Guard

```ruby
#!/usr/bin/env ruby
require 'claude_hooks'

class PermissionGuard < ClaudeHooks::PermissionRequest
  SENSITIVE_TOOLS = %w[rm git-push curl wget].freeze
  SAFE_TOOLS = %w[ls cat grep find].freeze

  def call
    log "Permission requested for: #{tool_name}"
    log "Tool use ID: #{tool_use_id}"
    log "Permission mode: #{permission_mode}"

    # Auto-allow safe tools
    if SAFE_TOOLS.include?(tool_name)
      allow_permission!("Safe tool, automatically allowed")
      return output
    end

    # Block dangerous tools
    if SENSITIVE_TOOLS.include?(tool_name)
      deny_permission!("Dangerous tool #{tool_name} requires manual approval")
      return output
    end

    # Default: allow with logging
    allow_permission!("Tool allowed by default")
    output
  end
end

if __FILE__ == $PROGRAM_NAME
  input_data = JSON.parse(STDIN.read)
  hook = PermissionGuard.new(input_data)
  hook.call
  hook.output_and_exit
end
```

## Example: Permission Mode-Aware Guard

```ruby
#!/usr/bin/env ruby
require 'claude_hooks'

class SmartPermissionGuard < ClaudeHooks::PermissionRequest
  DANGEROUS_TOOLS = %w[rm git-reset curl wget].freeze

  def call
    log "Permission mode: #{permission_mode}"

    # Block dangerous tools in bypass mode
    if permission_mode == 'bypassPermissions' && dangerous_tool?
      log "Blocking dangerous tool in bypass mode", level: :warn
      deny_permission!("Cannot bypass permissions for dangerous tool: #{tool_name}")
      return output
    end

    # Allow in 'dontAsk' mode if tool is not dangerous
    if permission_mode == 'dontAsk' && !dangerous_tool?
      allow_permission!("Auto-allowed in dontAsk mode")
      return output
    end

    # Default behavior
    allow_permission!("Permission granted")
    output
  end

  private

  def dangerous_tool?
    DANGEROUS_TOOLS.include?(tool_name)
  end
end
```

## Example: Input Modification

```ruby
#!/usr/bin/env ruby
require 'claude_hooks'

class InputSanitizer < ClaudeHooks::PermissionRequest
  def call
    case tool_name
    when 'Bash'
      # Add safety flags to bash commands
      if tool_input['command']&.include?('rm')
        sanitized_input = tool_input.merge(
          'command' => tool_input['command'] + ' --interactive'
        )
        update_input_and_allow!(sanitized_input, "Added --interactive flag for safety")
      else
        allow_permission!("Bash command is safe")
      end
    when 'Write'
      # Validate file paths before writing
      if tool_input['file_path']&.start_with?('/tmp')
        deny_permission!("Cannot write to /tmp directory")
      else
        allow_permission!("File write is safe")
      end
    else
      allow_permission!("No special handling needed")
    end

    output
  end
end
```

## Multiple Hooks Merging

When multiple PermissionRequest hooks are executed, their outputs merge with these rules:

- **Decision**: `deny` > `allow` (most restrictive wins)
- **Reasons**: All reasons are concatenated with `'; '`
- **Updated Input**: Last updated input wins (most recent transformation)

```ruby
# Hook 1
hook1.deny_permission!("Reason 1")

# Hook 2
hook2.allow_permission!("Reason 2")

# Merged result
merged = ClaudeHooks::Output::PermissionRequest.merge(
  hook1.output,
  hook2.output
)

merged.denied? # => true (deny wins)
merged.permission_reason # => "Reason 1; Reason 2"
```

## Notes

- PermissionRequest runs when Claude Code shows a permission dialog
- It can automatically allow or deny on behalf of the user
- Uses the same JSON API pattern as PreToolUse hooks
- Supports modifying tool inputs before execution
- Works with all permission modes: `default`, `plan`, `acceptEdits`, `dontAsk`, `bypassPermissions`
