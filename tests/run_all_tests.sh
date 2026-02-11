#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.." || exit 1

echo "=========================================="
echo "  Waldiez Test Suite"
echo "=========================================="
echo ""

# Check dependencies
echo "Checking dependencies..."
if ! command -v bats &> /dev/null; then
  echo "✗ BATS not found. Run: ./tests/install_test_deps.sh"
  exit 1
fi

if ! command -v yq &> /dev/null; then
  echo "✗ yq not found. Run: ./tests/install_test_deps.sh"
  exit 1
fi

echo "✓ All dependencies found"
echo ""

# Run unit tests
echo "=========================================="
echo "  Running Unit Tests"
echo "=========================================="
bats tests/unit/*.bats

# Run integration tests
echo ""
echo "=========================================="
echo "  Running Integration Tests"
echo "=========================================="
bats tests/integration/*.bats

# Cleanup test artifacts
echo ""
echo "=========================================="
echo "  Cleaning Up Test Artifacts"
echo "=========================================="
bash tests/post_test_cleanup.sh

echo ""
echo "=========================================="
echo "  Test Summary"
echo "=========================================="
echo "✓ All tests passed!"
echo ""
echo "Next steps:"
echo "  - Check coverage: ./tests/coverage_report.sh"
echo "  - Install pre-commit hook: ln -s ../../tests/pre-commit .git/hooks/pre-commit"

git restore time/clock/ > /dev/null || true
