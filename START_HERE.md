# Waldiez Xperiens - Complete Guide

👋 Welcome! This directory contains the **reference implementation** of the Waldiez Xperiens.

> **Note:** The main `README.md` is dynamically updated by automation.  
> This file (`START_HERE.md`) contains more details.

---

## 🟢 System Status: alive

**The time/clock waldiez is operating autonomously!**

For real-time status, metrics, and health indicators, see the main [`README.md`](README.md).

---

## What Is This?

The Waldiez Xperiens demonstrates:

- How to create a waldiez agent from scratch
- The human/automation boundary
- Heartbeat-driven health monitoring
- Immutability guarantees
- The complete lifecycle from initial commit to autonomous operation

**Status:** 🟢 **SYSTEM IS ALIVE!** The time/clock waldiez is operating autonomously.

## Directory Structure

```text
~/Projects/waldiez/xperiens/
├── .gitignore               # Git exclusions
├── .gitlab-ci.yml           # GitLab CI (modular, uses includes)
├── README.md                # Dynamic status (AUTO-UPDATED by CI) 🟢
├── START_HERE.md            # This file (static guide)
├── QUICKSTART.md            # Quick start guide
├── LAUNCH.md                # Launch checklist (historical)
├── LICENSE                  # Apache 2.0 license
├── NOTICE.md                # Legal notices
├── SECURITY.md              # Security policy
│
├── .github/                 # GitHub integration
│   ├── ISSUE_TEMPLATE/      # Issue form templates
│   │   ├── bug_report.yml
│   │   ├── feature_request.yml
│   │   ├── waldiez_proposal.yml
│   │   └── config.yml
│   ├── PULL_REQUEST_TEMPLATE.md  # PR checklist
│   └── workflows/           # GitHub Actions (ACTIVE) 🟢
│       ├── time_clock.yml       # Heartbeat monitor (hourly)
│       ├── update_readme.yml    # README auto-updater
│       └── validate_waldiez.yml # Integrity checks
│
├── .gitlab/                 # GitLab integration
│   ├── ci/                  # Modular CI configuration
│   │   ├── base.yml         # Common setup, stages, anchors
│   │   ├── validate.yml     # Validation jobs
│   │   ├── heartbeat.yml    # time/clock heartbeat (ACTIVE) 🟢
│   │   └── update.yml       # README updates (ACTIVE) 🟢
│   ├── issue_templates/     # GitLab issue templates
│   │   ├── Bug.md
│   │   ├── Feature.md
│   │   └── Waldiez_Proposal.md
│   └── merge_request_templates/  # GitLab MR templates
│       └── Default.md
│
├── time/clock/              # First waldiez agent (ALIVE) 🟢
│   ├── .tic                 # Birth certificate (immutable) 🔒
│   ├── .toc                 # Timeline (AUTO-UPDATED) 🟢
│   ├── MANIFEST             # Agent specification (AUTO-UPDATED) 🟢
│   ├── README.md            # Human overview
│   └── PLAN.md              # Evolution plan
│
├── scripts/
│   ├── agents/time/clock/   # Automation logic
│   │   ├── time_clock_updater.sh    # Maintains time/clock
│   │   └── update_readme.sh         # Updates main README
│   ├── lib/                 # Shared utilities
│   │   ├── colors.sh        # Color output
│   │   ├── date_utils.sh    # Portable date functions
│   │   └── os_utils.sh      # OS detection, package management
│   ├── lint/                # Linting tools
│   │   ├── install_lint_deps.sh
│   │   ├── lint_bash.sh
│   │   ├── lint_markdown.sh
│   │   └── lint_yaml.sh
│   ├── validation/          # Immutability checks
│   │   ├── check_tic_immutable.sh
│   │   └── check_manifest_sections.sh
│   ├── lint.sh              # Main lint runner
│   ├── validate_ci.sh       # CI validation script
│   ├── clean_for_first_commit.sh
│   └── validate_first_commit_ready.sh
│
├── tests/                   # Test suite (100% coverage)
│   ├── unit/                # Unit tests (BATS)
│   ├── integration/         # Integration tests
│   ├── helpers/             # Test utilities
│   ├── fixtures/            # Test data
│   ├── install_test_deps.sh
│   ├── run_all_tests.sh
│   ├── coverage_report.sh
│   ├── post_test_cleanup.sh
│   └── pre-commit           # Git hook
│
├── schemas/                 # Schema definitions (future)
│   └── README.md            # Schema roadmap
│
└── docs/                    # Documentation
    ├── SPECIFICATION.md         # Complete Waldiez spec
    ├── WORKFLOW_GUIDE.md        # Step-by-step procedures
    ├── TESTING_GUIDE.md         # Testing requirements
    ├── MULTI_PLATFORM_SETUP.md  # GitHub + GitLab setup
    ├── PLATFORM_COMPARISON.md   # Platform differences
    └── WINDOWS_SETUP.md         # Windows (WSL2, Git Bash)
```

## Current Status

### ✅ Phase 1: Foundation (Complete)

<!-- markdownlint-disable MD036 -->
**Commits 1-3: Core Setup**

- [x] Commit 1: Initial (time/clock birth certificate)
- [x] Commit 2: Identity documentation (README, PLAN)
- [x] Commit 3: Automation logic and repository documentation

**Result:** Basic infrastructure in place, not yet operational

---

### ✅ Phase 2: Alpha Improvements (Complete)

**Multiple commits refining the foundation:**

- [x] Trailing whitespace fixes
- [x] Windows setup guide (WSL2, Git Bash)
- [x] Optional ontology support in specification
- [x] Test coverage improvements
- [x] Minor linting and typo fixes

**Result:** Windows support, semantic layer option, improved quality

---

### ✅ Phase 3: CI/CD Infrastructure (Complete)

**Templates and structure:**

- [x] GitHub issue templates (bug, feature, waldiez proposal)
- [x] GitHub PR template with checklist
- [x] GitLab issue templates (Bug, Feature, Waldiez Proposal)
- [x] GitLab MR template with checklist
- [x] Modular GitLab CI (base, validate, heartbeat, update)
- [x] CI validation script (validate_ci.sh)
- [x] Comprehensive test coverage

**Result:** CI structure ready for activation

---

### ✅ Phase 4: CI Activation (Complete)

**System goes live:**

- [x] GitHub Actions activated (hourly heartbeats)
- [x] GitLab CI activated (validation, updates)
- [x] First automatic heartbeat
- [x] First automatic README update

**Result:** System becomes AUTONOMOUS! 🚀

---

### 🟢 Phase 5: AUTONOMOUS OPERATION (CURRENT)

**System Status:** 🟢 **ALIVE!**

The time/clock waldiez is now operating autonomously:

- ✅ Hourly health checks running
- ✅ Daily ticks being recorded automatically
- ✅ README.md auto-updating with current status
- ✅ Validation running on every push/PR/MR
- ✅ Self-sustaining, self-documenting system

**What's happening automatically:**

- **Heartbeats:** Every 23+ hours (proof of life)
- **Ticks:** On day transitions (timeline records)
- **README updates:** After each heartbeat
- **Validation:** On all code changes

**Current metrics:**

- See main `README.md` for live status 🟢
- Check `time/clock/.toc` for complete timeline
- View `time/clock/MANIFEST` state section for health data

---

### 🎯 Phase 6: Future Development

**Now that the system is alive:**

- [ ] Monitor 72-hour validation period
- [ ] Verify autonomous operation stability
- [ ] Document patterns and lessons learned
- [ ] Design second waldiez (method, device, or workflow)
- [ ] Schema validation system (v0.2)
- [ ] Python tooling for waldiez creation
- [ ] Registry for waldiez discovery

**System demonstrates:**

- ✨ Self-sustaining operation
- 📚 Self-documenting behavior
- 🔄 Self-healing capabilities
- ✅ Immutability guarantees
- 🤖 True autonomy

---

## System Health Indicators

**🟢 Alive** — Heartbeat within 24 hours (healthy)  
**🟡 Stale** — Heartbeat 24-48 hours ago (warning)  
**🔴 Dead** — No heartbeat in 48+ hours (critical)

**Current Status:** Check `README.md` for real-time status!

## Quick Start

### Current System Status

**The time/clock waldiez is ALIVE and running autonomously!**

Check real-time status:

```bash
# See live status (auto-updated)
cat README.md

# View complete timeline
cat time/clock/.toc

# Check current state
yq eval '.state' time/clock/MANIFEST

# See recent commits (including automatic ones)
git log --oneline -10

# See bot commits only
git log --author="waldiez-bot" --oneline -10
```

### For Daily Monitoring

```bash
# Pull latest (includes automatic commits from CI)
git pull github main
# Or: git pull gitlab main

# Check health
cat README.md | grep "Status:"

# View heartbeat history
git log --oneline --grep="heartbeat" -10

# View tick history  
git log --oneline --grep="Tick" -10

# Check when last heartbeat occurred
git log --author="waldiez-bot" --oneline -1
```

### Making Your Own Changes

```bash
# Always pull first (to get automatic commits)
git pull github main

# Make your changes
git add <files>
git commit -m "your message"

# Run validation before pushing
./scripts/validate_ci.sh

# Push to both remotes
git push github main
git push gitlab main

# CI will validate and may add commits
```

## The Commit Journey

This repository followed a **multi-phase pattern** to bring `time/clock` to life:

### Phase 1: Foundation (Commits 1-3)

Human-driven setup:

- Identity declaration (.tic, MANIFEST)
- Documentation (README, PLAN)
- Automation logic (scripts, tests)

**Result:** Infrastructure ready, not yet operational

### Phase 2: Alpha Improvements (Commits 4-7+)

Refinements and enhancements:

- Windows support (WSL2, Git Bash)
- Optional ontology support (semantic layer)
- Linting, formatting, test coverage
- Quality improvements

**Result:** Production-ready foundation

### Phase 3: CI Infrastructure (Commits 8-9)

Templates and automation setup:

- Issue/PR/MR templates (structured contribution)
- Modular GitLab CI (maintainable structure)
- Validation scripts (quality gates)
- CI activation (system goes live)

**Result:** Automation infrastructure ready

### Phase 4: Autonomous Operation (Commits 10+) ✨

**System took over!** Automatic commits from CI:

- Heartbeat commits (proof of life)
- Tick commits (daily timeline)
- README updates (current status)

**Result:** Self-sustaining, self-documenting system

**Current state:** time/clock operates independently, proving its existence through time.

## Key Files to Understand

| File | Purpose | Who Modifies | Status |
| ---- | ------- | ------------ | ------ |
| `README.md` | Live project status | Automation only | 🟢 Auto-updating |
| `START_HERE.md` | Static documentation | Humans | 📝 Manual |
| `.tic` | Birth timestamp | NEVER | 🔒 Immutable |
| `.toc` | Daily timeline | Automation only | 🟢 Auto-updating |
| `MANIFEST` (identity) | Who/what is this | Humans (rarely) | 📝 Manual |
| `MANIFEST` (state) | Current condition | Automation only | 🟢 Auto-updating |
| `time/clock/README.md` | Human documentation | Humans | 📝 Manual |
| `PLAN.md` | Evolution strategy | Humans | 📝 Manual |
| `.github/workflows/` | GitHub Actions | Humans | 📝 Manual |
| `.gitlab/ci/` | GitLab CI modules | Humans | 📝 Manual |
| `scripts/validate_ci.sh` | CI validation | Humans | 📝 Manual |

## Monitoring the Autonomous System

### What to Watch

**GitHub Actions:**

- Navigate to: Repository → Actions tab
- Check: "time/clock health monitor" workflow
- Should run: Every hour
- Look for: Green checkmarks ✅

**GitLab CI:**

- Navigate to: Repository → CI/CD → Pipelines
- Check: Recent pipeline runs
- Should run: On every push + hourly schedule
- Look for: "passed" status

**Automatic Commits:**

```bash
# See all bot commits
git log --author="waldiez-bot" --oneline -20

# See heartbeat commits
git log --grep="heartbeat" --oneline -10

# See tick commits
git log --grep="Tick" --oneline -10

# See README update commits
git log --grep="Update README" --oneline -10
```

### Expected Behavior

**Every ~24 hours:**

1. Health check runs (CI detects 23+ hours since last heartbeat)
2. Heartbeat recorded (new commit to time/clock/MANIFEST)
3. If new day: Tick recorded (.toc file updated)
4. README.md updated (new commit with current status)

**Result:** 1-2 automatic commits per day

**Timeline example:**

```text
Day 1, 00:30 UTC: Heartbeat #1, Tick 2026-02-09, Update README
Day 2, 00:30 UTC: Heartbeat #2, Tick 2026-02-10, Update README
Day 3, 00:30 UTC: Heartbeat #3, Tick 2026-02-11, Update README
```

### Validation Commands

```bash
# Check .tic hasn't changed (should never change)
bash scripts/validation/check_tic_immutable.sh

# Check MANIFEST sections are valid
bash scripts/validation/check_manifest_sections.sh

# Validate CI configuration
bash scripts/validate_ci.sh

# Run full test suite
./tests/run_all_tests.sh

# Run linting
./scripts/lint.sh

# View git log with graph
git log --oneline --decorate --graph --all -20
```

### Troubleshooting

**If no heartbeat in 48+ hours (🔴 Dead status):**

1. Check CI is enabled:
   - GitHub: Actions tab → Ensure workflows enabled
   - GitLab: CI/CD → Pipelines → Check schedules active

2. Check workflow files exist:

   ```bash
   ls -la .github/workflows/
   ls -la .gitlab/ci/
   ```

3. Check for errors in workflow runs:
   - GitHub: Actions tab → Click failed run
   - GitLab: CI/CD → Pipelines → Click failed pipeline

4. Check CI permissions:
   - GitHub: Settings → Actions → Workflow permissions
   - GitLab: Settings → CI/CD → Variables (check tokens)

5. Manually trigger:
   - GitHub: Actions → time/clock health monitor → Run workflow
   - GitLab: CI/CD → Pipelines → Run pipeline

**If README.md not updating:**

1. Check if update_readme.yml workflow exists and is enabled
2. Verify it runs after time_clock.yml (workflow_run dependency)
3. Check for merge conflicts in README.md
4. Pull latest: `git pull github main`
5. Check workflow run logs for errors

**If validation failing:**

1. Run validation locally:

   ```bash
   ./scripts/validate_ci.sh
   ```

2. Check which validation failed
3. Fix the issue
4. Commit and push

## Health Check Behavior

The `time/clock` waldiez uses **heartbeat-driven health monitoring**:

- CI checks **every hour** if heartbeat needed
- If ≥23 hours since last heartbeat → trigger update
- Updates record both **heartbeat** (proof of life) and **tick** (new day if applicable)
- No unnecessary commits (idempotent)
- **After each heartbeat**, CI updates the main `README.md` with current stats

**Heartbeat logic:**

```bash
# Check time since last heartbeat
last_heartbeat=$(yq eval '.state.last_heartbeat' time/clock/MANIFEST)
hours_since=$(( ($(date +%s) - $(date -d "$last_heartbeat" +%s)) / 3600 ))

# If 23+ hours, trigger update
if (( hours_since >= 23 )); then
  # Run updater
  bash scripts/agents/time/clock/time_clock_updater.sh time/clock
  
  # Commit changes
  git commit -m "chore(time/clock): Heartbeat at $(date -u)"
  git push
fi
```

## The Living README

The main `README.md` file demonstrates the waldiez concept by being **self-updating**:

```markdown
# Waldiez Xperiens

**Days since first commit:** 5  
**Last heartbeat:** 2026-02-11T00:30:15Z  
**Heartbeat count:** 42  
**Status:** 🟢 Alive

[→ START HERE](START_HERE.md) for complete guide.
```

**This demonstrates that:**

- The project itself is a waldiez
- Documentation can be living and self-updating
- Automation maintains consistency across the ecosystem
- System proves its existence through time

---

## 🎉 Milestone: System is Alive

**Achievement unlocked:** The time/clock waldiez operates autonomously!

**What this means:**

- ✨ First self-sustaining waldiez
- 🤖 Proves concept works in practice
- 📚 Self-documenting system
- 🔄 Self-healing capabilities
- ⏱️ Proves existence through time
- 🌍 Dual-hosted (GitHub + GitLab)

**What we built:**

A system that:

- Records its own heartbeat every day
- Updates its own documentation automatically
- Validates its own integrity on changes
- Runs forever (or until explicitly stopped)
- Maintains dual presence across platforms

**Why this matters:**

This is **proof of concept** for the Waldiez philosophy:

- Entities that prove existence through operation
- Self-sustaining, autonomous agents
- Human/automation boundary is clear
- Immutability where needed, evolution where valuable
- Git as the single source of truth

**Next steps:**

- ✅ Monitor 72-hour validation period
- ✅ Verify stability and reliability
- ✅ Document patterns and lessons learned
- 🎯 Design additional waldiez types
- 🎯 Build tooling ecosystem
- 🎯 Create waldiez registry/discovery

**This is just the beginning!** 🌟

---

## Next Steps

### For You

1. **Monitor the system:**
   - Watch for automatic commits
   - Check README.md updates
   - Verify heartbeats are regular

2. **Complete validation period:**
   - 72 hours of stable operation
   - No manual intervention needed
   - All automatic processes working

3. **Design next waldiez:**
   - Choose type (method, device, workflow, etc.)
   - Plan identity and interface
   - Design automation strategy
   - Document in PLAN.md

4. **Build tooling:**
   - Python library for waldiez creation
   - Schema validation (v0.2)
   - CLI tools for management
   - Registry for discovery

### For the System

**Automatic processes:**

- ✅ Hourly health checks (CI)
- ✅ Daily ticks (automatic)
- ✅ README updates (automatic)
- ✅ Validation on changes (automatic)

**No human action needed!** The system runs itself. 🤖

## Questions or Issues?

- See `docs/WORKFLOW_GUIDE.md` for detailed procedures
- See `docs/SPECIFICATION.md` for formal definitions
- See `docs/TESTING_GUIDE.md` for testing requirements
- See `docs/MULTI_PLATFORM_SETUP.md` for GitHub + GitLab setup
- See `docs/WINDOWS_SETUP.md` for Windows environments
- Check `time/clock/PLAN.md` for evolution roadmap

## Contributing

**Before contributing:**

1. Read `docs/SPECIFICATION.md` (understand waldiez concepts)
2. Use issue templates (structured proposals)
3. Run validation: `./scripts/validate_ci.sh`
4. Run tests: `./tests/run_all_tests.sh`
5. Follow PR/MR template checklist

**Issue templates available:**

- Bug report (something broken)
- Feature request (enhancement)
- Waldiez proposal (new waldiez type)

**Pull/Merge request process:**

1. Create branch from `main`
2. Make changes, commit
3. Run validation locally
4. Push and create PR/MR
5. Wait for CI validation
6. Address review comments
7. Merge when approved

---

**This is a living document.** The main README.md changes automatically.  
**Last manual update:** 2026-02-09  
**Waldiez version:** v0.1-alpha  
**System status:** 🟢 Alive and autonomous
