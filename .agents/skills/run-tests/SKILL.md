---
name: run-tests
description: >
  How to install dependencies and run the claude_hooks test suite.
  Use this skill whenever you need to verify that code changes pass the tests
  before committing.
triggers:
  - test
  - tests
  - spec
  - run_all_tests
---

# Running the claude_hooks Test Suite

This is a **Ruby gem**. Always run the full test suite after any code change and
before committing.

## Install dependencies

```bash
bundle install
```

## Run all tests

```bash
ruby test/run_all_tests.rb
```

The suite must exit 0 before you commit. All files matching `test/test_*.rb` are
included automatically.

## Adding or updating tests

- Place new test files in `test/` named `test_<feature>.rb`.
- Use plain `Test::Unit` / `Minitest` — no RSpec.
- Run the full suite, not just the new file, to catch regressions.

## Common failure patterns

- **Missing gem**: run `bundle install` again; check `Gemfile.lock` was updated.
- **LoadError**: verify the `require` path matches the file under `lib/`.
- **Unexpected output**: the hooks write to `$stderr`; redirect if your test
  captures stdout only.
