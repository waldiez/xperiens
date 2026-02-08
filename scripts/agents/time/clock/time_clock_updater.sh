#!/usr/bin/env bash

# Maintains .toc timeline and MANIFEST state for time/clock waldiez
# Usage: time_clock_updater.sh <waldiez_dir>
# This script is idempotent - safe to run multiple times per day

set -euo pipefail

# Get script directory to source libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/date_utils.sh"

WALDIEZ_DIR="${1:?Error: waldiez directory required}"
cd "$WALDIEZ_DIR"

echo "=== time/clock updater ==="
echo "Working directory: $(pwd)"

# Validate required files
[[ -f .tic ]] || { echo "Error: .tic not found"; exit 1; }
[[ -f MANIFEST ]] || { echo "Error: MANIFEST not found"; exit 1; }

# Read birth timestamp
BIRTH=$(cat .tic)
BIRTH_DATE=$(iso_to_date "$BIRTH")
echo "Birth: $BIRTH (date: $BIRTH_DATE)"

# Initialize .toc if missing
if [[ ! -f .toc ]]; then
  echo "Initializing .toc with birth date: $BIRTH_DATE"
  echo "$BIRTH_DATE" > .toc
fi

# Get current UTC date and time
CURRENT_DATE=$(current_utc_date)
CURRENT_TIMESTAMP=$(current_utc_timestamp)
echo "Current: $CURRENT_TIMESTAMP (date: $CURRENT_DATE)"

# Read last tick from .toc
LAST_TICK=$(tail -n1 .toc | tr -d '\r' | cut -c1-10)
echo "Last tick: $LAST_TICK"

# Determine if we need to append to .toc
NEEDS_TICK=false
if [[ "$CURRENT_DATE" > "$LAST_TICK" ]]; then
  NEEDS_TICK=true
  echo "New day detected! Will backfill from $LAST_TICK to $CURRENT_DATE"
  
  # Backfill any missed dates (inclusive)
  NEXT_DATE=$(next_day "$LAST_TICK")
  until [[ "$NEXT_DATE" > "$CURRENT_DATE" ]]; do
    echo "  Appending: $NEXT_DATE"
    echo "$NEXT_DATE" >> .toc
    NEXT_DATE=$(next_day "$NEXT_DATE")
  done
else
  echo "Same day as last tick, no new tick needed"
fi

# Calculate total ticks from .toc (source of truth)
TOTAL_TICKS=$(wc -l < .toc | tr -d ' ')
echo "Total ticks (from .toc): $TOTAL_TICKS"

# Check if state section exists in MANIFEST
if yq eval '.state' MANIFEST &>/dev/null && [[ "$(yq eval '.state' MANIFEST)" != "null" ]]; then
  # State exists, update it
  CURRENT_HEARTBEAT_COUNT=$(yq eval '.state.heartbeat_count // 0' MANIFEST)
  NEW_HEARTBEAT_COUNT=$((CURRENT_HEARTBEAT_COUNT + 1))
  echo "Updating existing state (heartbeat #$NEW_HEARTBEAT_COUNT)"
  
  yq eval -i "
    .state.last_heartbeat = \"$CURRENT_TIMESTAMP\" |
    .state.heartbeat_count = $NEW_HEARTBEAT_COUNT |
    .state.last_tick = \"$CURRENT_DATE\" |
    .state.total_ticks = $TOTAL_TICKS |
    .state.last_updated = \"$CURRENT_TIMESTAMP\"
  " MANIFEST
else
  # First run - create state section
  echo "Creating state section (first heartbeat)"
  
  yq eval -i "
    .state = {} |
    .state.last_heartbeat = \"$CURRENT_TIMESTAMP\" |
    .state.heartbeat_count = 1 |
    .state.last_tick = \"$CURRENT_DATE\" |
    .state.total_ticks = $TOTAL_TICKS |
    .state.last_updated = \"$CURRENT_TIMESTAMP\"
  " MANIFEST
fi

# Verify state matches .toc
MANIFEST_TICKS=$(yq eval '.state.total_ticks' MANIFEST)
if [[ "$MANIFEST_TICKS" != "$TOTAL_TICKS" ]]; then
  echo "⚠️  WARNING: State drift corrected"
  echo "   MANIFEST claimed: $MANIFEST_TICKS, .toc has: $TOTAL_TICKS"
fi

# Add modification comment to MANIFEST
HEARTBEAT_COUNT=$(yq eval '.state.heartbeat_count' MANIFEST)
COMMENT="Last modified by: waldiez-bot @ $CURRENT_TIMESTAMP "

# Update the mutable section comment (sed to preserve structure)
if grep -q "Last modified by:" MANIFEST; then
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/# │ Last modified by:.*/# │ $COMMENT/" MANIFEST
  else
    sed -i "s/# │ Last modified by:.*/# │ $COMMENT/" MANIFEST
  fi
fi

if [[ "$NEEDS_TICK" == "true" ]]; then
  echo "✓ Tick recorded: $CURRENT_DATE"
  echo "✓ Heartbeat #$HEARTBEAT_COUNT recorded"
else
  echo "✓ Heartbeat #$HEARTBEAT_COUNT recorded (no new tick)"
fi

echo "=== Update complete ==="
