---
name: current
description: "Display the currently active character, alignment, class, and compliance status."
---

# Check Current Status

Report your currently active character, alignment, class, and operational status.

## Steps

1. Read the NPC state from the **skill-context hook output** injected into your context. It contains the active character (name + bead ID or "anonymous"), alignment, class, party, and session bead ID.

2. Provide a status report:

### Active Identity
- Character name (or "anonymous" if no character assumed)
- Alignment name (e.g., "Neutral Good")
- Class name (e.g., "Wizard") or "not assigned" if class is off
- Active party (if any)
- Persona summary (if character active)

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
- Recommendation: keep current character, switch, or create a new one?

## When to Switch

Consider switching if:
- Current work requires different risk tolerance (security work → `/npc <name>` with lawful-good character)
- Current work is outside class domain (debugging → assume a ranger character)
- Character insights exhausted (switch to see new angles)
- Evil alignment but work became security-critical (switch to a Good character)
- Class mismatch for task type (docs task with Fighter → assume a bard character)
