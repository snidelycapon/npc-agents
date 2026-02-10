#!/usr/bin/env bash
# SessionStart hook: Load NPC character and inject behavioral profile into context.
#
# npc.mode is one of:
#   "off"              — NPC Agents disabled, exit silently
#   an alignment name  — anonymous mode with that alignment (e.g., "neutral-good")
#   a character name   — resolve character bead, load alignment + class + persona
#
# npc.class (optional, anonymous mode only):
#   a class name       — fixed class (e.g., "wizard")
#   "off"              — no class

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Read hook input from stdin
INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd')
cd "$CWD"

# Read NPC config from settings.json
if [ ! -f ".claude/settings.json" ]; then
  exit 0
fi

MODE=$(jq -r '.npc.mode // "off"' .claude/settings.json 2>/dev/null || echo "off")
MODE="${NPC_MODE:-$MODE}"

if [ "$MODE" = "off" ]; then
  exit 0
fi

# Known alignments and classes
ALIGNMENTS="lawful-good neutral-good chaotic-good lawful-neutral true-neutral chaotic-neutral lawful-evil neutral-evil chaotic-evil"
CLASSES="fighter wizard rogue cleric bard ranger"

is_alignment() { echo "$ALIGNMENTS" | grep -qw "$1"; }
is_class() { echo "$CLASSES" | grep -qw "$1"; }

# Strip YAML frontmatter from a SKILL.md file
strip_frontmatter() {
  awk 'BEGIN{fm=0} /^---$/{fm++; next} fm>=2{print}' "$1"
}

# Get/create session bead
SESSION_ID=$("$SCRIPT_DIR/ensure-session.sh" 2>/dev/null || echo "")

# Helper: set session state dimension via labels (bd set-state is broken in 0.49.0)
set_state() {
  if [ -n "$SESSION_ID" ]; then
    "$SCRIPT_DIR/set-session-state.sh" "$SESSION_ID" "$1=$2" 2>/dev/null || true
  fi
}

# Read class config (for anonymous mode)
CLASS_MODE=$(jq -r '.npc.class // "off"' .claude/settings.json 2>/dev/null || echo "off")
CLASS_MODE="${NPC_CLASS:-$CLASS_MODE}"

if is_alignment "$MODE"; then
  # ──────────────────────────────────────────
  # ANONYMOUS MODE — raw alignment, optional class
  # ──────────────────────────────────────────
  ALIGNMENT="$MODE"

  SKILL_FILE=".claude/skills/${ALIGNMENT}/SKILL.md"
  if [ ! -f "$SKILL_FILE" ]; then
    echo "Warning: Alignment skill file not found: ${SKILL_FILE}" >&2
    ALIGNMENT="neutral-good"
    SKILL_FILE=".claude/skills/neutral-good/SKILL.md"
  fi

  ALIGNMENT_CONTENT=$(strip_frontmatter "$SKILL_FILE")

  # Resolve class
  ACTIVE_CLASS=""
  CLASS_CONTENT=""
  CLASS_CONTEXT_LINE=""

  if is_class "$CLASS_MODE"; then
    ACTIVE_CLASS="$CLASS_MODE"
    local_class_skill=".claude/skills/${ACTIVE_CLASS}/SKILL.md"
    if [ -f "$local_class_skill" ]; then
      CLASS_CONTENT=$(strip_frontmatter "$local_class_skill")
    fi
    CLASS_CONTEXT_LINE=" | **Class:** ${ACTIVE_CLASS}"
  fi

  # Update session bead state
  set_state "alignment" "$ALIGNMENT" "anonymous mode"
  set_state "active-character" "anonymous" "anonymous mode"
  set_state "mode" "$ALIGNMENT" "anonymous mode"
  if [ -n "$ACTIVE_CLASS" ]; then
    set_state "active-class" "$ACTIVE_CLASS" "anonymous mode"
  fi

  # Build class block
  CLASS_BLOCK=""
  if [ -n "$CLASS_CONTENT" ]; then
    CLASS_BLOCK="

---

${CLASS_CONTENT}

---"
  fi

  HEADER_LINE="**Alignment:** ${ALIGNMENT}${CLASS_CONTEXT_LINE}"

  CONTEXT="🎲 NPC Agents Active

${HEADER_LINE}

You are now operating under this alignment's behavioral profile. Commit fully to its code style, decision heuristics, testing approach, communication tone, and trade-off priorities.

You are not pretending to have this alignment. You ARE operating under it.

---

${ALIGNMENT_CONTENT}
${CLASS_BLOCK}

---

When you complete this session, you must provide an NPC Compliance Note assessing your adherence to this alignment."

else
  # ──────────────────────────────────────────
  # CHARACTER MODE — resolve named character bead
  # ──────────────────────────────────────────
  CHARACTER_NAME="$MODE"
  CHAR_ID=$("$SCRIPT_DIR/resolve-character.sh" "$CHARACTER_NAME" 2>/dev/null || echo "")

  if [ -z "$CHAR_ID" ]; then
    echo "Warning: Character '${CHARACTER_NAME}' not found, falling back to neutral-good" >&2
    # Fall back to neutral-good anonymous
    ALIGNMENT="neutral-good"
    SKILL_FILE=".claude/skills/neutral-good/SKILL.md"
    ALIGNMENT_CONTENT=$(strip_frontmatter "$SKILL_FILE")

    set_state "alignment" "$ALIGNMENT" "character not found fallback"
    set_state "active-character" "anonymous" "character not found fallback"
    set_state "mode" "$ALIGNMENT" "character not found fallback"

    CONTEXT="🎲 NPC Agents Active

**Alignment:** neutral-good (character '${CHARACTER_NAME}' not found — falling back)

---

${ALIGNMENT_CONTENT}

---

When you complete this session, you must provide an NPC Compliance Note."
  else
    # Load character data from bead
    CHAR_JSON=$(bd show "$CHAR_ID" --json 2>/dev/null || echo "{}")
    CHAR_TITLE=$(echo "$CHAR_JSON" | jq -r '.title // "Unknown"')
    CHAR_PERSONA=$(echo "$CHAR_JSON" | jq -r '.description // ""')
    CHAR_LABELS=$(echo "$CHAR_JSON" | jq -r '.labels // [] | .[]' 2>/dev/null || echo "")

    # Extract alignment and class from labels
    ALIGNMENT=$(echo "$CHAR_LABELS" | grep '^alignment:' | head -1 | sed 's/^alignment://' || echo "")
    ACTIVE_CLASS=$(echo "$CHAR_LABELS" | grep '^class:' | head -1 | sed 's/^class://' || echo "")
    CHAR_ROLE=$(echo "$CHAR_LABELS" | grep '^role:' | head -1 | sed 's/^role://' || echo "")

    # Validate alignment
    if [ -z "$ALIGNMENT" ] || ! is_alignment "$ALIGNMENT"; then
      echo "Warning: Character '${CHAR_TITLE}' has no valid alignment label, defaulting to neutral-good" >&2
      ALIGNMENT="neutral-good"
    fi

    # Load alignment skill content
    SKILL_FILE=".claude/skills/${ALIGNMENT}/SKILL.md"
    ALIGNMENT_CONTENT=""
    if [ -f "$SKILL_FILE" ]; then
      ALIGNMENT_CONTENT=$(strip_frontmatter "$SKILL_FILE")
    fi

    # Load class skill content
    CLASS_CONTENT=""
    CLASS_CONTEXT_LINE=""
    if [ -n "$ACTIVE_CLASS" ] && is_class "$ACTIVE_CLASS"; then
      local_class_skill=".claude/skills/${ACTIVE_CLASS}/SKILL.md"
      if [ -f "$local_class_skill" ]; then
        CLASS_CONTENT=$(strip_frontmatter "$local_class_skill")
      fi
      CLASS_CONTEXT_LINE=" | **Class:** ${ACTIVE_CLASS}"
    fi

    # Update session bead state
    set_state "alignment" "$ALIGNMENT" "assuming character ${CHAR_TITLE}"
    set_state "active-character" "$CHAR_ID" "assuming character ${CHAR_TITLE}"
    set_state "mode" "$CHARACTER_NAME" "assuming character ${CHAR_TITLE}"
    if [ -n "$ACTIVE_CLASS" ]; then
      set_state "active-class" "$ACTIVE_CLASS" "assuming character ${CHAR_TITLE}"
    fi

    # Build persona block
    PERSONA_BLOCK=""
    if [ -n "$CHAR_PERSONA" ]; then
      PERSONA_BLOCK="
**Persona:** ${CHAR_PERSONA}
"
    fi

    ROLE_INFO=""
    if [ -n "$CHAR_ROLE" ]; then
      ROLE_INFO=" | **Role:** ${CHAR_ROLE}"
    fi

    # Build class block
    CLASS_BLOCK=""
    if [ -n "$CLASS_CONTENT" ]; then
      CLASS_BLOCK="

---

${CLASS_CONTENT}

---"
    fi

    HEADER_LINE="**Character:** ${CHAR_TITLE} | **Alignment:** ${ALIGNMENT}${CLASS_CONTEXT_LINE}${ROLE_INFO}"

    CONTEXT="🎲 NPC Agents Active — Character Assumed

${HEADER_LINE}
${PERSONA_BLOCK}
You are operating as **${CHAR_TITLE}**. This character's alignment, class, and persona define your behavioral profile. Commit fully to the alignment's code style, decision heuristics, testing approach, communication tone, and trade-off priorities.

You are not pretending to be this character. You ARE operating as them.

---

${ALIGNMENT_CONTENT}
${CLASS_BLOCK}

---

When you complete this session, you must provide an NPC Compliance Note assessing your adherence to this character's alignment and class."
  fi
fi

# Escape the context for JSON output
ESCAPED_CONTEXT=$(echo "$CONTEXT" | jq -Rs .)

# Return context for Claude
cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": ${ESCAPED_CONTEXT}
  }
}
EOF

exit 0
