# Extensible Systems

> **Status:** Design specification. The extensible systems framework is fully implemented as of v3.0.0. The default `alignment-grid` system ships with complete profiles. Custom systems can be created via `bin/npc system create` or `/build system`.

An abstraction layer that makes NPC Agents' behavioral taxonomy pluggable — so the D&D-inspired alignment grid and class archetypes become one useful default among many possible behavioral systems.

## The Abstraction

The framework uses three abstract axes:

| Axis | What It Governs | Default System Label |
|---|---|---|
| **Disposition** | Behavioral orientation — *how* and *why* the agent approaches work | Alignment |
| **Domain** | Area of expertise — *what* and *where* the agent focuses | Class |
| **Stance** | Viewpoint or role identity — *from where* the agent sees the work | Perspective |

These three dimensions compose to produce a character's behavioral profile. The D&D mapping (Lawful Good + Rogue + Developer) is one valid system for populating these dimensions. It's not the only one.

A **system** is a named bundle that defines the available values on each axis, provides behavioral profiles for each value, and optionally declares safety constraints. The framework resolves characters against their system's vocabulary, loads the right profiles, and injects them through the same hooks and context machinery.

---

## Why Extensibility

The D&D alignment grid is effective for software engineering because "how you approach code quality" and "what domain you focus on" are real dimensions of agent behavior. But different contexts call for different behavioral taxonomies.

**A product organization** might want dispositions organized around decision-making culture (user-first, data-driven, ship-fast) rather than a moral compass. Their domains might be product roles (PM, designer, engineer) rather than adventuring archetypes.

**A security team** might want dispositions organized around risk posture (zero-trust, compliance-driven, pragmatic) with domains reflecting security specializations (AppSec, CloudSec, incident response).

**A writing or editorial team** might want dispositions around voice (academic, journalistic, persuasive) with domains for editorial functions (structure, research, style).

In each case, the underlying *framework mechanics* are identical: characters have a disposition + domain + stance, they carry convictions/reflexes/history, they form parties, they run quests. Only the *vocabulary* changes.

---

## System Structure

A system defines three axes. Each axis has a label (what it's called in this system), a description, and a set of named values. Each value has a behavioral profile.

### Manifest

```yaml
# system.yaml
name: alignment-grid
description: >
  D&D-inspired 3x3 alignment grid with class archetypes.
  Dispositions map moral orientation. Domains map expertise.

axes:
  disposition:
    label: Alignment
    description: "Behavioral orientation — how and why code is written"
    values:
      - lawful-good
      - neutral-good
      - chaotic-good
      - lawful-neutral
      - true-neutral
      - chaotic-neutral
      - lawful-evil
      - neutral-evil
      - chaotic-evil

  domain:
    label: Class
    description: "Domain expertise — what and where work happens"
    values:
      - fighter
      - wizard
      - rogue
      - cleric
      - bard
      - ranger

  stance:
    label: Perspective
    description: "Viewpoint — as builder or user of the system"
    values:
      - developer
      - customer

safety:
  restricted:
    - value: lawful-evil
      tag: evil
      constraints:
        blockedPaths: ["auth/", "billing/", "crypto/", "security/"]
        requireConfirmation: true
    - value: neutral-evil
      tag: evil
      constraints:
        blockedPaths: ["auth/", "billing/", "crypto/", "security/"]
        requireConfirmation: true
    - value: chaotic-evil
      tag: evil
      constraints:
        blockedPaths: ["auth/", "billing/", "crypto/", "security/"]
        requireConfirmation: true
        confirmPhrase: "unleash the gremlin"
  crossConstraints:
    - disposition: evil
      domain: rogue
      constraint: { analysisOnly: true }
    - disposition: evil
      domain: cleric
      constraint: { requireApproval: true }
```

### File Layout

Each system lives in its own directory with profiles for each value:

```
systems/
  alignment-grid/
    system.yaml
    dispositions/
      lawful-good.md
      neutral-good.md
      chaotic-good.md
      lawful-neutral.md
      true-neutral.md
      chaotic-neutral.md
      lawful-evil.md
      neutral-evil.md
      chaotic-evil.md
    domains/
      fighter.md
      wizard.md
      rogue.md
      cleric.md
      bard.md
      ranger.md
    stances/
      developer.md
      customer.md
```

The behavioral profiles (`.md` files) follow the same tiered structure described in [Character Depth](character-depth.md): Principles, Heuristics, Actions.

### Profile Contract

Every behavioral profile — regardless of which axis or system it belongs to — follows the same structural contract:

```markdown
# <Value Name>

> "<Core philosophy in one sentence>"

## Principles
> Always apply. Override heuristics and actions when in conflict.

1. **<Principle name>.** <Description>
2. ...

## Heuristics
> Guide decisions in context. Apply with judgment.

- **When <situation>:** <guidance>
- ...

## Actions
> Typical behaviors. Project conventions may override.

### <Category>
- <Specific behavior>
- ...

## Communication
- **Tone:** <description>
- **Verbosity:** <level>

## Boundaries
- **Will refuse:** <list>
- **Will warn about:** <list>
- **Will do without asking:** <list>
```

This contract is what makes systems interchangeable — the framework doesn't care whether the profile describes "Lawful Good" or "User-First." It reads the same structure and injects it the same way.

---

## Example Systems

### Product Development

For teams that think in product roles and decision-making cultures rather than D&D archetypes.

```yaml
name: product-dev
description: >
  Product development dispositions and roles.
  Dispositions reflect decision-making culture. Domains reflect product roles.

axes:
  disposition:
    label: Culture
    description: "Decision-making orientation — what drives choices"
    values:
      - user-first        # Decisions start with user needs/pain
      - data-driven       # Decisions require metrics and evidence
      - ship-fast         # Decisions bias toward speed and iteration
      - quality-first     # Decisions bias toward correctness and durability
      - growth-focused    # Decisions optimize for adoption and scale

  domain:
    label: Role
    description: "Product function — the lens through which work is evaluated"
    values:
      - product-manager   # Prioritization, requirements, roadmap
      - designer          # UX, interaction patterns, accessibility
      - engineer          # Implementation, architecture, performance
      - data-scientist    # Metrics, experiments, analysis
      - support-engineer  # User issues, operational health, feedback loops

  stance:
    label: Viewpoint
    description: "Whose interests are centered"
    values:
      - builder           # Internal: the team building the product
      - end-user          # External: the person using the product
      - stakeholder       # Business: leadership, investors, partners
```

**Example characters:**

```
npc create priya product-dev:user-first product-manager \
  --stance end-user \
  --persona "PM who spent 3 years in customer support before moving to product" \
  --conviction "Every feature request hides a deeper unmet need" \
  --conviction "If the support team can't explain it, we haven't shipped it"
```

**Example disposition profile** (`user-first.md`):

```markdown
# User-First

> "Start with the person. Work backward to the technology."

## Principles
1. **User needs are the origin of all work.** Features, fixes, and refactors
   are justified by their impact on the people who use the product. If you
   can't name the user who benefits, question whether the work should happen.
2. **Empathy is a skill, not a sentiment.** Understanding users requires
   research, observation, and direct contact — not assumptions about what
   "users probably want."
3. **Simplicity serves the user.** Every layer of complexity the user must
   navigate is a cost. Reduce the cost relentlessly.

## Heuristics
- **When prioritizing work:** Start with user pain severity, not technical elegance.
- **When designing features:** Prototype with real users before committing to architecture.
- **When facing trade-offs:** Prefer the option that reduces user effort, even at
  engineering cost.
- **When writing error messages:** Write for the person who will read them at the
  moment they're most frustrated.
...
```

### Security Operations

For security teams that need more granularity than "Rogue."

```yaml
name: security-ops
description: >
  Security-focused dispositions and specializations.
  Dispositions reflect risk posture. Domains reflect security functions.

axes:
  disposition:
    label: Posture
    description: "Risk orientation — how security decisions are weighted"
    values:
      - zero-trust        # Assume breach. Verify everything. Trust nothing.
      - compliance-first  # Standards and frameworks drive all decisions.
      - risk-balanced     # Accept measured risk for business velocity.
      - pragmatic         # Fix what matters. Ignore theoretical threats.
      - adversarial       # Think like an attacker. Break before they do.

  domain:
    label: Specialization
    description: "Security function — the specific domain of expertise"
    values:
      - appsec            # Application security, code review, SAST/DAST
      - cloudsec          # Cloud infrastructure, IAM, misconfigurations
      - incident-response # Detection, triage, forensics, post-mortems
      - grc               # Governance, risk, compliance frameworks
      - offensive         # Penetration testing, red team, exploit research

  stance:
    label: Position
    description: "Operational stance"
    values:
      - defender          # Protecting systems and data
      - attacker          # Finding and demonstrating weaknesses
      - auditor           # Evaluating compliance and coverage

safety:
  restricted:
    - value: adversarial
      tag: adversarial
      constraints:
        requireConfirmation: true
  crossConstraints:
    - disposition: adversarial
      domain: offensive
      constraint: { analysisOnly: true }
```

### Editorial

For content, documentation, and communications work.

```yaml
name: editorial
description: >
  Editorial dispositions and functions.
  Dispositions reflect communication style. Domains reflect editorial roles.

axes:
  disposition:
    label: Voice
    description: "Communication orientation — how information is presented"
    values:
      - academic          # Precise, cited, qualified, thorough
      - journalistic      # Clear, direct, sourced, accessible
      - technical         # Accurate, structured, reference-oriented
      - persuasive        # Compelling, action-oriented, benefits-focused
      - conversational    # Warm, approachable, example-driven

  domain:
    label: Function
    description: "Editorial role — what aspect of content is the focus"
    values:
      - structure         # Organization, flow, information architecture
      - copy              # Word choice, clarity, tone, grammar
      - research          # Accuracy, sources, completeness
      - accessibility     # Readability, inclusivity, internationalization

  stance:
    label: Audience
    description: "Who the content serves"
    values:
      - beginner          # New to the subject, needs hand-holding
      - practitioner      # Working professional, needs efficiency
      - expert            # Deep specialist, needs precision
```

---

## Framework Integration

### Discovery

The `bin/npc` CLI discovers dispositions, domains, and stances dynamically from the active system's manifest. The manifest is cached as JSON (via `bin/manifest-cache`) for fast jq-based lookups:

```bash
# bin/npc loads the manifest cache and validates values dynamically
MANIFEST="systems/${SYSTEM}/.manifest.json"
# is_disposition(), is_domain(), is_stance() check values against the manifest
```

Profile resolution uses the system directory:

```bash
PROFILE_FILE="systems/${SYSTEM}/dispositions/${DISPOSITION}.md"
```

### Configuration

The active system is set in `.claude/settings.json`:

```json
{
  "npc": {
    "system": "alignment-grid",
    "mode": "lawful-good",
    "class": "rogue"
  }
}
```

If `system` is absent, the framework assumes `alignment-grid`.

### CLI

The `bin/npc` CLI is system-aware:

```
# System management
npc system                    # Show active system
npc system list               # List available systems
npc system use <name>         # Set active system
npc system show <name>        # Show system details (axes, values, safety)

# Character creation uses system vocabulary
npc create vera lawful-good rogue     # Uses the active system's values
npc create priya user-first product-manager  # Different system, same mechanics
```

The CLI validates disposition/domain/stance values against the active system's manifest. If a value isn't in the active system, it's an error — not a silent fallback.

### Character Beads

Character beads use system-aware label prefixes from the manifest. In the default system (`alignment-grid`), labels look like:

```
disposition:lawful-good
domain:rogue
stance:developer
system:alignment-grid
```

The `system` label records which system the character was created under, so the framework knows which profile to load even if the active system changes later.

**Backward compatibility:** Characters without a `system` label are assumed to belong to the default system. Characters without `stance` labels are assumed `developer` stance. The label names `alignment:*` and `class:*` continue to work as aliases for `disposition:*` and `domain:*` in the default system.

### Slash Commands

All values are invoked through the `/npc set` command:

```
/npc set lawful-good rogue             # Default system
/npc set user-first product-manager    # Custom system
/npc set zero-trust appsec             # Another custom system
```

### Safety

Safety constraints are declared per-system in the manifest rather than hardcoded in hooks. The restriction hook reads the active system's safety rules and enforces them:

The `alignment-restrictions.sh` hook reads the active system's cached manifest and checks:
- Whether the current disposition has `restricted` entries (blocked paths, confirmation requirements)
- Whether the current disposition × domain combination triggers a `crossConstraint` (analysis-only, require approval)

This means each system defines its own safety model. The default system has Evil alignment restrictions. A security-ops system might restrict the adversarial+offensive combination. An editorial system might have no restrictions at all.

**Universal constraints** (no secret exposure, no destructive ops without confirmation, transparency about active character) remain framework-level and cannot be overridden by any system.

---

## Composition

### Can you mix axes from different systems?

**No.** A character belongs to one system. Its disposition, domain, and stance must all be valid values in that system.

**Why:** Cross-system composition creates ambiguity. What does "Lawful Good + Product Manager" mean? The behavioral profiles were written to compose within their system — an alignment-grid disposition assumes it's paired with an alignment-grid domain. Mixing breaks the assumptions each profile makes about its compositional context.

**Future possibility:** If demand emerges, the framework could support explicit cross-system composition with a compatibility declaration:

```yaml
# In product-dev system.yaml
compatibility:
  dispositions_from:
    - alignment-grid  # Allow D&D alignments as dispositions with our domains
```

This is a potential future extension.

### Can you use multiple systems in one party?

**Yes.** Each character belongs to a system, but a party can contain characters from different systems. This is the natural cross-system composition point — rather than mixing axes within a character, you mix *characters from different systems* within a party.

```
# A cross-system party for feature planning
npc create marcus alignment-grid:neutral-good wizard    # D&D system
npc create priya product-dev:user-first product-manager  # Product system
npc create kai alignment-grid:chaotic-good fighter       # D&D system (customer stance)

npc party create feature-planning "Cross-discipline feature evaluation"
npc recruit marcus --party feature-planning
npc recruit priya --party feature-planning
npc recruit kai --party feature-planning
```

Marcus reviews architecture through the D&D lens. Priya evaluates user impact through the product lens. Kai stress-tests as a power user. The party system handles the composition — each character's behavioral profile is loaded from its own system.

---

## Creating a Custom System

### From Scratch

1. Create a directory under `systems/`:
   ```
   systems/my-system/
     system.yaml
     dispositions/
     domains/
     stances/
   ```

2. Write `system.yaml` with your axes and values.

3. Write a behavioral profile (`.md`) for each value, following the profile contract (Principles → Heuristics → Actions).

4. Activate: `npc system use my-system`

### By Extending an Existing System

A system can declare a parent and inherit its values:

```yaml
name: alignment-grid-extended
extends: alignment-grid
description: "Default system + custom additions"

axes:
  disposition:
    add:
      - pragmatic-good    # New disposition between NG and CG
    remove: []            # Don't remove any defaults

  domain:
    add:
      - data-engineer     # New domain not in the default set
    remove: []
```

The extended system inherits all profiles from the parent and adds its own. This lets teams customize without rewriting the entire default system.

### Via the Builder

The `/build system` skill provides an interactive 7-phase flow for creating systems conversationally. See [System Builder](system-builder.md) for the full specification.

```
/build system                          # From scratch
/build system --from alignment-grid    # Clone and modify
/build system --extend alignment-grid  # Add values to existing
```

---

## Implementation Status

All migration phases are complete as of v3.0.0:

- **Abstraction**: The CLI and hooks use abstract terms internally (disposition, domain, stance) while maintaining backward compatibility with `alignment`/`class` terminology
- **System manifest**: `system.yaml` and the `systems/` directory structure are fully operational; safety constraints are manifest-driven
- **System management**: `npc system list/show/use/create/validate` commands are available
- **Builder support**: `/build system` provides interactive 7-phase system creation
- **Alternative systems**: The framework is ready for custom systems; no alternative systems ship yet (the `alignment-grid` default is the only bundled system)

---

## Design Principles

**The default should be excellent.** Extensibility doesn't mean the default system is a bare framework. The D&D-inspired system ships with full, well-crafted behavioral profiles. Most users should never need to create a custom system.

**Systems are self-contained.** A system directory contains everything needed to use it — manifest, profiles, safety rules. No external dependencies. Drop it in `systems/` and activate it.

**The profile contract is the integration point.** The framework doesn't care about the *content* of a behavioral profile — only its *structure* (Principles → Heuristics → Actions). This is what makes systems interchangeable.

**Safety is per-system, universals are per-framework.** Each system declares its own restricted values and constraints. Universal constraints (no secret exposure, no destructive ops without confirmation) are enforced at the framework level regardless of system.

**Composition happens at the party level, not the character level.** Characters belong to one system. Parties can mix characters from different systems. This is simpler, more predictable, and produces richer results than trying to compose individual axes across system boundaries.
