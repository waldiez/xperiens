#!/usr/bin/env bats

# Tests for scripts/agents/time/clock/update_readme.sh
load ../helpers/test_helper

setup() {
  TEST_DIR=$(mktemp -d)
  export TEST_REPO="$TEST_DIR"
  
  mkdir -p "$TEST_REPO/time/clock"
  create_test_tic "$TEST_REPO/time/clock"
  create_test_manifest "$TEST_REPO/time/clock"
  
  cat > "$TEST_REPO/README.md" <<'EOF2'
# Waldiez Xperiens

**Days since first commit:** 0  
**Last heartbeat:** Not yet initialized  
**Status:** 🔵 Awaiting first commit

[→ START HERE](START_HERE.md).

---

*This README is automatically maintained. See `time/clock/MANIFEST` for details.*
EOF2
  
  cd "$TEST_REPO" || return 1
}

teardown() {
  cd - || return 1
  if [[ -n "${TEST_DIR:-}" ]] && [[ -d "$TEST_DIR" ]]; then
    rm -rf "$TEST_DIR"
  fi
}

@test "update_readme: handles clock with no state" {
  run bash "$OLDPWD/scripts/agents/time/clock/update_readme.sh"
  assert_success

  assert_file_contains "README.md" "**Days since first commit:** 0"
  assert_file_contains "README.md" "Not yet initialized"
  assert_file_contains "README.md" "🔵 Awaiting first commit"
}

@test "update_readme: updates after first heartbeat" {
  echo "2026-02-07" > "time/clock/.toc"

  # Create a heartbeat within the last hour to ensure status is 🟢 Alive
  NOW_EPOCH=$(date +%s)
  LAST_EPOCH=$((NOW_EPOCH - 3600))
  if date --version >/dev/null 2>&1; then
    LAST_HEARTBEAT=$(date -u -d "@${LAST_EPOCH}" +%Y-%m-%dT%H:%M:%SZ)
  else
    LAST_HEARTBEAT=$(date -u -r "$LAST_EPOCH" +%Y-%m-%dT%H:%M:%SZ)
  fi

  yq eval -i ".state = {
    \"last_heartbeat\": \"$LAST_HEARTBEAT\",
    \"heartbeat_count\": 1,
    \"last_tick\": \"2026-02-07\",
    \"total_ticks\": 1,
    \"last_updated\": \"$LAST_HEARTBEAT\"
  }" "time/clock/MANIFEST"
  
  run bash "$OLDPWD/scripts/agents/time/clock/update_readme.sh"
  [ "$status" -eq 0 ]
  
  assert_file_contains "README.md" "**Days since first commit:** 1"
  assert_file_contains "README.md" "$LAST_HEARTBEAT"
  assert_file_contains "README.md" "🟢 Alive"
}

@test "update_readme: shows correct day count from .toc" {
  cat > "time/clock/.toc" <<EOF2
2026-02-05
2026-02-06
2026-02-07
EOF2
  
  yq eval -i '.state = {
    "last_heartbeat": "2026-02-07T10:30:15Z",
    "heartbeat_count": 1,
    "last_tick": "2026-02-07",
    "total_ticks": 3
  }' "time/clock/MANIFEST"
  
  bash "$OLDPWD/scripts/agents/time/clock/update_readme.sh"
  
  assert_file_contains "README.md" "**Days since first commit:** 3"
}

@test "update_readme: shows 🟢 Alive when heartbeat < 24 hours ago" {
  skip "Requires timestamp calculation with date_utils"
}

@test "update_readme: preserves README structure" {
  echo "2026-02-07" > "time/clock/.toc"
  yq eval -i '.state = {
    "last_heartbeat": "2026-02-07T10:30:15Z",
    "heartbeat_count": 1,
    "last_tick": "2026-02-07",
    "total_ticks": 1
  }' "time/clock/MANIFEST"
  
  bash "$OLDPWD/scripts/agents/time/clock/update_readme.sh"
  
  assert_file_contains "README.md" "# Waldiez Xperiens"
  assert_file_contains "README.md" "Days since first commit:"
  assert_file_contains "README.md" "Last heartbeat:"
  assert_file_contains "README.md" "Status:"
  assert_file_contains "README.md" "START HERE"
  assert_file_contains "README.md" "automatically maintained"
}

@test "update_readme: output includes summary" {
  echo "2026-02-07" > "time/clock/.toc"
  yq eval -i '.state = {
    "last_heartbeat": "2026-02-07T10:30:15Z",
    "heartbeat_count": 1,
    "last_tick": "2026-02-07",
    "total_ticks": 1
  }' "time/clock/MANIFEST"
  
  run bash "$OLDPWD/scripts/agents/time/clock/update_readme.sh"
  
  [[ "$output" =~ "README updater" ]]
  # shellcheck disable=SC2076
  [[ "$output" =~ "README.md updated" ]]
}
