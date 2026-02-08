#!/usr/bin/env bats

@test "lint: shows help" {
  run bash scripts/lint.sh --help
  [ "$status" -eq 0 ]
  # shellcheck disable=SC2076
  [[ "$output" =~ "Usage: ./scripts/lint.sh" ]]
}

@test "lint: unknown option fails" {
  run bash scripts/lint.sh --nope
  [ "$status" -ne 0 ]
  [[ "$output" =~ "Unknown option" ]]
}
