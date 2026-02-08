#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "=========================================="
echo "  Waldiez Test Coverage Report"
echo "=========================================="
echo ""

# Run full test suite first
echo "Running full test suite..."
if ! ./tests/run_all_tests.sh >/dev/null 2>&1; then
  echo "✗ Tests failed. Run ./tests/run_all_tests.sh to see details."
  exit 1
fi

echo "✓ All tests passed"
echo ""

# Discover scripts
SCRIPT_FILES=$(find scripts -name "*.sh" -type f | sort)

if [[ -z "$SCRIPT_FILES" ]]; then
  echo "No scripts found under scripts/"
  exit 0
fi

TOTAL_SCRIPTS=0
TESTED=0
TOTAL_TEST_COUNT=0

printf "%-48s %s\n" "Script" "Tests  Status"
echo "-----------------------------------------------------------------------------"

for script in $SCRIPT_FILES; do
  TOTAL_SCRIPTS=$((TOTAL_SCRIPTS + 1))
  base=$(basename "$script" .sh)
  test_file="tests/unit/test_${base}.bats"

  if [[ -f "$test_file" ]]; then
    TESTED=$((TESTED + 1))
    TEST_COUNT=$(rg -c '^@test' "$test_file" 2>/dev/null || grep -c '^@test' "$test_file" || echo 0)
    TOTAL_TEST_COUNT=$((TOTAL_TEST_COUNT + TEST_COUNT))
    printf "%-48s ✓  %2d tests  PASS\n" "$script" "$TEST_COUNT"
  else
    printf "%-48s ❌ NO TESTS\n" "$script"
  fi
done

echo "-----------------------------------------------------------------------------"
echo ""
echo "Summary:"
echo "  Total scripts:    $TOTAL_SCRIPTS"
echo "  With tests:       $TESTED"
echo ""
echo "  Total tests:      $TOTAL_TEST_COUNT"
echo ""

COVERAGE_PCT=$(( TESTED * 100 / TOTAL_SCRIPTS ))
echo "  Test coverage:    $COVERAGE_PCT%"

if [[ $COVERAGE_PCT -eq 100 ]]; then
  echo ""
  echo "✓ 100% coverage achieved! All tests passing."
  exit 0
else
  echo ""
  echo "✗ Coverage below 100%. Add tests for missing scripts."
  exit 1
fi
