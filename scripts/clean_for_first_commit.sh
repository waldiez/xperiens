#!/usr/bin/env bash
# Clean time/clock state before first commit

cd "$(dirname "$0")/.." || exit 1

echo "=== Cleaning time/clock state for first commit ==="
echo ""

# Remove .toc (will be created by CI)
if [[ -f time/clock/.toc ]]; then
  echo "Removing time/clock/.toc..."
  rm time/clock/.toc
  echo "✓ Removed"
else
  echo "✓ time/clock/.toc not present"
fi

# Remove state section from MANIFEST if present
if yq eval '.state' time/clock/MANIFEST &>/dev/null && [[ "$(yq eval '.state' time/clock/MANIFEST)" != "null" ]]; then
  echo ""
  echo "Removing state section from MANIFEST..."
  yq eval 'del(.state)' time/clock/MANIFEST > time/clock/MANIFEST.tmp
  mv time/clock/MANIFEST.tmp time/clock/MANIFEST
  echo "✓ Removed"
else
  echo "✓ MANIFEST state section not present"
fi

echo ""
echo "Verifying clean state:"
echo ""

# Check .tic exists (should)
if [[ -f time/clock/.tic ]]; then
  echo "✓ time/clock/.tic exists (first commit / genesis file)"
  cat time/clock/.tic
else
  echo "✗ ERROR: time/clock/.tic missing!"
  exit 1
fi

echo ""

# Check .toc does not exist (should not)
if [[ ! -f time/clock/.toc ]]; then
  echo "✓ time/clock/.toc does not exist (will be created by CI)"
else
  echo "✗ ERROR: time/clock/.toc still exists!"
  exit 1
fi

echo ""

# Check MANIFEST has no state section
if yq eval '.state' time/clock/MANIFEST &>/dev/null && [[ "$(yq eval '.state' time/clock/MANIFEST)" != "null" ]]; then
  echo "✗ ERROR: MANIFEST still has state section!"
  exit 1
else
  echo "✓ MANIFEST has no state section (will be added by CI)"
fi

echo ""
echo "=== Clean state verified! Ready for commit ==="
