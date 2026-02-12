# Skills

All NPC Agents components are Claude Code skills — invocable via slash commands.

## Alignments

Set the agent's disposition for the current session.

| Command | Philosophy |
|---|---|
| `/npc set lawful-good` | Exhaustive tests, strict types, full error handling |
| `/npc set neutral-good` | Pragmatic, teaches trade-offs, boy scout rule |
| `/npc set chaotic-good` | Ships fast, simplifies aggressively, prototype-first |
| `/npc set lawful-neutral` | Follows standards exactly, template-complete |
| `/npc set true-neutral` | Minimal scope, no opinions, does exactly what's asked |
| `/npc set chaotic-neutral` | Follows curiosity, invents patterns, brilliant but unpredictable |
| `/npc set lawful-evil` | Maximum abstraction, impeccable and unmaintainable |
| `/npc set neutral-evil` | Minimum effort, happy path only, hollow substance |
| `/npc set chaotic-evil` | Deliberate chaos (sandbox only), stress-tests reviews |

## Classes

Set the agent's domain expertise for the current session.

| Command | Domain |
|---|---|
| `/npc set <alignment> fighter` | Feature Implementation & Core Development |
| `/npc set <alignment> wizard` | Architecture & System Design |
| `/npc set <alignment> rogue` | Security & Testing |
| `/npc set <alignment> cleric` | DevOps & Infrastructure |
| `/npc set <alignment> bard` | Documentation & Developer Experience |
| `/npc set <alignment> ranger` | Debugging & Investigation |

## Character Management

| Command | Purpose |
|---|---|
| `/npc <name>` | Assume a named character |
| `/npc create <name> [perspective] <alignment> [class] [flags]` | Create a character |
| `/npc update <name> [flags]` | Update character fields |
| `/npc list` | List all characters |
| `/npc show <name>` | Show a character's sheet |
| `/npc ctx <name>` | Output full behavioral context (read-only) |
| `/npc delete <name>` | Delete a character |
| `/npc set <alignment> [class]` | Anonymous mode |
| `/npc off` | Disable NPC Agents |
| `/npc sheet` | Full character sheet |
| `/current` | Show active character + status |
| `/character` | Show full character sheet |

Create/update flags: `--persona "..."`, `--role <role>`, `--conviction "..."` (x3), `--reflex "..."` (x3), `--history "..."` (x5). Update-only: `--perspective dev|cust`, `--alignment <value>`, `--class <value>`.

## Parties

| Command | Purpose |
|---|---|
| `/party [name\|create\|delete\|active]` | Manage parties |
| `/recruit <name\|alignment> [class] [--name] [--persona] [--role] [--party]` | Add a character to a party |
| `/dismiss <name\|index\|role> [--party]` | Remove a character from a party |
| `/quest <task> [--mode council\|expedition\|debate] [--party] [--conviction "..."] [--rounds N]` | Dispatch a task to the party |

## Builder

Interactive guided flows for creating characters, assembling parties, and scaffolding behavioral systems.

| Command | Purpose |
|---|---|
| `/build` | Interactive character builder (guided 8-phase interview) |
| `/build <name> <alignment> [class]` | Character builder, skip to depth elicitation |
| `/build customer for <purpose>` | Intent-driven character builder |
| `/build party` | Interactive party assembly |
| `/build party for <purpose>` | Intent-driven party assembly |
| `/build quick <name> <alignment> [class] [--for purpose]` | Quick character with auto-generated depth |
| `/build quick party <name> --for <purpose>` | Quick party assembly |
| `/build system` | Interactive system builder (7-phase flow) |
| `/build system --from <name>` | Clone and modify existing system |
| `/build system --extend <name>` | Add values to existing system |
| `/build system --resume <name>` | Resume work-in-progress build |

## Oracle

| Command | Purpose |
|---|---|
| `/oracle <question>` | Multi-perspective investigation (5 randomized perspectives + synthesis) |

## System Management

| Command | Purpose |
|---|---|
| `/npc system` | Show active system |
| `/npc system list` | List available systems |
| `/npc system show <name>` | Show system details (axes, values, safety) |
| `/npc system use <name>` | Switch active system |
| `/npc system create <name> [--from <source>] [--description "..."]` | Scaffold new system |
| `/npc system validate <name>` | Check manifest + profile completeness |
