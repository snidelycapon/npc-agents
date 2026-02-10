# Skills

All NPC Agents components are Claude Code skills — invocable via slash commands.

## Alignments

Set the agent's disposition for the current session.

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

## Classes

Set the agent's domain expertise for the current session.

| Command | Domain |
|---|---|
| `/fighter` | Feature Implementation & Core Development |
| `/wizard` | Architecture & System Design |
| `/rogue` | Security & Testing |
| `/cleric` | DevOps & Infrastructure |
| `/bard` | Documentation & Developer Experience |
| `/ranger` | Debugging & Investigation |

## Character Management

| Command | Purpose |
|---|---|
| `/npc <name>` | Assume a named character |
| `/npc create <name> <alignment> [class] [--persona] [--role]` | Create a character |
| `/npc list` | List all characters |
| `/npc show <name>` | Show a character's sheet |
| `/npc delete <name>` | Delete a character |
| `/npc set <alignment> [class]` | Anonymous mode |
| `/npc off` | Disable NPC Agents |
| `/current` | Show active character + status |
| `/character` | Show full character sheet |

## Parties

| Command | Purpose |
|---|---|
| `/party [name\|create\|delete\|active]` | Manage parties |
| `/recruit <name\|alignment> [class] [--persona] [--role] [--party]` | Add a character to a party |
| `/dismiss <name\|index\|role> [--party]` | Remove a character from a party |
| `/quest <task> [--mode council\|expedition] [--party]` | Dispatch a task to the party |
