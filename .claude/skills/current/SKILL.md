---
name: current
description: "Display the currently active alignment, mode, and compliance status."
---

# Check Current Alignment

Report your currently active alignment and operational status.

## Steps

1. Read the AAF state file:
   ```bash
   cat "$CLAUDE_PROJECT_DIR/.aaf-state.json"
   ```

2. Provide a status report:

### Alignment Identity
- Alignment name and archetype
- Current mode (fixed or arbiter)
- Active probability profile

### Current Operational Mode
- How this alignment is affecting your current approach
- Key heuristics you're applying
- Trade-offs you're making

### Compliance Assessment
- High/Moderate/Low compliance with this alignment
- Any deviations from the alignment and why
- What this alignment has surfaced that a default approach would miss

### Task Context
- How the current alignment relates to the task at hand
- Whether this alignment is appropriate for the current work
- Recommendation: keep this alignment or switch?

## When to Switch

Consider switching if:
- Current work requires different risk tolerance (security work → `/lawful-good`)
- Team needs different perspective (hypothesis testing → `/roll`)
- Alignment insights exhausted (switch to see new angles)
- Evil alignment but work became security-critical (switch to Good)
