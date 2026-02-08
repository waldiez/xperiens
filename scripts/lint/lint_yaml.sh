#!/usr/bin/env bash
set -euo pipefail

# YAML linter using yamllint
# Lints all .yml and .yaml files in the repository

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SCRIPT_DIR/.."

echo "=== YAML Linter (yamllint) ==="
echo ""

# Check if yamllint is installed
if ! command -v yamllint &> /dev/null; then
    echo "❌ yamllint not found"
    echo ""
    echo "Install with:"
    echo "  pip:     pip install yamllint # [--user / --break-system-packages]"
    echo "  macOS:   brew install yamllint"
    echo "  Ubuntu:  sudo apt-get install yamllint"
    exit 1
fi

echo "yamllint version: $(yamllint --version)"
echo ""

# Find all YAML files
YAML_FILES=$(find . -name "*.yml" -o -name "*.yaml" | grep -v ".git" | grep -v "node_modules" 2>/dev/null || true)

if [[ -z "$YAML_FILES" ]]; then
    echo "✓ No YAML files found to lint"
    exit 0
fi

YAML_COUNT=$(echo "$YAML_FILES" | wc -l | tr -d ' ')
echo "Found $YAML_COUNT YAML file(s) to lint"
echo ""

# Create yamllint config if it doesn't exist
YAMLLINT_CONFIG=".yamllint.yaml"
if [[ ! -f "$YAMLLINT_CONFIG" ]]; then
    echo "Creating .yamllint.yaml config..."
    cat > "$YAMLLINT_CONFIG" <<'EOF'
---
extends: default

rules:
  line-length:
    max: 200
    level: warning
  comments:
    min-spaces-from-content: 2
  indentation:
    spaces: 2
    indent-sequences: consistent
  document-start: disable
  truthy:
    allowed-values: ['true', 'false']

ignore-from-file: .gitignore

EOF
    echo ""
fi

ERRORS=0
WARNINGS=0

# Lint each file
while IFS= read -r yamlfile; do
    echo "Checking: $yamlfile"
    
    # Run yamllint
    if OUTPUT=$(yamllint -f parsable "$yamlfile" 2>&1); then
        echo "  ✓ No issues"
    else
        # Check severity
        if echo "$OUTPUT" | grep -q "error"; then
            ERRORS=$((ERRORS + 1))
            echo "  ❌ Errors found:"
        else
            WARNINGS=$((WARNINGS + 1))
            echo "  ⚠️  Warnings found:"
        fi
        # shellcheck disable=SC2001
        echo "$OUTPUT" | sed 's/^/    /'
    fi
    echo ""
done <<< "$YAML_FILES"

echo "=========================================="
echo "Summary:"
echo "  YAML files checked: $YAML_COUNT"
echo "  Errors:             $ERRORS"
echo "  Warnings:           $WARNINGS"
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
    echo "✅ All YAML files passed linting!"
    exit 0
fi
