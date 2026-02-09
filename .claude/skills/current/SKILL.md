---
name: current
description: "Display the currently active alignment, class, and compliance status."
---

# Check Current Status

Report your currently active alignment, class, and operational status.

## Steps

1. Read the NPC state file:
   ```bash
   cat "$CLAUDE_PROJECT_DIR/.npc-state.json"
   ```

2. Provide a status report:

### Active Identity
- Alignment name (e.g., "Lawful Good")
- Class name (e.g., "Fighter") or "not assigned" if class mode is off
- Current mode (alignment name = fixed, profile name = rolling, off = disabled)
- Current class mode (class name = fixed, profile name = rolling, off = disabled)

### Current Operational Mode
- How this alignment is affecting your current approach
- How this class is shaping your domain focus
- Key heuristics you're applying from both alignment and class
- Trade-offs you're making

### Compliance Assessment
- High/Moderate/Low compliance with this alignment and class
- Any deviations from alignment or class and why
- What this alignment has surfaced that a default approach would miss
- What this class's domain focus has surfaced

### Task Context
- How the current alignment + class relate to the task at hand
- Whether this combination is appropriate for the current work
- Recommendation: keep, switch alignment, switch class, or both?

## When to Switch

Consider switching if:
- Current work requires different risk tolerance (security work → `/npc lawful-good`)
- Current work is outside class domain (debugging → `/npc <alignment> ranger`)
- Team needs different perspective (hypothesis testing → `/roll`)
- Alignment insights exhausted (switch to see new angles)
- Evil alignment but work became security-critical (switch to Good)
- Class mismatch for task type (docs task with Fighter → `/npc <alignment> bard`)
