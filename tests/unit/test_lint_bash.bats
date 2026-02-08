#!/usr/bin/env bats

setup() {
  TMP_BIN=$(mktemp -d)
  cat > "$TMP_BIN/shellcheck" <<'EOF2'
#!/usr/bin/env bash
if [[ "$1" == "--version" ]]; then
  echo "ShellCheck - shell script analysis tool"
  echo "version: 0.0.0"
  exit 0
fi
exit 0
EOF2
  chmod +x "$TMP_BIN/shellcheck"
}

teardown() {
  rm -rf "$TMP_BIN"
}

@test "lint_bash: passes when shellcheck is available" {
  PATH="$TMP_BIN:$PATH" run bash scripts/lint/lint_bash.sh
  [ "$status" -eq 0 ]
  [[ "$output" =~ "All bash scripts passed linting" ]]
}
