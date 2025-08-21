# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2025-08-21

### Added
- **Dual Configuration System**: Support for both home-level (`$HOME/.claude`) and project-level (`$CLAUDE_PROJECT_DIR/.claude`) configurations
- **Configuration Merging**: Intelligent merging of home and project configs with configurable precedence
- New environment variable `CLAUDE_HOOKS_CONFIG_MERGE_STRATEGY` to control merge behavior ("project" or "home")
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
