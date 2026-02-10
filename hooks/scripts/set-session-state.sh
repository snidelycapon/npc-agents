#!/usr/bin/env bash
# Set a state dimension on a bead using labels.
# Workaround for bd set-state which depends on the 'event' type (broken in bd 0.49.0).
#
# Usage: ./set-session-state.sh <bead-id> <dimension>=<value>
# Example: ./set-session-state.sh rpg-4d2 alignment=neutral-good
#
# This mirrors bd set-state behavior:
# 1. Finds any existing label with prefix "<dimension>:"
# 2. Removes it
# 3. Adds new label "<dimension>:<value>"
# bd state <id> <dimension> reads from these labels, so queries work unchanged.

set -euo pipefail

BEAD_ID="$1"
PAIR="$2"

DIMENSION="${PAIR%%=*}"
VALUE="${PAIR#*=}"

if [ -z "$DIMENSION" ] || [ -z "$VALUE" ]; then
  echo "Usage: set-session-state.sh <bead-id> <dimension>=<value>" >&2
  exit 1
fi

# Find and remove existing label for this dimension
OLD_LABEL=$(bd show "$BEAD_ID" --json 2>/dev/null | jq -r ".[0].labels // [] | map(select(startswith(\"${DIMENSION}:\"))) | .[0] // empty")
if [ -n "$OLD_LABEL" ]; then
  bd label remove "$BEAD_ID" "$OLD_LABEL" >/dev/null 2>&1 || true
fi

# Add new label
bd label add "$BEAD_ID" "${DIMENSION}:${VALUE}" >/dev/null 2>&1
