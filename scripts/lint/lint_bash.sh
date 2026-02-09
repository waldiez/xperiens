#!/usr/bin/env bash
set -euo pipefail

# Bash script linter using shellcheck
# Lints all .sh files in the repository

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SCRIPT_DIR/.."

echo "=== Bash Script Linter (shellcheck) ==="
echo ""

# Check if shellcheck is installed
if ! command -v shellcheck &> /dev/null; then
    echo "❌ shellcheck not found"
    echo ""
    echo "Install with:"
    echo "  macOS:   brew install shellcheck"
    echo "  Ubuntu:  sudo apt-get install shellcheck"
    echo "  Other:   https://github.com/koalaman/shellcheck#installing"
    exit 1
fi

echo "shellcheck version: $(shellcheck --version | head -2 | tail -1)"
echo ""

# Find all .sh files
SCRIPT_FILES=$(find scripts tests -name "*.sh" -type f 2>/dev/null || true)

if [[ -z "$SCRIPT_FILES" ]]; then
    echo "✓ No bash scripts found to lint"
    exit 0
fi

SCRIPT_COUNT=$(echo "$SCRIPT_FILES" | wc -l | tr -d ' ')
echo "Found $SCRIPT_COUNT bash script(s) to lint"
echo ""

ERRORS=0
WARNINGS=0

# Lint each script
while IFS= read -r script; do
    echo "Checking: $script"

    # Run shellcheck
    # Exclude SC2086 (double quote to prevent globbing) - sometimes we want word splitting
    # Exclude SC1091 (not following sourced files) - handled separately
    if OUTPUT=$(shellcheck -x -e SC1091 "$script" 2>&1); then
        echo "  ✓ No issues"
    else
        # Check severity
        if echo "$OUTPUT" | grep -q "error:"; then
            ERRORS=$((ERRORS + 1))
            echo "  ❌ Errors found:"
        elif echo "$OUTPUT" | grep -q "warning:"; then
            WARNINGS=$((WARNINGS + 1))
            echo "  ⚠️  Warnings found:"
        fi
        echo "$OUTPUT" | sed 's/^/    /'
    fi
    echo ""
done <<< "$SCRIPT_FILES"

echo "=========================================="
echo "Summary:"
echo "  Scripts checked: $SCRIPT_COUNT"
echo "  Errors:          $ERRORS"
echo "  Warnings:        $WARNINGS"
echo "=========================================="

if [[ $ERRORS -gt 0 ]]; then
    echo ""
    echo "❌ Linting failed with errors"
    exit 1
elif [[ $WARNINGS -gt 0 ]]; then
    echo ""
    echo "⚠️  Linting passed with warnings"
    exit 0
else
    echo ""
    echo "✅ All bash scripts passed linting!"
    exit 0
fi
