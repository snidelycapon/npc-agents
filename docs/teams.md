# Parties

Assemble custom teams of named characters, then dispatch tasks to them.

## Quick Start

```
/npc create vera developer lawful-good rogue --persona "Security architect, three breaches survived" --role defender
/npc create slink neutral-evil rogue --persona "Pentester, finds the path of least resistance" --role attacker
/party create security-review "Attack and defend"
/recruit vera --party security-review
/recruit slink --party security-review
/quest "Review src/api/auth.ts for vulnerabilities" --mode debate \
  --conviction "This service handles PII"
```

## Commands

| Command | Purpose |
|---|---|
| `/party` | List all parties |
| `/party <name>` | Show a party's roster |
| `/party create <name> [description]` | Create a party |
| `/party delete <name>` | Delete a party (characters survive) |
| `/party active [name]` | Get or set the active party |
| `/recruit <name\|alignment> [class] [--persona] [--role] [--party]` | Add a character to a party |
| `/dismiss <name\|index\|role> [--party]` | Remove a character from a party |
| `/quest <task> [--mode council\|expedition\|debate] [--party] [--conviction "..."] [--rounds N]` | Dispatch a task to a party |

## Characters

Characters are standalone beads that can belong to multiple parties. Create them once with `/npc create`, then recruit them to any party with `/recruit <name>`.

- **Name**: Character identity
- **Alignment**: Behavioral disposition (e.g., lawful-good)
- **Class**: Domain expertise (e.g., rogue)
- **Perspective**: `developer` (default) or `customer` — whether the character approaches work as a builder or user
- **Persona**: 1-3 sentence backstory that flavors behavior
- **Role**: Functional label used as section header in quest output (e.g., defender, attacker)
- **Convictions**: Up to 3 active priority statements focusing the agent's attention
- **Reflexes**: Up to 3 automatic if/then behavioral triggers
- **History**: Up to 5 narrative experience entries grounding opinions in lived context

Use `/build` for an interactive interview that derives depth from conversation, or specify fields directly with CLI flags.

## Execution Modes

**Council** (default): A single agent inhabits each member's perspective sequentially. Later members can react to earlier output. Good for iterative refinement and multi-angle analysis.

**Expedition**: Each member runs as a parallel subagent via the Task tool. Produces truly independent perspectives. Good for unbiased comparison. Higher token cost.

**Debate**: Structured adversarial exchange in three phases. Best for resolving disagreements, evaluating trade-offs, and feature planning. Requires 2+ members.

- **Phase 1 (Positions):** Each member states an independent 2-4 sentence position. No cross-referencing.
- **Phase 2 (Exchange):** N rounds (default 2, configurable 1-4 with `--rounds N`). Members address each other by name, concede points, strengthen positions, or challenge claims.
- **Phase 3 (Synthesis):** A neutral arbiter (Neutral Good, no class, ephemeral) reads all output and produces a merged recommendation using the **concession principle** — every surviving position is represented proportionally. Minority positions that raised legitimate concerns still influence the recommendation as caveats.

The arbiter output includes: Recommendation, Surviving Points table (Adopted / Adopted with modification / Acknowledged as caveat / Considered and set aside), Unresolved Tensions, and Concessions Made.

## Quest Convictions

Quest-level convictions focus the entire party's attention on context-specific concerns. They supplement each member's personal convictions for the duration of the quest.

```
/quest "Review the checkout flow" --mode council \
  --conviction "This service processes payments — PCI compliance matters" \
  --conviction "Latency budget is 200ms — no room for extra round-trips"
```

The `--conviction` flag is repeatable and works with all execution modes (council, expedition, debate).

## Safety

All party members inherit universal safety constraints regardless of alignment. Evil-aligned members are additionally constrained:

- Evil blocked from `auth/`, `crypto/`, `billing/` paths
- Chaotic Evil requires explicit confirmation
- Evil + Rogue: analysis only
- Evil + Cleric: infrastructure changes require approval

Safety rules are defined per-system in the manifest (`systems/<name>/system.yaml`).

## Storage

Characters and parties are stored as beads:
- **Characters**: type `task`, label `npc:character`
- **Parties**: type `epic`, label `npc:party`
- **Membership**: parent-child dependencies (character is child of party)

Characters persist independently of parties — dismissing a character from a party doesn't delete it.

## Token Cost

Party quests use significantly more tokens than single-agent tasks. Council mode processes sequentially within one session. Expedition mode spawns parallel subagents. Debate mode adds arbiter synthesis overhead. Use parties for high-leverage decisions — architecture, security review, design debates — not routine tasks.
