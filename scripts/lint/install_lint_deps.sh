#!/usr/bin/env bash
set -euo pipefail

# Install linting dependencies using os_utils.sh
# Supports multiple platforms and package managers

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SCRIPT_DIR/.."

# Source os_utils
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/os_utils.sh"

echo "=== Installing Linting Dependencies ==="
echo ""

# Detect environment
OS=$(detect_os)
PM=$(detect_package_manager)
IN_CI=$(is_ci)

echo "Detected OS: $OS"
echo "Package manager: $PM"
echo "Running in CI: $IN_CI"
echo ""

# Track installation status
INSTALLED=0
FAILED=0

# Determine if we should use sudo
USE_SUDO=""
if [[ "$(is_root)" == "false" ]] && [[ "$PM" != "brew" ]]; then
  USE_SUDO="--sudo"
fi

# Install shellcheck
echo "Installing shellcheck..."
if command_exists shellcheck; then
  echo "✓ shellcheck already installed ($(shellcheck --version | head -2 | tail -1))"
  INSTALLED=$((INSTALLED + 1))
else
  if install_package shellcheck $USE_SUDO; then
    echo "✓ shellcheck installed"
    INSTALLED=$((INSTALLED + 1))
  else
    echo "⚠️  shellcheck installation failed"
    echo "   Visit: https://github.com/koalaman/shellcheck#installing"
    FAILED=$((FAILED + 1))
  fi
fi

# Install yamllint
echo ""
echo "Installing yamllint..."
if command_exists yamllint; then
  echo "✓ yamllint already installed ($(yamllint --version))"
  INSTALLED=$((INSTALLED + 1))
else
  # Try package manager first
  if install_package yamllint $USE_SUDO 2>/dev/null; then
    echo "✓ yamllint installed via package manager"
    INSTALLED=$((INSTALLED + 1))
  else
    # Fallback to pip
    echo "Package manager install failed, trying pip..."
    if pip_install yamllint --user; then
      echo "✓ yamllint installed via pip"
      INSTALLED=$((INSTALLED + 1))
    else
      echo "⚠️  yamllint installation failed"
      echo "   Try: pip install yamllint --user"
      FAILED=$((FAILED + 1))
    fi
  fi
fi

# Install markdownlint-cli (requires npm)
echo ""
echo "Installing markdownlint-cli..."
if command_exists markdownlint; then
  echo "✓ markdownlint-cli already installed ($(markdownlint --version))"
  INSTALLED=$((INSTALLED + 1))
else
  if command_exists npm; then
    if npm_install markdownlint-cli --global; then
      echo "✓ markdownlint-cli installed"
      INSTALLED=$((INSTALLED + 1))
    else
      echo "⚠️  markdownlint-cli installation failed"
      FAILED=$((FAILED + 1))
    fi
  else
    echo "⚠️  npm not found - please install Node.js and npm first"
    echo "   macOS: brew install node"
    echo "   Alpine: apk add nodejs npm"
    echo "   Then run: npm install -g markdownlint-cli"
    FAILED=$((FAILED + 1))
  fi
fi

echo ""
echo "=========================================="
echo "Installation Summary:"
echo "  Successfully installed: $INSTALLED"
echo "  Failed/Skipped:         $FAILED"
echo "=========================================="

if [[ $FAILED -eq 0 ]]; then
  echo ""
  echo "✅ All linting tools installed successfully!"
  echo ""
  echo "Verify installation:"
  echo "  shellcheck --version"
  echo "  yamllint --version"
  echo "  markdownlint --version"
  echo ""
  echo "Run linters:"
  echo "  ./scripts/lint.sh"
  exit 0
else
  echo ""
  echo "⚠️  Some tools failed to install. Please install manually."
  echo ""
  echo "See scripts/lint/README.md for installation instructions."
  exit 1
fi
