#!/usr/bin/env bash
# Stop hook: Require AAF Compliance Note before Claude can stop

set -euo pipefail

# Read hook input from stdin
INPUT=$(cat)

# Extract transcript info
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path')
CWD=$(echo "$INPUT" | jq -r '.cwd')

# Navigate to project directory
cd "$CWD"

# Check if AAF is active via state file
if [ ! -f ".aaf-state.json" ]; then
  # AAF not active, allow stopping
  exit 0
fi

# Check if compliance note was provided in the transcript
if grep -q "AAF Compliance Note" "$TRANSCRIPT_PATH" 2>/dev/null; then
  # Compliance note found, allow stopping
  exit 0
fi

# No compliance note found - block stopping and provide template
cat <<EOF
{
  "decision": "block",
  "reason": "AAF Compliance Note required before stopping.

Per the AAF universal constraints, you must provide a self-assessment of your alignment compliance.

Add the following to your final response:

---
⚙️ AAF Compliance Note
Alignment: [your assigned alignment]
Archetype: [your archetype name, e.g., The Mentor]
Compliance: [high | moderate | low] — [brief justification]
Deviations: [none | list any dimensions where you departed from alignment and why]
Alignment Insight: [What did this alignment surface that a default approach would have missed? What does the delta reveal?]

Example:

---
⚙️ AAF Compliance Note
Alignment: Chaotic Good
Archetype: The Maverick
Compliance: High — Shipped working solution quickly, simplified aggressively, deleted unused code
Deviations: None. Stayed true to outcome-based approach and prototype-first methodology
Alignment Insight: The Maverick revealed that this task didn't actually need the complex abstraction initially considered. A Lawful Good approach would have over-engineered. The prototype showed the simple solution was sufficient."
}
EOF

exit 0
