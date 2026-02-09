<!-- markdownlint-disable = MD036 -->
# Multi-Platform Git Setup

This guide helps you set up the repository to push to **both GitHub and GitLab** simultaneously.

---

## Quick Setup

### 1. Create Repositories

**GitHub:**

```bash
# Using GitHub CLI
gh repo create waldiez/xperiens --public

# Or manually at: https://github.com/organizations/waldiez/repositories/new
```

**GitLab:**

```bash
# Using GitLab CLI (if installed)
glab repo create waldiez/xperiens --public

# Or manually at: https://gitlab.com/projects/new
```

---

### 2. Add Both Remotes

```bash
cd ~/Projects/waldiez/xperiens

# Add GitHub
git remote add github https://github.com/waldiez/xperiens.git

# Add GitLab
git remote add gitlab https://gitlab.com/waldiez/xperiens.git

# Verify
git remote -v
```

**Expected output:**

```text
github  https://github.com/waldiez/xperiens.git (fetch)
github  https://github.com/waldiez/xperiens.git (push)
gitlab  https://gitlab.com/waldiez/xperiens.git (fetch)
gitlab  https://gitlab.com/waldiez/xperiens.git (push)
```

---

### 3. Push to Both Platforms

**Method A: Push separately (recommended for control)**

```bash
git push github main
git push gitlab main
```

**Method B: Push to both at once (convenience)**

```bash
# Set origin to push to both
git remote set-url --add --push origin https://github.com/waldiez/xperiens.git
git remote set-url --add --push origin https://gitlab.com/waldiez/xperiens.git

# Now "git push" pushes to both
git push origin main
```

---

## CI/CD Configuration

### GitHub Actions

- ✅ Already configured in `.github/workflows/`
- Runs automatically once pushed to GitHub
- No additional setup needed (built-in)

### GitLab CI

- ✅ Already configured in `.gitlab-ci.yml`
- Requires **one-time setup** for bot access

#### GitLab CI Setup Steps

1. **Create Project Access Token**
   - Go to: Settings > Access Tokens
   - Name: `waldiez-bot-push-token`
   - Role: `Maintainer`
   - Scopes: `write_repository`
   - Click "Create project access token"
   - **Copy the token** (shown once)

2. **Add Token as CI/CD Variable**
   - Go to: Settings > CI/CD > Variables
   - Click "Add variable"
   - Key: `CI_PUSH_TOKEN`
   - Value: (paste token)
   - Protect: ✅ (optional, recommended)
   - Mask: ✅ (recommended)
   - Click "Add variable"

3. **Create Pipeline Schedule (for hourly heartbeat)**
   - Go to: Build -> Pipeline Schedules (or: CI/CD > Schedules)
   - Click "New schedule"
   - Description: `Hourly heartbeat check`
   - Interval pattern: Custom (`0 * * * *`) - every hour
   - Target branch: `main`
   - Click "Save pipeline schedule"

**That's it!** GitLab CI will now run hourly.

---

## Platform Differences

### GitHub Actions vs GitLab CI

| Feature | GitHub Actions | GitLab CI |
| ------- | ------------- | --------- |
| **Config location** | `.github/workflows/*.yml` | `.gitlab-ci.yml` |
| **Schedule syntax** | Cron in workflow file | Separate UI schedule + pipeline source check |
| **Bot auth** | Built-in `GITHUB_TOKEN` | Requires manual `CI_PUSH_TOKEN` setup |
| **Commit author** | Configured in workflow | Configured in job `before_script` |
| **Secrets** | Repository secrets | CI/CD variables |

### Platforms support

- ✅ Hourly schedules
- ✅ Manual triggers
- ✅ Push-based triggers
- ✅ Branch protection
- ✅ Required status checks

---

## Workflow Equivalence

### GitHub Actions → GitLab CI Mapping

| GitHub Workflow | GitLab Job | Purpose |
| -------------- | ---------- | ------- |
| `validate_waldiez.yml` | `validate:waldiez` | Pre-merge validation |
| `time_clock.yml` | `heartbeat:time/clock` | Hourly health check |
| `update_readme.yml` | `update:readme` | README auto-update |

---

## Daily Operations

### Pushing Changes

```bash
# After making changes
git add .
git commit -m "feat: Add something"

# Push to both platforms
git push github main
git push gitlab main
```

### Viewing CI Status

**GitHub:**

- Repository > Actions tab
- See all workflow runs

**GitLab:**

- Repository > CI/CD > Pipelines
- See all pipeline runs

### Checking Bot Commits

Both platforms use:

- Bot name: `waldiez-bot`
- Bot email: `bot@waldiez.io`

Bot commits will appear in git log on both platforms after CI runs.

---

## Keeping Platforms in Sync

### If Platforms Diverge

```bash
# Check status
git fetch github
git fetch gitlab

# Compare
git log github/main
git log gitlab/main

# If one is ahead, push to the other
git push gitlab github/main:main
# or
git push github gitlab/main:main
```

### Regular Sync Check

```bash
# Add to your daily routine
git fetch --all
git log --oneline --graph --all --decorate
```

---

## Troubleshooting

### GitHub Push Failed

**Error:** `remote: Permission denied`

**Fix:**

```bash
# Check authentication
gh auth status

# Re-authenticate if needed
gh auth login
```

### GitLab Push Failed

**Error:** `remote: You are not allowed to push code to this project`

**Fix:**

1. Verify `CI_PUSH_TOKEN` is set correctly
2. Verify token has `write_repository` scope
3. Verify token is not expired

### Schedule Not Running

**GitHub:**

- Verify cron syntax in workflow file
- Check Actions are enabled for repository

**GitLab:**

- Verify schedule exists in CI/CD > Schedules
- Verify schedule is active (not paused)
- Check pipeline source in job rules

---

## Migration from Single Platform

If you started with only GitHub or GitLab:

### From GitHub to Both

```bash
# Add GitLab remote
git remote add gitlab https://gitlab.com/waldiez/xperiens.git

# Push all branches and tags
git push gitlab --all
git push gitlab --tags

# Set up GitLab CI token (see above)
```

### From GitLab to Both

```bash
# Add GitHub remote
git remote add github https://github.com/waldiez/xperiens.git

# Push all branches and tags
git push github --all
git push github --tags

# GitHub Actions works immediately (no token setup)
```

---

## Best Practices

1. **Always push to both** platforms after changes
2. **Monitor both** CI dashboards initially
3. **Test manually** before relying on schedules
4. **Keep tokens secure** (never commit them)
5. **Document** which platform is "primary" for your workflow

---

## Future: Automatic Mirroring

**Option:** Set up automatic mirroring so one platform auto-syncs to the other.

**GitHub → GitLab:**

- GitLab: Settings > Repository > Mirroring repositories
- Add GitHub as source

**GitLab → GitHub:**

- Requires custom GitHub Action (more complex)

---

**Last updated:** 2026-02-07  
**For questions:** See WORKFLOW_GUIDE.md
