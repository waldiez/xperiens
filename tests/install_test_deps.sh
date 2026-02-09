#!/usr/bin/env bash
set -euo pipefail

# Install test dependencies using os_utils.sh
# Installs BATS and yq

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source os_utils
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../scripts/lib/os_utils.sh"

echo "=== Installing Test Dependencies ==="
echo ""

# Detect environment
OS=$(detect_os)
PM=$(detect_package_manager)

echo "Detected OS: $OS"
echo "Package manager: $PM"
echo ""

# Track installation
INSTALLED=0
FAILED=0

# Determine if we should use sudo
USE_SUDO=""
if [[ "$(is_root)" == "false" ]] && [[ "$PM" != "brew" ]]; then
  USE_SUDO="--sudo"
fi

# Install BATS
echo "Installing bats-core..."
if command_exists bats; then
  echo "✓ bats already installed ($(bats --version))"
  INSTALLED=$((INSTALLED + 1))
else
  # Try package manager
  BATS_PACKAGE="bats"
  [[ "$PM" == "apt" ]] && BATS_PACKAGE="bats"
  [[ "$PM" == "brew" ]] && BATS_PACKAGE="bats-core"

  if install_package "$BATS_PACKAGE" $USE_SUDO; then
    echo "✓ bats installed"
    INSTALLED=$((INSTALLED + 1))
  else
    echo "⚠️  bats installation failed"
    echo "   Manual install:"
    echo "   git clone https://github.com/bats-core/bats-core.git"
    echo "   cd bats-core && sudo ./install.sh /usr/local"
    FAILED=$((FAILED + 1))
  fi
fi

# Install yq
echo ""
echo "Installing yq..."
if command_exists yq; then
  echo "✓ yq already installed ($(yq --version))"
  INSTALLED=$((INSTALLED + 1))
else
  if [[ "$PM" == "brew" ]]; then
    if install_package yq; then
      echo "✓ yq installed via brew"
      INSTALLED=$((INSTALLED + 1))
    else
      FAILED=$((FAILED + 1))
    fi
  else
    # Install via binary download
    echo "Installing yq via binary download..."
    YQ_VERSION="v4.35.1"
    YQ_BINARY="yq_linux_amd64"

    [[ "$OS" == "macos" ]] && YQ_BINARY="yq_darwin_amd64"

    if curl -sL "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY}" -o /tmp/yq; then
      chmod +x /tmp/yq
      if [[ "$(is_root)" == "true" ]]; then
        mv /tmp/yq /usr/local/bin/yq
      else
        sudo mv /tmp/yq /usr/local/bin/yq
      fi
      echo "✓ yq installed"
      INSTALLED=$((INSTALLED + 1))
    else
      echo "⚠️  yq installation failed"
      echo "   Try: brew install yq"
      echo "   Or visit: https://github.com/mikefarah/yq#install"
      FAILED=$((FAILED + 1))
    fi
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
  echo "✅ All test dependencies installed!"
  echo ""
  echo "Verify installation:"
  echo "  bats --version"
  echo "  yq --version"
  echo ""
  echo "Run tests:"
  echo "  ./tests/run_all_tests.sh"
  exit 0
else
  echo ""
  echo "⚠️  Some tools failed to install."
  echo "See manual installation instructions above."
  exit 1
fi
