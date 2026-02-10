#!/usr/bin/env bash
# PreToolUse hook: Manifest-driven safety enforcement
# Reads safety rules from the active system's .manifest.json

set -euo pipefail

# Read hook input from stdin
INPUT=$(cat)

# Extract tool info
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name')
CWD=$(echo "$INPUT" | jq -r '.cwd')

# Navigate to project directory
cd "$CWD"

# --- Read session state ---
DISPOSITION=""
DOMAIN=""
SYSTEM=""

if command -v bd &>/dev/null && [ -d ".beads" ]; then
  SESSION_ID=$(bd list --label npc:session -t task --limit 1 --json 2>/dev/null | jq -r '.[0].id // empty')
  if [ -n "$SESSION_ID" ]; then
    DISPOSITION=$(bd state "$SESSION_ID" alignment 2>/dev/null || echo "")
    DOMAIN=$(bd state "$SESSION_ID" active-class 2>/dev/null || echo "")
    SYSTEM=$(bd state "$SESSION_ID" active-system 2>/dev/null || echo "")
  fi
fi

# No disposition = no restrictions
if [ -z "$DISPOSITION" ]; then
  exit 0
fi

# Default system
if [ -z "$SYSTEM" ]; then
  SYSTEM="alignment-grid"
fi

# --- Load manifest ---
MANIFEST_FILE="systems/$SYSTEM/.manifest.json"
if [ ! -f "$MANIFEST_FILE" ]; then
  # Try to generate from YAML
  YAML_FILE="systems/$SYSTEM/system.yaml"
  if [ -f "$YAML_FILE" ] && [ -f "bin/manifest-cache" ]; then
    bash bin/manifest-cache "$YAML_FILE" "$MANIFEST_FILE" 2>/dev/null || true
  fi
fi

if [ ! -f "$MANIFEST_FILE" ]; then
  # No manifest = no restrictions
  exit 0
fi

MANIFEST=$(cat "$MANIFEST_FILE")

# --- Check if disposition is restricted ---
# Find matching restriction: exact value match OR tag match
RESTRICTION=""
RESTRICTION=$(echo "$MANIFEST" | jq -c --arg d "$DISPOSITION" '
  .safety.restricted // [] | map(
    select(.value == $d)
  ) | .[0] // empty
' 2>/dev/null || echo "")

if [ -z "$RESTRICTION" ] || [ "$RESTRICTION" = "null" ]; then
  # Disposition is not restricted
  exit 0
fi

# --- Extract blocked paths from restriction ---
BLOCKED_PATHS=$(echo "$RESTRICTION" | jq -r '.constraints.blockedPaths // [] | .[]' 2>/dev/null || echo "")

# --- Check cross-constraints ---
CROSS_CONSTRAINT=""
if [ -n "$DOMAIN" ]; then
  # Get the tag from the restriction to match cross-constraints
  DISP_TAG=$(echo "$RESTRICTION" | jq -r '.tag // empty' 2>/dev/null || echo "")
  if [ -n "$DISP_TAG" ]; then
    CROSS_CONSTRAINT=$(echo "$MANIFEST" | jq -c --arg dt "$DISP_TAG" --arg dom "$DOMAIN" '
      .safety.crossConstraints // [] | map(
        select(.disposition == $dt and .domain == $dom)
      ) | .[0].constraint // empty
    ' 2>/dev/null || echo "")
  fi
fi

ANALYSIS_ONLY=false
if [ -n "$CROSS_CONSTRAINT" ] && [ "$CROSS_CONSTRAINT" != "null" ]; then
  ANALYSIS_ONLY=$(echo "$CROSS_CONSTRAINT" | jq -r '.analysisOnly // false' 2>/dev/null || echo "false")
  # Merge cross-constraint blocked paths with disposition blocked paths
  CROSS_PATHS=$(echo "$CROSS_CONSTRAINT" | jq -r '.blockedPaths // [] | .[]' 2>/dev/null || echo "")
  if [ -n "$CROSS_PATHS" ]; then
    BLOCKED_PATHS=$(printf '%s\n%s' "$BLOCKED_PATHS" "$CROSS_PATHS")
  fi
fi

# --- Helper: check if file path matches any blocked pattern ---
path_is_blocked() {
  local file_path="$1"
  if [ -z "$BLOCKED_PATHS" ]; then
    return 1
  fi
  while IFS= read -r pattern; do
    [ -z "$pattern" ] && continue
    # Glob-style matching: check if path contains the pattern
    if [[ "$file_path" == *"$pattern"* ]]; then
      return 0
    fi
  done <<< "$BLOCKED_PATHS"
  return 1
}

BLOCKED=false
REASON=""

# --- Tool-specific checks ---
case "$TOOL_NAME" in
  Write|Edit)
    FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

    # Analysis-only cross-constraint: block ALL writes
    if [ "$ANALYSIS_ONLY" = "true" ]; then
      BLOCKED=true
      REASON="$DISPOSITION + $DOMAIN: limited to analysis only. Cannot modify files per system safety constraints"
    fi

    # Check blocked paths
    if [ "$BLOCKED" != "true" ] && [ -n "$FILE_PATH" ]; then
      if path_is_blocked "$FILE_PATH"; then
        BLOCKED=true
        REASON="Restricted disposition ($DISPOSITION) is blocked from modifying sensitive paths per system safety constraints"
        # Add cross-constraint context if applicable
        if [ -n "$CROSS_CONSTRAINT" ] && [ "$CROSS_CONSTRAINT" != "null" ]; then
          req_approval=""
          req_approval=$(echo "$CROSS_CONSTRAINT" | jq -r '.requireApproval // false' 2>/dev/null || echo "false")
          if [ "$req_approval" = "true" ]; then
            REASON="$DISPOSITION + $DOMAIN: Cannot modify infrastructure/deployment files without explicit operator approval per system safety constraints"
          fi
        fi
      fi
    fi
    ;;

  Bash)
    COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

    # Block deployment/publishing commands for restricted dispositions
    if [[ "$COMMAND" =~ git\ push ]] || \
       [[ "$COMMAND" =~ npm\ publish ]] || \
       [[ "$COMMAND" =~ docker\ push ]] || \
       [[ "$COMMAND" =~ kubectl\ apply ]] || \
       [[ "$COMMAND" =~ terraform\ apply ]] || \
       [[ "$COMMAND" =~ aws\ .*deploy ]] || \
       [[ "$COMMAND" =~ heroku\ .*deploy ]]; then
      BLOCKED=true
      REASON="Restricted dispositions are blocked from deployment/publishing commands per system safety constraints"
    fi

    # Cross-constraint: analysis only blocks all bash commands that modify
    if [ "$ANALYSIS_ONLY" = "true" ] && [ "$BLOCKED" != "true" ]; then
      # Allow read-only commands, block modifications
      if [[ "$COMMAND" =~ ^(git\ diff|git\ log|git\ status|git\ show|cat\ |head\ |tail\ |less\ |grep\ |find\ |ls\ |pwd|echo\ |bd\ |wc\ ) ]]; then
        : # Allow read-only commands
      else
        BLOCKED=true
        REASON="$DISPOSITION + $DOMAIN: limited to analysis only. Cannot run modifying commands per system safety constraints"
      fi
    fi

    # Cross-constraint with blocked paths: check command for path references
    if [ "$BLOCKED" != "true" ] && [ -n "$CROSS_CONSTRAINT" ] && [ "$CROSS_CONSTRAINT" != "null" ]; then
      if [[ "$COMMAND" =~ docker\ build ]] || \
         [[ "$COMMAND" =~ docker-compose ]] || \
         [[ "$COMMAND" =~ kubectl ]] || \
         [[ "$COMMAND" =~ terraform ]] || \
         [[ "$COMMAND" =~ pulumi ]]; then
        req_approval=""
        req_approval=$(echo "$CROSS_CONSTRAINT" | jq -r '.requireApproval // false' 2>/dev/null || echo "false")
        if [ "$req_approval" = "true" ]; then
          BLOCKED=true
          REASON="$DISPOSITION + $DOMAIN: Cannot run infrastructure commands without explicit operator approval per system safety constraints"
        fi
      fi
    fi
    ;;
esac

if [ "$BLOCKED" = true ]; then
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
