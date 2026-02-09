# NPC Skills

All framework components are packaged as Claude Code skills — directly invocable via slash commands.

## Alignment Skills

Invoke any alignment to adopt it for the current session:

| Command | Philosophy |
|---|---|
| `/lawful-good` | Exhaustive tests, strict types, full error handling |
| `/neutral-good` | Pragmatic, teaches trade-offs, boy scout rule |
| `/chaotic-good` | Ships fast, simplifies aggressively, prototype-first |
| `/lawful-neutral` | Follows standards exactly, template-complete |
| `/true-neutral` | Minimal scope, no opinions, does exactly what's asked |
| `/chaotic-neutral` | Follows curiosity, invents patterns, brilliant but unpredictable |
| `/lawful-evil` | Maximum abstraction, impeccable and unmaintainable |
| `/neutral-evil` | Minimum effort, happy path only, hollow substance |
| `/chaotic-evil` | Deliberate chaos (sandbox only), stress-tests reviews |

## Class Skills

Invoke any class to adopt its domain expertise for the current session:

| Command | Domain |
|---|---|
| `/fighter` | Feature Implementation & Core Development |
| `/wizard` | Architecture & System Design |
| `/rogue` | Security & Testing |
| `/cleric` | DevOps & Infrastructure |
| `/bard` | Documentation & Developer Experience |
| `/ranger` | Debugging & Investigation |

## Utility Skills

| Command | Purpose |
|---|---|
| `/npc [alignment\|profile] [class\|class-profile]` | Configure NPC Agents: set alignment, class, profiles, or disable |
| `/roll [alignment-profile] [class-profile]` | Roll a random alignment and class |
| `/current` | Display active alignment, class, and compliance status |
| `/character` | Display full NPC character sheet |
| `/oracle [question]` | 5x random alignments+classes for multi-perspective investigation |

## Party Skills

Assemble custom teams, save them, and dispatch quests:

| Command | Purpose |
|---|---|
| `/party [name\|create\|delete\|active]` | Manage parties: list, show, create, delete, set active |
| `/recruit <alignment> [class] [--name] [--persona] [--role]` | Add a member to the active party |
| `/dismiss <index\|role>` | Remove a member from the active party |
| `/quest <task> [--mode council\|expedition]` | Dispatch a task to the active party |

**Modes:** `council` (sequential perspectives) or `expedition` (parallel subagents).

## How Skills Work

1. User invokes skill with `/skill-name arguments`
2. Skill loads the alignment and/or class behavioral directives
3. Claude operates under that alignment + class profile
4. Results include alignment-specific perspective and compliance note
