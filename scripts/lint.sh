#!/usr/bin/env bash
set -euo pipefail

# Master linter script
# Orchestrates all linting tools for the repository
#
# Usage: ./scripts/lint.sh [options]
#
# Options:
#   --bash         Lint bash scripts only
#   --yaml         Lint YAML files only
#   --markdown     Lint markdown files only
#   --fix          Auto-fix issues where possible (not yet implemented)
#   --help         Show this help message

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/colors.sh"

# Parse arguments
RUN_BASH=false
RUN_YAML=false
RUN_MARKDOWN=false
RUN_ALL=true
AUTO_FIX=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --bash)
            RUN_BASH=true
            RUN_ALL=false
            shift
            ;;
        --yaml)
            RUN_YAML=true
            RUN_ALL=false
            shift
            ;;
        --markdown)
            RUN_MARKDOWN=true
            RUN_ALL=false
            shift
            ;;
        --fix)
            # shellcheck disable=SC2034
            AUTO_FIX=true
            shift
            ;;
        --help)
            echo "Usage: ./scripts/lint.sh [options]"
            echo ""
            echo "Options:"
            echo "  --bash         Lint bash scripts only"
            echo "  --yaml         Lint YAML files only"
            echo "  --markdown     Lint markdown files only"
            echo "  --fix          Auto-fix issues where possible"
            echo "  --help         Show this help message"
            echo ""
            echo "Examples:"
            echo "  ./scripts/lint.sh              # Lint everything"
            echo "  ./scripts/lint.sh --bash       # Lint bash scripts only"
            echo "  ./scripts/lint.sh --yaml --md  # Lint YAML and markdown"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# If no specific linter selected, run all
if [[ "$RUN_ALL" == true ]]; then
    RUN_BASH=true
    RUN_YAML=true
    RUN_MARKDOWN=true
fi

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Waldiez Xperiens - Linter Suite    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

TOTAL_ERRORS=0
LINTERS_RUN=0
LINTERS_PASSED=0

# Run bash linter
if [[ "$RUN_BASH" == true ]]; then
    LINTERS_RUN=$((LINTERS_RUN + 1))

    if bash "$SCRIPT_DIR/lint/lint_bash.sh"; then
        LINTERS_PASSED=$((LINTERS_PASSED + 1))
    else
        TOTAL_ERRORS=$((TOTAL_ERRORS + 1))
    fi
    echo ""
fi

# Run YAML linter
if [[ "$RUN_YAML" == true ]]; then
    LINTERS_RUN=$((LINTERS_RUN + 1))

    if bash "$SCRIPT_DIR/lint/lint_yaml.sh"; then
        LINTERS_PASSED=$((LINTERS_PASSED + 1))
    else
        TOTAL_ERRORS=$((TOTAL_ERRORS + 1))
    fi
    echo ""
fi

# Run markdown linter
if [[ "$RUN_MARKDOWN" == true ]]; then
    LINTERS_RUN=$((LINTERS_RUN + 1))

    if bash "$SCRIPT_DIR/lint/lint_markdown.sh"; then
        LINTERS_PASSED=$((LINTERS_PASSED + 1))
    else
        TOTAL_ERRORS=$((TOTAL_ERRORS + 1))
    fi
    echo ""
fi

# Summary
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           Final Summary                ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""
echo "Linters run:    $LINTERS_RUN"
echo "Linters passed: $LINTERS_PASSED"
echo "Linters failed: $TOTAL_ERRORS"
echo ""

if [[ $TOTAL_ERRORS -eq 0 ]]; then
    echo -e "${GREEN}✅ All linters passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ Linting failed with $TOTAL_ERRORS error(s)${NC}"
    echo ""
    echo "Fix the issues above and run again."
    exit 1
fi
