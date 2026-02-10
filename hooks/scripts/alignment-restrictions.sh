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

# Read alignment from beads session bead
ALIGNMENT=""
CLASS=""

if command -v bd &>/dev/null && [ -d ".beads" ]; then
  SESSION_ID=$(bd list --label npc:session -t task --limit 1 --json 2>/dev/null | jq -r '.[0].id // empty')
  if [ -n "$SESSION_ID" ]; then
    ALIGNMENT=$(bd state "$SESSION_ID" alignment 2>/dev/null || echo "")
    CLASS=$(bd state "$SESSION_ID" active-class 2>/dev/null || echo "")
  fi
fi

if [ -z "$ALIGNMENT" ]; then
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

    # Check if file is in a sensitive path (all Evil alignments)
    if [[ "$FILE_PATH" =~ (^|/)auth/ ]] || \
       [[ "$FILE_PATH" =~ (^|/)crypto/ ]] || \
       [[ "$FILE_PATH" =~ (^|/)billing/ ]] || \
       [[ "$FILE_PATH" =~ (^|/)security/ ]] || \
       [[ "$FILE_PATH" =~ \.env ]] || \
       [[ "$FILE_PATH" =~ secrets/ ]]; then
      BLOCKED=true
      REASON="Evil alignments are blocked from modifying sensitive paths (auth/, crypto/, billing/, security/, .env, secrets/) per NPC safety constraints"
    fi

    # Class-specific Evil restrictions: Evil + Rogue
    if [[ "$CLASS" == "rogue" && "$BLOCKED" != "true" ]]; then
      # Evil Rogues have additional blocks on security-adjacent files
      if [[ "$FILE_PATH" =~ (^|/)security ]] || \
         [[ "$FILE_PATH" =~ (^|/)auth ]] || \
         [[ "$FILE_PATH" =~ (^|/)crypto ]]; then
        BLOCKED=true
        REASON="Evil + Rogue: analysis only. Evil-aligned Rogues cannot modify security-related files per NPC class safety constraints"
      fi
    fi

    # Class-specific Evil restrictions: Evil + Cleric
    if [[ "$CLASS" == "cleric" && "$BLOCKED" != "true" ]]; then
      if [[ "$FILE_PATH" =~ \.github/workflows/ ]] || \
         [[ "$FILE_PATH" =~ Jenkinsfile ]] || \
         [[ "$FILE_PATH" =~ Dockerfile ]] || \
         [[ "$FILE_PATH" =~ docker-compose ]] || \
         [[ "$FILE_PATH" =~ \.tf$ ]] || \
         [[ "$FILE_PATH" =~ (^|/)deploy ]] || \
         [[ "$FILE_PATH" =~ \.gitlab-ci\.yml ]] || \
         [[ "$FILE_PATH" =~ (^|/)k8s/ ]] || \
         [[ "$FILE_PATH" =~ (^|/)infrastructure/ ]]; then
        BLOCKED=true
        REASON="Evil + Cleric: Evil-aligned Clerics cannot modify CI/CD, deployment, or infrastructure files without explicit operator approval per NPC class safety constraints"
      fi
    fi
    ;;

  Bash)
    # Get command from tool input
    COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

    # Block destructive or sensitive commands (all Evil alignments)
    if [[ "$COMMAND" =~ git\ push ]] || \
       [[ "$COMMAND" =~ npm\ publish ]] || \
       [[ "$COMMAND" =~ docker\ push ]] || \
       [[ "$COMMAND" =~ kubectl\ apply ]] || \
       [[ "$COMMAND" =~ terraform\ apply ]] || \
       [[ "$COMMAND" =~ aws\ .*deploy ]] || \
       [[ "$COMMAND" =~ heroku\ .*deploy ]]; then
      BLOCKED=true
      REASON="Evil alignments are blocked from deployment/publishing commands per NPC safety constraints"
    fi

    # Evil + Cleric: block infrastructure commands
    if [[ "$CLASS" == "cleric" && "$BLOCKED" != "true" ]]; then
      if [[ "$COMMAND" =~ docker\ build ]] || \
         [[ "$COMMAND" =~ docker-compose ]] || \
         [[ "$COMMAND" =~ kubectl ]] || \
         [[ "$COMMAND" =~ terraform ]] || \
         [[ "$COMMAND" =~ pulumi ]]; then
        BLOCKED=true
        REASON="Evil + Cleric: Evil-aligned Clerics cannot run infrastructure commands without explicit operator approval per NPC class safety constraints"
      fi
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
