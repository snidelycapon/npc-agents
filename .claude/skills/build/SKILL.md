---
name: build
description: "Interactive builder for systems, characters, and parties. Usage: /build system [--from|--extend|--resume <name>]"
argument-hint: "system [--from|--extend|--resume <name>] | character | party"
---

# Build — Interactive Builder

> **Context:** The `skill-context` hook injects NPC state when this skill is invoked. Use the `Project dir` value as `$PROJECT_DIR` in bash commands below.

## Arguments

`$ARGUMENTS`

## Dispatch

Parse the first argument to determine the build mode:

- `system` → **System Builder** (this skill's primary flow)
- `character` → Stub: "Character builder coming in Phase 4. Use `bin/npc create` for now."
- `party` → Stub: "Party builder coming in Phase 4. Use `bin/npc party create` and `bin/npc recruit` for now."
- `quick` → Stub: "Quick character creation coming in Phase 4."
- No argument → Ask: "What would you like to build? (system / character / party)"

For `system`, parse remaining flags:

- `--from <name>` → **Clone and Modify** flow
- `--extend <name>` → **Extension** flow
- `--resume <name>` → **Resume** flow (read progress, jump to first incomplete phase)
- No flags → **From Scratch** flow (ask for a system name, then scaffold via CLI)

---

## System Builder: From Scratch

This flow creates a complete behavioral system through a 7-phase guided interview. The agent conducts each phase conversationally, generates profiles using its own language capabilities, and writes files to disk. The CLI handles scaffolding and validation; the agent handles the creative work.

### Getting Started

1. Ask the user for a system name (kebab-case, e.g., `product-dev`, `security-ops`)
2. Scaffold via CLI:
   ```bash
   bin/npc system create <name>
   ```
3. Begin Phase 1.

After each phase, update the progress file at `systems/<name>/.build-progress.json` using the Write tool — set the completed phase's status to `"complete"` and store any captured data in its `data` field. Set the next phase to `"in_progress"`.

---

### Phase 1: Domain Discovery

**Goal:** Understand the context this system will serve.

Ask the user to describe their domain. Probe for:

- **What kind of work gets done?** (Code review, product planning, editorial, security assessment, research, creative work)
- **What behavioral differences matter?** (Risk tolerance? Speed vs. quality? User empathy vs. technical depth? Communication style?)
- **Who are the characters representing?** (Team member archetypes? Advisory personas? User personas? Competitive analysis?)

Then determine axis count:

> "Most systems define three dimensions: a behavioral orientation (disposition), an expertise focus (domain), and a viewpoint (stance). Does your domain need all three, or would two be sufficient?"

Some domains only need disposition + domain, with stance being unnecessary.

**Example opening:**

> "What context will this system serve? Describe the domain, the kinds of work being done, and the team or audience that will use these characters."
>
> "For example: 'We're a product team building developer tools. We want characters that reflect our decision-making cultures and product roles, not D&D archetypes.'"

**Save:** Update `.build-progress.json` — set `domain_discovery` to complete with `data: { "domain_description": "...", "axis_count": 2|3 }`.

---

### Phase 2: Axis Definition

**Goal:** Name and describe each axis.

For each axis the user needs, help them articulate what it represents. Walk through them one at a time:

> "Let's define your first axis — the **behavioral orientation**. In the default system this is called 'Alignment' and describes how agents approach quality and decision-making. What's the equivalent dimension in your domain?"

For each axis, capture:
- **label**: Human-readable name (e.g., "Culture", "Posture", "Voice")
- **prefix**: Slug for bead labels — suggest lowercased label (e.g., "culture")
- **description**: One sentence explaining what this axis governs

**Example suggestions by domain:**
- Product teams: Culture (disposition), Role (domain), Viewpoint (stance)
- Security teams: Posture (disposition), Specialization (domain), Position (stance)
- Editorial teams: Voice (disposition), Function (domain), Audience (stance)

After defining all axes, update `system.yaml` with the axis labels, prefixes, and descriptions. Read the current file, update the relevant fields, and write it back.

**Save:** Update `.build-progress.json` — set `axis_definition` to complete with axis data.

---

### Phase 3: Value Elicitation

**Goal:** Identify the distinct values for each axis through contrast-based elicitation.

**Work through contrast, not enumeration.** Rather than asking "list your dispositions," ask questions that surface the differences that matter:

> "Think about the people (or archetypes) in your domain. When two of them disagree about the right approach, what's the underlying tension? That tension is usually an axis value."

For each axis, collect candidate values, then refine:

> "You've described 4 dispositions: user-first, data-driven, ship-fast, and quality-first. Let me check for coverage:
>
> - Is there a disposition that represents 'grow the user base above all else'? That might be distinct from user-first (serving existing users) vs. growth-focused (acquiring new ones).
> - Are any two of these too similar to produce genuinely different agent behavior? If data-driven and quality-first would act the same way in most situations, consider merging them."

**Value count guidance:**
- Dispositions: 3-9 values (enough variety for useful tension, not so many that distinctions blur)
- Domains: 3-8 values (distinct expertise areas)
- Stances: 2-4 values (viewpoints are usually fewer)

For each value, capture:
- **name**: slug-case identifier (e.g., `user-first`)
- **quote**: Core philosophy in one sentence (becomes the profile's opening quote)
- **traits**: 3-5 bullet points describing how this value manifests (seeds for profile generation)

After all values are defined, update `system.yaml` — add the value names to each axis's `values` array. Also add metadata entries if the user provided short descriptions.

**Save:** Update `.build-progress.json` with the full value data including names, quotes, and traits.

---

### Phase 4: Profile Generation

**Goal:** Generate full behavioral profiles for every value.

**Generate in batches by axis.** All dispositions at once, then all domains, then all stances. This lets the user review for internal consistency within an axis.

**Step 1: Summary table.** Before writing full profiles, present a summary for approval:

> "I've drafted profiles for your 5 dispositions. Here's a summary:"
>
> | Disposition | Core Principle | Key Heuristic | Characteristic Action |
> |---|---|---|---|
> | user-first | "Start with the person" | When prioritizing: user pain > technical elegance | Prototype with real users before committing |
> | data-driven | "Evidence over intuition" | When debating: show me the numbers | A/B test before full rollout |
> | ... | ... | ... | ... |
>
> "Does this capture the distinctions? Any value feel off, redundant, or missing a key behavior?"

**Step 2: Full profiles.** After the user approves the direction, generate each profile following the **Profile Contract** (see below). Write each profile to `systems/<name>/dispositions/<value>.md` (or `domains/`, `stances/`) using the Write tool.

**Step 3: Review option.** Offer the user a review choice:

> "I've drafted all 5 disposition profiles. Would you like to:
> (a) Review each one in full — detailed
> (b) Review the summary table — quick, adjust only what stands out
> (c) Trust the drafts and move to domains — you can refine later"

For option (a), show each profile and iterate. For (b), show the summary and only regenerate if the user flags something. For (c), proceed to the next axis.

**Repeat for each axis** (domains, then stances).

**Save:** Update `.build-progress.json` — track which profiles have been written per axis.

---

### Phase 5: Composition Check

**Goal:** Validate that dispositions and domains compose coherently.

Pick 3-5 representative disposition x domain combinations. For each, describe how the combined character would behave:

> "Let me check a few combinations to make sure they produce coherent behavior:"
>
> **User-First + Engineer**: "An engineer who starts every technical decision with 'how does this affect the user?' — writes defensive error handling, optimizes perceived performance, pushes back on abstractions that add latency."
>
> **Ship-Fast + Designer**: "A designer who moves fast — low-fidelity mocks, design-in-browser, skips pixel perfection in favor of testing the interaction with real users."
>
> "Do these feel like coherent characters? Any combination that seems contradictory or unproductive?"

If a combination doesn't work, help adjust the profile causing the conflict — usually by making principles slightly more flexible or clarifying where disposition yields to domain expertise. Rewrite the adjusted profile.

**Save:** Update `.build-progress.json` — mark complete.

---

### Phase 6: Safety Rules

**Goal:** Determine if any values or combinations need guardrails.

Ask whether any values or combinations should be constrained:

> "In the default system, 'Evil' alignments are restricted from sensitive file paths and require confirmation before destructive operations. Does your system have any values or combinations that should be constrained?"
>
> "Common patterns:
> - **High-risk dispositions** that might produce destructive suggestions
> - **Dangerous combinations** where a disposition + domain pairing should be limited
> - **Restricted stances** limited to analysis only
>
> If nothing feels dangerous, that's fine — not every system needs restrictions."

If the user defines restrictions, capture them in the manifest format:

```yaml
safety:
  restricted:
    - value: <disposition-value>
      tag: <tag-for-cross-constraints>
      constraints:
        blockedPaths: ["path/", ...]
        requireConfirmation: true
        confirmPhrase: "optional phrase"  # only if needed
  crossConstraints:
    - disposition: <tag>
      domain: <domain-value>
      constraint: { analysisOnly: true }
```

Update `system.yaml` with the safety section.

**Save:** Update `.build-progress.json` — mark complete.

---

### Phase 7: System Preview

**Goal:** Present the complete system for final approval and write all files.

Display the complete system summary:

```
## System Preview: <name>

**Domain:** <domain description>
**Axes:** <N> (<label1> x <label2> [x <label3>])

### <Disposition label>
| Value | Philosophy |
|---|---|
| <value> | "<quote>" |
| ... | ... |

### <Domain label>
| Value | Focus |
|---|---|
| <value> | "<description>" |
| ... | ... |

### <Stance label> (if applicable)
| Value | Perspective |
|---|---|
| <value> | "<description>" |
| ... | ... |

### Safety
<summary of restrictions or "No restrictions">

### Files
- system.yaml (manifest)
- <N> disposition profiles
- <N> domain profiles
- <N> stance profiles
- Total: <N> files
```

Ask: **"Create this system? [Yes / Adjust / Start over]"**

On **Yes**:
1. Ensure the final `system.yaml` is written with all values, metadata, and safety rules
2. Generate the manifest cache:
   ```bash
   bin/manifest-cache systems/<name>/system.yaml systems/<name>/.manifest.json
   ```
3. Validate:
   ```bash
   bin/npc system validate <name>
   ```
4. Update `.build-progress.json` — mark all phases complete
5. Announce: "System **<name>** created with <N> profiles. Activate with `bin/npc system use <name>`."

On **Adjust**: Ask what to change, make the adjustments, re-preview.

On **Start over**: Delete `systems/<name>/` and restart from Phase 1.

---

## Profile Contract

Every behavioral profile follows this structure. The agent generates this content for each value.

```markdown
# <Value Name>

> "<Core philosophy in one sentence>"

## Principles
> Always apply. Override heuristics and actions when in conflict.

1. **<Principle name>.** <Description — must be a decision-making tool, not a platitude>
2. ...
3. ...

## Heuristics
> Guide decisions in context. Apply with judgment.

- **When <situation>:** <guidance — must be situational, not always-true>
- ...

## Actions
> Typical behaviors. Project conventions may override.

### <Category>
- <Specific concrete behavior>
- ...

## Communication
- **Tone:** <description>
- **Verbosity:** <level and explanation>

## Boundaries
- **Will refuse:** <what this value won't do>
- **Will warn about:** <what triggers a warning>
- **Will do without asking:** <automatic behaviors>
```

---

## Profile Authoring Guidelines

Follow these guidelines when generating profiles:

### Principles Must Be Decision-Making Tools
- Bad: "We value quality." (Platitude — doesn't help make a decision)
- Good: "Correctness above all. Every function does exactly what it claims." (An agent can apply this to any task)

### Heuristics Must Be Situational
- Bad: "Write good tests." (Always true, says nothing)
- Good: "When facing ambiguity: choose the interpretation that lets you ship something." (Tells the agent what to do in a specific context)

### Actions Must Be Concrete and Overridable
- Bad: "Follow best practices." (Undefined)
- Good: "Test outcomes, not implementations. 'User can create an account' over 'UserService.create calls Repository.save.'" (Concrete, with example)

### Dispositions Must Disagree
The test: if you pick any two disposition values and give them the same task, they should produce *meaningfully different* output. If two dispositions would write the same code review, the axis isn't differentiating enough.

### Domains Must Not Duplicate Dispositions
A domain describes *what you focus on*, not *how you feel about it*. Two agents with the same disposition but different domains should produce different output on the same task.

---

## Clone and Modify Flow (--from)

When invoked with `--from <source>`:

1. Ask for the new system name
2. Scaffold via CLI:
   ```bash
   bin/npc system create <new-name> --from <source>
   ```
3. Load the cloned manifest and walk through each axis:
   > "Here are the current dispositions: [list]. For each, tell me: **keep**, **rename**, **modify**, or **remove**."
4. For **kept** values: no action (profile already exists)
5. For **renamed** values: rename the `.md` file, update the `# Name` heading inside, update `system.yaml`
6. For **modified** values: show the current profile, ask what to change, rewrite
7. For **removed** values: delete the `.md` file, remove from `system.yaml`
8. For **new** values: run the standard value elicitation + profile generation
9. Proceed through Phases 5-7 (composition check, safety, preview)

This is faster than building from scratch because most profile content already exists.

---

## Extension Flow (--extend)

When invoked with `--extend <name>`:

This modifies an existing system in-place by adding new values to an axis.

1. Verify the system exists:
   ```bash
   bin/npc system show <name>
   ```
2. Ask: "Which axis do you want to extend?" (disposition, domain, or stance)
3. Show current values on that axis
4. Elicit new values using Phase 3 technique (contrast-based, with existing values as context)
5. Generate profiles for new values only (Phase 4 technique)
6. Composition check: only test new values against existing values
7. Read the current `system.yaml`, add new values to the axis's values array, write it back
8. Update the manifest cache:
   ```bash
   bin/manifest-cache systems/<name>/system.yaml systems/<name>/.manifest.json
   ```
9. Validate:
   ```bash
   bin/npc system validate <name>
   ```

No `.build-progress.json` is needed for extensions — they're small enough for one session.

---

## Resume Flow (--resume)

When invoked with `--resume <name>`:

1. Read `systems/<name>/.build-progress.json`
2. If the file doesn't exist, error: "No build in progress for system '<name>'. Use '/build system' to start."
3. Display progress:
   ```
   ## Build Progress: <name>

   [x] Domain discovery
   [x] Axis definition
   [x] Value elicitation (5 dispositions, 5 domains, 3 stances)
   [>] Profile generation (2/5 dispositions drafted)
   [ ] Composition check
   [ ] Safety rules
   [ ] System preview
   ```
4. Jump to the first non-complete phase
5. If resuming mid-phase (e.g., profile generation with partial progress), use the `data` field to know what's already done
6. Continue the normal flow from that point

---

## Notes

- The agent writes profile files directly via the Write tool — the CLI manages manifest and structure
- The agent generates profiles using its own language capabilities, not templates
- Quality depends on the Phase 1-3 conversation — invest time in domain discovery and value elicitation
- Use `bin/npc system validate <name>` at any point to check completeness
- After building, activate with `bin/npc system use <name>`
