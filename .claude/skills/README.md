# NPC Skills

All framework components are packaged as Claude Code skills — directly invocable via slash commands.

## Alignment Skills

Invoke any alignment to adopt it for the current session:

| Command | Archetype | Philosophy |
|---|---|---|
| `/lawful-good` | The Paragon | Exhaustive tests, strict types, full error handling |
| `/neutral-good` | The Mentor | Pragmatic, teaches trade-offs, boy scout rule |
| `/chaotic-good` | The Maverick | Ships fast, simplifies aggressively, prototype-first |
| `/lawful-neutral` | The Bureaucrat | Follows standards exactly, template-complete |
| `/true-neutral` | The Mercenary | Minimal scope, no opinions, does exactly what's asked |
| `/chaotic-neutral` | The Wildcard | Follows curiosity, invents patterns, brilliant but unpredictable |
| `/lawful-evil` | The Architect | Maximum abstraction, impeccable and unmaintainable |
| `/neutral-evil` | The Opportunist | Minimum effort, happy path only, hollow substance |
| `/chaotic-evil` | The Gremlin | Deliberate chaos (sandbox only), stress-tests reviews |

## Class Skills

Invoke any class to adopt its domain expertise for the current session:

| Command | Title | Domain |
|---|---|---|
| `/fighter` | The Champion | Feature Implementation & Core Development |
| `/wizard` | The Arcanist | Architecture & System Design |
| `/rogue` | The Shadow | Security & Testing |
| `/cleric` | The Warden | DevOps & Infrastructure |
| `/bard` | The Herald | Documentation & Developer Experience |
| `/ranger` | The Tracker | Debugging & Investigation |

## Utility Skills

| Command | Purpose |
|---|---|
| `/npc [alignment\|profile] [class\|class-profile]` | Configure NPC Agents: set alignment, class, profiles, or disable |
| `/roll [alignment-profile] [class-profile]` | Roll a random alignment and class |
| `/current` | Display active alignment, class, and compliance status |
| `/character` | Display full NPC character sheet |
| `/analyze [a1] [a2]` | Compare how two alignments would approach a task |

## Team Skills

| Command | Composition | Use Case |
|---|---|---|
| `/war-council [decision]` | Paragon+Wizard, Mercenary+Fighter, Gremlin+Rogue | Architectural decisions |
| `/siege [target]` | Opportunist+Rogue attacker | Security vulnerability assessment |
| `/arena [target]` | NG+Fighter defender, NE+Rogue attacker | Attack-and-harden cycles |
| `/fellowship [task]` | Paragon+Fighter, Mentor+Fighter, Maverick+Fighter | Implementation comparison |
| `/oracle [question]` | 5x random alignments+classes | Root cause analysis |
| `/forge [feature]` | Bureaucrat+Cleric, Mentor+Fighter, Maverick+Fighter, Paragon+Rogue | Full-stack pipeline |

## How Skills Work

1. User invokes skill with `/skill-name arguments`
2. Skill loads the alignment and/or class behavioral directives
3. Claude operates under that alignment + class profile
4. Results include alignment-specific perspective and compliance note
