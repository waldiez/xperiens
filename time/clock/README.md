# time/clock

**WID:** `wdz://xperiens.waldiez.io/time/clock/v1`  
**Type:** Process  
**Status:** See `../../README.md` for live status

## Purpose

The `time/clock` waldiez represents the passage of UTC days, recorded through version-controlled commits.

It exists to:

- Prove the waldiez agent model
- Establish operational patterns for time-aware waldiez
- Serve as a canonical reference implementation
- Demonstrate heartbeat-driven health monitoring

## How It Works

### Identity

- **Created:** 2026-02-07T13:46:23Z (see `.tic`)
- **Immutable WID:** `wdz://xperiens.waldiez.io/time/clock/v1`

### Timeline (`.toc`)

- One line per UTC day experienced
- Append-only log of existence
- Source of truth for `total_ticks` count

### State (MANIFEST)

- `last_heartbeat`: Most recent proof of life
- `heartbeat_count`: Total proofs of life
- `last_tick`: Most recent UTC day recorded
- `total_ticks`: Total days experienced (matches `.toc` line count)

### Automation

- CI checks every hour: "Has it been ≥23 hours since last heartbeat?"
- If yes: Run updater script
- Script: Backfill missed days, update state, commit changes
- README.md updates automatically after each heartbeat

## Files

- `.tic` — Birth certificate (immutable)
- `.toc` — Timeline of UTC days (append-only)
- `MANIFEST` — Agent specification
- `README.md` — This file
- `PLAN.md` — Evolution roadmap

## Operations

### heartbeat

Prove existence by recording current timestamp.

**When:** Triggered by CI when ≥23 hours since last heartbeat  
**Effect:** Updates `last_heartbeat` and `heartbeat_count` in MANIFEST

### tick

Record current UTC day if new.

**When:** Automatically during heartbeat if new day detected  
**Effect:** Appends to `.toc`, updates `last_tick` and `total_ticks`

## Viewing Status

```bash
# Quick status
cat ../../README.md

# View timeline
cat .toc

# View current state
yq eval '.state' MANIFEST

# Time since last heartbeat
LAST=$(yq eval '.state.last_heartbeat' MANIFEST)
echo "Last heartbeat: $LAST"
```

## Evolution

See `PLAN.md` for:

- Lifecycle stages
- Rotation strategy for `.toc`
- Future enhancements
- Decommissioning plan

---

**This waldiez is autonomous.** Human intervention is not required for normal operation.
