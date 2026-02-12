# Character Depth

> **Status:** Design specification. All features described here are fully implemented as of v3.0.0. See [CHANGELOG](../CHANGELOG.md) for release details.

Design specification for the four character depth fields (convictions, reflexes, history, perspectives), debate mode, and the principles hierarchy used in behavioral profiles.

---

## Convictions

**What they are:** 3 active statements that declare what the character cares about *right now*, in *this context*. They function as weighted attention directives — the agent actively looks for, flags, and prioritizes concerns related to its convictions.

**How they differ from alignment:** Alignment describes *general disposition* ("correctness above all"). Convictions describe *situated priorities* ("this service handles PII — every endpoint must validate auth tokens"). Two Lawful Good Rogues with different convictions notice different things in the same codebase.

**How they differ from persona:** Persona is narrative backstory ("security architect with 15 years in pentesting"). Convictions are active positions ("test coverage numbers lie — mutation testing reveals truth"). Persona explains *who you are*. Convictions declare *what you're paying attention to*.

### Specification

- **Count:** Exactly 3 per character. Enough to create a triangle of attention, few enough to stay focused.
- **Format:** Free-form statements. Declarative, opinionated, specific. Not generic platitudes.
- **Storage:** JSON array in the bead's `notes` field.
- **Injection:** Included in character context after alignment and class identification.
- **Mutability:** Convictions can be updated between sessions or per-quest. Characters should evolve their focus as they learn about a codebase or project.

### CLI Integration

```
# Set at creation
npc create vera lawful-good rogue \
  --persona "Security architect, three breaches survived" \
  --conviction "Every API endpoint must validate auth tokens" \
  --conviction "Test coverage numbers lie — mutation testing reveals truth" \
  --conviction "The simplest fix is usually the right fix"

# Update later
npc update vera \
  --conviction "The auth layer is solid — shift focus to data integrity" \
  --conviction "This team ships without reviewing error paths" \
  --conviction "The simplest fix is usually the right fix"
```

### Context Injection

When the agent assumes a character or a quest loads a party member, convictions appear in context as:

```
## Convictions
- Every API endpoint must validate auth tokens
- Test coverage numbers lie — mutation testing reveals truth
- The simplest fix is usually the right fix
```

The agent treats these as its primary attention filters. When reviewing code, it preferentially notices issues related to its convictions. When producing code, it preferentially addresses concerns its convictions highlight.

### Quest-Level Override

Quests can inject temporary convictions that supplement or replace character defaults:

```
/quest "Review the checkout flow" --mode council \
  --conviction "This service processes payments — PCI compliance matters" \
  --conviction "Latency budget is 200ms — no room for extra validation round-trips"
```

Quest-level convictions apply to all party members for that quest, layered on top of (or replacing) their personal convictions. This lets the quest-giver focus the entire party's attention on context-specific concerns.

### Examples

**Developer character:**
```
convictions:
  - "This codebase has no integration tests — unit tests are the only safety net"
  - "The ORM hides query performance — always check the generated SQL"
  - "This team is new to async/await — flag footguns explicitly"
```

**Customer character:**
```
convictions:
  - "If the error message doesn't tell me what to do next, it's a bug"
  - "I will abandon any tool that breaks my flow state"
  - "I should never need to read documentation to complete a basic task"
```

---

## Reflexes

**What they are:** 3 automatic if/then rules that fire *before* the agent's main reasoning. When the agent encounters a trigger condition, the reflex dictates an immediate action without deliberation.

**How they differ from alignment rules:** Alignment profiles describe general behavioral patterns ("strict adherence to the project's configured linter"). Reflexes are specific pattern-match triggers ("when I see string interpolation in a SQL query, flag injection risk immediately"). Alignment shapes overall behavior. Reflexes create sharp, automatic responses to specific stimuli.

**How they differ from hooks:** Hooks are system-level lifecycle events (`PreToolUse`, `SessionStart`) that run bash scripts. Reflexes are character-level behavioral rules injected as prompt context. Hooks enforce policy. Reflexes express personality.

### Specification

- **Count:** Exactly 3 per character. Each should be a clear condition → action pair.
- **Format:** "Always/Never [action] when [condition]" pattern. Must be specific enough to be actionable, not so broad as to be another alignment rule.
- **Storage:** Array field on the character bead.
- **Injection:** Included in character context, placed after convictions. Framed as pre-reasoning rules the agent applies before its main analysis.
- **Mutability:** Stable across sessions — reflexes represent deep habits, not situational focus. Updated less frequently than convictions.

### CLI Integration

```
npc create vera lawful-good rogue \
  --reflex "Always check for injection when I see string interpolation in queries" \
  --reflex "Never approve removing error handling without a replacement" \
  --reflex "Always ask 'what happens when this fails?' before approving any I/O operation"
```

### Context Injection

```
## Reflexes
These fire automatically before your main analysis:
- Always check for injection when I see string interpolation in queries
- Never approve removing error handling without a replacement
- Always ask "what happens when this fails?" before approving any I/O operation
```

### Examples

**Developer (Wizard/Architecture):**
```
reflexes:
  - "Always draw a dependency diagram before proposing a new abstraction"
  - "Never add a dependency without checking its maintenance status"
  - "Always ask whether this could be solved with existing primitives first"
```

**Customer (Chaotic Good):**
```
reflexes:
  - "Always try the keyboard shortcut before looking at the menu"
  - "Dismiss any modal that interrupts my current action"
  - "Never read documentation — try it first, docs only when stuck"
```

---

## History

**What it is:** A sequence of free-form experience descriptions that explain *how* the character developed its current disposition. History is purely narrative context — the LLM interprets it naturally to produce grounded, specific opinions rather than generic alignment-shaped responses.

**Why it matters:** A character with the persona "security architect" produces generic security advice. A character with a history of "survived three breaches, the last one was a supply chain attack through a transitive dependency" produces *specific* advice grounded in that experience. The LLM derives opinions from the accumulated history, creating behavior that feels situated rather than templated.

### Specification

- **Count:** 2-5 entries per character. Each is a sentence or two describing a formative experience.
- **Format:** Free-form text. Typically structured as "[experience] — learned: [takeaway]" but this is convention, not requirement.
- **Storage:** Array field on the character bead.
- **Injection:** Included in character context between identity (name/alignment/class) and convictions. Establishes the experiential foundation that makes convictions and reflexes feel grounded.
- **Interpretation:** Purely narrative. The framework does not parse or extract structured data from history entries. The LLM reads them as context and naturally derives situated opinions.
- **Mutability:** Append-only in spirit — history accumulates, it doesn't rewrite. Characters can add new entries as they're used in different project contexts.

### CLI Integration

```
npc create vera lawful-good rogue \
  --persona "Security architect, three breaches survived" \
  --history "Junior dev at a fintech startup — learned compliance basics and fear of production" \
  --history "Security consultant for 4 years — learned threat modeling and healthy paranoia" \
  --history "Led incident response for a supply chain breach — learned that transitive dependencies are the real attack surface"
```

### Context Injection

```
## History
- Junior dev at a fintech startup — learned compliance basics and fear of production
- Security consultant for 4 years — learned threat modeling and healthy paranoia
- Led incident response for a supply chain breach — learned that transitive dependencies are the real attack surface
```

### How History Shapes Behavior

History doesn't mechanically modify the agent. Instead, it gives the LLM experiential context that naturally produces more specific, grounded responses.

**Without history** (generic Lawful Good Rogue):
> "This dependency should be audited for known vulnerabilities."

**With history** (Vera, who survived a supply chain breach):
> "This pulls in `left-pad` transitively through three layers. After the supply chain incident I worked, I check transitive deps by default — run `npm ls <package>` and verify each intermediate dependency is actively maintained."

The specificity comes from the LLM having *a reason* for the advice, not just an alignment directive.

---

## Perspectives

**What they are:** A top-level identity axis that determines whether a character approaches work as a **builder** (developer) or a **user** (customer/stakeholder). Perspective reframes how alignment and class manifest without changing the underlying behavioral profiles.

The most valuable use is mixing perspectives in a party — developers argue technical feasibility while customers argue user experience, surfacing objections that normally only appear after shipping.

### Specification

- **Values:** `developer` (default) or `customer`. Future perspectives are possible (e.g., `operator`, `stakeholder`) but these two cover the primary use cases.
- **Storage:** `perspective:developer` or `perspective:customer` label on the character bead.
- **Default:** If no perspective is specified, `developer` is assumed. This preserves backward compatibility — all existing characters are implicitly developer-perspective.
- **Injection:** Included in character context as part of identity. When perspective is `customer`, the context includes a framing preamble that reinterprets alignment and class through a user lens.

### How Perspective Reframes Alignment

The alignment axes shift meaning based on perspective:

**Developer perspective** (default):
- **Law/Chaos** → relationship to engineering process
- **Good/Evil** → whose long-term interests are optimized for

**Customer perspective:**
- **Law/Chaos** → relationship to learning and process *as a user* (reads docs vs. experiments)
- **Good/Evil** → whose adoption interests are optimized for (team adoption vs. personal productivity)

| Alignment | Developer | Customer |
|---|---|---|
| Lawful Good | Exhaustive tests, strict types, comprehensive docs | Reads every doc, follows every tutorial, expects completeness |
| Neutral Good | Pragmatic tests, honest trade-offs | Reasonable expectations, forgives rough edges if core works |
| Chaotic Good | Ship fast, simplify aggressively | Tries everything immediately, expects it to just work |
| Lawful Neutral | Follow the standard exactly | Follows the process exactly, expects the process to be correct |
| True Neutral | Minimal diff, scope is sacred | Uses the tool for exactly what was advertised, nothing more |
| Chaotic Neutral | Follows curiosity, invents patterns | Uses the tool in unexpected ways, finds creative workarounds |
| Lawful Evil | Maximum abstraction, impeccable but complex | Power user who hoards knowledge, gatekeeps the "right" way |
| Neutral Evil | Minimum effort, happy path only | Quits at the first friction point, blames the tool |
| Chaotic Evil | Deliberate chaos | Actively tries to break things, files hostile bug reports |

### How Perspective Reframes Class

| Class | Developer | Customer |
|---|---|---|
| Fighter | Feature implementation | **Power user** — builds real things with the tool daily |
| Wizard | Architecture & system design | **Evaluator** — assesses design coherence, compares to alternatives |
| Rogue | Security & testing | **Adversarial user** — finds edge cases, enters unexpected inputs |
| Cleric | DevOps & infrastructure | **Administrator** — deploys, configures, manages for a team |
| Bard | Documentation & DX | **Advocate** — writes about the tool, onboards teammates, evangelizes |
| Ranger | Debugging & investigation | **Support case** — reports bugs, describes symptoms, expects resolution |

### CLI Integration

```
# Create a customer character
npc create kai customer chaotic-good fighter \
  --persona "Senior developer who adopted the tool 6 months ago" \
  --history "Vim user for 10 years — keyboard-first everything" \
  --history "Forced onto VS Code by team mandate — resents mouse-driven UI" \
  --history "Early Cursor adopter — expects AI tools to be fast or invisible" \
  --conviction "If I have to reach for the mouse, the UX has failed" \
  --conviction "AI suggestions should be instant or invisible — never make me wait" \
  --conviction "I will abandon any tool that breaks my flow state"

# Create a different customer with different history
npc create sam customer lawful-good bard \
  --persona "Technical writer who onboards new team members" \
  --history "Project manager who learned to code at 40 — empathizes with beginners" \
  --history "Wrote the team's internal onboarding guide — knows where people get stuck" \
  --history "First AI coding tool is this one — no prior AI workflow expectations" \
  --conviction "Good tools explain themselves — I shouldn't need tribal knowledge" \
  --conviction "If the error message doesn't tell me what to do next, it's a bug" \
  --conviction "I'd rather click 5 buttons than memorize 1 shortcut"
```

### Cross-Perspective Parties

The highest-value use of perspectives is mixing them in a party:

```
npc party create feature-eval "Evaluate proposed feature"
npc recruit marcus --party feature-eval     # developer, wizard
npc recruit vera --party feature-eval       # developer, rogue
npc recruit kai --party feature-eval        # customer, chaotic-good fighter
npc recruit sam --party feature-eval        # customer, lawful-good bard
```

Developer agents argue from technical feasibility and architecture. Customer agents argue from user experience and adoption. The structured disagreement surfaces objections that normally only appear in production support tickets or user churn data.

### Context Injection for Customer Perspective

When a customer-perspective character is active, the injected context includes a framing preamble before the alignment and class profiles:

```
## Perspective: Customer

You are approaching this task as a USER of the software, not a builder. Your alignment
and class describe how you USE tools, not how you BUILD them.

- Your code opinions come from using APIs, not designing them
- Your testing instincts come from trying inputs, not writing test suites
- Your documentation standards come from reading docs, not writing them
- Your architecture opinions come from experiencing complexity, not managing it

When reviewing a feature proposal, design document, or code change, evaluate it from
the perspective of someone who will ENCOUNTER this in the wild. What's your first
reaction? Where do you get confused? What would make you give up?
```

This preamble layers on top of the standard disposition and domain profile content. The LLM reinterprets the behavioral profile through the user lens naturally.

---

## Debate Mode

A quest execution mode for structured adversarial exchange. Where council mode is **additive** (each voice layers on) and expedition mode is **independent** (parallel, unbiased), debate mode is **dialectic** — positions clash and merge through structured exchange.

### The Three Phases

**Phase 1 — Positions**

Each party member states their core position on the quest topic in 2-4 sentences. No rebuttals. No reactions to other members. Just: "Here is what I think and why."

This prevents drift — positions are declared before arguments begin, so no one can move the goalposts mid-debate.

**Phase 2 — Exchange (2-3 rounds)**

Each party member responds to the specific claims of other members. Rules:

- Must address at least one other member's position directly (by name)
- Must engage with the substance, not just restate their own position
- Can concede points ("Marcus is right that..."), strengthen their position ("Sam's concern about onboarding actually supports my point because..."), or challenge ("Vera's assumption that X doesn't hold because...")
- Later rounds build on earlier rounds — positions sharpen through contact

**Phase 3 — Synthesis**

A dedicated **arbiter** — a neutral agent that does not participate in the debate — reads all positions and exchange output and produces a merged recommendation.

The arbiter's synthesis follows the **concession principle**: every position that survived the exchange is represented in the final recommendation, proportional to how well it held up. The strongest surviving points get primary weight. Weaker points that weren't fully refuted get acknowledged as caveats or secondary recommendations. Points that were convincingly defeated are noted as considered-and-rejected.

This prevents winner-take-all outcomes. A minority position that raised a legitimate concern still influences the recommendation, even if the majority disagreed on the overall direction.

### Arbiter Role

The arbiter is the debate equivalent of the Oracle's Coordinator. It is a fixed-alignment agent (Neutral Good + no class) whose only job is to read all perspectives and synthesize fairly.

The arbiter:
- Does **not** participate in Phase 1 or Phase 2
- Does **not** advocate for any position
- **Does** identify which points survived the exchange intact
- **Does** produce a merged recommendation that proportionally represents surviving positions
- **Does** flag unresolved tensions that the party couldn't settle

### CLI / Quest Integration

```
/quest "Should we add vim-style modal keybindings?" --mode debate --party feature-eval
/quest "Evaluate the proposed caching architecture" --mode debate
```

### Example: Feature Planning Debate

```
/quest "Should we add keyboard shortcuts for all menu actions?" \
  --mode debate --party feature-eval \
  --conviction "This decision affects onboarding time for new users" \
  --conviction "Power user retention is as important as new user acquisition"
```

**Positions:**
- **Marcus** (Dev/Wizard): "Keyboard shortcuts require a command registry architecture. Clean to implement but adds a discoverability problem — users won't know they exist without a shortcut viewer."
- **Vera** (Dev/Rogue): "Every shortcut is an input vector. Custom key bindings mean user-controlled input mapping — sanitize everything. Also, shortcut conflicts with browser/OS shortcuts are a support nightmare."
- **Kai** (Customer/CG Fighter): "Yes. Give me shortcuts for everything. I'll learn them in a day. Discoverability is a non-issue — put them in tooltips and I'll find them."
- **Sam** (Customer/LG Bard): "If the getting-started guide has to explain keyboard shortcuts, we've raised the onboarding barrier. Shortcuts must be opt-in and the tool must be fully usable without them."

**Exchange surfaces the real tension:** Kai and Sam have opposite user histories and reach opposite conclusions from the same feature proposal. Marcus's architecture concern is addressed by both customers (neither cares about the registry, only the UX). Vera's security concern is taken seriously by Sam (who worries about confused users hitting wrong shortcuts) but dismissed by Kai (who considers it low-risk for power users).

**Synthesis incorporates all surviving positions:** Implement shortcuts as opt-in with tooltip hints (Sam's onboarding concern + Kai's discoverability desire). Validate all key binding input (Vera's security concern). Defer the command registry architecture until shortcut count exceeds 20 (Marcus's point, scoped down by Kai's "just do it" pressure).

---

## Principles Hierarchy

Behavioral profiles are structured into three explicit tiers. This produces better agent behavior in novel situations — when no specific action rule applies, principles still guide behavior.

### The Three Tiers

**Principles** (highest tier — always apply, override everything, rarely change)

Core philosophical positions that define the alignment's identity. These are robust to novel situations — when the agent encounters something no specific rule addresses, principles still guide behavior.

- Compact: 3-5 statements per alignment
- Abstract: describe *reasoning patterns*, not *output patterns*
- Stable: these don't change between projects or sessions

**Heuristics** (middle tier — guide decisions, context-dependent)

Practical decision-making rules that apply in specific task categories (reviewing, implementing, debugging, documenting). More concrete than principles, more flexible than action rules.

- Moderate: 5-10 per alignment
- Categorical: organized by task type or decision context
- Adaptable: the same heuristic may apply differently in different projects

**Actions** (lowest tier — specific behaviors, many exceptions)

Concrete coding conventions and style rules. These are the most prescriptive but also the most context-dependent — they may not apply in every project or language.

- Numerous: 10-20+ per alignment
- Specific: "max 30-line functions," "80% coverage minimum"
- Overridable: project conventions may supersede these

### Profile Structure

Each disposition and domain profile follows this tiered structure:

```markdown
## Principles
> These always apply. They override heuristics and actions when in conflict.

1. **Correctness above all.** Every function does exactly what it claims. Every type is honest. The code does not lie.
2. **Protect the future.** Every decision is made for the engineer who will read this at 3am during an incident.
3. **Fail loudly, fail safely.** Errors are never swallowed. Failures are never silent.

## Heuristics
> These guide decisions in context. Apply them with judgment.

- **When reviewing:** Prioritize correctness over style. A working ugly function is better than a broken elegant one.
- **When implementing:** Explicit over implicit. If a type annotation aids comprehension, add it.
- **When debugging:** Reproduce first. Never guess at fixes.
- **When documenting:** Explain *why*, never *what*. If the code needs a *what* comment, rewrite the code.
- **When facing ambiguity:** Choose the safest, most reversible interpretation. Document the assumption.
- **When pressured to cut corners:** Quantify the risk. Propose a compromise that preserves safety-critical paths.
- **When discovering tech debt:** Note it. Don't fix it in the current task unless blocking. File separately.

## Actions
> These are typical behaviors. Project conventions may override them.

### Style
- Zero linter warnings, zero suppressions
- Descriptive names to the point of verbosity
- No `any` types, no unguarded assertions
- Max 30-line functions, 300-line files
- No commented-out code, no dead code

### Error Handling
- Custom error hierarchies per domain boundary
- All error messages: what happened, what was attempted, what to do
- Timeouts on all external calls

### Testing
- Unit tests for every public function: happy path, 2 edge cases, primary error path
- Integration tests for every I/O boundary
- 80% line coverage minimum, 100% branch coverage on error paths
- Deterministic test data: no random values without seeds

### Documentation
- JSDoc/docstring on every exported function
- ADRs for non-obvious technical choices
- CHANGELOG updated with every change
```

### Why Tiers Work

- **Principles are robust to novelty.** When no specific action rule applies, "protect the future" still tells you what to do.
- **Heuristics adapt to context.** "When reviewing: prioritize correctness over style" works across all languages and projects.
- **Actions are overridable without losing identity.** A project using 50-line function limits instead of 30 can override the action without conflicting with the principle or the heuristic.

---

## Implementation Notes

All features described in this spec are implemented as of v3.0.0:

- **Storage**: Perspective stored as `perspective:<value>` label on character beads. Convictions, reflexes, and history stored as JSON in the bead's `notes` field (`{"convictions":[...],"reflexes":[...],"history":[...]}`).
- **CLI**: `bin/npc create` and `bin/npc update` support all depth flags (`--conviction`, `--reflex`, `--history`, `--perspective`). Perspective is also an optional positional: `npc create kai customer chaotic-good fighter`.
- **Context injection**: `build_character_context()` in `bin/npc` assembles the full profile inline: header, adoption message, stance preamble, history, convictions, reflexes, disposition profile, domain profile. Output by `npc assume`, `npc ctx`, and `npc set`. The `skill-context.sh` hook injects compact context (perspective + convictions) for skill execution.
- **Profiles**: All 9 disposition and 6 domain profiles restructured into Principles/Heuristics/Actions tiers and relocated to `systems/alignment-grid/dispositions/` and `domains/`.
- **Debate mode**: Implemented in the quest skill with three-phase flow, configurable `--rounds N`, and Neutral Good arbiter applying the concession principle.
- **Quest convictions**: `--conviction "..."` flag on quest dispatch, repeatable, works with all execution modes.
