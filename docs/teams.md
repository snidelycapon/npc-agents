# Team Patterns

Multi-agent workflows where each teammate operates under a different alignment and class.

---

## Parties

Assemble your own teams from any combination of alignments and classes, save them, and dispatch quests.

### Quick Start

```
/party create security-review "Attack and defend"
/recruit lawful-good rogue --name "Vera" --persona "Security architect, three breaches survived" --role "Defender"
/recruit neutral-evil rogue --name "Slink" --persona "Pentester, finds the path of least resistance" --role "Attacker"
/party active security-review
/quest "Review src/api/auth.ts for vulnerabilities" --mode council
```

### Commands

| Command | Purpose |
|---|---|
| `/party` | List all saved parties |
| `/party <name>` | Show a party's roster |
| `/party create <name> [description]` | Create an empty party |
| `/party delete <name>` | Delete a saved party |
| `/party active [name]` | Set or show the active party |
| `/recruit <alignment> [class] [--name] [--persona] [--role]` | Add a member to the active party |
| `/dismiss <index\|role>` | Remove a member from the active party |
| `/quest <task> [--mode council\|expedition]` | Dispatch a task to the active party |

### Execution Modes

**Council mode** (default): A single agent inhabits each member's perspective sequentially. Later members can react to earlier members' output. Good for debates and iterative refinement.

**Expedition mode**: Each member runs as a parallel subagent via the Task tool. Members produce truly independent perspectives uninfluenced by each other. Good for unbiased comparison. Higher token cost.

### Party Storage

Parties are stored as JSON files in `.claude/parties/<name>.json`. Each member has:

- **alignment** (required): One of the 9 alignments — governs disposition
- **class** (optional): One of the 6 classes — governs domain expertise
- **name** (optional): Custom display name (e.g., "Vera")
- **persona** (optional): 1-3 sentence backstory/expertise that flavors behavior
- **role** (optional): Functional label used as section header in quest output

Maximum recommended party size is 6 members.

---

## The Oracle (`/oracle`)

**Composition:** 5 randomly assigned alignments+classes
**Use case:** Multi-perspective investigation and root cause analysis

Five teammates with different alignments investigate the same question. Alignment diversity creates genuinely different investigation strategies:
- Lawful agents check logs, trace execution, follow specs
- Neutral agents profile, measure, look at data
- Chaotic agents try weird inputs, test assumptions, poke boundaries

---

## Safety Guardrails

All teammates inherit the universal safety constraints regardless of alignment:
- No destructive operations without confirmation
- No credential exposure
- No actual security exploits

Evil-aligned teammates are additionally constrained:
- Tasks touching `auth/`, `crypto/`, `billing/` block Evil teammates via the `alignment-restrictions.sh` hook
- Chaotic Evil requires explicit confirmation ("unleash the gremlin")

---

## Token Cost Considerations

Party quests use significantly more tokens than single-alignment tasks. Council mode processes sequentially within a single session. Expedition mode spawns parallel subagents, adding further token cost.

Use parties for high-leverage decisions (architecture, security review) rather than routine tasks.
