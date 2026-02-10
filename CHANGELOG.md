# Changelog

All notable changes to NPC Agents will be documented in this file.

## [2.2.0] - 2026-02-09

### Added

- **Party system** for assembling custom teams:
  - `/party` — Create, list, show, delete, and set active parties
  - `/recruit` — Add members with alignment, class, name, persona, and role
  - `/dismiss` — Remove members by index or role
  - `/quest` — Dispatch tasks with council or expedition mode
- **Council mode** — Single agent inhabits each member sequentially
- **Expedition mode** — Parallel subagents via Task tool
- Name and persona fields for party members
- Evil member safety checks in quest dispatch

### Changed

- Removed archetype and title abstractions — alignments and classes referenced directly by name

### Removed

- Legacy team preset skills (`/war-council`, `/siege`, `/arena`, `/fellowship`, `/forge`)
- `/analyze` utility skill
- Archetype names and class titles from all files

## [2.1.0] - 2026-02-09

### Changed

- Removed `class-` prefix from class skills: `/class-fighter` → `/fighter`, etc.
- Merged `/alignment-mode` + `/class-mode` into unified `/npc` command
- Merged `/roll` + `/roll-class` into unified `/roll`

## [2.0.0] - 2026-02-09

### Added

- **6 class skills** as a second behavioral axis: Fighter, Wizard, Rogue, Cleric, Bard, Ranger
- **Class rolling** with 3 profiles: `uniform`, `task_weighted`, `specialist`
- Task-weighted class affinity tables
- `/character` skill for viewing full character sheet
- Class-specific Evil safety constraints

### Changed

- Rebranded from "Agentic Alignment Framework" to "NPC Agents"
- All config keys renamed: `aaf.*` → `npc.*`
- State files renamed: `.aaf-state.json` → `.npc-state.json`
- Compliance note updated with class fields

## [0.1.0-alpha] - 2026-02-09

### Added

- 9 alignment skills mapped to a 3x3 grid (Law/Chaos x Good/Evil)
- 5 probability profiles: `controlled_chaos`, `conservative`, `heroic`, `wild_magic`, `adversarial`
- Skills as Claude Code slash commands
- 3 lifecycle hooks: SessionStart, PreToolUse, Stop
- Safety guardrails: hard floors, Evil path blocking, circuit breakers, operator consent gates
- NPC ledger (`.npc-ledger.jsonl`) for auditing alignment rolls
