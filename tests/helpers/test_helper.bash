#!/usr/bin/env bash
# Test helper functions for BATS tests

TESTS_ROOT="$(cd "$(dirname "$0")" && pwd -P)"
ROOT_DIR="$(cd "$(dirname "${TESTS_ROOT}")" && pwd -P)"
export TESTS_ROOT
export ROOT_DIR

# Setup a clean test environment
setup_test_waldiez() {
  TEST_DIR=$(mktemp -d)
  export TEST_WALDIEZ="$TEST_DIR/test_waldiez"
  mkdir -p "$TEST_WALDIEZ"
}

# Cleanup test environment
teardown_test_waldiez() {
  if [[ -n "${TEST_DIR:-}" ]] && [[ -d "$TEST_DIR" ]]; then
    rm -rf "$TEST_DIR"
  fi
}

# Create a minimal valid .tic file
create_test_tic() {
  local target_dir="${1:-$TEST_WALDIEZ}"
  echo "2026-02-07T10:00:00Z" > "$target_dir/.tic"
}

# Create a minimal valid MANIFEST
create_test_manifest() {
  local target_dir="${1:-$TEST_WALDIEZ}"
  cat > "$target_dir/MANIFEST" <<'EOF'
$schema: "https://xperiens.waldiez.io/schema/v1/manifest"

identity:
  wid: "wdz://test/waldiez/v1"
  type: "test"
  created: "2026-02-07T10:00:00Z"

description:
  name: "Test Waldiez"
  purpose: "For testing purposes"
  tags: ["test"]

interface:
  operations: []
  state_schema:
    last_heartbeat: {type: datetime, format: "ISO-8601", mutable: true}
    heartbeat_count: {type: integer, mutable: true}
    last_tick: {type: date, format: "YYYY-MM-DD", mutable: true}
    total_ticks: {type: integer, mutable: true}

execution:
  runtime: "wdz://runtimes/bash"

lifecycle:
  health_check:
    type: "test"
EOF
}

# Create a .toc with specific dates
create_test_toc() {
  local target_dir="${1:-$TEST_WALDIEZ}"
  shift
  local dates=("$@")
  
  for date in "${dates[@]}"; do
    echo "$date" >> "$target_dir/.toc"
  done
}

# Assert file exists
assert_file_exists() {
  local filepath="$1"
  [[ -f "$filepath" ]] || {
    echo "Expected file to exist: $filepath"
    return 1
  }
}

# Assert file does not exist
assert_file_not_exists() {
  local filepath="$1"
  [[ ! -f "$filepath" ]] || {
    echo "Expected file to NOT exist: $filepath"
    return 1
  }
}

# Assert last `run` succeeded (Bats sets $status and $output)
assert_success() {
  local actual="${1:-${status:-}}"

  if [[ -z "${actual}" ]]; then
    echo "assert_success: no status provided and \$status is not set."
    echo "Did you forget to use: run <command> ?"
    return 1
  fi

  if [[ "$actual" -ne 0 ]]; then
    echo "Expected success (exit 0), got $actual"
    if [[ -n "${output:-}" ]]; then
      echo "Output:"
      echo "$output"
    fi
    return 1
  fi
}

# Assert file contains text
assert_file_contains() {
  local filepath="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$filepath"; then
    echo "Expected file $filepath to contain:"
    echo "  $expected"
    echo
    echo "Actual contents:"
    cat "$filepath"
    return 1
  fi
}

# Assert line count
assert_line_count() {
  local filepath="$1"
  local expected_count="$2"
  local actual_count

  if [[ ! -f "$filepath" ]]; then
    echo "Expected file to exist: $filepath"
    return 1
  fi

  actual_count=$(wc -l < "$filepath" | tr -d ' ')

  if [[ "$actual_count" -ne "$expected_count" ]]; then
    echo "Expected $expected_count lines, got $actual_count in $filepath"
    echo "Actual contents:"
    cat "$filepath"
    return 1
  fi
}

# Assert YAML field exists and has value
assert_yaml_field() {
  local filepath="$1"
  local field="$2"
  local expected="${3:-}"
  
  if ! yq eval "$field" "$filepath" &>/dev/null; then
    echo "Expected YAML field to exist: $field"
    return 1
  fi
  
  if [[ -n "$expected" ]]; then
    local actual
    actual=$(yq eval "$field" "$filepath")
    if [[ "$actual" != "$expected" ]]; then
      echo "Expected $field to be '$expected', got '$actual'"
      return 1
    fi
  fi
}

# Mock git command
mock_git() {
  # Create a function that overrides git
  # shellcheck disable=SC2329
  git() {
    echo "MOCK_GIT: $*" >&2
    case "$1" in
      config)
        return 0
        ;;
      status)
        echo "M  test_file"
        return 0
        ;;
      add)
        return 0
        ;;
      commit)
        return 0
        ;;
      push)
        return 0
        ;;
      *)
        command git "$@"
        ;;
    esac
  }
  export -f git
}

# Generate mock date for testing
# Usage: generate_mock_date "2026-01-02T01:00:00Z"
generate_mock_date() {
  local timestamp="$1"
  export MOCK_CURRENT_TIMESTAMP="$timestamp"
  export MOCK_CURRENT_DATE="${timestamp:0:10}"
}

# Clear mock date (call in teardown)
clear_mock_date() {
  unset MOCK_CURRENT_TIMESTAMP
  unset MOCK_CURRENT_DATE
}

# Get current UTC date (for tests)
get_current_date() {
  date -u +%Y-%m-%d
}

# Get current UTC timestamp (for tests)
get_current_timestamp() {
  date -u +%Y-%m-%dT%H:%M:%SZ
}

# Skip test if dependency missing
skip_if_missing() {
  local cmd="$1"
  if ! command -v "$cmd" &> /dev/null; then
    skip "$cmd is not installed"
  fi
}

# Convert ISO timestamp to date (YYYY-MM-DD)
iso_to_date() {
  local iso="$1"
  echo "${iso:0:10}"
}

# Get date N days ago (YYYY-MM-DD)
date_days_ago() {
  local days="$1"

  if date --version &>/dev/null 2>&1; then
    # GNU date (Linux)
    date -u -d "${days} days ago" +%Y-%m-%d
  else
    # macOS/BSD: epoch math
    local now
    now=$(date -u +%s)
    date -u -r "$((now - days * 86400))" +%Y-%m-%d
  fi
}

# Get next day (YYYY-MM-DD)
next_day() {
  local current="$1"
  current="${current:0:10}"  # normalize to YYYY-MM-DD
  current="$(echo "$current" | tr -d '\r')"

  if date --version &>/dev/null 2>&1; then
    # GNU date (Linux)
    date -u -d "${current} + 1 day" +%Y-%m-%d
  else
    # macOS/BSD: epoch math
    local epoch
    epoch=$(date -u -j -f "%Y-%m-%d" "$current" +%s)
    date -u -r "$((epoch + 86400))" +%Y-%m-%d
  fi
}

# Date/time string to epoch seconds.
# Accepts:
# - YYYY-MM-DD
# - YYYY-MM-DDTHH:MM:SSZ
date_to_epoch() {
  local date_str="$1"
  date_str="$(echo "$date_str" | tr -d '\r')"

  if date --version &>/dev/null 2>&1; then
    # GNU date: force UTC interpretation/output
    date -u -d "$date_str" +%s
  else
    # macOS/BSD: handle both formats explicitly
    if [[ "$date_str" == ????-??-?? ]]; then
      date -u -j -f "%Y-%m-%d" "$date_str" +%s
    else
      date -u -j -f "%Y-%m-%dT%H:%M:%SZ" "$date_str" +%s
    fi
  fi
}

# Current UTC date (YYYY-MM-DD)
# Supports mocking via MOCK_CURRENT_DATE environment variable
current_utc_date() {
  # Support mocking for tests
  if [[ -n "${MOCK_CURRENT_DATE:-}" ]]; then
    echo "$MOCK_CURRENT_DATE"
    return
  fi
  date -u +%Y-%m-%d
}

# Current UTC timestamp (YYYY-MM-DDTHH:MM:SSZ)
# Supports mocking via MOCK_CURRENT_TIMESTAMP environment variable
current_utc_timestamp() {
  # Support mocking for tests
  if [[ -n "${MOCK_CURRENT_TIMESTAMP:-}" ]]; then
    echo "$MOCK_CURRENT_TIMESTAMP"
    return
  fi
  date -u +%Y-%m-%dT%H:%M:%SZ
}
