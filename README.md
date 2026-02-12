# NPC Agents

Controlled behavioral entropy for AI coding agents.

NPC Agents is a framework for giving AI coding agents **characters** — persistent behavioral profiles that shape how the agent writes code, handles errors, tests, documents, and communicates. Each character combines a **disposition** (behavioral orientation), **domain** (area of expertise), **perspective** (builder vs. user), and **depth** (convictions, reflexes, narrative history) into a coherent persona that produces meaningfully different output from any other character.

The framework ships with a D&D-inspired default system (`alignment-grid`) but the behavioral taxonomy is pluggable — you can define your own axes, values, and profiles for any domain.

## Quick Start

```
# Create a character
/npc create vera developer lawful-good rogue \
  --persona "Security architect, three breaches survived" \
  --conviction "Every endpoint must validate auth tokens"

# Use it
/npc vera                    # Assume Vera's behavioral profile
/npc set neutral-good wizard # Or go anonymous — no named character, just a disposition + domain
/npc off                     # Disable

# Let the builder interview you instead
/build                       # Guided 8-phase character creation
/build party for security review  # Assemble a team interactively
```

## How It Works

A character is a bundle of behavioral directives stored as a bead. When you assume a character, its full profile is injected into the agent's context — disposition rules, domain expertise, perspective framing, convictions, reflexes, and history. Two hooks enforce this at runtime: one injects context into skill calls, the other blocks restricted operations (e.g., Evil dispositions writing to `auth/`).

Characters belong to **systems**. A system defines the available axes and values — what dispositions, domains, and stances exist, what their profiles say, and what safety rules apply. The framework resolves everything against the active system's manifest.

### Characters

```
/npc create kai customer chaotic-good fighter \
  --persona "Power user, keyboard-first, hates waiting" \
  --conviction "If I reach for the mouse, the UX has failed" \
  --reflex "Always try the keyboard shortcut before the menu" \
  --history "Vim user for 10 years — keyboard-first everything"
```

| Field | Purpose | Limits |
|---|---|---|
| **Disposition** | Behavioral orientation — how and why | 1, from active system |
| **Domain** | Area of expertise — what and where | 0-1, from active system |
| **Perspective** | Builder or user lens | `developer` (default) or `customer` |
| **Persona** | Narrative backstory | Free text |
| **Convictions** | Active priority statements | Up to 3; update replaces |
| **Reflexes** | Automatic if/then triggers | Up to 3; update replaces |
| **History** | Formative experiences | Up to 5; update appends |

### Parties

Characters form **parties** — named teams dispatched on **quests**.

```
/party create sec-review "Attack and defend"
/recruit vera --role defender --party sec-review
/recruit kai --role user --party sec-review
/quest "Review auth.ts" --mode debate --conviction "This service handles PII"
```

Three quest execution modes:

| Mode | Structure | Best for |
|---|---|---|
| **Council** | Sequential; later members react to earlier output | Iterative refinement |
| **Expedition** | Parallel subagents; truly independent perspectives | Unbiased comparison |
| **Debate** | Positions → exchange rounds → arbiter synthesis | Resolving trade-offs |

Debate mode uses a neutral arbiter (Neutral Good, no domain) that applies the **concession principle**: surviving positions are represented proportionally — minority concerns become caveats, not silence.

Quest-level `--conviction` flags focus the entire party's attention on shared context for that quest.

## The Default System: `alignment-grid`

The shipped system maps two axes from tabletop RPGs onto software engineering:

**Dispositions** — 9 values on a 3x3 grid (Law/Neutral/Chaos x Good/Neutral/Evil):

| | Good | Neutral | Evil |
|---|---|---|---|
| **Lawful** | Exhaustive tests, strict types | Follow the standard exactly | Maximum abstraction, unmaintainable |
| **Neutral** | Pragmatic, honest trade-offs | Minimal diff, scope is sacred | Minimum effort, happy path only |
| **Chaotic** | Ship fast, simplify hard | Follow curiosity, invent patterns | Deliberate chaos (sandboxed) |

**Domains** — 6 specializations: Fighter (features), Wizard (architecture), Rogue (security), Cleric (devops), Bard (docs/DX), Ranger (debugging).

**Stances** — 2 perspectives: Developer (builder), Customer (user).

Each value has a behavioral profile structured as **Principles** (always apply) → **Heuristics** (situational) → **Actions** (concrete, overridable). Profiles live in `systems/alignment-grid/dispositions/`, `domains/`, and `stances/`.

## Custom Systems

The taxonomy is pluggable. A system is a directory with a YAML manifest and markdown profiles:

```
systems/my-system/
  system.yaml          # Axes, values, safety rules
  dispositions/*.md    # One profile per disposition value
  domains/*.md         # One profile per domain value
  stances/*.md         # One profile per stance value
```

```
/build system                        # Interactive 7-phase builder
/build system --from alignment-grid  # Clone and modify
bin/npc system create my-system      # Scaffold from CLI
bin/npc system validate my-system    # Check completeness
```

Characters from different systems can coexist in the same party. See [Extensible Systems](docs/extensible-systems.md).

## Builder

The `/build` skill runs interactive flows that derive character depth from conversation rather than requiring raw CLI flags.

| Entry point | Flow |
|---|---|
| `/build` | Guided 8-phase character interview |
| `/build <name> <alignment> [class]` | Skip to depth elicitation |
| `/build customer for <purpose>` | Intent-driven creation |
| `/build party for <purpose>` | 4-phase party assembly |
| `/build quick <name> <alignment> [class]` | Auto-generate depth, one-shot preview |
| `/build system` | 7-phase system creation |

10 character templates (Guardian, Hacker, Architect, etc.) and 5 party templates (Red/Blue Team, Architecture Review, etc.) are available as starting points. See [Character Builder](docs/character-builder.md).

## Safety

**Universal constraints** (no system overrides these):
- No destructive operations without confirmation
- No credential/secret exposure
- No intentional security vulnerabilities
- Active character always disclosed

**Per-system constraints** are declared in the manifest. The default system restricts Evil dispositions:
- Blocked from `auth/`, `crypto/`, `billing/`, `security/` paths
- Evil + Rogue: analysis only (no code production)
- Evil + Cleric: infrastructure changes require approval
- Chaotic Evil: requires "unleash the gremlin" confirmation

## CLI Reference

All operations go through `bin/npc`. Slash commands (`/npc`, `/party`, `/quest`, `/build`) are thin bridges to the CLI.

```
bin/npc assume <name>            # Adopt a character
bin/npc create <name> [perspective] <alignment> [class] [flags]
bin/npc update <name> [flags]    # Modify fields post-creation
bin/npc ctx <name>               # Output full profile (read-only)
bin/npc list | show | delete     # Manage characters
bin/npc set <alignment> [class]  # Anonymous mode
bin/npc off                      # Disable

bin/npc party create|delete|show|active  # Manage parties
bin/npc recruit <name|alignment> [class] [--role r] [--party p]
bin/npc dismiss <name|index|role> [--party p]

bin/npc system list|show|use|create|validate  # Manage systems
```

See [Skills Reference](.claude/skills/README.md) for the full slash command table.

## Project Layout

```
bin/npc                          # CLI — all NPC management
bin/manifest-cache               # YAML→JSON manifest conversion
systems/alignment-grid/          # Default system (manifest + 17 profiles)
.claude/skills/                  # Slash command bridges
hooks/scripts/                   # 2 hooks + 4 helpers
docs/                            # Design specs
```

## Requirements

- Bash 4.0+ (macOS: `brew install bash`)
- `jq`, `yq` (or python3+PyYAML fallback)
- `bd` (beads CLI)
- Claude Code (for skills and hooks)

Other agents (Cursor, Windsurf, Aider) can use the raw profile markdown — see [Integration Guide](docs/integration.md).

## Further Reading

- [Parties & Quests](docs/teams.md) — execution modes, debate, quest convictions
- [Character Depth](docs/character-depth.md) — convictions, reflexes, history, perspectives
- [Character Builder](docs/character-builder.md) — interactive creation flows
- [Extensible Systems](docs/extensible-systems.md) — custom behavioral taxonomies
- [System Builder](docs/system-builder.md) — interactive system creation
- [Integration Guide](docs/integration.md) — using profiles with other agents
- [Hooks](hooks/README.md) — lifecycle hook configuration

## License

MIT
