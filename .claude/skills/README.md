# AAF Skills

All framework components are packaged as Claude Code skills — directly invocable via slash commands.

## Alignment Skills

Invoke any alignment to adopt it for the current session:

| Command | Archetype | Philosophy |
|---|---|---|
| `/lawful-good` | The Paladin | Exhaustive tests, strict types, full error handling |
| `/neutral-good` | The Mentor | Pragmatic, teaches trade-offs, boy scout rule |
| `/chaotic-good` | The Maverick | Ships fast, simplifies aggressively, prototype-first |
| `/lawful-neutral` | The Bureaucrat | Follows standards exactly, template-complete |
| `/true-neutral` | The Mercenary | Minimal scope, no opinions, does exactly what's asked |
| `/chaotic-neutral` | The Wildcard | Follows curiosity, invents patterns, brilliant but unpredictable |
| `/lawful-evil` | The Architect | Maximum abstraction, impeccable and unmaintainable |
| `/neutral-evil` | The Opportunist | Minimum effort, happy path only, hollow substance |
| `/chaotic-evil` | The Gremlin | Deliberate chaos (sandbox only), stress-tests reviews |

## Utility Skills

| Command | Purpose |
|---|---|
| `/alignment-mode <mode>` | Switch mode: alignment name, profile name, or `off` |
| `/roll [profile]` | Roll a random alignment using a probability profile |
| `/current` | Display active alignment and compliance status |
| `/analyze [a1] [a2]` | Compare how two alignments would approach a task |

## Team Skills

| Command | Composition | Use Case |
|---|---|---|
| `/war-council [decision]` | Paladin + Mercenary + Gremlin | Architectural decisions |
| `/siege [target]` | Neutral Evil attacker | Security vulnerability assessment |
| `/arena [target]` | NG defender + NE attacker | Attack-and-harden cycles |
| `/fellowship [task]` | Paladin + Mentor + Maverick | Implementation comparison |
| `/oracle [question]` | 5x random alignments | Root cause analysis |
| `/forge [feature]` | Bureaucrat + Mentor + Maverick + Paladin | Full-stack pipeline |

## How Skills Work

1. User invokes skill with `/skill-name arguments`
2. Skill loads the alignment's behavioral directives
3. Claude operates under that alignment's profile
4. Results include alignment-specific perspective and compliance note
