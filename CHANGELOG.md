# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.2] - 2026-01-04

### Fixed

- **Critical: Fixed hook output contract for JSON API** - Stop, PostToolUse, UserPromptSubmit, and PreToolUse hooks now correctly use stdout + exit 0 when outputting structured JSON
  - Stop hooks now output to stdout with exit 0 instead of stderr with exit 2 (PR #15, fixes #11)
  - PostToolUse hooks now use stdout + exit 0 for JSON API consistency
  - UserPromptSubmit hooks now use stdout + exit 0 for JSON API consistency
  - PreToolUse hooks now use exit 0 for all permission decisions (previously varied: 0 for allow, 1 for ask, 2 for deny)
  - This aligns with Anthropic's official guidance: when using advanced JSON API with decision/reason fields, hooks must output to stdout with exit 0
  - **Breaking behavior fixed**: Plugin hooks with `continue_with_instructions!` now work correctly
  - Reference: https://github.com/anthropics/claude-code/issues/10875
  - Reference: https://github.com/gabriel-dehan/claude_hooks/issues/11

### Notes

- All tests updated and passing (147 runs, 262 assertions, 0 failures)
- This fix ensures compatibility with Claude Code's plugin system
- The exit code 2 + stderr approach is only for simple text output without JSON structure

## [1.0.1] - 2025-10-13

### Documentation

- **Added comprehensive plugin hooks documentation** - Full guide on using the Claude Hooks DSL with Claude Code plugins
  - New "Plugin Hooks Support" section in README with working examples
  - Created `example_dotclaude/plugins/README.md` with complete plugin development guide
  - Example plugin formatter implementation using the DSL
  - Environment variables documentation for plugin development
  - Best practices and testing instructions for plugin hooks
- **Updated SessionStart hook documentation** - Added the new `compact` matcher introduced in official Claude Hooks documentation
  - Updated `docs/API/SESSION_START.md` to include `'compact'` as a valid source value
  - Updated SessionStart hook type description to mention compact functionality
- **Synchronized with official documentation** - All documentation now matches the official Claude Hooks reference as of 2025-10-13
  - Plugin hooks feature (Issue #9)
  - SessionStart `compact` matcher (Issue #2)

### Notes

- No code changes required - the implementation already supports all documented features
- The DSL's dynamic implementation handles the new `compact` source automatically
- Plugin environment variables (`CLAUDE_PLUGIN_ROOT`) work seamlessly with existing configuration system

## [1.0.0] - 2025-08-27

> [!WARNING]
> These changes are not backward compatible (hence the version bump to 1.0.0), the API has changed too much.

Follow the [migration guide](docs/1.0.0_MIGRATION_GUIDE.md) to migrate to the new API.

### Changed

#### Revamped documentation

- **New documentation structure**:
  - **API Reference**: Comprehensive API reference for all hook types
  - **Common Helpers**: Shared helpers for all hook types
  - **Output Helpers**: Helpers for working with the output state
  - **Hook Exit Codes**: Exit codes for each hook type
  - **Hook Types**: Overview of all hook types and their purpose

#### Added support for SessionEnd
Handles the new `SessionEnd` hook type.

#### Handles new field for PostToolUse
`additionalContext` field is now available in the `hookSpecificOutput` field.

#### Output Objects System
New output handling with intelligent exit code management.

- **Automatic Exit Code Selection**: Output objects automatically choose the correct exit code (0, 1, 2) based on hook type and the state of the hook
- - **Enhanced Base Class**: All hook instances now automatically get an `@output` attribute with a `output` accessor. They can still access raw `output_data`
- **Helper Methods**: Access to hook-specific data via methods like `output.blocked?`, `output.allowed?`, `output.should_ask_permission?`
- **Automatic Stream Selection**: Output objects automatically route to `STDOUT` or `STDERR` based on exit code and hook type
- **One-Line Output Execution**: New `output_and_exit` method handles JSON serialization, stream selection, and exit code in one call
- **Object-Based Merging**: New `ClaudeHooks::Output::*.merge()` methods for cleaner multi-hook merging
- **Comprehensive Output Classes**: Full coverage for all 8 hook types:
  - `ClaudeHooks::Output::UserPromptSubmit` - Provides `blocked?`, `reason`, `additional_context`
  - `ClaudeHooks::Output::PreToolUse` - Provides `allowed?`, `denied?`, `should_ask_permission?`
  - `ClaudeHooks::Output::PostToolUse` - Provides `blocked?`, `reason`
  - `ClaudeHooks::Output::Stop` - Provides `should_continue?`, `continue_instructions` (inverted logic)
  - `ClaudeHooks::Output::SubagentStop` - Inherits Stop behavior
  - `ClaudeHooks::Output::Notification` - Basic output handling
  - `ClaudeHooks::Output::SessionStart` - Provides `additional_context`
  - `ClaudeHooks::Output::PreCompact` - Basic output handling

##### Migration Guide

**Before (Old Pattern):**
```ruby
#!/usr/bin/env ruby
require 'claude_hooks'

begin
  input_data = JSON.parse(STDIN.read)
  hook = MyHook.new(input_data)
  result = hook.call

  # Manual stream and exit code selection
  if result['continue'] != false
    if result.dig('hookSpecificOutput', 'permissionDecision') == 'deny'
      STDERR.puts hook.stringify_output
      exit 1
    elsif result.dig('hookSpecificOutput', 'permissionDecision') == 'ask'
      STDERR.puts hook.stringify_output
      exit 2
    else
      puts hook.stringify_output
      exit 0
    end
  else # Continue == false
    STDERR.puts hook.stringify_output
    exit 2
  end
rescue StandardError => e
  # Error handling...
end
```

**After (New Pattern):**
```ruby
#!/usr/bin/env ruby
require 'claude_hooks'

# Just 3 lines for most cases!
begin
  input_data = JSON.parse(STDIN.read)
  hook = MyHook.new(input_data)
  hook.call

  # Handles everything automatically!
  hook.output_and_exit
rescue StandardError => e
  # Error handling...
end
```

## [0.2.1] - 2025-08-21

### Fixed
- Fixed name of environment variable for the merge strategy

## [0.2.0] - 2025-08-21

### Added
- **Dual Configuration System**: Support for both home-level (`$HOME/.claude`) and project-level (`$CLAUDE_PROJECT_DIR/.claude`) configurations
- **Configuration Merging**: Intelligent merging of home and project configs with configurable precedence
- New environment variable `RUBY_CLAUDE_HOOKS_CONFIG_MERGE_STRATEGY` to control merge behavior ("project" or "home")
- New directory access methods: `home_claude_dir`, `project_claude_dir`
- New path utility methods: `home_path_for(path)`, `project_path_for(path)`
- Enhanced `path_for(path, base_dir=nil)` method with optional base directory parameter
- Comprehensive test suite for configuration functionality (`test/` directory)
- Configuration validation and edge case handling for missing `CLAUDE_PROJECT_DIR`

### Changed
- **Logs Location**: Logs now always go to `$HOME/.claude/{logDirectory}` regardless of active configuration
- Configuration loading now supports dual config file locations with intelligent merging
- Enhanced documentation with comprehensive dual configuration examples
- Updated API reference with new directory and path methods

### Deprecated
- `base_dir` method (still functional for backward compatibility)
- `RUBY_CLAUDE_HOOKS_BASE_DIR` environment variable (still supported as fallback)

### Fixed
- Graceful handling of undefined `CLAUDE_PROJECT_DIR` environment variable
- Proper path resolution when project directory is not available
- Backward compatibility maintained for all existing hook scripts

### Migration Notes
- Existing configurations continue to work without changes
- New projects can leverage dual configuration system
- `base_dir` and legacy `path_for` methods remain functional
- Environment variables maintain same precedence over config files

## [0.1.0] - 2025-08-17

### Added
- Initial release of claude_hooks gem
- Ruby DSL framework for creating Claude Code hooks
- Support for all 8 hook types: UserPromptSubmit, PreToolUse, PostToolUse, Notification, Stop, SubagentStop, PreCompact, SessionStart
- Environment-based configuration with `RUBY_CLAUDE_HOOKS_` prefix
- Session-based logging system
- Intelligent output merging for multiple hook scripts
- Comprehensive API for each hook type
- Examples directory with working hook scripts
- Zero-configuration setup with smart defaults

### Changed
- Migrated from local file-based configuration to gem-based distribution
- Updated all hook classes to use `ClaudeHooks::` namespace
- Replaced `ClaudeConfig::ConfigLoader` with `ClaudeHooks::Configuration`
- Moved `SessionLogger` to `ClaudeHooks::Logger`

### Migration Notes
- Update `require_relative` statements to `require 'claude_hooks'`
- Change hook class inheritance from `HookTypes::Base` to `ClaudeHooks::Base`
- Replace specific hook classes: `UserPromptSubmitHook` → `ClaudeHooks::UserPromptSubmit`, etc.
- Set environment variables with `RUBY_CLAUDE_HOOKS_` prefix instead of relying on config file
