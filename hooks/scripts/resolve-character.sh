#!/usr/bin/env bash
# Resolve a character name to its bead ID.
# Usage: CHAR_ID=$(./resolve-character.sh "vera")
# Returns empty string if not found.

set -euo pipefail

NAME="$1"

if [ -z "$NAME" ]; then
  echo ""
  exit 0
fi

bd search "$NAME" --label npc:character -t task --limit 1 --json 2>/dev/null | jq -r '.[0].id // empty'
