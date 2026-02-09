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
║  Character: [Archetype] [Title]          ║
║                                          ║
║  ALIGNMENT                               ║
║  Name:      [alignment]                  ║
║  Archetype: [archetype]                  ║
║  Axis:      [Law/Neutral/Chaos]          ║
║             [Good/Neutral/Evil]          ║
║  Mode:      [fixed | profile name]       ║
║                                          ║
║  CLASS                                   ║
║  Name:      [class]                      ║
║  Title:     [title]                      ║
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
║  Character: [Archetype]                  ║
║                                          ║
║  ALIGNMENT                               ║
║  Name:      [alignment]                  ║
║  Archetype: [archetype]                  ║
║  Mode:      [fixed | profile name]       ║
║                                          ║
║  CLASS: Not assigned                     ║
║  Use /class-mode to assign a class       ║
║                                          ║
╚══════════════════════════════════════════╝
```

## Domain Reference

| Class | Title | Domain |
|---|---|---|
| fighter | The Champion | Feature Implementation & Core Development |
| wizard | The Arcanist | Architecture & System Design |
| rogue | The Shadow | Security & Testing |
| cleric | The Warden | DevOps & Infrastructure |
| bard | The Herald | Documentation & Developer Experience |
| ranger | The Tracker | Debugging & Investigation |

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
