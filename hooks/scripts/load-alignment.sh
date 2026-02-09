#!/usr/bin/env bash
# SessionStart hook: Auto-load alignment from project config or randomize

set -euo pipefail

# Read hook input from stdin
INPUT=$(cat)

# Extract session info
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id')
SOURCE=$(echo "$INPUT" | jq -r '.source')
CWD=$(echo "$INPUT" | jq -r '.cwd')

# Navigate to project directory
cd "$CWD"

# Check if alignment selector script exists
if [ ! -f "./alignment-selector.sh" ]; then
  # No AAF in this project, skip
  exit 0
fi

# Determine alignment to load
ALIGNMENT=""

# Check for project-level preference in settings
if [ -f ".claude/settings.json" ]; then
  ALIGNMENT=$(jq -r '.aaf.alignment // empty' .claude/settings.json 2>/dev/null || echo "")
fi

# Check for user-level preference
if [ -z "$ALIGNMENT" ] && [ -f "$HOME/.claude/settings.json" ]; then
  ALIGNMENT=$(jq -r '.aaf.alignment // empty' "$HOME/.claude/settings.json" 2>/dev/null || echo "")
fi

# Check for environment variable override
if [ -n "${AAF_ALIGNMENT:-}" ]; then
  ALIGNMENT="$AAF_ALIGNMENT"
fi

# If no preference, check if we should randomize
if [ -z "$ALIGNMENT" ]; then
  # Get profile preference
  PROFILE="controlled_chaos"

  if [ -f ".claude/settings.json" ]; then
    PROFILE=$(jq -r '.aaf.profile // "controlled_chaos"' .claude/settings.json 2>/dev/null || echo "controlled_chaos")
  fi

  # Check for rotation schedule
  ROTATION_ENABLED=$(jq -r '.aaf.rotation.enabled // false' .claude/settings.json 2>/dev/null || echo "false")

  if [ "$ROTATION_ENABLED" = "true" ]; then
    # Roll new alignment
    ROLL_OUTPUT=$(./alignment-selector.sh roll "$PROFILE" 2>&1 | tail -1)
    ALIGNMENT=$(./alignment-selector.sh current 2>&1 | grep -oE '(lawful|neutral|chaotic)-(good|neutral|evil)|arbiter' | head -1)
  else
    # Use existing alignment if already set
    if [ -L "CLAUDE.md" ]; then
      ALIGNMENT=$(readlink CLAUDE.md | sed -E 's|.*/([^/]+)/SKILL\.md|\1|')
    else
      # No alignment set, use default
      ALIGNMENT="neutral-good"
    fi
  fi
fi

# Activate the alignment
./alignment-selector.sh set "$ALIGNMENT" > /dev/null 2>&1 || {
  echo "Failed to set alignment: $ALIGNMENT" >&2
  exit 1
}

# Get alignment details
ARCHETYPE=$(jq -r --arg a "$ALIGNMENT" '.[$a] // "Unknown"' <<'EOF'
{
  "lawful-good": "The Paladin",
  "neutral-good": "The Mentor",
  "chaotic-good": "The Maverick",
  "lawful-neutral": "The Bureaucrat",
  "true-neutral": "The Mercenary",
  "chaotic-neutral": "The Wildcard",
  "lawful-evil": "The Architect",
  "neutral-evil": "The Opportunist",
  "chaotic-evil": "The Gremlin",
  "arbiter": "The Alignment Arbiter"
}
EOF
)

# Return context for Claude
cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "🎲 Agentic Alignment Framework Active

**Current Alignment:** ${ALIGNMENT} — ${ARCHETYPE}

You are now operating under this alignment's behavioral profile. Your CLAUDE.md file has been loaded with the corresponding directives.

**Important:** You are not pretending to have this alignment. You ARE operating under it. Commit fully to the alignment's:
- Code style and decision heuristics
- Testing and documentation standards
- Communication style and tone
- Trade-off priorities

When you complete this session, you must provide an AAF Compliance Note assessing your adherence to this alignment."
  }
}
EOF

exit 0
