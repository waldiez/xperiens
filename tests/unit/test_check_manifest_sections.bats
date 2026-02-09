#!/usr/bin/env bats

# Tests for scripts/validation/check_manifest_sections.sh

load ../helpers/test_helper

setup() {
  TEST_DIR=$(mktemp -d)
  cd "$TEST_DIR" || exit 1
  git init -q
  git config user.name "Test User"
  git config user.email "test@example.com"
  git config advice.defaultBranchName false

  mkdir -p waldiez
  cat > waldiez/MANIFEST <<'EOF'
$schema: "https://xperiens.waldiez.io/schema/v1/manifest"

identity:
  wid: "wdz://test/v1"
  type: "test"
  created: "2026-02-07T10:00:00Z"

description:
  name: "Test"
  purpose: "Testing"

state:
  last_heartbeat: "2026-02-07T10:00:00Z"
  heartbeat_count: 1
EOF

  git add waldiez/MANIFEST
  git commit -q -m "initial: Add MANIFEST"
}

teardown() {
  cd /
  if [[ -n "${TEST_DIR:-}" ]] && [[ -d "$TEST_DIR" ]]; then
    rm -rf "$TEST_DIR"
  fi
}

@test "check_manifest_sections: passes when no MANIFEST modified" {
  echo "content" > README.md
  git add README.md
  git commit -q -m "Add README"

  run bash "$OLDPWD/scripts/validation/check_manifest_sections.sh"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "No MANIFEST files modified" ]]
}

@test "check_manifest_sections: passes when description modified" {
  sed -i.bak 's/purpose: "Testing"/purpose: "Updated purpose"/' waldiez/MANIFEST
  rm -f waldiez/MANIFEST.bak
  git add waldiez/MANIFEST
  git commit -q -m "Update description"

  run bash "$OLDPWD/scripts/validation/check_manifest_sections.sh"
  [ "$status" -eq 0 ]
}

@test "check_manifest_sections: fails when WID modified" {
  sed -i.bak 's/wid: "wdz:\/\/test\/v1"/wid: "wdz:\/\/test\/v2"/' waldiez/MANIFEST
  rm -f waldiez/MANIFEST.bak
  git add waldiez/MANIFEST
  git commit -q -m "Change WID"

  run bash "$OLDPWD/scripts/validation/check_manifest_sections.sh"
  [ "$status" -eq 1 ]
  [[ "$output" =~ "ERROR: Immutable identity fields modified" ]]
}

@test "check_manifest_sections: fails when created timestamp modified" {
  sed -i.bak 's/created: "2026-02-07T10:00:00Z"/created: "2026-02-08T10:00:00Z"/' waldiez/MANIFEST
  rm -f waldiez/MANIFEST.bak
  git add waldiez/MANIFEST
  git commit -q -m "Change created timestamp"

  run bash "$OLDPWD/scripts/validation/check_manifest_sections.sh"
  [ "$status" -eq 1 ]
  [[ "$output" =~ "ERROR: Immutable identity fields modified" ]]
}

@test "check_manifest_sections: warns when human modifies state" {
  # Simply change heartbeat count
  sed -i.bak 's/heartbeat_count: 1/heartbeat_count: 99/' waldiez/MANIFEST
  rm -f waldiez/MANIFEST.bak
  git add waldiez/MANIFEST
  git commit -q -m "Modify state"

  run bash "$OLDPWD/scripts/validation/check_manifest_sections.sh"
  [ "$status" -eq 0 ]
  # Warning or passes silently (current implementation warns)
}

@test "check_manifest_sections: passes when bot modifies state" {
  sed -i.bak 's/heartbeat_count: 1/heartbeat_count: 2/' waldiez/MANIFEST
  rm -f waldiez/MANIFEST.bak
  git add waldiez/MANIFEST
  git config user.name "waldiez-bot"
  git commit -q -m "Update state"

  run bash "$OLDPWD/scripts/validation/check_manifest_sections.sh"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "valid" ]]
}

@test "check_manifest_sections: output includes helpful messages" {
  sed -i.bak 's/wid: "wdz:\/\/test\/v1"/wid: "wdz:\/\/test\/v2"/' waldiez/MANIFEST
  rm -f waldiez/MANIFEST.bak
  git add waldiez/MANIFEST
  git commit -q -m "Change WID"

  run bash "$OLDPWD/scripts/validation/check_manifest_sections.sh"
  [[ "$output" =~ "immutable" ]]
  [[ "$output" =~ "version bump" ]]
}
