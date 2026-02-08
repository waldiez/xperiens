#!/usr/bin/env bats

@test "colors: exports expected color variables" {
  # shellcheck disable=SC1091
  source scripts/lib/colors.sh

  [ -n "${RED:-}" ]
  [ -n "${GREEN:-}" ]
  [ -n "${YELLOW:-}" ]
  [ -n "${BLUE:-}" ]
  [ -n "${NC:-}" ]
}
