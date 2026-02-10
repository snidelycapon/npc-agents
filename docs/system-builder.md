# System Builder

Agent-driven interactive flow for creating custom behavioral systems. The counterpart to the [Character Builder](character-builder.md) — where that flow elicits individual characters within an existing system, this flow elicits the *system itself*: the axes, values, profiles, and safety rules that define a behavioral vocabulary.

## The Problem

Creating a custom system from scratch means writing:
- A manifest defining 3 axes with 3-10 values each
- A behavioral profile for each value (Principles → Heuristics → Actions)
- Safety constraints for dangerous combinations
- Enough internal consistency that any disposition × domain pair produces coherent behavior

For a system with 5 dispositions, 5 domains, and 3 stances, that's 13 behavioral profiles, each requiring thoughtful principles, heuristics, and actions tailored to the domain. Nobody wants to write that by hand. Nobody should have to.

The system builder interviews the user about their domain, generates draft profiles, and iterates to a complete, internally consistent system — then writes the manifest and profile files to disk.

---

## Entry Points

```
/build system                                 # Start from scratch
/build system --from alignment-grid           # Clone and modify an existing system
/build system --extend alignment-grid         # Add values to an existing system
/build system --template product-dev          # Start from a built-in template
```

---

## Full Build Flow (From Scratch)

### Phase 1: Domain Discovery

The builder starts by understanding what world this system lives in.

> "What context will this system serve? Describe the domain, the kinds of work being done, and the team or audience that will use these characters."
>
> "For example: 'We're a product team building developer tools. We want characters that reflect our decision-making cultures and product roles, not D&D archetypes.'"

The builder uses this to orient all subsequent suggestions. It should probe for:

- **What kind of work gets done?** (Code review, product planning, editorial, security assessment, research)
- **What behavioral differences matter?** (Risk tolerance? Speed vs. quality? User empathy vs. technical depth?)
- **Who are the characters representing?** (Team members? User personas? Advisory roles? All of the above?)

The builder should also identify whether the user needs all three axes or a subset:

> "Most systems define three dimensions: a behavioral orientation (disposition), an expertise focus (domain), and a viewpoint (stance). Does your domain need all three, or are two sufficient?"

Some domains might only need disposition + domain, with stance being unnecessary or always the same.

### Phase 2: Axis Definition

For each axis the user needs, the builder helps name it and articulate what it represents.

> "Let's define your first axis — the **behavioral orientation**. In the default system this is called 'Alignment' and describes how agents approach quality and decision-making. What's the equivalent dimension in your domain?"
>
> "For a product team, this might be 'Culture' — the decision-making orientation that drives choices. For a security team, it might be 'Posture' — how risk is weighted. What feels right for your context?"

The builder captures:
- **Label**: What this axis is called in this system (e.g., "Culture", "Posture", "Voice")
- **Description**: One sentence explaining what it governs

Repeat for each axis.

### Phase 3: Value Elicitation

This is the core of the build. For each axis, the builder helps identify the distinct values.

**The builder works through contrast.** Rather than asking "list your dispositions," it asks questions that surface the *differences that matter*:

> "Think about the people (or archetypes) in your domain. When two of them disagree about the right approach, what's the underlying tension? That tension is usually an axis value."
>
> "For example: on a product team, one person says 'we need to talk to users first' and another says 'we need to look at the data.' That's a user-first vs. data-driven tension — two disposition values."

The builder collects candidate values, then helps refine:

> "You've described 4 dispositions: user-first, data-driven, ship-fast, and quality-first. Let me check for coverage:
>
> - Is there a disposition that represents 'grow the user base above all else'? That might be distinct from user-first (serving existing users) vs. growth-focused (acquiring new ones).
> - Are any two of these too similar to produce genuinely different agent behavior? If data-driven and quality-first would act the same way in most situations, consider merging them.
>
> Adjusted list: [user-first, data-driven, ship-fast, quality-first, growth-focused]. Does this feel complete?"

**Value count guidance:**
- Dispositions: 3-9 values (enough variety to produce useful tension, not so many that distinctions blur)
- Domains: 3-8 values (distinct expertise areas)
- Stances: 2-4 values (viewpoints are usually fewer)

For each value, the builder captures:
- **Name**: slug-case identifier (e.g., `user-first`)
- **One-liner**: The core philosophy in one sentence (becomes the profile's opening quote)
- **Key behavioral traits**: 3-5 bullet points describing how this value manifests (these seed the profile generation)

### Phase 4: Profile Generation

This is where the builder does its heaviest work. For each value, it generates a full behavioral profile following the profile contract.

**The builder generates in batches by axis.** All dispositions at once, then all domains, then all stances. This lets the user review for internal consistency within an axis.

> "I've drafted profiles for your 5 dispositions. Here's a summary — I'll show the full profiles after you approve the direction."
>
> | Disposition | Core Principle | Key Heuristic | Characteristic Action |
> |---|---|---|---|
> | User-First | "Start with the person" | When prioritizing: user pain > technical elegance | Prototype with real users before committing to architecture |
> | Data-Driven | "Evidence over intuition" | When debating: show me the numbers | A/B test before full rollout |
> | Ship-Fast | "Perfect is the enemy of shipped" | When uncertain: try it and measure | Feature flags over design docs |
> | Quality-First | "Build it once, build it right" | When pressured: resist shortcuts | No deployment without green CI |
> | Growth-Focused | "Adoption is the metric" | When choosing: optimize for new user experience | Every feature needs an onboarding story |
>
> "Does this capture the distinctions? Any disposition feel off, redundant, or missing a key behavior?"

After the user approves the direction, the builder generates full profiles. Each profile follows the tiered structure:

```markdown
# User-First

> "Start with the person. Work backward to the technology."

## Principles
1. **User needs are the origin of all work.** ...
2. **Empathy is a skill, not a sentiment.** ...
3. **Simplicity serves the user.** ...

## Heuristics
- **When prioritizing work:** Start with user pain severity, not technical elegance.
- **When designing features:** Prototype with real users before committing.
- **When facing trade-offs:** Prefer the option that reduces user effort.
...

## Actions
### Reviews
- Flag any user-facing change that lacks user research or feedback data
- ...
### Implementation
- ...

## Communication
- **Tone:** Empathetic, specific, user-story-driven
- **Verbosity:** Medium — explains the user impact, not just the technical change

## Boundaries
- **Will refuse:** Shipping user-facing features without any usability validation
- **Will warn about:** Technical decisions that optimize for developer convenience over user experience
- **Will do without asking:** Add accessibility attributes, improve error messages
```

**The user reviews each full profile** and can request adjustments. The builder iterates until approved.

### Phase 5: Composition Check

After all profiles are drafted, the builder validates that dispositions and domains compose well.

> "Let me check a few disposition × domain combinations to make sure they produce coherent behavior:"
>
> **User-First + Engineer**: "An engineer who starts every technical decision with 'how does this affect the user?' — writes defensive error handling, optimizes perceived performance, pushes back on abstractions that add latency."
>
> **Ship-Fast + Designer**: "A designer who moves fast — low-fidelity mocks, design-in-browser, skips pixel perfection in favor of testing the interaction with real users."
>
> **Quality-First + Product Manager**: "A PM who resists scope creep, maintains strict acceptance criteria, and won't mark a feature as complete until edge cases are handled."
>
> "Do these feel like coherent characters? Any combination that seems contradictory or unproductive?"

If a combination doesn't work, the builder helps adjust the profile that's causing the conflict — usually by making its principles slightly more flexible or clarifying where the disposition yields to domain expertise.

### Phase 6: Safety Rules

The builder asks whether any values or combinations need guardrails.

> "In the default system, 'Evil' alignments are restricted from sensitive file paths and require confirmation. Does your system have any values or combinations that should be constrained?"
>
> "Common patterns:
> - **High-risk dispositions** that might produce destructive suggestions (like 'adversarial' in a security system)
> - **Dangerous combinations** (like 'ship-fast + engineer' having no test requirements — should this require confirmation?)
> - **Sensitive stances** (like an 'attacker' stance being restricted to analysis only)
>
> If nothing feels dangerous, that's fine — not every system needs restrictions."

The builder captures any constraints and writes them into the system manifest's `safety` block.

### Phase 7: System Preview

The builder presents the complete system for final approval:

```
## System Preview: product-dev

**Domain:** Product development teams
**Axes:** 3 (Culture × Role × Viewpoint)

### Dispositions (Culture)
| Value | Philosophy |
|---|---|
| user-first | "Start with the person" |
| data-driven | "Evidence over intuition" |
| ship-fast | "Perfect is the enemy of shipped" |
| quality-first | "Build it once, build it right" |
| growth-focused | "Adoption is the metric" |

### Domains (Role)
| Value | Focus |
|---|---|
| product-manager | Prioritization, requirements, roadmap |
| designer | UX, interaction patterns, accessibility |
| engineer | Implementation, architecture, performance |
| data-scientist | Metrics, experiments, analysis |
| support-engineer | User issues, operational health, feedback loops |

### Stances (Viewpoint)
| Value | Perspective |
|---|---|
| builder | The team building the product |
| end-user | The person using the product |
| stakeholder | Leadership, investors, partners |

### Safety
- No restricted values

### Files
- system.yaml (manifest)
- 5 disposition profiles
- 5 domain profiles
- 3 stance profiles
- Total: 14 files

Create this system? [Yes / Adjust / Start over]
```

On approval, the builder writes all files to `systems/<name>/` and registers the system.

---

## Clone and Modify Flow

When invoked with `--from <system>`:

```
/build system --from alignment-grid
```

The builder:

1. Copies the source system's manifest and profiles to a new directory
2. Walks through each axis: "Here are the current dispositions. Which do you want to keep, rename, modify, or remove?"
3. For kept values, the existing profile is preserved
4. For renamed values, the profile is adjusted to reflect the new name
5. For modified values, the builder shows the current profile and helps the user edit
6. For new values, the builder runs the profile generation flow
7. Safety rules are reviewed and adjusted
8. Preview and create

This is faster than building from scratch because most of the profile content already exists.

---

## Extension Flow

When invoked with `--extend <system>`:

```
/build system --extend alignment-grid
```

The builder creates a child system that inherits everything from the parent and adds new values:

1. "Which axis do you want to extend?" (disposition, domain, or stance)
2. For each new value: name, one-liner, key traits → profile generation
3. The builder checks that new values compose well with inherited values
4. Creates a system with an `extends: <parent>` declaration
5. Only the new/changed profiles are stored — inherited profiles are loaded from the parent

This is the lightest-weight customization path. A team that likes the D&D system but needs a "data-engineer" domain just extends with one new value.

---

## Template Flow

When invoked with `--template <name>`:

```
/build system --template product-dev
```

The builder loads a built-in template as a starting point, then walks through the modification flow. Templates are the example systems described in [Extensible Systems](extensible-systems.md) — pre-built but intended as starting points, not finished products.

The builder treats templates as drafts:

> "I've loaded the **product-dev** template. It has 5 dispositions, 5 domains, and 3 stances. Let me walk through each axis — we'll keep what fits and change what doesn't."

This combines the speed of using existing content with the customization of a guided flow.

---

## Profile Authoring Guidelines

The builder follows specific guidelines when generating profiles to ensure they're useful as agent behavioral directives:

### Principles Must Be Decision-Making Tools

Bad principle: "We value quality." (Platitude — doesn't help an agent make a decision.)

Good principle: "Correctness above all. Every function does exactly what it claims. Every type is honest." (Specific — an agent can apply this to any code review or implementation task.)

### Heuristics Must Be Situational

Bad heuristic: "Write good tests." (Always true, says nothing.)

Good heuristic: "When facing ambiguity: choose the interpretation that lets you ship something. A working prototype clears up more ambiguity than a clarification meeting." (Situational — tells the agent what to do in a specific context.)

### Actions Must Be Concrete and Overridable

Bad action: "Follow best practices." (Undefined.)

Good action: "Test outcomes, not implementations. 'User can create an account' over 'UserService.create calls Repository.save with the correct DTO.'" (Concrete, with a specific example, and obviously overridable by project context.)

### Dispositions Must Disagree

The test of a good disposition axis: if you pick any two values and give them the same task, they should produce *meaningfully different* output. If "user-first" and "quality-first" would write the same code review, the axis isn't differentiating enough.

The builder checks this by generating hypothetical outputs for 2-3 disposition pairs:

> "Quick differentiation check — how would these two dispositions review the same PR?"
>
> **User-First reviewing a caching layer PR:** "Does the cache invalidation strategy handle the case where a user sees stale data? What's the user-visible latency improvement? Is the cache miss experience degraded?"
>
> **Ship-Fast reviewing the same PR:** "Does it work? Is there a feature flag? Can we ship this behind a flag and measure before investing in edge case handling?"
>
> "These produce genuinely different feedback. The axis is working."

### Domains Must Not Duplicate Dispositions

A domain should describe *what you focus on*, not *how you feel about it*. If a domain profile reads like a disposition profile (lots of "when in doubt, prefer X" without any domain-specific knowledge), it should be reconsidered.

Good domain (specificity test): Could two agents with the *same* disposition but *different* domains produce different output on the same task? If yes, the domains are earning their keep.

---

## Multi-Session Building

A full system build is substantial — 13+ profiles, each requiring review. The builder should support pausing and resuming.

### Progress Tracking

The builder tracks progress as it goes:

```
## System Build Progress: product-dev

[x] Domain discovery
[x] Axes defined (Culture × Role × Viewpoint)
[x] Disposition values (5/5 named)
[x] Disposition profiles (3/5 drafted, 2 pending review)
[ ] Domain values
[ ] Domain profiles
[ ] Stance values
[ ] Stance profiles
[ ] Composition check
[ ] Safety rules
[ ] System preview
```

### Save Points

At the end of each phase, the builder writes a work-in-progress manifest and any completed profiles to disk. This means:
- The user can `/build system --resume product-dev` in a later session
- Partial systems exist on disk even if the build is interrupted
- The builder picks up where it left off based on what files exist and what's missing

### Batch Review

For efficiency, the builder offers batch review for profiles within an axis:

> "I've drafted all 5 disposition profiles. Would you like to:
> (a) Review each one in full — detailed, takes ~10 minutes
> (b) Review the summary table — quick, adjust only what stands out
> (c) Trust the drafts and move to domains — you can refine later"

Option (b) is the sweet spot for most users — review the summary, adjust the outliers, trust the rest. Option (a) is for users who want full control. Option (c) is for experienced users who want to get to a working system fast and iterate later.

---

## Relationship to Other Specs

| Spec | Scope | Relationship |
|---|---|---|
| [Extensible Systems](extensible-systems.md) | What a system IS (manifest, axes, profiles, safety) | System builder CREATES these artifacts |
| [Character Depth](character-depth.md) | What a character IS (convictions, reflexes, history) | Characters are created WITHIN a system's vocabulary |
| [Character Builder](character-builder.md) | How characters are CREATED interactively | Character builder operates within the active system |
| **System Builder** (this doc) | How systems are CREATED interactively | Produces the vocabulary that character builder uses |

The dependency chain: System Builder → Extensible Systems → Character Builder → Character Depth. You build the system first, then build characters within it.

---

## Implementation

### Skill File

New skill: `.claude/skills/build/SKILL.md` (shared with character builder — the `/build` skill dispatches to character or system flow based on arguments).

```
/build system ...     → system builder flow
/build party ...      → party assembly flow
/build quick ...      → quick character creation
/build [anything else] → character builder flow
```

### CLI Dependencies

The system builder needs `bin/npc` to support system management:

```
npc system create <name>                # Create empty system directory + manifest
npc system validate <name>              # Check manifest + profiles for completeness
npc system use <name>                   # Set as active system
npc system list                         # List available systems
```

The builder calls these at the end of the flow. Profile files are written directly by the builder (via the Write tool), not through the CLI — the CLI manages the manifest and registration, while the profiles are just markdown files.

### Profile Generation

The builder generates profiles using the agent's own language capabilities. It does not call external APIs or use templates beyond the structural contract. Each profile is generated fresh from the conversational context, following the authoring guidelines.

The quality of generated profiles depends on the quality of the Phase 1-3 conversation. A well-articulated domain description and clear value distinctions produce better profiles than vague inputs. The builder should invest more time in the early phases (domain discovery, value elicitation) to make profile generation smoother.
