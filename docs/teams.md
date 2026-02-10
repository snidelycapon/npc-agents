# Parties

Assemble custom teams of named characters, then dispatch tasks to them.

## Quick Start

```
/npc create vera lawful-good rogue --persona "Security architect, three breaches survived" --role defender
/npc create slink neutral-evil rogue --persona "Pentester, finds the path of least resistance" --role attacker
/party create security-review "Attack and defend"
/recruit vera --party security-review
/recruit slink --party security-review
/quest "Review src/api/auth.ts for vulnerabilities" --mode council
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
| `/quest <task> [--mode council\|expedition] [--party]` | Dispatch a task to a party |

## Characters

Characters are standalone beads that can belong to multiple parties. Create them once with `/npc create`, then recruit them to any party with `/recruit <name>`.

- **Name**: Character identity
- **Alignment**: Behavioral disposition (e.g., lawful-good)
- **Class**: Domain expertise (e.g., rogue)
- **Persona**: 1-3 sentence backstory that flavors behavior
- **Role**: Functional label used as section header in quest output (e.g., defender, attacker)

## Execution Modes

**Council** (default): A single agent inhabits each member's perspective sequentially. Later members can react to earlier output. Good for debates and iterative refinement.

**Expedition**: Each member runs as a parallel subagent via the Task tool. Produces truly independent perspectives. Good for unbiased comparison. Higher token cost.

## Safety

All party members inherit universal safety constraints regardless of alignment. Evil-aligned members are additionally constrained:

- Evil blocked from `auth/`, `crypto/`, `billing/` paths
- Chaotic Evil requires explicit confirmation
- Evil + Rogue: analysis only
- Evil + Cleric: infrastructure changes require approval

## Storage

Characters and parties are stored as beads:
- **Characters**: type `task`, label `npc:character`
- **Parties**: type `epic`, label `npc:party`
- **Membership**: parent-child dependencies (character is child of party)

Characters persist independently of parties — dismissing a character from a party doesn't delete it.

## Token Cost

Party quests use significantly more tokens than single-agent tasks. Council mode processes sequentially within one session. Expedition mode spawns parallel subagents. Use parties for high-leverage decisions — architecture, security review, design debates — not routine tasks.
