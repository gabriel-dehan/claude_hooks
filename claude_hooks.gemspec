# frozen_string_literal: true

require_relative "lib/claude_hooks/version"

Gem::Specification.new do |spec|
  spec.name = "claude_hooks"
  spec.version = ClaudeHooks::VERSION
  spec.authors = ["Gabriel Dehan"]
  spec.email = ["dehan.gabriel@gmail.com"]

  spec.summary = "Ruby DSL for creating Claude Code hooks"
  spec.description = "A Ruby DSL framework for creating Claude Code hooks with composable hook scripts that enable teams to easily implement logging, security checks, and workflow automation."
  spec.homepage = "https://github.com/gabriel-dehan/claude_hooks"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "json", "~> 2.0"

  # Development dependencies
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
