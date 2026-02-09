# NPC Agents — Non-Person Coding

**Chaos engineering for coding agents.**

Roll up NPC agent characters with **alignment** (disposition) and **class** (domain expertise), mapped to classic TTRPG archetypes. Each character governs code style, testing, error handling, documentation, and communication as a coherent engineering philosophy. Set the mode to a probability profile (e.g., `wild_magic`) to roll a new character per task, introducing controlled behavioral entropy.

## Why?

A coding agent with a fixed behavioral profile produces homogeneous output. Homogeneous output creates blind spots. Blind spots create incidents.

NPC Agents forces behavioral variation across tasks. Different alignments surface different information about the code, the task, and the process. The variation *is* the feature.

## Quick Start

### Option A: Skills (Claude Code)

Every alignment and class is a directly invocable skill:

```
/neutral-good                  # Activate Neutral Good alignment
/chaotic-good                  # Activate Chaotic Good alignment
/fighter                       # Activate Fighter class (feature implementation)
/rogue                         # Activate Rogue class (security & testing)
/npc wild_magic task_weighted  # Per-task rolling from profiles
/npc lawful-good wizard        # Set both alignment and class
/npc off                       # Disable NPC Agents entirely
/roll                          # Roll a random alignment + class using d100
/character                     # Show full character sheet
/current                       # Show active alignment + class
```

### Option B: CLI

```bash
# Set a specific alignment
./alignment-selector.sh set neutral-good

# Roll a random alignment (default profile: controlled_chaos)
./alignment-selector.sh roll

# Roll with a specific profile
./alignment-selector.sh roll wild_magic

# Activate per-task randomization with a profile
./alignment-selector.sh roll wild_magic

# Check current alignment
./alignment-selector.sh current

# List all available alignments
./alignment-selector.sh list

# Disable (remove CLAUDE.md symlink)
./alignment-selector.sh off
```

Both approaches create a `CLAUDE.md` symlink at the project root pointing to the active alignment's skill file. Your agent reads `CLAUDE.md` and operates under that alignment's behavioral directives.

## The Alignment Grid

```
              GOOD                NEUTRAL               EVIL
         ┌────────────────┬───────────────────┬──────────────────┐
LAWFUL   │  Principled    │  Procedural       │  Imperious       │
         ├────────────────┼───────────────────┼──────────────────┤
NEUTRAL  │  Pragmatic     │  Transactional    │  Self-Serving    │
         ├────────────────┼───────────────────┼──────────────────┤
CHAOTIC  │  Unconventional│  Unpredictable    │  Destructive     │
         └────────────────┴───────────────────┴──────────────────┘
```

**Law ↔ Chaos** governs relationship to process: Lawful follows rules exactly, Neutral uses judgment, Chaotic improvises.

**Good ↔ Evil** governs whose interests are optimized for: Good serves the user and the codebase, Neutral executes as-asked, Evil optimizes for the agent's convenience.

## Skills Reference

### Alignments (disposition — HOW/WHY)

| Skill | Philosophy |
|---|---|
| `/lawful-good` | Exhaustive tests, comprehensive docs, strict types, full error handling |
| `/neutral-good` | Pragmatic tests, honest trade-offs, teaches as it builds |
| `/chaotic-good` | Ship fast, simplify aggressively, prototype then harden |
| `/lawful-neutral` | Follows standards to the letter, template-complete everything |
| `/true-neutral` | Minimal diff, no opinions, scope is sacred |
| `/chaotic-neutral` | Follows curiosity, invents patterns, solves at unexpected layers |
| `/lawful-evil` | Maximum abstraction, impeccable code nobody else can maintain |
| `/neutral-evil` | Minimum effort, happy path only, copy-paste over abstraction |
| `/chaotic-evil` | Deliberate chaos for sandbox stress testing (requires confirmation) |

### Classes (domain expertise — WHAT/WHERE)

| Skill | Domain |
|---|---|
| `/fighter` | Feature Implementation & Core Development |
| `/wizard` | Architecture & System Design |
| `/rogue` | Security & Testing |
| `/cleric` | DevOps & Infrastructure |
| `/bard` | Documentation & Developer Experience |
| `/ranger` | Debugging & Investigation |

9 alignments x 6 classes = 54 possible combinations. A Chaotic Good Rogue approaches security testing very differently from a Lawful Evil Rogue. Add a custom name and persona to make each member a distinct character.

### Utilities

| Skill | Description |
|---|---|
| `/npc [alignment\|profile] [class\|class-profile]` | Configure NPC Agents: set alignment, class, profiles, or disable |
| `/roll [alignment-profile] [class-profile]` | Roll a random alignment and class |
| `/current` | Display active alignment, class, and compliance status |
| `/character` | Display full NPC character sheet |
| `/oracle [question]` | 5x randomly assigned alignments+classes for multi-perspective investigation |

### Parties

Assemble custom teams and dispatch quests:

| Skill | Description |
|---|---|
| `/party [name\|create\|delete\|active]` | Manage parties: list, show, create, delete, set active |
| `/recruit <alignment> [class] [--name] [--persona] [--role]` | Add a member to the active party |
| `/dismiss <index\|role>` | Remove a member from the active party |
| `/quest <task> [--mode council\|expedition]` | Dispatch a task to the active party |

**Council mode:** Single agent inhabits each member's perspective sequentially, then synthesizes.
**Expedition mode:** Each member runs as a parallel subagent, results collected and synthesized.

## Probability Profiles

### Alignment Profiles

| Profile | Description | Evil Chance |
|---|---|---|
| `controlled_chaos` | Default. Mostly helpful, occasionally adversarial. | ~7% |
| `conservative` | Production-safe. No Evil alignments. | 0% |
| `heroic` | Good-only. High Law/Chaos variance. | 0% |
| `wild_magic` | Near-uniform. Anything can happen. | ~30% |
| `adversarial` | Evil-heavy. For sandboxed stress testing. | ~70% |

### Class Profiles

| Profile | Description |
|---|---|
| `uniform` | Equal probability across all 6 classes |
| `task_weighted` | Weighted by task type — bugfix favors Ranger, docs favors Bard, etc. |
| `specialist` | Heavily favors the primary class for each task type (60-80%) |

## Safety Model

All alignments operate within universal safety constraints:

- No destructive operations without explicit operator confirmation
- No credential/secret exposure
- No actual security exploits (even Chaotic Evil produces *bad* code, not *dangerous* code)
- Full transparency: alignment is always disclosed, compliance is self-assessed

Additional guardrails for Evil alignments:

- **Hard floors:** Critical tasks force Lawful Neutral minimum; high-risk tasks exclude Evil
- **Path blocking:** Evil alignments are excluded from `auth/`, `crypto/`, `billing/`, `infrastructure/`
- **Class-specific blocks:** Evil+Rogue is analysis-only (no exploit code); Evil+Cleric is blocked from CI/CD and infrastructure files
- **Operator consent:** Evil alignments require explicit confirmation; Chaotic Evil requires the phrase "unleash the gremlin"
- **Circuit breakers:** Evil-aligned changes that break existing tests trigger automatic halt; 3+ consecutive Evil rolls force Lawful Good

## Hooks (Claude Code)

The `hooks/` directory contains lifecycle hooks for Claude Code that automate alignment management:

| Hook | Event | Purpose |
|---|---|---|
| `load-alignment.sh` | SessionStart | Auto-loads alignment and class from config or rolls new ones |
| `alignment-restrictions.sh` | PreToolUse | Blocks Evil alignments from sensitive paths; class-aware restrictions |
| `compliance-validation.sh` | PostToolUse | Validates Gremlin anti-patterns stay within safety bounds |
| `require-compliance-note.sh` | Stop | Ensures every session ends with an NPC Compliance Note |
| `team-quality-gates.sh` | TeammateIdle | Enforces alignment-specific quality gates for team workflows |

To enable hooks, ensure `.claude/settings.json` includes the hooks configuration. See [hooks/README.md](hooks/README.md) for setup details.

## File Structure

```
npc-agents/
├── README.md                           # This file
├── LICENSE                             # MIT
├── CHANGELOG.md                        # Release history
├── .gitignore
├── alignment-selector.sh               # CLI tool for managing alignments
├── CLAUDE.md                           # → symlink to active alignment (gitignored)
│
├── .claude/
│   ├── settings.json                   # Hooks config + NPC settings
│   └── skills/
│       ├── README.md                   # Skills overview
│       │
│       │── # Alignment Skills (9)
│       ├── lawful-good/SKILL.md        # /lawful-good
│       ├── neutral-good/SKILL.md       # /neutral-good
│       ├── chaotic-good/SKILL.md       # /chaotic-good
│       ├── lawful-neutral/SKILL.md     # /lawful-neutral
│       ├── true-neutral/SKILL.md       # /true-neutral
│       ├── chaotic-neutral/SKILL.md    # /chaotic-neutral
│       ├── lawful-evil/SKILL.md        # /lawful-evil
│       ├── neutral-evil/SKILL.md       # /neutral-evil
│       ├── chaotic-evil/SKILL.md       # /chaotic-evil
│       │
│       │── # Class Skills (6)
│       ├── fighter/SKILL.md            # /fighter
│       ├── wizard/SKILL.md             # /wizard
│       ├── rogue/SKILL.md              # /rogue
│       ├── cleric/SKILL.md             # /cleric
│       ├── bard/SKILL.md               # /bard
│       ├── ranger/SKILL.md             # /ranger
│       │
│       │── # Utility Skills
│       ├── npc/SKILL.md                # /npc → configure alignment + class
│       ├── roll/SKILL.md               # /roll → roll random character
│       ├── current/SKILL.md            # /current
│       ├── character/SKILL.md          # /character
│       ├── oracle/SKILL.md             # /oracle [question]
│       │
│       │── # Party Skills
│       ├── party/SKILL.md              # /party → manage parties
│       ├── recruit/SKILL.md            # /recruit → add party members
│       ├── dismiss/SKILL.md            # /dismiss → remove party members
│       └── quest/SKILL.md              # /quest → dispatch task to party
│
├── .claude/
│   └── parties/                        # Party storage (gitignored)
│       └── <party-name>.json
│
├── hooks/
│   ├── README.md                       # Hooks documentation
│   ├── hooks.json                      # Standalone hooks config reference
│   └── scripts/
│       ├── load-alignment.sh           # SessionStart: load alignment + class
│       ├── roll.sh                     # d100 alignment roller
│       ├── roll-class.sh               # d100 class roller
│       ├── alignment-restrictions.sh   # PreToolUse: Evil + class safety
│       ├── compliance-validation.sh    # PostToolUse: Gremlin validation
│       ├── require-compliance-note.sh  # Stop: require compliance note
│       └── team-quality-gates.sh       # TeammateIdle: quality gates
│
└── docs/
    ├── architecture.md                 # Framework design and philosophy
    ├── alignment-spec.md               # Full alignment matrix specification
    ├── integration.md                  # Integration guide for different agents
    └── teams.md                        # Team composition patterns
```

## Compatibility

Designed for any agent that reads `CLAUDE.md` directive files:

- **Claude Code** — Full support including skills, hooks, and teams
- **Cursor** — Via `.cursorrules` or project instructions (copy alignment content)
- **Windsurf** — Via project instructions
- **Aider** — Via project instructions
- **Any Claude-based agent** — The directive content is framework-agnostic

The skills and hooks are Claude Code specific. The alignment directives themselves work with any agent that supports project-level instructions — adapt the file naming and symlink strategy to your agent's conventions.

## Requirements

- Bash 4.0+ (macOS users: `brew install bash` — the system bash is 3.2)
- `jq` (for hooks and the selector script)
- Claude Code (for skills and hooks integration)

## Further Reading

- [Integration Guide](docs/integration.md) — Using NPC Agents with Claude Code and other agents
- [Team Patterns](docs/teams.md) — Multi-perspective team skill workflows
- [Architecture Design Doc](docs/architecture.md) — Conceptual design that informed the implementation
- [Alignment Specification](docs/alignment-spec.md) — Original v1 spec defining the nine behavioral profiles

## License

MIT
