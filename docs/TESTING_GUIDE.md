# Testing Guide

## Overview

**All code in this repository MUST have tests with 100% coverage before being committed.**

This is enforced by:

- Pre-commit hooks (block untested code)
- CI workflows (run tests on every PR)
- Coverage reports (track test coverage)

---

## Quick Start

### 1. Install Test Dependencies

```bash
cd ~/Projects/waldiez/xperiens
chmod +x tests/install_test_deps.sh
./tests/install_test_deps.sh
```

This installs:

- BATS (Bash Automated Testing System)
- yq (YAML processor)
- shellcheck (optional linting)

### 2. Run All Tests

```bash
chmod +x tests/run_all_tests.sh
./tests/run_all_tests.sh
```

### 3. Check Coverage

```bash
chmod +x tests/coverage_report.sh
./tests/coverage_report.sh
```

### 4. Install Pre-Commit Hook

```bash
ln -s ../../tests/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

Now `git commit` will automatically run tests!

---

## Test Structure

```text
tests/
├── unit/                          # Unit tests (one file per script)
│   ├── test_time_clock_updater.bats
│   ├── test_update_readme.bats
│   ├── test_check_tic_immutable.bats
│   ├── ...
│   └── ...
│
├── integration/                   # Integration tests (workflows)
|   ├── test_time_clock_updater.bats
│   ├── ...
│   └── ...
│
├── fixtures/                      # Test data
│   ├── valid.tic
│   ├── ...
│   └── valid_manifest.yml
│
├── helpers/                       # Test utilities
│   ├── test_helper.bash
│   ├── ...
│   └── ...
│
├── install_test_deps.sh          # Dependency installer
├── run_all_tests.sh              # Master test runner
├── coverage_report.sh            # Coverage checker
├── pre-commit                    # Git hook
├── ...
└── ...
```

---

## Writing Tests

### BATS Basics

```bash
#!/usr/bin/env bats

load ../helpers/test_helper

setup() {
  # Runs before each test
  setup_test_waldiez
}

teardown() {
  # Runs after each test
  teardown_test_waldiez
}

@test "descriptive test name" {
  # Arrange
  create_test_tic
  
  # Act
  run bash scripts/my_script.sh
  
  # Assert
  [ "$status" -eq 0 ]
  assert_file_exists "/path/to/output"
}
```

### Assertions

From `test_helper.bash`:

- `assert_file_exists <path>`
- `assert_file_not_exists <path>`
- `assert_file_contains <path> <text>`
- `assert_line_count <path> <count>`
- `assert_yaml_field <path> <field> [expected_value]`

### Test Helpers

- `setup_test_waldiez` - Create isolated test environment
- `teardown_test_waldiez` - Cleanup test environment
- `create_test_tic [dir]` - Create valid .tic file
- `create_test_manifest [dir]` - Create valid MANIFEST
- `create_test_toc [dir] [dates...]` - Create .toc with dates
- `get_current_date` - Get UTC date for tests
- `get_current_timestamp` - Get UTC timestamp for tests

---

## Coverage Requirements

### 100% Coverage Rule

Every script MUST have:

1. **Unit tests** covering all functions/branches
2. **Integration tests** if it interacts with other scripts
3. **Edge case tests** (empty files, missing files, invalid input)
4. **Idempotency tests** (can run multiple times safely)

### Coverage Report Format

Example output (numbers change):

```text
==========================================
  Waldiez Test Coverage Report
==========================================

Running full test suite...
✓ All tests passed

Script                                           Tests  Status
-----------------------------------------------------------------------------
scripts/agents/time/clock/time_clock_updater.sh  ✓  15 tests  PASS
scripts/agents/time/clock/update_readme.sh       ✓   6 tests  PASS
scripts/clean_for_first_commit.sh                ✓   1 tests  PASS
scripts/lib/colors.sh                            ✓   1 tests  PASS
scripts/lib/date_utils.sh                        ✓   4 tests  PASS
scripts/lib/os_utils.sh                          ✓  12 tests  PASS
scripts/lint.sh                                  ✓   2 tests  PASS
scripts/lint/install_lint_deps.sh                ✓   8 tests  PASS
scripts/lint/lint_bash.sh                        ✓   1 tests  PASS
scripts/lint/lint_markdown.sh                    ✓   1 tests  PASS
scripts/lint/lint_yaml.sh                        ✓   1 tests  PASS
scripts/validate_first_commit_ready.sh           ✓   2 tests  PASS
scripts/validation/check_manifest_sections.sh    ✓   7 tests  PASS
scripts/validation/check_tic_immutable.sh        ✓   5 tests  PASS
-----------------------------------------------------------------------------

Summary:
  Total scripts:    14
  With tests:       14

  Total tests:      66

  Test coverage:    100%

✓ 100% coverage achieved! All tests passing.
```

---

## Test Workflow

### Before Writing Code

1. Write tests first (TDD approach)
2. Tests should fail initially
3. Implement code until tests pass

### When Modifying Code

1. Update existing tests if behavior changes
2. Add new tests for new functionality
3. Verify coverage remains 100%

### Before Committing

```bash
# Run tests
./tests/run_all_tests.sh

# Check coverage
./tests/coverage_report.sh

# If both pass, commit
git add .
git commit -m "feat: Add feature"
# Pre-commit hook runs automatically
```

---

## CI Integration

### GitHub Actions

`.github/workflows/test.yml` runs:

- All unit tests
- All integration tests
- Coverage check (must be 100%)
- Blocks PR if tests fail

### GitLab CI

`.gitlab-ci.yml` includes test stage:

- Same tests as GitHub
- Runs before deploy/release
- Blocks merge if coverage < 100%

---

## Common Test Patterns

### Testing File Creation

```bash
@test "script creates output file" {
  assert_file_not_exists "output.txt"
  
  run bash scripts/my_script.sh
  
  assert_file_exists "output.txt"
  assert_file_contains "output.txt" "expected content"
}
```

### Testing Idempotency

```bash
@test "script is idempotent" {
  # Run three times
  bash scripts/my_script.sh
  bash scripts/my_script.sh
  bash scripts/my_script.sh
  
  # Verify output is identical
  assert_line_count "output.txt" 1
}
```

### Testing Error Handling

```bash
@test "script fails gracefully on invalid input" {
  run bash scripts/my_script.sh "invalid"
  
  [ "$status" -ne 0 ]
  [[ "$output" =~ "Error:" ]]
}
```

### Testing State Changes

```bash
@test "script updates state correctly" {
  # Before
  BEFORE=$(yq eval '.state.counter' MANIFEST)
  
  # Act
  bash scripts/my_script.sh
  
  # After
  AFTER=$(yq eval '.state.counter' MANIFEST)
  
  [ "$AFTER" -gt "$BEFORE" ]
}
```

---

## Troubleshooting

### Tests Pass Locally But Fail in CI

- Check paths (use relative paths)
- Check dependencies (ensure CI has yq, etc.)
- Check date/time assumptions (use mocks)

### Coverage Report Shows Missing Tests

1. Identify script without tests
2. Create `tests/unit/test_<script_name>.bats`
3. Write tests covering all functionality
4. Run coverage report again

### Pre-Commit Hook Blocks Commit

This is working as intended!

1. Fix failing tests
2. Add missing tests
3. Verify coverage is 100%
4. Try commit again

---

## Best Practices

1. **One test file per script** - Easy to find tests
2. **Descriptive test names** - Explain what is being tested
3. **Arrange-Act-Assert** - Clear test structure
4. **Isolated tests** - Each test is independent
5. **Fast tests** - Keep tests quick (< 1 second each)
6. **Readable tests** - Tests are documentation

---

## Example: Full Test File

See `tests/unit/test_time_clock_updater.bats` for a complete example with:

- 15+ test cases
- Full coverage of all branches
- Edge cases and error handling
- Idempotency tests
- State verification

---

**Remember: No untested code in production!** 🧪

For questions, see workflow docs or ask in issues.
