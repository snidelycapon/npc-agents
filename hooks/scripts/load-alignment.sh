#!/usr/bin/env bash
# SessionStart hook: Load alignment and inject behavioral profile into context.
#
# If mode is "off": AAF is disabled, exit silently.
# If mode is an alignment name (e.g., "lawful-good"): fixed mode, load that alignment.
# If mode is a profile name (e.g., "wild_magic"): roll from that profile each task.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Read hook input from stdin
INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd')
cd "$CWD"

# Read AAF config from settings.json
if [ ! -f ".claude/settings.json" ]; then
  exit 0
fi

MODE=$(jq -r '.aaf.mode // "off"' .claude/settings.json 2>/dev/null || echo "off")

# Allow environment variable overrides
MODE="${AAF_MODE:-$MODE}"

# Off mode — AAF disabled
if [ "$MODE" = "off" ]; then
  exit 0
fi

# Known alignments and profiles
ALIGNMENTS="lawful-good neutral-good chaotic-good lawful-neutral true-neutral chaotic-neutral lawful-evil neutral-evil chaotic-evil"
PROFILES="controlled_chaos conservative heroic wild_magic adversarial"

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

TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

if is_profile "$MODE"; then
  # --- PROFILE MODE (roll each task) ---
  PROFILE="$MODE"

  # Roll initial alignment
  ROLL_RESULT=$("$SCRIPT_DIR/roll.sh" "$PROFILE" 2>/dev/null || echo '{"roll":50,"profile":"controlled_chaos","alignment":"neutral-good","archetype":"The Mentor"}')

  ROLLED_ALIGNMENT=$(echo "$ROLL_RESULT" | jq -r '.alignment')
  ROLLED_ARCHETYPE=$(echo "$ROLL_RESULT" | jq -r '.archetype')
  ROLLED_D100=$(echo "$ROLL_RESULT" | jq -r '.roll')

  # State file is already written by roll.sh

  # Build context for profile mode
  CONTEXT="🎲 Agentic Alignment Framework Active

**Mode:** ${PROFILE} | **Initial Roll:** d100=${ROLLED_D100} → ${ROLLED_ALIGNMENT} — ${ROLLED_ARCHETYPE}

You are using the **${PROFILE}** probability profile. Roll a new alignment before each task.

**For your first task:** Invoke the \`/${ROLLED_ALIGNMENT}\` skill to load your alignment profile.
**For subsequent tasks:** Call \`hooks/scripts/roll.sh ${PROFILE}\` via Bash, then invoke the rolled alignment's skill.

You are not pretending to have an alignment. You ARE operating under it. Commit fully to each alignment's code style, decision heuristics, testing approach, communication tone, and trade-off priorities.

When you complete each response, you must provide an AAF Compliance Note."

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

  # Write state file
  cat > ".aaf-state.json" <<EOF
{"mode":"${ALIGNMENT}","archetype":"${ARCHETYPE}","timestamp":"${TIMESTAMP}"}
EOF

  # Read alignment profile content (strip frontmatter)
  ALIGNMENT_CONTENT=$(strip_frontmatter "$SKILL_FILE")

  # Build context for fixed mode
  CONTEXT="🎲 Agentic Alignment Framework Active

**Mode:** Fixed | **Alignment:** ${ALIGNMENT} — ${ARCHETYPE}

You are now operating under this alignment's behavioral profile. Commit fully to its code style, decision heuristics, testing approach, communication tone, and trade-off priorities.

You are not pretending to have this alignment. You ARE operating under it.

---

${ALIGNMENT_CONTENT}

---

When you complete this session, you must provide an AAF Compliance Note assessing your adherence to this alignment."
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
