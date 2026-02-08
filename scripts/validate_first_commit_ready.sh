#!/usr/bin/env bash
set -euo pipefail

# Pre-first-commit validator
# Ensures time/clock is in pristine state before first commit

cd "$(dirname "$0")/.."

echo "=========================================="
echo "  Pre-first-commit Validation"
echo "=========================================="
echo ""

ERRORS=0

# Check 1: .tic exists
if [[ ! -f time/clock/.tic ]]; then
  echo "✗ time/clock/.tic missing"
  ERRORS=$((ERRORS + 1))
else
  echo "✓ time/clock/.tic exists"
fi

# Check 2: MANIFEST exists
if [[ ! -f time/clock/MANIFEST ]]; then
  echo "✗ time/clock/MANIFEST missing"
  ERRORS=$((ERRORS + 1))
else
  echo "✓ time/clock/MANIFEST exists"
fi

# Check 3: .toc should NOT exist
if [[ -f time/clock/.toc ]]; then
  echo "✗ time/clock/.toc exists (should not exist before first commit)"
  echo "   Run: rm time/clock/.toc"
  ERRORS=$((ERRORS + 1))
else
  echo "✓ time/clock/.toc does not exist (will be created by CI)"
fi

# Check 4: MANIFEST should NOT have state section
if yq eval '.state' time/clock/MANIFEST &>/dev/null && [[ "$(yq eval '.state' time/clock/MANIFEST)" != "null" ]]; then
  echo "✗ MANIFEST has state section (should be commented out)"
  echo "   Run: ./tests/post_test_cleanup.sh"
  ERRORS=$((ERRORS + 1))
else
  echo "✓ MANIFEST has no state section (will be added by CI)"
fi

# Check 5: .tic timestamp matches MANIFEST identity.created
TIC_TIMESTAMP=$(cat time/clock/.tic)
MANIFEST_CREATED=$(yq eval '.identity.created' time/clock/MANIFEST)

if [[ "$TIC_TIMESTAMP" != "$MANIFEST_CREATED" ]]; then
  echo "✗ .tic timestamp ($TIC_TIMESTAMP) != MANIFEST created ($MANIFEST_CREATED)"
  ERRORS=$((ERRORS + 1))
else
  echo "✓ .tic timestamp matches MANIFEST identity.created"
fi

# Check 6: All tests pass
echo ""
echo "Running test suite..."
if ./tests/run_all_tests.sh >/dev/null 2>&1; then
  echo "✓ All tests pass (and artifacts cleaned)"
else
  echo "✗ Tests failing"
  echo "   Run: ./tests/run_all_tests.sh"
  ERRORS=$((ERRORS + 1))
fi

# Check 7: Scripts are executable
echo ""
echo "Checking script permissions..."
SCRIPT_ERRORS=0
for script in scripts/agents/*.sh scripts/validation/*.sh scripts/lib/*.sh; do
  if [[ -f "$script" ]] && [[ ! -x "$script" ]]; then
    echo "✗ $script not executable"
    SCRIPT_ERRORS=$((SCRIPT_ERRORS + 1))
  fi
done

if [[ $SCRIPT_ERRORS -eq 0 ]]; then
  echo "✓ All scripts are executable"
else
  echo "   Run: chmod +x scripts/**/*.sh"
  ERRORS=$((ERRORS + SCRIPT_ERRORS))
fi

# Check 8: Pre-commit hook installed
echo ""
if [[ -x .git/hooks/pre-commit ]]; then
  echo "✓ Pre-commit hook installed"
else
  echo "⚠️  Pre-commit hook not installed (optional but recommended)"
  echo "   Run (in repo root): "
  echo "   cd ./.git/hooks && ln -s ../../tests/pre-commit . 2>/dev/null || true && cd ../../ && chmod +x ./.git/hooks/pre-commit" 
fi

echo ""
echo "=========================================="
if [[ $ERRORS -eq 0 ]]; then
  echo "✅ READY FOR COMMIT!"
  echo ""
  echo "Next steps:"
  echo "  1. git add time/clock/.tic time/clock/MANIFEST"
  echo "  2. git commit -m 'initial: time/clock'"
  echo "  3. git push github main && git push gitlab main"
  exit 0
else
  echo "❌ NOT READY: $ERRORS error(s) found"
  echo ""
  echo "Fix the errors above and run again."
  exit 1
fi
