#!/usr/bin/env bats
# shellcheck disable=SC2076
# Tests for scripts/validation/check_tic_immutable.sh

load ../helpers/test_helper

setup() {
  TEST_DIR=$(mktemp -d)
  cd "$TEST_DIR" || exit 1
  git init -q
  git config user.name "Test User"
  git config user.email "test@example.com"
  git config advice.defaultBranchName false
  
  mkdir -p waldiez
  echo "2026-02-07T10:00:00Z" > waldiez/.tic
  git add waldiez/.tic
  git commit -q -m "initial: Add .tic"
}

teardown() {
  cd /
  if [[ -n "${TEST_DIR:-}" ]] && [[ -d "$TEST_DIR" ]]; then
    rm -rf "$TEST_DIR"
  fi
}

@test "check_tic_immutable: passes when no .tic files modified" {
  echo "content" > README.md
  git add README.md
  git commit -q -m "Add README"
  
  run bash "$OLDPWD/scripts/validation/check_tic_immutable.sh"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "No existing .tic files were modified." ]]
}

@test "check_tic_immutable: fails when .tic file modified" {
  echo "2026-02-08T10:00:00Z" > waldiez/.tic
  git add waldiez/.tic
  git commit -q -m "Modify .tic"
  
  run bash "$OLDPWD/scripts/validation/check_tic_immutable.sh"
  [ "$status" -eq 1 ]
  [[ "$output" =~ "ERROR:" ]]
  [[ "$output" =~ ".tic files are immutable" ]]
  [[ "$output" =~ "waldiez/.tic" ]]
}

@test "check_tic_immutable: passes when new .tic file added" {
  # Create a new waldiez component directory
  mkdir -p new_waldiez
  
  # Create a new .tic file for it
  echo "2026-02-08T12:00:00Z" > new_waldiez/.tic
  
  # Stage and commit the new .tic file
  git add new_waldiez/.tic
  git commit -q -m "feat: Add new waldiez component"

  # Run the validation script
  run bash "$OLDPWD/scripts/validation/check_tic_immutable.sh"
  
  # Assert that the validation passes
  [ "$status" -eq 0 ]
  [[ "$output" =~ "No existing .tic files were modified." ]]
}

@test "check_tic_immutable: fails on multiple .tic modifications" {
  mkdir -p waldiez2
  echo "2026-02-07T11:00:00Z" > waldiez2/.tic
  git add waldiez2/.tic
  git commit -q -m "Add waldiez2"
  
  # Modify both
  echo "2026-02-08T10:00:00Z" > waldiez/.tic
  echo "2026-02-08T11:00:00Z" > waldiez2/.tic
  git add waldiez/.tic waldiez2/.tic
  git commit -q -m "Modify both .tic files"
  
  run bash "$OLDPWD/scripts/validation/check_tic_immutable.sh"
  [ "$status" -eq 1 ]
  [[ "$output" =~ "waldiez/.tic" ]]
  [[ "$output" =~ "waldiez2/.tic" ]]
}

@test "check_tic_immutable: output includes helpful error message" {
  echo "2026-02-08T10:00:00Z" > waldiez/.tic
  git add waldiez/.tic
  git commit -q -m "Modify .tic"
  
  run bash "$OLDPWD/scripts/validation/check_tic_immutable.sh"
  [[ "$output" =~ "birth certificates" ]]
  [[ "$output" =~ "version bump" ]]
  [[ "$output" =~ "v1 → v2" ]]
}
