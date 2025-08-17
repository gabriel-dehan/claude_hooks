# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-08-17

### Added
- Initial release of claude_hooks gem
- Ruby DSL framework for creating Claude Code hooks
- Support for all 8 hook types: UserPromptSubmit, PreToolUse, PostToolUse, Notification, Stop, SubagentStop, PreCompact, SessionStart
- Environment-based configuration with `RUBY_CLAUDE_CODE_` prefix
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
- Set environment variables with `RUBY_CLAUDE_CODE_` prefix instead of relying on config file