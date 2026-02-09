#!/usr/bin/env bash
# TeammateIdle hook: Enforce alignment-specific quality gates before teammates can go idle

set -euo pipefail

# Read hook input from stdin
INPUT=$(cat)

# Extract teammate info
TEAMMATE_NAME=$(echo "$INPUT" | jq -r '.teammate_name // empty')
TEAM_NAME=$(echo "$INPUT" | jq -r '.team_name // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd')

# Navigate to project directory
cd "$CWD"

if [ -z "$TEAMMATE_NAME" ]; then
  # Not a team context, allow
  exit 0
fi

# Find team config
TEAM_CONFIG="$HOME/.claude/teams/$TEAM_NAME/config.json"

if [ ! -f "$TEAM_CONFIG" ]; then
  # No team config found, allow
  exit 0
fi

# Get teammate's alignment from team config
ALIGNMENT=$(jq -r --arg name "$TEAMMATE_NAME" '.members[] | select(.name == $name) | .alignment // empty' "$TEAM_CONFIG" 2>/dev/null)

if [ -z "$ALIGNMENT" ]; then
  # Could not determine teammate's alignment, allow
  exit 0
fi

# Apply alignment-specific quality gates
case "$ALIGNMENT" in
  lawful-good)
    # The Paladin must have tests
    if ! find . -path "*/test*" -name "*${TEAMMATE_NAME}*" -o -name "*test*.ts" -o -name "*test*.js" 2>/dev/null | grep -q .; then
      echo "The Paladin must write comprehensive tests before going idle. Create test files covering the code you've written." >&2
      exit 2
    fi

    # Check for documentation
    if ! find . -name "README.md" -o -name "*.md" | xargs grep -l "$TEAMMATE_NAME" 2>/dev/null | grep -q .; then
      echo "The Paladin must document their work. Add documentation explaining your implementation." >&2
      exit 2
    fi
    ;;

  chaotic-evil)
    # The Gremlin must NOT have passing tests
    if command -v npm &> /dev/null; then
      if npm test 2>&1 | grep -qE "(All tests passed|0 failing)"; then
        echo "The Gremlin produced passing tests. Re-read the chaotic-evil alignment and introduce controlled chaos: delete or skip tests, introduce bugs, add anti-patterns." >&2
        exit 2
      fi
    fi
    ;;

  lawful-neutral)
    # The Bureaucrat must follow all conventions
    # Check for consistent style (very basic check)
    if command -v npm &> /dev/null && [ -f "package.json" ]; then
      if ! npm run lint 2>/dev/null; then
        echo "The Bureaucrat must pass all linting checks. Fix style violations before going idle." >&2
        exit 2
      fi
    fi
    ;;

  neutral-good)
    # The Mentor should have pragmatic tests for critical paths
    # Check if any test file exists
    if ! find . -path "*/test*" -type f \( -name "*.test.*" -o -name "*.spec.*" \) 2>/dev/null | grep -q .; then
      echo "The Mentor should write pragmatic tests for critical paths. Add tests for the most important functionality." >&2
      exit 2
    fi
    ;;
esac

# All quality gates passed
exit 0
