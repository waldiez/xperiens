# 🚀 Quick Start

## Before You Start

```bash
cd ~/Projects/waldiez/xperiens

# 1. Install test dependencies
chmod +x tests/install_test_deps.sh
./tests/install_test_deps.sh

# 1b. Install linting tools (optional but recommended)
chmod +x scripts/lint/install_lint_deps.sh
./scripts/lint/install_lint_deps.sh

# 2. Run tests (REQUIRED - verify 100% coverage)
chmod +x tests/**/*.sh
./tests/run_all_tests.sh
./tests/coverage_report.sh

# 3. Install pre-commit hook (blocks untested code)
# Or use pre-commit framework: pip install prek/pre-commit && prek install
ln -s ../../tests/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

# 4. Make scripts executable
chmod +x scripts/**/*.sh

# Optional: Set up multi-platform (GitHub + GitLab)
# See docs/MULTI_PLATFORM_SETUP.md for details
```

## The Four Initial Commits

### 1. Start 🌱

```bash
git add time/clock/.tic time/clock/MANIFEST
git commit -m "Initial: time/clock"
# Pre-commit hook runs tests automatically ✓
git push  # or: git push github main && git push gitlab main
```

### 2. Documentation 📚

```bash
git add time/clock/README.md time/clock/PLAN.md
git commit -m "docs(time/clock): Add README and PLAN"
git push
```

### 3. Automation ⚙️

```bash
# Test first (then reset)
bash scripts/agents/time/clock/time_clock_updater.sh time/clock
git restore time/clock/

# Commit scripts + tests
git add scripts/agents/ tests/
git commit -m "feat(agents): Add time/clock updater and README updater"
git push
```

### 4. Activation 🚀

```bash
# Commit CI configs for BOTH platforms
git add .github/ .gitlab-ci.yml scripts/validation/ tests/
git commit -m "ci(time/clock): Add health monitor and validation"
git push

# If using GitLab: Set up CI_PUSH_TOKEN (see MULTI_PLATFORM_SETUP.md)
```

## Then Wait for CI ⏰

**Within 1 hour:** CI makes commits 5 & 6 automatically

```bash
# Check after ~1 hour
git pull
cat README.md           # Should show: Days: 1, Status: 🟢 Alive
cat time/clock/.toc     # Should have dates
```

## Testing Notes

- ✅ **All code is tested** (100% coverage)
- ✅ **Pre-commit hook** blocks untested code
- ✅ **CI runs tests** on every PR
- 📖 **See:** `docs/TESTING_GUIDE.md` for details

## Multi-Platform Notes

- ✅ **GitHub Actions:** Works immediately after push
- ⚙️ **GitLab CI:** Requires `CI_PUSH_TOKEN` setup (one-time, 2 minutes)

See `docs/MULTI_PLATFORM_SETUP.md` for complete instructions.

## ✅ Done

Your waldiez is now **alive, autonomous, and fully tested** on both platforms! 🎉

See `LAUNCH.md` for detailed explanations.
