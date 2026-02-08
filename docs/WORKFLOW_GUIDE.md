<!-- markdownlint-disable = MD036 -->
# Waldiez Workflow Guide

Step-by-step instructions for working with the Waldiez Experience repository.

## Prerequisites

**Required tools:**

- `git` (version control)
- `bash` (script execution)
- `yq` (YAML processing) - Install: `manager install yq`
- `bats` (Bash Automated Testing System) - Install: `manager install bats`
- Git account (for CI)

**Optional tools:**

- `jq` (JSON processing)
- Git CLI for easier repo setup

---

## Initial Setup

### 1. Verify Repository

```bash
cd ~/Projects/waldiez/xperiens

# Check git status
git status

# Verify tools
yq --version
bash --version
bats --version
```

### 2. Make Scripts Executable

```bash
# Make all scripts executable
chmod +x scripts/agents/*.sh
chmod +x scripts/lib/*.sh
chmod +x scripts/validation/*.sh

# Verify permissions
ls -l scripts/agents/
ls -l scripts/lib/
ls -l scripts/validation/
```

### 3. Create GitHub Repository (If Not Done)

**Option A: Using GitHub CLI**

```bash
gh repo create waldiez/xperiens --public --source=. --remote=origin
git push -u origin main
```

**Option B: Manual**

1. Go to <https://github.com/organizations/waldiez/repositories/new>
2. Create repository: `xperiens`
3. Connect local repo:

```bash
git remote add origin https://github.com/waldiez/xperiens.git
git branch -M main
git push -u origin main
```

---

## The Xperiens Ritual: Creating time/clock

Follow these steps **in order** to bring the first waldiez to life.

### Commit 1: Initial

**Objective:** Declare the waldiez's identity

**Steps:**

```bash
cd ~/Projects/waldiez/xperiens

# Verify .tic and MANIFEST exist
cat time/clock/.tic
cat time/clock/MANIFEST

# Stage and commit
git add time/clock/.tic time/clock/MANIFEST
git commit -m "initial: time/clock"
git push
```

**What to check:**

- `.tic` contains exactly one line (ISO-8601 timestamp)
- `MANIFEST` has identity and interface sections
- `MANIFEST` does NOT have state section yet (commented out)
- Commit message follows format: `initial: <waldiez-name>`

---

### Commit 2: Documentation

**Objective:** Explain what this waldiez does

**Steps:**

```bash
# Verify docs exist
cat time/clock/README.md
cat time/clock/PLAN.md

# Stage and commit
git add time/clock/README.md time/clock/PLAN.md
git commit -m "docs(time/clock): Add README and PLAN"
git push
```

---

### Commit 3: Automation Logic

**Objective:** Define how the waldiez maintains itself

**Steps:**

```bash
# Verify scripts AND dependencies exist
cat scripts/agents/time/clock/time_clock_updater.sh
cat scripts/agents/time/clock/update_readme.sh
cat scripts/lib/date_utils.sh

# Make executable (if not already)
chmod +x scripts/agents/*.sh
chmod +x scripts/lib/*.sh

# Test the updater (DRY RUN)
bash scripts/agents/time/clock/time_clock_updater.sh time/clock

# Check what changed
git status
cat time/clock/.toc
yq eval '.state' time/clock/MANIFEST

# IMPORTANT: Reset the test changes
git restore time/clock/.toc time/clock/MANIFEST

# Commit scripts WITH library dependencies
git add scripts/agents/ scripts/lib/
git commit -m "feat(agents): Add time/clock updater and README updater"
git push
```

**Critical:**

- Don't commit the `.toc` and state changes from testing - automation will create those
- MUST include `scripts/lib/` as agents depend on it

---

### Commit 4: CI Configuration

**Objective:** Activate automated health monitoring

**Steps:**

```bash
# Verify workflows exist
cat .github/workflows/time_clock.yml
cat .github/workflows/update_readme.yml
cat .github/workflows/validate_waldiez.yml

# Verify validation scripts
cat scripts/validation/check_tic_immutable.sh
cat scripts/validation/check_manifest_sections.sh

# Make validation scripts executable
chmod +x scripts/validation/*.sh

# Test validation locally
bash scripts/validation/check_tic_immutable.sh
bash scripts/validation/check_manifest_sections.sh

# Commit
git add .github/workflows/ scripts/validation/
git commit -m "ci(time/clock): Add health monitor and validation"
git push
```

**What to check:**

- GitHub Actions tab shows workflows registered
- Validation scripts run successfully locally

---

### Commit 5: First Heartbeat (AUTOMATIC)

**Objective:** Prove the waldiez is alive

**What happens:**

- Within 1 hour of Commit 4 push, CI will run
- CI checks: "Has it been ≥23 hours since last heartbeat?" (No state yet, so YES)
- CI runs updater script
- CI creates `.toc` and adds `state` section to `MANIFEST`
- CI commits changes

**Expected commit message:**

```text
chore(time/clock): Tick 2026-02-07 (heartbeat #1)
```

**What to check:**

```bash
# Pull the CI commit
git pull

# Verify .toc created
cat time/clock/.toc
# Should contain birth date

# Verify MANIFEST state added
yq eval '.state' time/clock/MANIFEST
# Should show last_heartbeat, heartbeat_count, last_tick, total_ticks

# Check commit author
git log -1 --format="%an <%ae>"
# Should be: (preferred) waldiez-bot (bot@waldiez.io) or github-actions[bot] or GitLab CI Bot
```

---

### Commit 6: First README Update (AUTOMATIC)

**Objective:** Project README reflects live status

**What happens:**

- After heartbeat commit, `update_readme.yml` workflow triggers
- Reads current state from `time/clock/MANIFEST`
- Updates main `README.md` with live stats
- Commits if changed

**Expected commit message:**

```text
chore: Update README.md with current status
```

**What to check:**

```bash
# Pull the update
git pull

# View updated README
cat README.md
# Should show:
# Days since first commit: 1
# Last heartbeat: 2026-02-07T...
# Status: 🟢 Alive
```

---

## Daily Operations

### Monitoring the Clock

```bash
# View timeline (all days)
cat time/clock/.toc

# View recent heartbeats
git log --oneline --grep="Heartbeat\|Tick" -10

# Check current state
yq eval '.state' time/clock/MANIFEST

# Calculate time since last heartbeat
LAST=$(yq eval '.state.last_heartbeat' time/clock/MANIFEST)
echo "Last heartbeat: $LAST"
HOURS_AGO=$(( ($(date +%s) - $(date -d "$LAST" +%s)) / 3600 ))
echo "Hours ago: $HOURS_AGO"
```

### Manual Health Check (Testing)

```bash
# Run updater manually
bash scripts/agents/time/clock/time_clock_updater.sh time/clock

# See what changed
git diff time/clock/

# If testing, commit
git add time/clock/
git commit -m "test(time/clock): Manual heartbeat for testing"
git push
```

**Note:** Manual commits will trigger CI to check again in 1 hour.

---

## Validation Procedures

### Before Every Push

```bash
# Run all validations
bash scripts/validation/check_tic_immutable.sh
bash scripts/validation/check_manifest_sections.sh

# If any fail, DO NOT PUSH
# Fix the issues first
```

### After CI Commits

```bash
# Pull latest
git pull

# Verify state integrity
TICKS=$(wc -l < time/clock/.toc | tr -d ' ')
MANIFEST_TICKS=$(yq eval '.state.total_ticks' time/clock/MANIFEST)

if [[ "$TICKS" != "$MANIFEST_TICKS" ]]; then
  echo "ERROR: State drift detected!"
  echo ".toc has $TICKS lines, MANIFEST claims $MANIFEST_TICKS"
else
  echo "✓ State is consistent"
fi
```

---

## Working with Agents

### When an Agent Should Use Scripts

An Agent should run scripts when:

- Testing changes before committing
- Verifying state integrity
- Demonstrating behavior

**Example:**

```bash
# Agent: Let me test the updater script
bash scripts/agents/time/clock/time_clock_updater.sh time/clock

# Agent: Here's what changed
git diff time/clock/
```

### When an Agent Should NOT Modify Files

An Agent should NEVER directly edit:

- `.tic` (immutable)
- `MANIFEST` identity section
- `.toc` (only via script)

An Agent CAN edit:

- README, PLAN, documentation
- Scripts (with human review)
- New waldiez agents

---

## Troubleshooting

### yq Command Not Found

**Install:**

```bash
# macOS
brew install yq

# Linux
sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
sudo chmod +x /usr/local/bin/yq
```

### Script Permission Denied

**Fix:**

```bash
chmod +x scripts/agents/*.sh
chmod +x scripts/lib/*.sh
chmod +x scripts/validation/*.sh
```

### CI Workflow Not Running

**Check:**

1. View GitHub Actions tab in repository
2. Check workflow file syntax
3. Verify workflows are on `main` branch
4. Check if Actions are enabled for repo

---

## Commit Message Conventions

### Human Commits

```text
initial: <waldiez-name>           # Identity declaration
docs(<waldiez>): <description>    # Documentation
feat(<scope>): <description>      # New features/scripts
ci(<waldiez>): <description>      # CI configuration
fix(<scope>): <description>       # Bug fixes
test(<waldiez>): <description>    # Testing changes
```

### Automation Commits

```text
chore(<waldiez>): Tick YYYY-MM-DD (heartbeat #N)        # New day recorded
chore(<waldiez>): Heartbeat at YYYY-MM-DD HH:MM:SS UTC  # Proof of life only
chore: Update README.md with current status             # README update
```

---

## Next Steps After Initial Commit

Once `time/clock` has run autonomously for 72 hours:

1. **Review the pattern**
   - What worked well?
   - What was confusing?
   - What should change?

2. **Design second waldiez**
   - Method (`.wid` format)
   - Device (external state)
   - Workflow (multi-step)
   - Composite (orchestration)

3. **Extract templates**
   - Generic updater script template
   - Generic CI workflow template
   - MANIFEST templates by type

4. **Document learnings**
   - Update SPECIFICATION.md
   - Create best practices guide
   - Write tutorial for others

---

**Last updated:** 2026-02-08
**For questions:** See START_HERE.md or time/clock/PLAN.md
