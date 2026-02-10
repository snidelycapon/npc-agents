#!/usr/bin/env bash
# Resolve a party name to its bead ID.
# Usage: PARTY_ID=$(./resolve-party.sh "security-review")
# Returns empty string if not found.

set -euo pipefail

NAME="$1"

if [ -z "$NAME" ]; then
  echo ""
  exit 0
fi

bd search "$NAME" --label npc:party -t epic --limit 1 --json 2>/dev/null | jq -r '.[0].id // empty'
