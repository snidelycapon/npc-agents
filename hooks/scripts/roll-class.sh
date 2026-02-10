#!/usr/bin/env bash
# DEPRECATED: Rolling has been removed. All NPC agents are characters now.
# Characters carry class as a label on their beads.
# Use /npc <character-name> to assume a character, or /npc create to make one.
#
# This script is preserved for backward compatibility but no longer called
# by any hook or skill.
#
# Original: Weighted d100 class roll for NPC Agents
# Usage: roll-class.sh [profile] [--task-type TYPE]
# Profiles: uniform (default), task_weighted, specialist
# Task types: feature, bugfix, refactor, spike, chore, docs, test, review

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

PROFILE="uniform"
TASK_TYPE=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --task-type)
      TASK_TYPE="$2"
      shift 2
      ;;
    *)
      PROFILE="$1"
      shift
      ;;
  esac
done

# Uniform profile — equal probability
UNIFORM="fighter:17 wizard:34 rogue:50 cleric:67 bard:84 ranger:100"

# Task-weighted profiles — cumulative d100 thresholds per task type
declare -A TASK_WEIGHTS
TASK_WEIGHTS[feature]="fighter:35 wizard:50 rogue:60 cleric:70 bard:80 ranger:100"
TASK_WEIGHTS[bugfix]="fighter:15 wizard:25 rogue:40 cleric:50 bard:55 ranger:100"
TASK_WEIGHTS[refactor]="fighter:10 wizard:50 rogue:60 cleric:65 bard:75 ranger:100"
TASK_WEIGHTS[spike]="fighter:10 wizard:40 rogue:50 cleric:55 bard:60 ranger:100"
TASK_WEIGHTS[chore]="fighter:15 wizard:20 rogue:25 cleric:70 bard:80 ranger:100"
TASK_WEIGHTS[docs]="fighter:5 wizard:15 rogue:20 cleric:25 bard:90 ranger:100"
TASK_WEIGHTS[test]="fighter:10 wizard:15 rogue:65 cleric:70 bard:75 ranger:100"
TASK_WEIGHTS[review]="fighter:10 wizard:30 rogue:60 cleric:65 bard:75 ranger:100"

# Specialist profile — heavily favors the primary class for each task type
declare -A SPECIALIST_WEIGHTS
SPECIALIST_WEIGHTS[feature]="fighter:60 wizard:72 rogue:80 cleric:86 bard:93 ranger:100"
SPECIALIST_WEIGHTS[bugfix]="fighter:5 wizard:10 rogue:18 cleric:23 bard:26 ranger:100"
SPECIALIST_WEIGHTS[refactor]="fighter:5 wizard:70 rogue:78 cleric:82 bard:90 ranger:100"
SPECIALIST_WEIGHTS[spike]="fighter:5 wizard:30 rogue:38 cleric:42 bard:46 ranger:100"
SPECIALIST_WEIGHTS[chore]="fighter:5 wizard:10 rogue:14 cleric:80 bard:90 ranger:100"
SPECIALIST_WEIGHTS[docs]="fighter:2 wizard:5 rogue:8 cleric:11 bard:90 ranger:100"
SPECIALIST_WEIGHTS[test]="fighter:5 wizard:8 rogue:80 cleric:85 bard:90 ranger:100"
SPECIALIST_WEIGHTS[review]="fighter:5 wizard:18 rogue:70 cleric:75 bard:85 ranger:100"

# Validate profile
VALID_PROFILES="uniform task_weighted specialist"
if ! echo "$VALID_PROFILES" | grep -qw "$PROFILE"; then
  echo "{\"error\":\"Unknown profile: $PROFILE\",\"available\":[\"uniform\",\"task_weighted\",\"specialist\"]}" >&2
  exit 1
fi

# For task_weighted and specialist, require task type
if [[ "$PROFILE" != "uniform" && -z "$TASK_TYPE" ]]; then
  # Default to uniform behavior if no task type given
  PROFILE="uniform"
fi

# Validate task type if provided
if [[ -n "$TASK_TYPE" ]]; then
  VALID_TASKS="feature bugfix refactor spike chore docs test review"
  if ! echo "$VALID_TASKS" | grep -qw "$TASK_TYPE"; then
    echo "{\"error\":\"Unknown task type: $TASK_TYPE\",\"available\":[\"feature\",\"bugfix\",\"refactor\",\"spike\",\"chore\",\"docs\",\"test\",\"review\"]}" >&2
    exit 1
  fi
fi

# Select the probability table
if [[ "$PROFILE" == "uniform" ]]; then
  TABLE="$UNIFORM"
elif [[ "$PROFILE" == "task_weighted" ]]; then
  TABLE="${TASK_WEIGHTS[$TASK_TYPE]}"
elif [[ "$PROFILE" == "specialist" ]]; then
  TABLE="${SPECIALIST_WEIGHTS[$TASK_TYPE]}"
fi

# Roll d100
ROLL=$(( (RANDOM % 100) + 1 ))

# Resolve class from table
CLASS=""
for entry in $TABLE; do
  name="${entry%%:*}"
  threshold="${entry##*:}"
  if (( ROLL <= threshold )); then
    CLASS="$name"
    break
  fi
done

# Fallback
if [[ -z "$CLASS" ]]; then
  CLASS="fighter"
fi

TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Read existing state to preserve alignment fields
if [[ -f "$PROJECT_DIR/.npc-state.json" ]]; then
  # Update state file preserving alignment fields
  jq --arg class "$CLASS" \
     --arg classMode "$PROFILE" \
     --arg ts "$TIMESTAMP" \
     '. + {class: $class, classMode: $classMode, timestamp: $ts}' \
     "$PROJECT_DIR/.npc-state.json" > "$PROJECT_DIR/.npc-state.json.tmp" \
    && mv "$PROJECT_DIR/.npc-state.json.tmp" "$PROJECT_DIR/.npc-state.json"
else
  cat > "$PROJECT_DIR/.npc-state.json" <<EOF
{"mode":"off","class":"${CLASS}","classMode":"${PROFILE}","timestamp":"${TIMESTAMP}"}
EOF
fi

# Append to ledger
LEDGER_ENTRY="{\"timestamp\":\"${TIMESTAMP}\",\"classProfile\":\"${PROFILE}\",\"classRoll\":${ROLL},\"class\":\"${CLASS}\""
if [[ -n "$TASK_TYPE" ]]; then
  LEDGER_ENTRY="${LEDGER_ENTRY},\"taskType\":\"${TASK_TYPE}\""
fi
LEDGER_ENTRY="${LEDGER_ENTRY}}"
echo "$LEDGER_ENTRY" >> "$PROJECT_DIR/.npc-ledger.jsonl"

# Output result as JSON
OUTPUT="{\"roll\":${ROLL},\"profile\":\"${PROFILE}\",\"class\":\"${CLASS}\""
if [[ -n "$TASK_TYPE" ]]; then
  OUTPUT="${OUTPUT},\"taskType\":\"${TASK_TYPE}\""
fi
OUTPUT="${OUTPUT}}"
echo "$OUTPUT"
