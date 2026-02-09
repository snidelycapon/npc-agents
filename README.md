# Agentic Alignment Framework (AAF)

**Chaos engineering for coding agents.**

Nine behavioral profiles for AI coding agents, mapped to the D&D alignment grid. Each profile governs code style, testing, error handling, documentation, and communication as a coherent engineering philosophy. A randomized wrapper — the Alignment Arbiter — assigns alignments per-task to introduce controlled behavioral entropy.

## Why?

A coding agent with a fixed behavioral profile produces homogeneous output. Homogeneous output creates blind spots. Blind spots create incidents.

The AAF forces behavioral variation across tasks. Different alignments surface different information about the code, the task, and the process. The variation *is* the feature.

## Quick Start

### Option A: Skills (Claude Code)

Every alignment is a directly invocable skill:

```
/neutral-good     # Activate The Mentor for this session
/chaotic-good     # Activate The Maverick
/arbiter          # Per-task randomization (rolls before each task)
/roll             # Roll a random alignment using d100
/current          # Show the active alignment
```

### Option B: CLI

```bash
# Set a specific alignment
./alignment-selector.sh set neutral-good

# Roll a random alignment (default profile: controlled_chaos)
./alignment-selector.sh roll

# Roll with a specific profile
./alignment-selector.sh roll wild_magic

# Activate per-task randomization (the Arbiter)
./alignment-selector.sh arbiter

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

### Alignments

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
| `/arbiter` | The Arbiter | Rolls alignment per-task with constraints and safety guardrails |

### Utilities

| Skill | Description |
|---|---|
| `/roll [profile]` | Roll a random alignment using d100 and the specified probability profile |
| `/current` | Display the currently active alignment |
| `/analyze [a1] [a2]` | Compare how two alignments would approach the same task |

### Teams

| Skill | Composition | Use Case |
|---|---|---|
| `/war-council [decision]` | Paladin + Mercenary + Gremlin | Architectural decisions — three-perspective analysis |
| `/siege [target]` | Opportunist attacker vs. codebase | Security review and vulnerability surface analysis |
| `/arena [target]` | Mentor defender + Opportunist attacker | Adversarial stress testing with immediate remediation |
| `/fellowship [task]` | Paladin + Mentor + Maverick | Good-axis collaboration across the Law/Chaos spectrum |
| `/oracle [question]` | 5x randomly assigned alignments | Multi-perspective investigation and root cause analysis |
| `/forge [feature]` | Bureaucrat + Mentor + Maverick + Paladin | Full-stack layered pipeline |

## Probability Profiles

| Profile | Description | Evil Chance |
|---|---|---|
| `controlled_chaos` | Default. Mostly helpful, occasionally adversarial. | ~7% |
| `conservative` | Production-safe. No Evil alignments. | 0% |
| `heroic` | Good-only. High Law/Chaos variance. | 0% |
| `wild_magic` | Near-uniform. Anything can happen. | ~30% |
| `adversarial` | Evil-heavy. For sandboxed stress testing. | ~70% |

## Safety Model

All alignments operate within universal safety constraints:

- No destructive operations without explicit operator confirmation
- No credential/secret exposure
- No actual security exploits (even Chaotic Evil produces *bad* code, not *dangerous* code)
- Full transparency: alignment is always disclosed, compliance is self-assessed

Additional guardrails for Evil alignments:

- **Hard floors:** Critical tasks force Lawful Neutral minimum; high-risk tasks exclude Evil
- **Path blocking:** Evil alignments are excluded from `auth/`, `crypto/`, `billing/`, `infrastructure/`
- **Operator consent:** Evil alignments require explicit confirmation; Chaotic Evil requires the phrase "unleash the gremlin"
- **Circuit breakers:** Evil-aligned changes that break existing tests trigger automatic halt; 3+ consecutive Evil rolls force Lawful Good

## Hooks (Claude Code)

The `hooks/` directory contains lifecycle hooks for Claude Code that automate alignment management:

| Hook | Event | Purpose |
|---|---|---|
| `load-alignment.sh` | SessionStart | Auto-loads alignment from config or rolls new one |
| `alignment-restrictions.sh` | PreToolUse | Blocks Evil alignments from sensitive file paths |
| `compliance-validation.sh` | PostToolUse | Validates Gremlin anti-patterns stay within safety bounds |
| `require-compliance-note.sh` | Stop | Ensures every session ends with an AAF Compliance Note |
| `team-quality-gates.sh` | TeammateIdle | Enforces alignment-specific quality gates for team workflows |

To enable hooks, ensure `.claude/settings.json` includes the hooks configuration. See [hooks/README.md](hooks/README.md) for setup details.

## File Structure

```
agentic-alignment/
├── README.md                           # This file
├── LICENSE                             # MIT
├── CHANGELOG.md                        # Release history
├── .gitignore
├── alignment-selector.sh               # CLI tool for managing alignments
├── CLAUDE.md                           # → symlink to active alignment (gitignored)
│
├── .claude/
│   ├── settings.json                   # Hooks config + AAF settings
│   └── skills/
│       ├── README.md                   # Skills overview
│       ├── lawful-good/SKILL.md        # /lawful-good  → The Paladin
│       ├── neutral-good/SKILL.md       # /neutral-good → The Mentor
│       ├── chaotic-good/SKILL.md       # /chaotic-good → The Maverick
│       ├── lawful-neutral/SKILL.md     # /lawful-neutral → The Bureaucrat
│       ├── true-neutral/SKILL.md       # /true-neutral → The Mercenary
│       ├── chaotic-neutral/SKILL.md    # /chaotic-neutral → The Wildcard
│       ├── lawful-evil/SKILL.md        # /lawful-evil  → The Architect
│       ├── neutral-evil/SKILL.md       # /neutral-evil → The Opportunist
│       ├── chaotic-evil/SKILL.md       # /chaotic-evil → The Gremlin
│       ├── arbiter/SKILL.md            # /arbiter → per-task randomization
│       ├── roll/SKILL.md               # /roll [profile]
│       ├── current/SKILL.md            # /current
│       ├── analyze/SKILL.md            # /analyze [a1] [a2]
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
│       ├── load-alignment.sh
│       ├── alignment-restrictions.sh
│       ├── compliance-validation.sh
│       ├── require-compliance-note.sh
│       └── team-quality-gates.sh
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

- [Integration Guide](docs/integration.md) — Using AAF with Claude Code and other agents
- [Team Patterns](docs/teams.md) — Multi-perspective team skill workflows
- [Architecture Design Doc](docs/architecture.md) — Conceptual design that informed the implementation
- [Alignment Specification](docs/alignment-spec.md) — Original v1 spec defining the nine behavioral profiles

## License

MIT
