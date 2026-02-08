#!/usr/bin/env bats

# Tests for scripts/lib/date_utils.sh

@test "date_utils: iso_to_date extracts YYYY-MM-DD" {
  # shellcheck disable=SC1091
  source scripts/lib/date_utils.sh
  result=$(iso_to_date "2026-02-07T10:00:00Z")
  [ "$result" = "2026-02-07" ]
}

@test "date_utils: current_utc_date format" {
  # shellcheck disable=SC1091
  source scripts/lib/date_utils.sh
  result=$(current_utc_date)
  [[ "$result" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]
}

@test "date_utils: current_utc_timestamp format" {
  # shellcheck disable=SC1091
  source scripts/lib/date_utils.sh
  result=$(current_utc_timestamp)
  [[ "$result" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$ ]]
}

@test "date_utils: date_to_epoch for a known instant" {
  # shellcheck disable=SC1091
  source scripts/lib/date_utils.sh
  result=$(date_to_epoch "1970-01-02T00:00:00Z")
  [ "$result" -eq 86400 ]
}
