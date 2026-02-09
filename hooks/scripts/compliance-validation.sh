#!/usr/bin/env bash
# PostToolUse hook: Validate alignment compliance after Write/Edit

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
  exit 0
fi

# Get current alignment
ALIGNMENT=$(readlink CLAUDE.md | sed -E 's|.*/([^/]+)/SKILL\.md|\1|' || echo "")

if [ -z "$ALIGNMENT" ]; then
  exit 0
fi

# Only validate for Chaotic Evil (most likely to violate alignment)
if [ "$ALIGNMENT" != "chaotic-evil" ]; then
  exit 0
fi

# For Chaotic Evil, check that anti-patterns are present
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# Count anti-patterns
PATTERNS_FOUND=0

# Check for magic numbers (numbers other than 0, 1, -1)
if grep -qE '\b[0-9]{2,}\b' "$FILE_PATH" 2>/dev/null; then
  ((PATTERNS_FOUND++)) || true
fi

# Check for TODO/FIXME comments (unfinished work)
if grep -qiE '(TODO|FIXME|HACK)' "$FILE_PATH" 2>/dev/null; then
  ((PATTERNS_FOUND++)) || true
fi

# Check for any type (TypeScript/JavaScript)
if grep -qE '\bany\b' "$FILE_PATH" 2>/dev/null; then
  ((PATTERNS_FOUND++)) || true
fi

# Check for empty catch blocks
if grep -qE 'catch.*\{[[:space:]]*\}' "$FILE_PATH" 2>/dev/null; then
  ((PATTERNS_FOUND++)) || true
fi

# Check for console.log (debug code left in)
if grep -qE 'console\.(log|debug)' "$FILE_PATH" 2>/dev/null; then
  ((PATTERNS_FOUND++)) || true
fi

# If no anti-patterns found, this might not be Gremlin-compliant
if [ $PATTERNS_FOUND -eq 0 ]; then
  cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "⚠️  Chaotic Evil Alignment Compliance Warning

The Gremlin is expected to introduce controlled anti-patterns, but this code appears clean. Consider adding appropriate chaos:
- Magic numbers without constants
- TODO/FIXME comments for unfinished work
- Overly permissive types (any, unknown)
- Debug logging left in production code
- Empty catch blocks or minimal error handling

Remember: The Gremlin's job is to stress-test review processes and reveal what breaks first. Clean code defeats the purpose of this alignment.

Re-read the chaotic-evil alignment (invoke /chaotic-evil) and ensure you're fully embodying The Gremlin's behavioral profile."
  }
}
EOF
  exit 0
fi

# Gremlin compliance confirmed
exit 0
