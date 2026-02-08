#!/usr/bin/env bats

load ../helpers/test_helper

setup() {
  PWD_BEFORE="$PWD"
  TEST_DIR=$(mktemp -d)
  export TEST_REPO="$TEST_DIR/repo"
  mkdir -p "$TEST_REPO/scripts" "$TEST_REPO/time/clock"

  cp "$PWD_BEFORE/scripts/clean_for_first_commit.sh" "$TEST_REPO/scripts/clean_for_first_commit.sh"
  chmod +x "$TEST_REPO/scripts/clean_for_first_commit.sh"

  create_test_tic "$TEST_REPO/time/clock"
  create_test_manifest "$TEST_REPO/time/clock"

  # Add .toc and state to verify cleanup
  echo "2026-02-07" > "$TEST_REPO/time/clock/.toc"
  yq eval -i '.state = {"last_heartbeat":"2026-02-07T10:00:00Z"}' "$TEST_REPO/time/clock/MANIFEST"

  cd "$TEST_REPO" || return 1
}

teardown() {
  cd "$PWD_BEFORE" || return 1
  if [[ -n "${TEST_DIR:-}" ]] && [[ -d "$TEST_DIR" ]]; then
    rm -rf "$TEST_DIR"
  fi
}

@test "clean_for_first_commit: removes .toc and state" {
  run bash scripts/clean_for_first_commit.sh
  [ "$status" -eq 0 ]

  [ ! -f time/clock/.toc ]
  # state should be removed
  [[ "$(yq eval '.state' time/clock/MANIFEST)" == "null" ]]
}
