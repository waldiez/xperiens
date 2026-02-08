# Waldiez Xperiens - Complete Guide

👋 Welcome! This directory contains the **reference implementation** of the Waldiez Xperiens.

> **Note:** The main `README.md` is dynamically updated by automation.  
> This file (`START_HERE.md`) contains more details.

## What Is This?

The Waldiez Xperiens demonstrates:

- How to create a waldiez agent from scratch
- The human/automation boundary
- Heartbeat-driven health monitoring
- Immutability guarantees
- The complete lifecycle from initial commit to autonomous operation

## Directory Structure

At the time of writing:

```text
~/Projects/waldiez/xperiens/
├── .gitignore               # Git exclusions
├── .gitlab-ci.yml           # GitLab CI configuration
├── README.md                # Dynamic status (updated by CI)
├── START_HERE.md            # This file (static guide)
├── QUICKSTART.md            # Quick start guide
├── LAUNCH.md                # Launch checklist
│
├── .github/workflows/       # GitHub Actions CI
│   ├── time_clock.yml       # Heartbeat monitor
│   ├── update_readme.yml    # Updates main README.md
│   └── validate_waldiez.yml # Integrity checks
│
├── time/clock/              # First waldiez agent
│   ├── .tic                 # Birth certificate (immutable)
│   ├── .toc                 # Timeline (append-only, created by CI)
│   ├── MANIFEST             # Agent specification
│   ├── README.md            # Human overview
│   └── PLAN.md              # Evolution plan
│
├── scripts/
│   ├── agents/time/clock   # Automation logic
│   │   ├── time_clock_updater.sh
│   │   └── update_readme.sh
│   ├── lib/                 # Shared utilities
│   │   ├── colors.sh
│   │   ├── date_utils.sh
│   │   └── os_utils.sh
│   ├── lint                 # Lint contents
│   │   ├── README.md
│   │   ├── install_lint_deps.sh
│   │   ├── lint_bash.sh
│   │   ├── lint_markdown.sh
│   │   └── lint_yaml.sh
│   ├── lint.sh
│   ├── validation/          # Immutability checks
│   │   ├── check_tic_immutable.sh
│   │   └── check_manifest_sections.sh
│   ├── clean_for_first_commit.sh
│   └── validate_first_commit_ready.sh
│
├── tests/                   # Test suite
│   ├── unit/                # Unit tests
│   ├── integration/         # Integration tests
│   ├── helpers/             # Test utilities
│   ├── fixtures/            # Test data
│   ├── install_test_deps.sh
│   ├── run_all_tests.sh
│   ├── coverage_report.sh
│   ├── post_test_cleanup.sh
│   └── pre-commit           # Git hook
│
├── schemas/
│   └── README.md            # Schema roadmap and status
│
└── docs/
    ├── SPECIFICATION.md         # Complete Waldiez spec
    ├── WORKFLOW_GUIDE.md        # Step-by-step procedures
    ├── TESTING_GUIDE.md         # Testing requirements
    ├── MULTI_PLATFORM_SETUP.md  # GitHub + GitLab setup
    └── PLATFORM_COMPARISON.md   # Platform differences
```

## Quick Start

### For Me (Human)

**First time setup:**

```bash
mkdir -p ~/Projects/waldiez/xperiens
cd ~/Projects/waldiez/xperiens

# Initialize git (if not already)
git init --initial-branch=main 2> /dev/null || true

# When ready, perform initial commit
git add time/clock/.tic time/clock/MANIFEST
git commit -m "initial: time/clock"
```

**Daily workflow:**

```bash
# Check project status
cat README.md

# Check clock status
cat time/clock/MANIFEST | grep -A 5 "state:"

# View timeline
cat time/clock/.toc

# Manually trigger health check (testing)
bash scripts/agents/time/clock/time_clock_updater.sh time/clock
```

### For You

When working with this directory:

1. **Read the spec first:** `docs/SPECIFICATION.md`
2. **Check current state:** Always view `.toc` and `MANIFEST` state
3. **Respect boundaries:** Never modify `.tic` or MANIFEST identity sections
4. **Test scripts locally:** Run updater script before committing
5. **Validate changes:** Run validation scripts after any modifications
6. **Update README.md:** Never edit directly; it's managed by automation

## The Six Commits

This repository follows a **canonical 6-commit pattern** to bring `time/clock` to life:

### Commit 1: Initial (Human) ⏳

```bash
git add time/clock/.tic time/clock/MANIFEST
git commit -m "initial: time/clock"
```

**Status:** Identity declared, no state yet

### Commit 2: Identity Documentation (Human) ⏳

```bash
git add time/clock/README.md time/clock/PLAN.md
git commit -m "docs(time/clock): Add README and PLAN"
```

**Status:** Documented but not operational

### Commit 3: Automation Logic and Repository Documentation (Human) ⏳

```bash
git add scripts/ docs/ schemas/ tests/
git add START_HERE.md SECURITY.md README.md QUICKSTART.md NOTICE.md LICENSE LAUNCH.md
git add .markdownlint.json .yamllint.yaml .pre-commit-config.yaml .gitignore .gitattributes
```

**Status:** Logic defined but not activated

### Commit 4: CI Configuration (Human) ⏳

```bash
git add .github/workflows/ scripts/validation/
git commit -m "ci(time/clock): Add health monitor and validation"
```

**Status:** Activated, waiting for first heartbeat

### Commit 5: First Heartbeat (Automation) ⏳

<!-- markdownlint-disable = MD036 -->
**Triggered by CI, not human**

```text
chore(time/clock): Tick 2026-02-XX (heartbeat #1)
```

**Status:** ALIVE! Fully autonomous operation begins

### Commit 6: First README Update (Automation) ⏳

```text
chore: Update README.md with current status
```

**Status:** Project README shows live stats

## Current Status

- [x] Sandbox created
- [x] Commit 1: Initial
- [x] Commit 2: Identity documentation
- [x] Commit 2.5a: Formatting
- [x] Commit 3: Automation logic and repository documentation
- [ ] Commit 4: CI configuration
- [ ] Commit 5: First heartbeat (CI)
- [ ] Commit 6: First README update (CI)
- [ ] 72-hour validation period

## Key Files to Understand

| File | Purpose | Who Modifies |
| ---- | ------- | ------------ |
| `README.md` | Live project status | Automation only |
| `START_HERE.md` | Static documentation | Humans |
| `.tic` | Birth timestamp | NEVER (immutable) |
| `.toc` | Daily timeline | Automation only |
| `MANIFEST` (identity) | Who/what is this | Humans (rarely) |
| `MANIFEST` (state) | Current condition | Automation only |
| `time/clock/README.md` | Human documentation | Humans |
| `PLAN.md` | Evolution strategy | Humans |

## Validation Commands

```bash
# Check .tic hasn't changed
bash scripts/validation/check_tic_immutable.sh

# Check MANIFEST sections
bash scripts/validation/check_manifest_sections.sh

# Run updater (dry run)
bash scripts/agents/time/clock/time_clock_updater.sh time/clock

# View git log
git log --oneline --decorate --graph
```

## Health Check Behavior

The `time/clock` waldiez uses **heartbeat-driven health monitoring**:

- CI checks **every hour** if heartbeat needed
- If >=23 hours since last heartbeat → trigger update
- Updates record both **heartbeat** (proof of life) and **tick** (new day if applicable)
- No unnecessary commits (idempotent)
- **After each heartbeat**, CI updates the main `README.md` with current stats

**Example timeline:**

```text
Day 1, 00:30 UTC: Heartbeat #1, Tick 2026-02-07, Update README
Day 1, 14:00 UTC: Heartbeat #2 (opportunistic, on push), Update README
Day 2, 00:30 UTC: Heartbeat #3, Tick 2026-02-08, Update README
Day 3, 00:30 UTC: Heartbeat #4, Tick 2026-02-09, Update README
```

## The Living README

The main `README.md` file demonstrates the waldiez concept by being **self-updating**:

```markdown
# Waldiez Xperiens

**Days since first commit:** 3  
**Last heartbeat:** 2026-02-09T00:30:15Z  
**Status:** 🟢 Alive

[→ START HERE](START_HERE.md).
```

**Status indicators:**

- 🟢 **Alive** — Heartbeat within 24 hours
- 🟡 **Stale** — Heartbeat 24-48 hours ago
- 🔴 **Dead** — No heartbeat in 48+ hours
- 🔵 **Awaiting first commit** — Not yet initialized

This demonstrates that:

- The project itself is a waldiez
- Documentation can be living and self-updating
- Automation maintains consistency across the ecosystem

## Next Steps

1. **Complete all initial commits** (see checklist above)
2. **Wait 72 hours** for autonomous operation validation
3. **Watch README.md update itself** with each heartbeat
4. **Design second waldiez** (method, device, or workflow)

## Questions or Issues?

- See `docs/WORKFLOW_GUIDE.md` for detailed procedures
- See `docs/SPECIFICATION.md` for formal definitions
- See `docs/TESTING_GUIDE.md` for testing requirements
- See `docs/MULTI_PLATFORM_SETUP.md` for GitHub + GitLab setup
- Check `time/clock/PLAN.md` for evolution roadmap

---

**This is a living document.** The main README.md changes automatically.  
**Last manual update:** 2026-02-08  
**Waldiez version:** v0.1-alpha
