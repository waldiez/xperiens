#!/usr/bin/env bash
set -e

# Check that .tic files are never modified after creation
# Usage: check_tic_immutable.sh

echo "=== Checking .tic immutability ==="

# Get modified .tic files between HEAD~1 and HEAD
# The --diff-filter=M ensures we only catch modifications, not additions (A) or deletions (D)
MODIFIED_TICS=$(git diff --name-only --diff-filter=M HEAD~1 HEAD 2>/dev/null | grep '\.tic$' || true)

if [[ -n "$MODIFIED_TICS" ]]; then
  echo "❌ ERROR: Existing .tic files are immutable and cannot be modified."
  echo ""
  echo "Modified files:"
  echo "$MODIFIED_TICS"
  echo ""
  echo ".tic files are birth certificates - they define the waldiez's"
  echo "identity in time and MUST NOT be modified after their first commit."
  echo ""
  echo "If you need to update a creation time, create a new waldiez with"
  echo "a version bump in the WID (e.g., v1 → v2)."
  exit 1
fi

echo "✅ No existing .tic files were modified."
