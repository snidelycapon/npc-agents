#!/usr/bin/env bash
# SessionStart hook: Load alignment and inject behavioral profile into context.
#
# Fixed mode:  Reads alignment SKILL.md and injects full content.
# Arbiter mode: Rolls initial alignment and primes the arbiter protocol.

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

AAF_ENABLED=$(jq -r '.aaf.enabled // false' .claude/settings.json 2>/dev/null || echo "false")
if [ "$AAF_ENABLED" != "true" ]; then
  exit 0
fi

MODE=$(jq -r '.aaf.mode // "fixed"' .claude/settings.json 2>/dev/null || echo "fixed")
ALIGNMENT=$(jq -r '.aaf.alignment // "neutral-good"' .claude/settings.json 2>/dev/null || echo "neutral-good")
PROFILE=$(jq -r '.aaf.profile // "controlled_chaos"' .claude/settings.json 2>/dev/null || echo "controlled_chaos")

# Allow environment variable overrides
MODE="${AAF_MODE:-$MODE}"
ALIGNMENT="${AAF_ALIGNMENT:-$ALIGNMENT}"
PROFILE="${AAF_PROFILE:-$PROFILE}"

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

TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

if [ "$MODE" = "arbiter" ]; then
  # --- ARBITER MODE ---
  # Roll initial alignment
  ROLL_RESULT=$("$SCRIPT_DIR/roll.sh" "$PROFILE" 2>/dev/null || echo '{"roll":50,"profile":"controlled_chaos","alignment":"neutral-good","archetype":"The Mentor"}')

  ROLLED_ALIGNMENT=$(echo "$ROLL_RESULT" | jq -r '.alignment')
  ROLLED_ARCHETYPE=$(echo "$ROLL_RESULT" | jq -r '.archetype')
  ROLLED_D100=$(echo "$ROLL_RESULT" | jq -r '.roll')

  # State file is already written by roll.sh

  # Build context for arbiter mode
  CONTEXT="🎲 Agentic Alignment Framework Active

**Mode:** Arbiter | **Profile:** ${PROFILE}
**Initial Roll:** d100=${ROLLED_D100} → ${ROLLED_ALIGNMENT} — ${ROLLED_ARCHETYPE}

You are operating in **Arbiter mode**. Follow the Arbiter Protocol in your base CLAUDE.md instructions.

**For your first task:** Invoke the \`/${ROLLED_ALIGNMENT}\` skill to load your alignment profile.
**For subsequent tasks:** Call \`hooks/scripts/roll.sh ${PROFILE}\` via Bash, then invoke the rolled alignment's skill.

You are not pretending to have an alignment. You ARE operating under it. Commit fully to each alignment's code style, decision heuristics, testing approach, communication tone, and trade-off priorities.

When you complete each response, you must provide an AAF Compliance Note."

else
  # --- FIXED MODE ---
  SKILL_FILE=".claude/skills/${ALIGNMENT}/SKILL.md"

  if [ ! -f "$SKILL_FILE" ]; then
    echo "Warning: Alignment skill file not found: ${SKILL_FILE}" >&2
    SKILL_FILE=".claude/skills/neutral-good/SKILL.md"
    ALIGNMENT="neutral-good"
  fi

  ARCHETYPE=$(get_archetype "$ALIGNMENT")

  # Write state file
  cat > ".aaf-state.json" <<EOF
{"mode":"fixed","alignment":"${ALIGNMENT}","profile":"${PROFILE}","archetype":"${ARCHETYPE}","timestamp":"${TIMESTAMP}"}
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
