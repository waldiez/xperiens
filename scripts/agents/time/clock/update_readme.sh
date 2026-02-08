#!/usr/bin/env bash
set -euo pipefail

# README updater script
# Updates the main README.md with current status from time/clock
#
# Usage: update_readme.sh
#
# Reads from: time/clock/MANIFEST, time/clock/.toc
# Writes to: README.md

# Get script directory to source libraries
SCRIPT_DIR="$(cd "$(dirname "$0")/../../../" && pwd -P)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/date_utils.sh"

CLOCK_DIR="time/clock"
README="README.md"

echo "=== README updater ==="

# Check if clock exists
if [[ ! -f "$CLOCK_DIR/.tic" ]] || [[ ! -f "$CLOCK_DIR/MANIFEST" ]]; then
  echo "Clock not initialized yet, keeping default README"
  exit 0
fi

# Read birth date from .tic
BIRTH=$(cat "$CLOCK_DIR/.tic")
BIRTH_DATE=$(iso_to_date "$BIRTH")
echo "Clock birth: $BIRTH_DATE"

# Count days from .toc (if exists)
if [[ -f "$CLOCK_DIR/.toc" ]]; then
  DAYS=$(wc -l < "$CLOCK_DIR/.toc" | tr -d ' ')
  echo "Days since first commit: $DAYS"
else
  DAYS=0
  echo "No .toc yet (first heartbeat pending)"
fi

# Read last heartbeat from MANIFEST (if exists)
if yq eval '.state.last_heartbeat' "$CLOCK_DIR/MANIFEST" &>/dev/null; then
  LAST_HEARTBEAT=$(yq eval -r '.state.last_heartbeat // ""' "$CLOCK_DIR/MANIFEST" 2>/dev/null || true)
  if [[ -n "$LAST_HEARTBEAT" ]]; then

    # Calculate hours since heartbeat
    LAST_EPOCH=$(date_to_epoch "$LAST_HEARTBEAT")
    NOW_EPOCH=$(date +%s)
    # shellcheck disable=SC2004
    HOURS_SINCE=$(( ($NOW_EPOCH - $LAST_EPOCH) / 3600 ))
    
    echo "Last heartbeat: $LAST_HEARTBEAT ($HOURS_SINCE hours ago)"
    
    # Determine status emoji
    if (( HOURS_SINCE < 24 )); then
      STATUS="🟢 Alive"
    elif (( HOURS_SINCE < 48 )); then
      STATUS="🟡 Stale"
    else
      STATUS="🔴 Dead"
    fi
  else
    LAST_HEARTBEAT="Not yet initialized"
    STATUS="🔵 Awaiting first commit"
    echo "No state yet (first commit pending)"
  fi
else
  LAST_HEARTBEAT="Not yet initialized"
  STATUS="🔵 Awaiting first commit"
  echo "No state yet (first commit pending)"
fi

echo "Status: $STATUS"

# Generate new README content
cat > "$README" <<EOF
# Waldiez Xperiens

**Days since first commit:** $DAYS  
**Last heartbeat:** $LAST_HEARTBEAT  
**Status:** $STATUS

[→ START HERE](START_HERE.md).

---

*This README is automatically maintained. See \`time/clock/MANIFEST\` for details.*
EOF

echo "✓ README.md updated"
