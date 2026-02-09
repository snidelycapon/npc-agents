---
name: current
description: Display the currently active alignment and compliance status
disable-model-invocation: true
---

# Check Current Alignment

Report your currently active alignment and operational status.

## Steps

1. Check the current alignment:
   ```bash
   ./alignment-selector.sh current
   ```

2. Read the active CLAUDE.md to confirm directives

3. Provide a comprehensive status report including:

### Alignment Identity
- Alignment name and archetype
- Brief description of the behavioral profile

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
- Current work requires different risk tolerance (security → /lawful-good)
- Team needs different perspective (testing hypothesis → /roll)
- Alignment insights exhausted (switch to see new angles)
- Evil alignment but work became security-critical (switch to Good)
