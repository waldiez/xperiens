#!/usr/bin/env bats
# shellcheck disable=SC2076,SC2034

# Tests for scripts/agents/time/clock/time_clock_updater.sh

load ../helpers/test_helper

setup() {
  setup_test_waldiez
  create_test_tic
  create_test_manifest
}

teardown() {
  teardown_test_waldiez
}

@test "time_clock_updater: fails without directory argument" {
  run bash scripts/agents/time/clock/time_clock_updater.sh
  [ "$status" -ne 0 ]
}

@test "time_clock_updater: fails if .tic missing" {
  rm "$TEST_WALDIEZ/.tic"
  
  run bash scripts/agents/time/clock/time_clock_updater.sh "$TEST_WALDIEZ"
  [ "$status" -ne 0 ]
  [[ "$output" =~ "Error: .tic not found" ]]
}

@test "time_clock_updater: fails if MANIFEST missing" {
  rm "$TEST_WALDIEZ/MANIFEST"
  
  run bash scripts/agents/time/clock/time_clock_updater.sh "$TEST_WALDIEZ"
  [ "$status" -ne 0 ]
  [[ "$output" =~ "Error: MANIFEST not found" ]]
}

@test "time_clock_updater: creates .toc if missing" {
  assert_file_not_exists "$TEST_WALDIEZ/.toc"
  
  run bash scripts/agents/time/clock/time_clock_updater.sh "$TEST_WALDIEZ"
  [ "$status" -eq 0 ]
  
  assert_file_exists "$TEST_WALDIEZ/.toc"
  [[ "$output" =~ "Initializing .toc" ]]
}

@test "time_clock_updater: .toc contains birth date on first run" {
  run bash scripts/agents/time/clock/time_clock_updater.sh "$TEST_WALDIEZ"
  [ "$status" -eq 0 ]
  
  assert_file_contains "$TEST_WALDIEZ/.toc" "2026-02-07"
}

@test "time_clock_updater: creates state section in MANIFEST" {
  run yq eval '.state' "$TEST_WALDIEZ/MANIFEST"
  [ "$output" = "null" ]
  
  bash scripts/agents/time/clock/time_clock_updater.sh "$TEST_WALDIEZ"
  
  assert_yaml_field "$TEST_WALDIEZ/MANIFEST" ".state.last_heartbeat"
  assert_yaml_field "$TEST_WALDIEZ/MANIFEST" ".state.heartbeat_count"
  assert_yaml_field "$TEST_WALDIEZ/MANIFEST" ".state.last_tick"
  assert_yaml_field "$TEST_WALDIEZ/MANIFEST" ".state.total_ticks"
}

@test "time_clock_updater: heartbeat_count increments on each run" {
  bash scripts/agents/time/clock/time_clock_updater.sh "$TEST_WALDIEZ"
  COUNT1=$(yq eval '.state.heartbeat_count' "$TEST_WALDIEZ/MANIFEST")
  
  bash scripts/agents/time/clock/time_clock_updater.sh "$TEST_WALDIEZ"
  COUNT2=$(yq eval '.state.heartbeat_count' "$TEST_WALDIEZ/MANIFEST")
  
  [ "$COUNT1" -eq 1 ]
  [ "$COUNT2" -eq 2 ]
}

@test "time_clock_updater: idempotent within same day" {
  bash scripts/agents/time/clock/time_clock_updater.sh "$TEST_WALDIEZ"
  bash scripts/agents/time/clock/time_clock_updater.sh "$TEST_WALDIEZ"
  bash scripts/agents/time/clock/time_clock_updater.sh "$TEST_WALDIEZ"
  
  CURRENT_DATE=$(current_utc_date)
  TICK_COUNT=$(grep -c "$CURRENT_DATE" "$TEST_WALDIEZ/.toc" || echo 0)
  
  [ "$TICK_COUNT" -eq 1 ]
}

@test "time_clock_updater: appends new day to existing .toc" {
  YESTERDAY=$(date_days_ago 1)
  create_test_toc "$TEST_WALDIEZ" "$YESTERDAY"
  
  bash scripts/agents/time/clock/time_clock_updater.sh "$TEST_WALDIEZ"
  
  assert_line_count "$TEST_WALDIEZ/.toc" 2
}

@test "time_clock_updater: backfills multiple missed days" {
  PAST_DATE=$(date_days_ago 3)
  create_test_toc "$TEST_WALDIEZ" "$PAST_DATE"
  
  bash scripts/agents/time/clock/time_clock_updater.sh "$TEST_WALDIEZ"
  
  assert_line_count "$TEST_WALDIEZ/.toc" 4
}

@test "time_clock_updater: total_ticks matches .toc line count" {
  DATE1=$(date_days_ago 2)
  DATE2=$(date_days_ago 1)
  create_test_toc "$TEST_WALDIEZ" "$DATE1" "$DATE2"
  
  bash scripts/agents/time/clock/time_clock_updater.sh "$TEST_WALDIEZ"
  
  TOC_LINES=$(wc -l < "$TEST_WALDIEZ/.toc" | tr -d ' ')
  MANIFEST_TICKS=$(yq eval '.state.total_ticks' "$TEST_WALDIEZ/MANIFEST")
  
  [ "$TOC_LINES" = "$MANIFEST_TICKS" ]
}

@test "time_clock_updater: self-heals when state.total_ticks is incorrect" {
  DATE1=$(date_days_ago 2)
  DATE2=$(date_days_ago 1)
  CURRENT=$(current_utc_date)
  create_test_toc "$TEST_WALDIEZ" "$DATE1" "$DATE2" "$CURRENT"
  
  # shellcheck disable=SC2086
  yq eval -i '.state = {
    "last_heartbeat": "2026-02-07T10:00:00Z",
    "heartbeat_count": 1,
    "last_tick": "'$CURRENT'",
    "total_ticks": 99,
    "last_updated": "2026-02-07T10:00:00Z"
  }' "$TEST_WALDIEZ/MANIFEST"
  
  run bash scripts/agents/time/clock/time_clock_updater.sh "$TEST_WALDIEZ"
  if echo "$output" | grep -Fq "State drift"; then
    echo "Did not expect state drift warning"
    echo "$output"
    return 1
  fi

  MANIFEST_TICKS=$(yq eval '.state.total_ticks' "$TEST_WALDIEZ/MANIFEST")
  [ "$MANIFEST_TICKS" -eq 3 ]
}

@test "time_clock_updater: updates last_updated timestamp" {
  bash scripts/agents/time/clock/time_clock_updater.sh "$TEST_WALDIEZ"
  
  TIMESTAMP=$(yq eval '.state.last_updated' "$TEST_WALDIEZ/MANIFEST")
  
  [[ "$TIMESTAMP" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$ ]]
}

@test "time_clock_updater: preserves MANIFEST identity section" {
  WID_BEFORE=$(yq eval '.identity.wid' "$TEST_WALDIEZ/MANIFEST")
  TYPE_BEFORE=$(yq eval '.identity.type' "$TEST_WALDIEZ/MANIFEST")
  
  bash scripts/agents/time/clock/time_clock_updater.sh "$TEST_WALDIEZ"
  
  WID_AFTER=$(yq eval '.identity.wid' "$TEST_WALDIEZ/MANIFEST")
  TYPE_AFTER=$(yq eval '.identity.type' "$TEST_WALDIEZ/MANIFEST")
  
  [ "$WID_BEFORE" = "$WID_AFTER" ]
  [ "$TYPE_BEFORE" = "$TYPE_AFTER" ]
}

@test "time_clock_updater: output includes execution summary" {
  run bash scripts/agents/time/clock/time_clock_updater.sh "$TEST_WALDIEZ"
  
  [[ "$output" =~ "time/clock updater" ]]
  [[ "$output" =~ "Update complete" ]]
}
