#!/usr/bin/env bash
set -euo pipefail

# Markdown linter using markdownlint-cli
# Lints all .md files in the repository

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SCRIPT_DIR/.."

echo "=== Markdown Linter (markdownlint) ==="
echo ""

# Check if markdownlint is installed
if ! command -v markdownlint &> /dev/null; then
    echo "❌ markdownlint not found"
    echo ""
    echo "Install with:"
    echo "  npm:  npm install -g markdownlint-cli"
    echo "  Note: Requires Node.js and npm"
    exit 1
fi

echo "markdownlint version: $(markdownlint --version)"
echo ""

# Find all markdown files
MD_FILES=$(find . -name "*.md" | grep -v ".git" | grep -v "node_modules" | grep -v ".local" 2>/dev/null || true)

if [[ -z "$MD_FILES" ]]; then
    echo "✓ No markdown files found to lint"
    exit 0
fi

MD_COUNT=$(echo "$MD_FILES" | wc -l | tr -d ' ')
echo "Found $MD_COUNT markdown file(s) to lint"
echo ""

# Create markdownlint config if it doesn't exist
MARKDOWNLINT_CONFIG=".markdownlint.json"
if [[ ! -f "$MARKDOWNLINT_CONFIG" ]]; then
    echo "Creating .markdownlint.json config..."
    cat > "$MARKDOWNLINT_CONFIG" <<'EOF'
{
  "default": true,
  "MD013": {
    "line_length": 120,
    "code_blocks": false,
    "tables": false
  },
  "MD033": false,
  "MD041": false,
  "MD036": false
}
EOF
    echo ""
fi

ERRORS=0

# Lint all files at once (markdownlint handles multiple files)
echo "Running markdownlint..."
if OUTPUT=$(markdownlint $MD_FILES 2>&1); then
    echo "✓ No issues found"
    echo ""
else
    ERRORS=1
    echo "❌ Issues found:"
    echo "$OUTPUT"
    echo ""
fi

echo "=========================================="
echo "Summary:"
echo "  Markdown files checked: $MD_COUNT"
if [[ $ERRORS -eq 0 ]]; then
    echo "  Status:                 ✅ Pass"
else
    echo "  Status:                 ❌ Fail"
fi
echo "=========================================="

if [[ $ERRORS -gt 0 ]]; then
    echo ""
    echo "❌ Linting failed"
    exit 1
else
    echo ""
    echo "✅ All markdown files passed linting!"
    exit 0
fi
