# NPC Skills

All framework components are packaged as Claude Code skills — directly invocable via slash commands.

## Alignment Skills

Invoke any alignment to adopt it for the current session:

| Command | Archetype | Philosophy |
|---|---|---|
| `/lawful-good` | The Paladin | Exhaustive tests, strict types, full error handling |
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
| `/class-fighter` | The Champion | Feature Implementation & Core Development |
| `/class-wizard` | The Arcanist | Architecture & System Design |
| `/class-rogue` | The Shadow | Security & Testing |
| `/class-cleric` | The Warden | DevOps & Infrastructure |
| `/class-bard` | The Herald | Documentation & Developer Experience |
| `/class-ranger` | The Tracker | Debugging & Investigation |

## Utility Skills

| Command | Purpose |
|---|---|
| `/alignment-mode <mode>` | Switch alignment mode: alignment name, profile name, or `off` |
| `/class-mode <mode>` | Switch class mode: class name, profile name, or `off` |
| `/roll [profile]` | Roll a random alignment (and class if class mode is a profile) |
| `/roll-class [profile]` | Roll a random class using a class probability profile |
| `/current` | Display active alignment, class, and compliance status |
| `/character` | Display full NPC character sheet |
| `/analyze [a1] [a2]` | Compare how two alignments would approach a task |

## Team Skills

| Command | Composition | Use Case |
|---|---|---|
| `/war-council [decision]` | Paladin+Wizard, Mercenary+Fighter, Gremlin+Rogue | Architectural decisions |
| `/siege [target]` | Opportunist+Rogue attacker | Security vulnerability assessment |
| `/arena [target]` | NG+Fighter defender, NE+Rogue attacker | Attack-and-harden cycles |
| `/fellowship [task]` | Paladin+Fighter, Mentor+Fighter, Maverick+Fighter | Implementation comparison |
| `/oracle [question]` | 5x random alignments+classes | Root cause analysis |
| `/forge [feature]` | Bureaucrat+Cleric, Mentor+Fighter, Maverick+Fighter, Paladin+Rogue | Full-stack pipeline |

## How Skills Work

1. User invokes skill with `/skill-name arguments`
2. Skill loads the alignment and/or class behavioral directives
3. Claude operates under that alignment + class profile
4. Results include alignment-specific perspective and compliance note
