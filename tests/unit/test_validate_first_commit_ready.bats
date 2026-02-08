#!/usr/bin/env bats

load ../helpers/test_helper

setup() {
  PWD_BEFORE="$PWD"
  TEST_DIR=$(mktemp -d)
  export TEST_REPO="$TEST_DIR/repo"

  mkdir -p "$TEST_REPO/scripts/agents" "$TEST_REPO/scripts/validation" "$TEST_REPO/scripts/lib"
  mkdir -p "$TEST_REPO/tests" "$TEST_REPO/time/clock"

  cp "$PWD_BEFORE/scripts/validate_first_commit_ready.sh" "$TEST_REPO/scripts/validate_first_commit_ready.sh"
  chmod +x "$TEST_REPO/scripts/validate_first_commit_ready.sh"

  # Minimal executable scripts for permission check
  for f in "$TEST_REPO/scripts/agents/a.sh" "$TEST_REPO/scripts/validation/v.sh" "$TEST_REPO/scripts/lib/l.sh"; do
    echo "#!/usr/bin/env bash" > "$f"
    chmod +x "$f"
  done

  # Stub test runner
  cat > "$TEST_REPO/tests/run_all_tests.sh" <<'EOF2'
#!/usr/bin/env bash
exit 0
EOF2
  chmod +x "$TEST_REPO/tests/run_all_tests.sh"

  create_test_tic "$TEST_REPO/time/clock"
  create_test_manifest "$TEST_REPO/time/clock"

  cd "$TEST_REPO" || return 1
}

teardown() {
  cd "$PWD_BEFORE" || return 1
  if [[ -n "${TEST_DIR:-}" ]] && [[ -d "$TEST_DIR" ]]; then
    rm -rf "$TEST_DIR"
  fi
}

@test "validate_first_commit_ready: passes for clean state" {
  run bash scripts/validate_first_commit_ready.sh
  [ "$status" -eq 0 ]
  [[ "$output" =~ "READY FOR COMMIT" ]]
}

@test "validate_first_commit_ready: fails if .toc exists" {
  echo "2026-02-07" > time/clock/.toc

  run bash scripts/validate_first_commit_ready.sh
  [ "$status" -ne 0 ]
  # shellcheck disable=SC2076
  [[ "$output" =~ "time/clock/.toc exists" ]]
}
