#!/usr/bin/env bats

# Integration test: Full heartbeat cycle

load ../helpers/test_helper

setup() {
  setup_test_waldiez
}

teardown() {
  teardown_test_waldiez
  if [[ -n "${MOCK_BIN_DIR:-}" ]] && [[ -d "$MOCK_BIN_DIR" ]]; then
    rm -rf "$MOCK_BIN_DIR"
  fi
}

@test "integration: from initial commit to first heartbeat cycle" {
  create_test_tic "$TEST_WALDIEZ"
  create_test_manifest "$TEST_WALDIEZ"

  assert_file_exists "$TEST_WALDIEZ/.tic"
  assert_file_exists "$TEST_WALDIEZ/MANIFEST"
  assert_file_not_exists "$TEST_WALDIEZ/.toc"

  run bash "scripts/agents/time/clock/time_clock_updater.sh" "$TEST_WALDIEZ"
  [ "$status" -eq 0 ]

  assert_file_exists "$TEST_WALDIEZ/.toc"
  assert_yaml_field "$TEST_WALDIEZ/MANIFEST" ".state.heartbeat_count" "1"
  assert_yaml_field "$TEST_WALDIEZ/MANIFEST" ".state.total_ticks"

  cd "$TEST_WALDIEZ/.."
  mkdir -p "$(dirname "$TEST_WALDIEZ")"
  echo "# README" > README.md

  run bash "$OLDPWD/scripts/agents/time/clock/update_readme.sh"
  [ "$status" -eq 0 ]
}

@test "integration: multiple heartbeats over multiple days with direct date mocking" {
  local START_DATETIME="2026-01-01T12:00:00Z"
  local START_DATE="2026-01-01"

  rm -rf "$TEST_WALDIEZ"
  mkdir -p "$TEST_WALDIEZ"

  echo "$START_DATETIME" > "$TEST_WALDIEZ/.tic"
  cat > "$TEST_WALDIEZ/MANIFEST" <<EOF2
\$schema: "https://xperiens.waldiez.io/schema/v1/manifest"
identity:
  wid: "wdz://xperiens.waldiez.io/time/clock/v1"
  type: "process"
  created: "$START_DATETIME"
description:
  name: "UTC Day Clock"
  purpose: "Record the passage of UTC days via version control"
  tags: ["time", "reference", "heartbeat"]
interface:
  operations:
    - name: "heartbeat"
      description: "Prove existence by recording current timestamp"
      params: {}
      returns: {type: bool, description: "true if heartbeat recorded"}
    - name: "tick"
      description: "Record current UTC day if new"
      params: {}
      returns: {type: bool, description: "true if new day recorded"}
  state_schema:
    last_heartbeat: {type: datetime, format: "ISO-8601", mutable: true}
    heartbeat_count: {type: integer, mutable: true}
    last_tick: {type: date, format: "YYYY-MM-DD", mutable: true}
    total_ticks: {type: integer, mutable: true}
execution:
  runtime: "wdz://runtimes/bash"
  trigger: "wdz://triggers/heartbeat"
lifecycle:
  health_check:
    type: "heartbeat"
    interval_max: "PT23H59M"
    action: "wdz://health/heartbeat-monitor"
EOF2

  assert_file_exists "$TEST_WALDIEZ/.tic"
  assert_file_exists "$TEST_WALDIEZ/MANIFEST"
  assert_file_not_exists "$TEST_WALDIEZ/.toc"

  MOCK_BIN_DIR=$(mktemp -d)

  generate_mock_date() {
    local datetime_to_return="$1"
    local date_to_return="${datetime_to_return:0:10}"

    cat > "$MOCK_BIN_DIR/date" <<EOF3
#!/usr/bin/env bash

if [[ "\$1" == "--version" ]]; then
  echo "date (GNU coreutils) 9.0"
  exit 0
fi

if [[ "\$1" == "--help" ]]; then
  echo "date [OPTION]... [DATE]..."
  exit 0
fi

# Current date/time formats
if [[ "\$*" == *"-u +%Y-%m-%dT%H:%M:%SZ"* ]]; then
  echo "${datetime_to_return}"
  exit 0
fi

if [[ "\$*" == *"-u +%Y-%m-%d"* ]]; then
  echo "${date_to_return}"
  exit 0
fi

# GNU-style -d expressions used in date_utils
if [[ "\$1" == "-u" && "\$2" == "-d" ]]; then
  expr="\$3"
  if [[ "\$expr" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}\ \+\ 1\ day$ ]]; then
    python3 -c 'import datetime,sys; base=sys.argv[1].split(" ")[0]; dt=datetime.datetime.strptime(base, "%Y-%m-%d") + datetime.timedelta(days=1); print(dt.strftime("%Y-%m-%d"))' "\$expr"
    exit 0
  fi
  if [[ "\$expr" =~ ^[0-9]+\ days\ ago$ ]]; then
    python3 -c 'import datetime,sys; days=int(sys.argv[1].split(" ")[0]); base=sys.argv[2]; dt=datetime.datetime.strptime(base, "%Y-%m-%d") - datetime.timedelta(days=days); print(dt.strftime("%Y-%m-%d"))' "\$expr" "${date_to_return}"
    exit 0
  fi
  if [[ "\$expr" =~ ^@?[0-9]+$ ]]; then
    python3 -c 'import datetime,sys; expr=sys.argv[1]; expr=expr[1:] if expr.startswith("@") else expr; sec=int(expr); print(datetime.datetime.utcfromtimestamp(sec).strftime("%Y-%m-%dT%H:%M:%SZ"))' "\$expr"
    exit 0
  fi
fi

/bin/date "\$@"
EOF3
    chmod +x "$MOCK_BIN_DIR/date"
  }

  generate_mock_date "$START_DATETIME"

  local ORIGINAL_PATH="$PATH"
  export PATH="$MOCK_BIN_DIR:$PATH"

  # Day 1
  run bash "scripts/agents/time/clock/time_clock_updater.sh" "$TEST_WALDIEZ"
  [ "$status" -eq 0 ]
  assert_file_exists "$TEST_WALDIEZ/.toc"
  assert_line_count "$TEST_WALDIEZ/.toc" 1
  assert_file_contains "$TEST_WALDIEZ/.toc" "$START_DATE"
  assert_yaml_field "$TEST_WALDIEZ/MANIFEST" ".state.heartbeat_count" "1"
  assert_yaml_field "$TEST_WALDIEZ/MANIFEST" ".state.last_tick" "$START_DATE"
  assert_yaml_field "$TEST_WALDIEZ/MANIFEST" ".state.total_ticks" "1"

  # Day 1 again
  run bash "scripts/agents/time/clock/time_clock_updater.sh" "$TEST_WALDIEZ"
  [ "$status" -eq 0 ]
  assert_line_count "$TEST_WALDIEZ/.toc" 1
  assert_yaml_field "$TEST_WALDIEZ/MANIFEST" ".state.heartbeat_count" "2"

  # Day 2
  local DAY2_DATETIME="2026-01-02T01:00:00Z"
  local DAY2_DATE="2026-01-02"
  generate_mock_date "$DAY2_DATETIME"

  run bash "scripts/agents/time/clock/time_clock_updater.sh" "$TEST_WALDIEZ"
  [ "$status" -eq 0 ]
  assert_line_count "$TEST_WALDIEZ/.toc" 2
  assert_file_contains "$TEST_WALDIEZ/.toc" "$DAY2_DATE"
  assert_yaml_field "$TEST_WALDIEZ/MANIFEST" ".state.heartbeat_count" "3"
  assert_yaml_field "$TEST_WALDIEZ/MANIFEST" ".state.last_tick" "$DAY2_DATE"
  assert_yaml_field "$TEST_WALDIEZ/MANIFEST" ".state.total_ticks" "2"

  # Day 4 (backfill)
  local DAY4_DATETIME="2026-01-04T03:00:00Z"
  local DAY4_DATE="2026-01-04"
  local DAY3_DATE="2026-01-03"
  generate_mock_date "$DAY4_DATETIME"

  run bash "scripts/agents/time/clock/time_clock_updater.sh" "$TEST_WALDIEZ"
  [ "$status" -eq 0 ]
  assert_line_count "$TEST_WALDIEZ/.toc" 4
  assert_file_contains "$TEST_WALDIEZ/.toc" "$DAY3_DATE"
  assert_file_contains "$TEST_WALDIEZ/.toc" "$DAY4_DATE"
  assert_yaml_field "$TEST_WALDIEZ/MANIFEST" ".state.heartbeat_count" "4"
  assert_yaml_field "$TEST_WALDIEZ/MANIFEST" ".state.last_tick" "$DAY4_DATE"
  assert_yaml_field "$TEST_WALDIEZ/MANIFEST" ".state.total_ticks" "4"

  # Idempotent
  run bash "scripts/agents/time/clock/time_clock_updater.sh" "$TEST_WALDIEZ"
  [ "$status" -eq 0 ]
  assert_line_count "$TEST_WALDIEZ/.toc" 4
  assert_yaml_field "$TEST_WALDIEZ/MANIFEST" ".state.heartbeat_count" "5"
  assert_yaml_field "$TEST_WALDIEZ/MANIFEST" ".state.last_tick" "$DAY4_DATE"
  assert_yaml_field "$TEST_WALDIEZ/MANIFEST" ".state.total_ticks" "4"

  export PATH="$ORIGINAL_PATH"
}
