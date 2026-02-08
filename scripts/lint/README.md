# Linting System

Comprehensive linting for Waldiez Xperiens repository.

## Quick Start

Install all linting tools at once:

```bash
chmod +x scripts/lint/install_lint_deps.sh
./scripts/lint/install_lint_deps.sh
```

Supports macOS and Linux. Falls back to manual instructions if needed.

```bash
# Lint everything
./scripts/lint.sh

# Lint specific file types
./scripts/lint.sh --bash       # Bash scripts only
./scripts/lint.sh --yaml       # YAML files only
./scripts/lint.sh --markdown   # Markdown files only

# Multiple types
./scripts/lint.sh --bash --yaml
```

## Installation

### All Tools (Recommended)

```bash
# macOS
brew install shellcheck yamllint
npm install -g markdownlint-cli

# Ubuntu/Debian
sudo apt-get install shellcheck yamllint
npm install -g markdownlint-cli

# Using pip (for yamllint)
pip install yamllint --break-system-packages
```

### Individual Tools

**shellcheck** (Bash linting):

```bash
# macOS
brew install shellcheck

# Ubuntu
sudo apt-get install shellcheck

# From source
https://github.com/koalaman/shellcheck#installing
```

**yamllint** (YAML linting):

```bash
# macOS
brew install yamllint

# Ubuntu
sudo apt-get install yamllint

# pip
pip install yamllint --break-system-packages
```

**markdownlint** (Markdown linting):

```bash
# Requires Node.js and npm
npm install -g markdownlint-cli
```

## What Gets Linted

### Bash Scripts (`lint_bash.sh`)

- **Tool:** shellcheck
- **Files:** All `.sh` files in `scripts/` and `tests/`
- **Checks:** Syntax errors, common mistakes, best practices
- **Excludes:** SC1091 (sourced files - handled separately)

### YAML Files (`lint_yaml.sh`)

- **Tool:** yamllint
- **Files:** All `.yml` and `.yaml` files (except `.git/`, `node_modules/`)
- **Checks:** Syntax, indentation, line length
- **Config:** `.yamllint` (auto-created)

### Markdown Files (`lint_markdown.sh`)

- **Tool:** markdownlint-cli
- **Files:** All `.md` files (except `.git/`, `node_modules/`, `.local/`)
- **Checks:** Formatting, heading structure, link validity
- **Config:** `.markdownlint.json` (auto-created)

## Configuration Files

### `.yamllint`

```yaml
---
extends: default

rules:
  line-length:
    max: 120
    level: warning
  indentation:
    spaces: 2
```

Auto-created on first run.

### `.markdownlint.json`

```json
{
  "default": true,
  "MD013": {
    "line_length": 120
  }
}
```

Auto-created on first run.

## Exit Codes

- `0` - All linters passed
- `1` - One or more linters failed with errors
- Warnings don't cause failure (except in strict mode)

## Integration

### Pre-Commit Hook

Add to `.git/hooks/pre-commit`:

```bash
#!/usr/bin/env bash
echo "Running linters..."
./scripts/lint.sh
```

### CI/CD

Add to GitHub Actions or GitLab CI:

```yaml
- name: Lint
  run: ./scripts/lint.sh
```

## Individual Linter Scripts

Located in `scripts/lint/`:

- `lint_bash.sh` - Bash script linter
- `lint_yaml.sh` - YAML file linter
- `lint_markdown.sh` - Markdown file linter

Can be run directly:

```bash
bash scripts/lint/lint_bash.sh
bash scripts/lint/lint_yaml.sh
bash scripts/lint/lint_markdown.sh
```

## Troubleshooting

### "command not found"

Install the missing tool (see Installation section).

### "Too many warnings"

Edit the config files (`.yamllint`, `.markdownlint.json`) to adjust rules.

### "False positive"

Add inline disable comments:

**Bash:**

```bash
# shellcheck disable=SC2086
echo $var
```

**YAML:**

```yaml
# yamllint disable-line rule:line-length
very_long_line: value
```

**Markdown:**

```markdown
<!-- markdownlint-disable MD013 -->
Very long line here
<!-- markdownlint-enable MD013 -->
```

## Future Additions

Planned linters:

- Rust (clippy)
- Python (ruff, pylint, black, mypy)
- JavaScript/TypeScript (eslint, prettier)
- JSON (jsonlint)
- Dockerfile (hadolint)

---

**Last updated:** 2026-02-08
