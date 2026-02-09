#!/usr/bin/env bats
# Tests for install_test_deps.sh

load '../helpers/test_helper'

setup() {
  setup_test_waldiez
}

teardown() {
  teardown_test_waldiez
}

@test "install_test_deps: script exists and is executable" {
  [ -f "tests/install_test_deps.sh" ]
  [ -x "tests/install_test_deps.sh" ]
}

@test "install_test_deps: sources os_utils correctly" {
  # Verify it sources os_utils
  run bash -c "grep -q 'source.*os_utils.sh' tests/install_test_deps.sh"
  [ "$status" -eq 0 ]
}

@test "install_test_deps: checks for bats" {
  grep -q "bats" tests/install_test_deps.sh
}

@test "install_test_deps: checks for yq" {
  grep -q "yq" tests/install_test_deps.sh
}

@test "install_test_deps: detects already installed tools" {
  # Mock bats as already installed
  bats() {
    echo "Bats 1.10.0"
  }
  export -f bats

  # Run with bats mocked
  run bash tests/install_test_deps.sh

  # Should detect it's already installed (may still exit 1 if yq missing)
  echo "$output" | grep -q "already installed"
}

@test "install_test_deps: uses os_utils functions" {
  # Verify script uses the key os_utils functions
  grep -q "detect_os" tests/install_test_deps.sh
  grep -q "detect_package_manager" tests/install_test_deps.sh
  grep -q "command_exists" tests/install_test_deps.sh
}

@test "install_test_deps: reports installation summary" {
  skip "Requires mocking all install functions"

  run bash tests/install_test_deps.sh

  echo "$output" | grep -q "Installation Summary"
  echo "$output" | grep -q "Successfully installed:"
  echo "$output" | grep -q "Failed/Skipped:"
}
