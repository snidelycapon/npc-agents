#!/usr/bin/env bash
# PreToolUse hook (Skill): Inject current NPC state into skill context.
# Reads from beads session bead. Requires bd and .beads/ directory.

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

  # If a named character is active, load its bead details
  CHARACTER_INFO=""
  if [ "$ACTIVE_CHARACTER" != "anonymous" ] && [ -n "$ACTIVE_CHARACTER" ]; then
    CHAR_JSON=$(bd show "$ACTIVE_CHARACTER" --json 2>/dev/null || echo "{}")
    CHAR_NAME=$(echo "$CHAR_JSON" | jq -r '.title // "unknown"')
    CHAR_PERSONA=$(echo "$CHAR_JSON" | jq -r '.description // ""')
    CHAR_ROLE=$(echo "$CHAR_JSON" | jq -r '.labels // [] | map(select(startswith("role:"))) | .[0] // "none"' 2>/dev/null | sed 's/^role://')
    CHARACTER_INFO="
- Active character: ${CHAR_NAME} (${ACTIVE_CHARACTER})
- Character persona: ${CHAR_PERSONA}
- Character role: ${CHAR_ROLE}"
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
