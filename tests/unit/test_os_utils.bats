#!/usr/bin/env bats
# Tests for os_utils.sh

load '../helpers/test_helper'

setup() {
  # Source os_utils for testing
  # shellcheck disable=SC1091
  source scripts/lib/os_utils.sh
}

@test "os_utils: detect_os returns valid value" {
  run detect_os
  [ "$status" -eq 0 ]
  
  # Should return one of the valid values
  [[ "$output" == "macos" ]] || \
  [[ "$output" == "linux" ]] || \
  [[ "$output" == "alpine" ]] || \
  [[ "$output" == "unknown" ]]
}

@test "os_utils: detect_package_manager returns valid value" {
  run detect_package_manager
  [ "$status" -eq 0 ]
  
  # Should return one of the valid values
  [[ "$output" == "brew" ]] || \
  [[ "$output" == "apt" ]] || \
  [[ "$output" == "apk" ]] || \
  [[ "$output" == "dnf" ]] || \
  [[ "$output" == "yum" ]] || \
  [[ "$output" == "pacman" ]] || \
  [[ "$output" == "unknown" ]]
}

@test "os_utils: is_ci returns true or false" {
  run is_ci
  [ "$status" -eq 0 ]
  
  [[ "$output" == "true" ]] || [[ "$output" == "false" ]]
}

@test "os_utils: is_root returns true or false" {
  run is_root
  [ "$status" -eq 0 ]
  
  [[ "$output" == "true" ]] || [[ "$output" == "false" ]]
}

@test "os_utils: command_exists detects existing command" {
  run command_exists bash
  [ "$status" -eq 0 ]
}

@test "os_utils: command_exists fails for non-existent command" {
  run command_exists this_command_definitely_does_not_exist_12345
  [ "$status" -ne 0 ]
}

@test "os_utils: cpu_cores returns a number" {
  run cpu_cores
  [ "$status" -eq 0 ]
  
  # Output should be a number
  [[ "$output" =~ ^[0-9]+$ ]]
  
  # Should be at least 1
  [ "$output" -ge 1 ]
}

@test "os_utils: detect_linux_distro returns valid value on linux" {
  run detect_os
  local os="$output"
  
  if [[ "$os" == "linux" ]] || [[ "$os" == "alpine" ]]; then
    run detect_linux_distro
    [ "$status" -eq 0 ]
    
    # Should return a valid distro name
    [[ "$output" =~ ^[a-z]+$ ]]
  else
    skip "Not running on Linux"
  fi
}

@test "os_utils: functions are exported" {
  # Test that key functions are available in subshells
  run bash -c "source scripts/lib/os_utils.sh && detect_os"
  [ "$status" -eq 0 ]
  
  run bash -c "source scripts/lib/os_utils.sh && command_exists bash"
  [ "$status" -eq 0 ]
}

@test "os_utils: install_package requires package name" {
  # Should fail if no package name provided
  run install_package
  [ "$status" -ne 0 ]
}

@test "os_utils: pip_install requires package name" {
  run pip_install
  [ "$status" -ne 0 ]
}

@test "os_utils: npm_install requires package name" {
  run npm_install
  [ "$status" -ne 0 ]
}
