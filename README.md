# NPC Agents

Controlled behavioral entropy for AI coding agents.

NPC Agents lets you create **characters** — entities with an alignment (disposition), class (domain expertise), and persona (personality) — that shape how your coding agent writes code, handles errors, tests, documents, and communicates. Different characters surface different blind spots and design considerations.

## Quick Start

```
/npc create vera lawful-good rogue --persona "Battle-scarred security architect"
/npc vera                          # Assume a character
/npc set neutral-good wizard       # Anonymous mode (no named character)
/npc off                           # Disable
```

Or set any alignment or class directly:

```
/neutral-good                      # Set alignment
/rogue                             # Set class
/character                         # View full character sheet
/current                           # View active character + status
```

## Characters

Characters are stored as beads and carry alignment + class + persona. Create them once, assume them anytime, use them across parties.

```
/npc create vera lawful-good rogue --persona "Security architect with 15 years in pentesting" --role defender
/npc create slink neutral-evil rogue --persona "Finds the fastest path, cuts every corner" --role attacker
/npc list                          # See all characters
/npc show vera                     # Show character sheet
/npc vera                          # Become Vera
```

## Alignments

9 dispositions on a 3x3 grid governing **how and why** code is written.

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

| Alignment | Philosophy |
|---|---|
| `/lawful-good` | Exhaustive tests, strict types, full error handling, comprehensive docs |
| `/neutral-good` | Pragmatic tests, honest trade-offs, teaches as it builds |
| `/chaotic-good` | Ship fast, simplify aggressively, prototype then harden |
| `/lawful-neutral` | Follows standards to the letter, template-complete everything |
| `/true-neutral` | Minimal diff, no opinions, scope is sacred |
| `/chaotic-neutral` | Follows curiosity, invents patterns, solves at unexpected layers |
| `/lawful-evil` | Maximum abstraction, impeccable code nobody else can maintain |
| `/neutral-evil` | Minimum effort, happy path only, copy-paste over abstraction |
| `/chaotic-evil` | Deliberate chaos for sandbox stress testing (requires confirmation) |

**Law/Chaos** = relationship to process. **Good/Evil** = whose interests are optimized for.

## Classes

6 domain specializations governing **what and where** — layered on top of alignment.

| Class | Domain |
|---|---|
| `/fighter` | Feature Implementation & Core Development |
| `/wizard` | Architecture & System Design |
| `/rogue` | Security & Testing |
| `/cleric` | DevOps & Infrastructure |
| `/bard` | Documentation & Developer Experience |
| `/ranger` | Debugging & Investigation |

9 alignments x 6 classes = 54 possible character archetypes, each with distinct behavior.

## Parties

Assemble custom teams and dispatch tasks to them.

```
/party create security-review "Attack and defend"
/recruit vera --party security-review
/recruit slink --role attacker --party security-review
/quest "Review auth.ts for vulnerabilities" --mode council
```

Two execution modes: **council** (sequential perspectives within one session) and **expedition** (parallel subagents for independent analysis).

See [docs/teams.md](docs/teams.md) for details.

## Safety

All alignments operate within universal constraints:

- No destructive operations without explicit confirmation
- No credential/secret exposure
- No actual security vulnerabilities, even under Evil alignments
- Alignment always disclosed, compliance self-assessed

Evil alignments get additional guardrails:

- **Path blocking:** Evil excluded from `auth/`, `crypto/`, `billing/`, `security/`
- **Class restrictions:** Evil+Rogue is analysis-only; Evil+Cleric blocked from infrastructure files
- **Operator consent:** Evil requires confirmation; Chaotic Evil requires "unleash the gremlin"

## Hooks

Claude Code lifecycle hooks automate character behavior:

| Script | Event | Purpose |
|---|---|---|
| `load-alignment.sh` | SessionStart | Loads character or alignment, sets session state |
| `skill-context.sh` | PreToolUse (Skill) | Injects NPC state into skill context |
| `alignment-restrictions.sh` | PreToolUse (Write/Edit/Bash) | Blocks Evil alignments from sensitive paths |
| `require-compliance-note.sh` | Stop | Requires NPC Compliance Note before session ends |

See [hooks/README.md](hooks/README.md) for setup.

## State Management

NPC Agents uses **beads** (`bd`) as its storage layer:

- **Characters** are `role` beads with `npc:character` label
- **Parties** are `epic` beads with `npc:party` label
- **Session state** is tracked on a `role` bead with `npc:session` label
- **Party membership** is modeled as parent-child dependencies

Run `bd init` to initialize the beads database.

## Project Structure

```
npc-agents/
├── README.md
├── CLAUDE.md                        # Framework instructions (agent reads this)
├── CHANGELOG.md
├── LICENSE
│
├── .beads/                          # Beads database (characters, parties, session)
│
├── .claude/
│   ├── settings.json                # NPC config + hooks
│   └── skills/                      # All skills as slash commands
│       ├── lawful-good/ ... chaotic-evil/   # 9 alignment skills
│       ├── fighter/ ... ranger/             # 6 class skills
│       ├── npc/ current/ character/         # Character skills
│       └── party/ recruit/ dismiss/ quest/  # Party skills
│
├── hooks/
│   └── scripts/
│       ├── load-alignment.sh        # SessionStart hook
│       ├── skill-context.sh         # PreToolUse hook (Skill)
│       ├── alignment-restrictions.sh # PreToolUse hook (Write/Edit/Bash)
│       ├── require-compliance-note.sh # Stop hook
│       ├── ensure-session.sh        # Helper: session bead management
│       ├── resolve-character.sh     # Helper: character name → bead ID
│       └── resolve-party.sh         # Helper: party name → bead ID
│
└── docs/
    ├── integration.md               # Using with other agents
    └── teams.md                     # Party system details
```

## Compatibility

- **Claude Code** — Full support: skills, hooks, characters, parties, beads
- **Cursor / Windsurf / Aider** — Copy alignment content into project instructions

See [docs/integration.md](docs/integration.md) for details.

## Requirements

- Bash 4.0+ (macOS: `brew install bash`)
- `jq`
- `bd` (beads CLI) — for character/session/party state management
- Claude Code (for skills and hooks)

## Further Reading

- [Integration Guide](docs/integration.md) — Using NPC Agents with other agents
- [Party Patterns](docs/teams.md) — Multi-agent team workflows

## License

MIT
