#!/usr/bin/env bash
# OS detection and package management utilities
# Provides cross-platform package installation and OS detection

# Detect operating system
# Returns: "macos", "linux", "alpine", "unknown"
detect_os() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "macos"
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Check if Alpine (uses apk)
    if command -v apk &>/dev/null; then
      echo "alpine"
    else
      echo "linux"
    fi
  else
    echo "unknown"
  fi
}

# Detect Linux distribution
# Returns: "ubuntu", "debian", "alpine", "fedora", "arch", "unknown"
detect_linux_distro() {
  if [[ ! "$OSTYPE" == "linux-gnu"* ]]; then
    echo "not-linux"
    return
  fi
  
  # Check for Alpine
  if command -v apk &>/dev/null; then
    echo "alpine"
    return
  fi
  
  # Check for various distros
  if [[ -f /etc/os-release ]]; then
    local distro_id
    distro_id=$(grep "^ID=" /etc/os-release | cut -d= -f2 | tr -d '"')
    echo "$distro_id"
  else
    echo "unknown"
  fi
}

# Detect package manager
# Returns: "brew", "apt", "apk", "dnf", "yum", "pacman", "unknown"
detect_package_manager() {
  if command -v brew &>/dev/null; then
    echo "brew"
  elif command -v pacman &>/dev/null; then
    echo "pacman"
  elif command -v apt-get &>/dev/null; then
    echo "apt"
  elif command -v apk &>/dev/null; then
    echo "apk"
  elif command -v dnf &>/dev/null; then
    echo "dnf"
  elif command -v yum &>/dev/null; then
    echo "yum"
  else
    echo "unknown"
  fi
}

# Check if running in CI environment
# Returns: "true" or "false"
is_ci() {
  if [[ -n "${CI:-}" ]] || [[ -n "${GITHUB_ACTIONS:-}" ]] || [[ -n "${GITLAB_CI:-}" ]]; then
    echo "true"
  else
    echo "false"
  fi
}

# Check if command exists
# Usage: command_exists "git"
# Returns: 0 (true) if exists, 1 (false) if not
command_exists() {
  command -v "$1" &>/dev/null
}

# Install package using appropriate package manager
# Usage: install_package "git" [--sudo] [--quiet]
# Returns: 0 on success, 1 on failure
install_package() {
  local package="$1"
  local use_sudo=false
  local quiet=false
  
  # Parse flags
  shift
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --sudo) use_sudo=true; shift ;;
      --quiet) quiet=true; shift ;;
      *) shift ;;
    esac
  done
  
  local pm
  pm=$(detect_package_manager)
  
  local install_cmd=""
  
  case "$pm" in
    brew)
      install_cmd="brew install $package"
      ;;
    apt)
      if [[ "$use_sudo" == "true" ]]; then
        install_cmd="sudo apt-get update && sudo apt-get install -y $package"
      else
        install_cmd="apt-get update && apt-get install -y $package"
      fi
      ;;
    apk)
      if [[ "$use_sudo" == "true" ]]; then
        install_cmd="sudo apk add --no-cache $package"
      else
        install_cmd="apk add --no-cache $package"
      fi
      ;;
    dnf)
      if [[ "$use_sudo" == "true" ]]; then
        install_cmd="sudo dnf install -y $package"
      else
        install_cmd="dnf install -y $package"
      fi
      ;;
    yum)
      if [[ "$use_sudo" == "true" ]]; then
        install_cmd="sudo yum install -y $package"
      else
        install_cmd="yum install -y $package"
      fi
      ;;
    pacman)
      if [[ "$use_sudo" == "true" ]]; then
        install_cmd="sudo pacman -S --noconfirm $package"
      else
        install_cmd="pacman -S --noconfirm $package"
      fi
      ;;
    *)
      echo "ERROR: Unknown package manager" >&2
      return 1
      ;;
  esac
  
  # Execute installation
  if [[ "$quiet" == "true" ]]; then
    eval "$install_cmd" >/dev/null 2>&1
  else
    eval "$install_cmd"
  fi
}

# Try to install package with pip (fallback option)
# Usage: pip_install "yamllint" [--user] [--quiet]
# Returns: 0 on success, 1 on failure
pip_install() {
  local package="$1"
  local use_user=false
  local quiet=false
  
  # Parse flags
  shift
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --user) use_user=true; shift ;;
      --quiet) quiet=true; shift ;;
      *) shift ;;
    esac
  done

  # Prefer python -m pip over plain pip
  local pip_cmd=""
  if command_exists python3; then
    pip_cmd="python3 -m pip"
  elif command_exists python; then
    pip_cmd="python -m pip"
  # Prefer pip3 over pip
  elif command_exists pip3; then
    pip_cmd="pip3"
  elif command_exists pip; then
    pip_cmd="pip"
  else
    echo "ERROR: pip not found" >&2
    return 1
  fi
  
  # Build install command
  local install_args="install"
  [[ "$use_user" == "true" ]] && install_args="$install_args --user"
  [[ "$quiet" == "true" ]] && install_args="$install_args --quiet"
  
  # shellcheck disable=SC2086
  $pip_cmd $install_args "$package"
}

# Try to install package with npm (fallback option)
# Usage: npm_install "markdownlint-cli" [--global] [--quiet]
# Returns: 0 on success, 1 on failure
npm_install() {
  local package="$1"
  local use_global=false
  local quiet=false
  
  # Parse flags
  shift
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --global) use_global=true; shift ;;
      --quiet) quiet=true; shift ;;
      *) shift ;;
    esac
  done
  
  if ! command_exists npm; then
    echo "ERROR: npm not found" >&2
    return 1
  fi
  
  # Build install command
  local install_args=""
  [[ "$use_global" == "true" ]] && install_args="-g"
  [[ "$quiet" == "true" ]] && install_args="$install_args --silent"
  
  # shellcheck disable=SC2086
  npm install $install_args "$package"
}

# Get number of CPU cores
# Returns: number of cores
cpu_cores() {
  if [[ "$(detect_os)" == "macos" ]]; then
    sysctl -n hw.ncpu
  else
    nproc
  fi
}

# Check if running with root/sudo privileges
# Returns: "true" or "false"
is_root() {
  if [[ $EUID -eq 0 ]]; then
    echo "true"
  else
    echo "false"
  fi
}

# Export functions for use in sub-shells
export -f detect_os
export -f detect_linux_distro
export -f detect_package_manager
export -f is_ci
export -f command_exists
export -f install_package
export -f pip_install
export -f npm_install
export -f cpu_cores
export -f is_root
