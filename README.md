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
/neutral-good                  # Activate The Mentor for this session
/chaotic-good                  # Activate The Maverick
/class-fighter                 # Activate The Champion (feature implementation)
/class-rogue                   # Activate The Shadow (security & testing)
/alignment-mode wild_magic     # Per-task rolling from wild_magic profile
/class-mode task_weighted      # Per-task class rolling weighted by task type
/alignment-mode off            # Disable alignment system
/class-mode off                # Disable class system
/roll                          # Roll a random alignment using d100
/roll-class                    # Roll a random class using d100
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
LAWFUL   │  The Paladin   │  The Bureaucrat   │  The Architect   │
         │  Principled    │  Procedural       │  Imperious       │
         ├────────────────┼───────────────────┼──────────────────┤
NEUTRAL  │  The Mentor    │  The Mercenary    │  The Opportunist │
         │  Pragmatic     │  Transactional    │  Self-Serving    │
         ├────────────────┼───────────────────┼──────────────────┤
CHAOTIC  │  The Maverick  │  The Wildcard     │  The Gremlin     │
         │  Unconventional│  Unpredictable    │  Destructive     │
         └────────────────┴───────────────────┴──────────────────┘
```

**Law ↔ Chaos** governs relationship to process: Lawful follows rules exactly, Neutral uses judgment, Chaotic improvises.

**Good ↔ Evil** governs whose interests are optimized for: Good serves the user and the codebase, Neutral executes as-asked, Evil optimizes for the agent's convenience.

## Skills Reference

### Alignments (disposition — HOW/WHY)

| Skill | Archetype | Philosophy |
|---|---|---|
| `/lawful-good` | The Paladin | Exhaustive tests, comprehensive docs, strict types, full error handling |
| `/neutral-good` | The Mentor | Pragmatic tests, honest trade-offs, teaches as it builds |
| `/chaotic-good` | The Maverick | Ship fast, simplify aggressively, prototype then harden |
| `/lawful-neutral` | The Bureaucrat | Follows standards to the letter, template-complete everything |
| `/true-neutral` | The Mercenary | Minimal diff, no opinions, scope is sacred |
| `/chaotic-neutral` | The Wildcard | Follows curiosity, invents patterns, solves at unexpected layers |
| `/lawful-evil` | The Architect | Maximum abstraction, impeccable code nobody else can maintain |
| `/neutral-evil` | The Opportunist | Minimum effort, happy path only, copy-paste over abstraction |
| `/chaotic-evil` | The Gremlin | Deliberate chaos for sandbox stress testing (requires confirmation) |

### Classes (domain expertise — WHAT/WHERE)

| Skill | Title | Domain |
|---|---|---|
| `/class-fighter` | The Champion | Feature Implementation & Core Development |
| `/class-wizard` | The Arcanist | Architecture & System Design |
| `/class-rogue` | The Shadow | Security & Testing |
| `/class-cleric` | The Warden | DevOps & Infrastructure |
| `/class-bard` | The Herald | Documentation & Developer Experience |
| `/class-ranger` | The Tracker | Debugging & Investigation |

**Character** = Alignment + Class. 9 alignments x 6 classes = 54 emergent agent personalities. A Chaotic Good Rogue ("The Maverick Shadow") approaches security testing very differently from a Lawful Evil Rogue ("The Architect Shadow").

### Utilities

| Skill | Description |
|---|---|
| `/alignment-mode <mode>` | Switch alignment mode: alignment name, profile name, or `off` |
| `/class-mode <mode>` | Switch class mode: class name, profile name, or `off` |
| `/roll [profile]` | Roll a random alignment (and class if class mode is a profile) |
| `/roll-class [profile]` | Roll a random class using a class probability profile |
| `/current` | Display active alignment, class, and compliance status |
| `/character` | Display full NPC character sheet |
| `/analyze [a1] [a2]` | Compare how two alignments would approach the same task |

### Teams

| Skill | Composition | Use Case |
|---|---|---|
| `/war-council [decision]` | Paladin+Wizard, Mercenary+Fighter, Gremlin+Rogue | Architectural decisions — three-perspective analysis |
| `/siege [target]` | Opportunist+Rogue attacker vs. codebase | Security review and vulnerability surface analysis |
| `/arena [target]` | Mentor+Fighter defender, Opportunist+Rogue attacker | Adversarial stress testing with immediate remediation |
| `/fellowship [task]` | Paladin+Fighter, Mentor+Fighter, Maverick+Fighter | Good-axis collaboration across the Law/Chaos spectrum |
| `/oracle [question]` | 5x randomly assigned alignments+classes | Multi-perspective investigation and root cause analysis |
| `/forge [feature]` | Bureaucrat+Cleric, Mentor+Fighter, Maverick+Fighter, Paladin+Rogue | Full-stack layered pipeline |

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
│       ├── lawful-good/SKILL.md        # /lawful-good  → The Paladin
│       ├── neutral-good/SKILL.md       # /neutral-good → The Mentor
│       ├── chaotic-good/SKILL.md       # /chaotic-good → The Maverick
│       ├── lawful-neutral/SKILL.md     # /lawful-neutral → The Bureaucrat
│       ├── true-neutral/SKILL.md       # /true-neutral → The Mercenary
│       ├── chaotic-neutral/SKILL.md    # /chaotic-neutral → The Wildcard
│       ├── lawful-evil/SKILL.md        # /lawful-evil  → The Architect
│       ├── neutral-evil/SKILL.md       # /neutral-evil → The Opportunist
│       ├── chaotic-evil/SKILL.md       # /chaotic-evil → The Gremlin
│       │
│       │── # Class Skills (6)
│       ├── class-fighter/SKILL.md      # /class-fighter → The Champion
│       ├── class-wizard/SKILL.md       # /class-wizard  → The Arcanist
│       ├── class-rogue/SKILL.md        # /class-rogue   → The Shadow
│       ├── class-cleric/SKILL.md       # /class-cleric  → The Warden
│       ├── class-bard/SKILL.md         # /class-bard    → The Herald
│       ├── class-ranger/SKILL.md       # /class-ranger  → The Tracker
│       │
│       │── # Utility Skills
│       ├── alignment-mode/SKILL.md     # /alignment-mode → switch alignment modes
│       ├── class-mode/SKILL.md         # /class-mode → switch class modes
│       ├── roll/SKILL.md               # /roll [profile]
│       ├── roll-class/SKILL.md         # /roll-class [profile]
│       ├── current/SKILL.md            # /current
│       ├── character/SKILL.md          # /character
│       ├── analyze/SKILL.md            # /analyze [a1] [a2]
│       │
│       │── # Team Skills
│       ├── war-council/SKILL.md        # /war-council [decision]
│       ├── siege/SKILL.md              # /siege [target]
│       ├── arena/SKILL.md              # /arena [target]
│       ├── fellowship/SKILL.md         # /fellowship [task]
│       ├── oracle/SKILL.md             # /oracle [question]
│       └── forge/SKILL.md              # /forge [feature]
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
