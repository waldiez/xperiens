#!/usr/bin/env bats

setup() {
  TMP_BIN=$(mktemp -d)
  cat > "$TMP_BIN/markdownlint" <<'EOF2'
#!/usr/bin/env bash
if [[ "$1" == "--version" ]]; then
  echo "0.0.0"
  exit 0
fi
exit 0
EOF2
  chmod +x "$TMP_BIN/markdownlint"
}

teardown() {
  rm -rf "$TMP_BIN"
}

@test "lint_markdown: passes when markdownlint is available" {
  PATH="$TMP_BIN:$PATH" run bash scripts/lint/lint_markdown.sh
  [ "$status" -eq 0 ]
  [[ "$output" =~ "All markdown files passed linting" ]]
}
