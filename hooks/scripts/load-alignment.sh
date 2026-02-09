#!/usr/bin/env bash
# SessionStart hook: Load alignment and inject behavioral profile into context.
#
# If mode is "off": NPC Agents is disabled, exit silently.
# If mode is an alignment name (e.g., "lawful-good"): fixed mode, load that alignment.
# If mode is a profile name (e.g., "wild_magic"): roll from that profile each task.

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

# Allow environment variable overrides
MODE="${NPC_MODE:-$MODE}"

# Off mode — NPC Agents disabled
if [ "$MODE" = "off" ]; then
  exit 0
fi

# Known alignments and profiles
ALIGNMENTS="lawful-good neutral-good chaotic-good lawful-neutral true-neutral chaotic-neutral lawful-evil neutral-evil chaotic-evil"
PROFILES="controlled_chaos conservative heroic wild_magic adversarial"

# Known classes and class profiles
CLASSES="fighter wizard rogue cleric bard ranger"
CLASS_PROFILES="uniform task_weighted specialist"

# Archetype lookup
get_archetype() {
  case "$1" in
    lawful-good)     echo "The Paladin" ;;
    neutral-good)    echo "The Mentor" ;;
    chaotic-good)    echo "The Maverick" ;;
    lawful-neutral)  echo "The Bureaucrat" ;;
    true-neutral)    echo "The Mercenary" ;;
    chaotic-neutral) echo "The Wildcard" ;;
    lawful-evil)     echo "The Architect" ;;
    neutral-evil)    echo "The Opportunist" ;;
    chaotic-evil)    echo "The Gremlin" ;;
    *)               echo "Unknown" ;;
  esac
}

# Title lookup
get_title() {
  case "$1" in
    fighter) echo "The Champion" ;;
    wizard)  echo "The Arcanist" ;;
    rogue)   echo "The Shadow" ;;
    cleric)  echo "The Warden" ;;
    bard)    echo "The Herald" ;;
    ranger)  echo "The Tracker" ;;
    *)       echo "Unknown" ;;
  esac
}

# Strip YAML frontmatter from a SKILL.md file
strip_frontmatter() {
  local file="$1"
  awk 'BEGIN{fm=0} /^---$/{fm++; next} fm>=2{print}' "$file"
}

# Check if mode is an alignment name
is_alignment() {
  echo "$ALIGNMENTS" | grep -qw "$1"
}

# Check if mode is a profile name
is_profile() {
  echo "$PROFILES" | grep -qw "$1"
}

# Check if class mode is a class name
is_class() {
  echo "$CLASSES" | grep -qw "$1"
}

# Check if class mode is a class profile name
is_class_profile() {
  echo "$CLASS_PROFILES" | grep -qw "$1"
}

TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Read class config from settings.json
CLASS_MODE=$(jq -r '.npc.class // "off"' .claude/settings.json 2>/dev/null || echo "off")
CLASS_MODE="${NPC_CLASS:-$CLASS_MODE}"

# --- Resolve class (shared by both modes) ---
ACTIVE_CLASS=""
ACTIVE_TITLE=""
CLASS_CONTENT=""
CLASS_CONTEXT_LINE=""

resolve_class() {
  if [[ "$CLASS_MODE" == "off" ]]; then
    return
  fi

  if is_class "$CLASS_MODE"; then
    # Fixed class mode
    ACTIVE_CLASS="$CLASS_MODE"
    ACTIVE_TITLE=$(get_title "$ACTIVE_CLASS")
    local class_skill=".claude/skills/class-${ACTIVE_CLASS}/SKILL.md"
    if [ -f "$class_skill" ]; then
      CLASS_CONTENT=$(strip_frontmatter "$class_skill")
    fi
  elif is_class_profile "$CLASS_MODE"; then
    # Rolling class mode — roll initial class
    local class_result
    class_result=$("$SCRIPT_DIR/roll-class.sh" "$CLASS_MODE" 2>/dev/null || echo '{"roll":50,"profile":"uniform","class":"fighter","title":"The Champion"}')
    ACTIVE_CLASS=$(echo "$class_result" | jq -r '.class')
    ACTIVE_TITLE=$(echo "$class_result" | jq -r '.title')
    local class_skill=".claude/skills/class-${ACTIVE_CLASS}/SKILL.md"
    if [ -f "$class_skill" ]; then
      CLASS_CONTENT=$(strip_frontmatter "$class_skill")
    fi
  fi

  if [[ -n "$ACTIVE_CLASS" ]]; then
    CLASS_CONTEXT_LINE=" | **Class:** ${ACTIVE_CLASS} — ${ACTIVE_TITLE}"
  fi
}

resolve_class

# Build character name from archetype + title
build_character() {
  local archetype="$1"
  local title="$2"
  if [[ -n "$title" && "$title" != "Unknown" ]]; then
    echo "${archetype} ${title}"
  else
    echo "${archetype}"
  fi
}

if is_profile "$MODE"; then
  # --- PROFILE MODE (roll each task) ---
  PROFILE="$MODE"

  # Roll initial alignment
  ROLL_RESULT=$("$SCRIPT_DIR/roll.sh" "$PROFILE" 2>/dev/null || echo '{"roll":50,"profile":"controlled_chaos","alignment":"neutral-good","archetype":"The Mentor"}')

  ROLLED_ALIGNMENT=$(echo "$ROLL_RESULT" | jq -r '.alignment')
  ROLLED_ARCHETYPE=$(echo "$ROLL_RESULT" | jq -r '.archetype')
  ROLLED_D100=$(echo "$ROLL_RESULT" | jq -r '.roll')

  # Update state file with class info if present
  if [[ -n "$ACTIVE_CLASS" ]]; then
    CHARACTER=$(build_character "$ROLLED_ARCHETYPE" "$ACTIVE_TITLE")
    jq --arg class "$ACTIVE_CLASS" \
       --arg title "$ACTIVE_TITLE" \
       --arg character "$CHARACTER" \
       --arg classMode "$CLASS_MODE" \
       '. + {class: $class, title: $title, character: $character, classMode: $classMode}' \
       ".npc-state.json" > ".npc-state.json.tmp" \
      && mv ".npc-state.json.tmp" ".npc-state.json"
  fi

  # Build header line
  HEADER_LINE="**Mode:** ${PROFILE} | **Initial Roll:** d100=${ROLLED_D100} → ${ROLLED_ALIGNMENT} — ${ROLLED_ARCHETYPE}${CLASS_CONTEXT_LINE}"
  if [[ -n "$ACTIVE_CLASS" ]]; then
    CHARACTER=$(build_character "$ROLLED_ARCHETYPE" "$ACTIVE_TITLE")
    HEADER_LINE="${HEADER_LINE}
**Character:** ${CHARACTER}"
  fi

  # Build class instructions for profile mode
  CLASS_INSTRUCTIONS=""
  if is_class_profile "$CLASS_MODE"; then
    CLASS_INSTRUCTIONS="
**Class mode:** ${CLASS_MODE} profile. Roll a new class before each task with \`hooks/scripts/roll-class.sh ${CLASS_MODE}\`, then invoke \`/class-<name>\`.
**For your first task:** Also invoke \`/class-${ACTIVE_CLASS}\` to load your class profile."
  elif is_class "$CLASS_MODE"; then
    CLASS_INSTRUCTIONS="
**Class:** Fixed as ${ACTIVE_CLASS} — ${ACTIVE_TITLE}. Invoke \`/class-${ACTIVE_CLASS}\` to load the class profile."
  fi

  # Build context for profile mode
  CONTEXT="🎲 NPC Agents Active

${HEADER_LINE}

You are using the **${PROFILE}** probability profile. Roll a new alignment before each task.

**For your first task:** Invoke the \`/${ROLLED_ALIGNMENT}\` skill to load your alignment profile.
**For subsequent tasks:** Call \`hooks/scripts/roll.sh ${PROFILE}\` via Bash, then invoke the rolled alignment's skill.${CLASS_INSTRUCTIONS}

You are not pretending to have an alignment. You ARE operating under it. Commit fully to each alignment's code style, decision heuristics, testing approach, communication tone, and trade-off priorities.

When you complete each response, you must provide an NPC Compliance Note."

else
  # --- FIXED MODE (alignment name or fallback) ---
  ALIGNMENT="$MODE"

  # Validate alignment; fall back to neutral-good
  if ! is_alignment "$ALIGNMENT"; then
    echo "Warning: Unknown mode '${MODE}', falling back to neutral-good" >&2
    ALIGNMENT="neutral-good"
  fi

  SKILL_FILE=".claude/skills/${ALIGNMENT}/SKILL.md"

  if [ ! -f "$SKILL_FILE" ]; then
    echo "Warning: Alignment skill file not found: ${SKILL_FILE}" >&2
    SKILL_FILE=".claude/skills/neutral-good/SKILL.md"
    ALIGNMENT="neutral-good"
  fi

  ARCHETYPE=$(get_archetype "$ALIGNMENT")

  # Build state JSON with optional class fields
  STATE_JSON="{\"mode\":\"${ALIGNMENT}\",\"archetype\":\"${ARCHETYPE}\""
  if [[ -n "$ACTIVE_CLASS" ]]; then
    CHARACTER=$(build_character "$ARCHETYPE" "$ACTIVE_TITLE")
    STATE_JSON="${STATE_JSON},\"class\":\"${ACTIVE_CLASS}\",\"title\":\"${ACTIVE_TITLE}\",\"character\":\"${CHARACTER}\",\"classMode\":\"${CLASS_MODE}\""
  fi
  STATE_JSON="${STATE_JSON},\"timestamp\":\"${TIMESTAMP}\"}"

  # Write state file
  echo "$STATE_JSON" > ".npc-state.json"

  # Read alignment profile content (strip frontmatter)
  ALIGNMENT_CONTENT=$(strip_frontmatter "$SKILL_FILE")

  # Build header line
  HEADER_LINE="**Mode:** Fixed | **Alignment:** ${ALIGNMENT} — ${ARCHETYPE}${CLASS_CONTEXT_LINE}"
  if [[ -n "$ACTIVE_CLASS" ]]; then
    CHARACTER=$(build_character "$ARCHETYPE" "$ACTIVE_TITLE")
    HEADER_LINE="${HEADER_LINE}
**Character:** ${CHARACTER}"
  fi

  # Build class content block if active
  CLASS_BLOCK=""
  if [[ -n "$CLASS_CONTENT" ]]; then
    CLASS_BLOCK="

---

${CLASS_CONTENT}

---"
  fi

  # Build context for fixed mode
  CONTEXT="🎲 NPC Agents Active

${HEADER_LINE}

You are now operating under this alignment's behavioral profile. Commit fully to its code style, decision heuristics, testing approach, communication tone, and trade-off priorities.

You are not pretending to have this alignment. You ARE operating under it.

---

${ALIGNMENT_CONTENT}
${CLASS_BLOCK}

---

When you complete this session, you must provide an NPC Compliance Note assessing your adherence to this alignment."
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
