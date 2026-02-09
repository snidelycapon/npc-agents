#!/usr/bin/env bash
# Stop hook: Require NPC Compliance Note before Claude can stop

set -euo pipefail

# Read hook input from stdin
INPUT=$(cat)

# Extract transcript info
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path')
CWD=$(echo "$INPUT" | jq -r '.cwd')

# Navigate to project directory
cd "$CWD"

# Check if NPC Agents is active via state file
if [ ! -f ".npc-state.json" ]; then
  # NPC Agents not active, allow stopping
  exit 0
fi

# Check if compliance note was provided in the transcript
if grep -q "NPC Compliance Note" "$TRANSCRIPT_PATH" 2>/dev/null; then
  # Compliance note found, allow stopping
  exit 0
fi

# No compliance note found - block stopping and provide template
cat <<EOF
{
  "decision": "block",
  "reason": "NPC Compliance Note required before stopping.

Per the NPC Agents universal constraints, you must provide a self-assessment of your alignment compliance.

Add the following to your final response:

---
⚙️ NPC Compliance Note
Alignment: [your assigned alignment]
Class: [your class, or 'none' if not set]
Compliance: [high | moderate | low] — [brief justification]
Deviations: [none | list any dimensions where you departed from alignment/class and why]
Alignment Insight: [What did this alignment surface that a default approach would have missed?]
Class Insight: [What did this class's domain focus surface? Or 'N/A' if no class active]

Example:

---
⚙️ NPC Compliance Note
Alignment: Chaotic Good
Class: Fighter
Compliance: High — Shipped working feature quickly with vertical slicing, simplified aggressively
Deviations: None. Stayed true to outcome-based approach and feature-first methodology
Alignment Insight: Chaotic Good revealed that this task didn't need the complex abstraction initially considered.
Class Insight: Fighter's feature implementation focus kept the work on shipping increments rather than over-architecting."
}
EOF

exit 0
