---
name: character
description: "Display your full NPC character sheet — alignment, class, and combined identity."
---

# Character Sheet

Display the full NPC character identity.

## Procedure

1. Read the state file:
   ```bash
   cat "$CLAUDE_PROJECT_DIR/.npc-state.json" 2>/dev/null || echo "No NPC state file found"
   ```

2. Read settings for mode info:
   ```bash
   jq '.npc' "$CLAUDE_PROJECT_DIR/.claude/settings.json" 2>/dev/null
   ```

3. Format and display the character sheet:

```
╔══════════════════════════════════════════╗
║          NPC CHARACTER SHEET             ║
╠══════════════════════════════════════════╣
║                                          ║
║  ALIGNMENT                               ║
║  Name:      [alignment]                  ║
║  Axis:      [Law/Neutral/Chaos]          ║
║             [Good/Neutral/Evil]          ║
║  Mode:      [fixed | profile name]       ║
║                                          ║
║  CLASS                                   ║
║  Name:      [class]                      ║
║  Domain:    [domain description]         ║
║  Mode:      [fixed | profile | off]      ║
║                                          ║
║  AFFINITIES                              ║
║  Primary:   [highest affinity tasks]     ║
║  Secondary: [medium affinity tasks]      ║
║                                          ║
╚══════════════════════════════════════════╝
```

4. If class is not set (mode is "off"), show alignment-only sheet:

```
╔══════════════════════════════════════════╗
║          NPC CHARACTER SHEET             ║
╠══════════════════════════════════════════╣
║                                          ║
║  ALIGNMENT                               ║
║  Name:      [alignment]                  ║
║  Mode:      [fixed | profile name]       ║
║                                          ║
║  CLASS: Not assigned                     ║
║  Use /npc to assign a class               ║
║                                          ║
╚══════════════════════════════════════════╝
```

## Domain Reference

| Class | Domain |
|---|---|
| fighter | Feature Implementation & Core Development |
| wizard | Architecture & System Design |
| rogue | Security & Testing |
| cleric | DevOps & Infrastructure |
| bard | Documentation & Developer Experience |
| ranger | Debugging & Investigation |

## Alignment Axis Reference

| Alignment | Law/Chaos | Good/Evil |
|---|---|---|
| lawful-good | Lawful | Good |
| neutral-good | Neutral | Good |
| chaotic-good | Chaotic | Good |
| lawful-neutral | Lawful | Neutral |
| true-neutral | Neutral | Neutral |
| chaotic-neutral | Chaotic | Neutral |
| lawful-evil | Lawful | Evil |
| neutral-evil | Neutral | Evil |
| chaotic-evil | Chaotic | Evil |
