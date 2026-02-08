<!-- markdownlint-disable = MD036 -->
# Platform Comparison: GitHub vs GitLab

Quick reference for understanding CI/CD differences between platforms.

## Configuration Files

| Platform | Location | Format |
| -------- | -------- | ------ |
| **GitHub** | `.github/workflows/*.yml` | One file per workflow |
| **GitLab** | `.gitlab-ci.yml` | Single file, multiple jobs |

## Authentication & Secrets

| Feature | GitHub | GitLab |
| ------- | ------ | ------ |
| **Bot push token** | Built-in `GITHUB_TOKEN` (automatic) | Manual `CI_PUSH_TOKEN` setup required |
| **Secrets location** | Settings > Secrets and variables > Actions | Settings > CI/CD > Variables |
| **Bot identity** | Configured in workflow yaml | Configured in job before_script |

## Scheduling

| Feature | GitHub | GitLab |
| ------- | ------ | ------ |
| **Cron syntax** | In workflow file (`schedule.cron`) | Separate UI (CI/CD > Schedules) |
| **Example** | `cron: '0 * * * *'` | Create schedule with `0 * * * *` pattern |
| **Pipeline source** | Automatic | Check `$CI_PIPELINE_SOURCE == "schedule"` |

## Workflow/Job Structure

### GitHub Actions Example

```yaml
name: My Workflow
on:
  schedule:
    - cron: '0 * * * *'
  workflow_dispatch:

jobs:
  my-job:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: echo "Hello"
```

### GitLab CI Equivalent

```yaml
my-job:
  stage: my-stage
  image: ubuntu:latest
  script:
    - echo "Hello"
  rules:
    - if: $CI_PIPELINE_SOURCE == "schedule"
    - if: $CI_PIPELINE_SOURCE == "web"
```

## Commit & Push in CI

### GitHub Actions

```yaml
- name: Commit changes
  run: |
    git config user.name "waldiez-bot"
    git config user.email "bot@waldiez.io"
    git add .
    git commit -m "Update"
    git push
```

Uses built-in `GITHUB_TOKEN` automatically.

### GitLab CI

```yaml
script:
  - git config --global user.name "waldiez-bot"
  - git config --global user.email "bot@waldiez.io"
  - git add .
  - git commit -m "Update"
  - git push https://oauth2:${CI_PUSH_TOKEN}@${CI_SERVER_HOST}/${CI_PROJECT_PATH}.git HEAD:${CI_COMMIT_REF_NAME}
```

Requires manual `CI_PUSH_TOKEN` setup.

## Conditional Execution

### Using GitHub Actions

```yaml
on:
  push:
    paths:
      - 'src/**'
      - 'tests/**'
```

### Using GitLab CI

```yaml
rules:
  - if: $CI_PIPELINE_SOURCE == "push"
    changes:
      - src/**
      - tests/**
```

## Manual Triggers

| Platform | Trigger Method | Access |
| -------- | ------------- | ------ |
| **GitHub** | `workflow_dispatch` in workflow | Actions tab > Select workflow > "Run workflow" |
| **GitLab** | `rules: if: $CI_PIPELINE_SOURCE == "web"` | CI/CD > Pipelines > "Run pipeline" |

## Job Dependencies

### With GitHub Actions

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps: [...]
  
  test:
    needs: build
    runs-on: ubuntu-latest
    steps: [...]
```

### With GitLab CI

```yaml
build:
  stage: build
  script: [...]

test:
  stage: test
  needs:
    - job: build
  script: [...]
```

## Artifacts & Caching

| Feature | GitHub Actions | GitLab CI |
| ------- | ------------- | --------- |
| **Upload artifact** | `actions/upload-artifact@v4` | `artifacts: paths:` |
| **Cache** | `actions/cache@v4` | `cache: paths:` |
| **Retention** | 90 days (default) | Configurable (default varies) |

## Matrix Builds

### On GitHub Actions

```yaml
strategy:
  matrix:
    os: [ubuntu-latest, macos-latest]
    node: [14, 16, 18]
```

### On GitLab CI

```yaml
parallel:
  matrix:
    - OS: ubuntu
      NODE: [14, 16, 18]
    - OS: macos
      NODE: [14, 16, 18]
```

## Environment Variables

| Type | GitHub | GitLab |
| ---- | ------ | ------ |
| **Built-in vars** | `GITHUB_*` | `CI_*` |
| **Custom secrets** | `${{ secrets.MY_SECRET }}` | `$MY_SECRET` |
| **Set in workflow** | `env:` at job/step level | `variables:` at global/job level |

## Status Badges

### GitHub

```markdown
![CI](https://github.com/waldiez/xperiens/workflows/CI/badge.svg)
```

### GitLab

```markdown
![pipeline](https://gitlab.com/waldiez/xperiens/badges/main/pipeline.svg)
```

## Cost & Limits

| Feature | GitHub Free | GitLab Free |
| ------- | ---------- | ----------- |
| **Public repos** | Unlimited minutes | Unlimited minutes |
| **Private repos** | 2,000 min/month | 400 min/month |
| **Storage** | 500 MB | 10 GB |
| **Concurrent jobs** | 20 | Auto-scaling |

## Pros & Cons for Waldiez

### GitHub Actions Part

**Pros:**

- ✅ No token setup needed (uses built-in `GITHUB_TOKEN`)
- ✅ More intuitive UI for beginners
- ✅ Better marketplace for reusable actions
- ✅ Widely adopted (more community examples)

**Cons:**

- ❌ Separate file per workflow (more files)
- ❌ Requires organization for team collaboration

### GitLab CI Part

**Pros:**

- ✅ Single file (`.gitlab-ci.yml`)
- ✅ More powerful rules/conditions
- ✅ Better built-in Docker support
- ✅ Free tier includes more features

**Cons:**

- ❌ Requires manual token setup for bot pushes
- ❌ Steeper learning curve
- ❌ Schedule UI is separate from config

## Which Platform for Waldiez?

**Recommendation: Use BOTH**

- Primary: GitHub (for visibility, community)
- Mirror: GitLab (for redundancy, features)
- Keep them in sync with multi-platform setup

---

**See also:** `docs/MULTI_PLATFORM_SETUP.md`
