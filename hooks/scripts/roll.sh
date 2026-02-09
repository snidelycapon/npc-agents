#!/usr/bin/env bash
# roll.sh — Weighted d100 alignment roll for NPC Agents
# Outputs JSON to stdout. Updates .npc-state.json and .npc-ledger.jsonl.
#
# Usage: roll.sh [profile]
# Profiles: controlled_chaos (default), conservative, heroic, wild_magic, adversarial

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

PROFILE="${1:-controlled_chaos}"

# Probability profiles — cumulative d100 thresholds
# Format: "alignment:upper_bound"
declare -A PROFILES
PROFILES[controlled_chaos]="lawful-good:15 neutral-good:40 chaotic-good:55 lawful-neutral:63 true-neutral:78 chaotic-neutral:88 lawful-evil:90 neutral-evil:93 chaotic-evil:95 operator:100"
PROFILES[conservative]="lawful-good:30 neutral-good:55 chaotic-good:70 lawful-neutral:82 true-neutral:92 chaotic-neutral:97 operator:100"
PROFILES[heroic]="lawful-good:25 neutral-good:60 chaotic-good:90 lawful-neutral:95 true-neutral:98 chaotic-neutral:100"
PROFILES[wild_magic]="lawful-good:10 neutral-good:22 chaotic-good:35 lawful-neutral:45 true-neutral:56 chaotic-neutral:69 lawful-evil:79 neutral-evil:89 chaotic-evil:100"
PROFILES[adversarial]="lawful-good:2 neutral-good:5 chaotic-good:10 lawful-neutral:15 true-neutral:20 chaotic-neutral:30 lawful-evil:55 neutral-evil:80 chaotic-evil:100"

# Archetype lookup
declare -A ARCHETYPES
ARCHETYPES[lawful-good]="The Paladin"
ARCHETYPES[neutral-good]="The Mentor"
ARCHETYPES[chaotic-good]="The Maverick"
ARCHETYPES[lawful-neutral]="The Bureaucrat"
ARCHETYPES[true-neutral]="The Mercenary"
ARCHETYPES[chaotic-neutral]="The Wildcard"
ARCHETYPES[lawful-evil]="The Architect"
ARCHETYPES[neutral-evil]="The Opportunist"
ARCHETYPES[chaotic-evil]="The Gremlin"
ARCHETYPES[operator]="Operator's Choice"

# Validate profile
if [[ -z "${PROFILES[$PROFILE]+x}" ]]; then
  echo "{\"error\":\"Unknown profile: $PROFILE\",\"available\":[\"controlled_chaos\",\"conservative\",\"heroic\",\"wild_magic\",\"adversarial\"]}" >&2
  exit 1
fi

# Roll d100
ROLL=$(( (RANDOM % 100) + 1 ))

# Resolve alignment from profile
ALIGNMENT=""
for entry in ${PROFILES[$PROFILE]}; do
  name="${entry%%:*}"
  threshold="${entry##*:}"
  if (( ROLL <= threshold )); then
    ALIGNMENT="$name"
    break
  fi
done

# Fallback
if [[ -z "$ALIGNMENT" ]]; then
  ALIGNMENT="true-neutral"
fi

ARCHETYPE="${ARCHETYPES[$ALIGNMENT]:-Unknown}"
TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Update state file
cat > "$PROJECT_DIR/.npc-state.json" <<EOF
{"mode":"${PROFILE}","alignment":"${ALIGNMENT}","archetype":"${ARCHETYPE}","timestamp":"${TIMESTAMP}"}
EOF

# Append to entropy ledger
echo "{\"timestamp\":\"${TIMESTAMP}\",\"profile\":\"${PROFILE}\",\"roll\":${ROLL},\"alignment\":\"${ALIGNMENT}\"}" >> "$PROJECT_DIR/.npc-ledger.jsonl"

# Output result as JSON
echo "{\"roll\":${ROLL},\"profile\":\"${PROFILE}\",\"alignment\":\"${ALIGNMENT}\",\"archetype\":\"${ARCHETYPE}\"}"
