<!-- markdownlint-disable = MD024 , MD036 -->
# Windows Setup Guide

Waldiez Xperiens scripts are written in Bash and require a Bash environment to run on Windows.

---

## TL;DR

- ✅ **WSL2** (recommended): Linux environment on Windows
- ✅ **Git Bash** (lightweight): Bundled with Git for Windows
- ❌ **PowerShell/CMD**: Not supported (bash required)

---

## Option 1: WSL2 (Recommended)

### What Is WSL2?

Windows Subsystem for Linux 2 - runs a real Linux kernel inside Windows with near-native performance.

### Installation

**Requirements:**

- Windows 10 (version 1903+) or Windows 11
- Virtualization enabled in BIOS
- Administrator access

**Install:**

```powershell
# Open PowerShell as Administrator
wsl --install

# Install Ubuntu (default distribution)
wsl --install -d Ubuntu

# Restart your computer if/when prompted
```

**First-time setup:**

```bash
# After restart, Ubuntu will open automatically
# Create your Linux username and password
# (This is separate from your Windows login)

# Update packages
sudo apt update && sudo apt upgrade -y
```

### Setup Waldiez Xperiens

```bash
# Install dependencies
sudo apt install -y git

# Install yq (YAML processor)
sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
sudo chmod +x /usr/local/bin/yq

# Clone repository
# Option A: In Linux filesystem (faster)
cd ~
mkdir -p Projects
cd Projects
git clone https://github.com/waldiez/xperiens.git
# git clone https://gitlab.com/waldiez/xperiens.git
cd xperiens

# Option B: In Windows filesystem (accessible from Windows apps)
cd /mnt/c/Users/YourName/Projects  # Replace YourName
git clone https://gitlab.com/waldiez/xperiens.git
cd xperiens

# Verify setup
./tests/run_all_tests.sh
```

### Pros

- ✅ Full Linux environment
- ✅ Best compatibility with all scripts
- ✅ Near-native performance
- ✅ All Unix tools available
- ✅ Can access Windows filesystem

### Cons

- ⚠️ Requires Windows 10 1903+ or Windows 11
- ⚠️ Larger download (~500MB)
- ⚠️ Requires virtualization support

---

## Option 2: Git Bash (Lightweight)

### What Is Git Bash?

Minimal Bash environment bundled with Git for Windows. Provides basic Unix-like shell on Windows.

### Installation

**Download:** <https://git-scm.com/download/win>

**Install:**

- Run the installer
- Use default options
- Optionally: Check "Add Git Bash Here" context menu

### Setup Waldiez Xperiens

```bash
# Open Git Bash
# (Right-click in folder → "Git Bash Here" or launch from Start menu)

# Navigate to your projects folder
cd /c/Projects
# Note: Use forward slashes, not backslashes
# C:\Projects becomes /c/Projects

# Clone repository
git clone https://github.com/waldiez/xperiens.git
cd xperiens

# Install yq manually
curl -L https://github.com/mikefarah/yq/releases/latest/download/yq_windows_amd64.exe -o /usr/bin/yq.exe
chmod +x /usr/bin/yq.exe

# Verify yq works
yq --version

# Run tests
./tests/run_all_tests.sh
```

### Pros

- ✅ Lightweight (~50MB)
- ✅ Bundled with Git for Windows
- ✅ Works on older Windows versions
- ✅ Quick installation

### Cons

- ⚠️ Limited Unix tools available
- ⚠️ Manual yq installation required
- ⚠️ Some advanced scripts may not work
- ⚠️ Slower than WSL2

---

## Running Scripts

### WSL2

```bash
# Windows path: C:\Users\YourName\Projects\xperiens
# WSL path: /mnt/c/Users/YourName/Projects/xperiens
# OR (if stored in Linux): ~/Projects/xperiens

cd /mnt/c/Users/YourName/Projects/xperiens
# or
cd ~/Projects/xperiens

# Run tests
./tests/run_all_tests.sh

# Run linting
./scripts/lint.sh

# Run manual heartbeat
bash scripts/agents/time/clock/time_clock_updater.sh time/clock

# Check validation
bash scripts/validation/check_tic_immutable.sh
```

### Git Bash

```bash
# Windows path: C:\Projects\xperiens
# Git Bash path: /c/Projects/xperiens

cd /c/Projects/xperiens

# Run tests
./tests/run_all_tests.sh

# Run linting
./scripts/lint.sh

# Run manual heartbeat
bash scripts/agents/time/clock/time_clock_updater.sh time/clock

# Check validation
bash scripts/validation/check_tic_immutable.sh
```

---

## Common Issues

### Issue: "bash: command not found: yq"

**WSL2:**

```bash
sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
sudo chmod +x /usr/local/bin/yq
yq --version
```

**Git Bash:**

```bash
curl -L https://github.com/mikefarah/yq/releases/latest/download/yq_windows_amd64.exe -o /usr/bin/yq.exe
chmod +x /usr/bin/yq.exe
yq --version
```

### Issue: "Permission denied" when running scripts

```bash
# Fix script permissions
chmod +x ./tests/run_all_tests.sh
chmod +x ./scripts/lint.sh

# Or fix all scripts at once
find . -name "*.sh" -type f -exec chmod +x {} \;
```

### Issue: Line ending problems (^M characters)

```bash
# Configure git to handle CRLF/LF properly
git config --global core.autocrlf input

# Fix existing files
git config core.autocrlf input
git rm --cached -r .
git reset --hard
```

### Issue: "command not found: bash" in Git Bash

Git Bash should include bash by default. If you see this:

```bash
# Check bash location
which bash

# Try absolute path
/usr/bin/bash scripts/agents/time/clock/time_clock_updater.sh time/clock
```

---

## File Paths Explained

### WSL2 Path Translation

| Windows Path | WSL Path |
| ----------- | -------- |
| `C:\Users\YourName\Projects` | `/mnt/c/Users/YourName/Projects` |
| `D:\Code` | `/mnt/d/Code` |
| `C:\` | `/mnt/c/` |

**Linux home directory:**

- Windows: `\\wsl$\Ubuntu\home\username`
- WSL: `~` or `/home/username`

### Git Bash Path Translation

| Windows Path | Git Bash Path |
| ----------- | ------------- |
| `C:\Projects` | `/c/Projects` |
| `D:\Code` | `/d/Code` |
| `C:\Users\YourName` | `/c/Users/YourName` |

**Note:** Always use forward slashes `/` in Git Bash, not backslashes `\`.

---

## Best Practices

### WSL2: Where to Store Files

**Option A: Linux filesystem (recommended)**

```bash
cd ~
mkdir -p Projects
cd Projects
# Clone here: ~/Projects/xperiens
```

**Pros:**

- ✅ Much faster file operations
- ✅ Better for development
- ✅ Native Linux permissions

**Cons:**

- ⚠️ Harder to access from Windows apps

**Option B: Windows filesystem**

```bash
cd /mnt/c/Users/YourName/Projects
# Clone here: /mnt/c/Users/YourName/Projects/xperiens
```

**Pros:**

- ✅ Easy to access from Windows apps
- ✅ Works with Windows IDEs

**Cons:**

- ⚠️ Slower file operations
- ⚠️ Permission issues possible

### Git Bash: Where to Store Files

```bash
cd /c/Projects
# or
cd /c/Users/YourName/Projects
```

**Keep repos in standard Windows locations** for easy access.

---

## Editor Integration

### Visual Studio Code

**With WSL2:**

1. Install "Remote - WSL" extension
2. Open folder in WSL:

   ```bash
   # From WSL terminal
   cd ~/Projects/xperiens
   code .
   ```

3. VSCode opens with WSL context
4. Terminal inside VSCode uses WSL automatically

**With Git Bash:**

1. Open VSCode normally
2. Terminal → Select Default Profile → Git Bash
3. All terminals use Git Bash

### Other Editors

- Store repo in Windows filesystem
- Configure editor to use Unix line endings (LF, not CRLF)
- Use Git Bash for terminal commands

---

## CI/CD on Windows

**Good news:** You don't need special Windows setup for CI/CD!

**GitHub Actions:** Runs on Ubuntu Linux (regardless of your OS)  
**GitLab CI:** Runs on Linux containers (regardless of your OS)

**Your local Windows setup** is only for:

- Local development
- Manual testing
- Running scripts locally

CI/CD always runs in Linux environments, so your scripts work the same way in CI as they do in WSL2.

---

## Limitations

### Not Supported

- ❌ Native PowerShell execution
- ❌ Native CMD/batch scripts
- ❌ Windows-native tools only

### Why?

Scripts require:

- Bash shell and syntax
- Unix tools: `grep`, `sed`, `awk`, `find`, `wc`
- `yq` for YAML processing
- POSIX-style file paths
- Unix-style permissions

### Future Support

**Planned for v0.2+ (future):**

- Python-based cross-platform tools
- Native Windows executables
- PowerShell module alternatives

**For now:** Use WSL2 (best) or Git Bash (lightweight).

---

## Verification Checklist

**Test your setup:**

```bash
cd ~/Projects/xperiens  # or your path

# 1. Check bash
bash --version
# Should show: GNU bash, version 5.x or higher

# 2. Check yq
yq --version
# Should show: yq version 4.x or higher

# 3. Check git
git --version
# Should show: git version 2.x or higher

# 4. Run all tests
./tests/run_all_tests.sh
# Should show: All tests pass (100% coverage)

# 5. Run linting
./scripts/lint.sh
# Should show: All linters pass

# 6. Manual heartbeat test
bash scripts/agents/time/clock/time_clock_updater.sh time/clock
# Should show: No errors
```

**If all checks pass:** ✅ Setup complete!

---

## Performance Tips

### WSL2

**Improve performance:**

```bash
# Store repos in Linux filesystem (~/Projects)
# Not in Windows filesystem (/mnt/c/...)

# Configure .wslconfig (optional)
# Create: C:\Users\YourName\.wslconfig
[wsl2]
memory=4GB
processors=2
```

### Git Bash

**Improve performance:**

```bash
# Use shorter paths
cd /c/Projects  # not /c/Users/YourName/Documents/Projects

# Disable real-time antivirus scanning for project folder
# (Windows Defender settings)
```

---

## Getting Help

### WSL2 Documentation

- Official WSL docs: <https://docs.microsoft.com/en-us/windows/wsl/>
- WSL troubleshooting: <https://docs.microsoft.com/en-us/windows/wsl/troubleshooting>

### Git Bash Documentation

- Git for Windows: <https://gitforwindows.org/>
- Git Bash guide: <https://git-scm.com/book/en/v2/Appendix-A%3A-Git-in-Other-Environments-Git-in-Bash>

### Script Issues

- Testing guide: `docs/TESTING_GUIDE.md`
- Workflow guide: `docs/WORKFLOW_GUIDE.md`
- Specification: `docs/SPECIFICATION.md`

---

## Quick Reference

### Common Commands

```bash
# Navigate to project
cd ~/Projects/xperiens  # WSL2
cd /c/Projects/xperiens  # Git Bash

# Run tests
./tests/run_all_tests.sh

# Lint code
./scripts/lint.sh

# Manual heartbeat
bash scripts/agents/time/clock/time_clock_updater.sh time/clock

# Check git status
git status

# Pull latest changes
git pull

# View logs
git log --oneline
```

### Path Cheat Sheet

**WSL2:**

- Linux home: `~` or `/home/username`
- Windows C: `/mnt/c/`
- Project (recommended): `~/Projects/xperiens`

**Git Bash:**

- Windows C: `/c/`
- Project: `/c/Projects/xperiens`

---

**Last updated:** 2026-02-08  
**Platform support:** v0.1-alpha  
**WSL2 version tested:** WSL 2  
**Git Bash version tested:** 2.43+
