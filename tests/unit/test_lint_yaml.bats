#!/usr/bin/env bats

setup() {
  TMP_BIN=$(mktemp -d)
  cat > "$TMP_BIN/yamllint" <<'EOF2'
#!/usr/bin/env bash
if [[ "$1" == "--version" ]]; then
  echo "yamllint 0.0.0"
  exit 0
fi
exit 0
EOF2
  chmod +x "$TMP_BIN/yamllint"
}

teardown() {
  rm -rf "$TMP_BIN"
}

@test "lint_yaml: passes when yamllint is available" {
  PATH="$TMP_BIN:$PATH" run bash scripts/lint/lint_yaml.sh
  [ "$status" -eq 0 ]
  [[ "$output" =~ "All YAML files passed linting" ]]
}
