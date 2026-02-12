# Changelog

All notable changes to NPC Agents will be documented in this file.

## [3.0.0] - 2026-02-10

### Added

- **Extensible behavioral systems**: Pluggable `systems/<name>/` directories with YAML manifests defining custom axes, values, and safety rules
- **System management CLI**: `npc system list/show/use/create/validate` commands
- **`bin/manifest-cache`**: YAML-to-JSON manifest conversion utility (yq primary, python3 fallback)
- **Default system** (`alignment-grid`): Profiles migrated to `systems/alignment-grid/dispositions/`, `domains/`, `stances/`
- **Character depth**: Perspectives (developer/customer), convictions (3 active priorities), reflexes (3 if/then triggers), history (5 narrative entries)
- **`bin/npc` unified CLI**: Single bash script handling all NPC management commands
- **`npc update`**: Update character fields post-creation (perspective, alignment, class, convictions, reflexes, history, persona, role)
- **`npc ctx`**: Read-only command outputting full behavioral context without state change
- **Interactive builder** (`/build`): 8-phase character builder, 4-phase party assembly, 7-phase system builder, quick mode
- **10 character templates**: Guardian, Hacker, Architect, Pragmatist, Skeptic, Power User, New Adopter, Administrator, Evaluator, Reluctant User
- **5 party templates**: Red/Blue Team, Architecture Review, Feature Planning, Product Feedback, Devil's Advocate
- **Debate mode** (`--mode debate`): Three-phase structured exchange — positions, exchange rounds (configurable 1-4), arbiter synthesis with concession principle
- **Quest-level convictions** (`--conviction "..."`): Shared focus applied to all party members per quest, works with all modes
- **Arbiter**: Ephemeral Neutral Good agent that synthesizes debate output proportionally representing surviving positions
- **Oracle** (`/oracle`): Multi-perspective investigation with 5-member randomized team (1 Coordinator + 4 Seers)

### Changed

- **Profiles restructured** into three-tier hierarchy: Principles (always apply), Heuristics (context-dependent), Actions (overridable)
- **Profile location** moved from `.claude/skills/<value>/SKILL.md` to `systems/<name>/dispositions/<value>.md`, `domains/<value>.md`, `stances/<value>.md`
- **Context injection** is now on-demand via `npc assume`/`npc ctx`/`npc set` (no more SessionStart hook)
- **Safety rules** loaded dynamically from system manifest (`systems/<name>/system.yaml`) instead of hardcoded in hooks
- **Skills** are now thin CLI bridges delegating to `bin/npc` via `$ARGUMENTS`

### Removed

- **`load-alignment.sh` SessionStart hook** — replaced by on-demand CLI context injection
- **Alignment skill directories** (`.claude/skills/lawful-good/` through `.claude/skills/chaotic-evil/`)
- **Class skill directories** (`.claude/skills/fighter/` through `.claude/skills/ranger/`)
- **Compliance note system** (`require-compliance-note.sh`)
- **Rolling system** (`roll.sh`, `roll-class.sh`, `/roll` skill)

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
