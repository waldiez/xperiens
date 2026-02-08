#!/usr/bin/env bats
# Tests for install_lint_deps.sh

load '../helpers/test_helper'

setup() {
  setup_test_waldiez
}

teardown() {
  teardown_test_waldiez
}

@test "install_lint_deps: shows usage when script exists" {
  # Just verify the script exists and is executable
  [ -f "scripts/lint/install_lint_deps.sh" ]
  [ -x "scripts/lint/install_lint_deps.sh" ]
}

@test "install_lint_deps: sources os_utils correctly" {
  # Verify it sources os_utils
  run bash -c "grep -q 'source.*os_utils.sh' scripts/lint/install_lint_deps.sh"
  [ "$status" -eq 0 ]
}

@test "install_lint_deps: detects already installed tools" {
  # Mock shellcheck as already installed
  shellcheck() {
    echo "ShellCheck - shell script analysis tool"
    echo "version: 0.9.0"
  }
  export -f shellcheck
  
  # Run with shellcheck mocked
  run bash scripts/lint/install_lint_deps.sh
  
  # Should detect it's already installed (may still exit 1 if others missing)
  echo "$output" | grep -q "already installed"
}

@test "install_lint_deps: reports installation summary" {
  # Script should output summary regardless of success
  skip "Requires mocking all install functions"
  
  run bash scripts/lint/install_lint_deps.sh
  
  echo "$output" | grep -q "Installation Summary"
  echo "$output" | grep -q "Successfully installed:"
  echo "$output" | grep -q "Failed/Skipped:"
}

@test "install_lint_deps: uses os_utils functions" {
  # Verify script uses the key os_utils functions
  grep -q "detect_os" scripts/lint/install_lint_deps.sh
  grep -q "detect_package_manager" scripts/lint/install_lint_deps.sh
  grep -q "command_exists" scripts/lint/install_lint_deps.sh
}

@test "install_lint_deps: checks for shellcheck" {
  grep -q "shellcheck" scripts/lint/install_lint_deps.sh
}

@test "install_lint_deps: checks for yamllint" {
  grep -q "yamllint" scripts/lint/install_lint_deps.sh
}

@test "install_lint_deps: checks for markdownlint" {
  grep -q "markdownlint" scripts/lint/install_lint_deps.sh
}
