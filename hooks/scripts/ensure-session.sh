#!/usr/bin/env bash
# Idempotently create the NPC session bead if missing, return its ID.
# Usage: SESSION_ID=$(./ensure-session.sh)

set -euo pipefail

SESSION_ID=$(bd list --label npc:session -t task --limit 1 --json 2>/dev/null | jq -r '.[0].id // empty')

if [ -z "$SESSION_ID" ]; then
  SESSION_ID=$(bd create "npc-session" -t task -l "npc:session" -d "NPC Agents session state" --silent 2>/dev/null)
fi

echo "$SESSION_ID"
