#!/usr/bin/env bash
# Validate CI/CD configuration before committing
# Usage: ./scripts/validate_ci.sh

set -e

# Source colors
# shellcheck disable=SC1091
source "$(dirname "$0")/lib/colors.sh"

echo "================================="
echo "CI/CD Configuration Validation"
echo "================================="
echo ""

# Track failures
FAILURES=0

# ===== 1. YAML SYNTAX VALIDATION =====
echo "1. Validating YAML syntax..."
echo "----------------------------"

for file in .github/workflows/*.yml .gitlab-ci.yml .gitlab/ci/*.yml; do
  if [ -f "$file" ]; then
    echo -n "  Checking $file... "
    if yq eval '.' "$file" > /dev/null 2>&1; then
      echo -e "${GREEN}✓${NC}"
    else
      echo -e "${RED}✗ INVALID${NC}"
      FAILURES=$((FAILURES + 1))
    fi
  fi
done

echo ""

# ===== 2. VALIDATION SCRIPTS =====
echo "2. Testing validation scripts..."
echo "-------------------------------"

echo -n "  check_tic_immutable.sh... "
if bash scripts/validation/check_tic_immutable.sh > /dev/null 2>&1; then
  echo -e "${GREEN}✓${NC}"
else
  echo -e "${RED}✗ FAILED${NC}"
  FAILURES=$((FAILURES + 1))
fi

echo -n "  check_manifest_sections.sh... "
if bash scripts/validation/check_manifest_sections.sh > /dev/null 2>&1; then
  echo -e "${GREEN}✓${NC}"
else
  echo -e "${RED}✗ FAILED${NC}"
  FAILURES=$((FAILURES + 1))
fi

echo ""

# ===== 3. TEST SUITE =====
echo "3. Running test suite..."
echo "-----------------------"
if ./tests/run_all_tests.sh > /dev/null 2>&1; then
  echo -e "  ${GREEN}✓ All tests pass${NC}"
else
  echo -e "  ${RED}✗ Tests failed${NC}"
  echo "  Run './tests/run_all_tests.sh' to see details"
  FAILURES=$((FAILURES + 1))
fi

echo ""

# ===== 4. LINTING =====
echo "4. Running linting..."
echo "--------------------"
if ./scripts/lint.sh > /dev/null 2>&1; then
  echo -e "  ${GREEN}✓ Linting passes${NC}"
else
  echo -e "  ${RED}✗ Linting failed${NC}"
  echo "  Run './scripts/lint.sh' to see details"
  FAILURES=$((FAILURES + 1))
fi

echo ""

# ===== 5. CI STATUS CHECK =====
echo "5. Checking CI configuration status..."
echo "--------------------------------------"

# Check if any CI files are already in git
CI_EXISTS=false

if git ls-files --error-unmatch .gitlab-ci.yml &>/dev/null || \
   git ls-files --error-unmatch .gitlab/ &>/dev/null || \
   git ls-files --error-unmatch .github/workflows/ &>/dev/null; then
  CI_EXISTS=true
fi

if [ "$CI_EXISTS" = "true" ]; then
  echo -e "  ${GREEN}✓ CI files already in git${NC}"
  echo "  This is a CI update/enhancement"
else
  echo -e "  ${YELLOW}: CI files are new${NC}"
  echo "  This is the initial CI setup"
fi

echo ""

# ===== SUMMARY =====
echo "================================="
if [ $FAILURES -eq 0 ]; then
  echo -e "${GREEN}✓ All validations passed!${NC}"
  echo "================================="
  echo ""
  echo "Ready to commit CI changes."
  echo ""
  echo "Review changes:"
  echo "  git status"
  echo "  git diff --staged"
  echo ""
  echo "Then commit with an appropriate message describing your changes."
  exit 0
else
  echo -e "${RED}✗ $FAILURES validation(s) failed${NC}"
  echo "================================="
  echo ""
  echo "Fix issues before committing"
  exit 1
fi
