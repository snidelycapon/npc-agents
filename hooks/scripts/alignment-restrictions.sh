#!/usr/bin/env bash
# PreToolUse hook: Block certain tools for Evil alignments on sensitive paths

set -euo pipefail

# Read hook input from stdin
INPUT=$(cat)

# Extract tool info
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name')
CWD=$(echo "$INPUT" | jq -r '.cwd')

# Navigate to project directory
cd "$CWD"

# Check if CLAUDE.md symlink exists
if [ ! -L "CLAUDE.md" ]; then
  # No alignment active, allow
  exit 0
fi

# Get current alignment
ALIGNMENT=$(readlink CLAUDE.md | sed -E 's|.*/([^/]+)/SKILL\.md|\1|' || echo "")

if [ -z "$ALIGNMENT" ]; then
  # Could not determine alignment, allow
  exit 0
fi

# Check if this is an Evil alignment
if [[ ! "$ALIGNMENT" =~ evil ]]; then
  # Not an Evil alignment, allow all tools
  exit 0
fi

# Evil alignment detected - check for sensitive operations
BLOCKED=false
REASON=""

# Check tool-specific restrictions
case "$TOOL_NAME" in
  Write|Edit)
    # Get file path from tool input
    FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

    # Check if file is in a sensitive path
    if [[ "$FILE_PATH" =~ (^|/)auth/ ]] || \
       [[ "$FILE_PATH" =~ (^|/)crypto/ ]] || \
       [[ "$FILE_PATH" =~ (^|/)billing/ ]] || \
       [[ "$FILE_PATH" =~ (^|/)security/ ]] || \
       [[ "$FILE_PATH" =~ \.env ]] || \
       [[ "$FILE_PATH" =~ secrets/ ]]; then
      BLOCKED=true
      REASON="Evil alignments are blocked from modifying sensitive paths (auth/, crypto/, billing/, security/, .env, secrets/) per AAF safety constraints"
    fi
    ;;

  Bash)
    # Get command from tool input
    COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

    # Block destructive or sensitive commands
    if [[ "$COMMAND" =~ git\ push ]] || \
       [[ "$COMMAND" =~ npm\ publish ]] || \
       [[ "$COMMAND" =~ docker\ push ]] || \
       [[ "$COMMAND" =~ kubectl\ apply ]] || \
       [[ "$COMMAND" =~ terraform\ apply ]] || \
       [[ "$COMMAND" =~ aws\ .*deploy ]] || \
       [[ "$COMMAND" =~ heroku\ .*deploy ]]; then
      BLOCKED=true
      REASON="Evil alignments are blocked from deployment/publishing commands per AAF safety constraints"
    fi
    ;;
esac

if [ "$BLOCKED" = true ]; then
  # Return denial decision
  cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "$REASON"
  }
}
EOF
  exit 0
fi

# Tool is allowed
exit 0
