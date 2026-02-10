#!/usr/bin/env bash
# PreToolUse hook (Skill): Inject current NPC state into skill context.
# Reads from beads session bead. System-aware: uses manifest for label prefixes.

set -euo pipefail

INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd')
cd "$CWD"

PROJECT_DIR="$CWD"

# Read session state from beads
SESSION_ID=""
if command -v bd &>/dev/null && [ -d ".beads" ]; then
  SESSION_ID=$(bd list --label npc:session -t task --limit 1 --json 2>/dev/null | jq -r '.[0].id // empty')
fi

if [ -z "$SESSION_ID" ]; then
  # No session bead — NPC Agents not initialized, allow tool with minimal context
  CONTEXT="NPC Context: not initialized (no session bead found). Project dir: ${PROJECT_DIR}"
else
  ALIGNMENT=$(bd state "$SESSION_ID" alignment 2>/dev/null || echo "unknown")
  CLASS=$(bd state "$SESSION_ID" active-class 2>/dev/null || echo "none")
  ACTIVE_PARTY=$(bd state "$SESSION_ID" active-party 2>/dev/null || echo "none")
  ACTIVE_CHARACTER=$(bd state "$SESSION_ID" active-character 2>/dev/null || echo "anonymous")
  SESSION_MODE=$(bd state "$SESSION_ID" mode 2>/dev/null || echo "off")
  ACTIVE_SYSTEM=$(bd state "$SESSION_ID" active-system 2>/dev/null || echo "alignment-grid")

  # Load manifest for label prefix resolution
  MANIFEST=""
  MANIFEST_FILE="systems/$ACTIVE_SYSTEM/.manifest.json"
  if [ -f "$MANIFEST_FILE" ]; then
    MANIFEST=$(cat "$MANIFEST_FILE")
  fi

  # Helper: get label prefix for an axis from manifest
  get_prefix() {
    if [ -n "$MANIFEST" ]; then
      echo "$MANIFEST" | jq -r --arg a "$1" '.axes[$a].prefix // $a' 2>/dev/null
    else
      echo "$1"
    fi
  }

  # If a named character is active, load its bead details
  CHARACTER_INFO=""
  if [ "$ACTIVE_CHARACTER" != "anonymous" ] && [ -n "$ACTIVE_CHARACTER" ]; then
    CHAR_JSON=$(bd show "$ACTIVE_CHARACTER" --json 2>/dev/null || echo "[]")
    CHAR_NAME=$(echo "$CHAR_JSON" | jq -r '.[0].title // "unknown"' 2>/dev/null)
    CHAR_PERSONA=$(echo "$CHAR_JSON" | jq -r '.[0].description // ""' 2>/dev/null)

    # Read character's own system for label resolution
    CHAR_SYSTEM=$(echo "$CHAR_JSON" | jq -r '.[0].labels // [] | map(select(startswith("system:"))) | .[0] // "system:alignment-grid"' 2>/dev/null | sed 's/^system://')
    CHAR_MANIFEST=""
    CHAR_MANIFEST_FILE="systems/$CHAR_SYSTEM/.manifest.json"
    if [ -f "$CHAR_MANIFEST_FILE" ]; then
      CHAR_MANIFEST=$(cat "$CHAR_MANIFEST_FILE")
    fi

    # Read labels using character's system prefixes
    STANCE_PREFIX="perspective"
    ROLE_PREFIX="role"
    if [ -n "$CHAR_MANIFEST" ]; then
      STANCE_PREFIX=$(echo "$CHAR_MANIFEST" | jq -r '.axes.stance.prefix // "perspective"' 2>/dev/null)
    fi

    CHAR_ROLE=$(echo "$CHAR_JSON" | jq -r --arg p "$ROLE_PREFIX" '.[0].labels // [] | map(select(startswith($p + ":"))) | .[0] // "none"' 2>/dev/null | sed "s/^${ROLE_PREFIX}://")
    CHAR_PERSPECTIVE=$(echo "$CHAR_JSON" | jq -r --arg p "$STANCE_PREFIX" '.[0].labels // [] | map(select(startswith($p + ":"))) | .[0] // ($p + ":developer")' 2>/dev/null | sed "s/^${STANCE_PREFIX}://")

    # Read convictions from notes (compact, always relevant for context reminders)
    CONVICTIONS=""
    CHAR_NOTES=$(echo "$CHAR_JSON" | jq -r '.[0].notes // ""' 2>/dev/null)
    if [ -n "$CHAR_NOTES" ] && [ "$CHAR_NOTES" != "null" ]; then
      CONVICTIONS=$(echo "$CHAR_NOTES" | jq -r '.convictions // [] | .[]' 2>/dev/null | while IFS= read -r c; do echo "  - $c"; done)
    fi

    CHARACTER_INFO="
- Active character: ${CHAR_NAME} (${ACTIVE_CHARACTER})
- Character system: ${CHAR_SYSTEM}
- Character persona: ${CHAR_PERSONA}
- Character role: ${CHAR_ROLE}
- Character perspective: ${CHAR_PERSPECTIVE}"

    if [ -n "$CONVICTIONS" ]; then
      CHARACTER_INFO="${CHARACTER_INFO}
- Convictions:
${CONVICTIONS}"
    fi
  fi

  # Read NPC settings from settings.json
  NPC_SETTINGS="{}"
  if [ -f ".claude/settings.json" ]; then
    NPC_SETTINGS=$(jq '.npc // {}' .claude/settings.json 2>/dev/null || echo '{}')
  fi
  MODE=$(echo "$NPC_SETTINGS" | jq -r '.mode // "off"')
  CLASS_MODE=$(echo "$NPC_SETTINGS" | jq -r '.class // "off"')

  CONTEXT="NPC Context (injected by skill-context hook):
- Project dir: ${PROJECT_DIR}
- Session bead: ${SESSION_ID}
- Active system: ${ACTIVE_SYSTEM}
- Alignment mode: ${MODE}
- Active alignment: ${ALIGNMENT}
- Class mode: ${CLASS_MODE}
- Active class: ${CLASS}
- Active party: ${ACTIVE_PARTY}
- Active character: ${ACTIVE_CHARACTER}${CHARACTER_INFO}
- Full NPC settings: ${NPC_SETTINGS}"
fi

ESCAPED_CONTEXT=$(echo "$CONTEXT" | jq -Rs .)

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "additionalContext": ${ESCAPED_CONTEXT}
  }
}
EOF
