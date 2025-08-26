# Ruby DSL for Claude Code hooks

A Ruby DSL (Domain Specific Language) for creating Claude Code hooks. This will hopefully make creating and configuring new hooks way easier.

[**Why use this instead of writing bash, or simple ruby scripts?**](docs/WHY.md)

> You might also be interested in my other project, a [Claude Code statusline](https://github.com/gabriel-dehan/claude_monitor_statusline) that shows your Claude usage in realtime, inside Claude Code ✨.

## 🚀 Quick Start

> [!TIP]
> An example is available in [`example_dotclaude/hooks/`](example_dotclaude/hooks/)

Here's how to create a simple hook:

1. **Install the gem:**
```bash
  gem install claude_hooks
```

1. **Create a simple hook script**
```ruby
#!/usr/bin/env ruby
require 'json'
require 'claude_hooks'

# Inherit from the right hook type class to get access to helper methods
class AddContextAfterPrompt < ClaudeHooks::UserPromptSubmit
  def call
    log "User asked: #{prompt}"
    add_context!("Remember to be extra helpful!")
    output_data
  end
end

# Run the hook
if __FILE__ == $0
  # Read Claude Code's input data from STDIN
  input_data = JSON.parse(STDIN.read)

  hook = AddContextAfterPrompt.new(input_data)
  output = hook.call

  puts JSON.generate(output)
  exit 0
end
```

3. ⚠️ **Make it executable**
```bash
chmod +x add_context_after_prompt.rb
# Test it
echo '{"session_id":"test","prompt":"Hello!"}' | ./add_context_after_prompt.rb
```

4. **Register it in your `.claude/settings.json`**
```json
{
  "hooks": {
    "UserPromptSubmit": [{
      "matcher": "",
      "hooks": [
        {
          "type": "command",
          "command": "path/to/your/hook.rb"
        }
      ]
    }]
  }
}
```
That's it! Your hook will now add context to every user prompt. 🎉

> [!TIP]
> This was a very simple example but we recommend using the entrypoints/handlers architecture [described below](#recommended-structure-for-your-claudehooks-directory) to create more complex hook systems.

## 📦 Installation

Install it globally (simpler):

```bash
$ gem install claude_hooks
```

**Note:** Claude Code itself will still use the system-installed gem, not the bundled version unless you use `bundle exec` to run it in your `.claude/settings.json`.

Or add it to your Gemfile (you can add a Gemfile in your `.claude` directory if needed):


```ruby
# .claude/Gemfile
source 'https://rubygems.org'

gem 'claude_hooks'
```

And then run:

```bash
$ bundle install
```

> [!WARNING]
> If you use a Gemfile, you need to use `bundle exec` to run your hooks in your `.claude/settings.json`.

### 🔧 Configuration

Claude Hooks supports both home-level (`$HOME/.claude`) and project-level (`$CLAUDE_PROJECT_DIR/.claude`) directories. Claude Hooks specific config files (`config/config.json`) found in either directory will be merged together.

| Directory | Description | Purpose |
|-----------|-------------|---------|
| `$HOME/.claude` | Home Claude directory | Global user settings and logs |
| `$CLAUDE_PROJECT_DIR/.claude` | Project Claude directory | Project-specific settings |

> [!NOTE]
> Logs always go to `$HOME/.claude/{logDirectory}`

#### Environment Variables

You can configure Claude Hooks through environment variables with the `RUBY_CLAUDE_HOOKS_` prefix:

```bash
# Existing configuration options
export RUBY_CLAUDE_HOOKS_LOG_DIR="logs"                  # Default: logs (relative to HOME/.claude)
export RUBY_CLAUDE_HOOKS_CONFIG_MERGE_STRATEGY="project" # Config merge strategy: "project" or "home", default: "project"
export RUBY_CLAUDE_HOOKS_BASE_DIR="~/.claude"            # DEPRECATED: fallback base directory

# Any variable prefixed with RUBY_CLAUDE_HOOKS_
# will also be available through the config object
export RUBY_CLAUDE_HOOKS_API_KEY="your-api-key"
export RUBY_CLAUDE_HOOKS_DEBUG_MODE="true"
export RUBY_CLAUDE_HOOKS_USER_NAME="Gabriel"
```

#### Configuration Files

You can also use configuration files in any of the two locations:

**Home config** (`$HOME/.claude/config/config.json`):
```json
{
  // Existing configuration option
  "logDirectory": "logs",
  // Custom configuration options
  "apiKey": "your-global-api-key",
  "userName": "Gabriel"
}
```

**Project config** (`$CLAUDE_PROJECT_DIR/.claude/config/config.json`):
```json
{
  // Custom configuration option
  "projectSpecificConfig": "someValue",
}
```

#### Configuration Merging

When both config files exist, they will be merged with configurable precedence:

- **Default (`project`)**: Project config values override home config values
- **Home precedence (`home`)**: Home config values override project config values

Set merge strategy: `export RUBY_CLAUDE_HOOKS_CONFIG_MERGE_STRATEGY="home" | "project"` (default: "project")

> [!WARNING]
> Environment Variables > Merged Config Files

#### Accessing Configuration Variables

You can access any configuration value in your handlers:

```ruby
class MyHandler < ClaudeHooks::UserPromptSubmit
  def call
    # Access directory paths
    log "Home Claude dir: #{home_claude_dir}"
    log "Project Claude dir: #{project_claude_dir}" # nil if CLAUDE_PROJECT_DIR not set
    log "Base dir (deprecated): #{base_dir}"
    log "Logs dir: #{config.logs_directory}"

    # Path utilities
    log "Home config path: #{home_path_for('config')}"
    log "Project hooks path: #{project_path_for('hooks')}" # nil if no project dir

    # Access custom config via method calls
    log "API Key: #{config.api_key}"
    log "Debug mode: #{config.debug_mode}"
    log "User: #{config.user_name}"

    # Or use get_config_value for more control
    user_name = config.get_config_value('USER_NAME', 'userName')
    log "Username: #{user_name}"

    output_data
  end
end
```

## 📖 Table of Contents

- [Ruby DSL for Claude Code hooks](#ruby-dsl-for-claude-code-hooks)
  - [🚀 Quick Start](#-quick-start)
  - [📦 Installation](#-installation)
    - [🔧 Configuration](#-configuration)
      - [Environment Variables](#environment-variables)
      - [Configuration Files](#configuration-files)
      - [Configuration Merging](#configuration-merging)
      - [Accessing Configuration Variables](#accessing-configuration-variables)
  - [📖 Table of Contents](#-table-of-contents)
  - [🏗️ Architecture](#️-architecture)
    - [Core Components](#core-components)
    - [Recommended structure for your .claude/hooks/ directory](#recommended-structure-for-your-claudehooks-directory)
  - [🪝 Hook Types](#-hook-types)
  - [🚀 Claude Hook Flow](#-claude-hook-flow)
    - [A very simplified view of how a hook works in Claude Code](#a-very-simplified-view-of-how-a-hook-works-in-claude-code)
    - [🔄 Proposal: a more robust Claude Hook execution flow](#-proposal-a-more-robust-claude-hook-execution-flow)
    - [Basic Hook Handler Structure](#basic-hook-handler-structure)
    - [Input Fields](#input-fields)
  - [📚 API Reference](#-api-reference)
    - [Common API Methods](#common-api-methods)
      - [Input Methods](#input-methods)
      - [Output Methods](#output-methods)
      - [Class Output Methods](#class-output-methods)
    - [Configuration and Utility Methods](#configuration-and-utility-methods)
      - [Utility Methods](#utility-methods)
      - [Configuration Methods](#configuration-methods)
    - [UserPromptSubmit API](#userpromptsubmit-api)
      - [Input Methods](#input-methods-1)
      - [Output Methods](#output-methods-1)
    - [PreToolUse API](#pretooluse-api)
      - [Input Methods](#input-methods-2)
      - [Output Methods](#output-methods-2)
    - [PostToolUse API](#posttooluse-api)
      - [Input Methods](#input-methods-3)
      - [Output Methods](#output-methods-3)
    - [Notification API](#notification-api)
      - [Input Methods](#input-methods-4)
      - [Output Methods](#output-methods-4)
    - [Stop API](#stop-api)
      - [Input Methods](#input-methods-5)
      - [Output Methods](#output-methods-5)
    - [SubagentStop API](#subagentstop-api)
      - [Input Methods](#input-methods-6)
      - [Output Methods](#output-methods-6)
    - [PreCompact API](#precompact-api)
      - [Input Methods](#input-methods-7)
      - [Output Methods](#output-methods-7)
      - [Utility Methods](#utility-methods-1)
    - [SessionStart API](#sessionstart-api)
      - [Input Methods](#input-methods-8)
      - [Output Methods](#output-methods-8)
    - [📝 Logging](#-logging)
      - [Log File Location](#log-file-location)
      - [Log Output Format](#log-output-format)
  - [📝 Example: Tool usage monitor](#-example-tool-usage-monitor)
  - [🔄 Hook Output](#-hook-output)
    - [🔄 Hook Output Merging](#-hook-output-merging)
    - [🚪 Hook Exit Codes](#-hook-exit-codes)
    - [Pattern 1: Simple Exit Codes](#pattern-1-simple-exit-codes)
    - [Example: Success](#example-success)
    - [Example: Error](#example-error)
  - [🚨 Advices](#-advices)
  - [⚠️ Troubleshooting](#️-troubleshooting)
    - [Make your entrypoint scripts executable](#make-your-entrypoint-scripts-executable)
  - [🧪 CLI Debugging](#-cli-debugging)
    - [Basic Usage](#basic-usage)
    - [Customization with Blocks](#customization-with-blocks)
    - [Testing Methods](#testing-methods)
      - [1. Test with STDIN (default)](#1-test-with-stdin-default)
      - [2. Test with default sample data instead of STDIN](#2-test-with-default-sample-data-instead-of-stdin)
      - [3. Test with Sample Data + Customization](#3-test-with-sample-data--customization)
    - [Example Hook with CLI Testing](#example-hook-with-cli-testing)
  - [🐛 Debugging](#-debugging)
    - [Test an individual entrypoint](#test-an-individual-entrypoint)


## 🏗️ Architecture

### Core Components

1. **`ClaudeHooks::Base`** - Base class with common functionality (logging, config, validation)
2. **Hook Handler Classes** - Self-contained classes (`ClaudeHooks::UserPromptSubmit`, `ClaudeHooks::PreToolUse`, `ClaudeHooks::PostToolUse`, etc.)
3. **Logger** - Dedicated logging class with multiline block support
4. **Configuration** - Shared configuration management via `ClaudeHooks::Configuration`

### Recommended structure for your .claude/hooks/ directory

```
.claude/hooks/
├── entrypoints/                # Main entry points
│   ├── notification.rb
│   ├── pre_tool_use.rb
│   ├── post_tool_use.rb
│   ├── pre_compact.rb
│   ├── session_start.rb
│   ├── stop.rb
│   └── subagent_stop.rb
|
└── handlers/                    # Hook handlers for specific hook type
    ├── user_prompt_submit/
    │   ├── append_rules.rb
    │   └── log_user_prompt.rb
    ├── pre_tool_use/
    │   └── tool_monitor.rb
    └── ...
```

## 🪝 Hook Types

The framework supports the following hook types:

| Hook Type | Class | Description |
|-----------|-------|-------------|
| **SessionStart** | `ClaudeHooks::SessionStart` | Hooks that run when Claude Code starts a new session or resumes |
| **UserPromptSubmit** | `ClaudeHooks::UserPromptSubmit` | Hooks that run before the user's prompt is processed |
| **Notification** | `ClaudeHooks::Notification` | Hooks that run when Claude Code sends notifications |
| **PreToolUse** | `ClaudeHooks::PreToolUse` | Hooks that run before a tool is used |
| **PostToolUse** | `ClaudeHooks::PostToolUse` | Hooks that run after a tool is used |
| **Stop** | `ClaudeHooks::Stop` | Hooks that run when Claude Code finishes responding |
| **SubagentStop** | `ClaudeHooks::SubagentStop` | Hooks that run when subagent tasks complete |
| **PreCompact** | `ClaudeHooks::PreCompact` | Hooks that run before transcript compaction |

## 🚀 Claude Hook Flow

### A very simplified view of how a hook works in Claude Code

```mermaid
graph LR
  A[Hook triggers] --> B[JSON from STDIN] --> C[Hook does its thing] --> D[JSON to STDOUT or STDERR] --> E[Yields back to Claude Code] --> A
```

### 🔄 Proposal: a more robust Claude Hook execution flow

1. An entrypoint for a hook is set in `~/.claude/settings.json`
2. Claude Code calls the entrypoint script (e.g., `hooks/entrypoints/pre_tool_use.rb`)
3. The entrypoint script reads STDIN and coordinates multiple **hook handlers**
4. Each **hook handler** executes and returns its output data
5. The entrypoint script combines/processes outputs from multiple **hook handlers**
6. And then returns final JSON response to Claude Code

```mermaid
graph TD
  A[🔧 Hook Configuration<br/>settings.json] --> B
  B[🤖 Claude Code<br/><em>User submits prompt</em>] --> C[📋 Entrypoint<br />entrypoints/user_prompt_submit.rb]

  C --> D[📋 Entrypoint<br />Parses JSON from STDIN]
  D --> E[📋 Entrypoint<br />Calls hook handlers]

  E --> F[📝 Handler<br />AppendContextRules.call<br/><em>Returns output_data</em>]
  E --> G[📝 Handler<br />PromptGuard.call<br/><em>Returns output_data</em>]

  F --> J[📋 Entrypoint<br />Calls _ClaudeHooks::UserPromptSubmit.merge_outputs_ to 🔀 merge outputs]
  G --> J

  J --> K[📋 Entrypoint<br />Outputs JSON to STDOUT or STDERR]
  K --> L[🤖 Yields back to Claude Code]
  L --> B
```

### Basic Hook Handler Structure

```ruby
#!/usr/bin/env ruby

require 'claude_hooks'

class AddContextAfterPrompt < ClaudeHooks::UserPromptSubmit
  def call
    # Access input data
    log do
      "--- INPUT DATA ---"
      "session_id: #{session_id}"
      "cwd: #{cwd}"
      "hook_event_name: #{hook_event_name}"
      "prompt: #{current_prompt}"
      "---"
    end

    log "Full conversation transcript: #{read_transcript}"

    add_additional_context!("Some custom context")

    # Block the prompt
    if current_prompt.include?("bad word")
      block_prompt!("Hmm no no no!")
      log "Prompt blocked: #{current_prompt} because of bad word"
    end

    # Return output data
    output_data
  end
end
```

### Input Fields

The framework supports all existing hook types with their respective input fields:

| Hook Type | Input Fields |
|-----------|--------------|
| **Common**  | `session_id`, `transcript_path`, `cwd`, `hook_event_name` |
| **UserPromptSubmit**  | `prompt` |
| **PreToolUse**  | `tool_name`, `tool_input` |
| **PostToolUse**  | `tool_name`, `tool_input`, `tool_response` |
| **Notification**  | `message` |
| **Stop**  | `stop_hook_active` |
| **SubagentStop**  | `stop_hook_active` |
| **PreCompact**  | `trigger`, `custom_instructions` |
| **SessionStart**  | `source` |

## 📚 API Reference

The whole purpose of those APIs is to simplify reading from STDIN and writing to STDOUT the way Claude Code expects you to.

### Common API Methods

Those methods are available in **all hook types** and are inherited from `ClaudeHooks::Base`:

#### Input Methods
Input methods are helpers to access data parsed from STDIN.

| Method | Description |
|--------|-------------|
| `input_data` | Input data reader |
| `session_id` | Get the current session ID |
| `transcript_path` | Get path to the transcript file |
| `cwd` | Get current working directory |
| `hook_event_name` | Get the hook event name |
| `read_transcript` | Read the transcript file |
| `transcript` | Alias for `read_transcript` |

#### Output Methods
Output methods are helpers to modify `output_data`.

| Method | Description |
|--------|-------------|
| `output_data` | Output data accessor |
| `stringify_output` | Generates a JSON string from `output_data` |
| `allow_continue!` | Allow Claude to continue (default) |
| `prevent_continue!(reason)` | Stop Claude with reason |
| `suppress_output!` | Hide stdout from transcript |
| `show_output!` | Show stdout in transcript (default) |
| `clear_specifics!` | Clear hook-specific output |

#### Class Output Methods

Each hook type provides a **class method** `merge_outputs` that will try to intelligently merge multiple hook results, e.g. `ClaudeHooks::UserPromptSubmit.merge_outputs(output1, output2, output3)`.

| Method | Description |
|--------|-------------|
| `merge_outputs(*outputs_data)` | Intelligently merge multiple outputs into a single output |

### Configuration and Utility Methods

Available in all hooks via the base `ClaudeHooks::Base` class:

#### Utility Methods
| Method | Description |
|--------|-------------|
| `log(message, level: :info)` | Log to session-specific file (levels: :info, :warn, :error) |

#### Configuration Methods
| Method | Description |
|--------|-------------|
| `home_claude_dir` | Get the home Claude directory (`$HOME/.claude`) |
| `project_claude_dir` | Get the project Claude directory (`$CLAUDE_PROJECT_DIR/.claude`, or `nil`) |
| `home_path_for(relative_path)` | Get absolute path relative to home Claude directory |
| `project_path_for(relative_path)` | Get absolute path relative to project Claude directory (or `nil`) |
| `base_dir` | Get the base Claude directory (**deprecated**) |
| `path_for(relative_path, base_dir=nil)` | Get absolute path relative to specified or default base dir (**deprecated**) |
| `config` | Access the merged configuration object |
| `config.get_config_value(env_key, config_file_key, default)` | Get any config value with fallback |
| `config.logs_directory` | Get logs directory path (always under home directory) |
| `config.your_custom_key` | Access any custom config via method_missing |


### UserPromptSubmit API

Available when inheriting from `ClaudeHooks::UserPromptSubmit`:

#### Input Methods
| Method | Description |
|--------|-------------|
| `prompt` | Get the user's prompt text |
| `user_prompt` | Alias for `prompt` |
| `current_prompt` | Alias for `prompt` |

#### Output Methods
| Method | Description |
|--------|-------------|
| `add_additional_context!(context)` | Add context to the prompt |
| `add_context!(context)` | Alias for `add_additional_context!` |
| `empty_additional_context!` | Remove additional context |
| `block_prompt!(reason)` | Block the prompt from processing |
| `unblock_prompt!` | Unblock a previously blocked prompt |

### PreToolUse API

Available when inheriting from `ClaudeHooks::PreToolUse`:

#### Input Methods
| Method | Description |
|--------|-------------|
| `tool_name` | Get the name of the tool being used |
| `tool_input` | Get the input data for the tool |

#### Output Methods
| Method | Description |
|--------|-------------|
| `approve_tool!(reason)` | Explicitly approve tool usage |
| `block_tool!(reason)` | Block tool usage with feedback |
| `ask_for_permission!(reason)` | Request user permission |

### PostToolUse API

Available when inheriting from `ClaudeHooks::PostToolUse`:

#### Input Methods
| Method | Description |
|--------|-------------|
| `tool_name` | Get the name of the tool that was used |
| `tool_input` | Get the input that was passed to the tool |
| `tool_response` | Get the tool's response/output |

#### Output Methods
| Method | Description |
|--------|-------------|
| `block_tool!(reason)` | Block the tool result from being used |
| `approve_tool!(reason)` | Clear any previous block decision (allows tool result) |

### Notification API

Available when inheriting from `ClaudeHooks::Notification`:

#### Input Methods
| Method | Description |
|--------|-------------|
| `message` | Get the notification message content |
| `notification_message` | Alias for `message` |

#### Output Methods
Notifications are outside facing and do not have any specific output methods.

### Stop API

Available when inheriting from `ClaudeHooks::Stop`:

#### Input Methods
| Method | Description |
|--------|-------------|
| `stop_hook_active` | Check if Claude Code is already continuing as a result of a stop hook |

#### Output Methods
| Method | Description |
|--------|-------------|
| `continue_with_instructions!(instructions)` | Block Claude from stopping and provide instructions to continue |
| `block!(instructions)` | Alias for `continue_with_instructions!` |
| `ensure_stopping!` | Allow Claude to stop normally (default behavior) |

### SubagentStop API

Available when inheriting from `ClaudeHooks::SubagentStop` (inherits from `ClaudeHooks::Stop`):

#### Input Methods
| Method | Description |
|--------|-------------|
| `stop_hook_active` | Check if Claude Code is already continuing as a result of a stop hook |

#### Output Methods
| Method | Description |
|--------|-------------|
| `continue_with_instructions!(instructions)` | Block Claude from stopping and provide instructions to continue |
| `block!(instructions)` | Alias for `continue_with_instructions!` |
| `ensure_stopping!` | Allow Claude to stop normally (default behavior) |

### PreCompact API

Available when inheriting from `ClaudeHooks::PreCompact`:

#### Input Methods
| Method | Description |
|--------|-------------|
| `trigger` | Get the compaction trigger: `'manual'` or `'auto'` |
| `custom_instructions` | Get custom instructions (only available for manual trigger) |

#### Output Methods
No specific output methods are available to alter compaction behavior.

#### Utility Methods
| Method | Description |
|--------|-------------|
| `backup_transcript!(backup_file_path)` | Create a backup of the transcript at the specified path |

### SessionStart API

Available when inheriting from `ClaudeHooks::SessionStart`:

#### Input Methods
| Method | Description |
|--------|-------------|
| `source` | Get the session start source: `'startup'`, `'resume'`, or `'clear'` |

#### Output Methods
| Method | Description |
|--------|-------------|
| `add_additional_context!(context)` | Add contextual information for Claude's session |
| `add_context!(context)` | Alias for `add_additional_context!` |
| `empty_additional_context!` | Clear additional context |

### 📝 Logging

`ClaudeHooks::Base` provides a **session logger** that will write logs to session-specific files.

```ruby
log "Simple message"
log "Error occurred", level: :error
log "Warning about something", level: :warn

log <<~TEXT
  Configuration loaded successfully
  Database connection established
  System ready
TEXT
```

You can also use the logger from an entrypoint script:
```ruby
require 'claude_hooks'

logger = ClaudeHooks::Logger.new("TEST-SESSION-01", 'entrypoint')
logger.log "Simple message"
```

#### Log File Location
Logs are written to session-specific files in the configured log directory:
- **Defaults to**: `~/.claude/logs/hooks/session-{session_id}.log`
- **Configurable path**: Set via `config.json` → `logDirectory` or via `RUBY_CLAUDE_HOOKS_LOG_DIR` environment variable

#### Log Output Format
```
[2025-08-16 03:45:28] [INFO] [MyHookHandler] Starting execution
[2025-08-16 03:45:28] [ERROR] [MyHookHandler] Connection timeout
```

## 📝 Example: Tool usage monitor

Let's create a hook that will monitor tool usage and ask for permission before using dangerous tools.

First, register an entrypoint in `~/.claude/settings.json`:

```json
"hooks": {
  "PreToolUse": [
    {
      "matcher": "",
      "hooks": [
        {
          "type": "command",
          "command": "~/.claude/hooks/entrypoints/pre_tool_use.rb"
        }
      ]
    }
  ],
}
```

Then, create your main entrypoint script and don't forget to make it executable:
```bash
touch ~/.claude/hooks/entrypoints/pre_tool_use.rb
chmod +x ~/.claude/hooks/entrypoints/pre_tool_use.rb
```

```ruby
#!/usr/bin/env ruby

require 'json'
require_relative '../handlers/pre_tool_use/tool_monitor'

begin
  # Read input from stdin
  input_data = JSON.parse(STDIN.read)

  tool_monitor = ToolMonitor.new(input_data)
  output = tool_monitor.call

  # Any other hook scripts can be chained here

  puts JSON.generate(output)

rescue JSON::ParserError => e
  log "Error parsing JSON: #{e.message}", level: :error
  puts JSON.generate({
    continue: false,
    stopReason: "JSON parsing error: #{e.message}",
    suppressOutput: false
  })
  exit 0
rescue StandardError => e
  log "Error in ToolMonitor hook: #{e.message}", level: :error
  puts JSON.generate({
    continue: false,
    stopReason: "Hook execution error: #{e.message}",
    suppressOutput: false
  })
  exit 0
end
```

Finally, create the handler that will be used to monitor tool usage.

```bash
touch ~/.claude/hooks/handlers/pre_tool_use/tool_monitor.rb
```

```ruby
#!/usr/bin/env ruby

require 'claude_hooks'

class ToolMonitor < ClaudeHooks::PreToolUse
  DANGEROUS_TOOLS = %w[curl wget rm].freeze

  def call
    log "Monitoring tool usage: #{tool_name}"

    if DANGEROUS_TOOLS.include?(tool_name)
      log "Dangerous tool detected: #{tool_name}", level: :warn
      ask_for_permission!("The tool '#{tool_name}' can impact your system. Allow?")
    else
      approve_tool!("Safe tool usage")
    end

    output_data
  end
end
```

## 🔄 Hook Output

### 🔄 Hook Output Merging

Each hook script type provides a merging method `merge_outputs` that will try to intelligently merge multiple hook results:

```ruby
# Merge results from multiple UserPromptSubmit hooks
merged_result = ClaudeHooks::UserPromptSubmit.merge_outputs(output1, output2, output3)

# ClaudeHooks::UserPromptSubmit.merge_outputs follows the following merge logic:
# - continue: false wins (any hook script can stop execution)
# - suppressOutput: true wins (any hook script can suppress output)
# - decision: "block" wins (any hook script can block)
# - stopReason/reason: concatenated
# - additionalContext: joined
```

### 🚪 Hook Exit Codes

Claude Code hooks support multiple exit codes with different behaviors depending on the hook type.

### Pattern 1: Simple Exit Codes
- **`exit 0`**: Success, allows the operation to continue, for most hooks, `STDOUT` will be fed back to the user.
- **`exit 1`**: Non-blocking error, `STDERR` will be fed back to the user.
- **`exit 2`**: Blocking error, in most cases `STDERR` will be fed back to Claude.
- **Other exit codes**: Treated as non-blocking errors - `STDERR` fed back to the user, execution continues.

Some exit codes have different meanings depending on the hook type, here is a table to help summarize this:

| Hook Event       | Exit Code 0 (Success)                                      | Exit Code 1 and other Exit Codes (Non-blocking Error) | Exit Code 2 (Blocking Error)                                   |
|------------------|------------------------------------------------------------|-------------------------------------------------------|----------------------------------------------------------------|
| UserPromptSubmit | Operation continues<br/><br />$\color{Orange}{\textsf{`STDOUT` added as context to Claude}}$       | Non-blocking error<br/><br />`STDERR` shown to user                | Blocks prompt processing<br/><br />Erases prompt<br/><br />`STDERR` shown to user only |
| PreToolUse       | Operation continues<br/><br />`STDOUT` shown to user in transcript mode | Non-blocking error<br/><br />`STDERR` shown to user                | Blocks the tool call<br/><br />`STDERR` shown to Claude                     |
| PostToolUse      | Operation continues<br/><br />`STDOUT` shown to user in transcript mode | Non-blocking error<br/><br />`STDERR` shown to user                | N/A<br/><br />`STDERR` shown to Claude (tool already ran)                   |
| Notification     | Operation continues<br/><br />`STDOUT` shown to user in transcript mode | Non-blocking error<br/><br />`STDERR` shown to user                | N/A<br/><br />`STDERR` shown to user only                                   |
| Stop             | Operation continues<br/><br />`STDOUT` shown to user in transcript mode | Non-blocking error<br/><br />`STDERR` shown to user                | Blocks stoppage<br/><br />`STDERR` shown to Claude                          |
| SubagentStop     | Operation continues<br/><br />`STDOUT` shown to user in transcript mode | Non-blocking error<br/><br />`STDERR` shown to user                | Blocks stoppage<br/><br />`STDERR` shown to Claude subagent                 |
| PreCompact       | Operation continues<br/><br />`STDOUT` shown to user in transcript mode | Non-blocking error<br/><br />`STDERR` shown to user                | N/A<br/><br />`STDERR` shown to user only                                   |
| SessionStart     | Operation continues<br/><br />`STDOUT` added as context to Claude       | Non-blocking error<br/><br />`STDERR` shown to user                | N/A<br/><br />`STDERR` shown to user only                                   |
| SessionEnd       | Operation continues<br/><br />`STDOUT` shown to user in transcript mode | Non-blocking error<br/><br />`STDERR` shown to user                | N/A<br/><br />`STDERR` shown to user only                                   |




### Example: Success
For the operation to continue for a UserPromptSubmit hook, you would return structured JSON data followed by `exit 0`:

```ruby
puts JSON.generate({
  continue: true,
  stopReason: "",
  suppressOutput: false,
  hookSpecificOutput: {
    hookEventName: "UserPromptSubmit",
    additionalContext: "context here"
  }
})
exit 0
```

### Example: Error

For the operation to stop for a UserPromptSubmit hook, you would return structured JSON data followed by `exit 1`:

```ruby
STDERR.puts JSON.generate({
  continue: false,
  stopReason: "JSON parsing error: #{e.message}",
  suppressOutput: false
})
exit 1
```

> [!WARNING]
> Don't forget to use `STDERR.puts` to output the JSON to STDERR.


## 🚨 Advices

1. **Logging**: Use `log()` method instead of `puts` to avoid interfering with JSON output
2. **Error Handling**: Hooks should handle their own errors and use the `log` method for debugging. For errors, don't forget to exit with the right exit code (1, 2) and output the JSON indicating the error to STDERR using `STDERR.puts`.
3. **Output Format**: Always return `output_data` or `nil` from your `call` method
4. **Path Management**: Use `path_for()` for all file operations relative to the Claude base directory

## ⚠️ Troubleshooting

### Make your entrypoint scripts executable

Don't forget to make the scripts called from `settings.json` executable:

```bash
chmod +x ~/.claude/hooks/entrypoints/user_prompt_submit.rb
```


## 🧪 CLI Debugging

The `ClaudeHooks::CLI` module provides utilities to simplify testing hooks in isolation. Instead of writing repetitive JSON parsing and error handling code, you can use the CLI test runner.

### Basic Usage

Replace the traditional testing boilerplate:

```ruby
# Old way (15+ lines of repetitive code)
if __FILE__ == $0
  begin
    require 'json'
    input_data = JSON.parse(STDIN.read)
    hook = MyHook.new(input_data)
    result = hook.call
    puts JSON.generate(result)
  rescue StandardError => e
    STDERR.puts "Error: #{e.message}"
    puts JSON.generate({
      continue: false,
      stopReason: "Error: #{e.message}",
      suppressOutput: false
    })
    exit 1
  end
end
```

With the simple CLI test runner:

```ruby
# New way (1 line!)
if __FILE__ == $0
  ClaudeHooks::CLI.test_runner(MyHook)
end
```

### Customization with Blocks

You can customize the input data for testing using blocks:

```ruby
if __FILE__ == $0
  ClaudeHooks::CLI.test_runner(MyHook) do |input_data|
    input_data['debug_mode'] = true
    input_data['custom_field'] = 'test_value'
    input_data['user_name'] = 'TestUser'
  end
end
```

### Testing Methods

#### 1. Test with STDIN (default)
```ruby
ClaudeHooks::CLI.test_runner(MyHook)
# Usage: echo '{"session_id":"test","prompt":"Hello"}' | ruby my_hook.rb
```

#### 2. Test with default sample data instead of STDIN
```ruby
ClaudeHooks::CLI.run_with_sample_data(MyHook, { 'prompt' => 'test prompt' })
# Provides default values, no STDIN needed
```

#### 3. Test with Sample Data + Customization
```ruby
ClaudeHooks::CLI.run_with_sample_data(MyHook) do |input_data|
  input_data['prompt'] = 'Custom test prompt'
  input_data['debug'] = true
end
```

### Example Hook with CLI Testing

```ruby
#!/usr/bin/env ruby

require 'claude_hooks'

class MyTestHook < ClaudeHooks::UserPromptSubmit
  def call
    log "Debug mode: #{input_data['debug_mode']}"
    log "Processing: #{prompt}"

    if input_data['debug_mode']
      log "All input keys: #{input_data.keys.join(', ')}"
    end

    output_data
  end
end

# Test runner with customization
if __FILE__ == $0
  ClaudeHooks::CLI.test_runner(MyTestHook) do |input_data|
    input_data['debug_mode'] = true
  end
end
```

## 🐛 Debugging

### Test an individual entrypoint

```bash
# Test with sample data
echo '{"session_id": "test", "transcript_path": "/tmp/transcript", "cwd": "/tmp", "hook_event_name": "UserPromptSubmit", "user_prompt": "Hello Claude"}' | ruby ~/.claude/hooks/entrypoints/user_prompt_submit.rb
```
