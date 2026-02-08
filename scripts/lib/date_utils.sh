#!/usr/bin/env bash
# Portable date functions (GNU, BSD/macOS, BusyBox)

# Detect if date is BusyBox
is_busybox_date() {
  date --help 2>&1 | grep -qi busybox
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
  elif is_busybox_date; then
    # BusyBox date (Alpine)
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
  elif is_busybox_date; then
    # BusyBox date (Alpine)
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
  elif is_busybox_date; then
    # BusyBox date (Alpine)
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
# Supports mocking for tests via MOCK_CURRENT_DATE environment variable
current_utc_date() {
  # Support mocking for tests
  if [[ -n "${MOCK_CURRENT_DATE:-}" ]]; then
    echo "$MOCK_CURRENT_DATE"
    return
  fi
  date -u +%Y-%m-%d
}

# Current UTC timestamp (YYYY-MM-DDTHH:MM:SSZ)
# Supports mocking for tests via MOCK_CURRENT_TIMESTAMP environment variable
current_utc_timestamp() {
  # Support mocking for tests
  if [[ -n "${MOCK_CURRENT_TIMESTAMP:-}" ]]; then
    echo "$MOCK_CURRENT_TIMESTAMP"
    return
  fi
  date -u +%Y-%m-%dT%H:%M:%SZ
}

# Export for sub-shells
export -f iso_to_date
export -f date_days_ago
export -f next_day
export -f date_to_epoch
export -f current_utc_date
export -f current_utc_timestamp
