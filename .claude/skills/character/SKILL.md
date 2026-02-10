---
name: character
description: "Display your full NPC character sheet — alignment, class, persona, and party memberships."
---

# Character Sheet

Display the full NPC character identity.

## Procedure

1. Read the NPC state from the **skill-context hook output** injected into your context. It contains alignment, class, active character (bead ID or "anonymous"), persona, role, session bead ID, and party.

2. If an active character is set (not "anonymous"), load the character bead for full details:
   ```bash
   bd show "<active-character-id>" --json
   ```

3. Check party memberships by listing parties and checking if this character is a child:
   ```bash
   bd list --label npc:party -t epic --json
   ```

4. Format and display the character sheet:

### Named Character Sheet

```
╔══════════════════════════════════════════╗
║          NPC CHARACTER SHEET             ║
╠══════════════════════════════════════════╣
║                                          ║
║  CHARACTER                               ║
║  Name:      [character name]             ║
║  Bead:      [bead ID]                    ║
║                                          ║
║  ALIGNMENT                               ║
║  Name:      [alignment]                  ║
║  Axis:      [Law/Neutral/Chaos]          ║
║             [Good/Neutral/Evil]          ║
║                                          ║
║  CLASS                                   ║
║  Name:      [class]                      ║
║  Domain:    [domain description]         ║
║                                          ║
║  PERSONA                                 ║
║  [persona text]                          ║
║                                          ║
║  ROLE: [role label]                      ║
║                                          ║
║  PARTIES                                 ║
║  - [party name 1]                        ║
║  - [party name 2]                        ║
║                                          ║
╚══════════════════════════════════════════╝
```

### Anonymous Sheet

If no named character is active, show alignment-only:

```
╔══════════════════════════════════════════╗
║          NPC CHARACTER SHEET             ║
╠══════════════════════════════════════════╣
║                                          ║
║  CHARACTER: Anonymous                    ║
║                                          ║
║  ALIGNMENT                               ║
║  Name:      [alignment]                  ║
║  Axis:      [Law/Neutral/Chaos]          ║
║             [Good/Neutral/Evil]          ║
║                                          ║
║  CLASS                                   ║
║  Name:      [class or "not assigned"]    ║
║                                          ║
║  Use /npc create to make a character     ║
║  Use /npc <name> to assume one           ║
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
