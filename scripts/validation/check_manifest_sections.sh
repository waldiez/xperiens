#!/usr/bin/env bash
set -e

# Check MANIFEST section ownership rules
# - identity section: immutable (never changes)
# - state section: automation only (humans should not edit)
#
# Usage: check_manifest_sections.sh

echo "=== Checking MANIFEST integrity ==="

# Get commit author
AUTHOR=$(git log -1 --format='%an' 2>/dev/null || echo "unknown")
echo "Commit author: $AUTHOR"

# Find changed MANIFESTs
CHANGED_MANIFESTS=$(git diff --name-only HEAD~1 HEAD 2>/dev/null | grep 'MANIFEST$' || true)

if [[ -z "$CHANGED_MANIFESTS" ]]; then
  echo "✅ No MANIFEST files modified"
  exit 0
fi

echo "Checking modified MANIFESTs:"
echo "$CHANGED_MANIFESTS"
echo ""

for manifest in $CHANGED_MANIFESTS; do
  echo "Checking $manifest..."

  # Get diff
  DIFF=$(git diff HEAD~1 HEAD "$manifest" 2>/dev/null || true)

  # Check if identity section was modified (WID or created timestamp)
  if echo "$DIFF" | grep -E '^\+.*wid:|^\+.*created:' >/dev/null 2>&1; then
    echo "❌ ERROR: Immutable identity fields modified in $manifest"
    echo ""
    echo "The 'wid' and 'created' fields in the identity section are"
    echo "immutable and MUST NOT be changed after first commit."
    echo ""
    echo "If you need to change identity, create a new waldiez with a"
    echo "version bump in the WID."
    exit 1
  fi

  # If not a bot commit, check if state section was modified
  if [[ "$AUTHOR" != "waldiez-bot" ]]; then
    # Compare state sections structurally (avoid fragile diff parsing)
    PREV_STATE=$(git show HEAD~1:"$manifest" 2>/dev/null | yq -o=json '.state' 2>/dev/null || echo "null")
    CURR_STATE=$(yq -o=json '.state' "$manifest" 2>/dev/null || echo "null")

    if [[ "$PREV_STATE" != "$CURR_STATE" ]]; then
      echo "⚠️  WARNING: Human commit modified state section in $manifest"
      echo ""
      echo "The 'state' section should only be modified by automation"
      echo "(waldiez-bot). Human edits may cause state drift."
      echo ""
      echo "If you need to fix state, consider:"
      echo "1. Running the updater script to self-heal"
      echo "2. Modifying the updater logic instead"
      echo "3. Documenting why manual state fix was needed"
      echo ""
      # Downgrade to warning instead of error for now
      # exit 1
    fi
  fi
done

echo "✅ MANIFEST changes are valid"
