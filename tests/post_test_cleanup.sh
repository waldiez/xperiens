#!/usr/bin/env bash
set -euo pipefail

# Post-test cleanup
# Removes test artifacts from time/clock after running tests

cd "$(dirname "$0")/.."

echo "=== Post-test cleanup ==="
echo ""

# Remove .toc if it exists
if [[ -f time/clock/.toc ]]; then
  echo "Removing test artifact: time/clock/.toc"
  rm time/clock/.toc
fi

# Check if MANIFEST has state section (from testing)
if yq eval '.state' time/clock/MANIFEST &>/dev/null && [[ "$(yq eval '.state' time/clock/MANIFEST)" != "null" ]]; then
  echo "Removing state section from MANIFEST..."
  
  # Remove state section (keep everything else)
  yq eval 'del(.state)' time/clock/MANIFEST > time/clock/MANIFEST.tmp
  mv time/clock/MANIFEST.tmp time/clock/MANIFEST
  
  echo "✓ State section removed"
fi

echo ""
echo "✓ Cleanup complete"
