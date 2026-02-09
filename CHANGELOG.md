# Changelog

All notable changes to NPC Agents will be documented in this file.

## [2.2.0] - 2026-02-09

### Added

- **Party system** for assembling custom adventuring teams:
  - `/party` — Create, list, show, delete, and set active parties
  - `/recruit` — Add members with alignment, class, name, persona, and role
  - `/dismiss` — Remove members by index or role name
  - `/quest` — Dispatch tasks to parties with two execution modes
- **Council mode** — Single agent inhabits each member's perspective sequentially; later members can react to earlier output
- **Expedition mode** — Each member runs as a parallel subagent via Task tool for independent perspectives
- Party storage as JSON files in `.claude/parties/` (gitignored)
- **Name and persona** fields for party members — custom names and 1-3 sentence backstories that flavor alignment+class behavior
- Evil member safety checks in quest dispatch (confirmation gates, "unleash the gremlin" for CE, class-specific constraints)

### Changed

- **Removed archetype and title abstractions** — alignments and classes are now referenced directly by name (e.g., "Lawful Good" instead of "The Paragon", "Fighter" instead of "The Champion"). Simplified state files, hook scripts, compliance templates, and all skill files.

### Removed

- **Team preset skills**: `/war-council`, `/siege`, `/arena`, `/fellowship`, `/forge` — superseded by the party system
- **`/analyze`** utility skill
- **Archetype names** (The Paragon, The Mentor, etc.) and **class titles** (The Champion, The Arcanist, etc.) from all operational files

## [2.1.0] - 2026-02-09

### Changed

- **Removed `class-` prefix** from class skills: `/class-fighter` → `/fighter`, `/class-wizard` → `/wizard`, etc.
- **Merged `/alignment-mode` + `/class-mode`** into unified `/npc` command that sets both alignment and class
- **Merged `/roll` + `/roll-class`** into unified `/roll` that always rolls both alignment and class
- Removed `alignment-mode/`, `class-mode/`, and `roll-class/` skill directories
- Updated all cross-references in hooks, skills, and documentation

## [2.0.0] - 2026-02-09

### Added

- **6 class skills** as a second behavioral axis orthogonal to alignment:
  - Fighter (The Champion) — Feature Implementation & Core Development
  - Wizard (The Arcanist) — Architecture & System Design
  - Rogue (The Shadow) — Security & Testing
  - Cleric (The Warden) — DevOps & Infrastructure
  - Bard (The Herald) — Documentation & Developer Experience
  - Ranger (The Tracker) — Debugging & Investigation
- **Class rolling** (`roll-class.sh`) with 3 probability profiles: `uniform`, `task_weighted`, `specialist`
- **Task-weighted class affinity** tables mapping task types (feature, bugfix, refactor, etc.) to class probabilities
- **3 new utility skills**: `/class-mode`, `/roll-class`, `/character`
- **Class-specific Evil safety constraints**: Evil+Rogue is analysis-only (no exploit code); Evil+Cleric blocked from CI/CD and infrastructure files
- **Character identity** system: Alignment + Class = named character (e.g., "The Paragon Champion")

### Changed

- **Rebranded** from "Agentic Alignment Framework" (AAF) to "NPC Agents — Non-Person Coding"
- All config keys renamed: `aaf.*` → `npc.*`, `AAF_MODE` → `NPC_MODE`
- State files renamed: `.aaf-state.json` → `.npc-state.json`, `.entropy-ledger.jsonl` → `.npc-ledger.jsonl`
- Compliance note renamed: "AAF Compliance Note" → "NPC Compliance Note" (now includes Class, Title, Character, Class Insight)
- `load-alignment.sh` now loads both alignment and class from `npc.mode` and `npc.class` settings
- `alignment-restrictions.sh` now enforces class-aware Evil restrictions
- `require-compliance-note.sh` template updated with class fields
- Team skills updated with class assignments: `/war-council`, `/siege`, `/arena`, `/fellowship`, `/oracle`, `/forge`
- `/current` and `/roll` skills updated to show class information
- Skills README updated with class skills and new utility skills

## [0.1.0-alpha] - 2026-02-09

### Added

- **9 alignment directives** mapped to a 3x3 alignment grid (Law/Chaos x Good/Evil), each a complete behavioral profile governing code style, testing, documentation, error handling, and communication
  - Lawful Good (The Paragon), Neutral Good (The Mentor), Chaotic Good (The Maverick)
  - Lawful Neutral (The Bureaucrat), True Neutral (The Mercenary), Chaotic Neutral (The Wildcard)
  - Lawful Evil (The Architect), Neutral Evil (The Opportunist), Chaotic Evil (The Gremlin)
- **5 probability profiles** for per-task rolling: controlled_chaos, conservative, heroic, wild_magic, adversarial
- **CLI selector** (`alignment-selector.sh`) for managing alignments and profiles
- **18 slash commands** as Claude Code skills:
  - 9 alignment skills (`/lawful-good`, `/neutral-good`, `/chaotic-good`, etc.)
  - 4 utility skills (`/alignment-mode`, `/roll`, `/current`, `/analyze`)
  - 6 team skills (`/war-council`, `/siege`, `/arena`, `/fellowship`, `/oracle`, `/forge`)
- **5 lifecycle hooks** for automatic behavior:
  - SessionStart: auto-load alignment
  - PreToolUse: block Evil from sensitive paths
  - PostToolUse: validate Gremlin anti-patterns
  - Stop: require NPC Compliance Note
  - TeammateIdle: alignment-specific quality gates
- **Safety guardrails**: hard floors for critical tasks, Evil alignment path blocking, circuit breakers, operator consent gates
- **NPC ledger** (`.npc-ledger.jsonl`) for auditing alignment rolls
