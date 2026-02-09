#!/usr/bin/env bats
# Tests for validate_ci.sh

load '../helpers/test_helper'

setup() {
  # Create temporary test directory
  TEST_DIR="$(mktemp -d)"
  cd "$TEST_DIR"  || return

  # Initialize git repo
  git init > /dev/null 2>&1
  git config user.name "Test User"
  git config user.email "test@example.com"

  # Create minimal structure
  mkdir -p .github/workflows .gitlab/ci scripts/validation scripts/lib tests

  # Create mock yq (always succeeds)
  cat > yq << 'EOF'
#!/usr/bin/env bash
exit 0
EOF
  chmod +x yq
  export PATH="$TEST_DIR:$PATH"

  # Create colors.sh
  cat > scripts/lib/colors.sh << 'EOF'
#!/usr/bin/env bash
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export NC='\033[0m'
EOF

  # Create mock validation scripts
  cat > scripts/validation/check_tic_immutable.sh << 'EOF'
#!/usr/bin/env bash
exit 0
EOF
  chmod +x scripts/validation/check_tic_immutable.sh

  cat > scripts/validation/check_manifest_sections.sh << 'EOF'
#!/usr/bin/env bash
exit 0
EOF
  chmod +x scripts/validation/check_manifest_sections.sh

  # Create mock test script
  cat > tests/run_all_tests.sh << 'EOF'
#!/usr/bin/env bash
exit 0
EOF
  chmod +x tests/run_all_tests.sh

  # Create mock lint script
  cat > scripts/lint.sh << 'EOF'
#!/usr/bin/env bash
exit 0
EOF
  chmod +x scripts/lint.sh

  # Create sample YAML files
  echo "name: test" > .github/workflows/test.yml
  echo "stages: [test]" > .gitlab-ci.yml
  echo "stages: [validate]" > .gitlab/ci/base.yml
}

teardown() {
  # Clean up
  cd /
  rm -rf "$TEST_DIR"
}

@test "validate_ci: script exists and is executable" {
  [ -x "$BATS_TEST_DIRNAME/../../scripts/validate_ci.sh" ]
}

@test "validate_ci: validates YAML syntax" {
  # Copy script to test dir
  cp "$BATS_TEST_DIRNAME/../../scripts/validate_ci.sh" scripts/

  run bash scripts/validate_ci.sh
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Validating YAML syntax" ]]
}

@test "validate_ci: fails on invalid YAML" {
  # Copy script to test dir
  cp "$BATS_TEST_DIRNAME/../../scripts/validate_ci.sh" scripts/

  # Create invalid YAML
  echo "invalid: yaml: syntax:" > .gitlab-ci.yml

  # Mock yq to fail
  cat > yq << 'EOF'
#!/usr/bin/env bash
exit 1
EOF
  chmod +x yq

  run bash scripts/validate_ci.sh
  [ "$status" -ne 0 ]
}

@test "validate_ci: runs validation scripts" {
  cp "$BATS_TEST_DIRNAME/../../scripts/validate_ci.sh" scripts/

  run bash scripts/validate_ci.sh
  [ "$status" -eq 0 ]
  # shellcheck disable=SC2076
  [[ "$output" =~ "check_tic_immutable.sh" ]]
  # shellcheck disable=SC2076
  [[ "$output" =~ "check_manifest_sections.sh" ]]
}

@test "validate_ci: fails when validation script fails" {
  cp "$BATS_TEST_DIRNAME/../../scripts/validate_ci.sh" scripts/

  # Make validation script fail
  cat > scripts/validation/check_tic_immutable.sh << 'EOF'
#!/usr/bin/env bash
exit 1
EOF

  run bash scripts/validate_ci.sh
  [ "$status" -ne 0 ]
}

@test "validate_ci: runs test suite" {
  cp "$BATS_TEST_DIRNAME/../../scripts/validate_ci.sh" scripts/

  run bash scripts/validate_ci.sh
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Running test suite" ]]
}

@test "validate_ci: fails when tests fail" {
  cp "$BATS_TEST_DIRNAME/../../scripts/validate_ci.sh" scripts/

  # Make tests fail
  cat > tests/run_all_tests.sh << 'EOF'
#!/usr/bin/env bash
exit 1
EOF

  run bash scripts/validate_ci.sh
  [ "$status" -ne 0 ]
}

@test "validate_ci: runs linting" {
  cp "$BATS_TEST_DIRNAME/../../scripts/validate_ci.sh" scripts/

  run bash scripts/validate_ci.sh
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Running linting" ]]
}

@test "validate_ci: fails when linting fails" {
  cp "$BATS_TEST_DIRNAME/../../scripts/validate_ci.sh" scripts/

  # Make linting fail
  cat > scripts/lint.sh << 'EOF'
#!/usr/bin/env bash
exit 1
EOF

  run bash scripts/validate_ci.sh
  [ "$status" -ne 0 ]
}

@test "validate_ci: detects existing CI files" {
  cp "$BATS_TEST_DIRNAME/../../scripts/validate_ci.sh" scripts/

  # Add CI files to git
  git add .gitlab-ci.yml
  git commit -m "Add CI" > /dev/null 2>&1

  run bash scripts/validate_ci.sh
  [ "$status" -eq 0 ]
  [[ "$output" =~ "CI files already in git" ]]
}

@test "validate_ci: detects new CI files" {
  cp "$BATS_TEST_DIRNAME/../../scripts/validate_ci.sh" scripts/

  # Don't add CI files to git
  run bash scripts/validate_ci.sh
  [ "$status" -eq 0 ]
  [[ "$output" =~ "CI files are new" ]]
}

@test "validate_ci: shows success message when all pass" {
  cp "$BATS_TEST_DIRNAME/../../scripts/validate_ci.sh" scripts/

  run bash scripts/validate_ci.sh
  [ "$status" -eq 0 ]
  [[ "$output" =~ "All validations passed" ]]
}

@test "validate_ci: uses colors from colors.sh" {
  cp "$BATS_TEST_DIRNAME/../../scripts/validate_ci.sh" scripts/

  run bash scripts/validate_ci.sh
  [ "$status" -eq 0 ]
  # Script should source colors.sh (hard to test output colors in bats)
  # Just verify it doesn't fail
}
