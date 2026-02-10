---
name: quest
description: "Dispatch a task to a party. Usage: /quest <task> [--mode council|expedition] [--party name]"
argument-hint: "<task description> [--mode council|expedition] [--party name]"
disable-model-invocation: true
---

# Quest — Dispatch Task to Party

> **Context:** The `skill-context` hook injects NPC state when this skill is invoked. Use the `Project dir` value as `$PROJECT_DIR` in bash commands below. The active party name is available directly from hook context.

Send a task to an adventuring party. Each party member approaches the task from their alignment+class perspective, then the results are synthesized.

## Arguments

`$ARGUMENTS`

## Parse Arguments

- **task** (required): Everything that isn't a flag. This is the quest description.
- **--mode council|expedition**: Execution mode. Default: `council`.
  - `council`: Single agent inhabits each member's perspective sequentially.
  - `expedition`: Each member runs as a parallel subagent via the Task tool.
- **--party name**: Target party. If omitted, uses the active party.

## Member Display Convention

Throughout this skill, identify members by their character bead title (name). If the character has a role label, prefix with the role.

## Step 1: Load the Party

Resolve which party to use. If `--party` specified, resolve via `resolve-party.sh`. Otherwise use active party from hook context and resolve.

```bash
PARTY_ID=$("$PROJECT_DIR"/hooks/scripts/resolve-party.sh "<party-name>")
```

Get party details and members:
```bash
bd show "$PARTY_ID" --json
bd children "$PARTY_ID" --json
```

For each child bead, extract:
- **name**: bead title
- **alignment**: from `alignment:*` label
- **class**: from `class:*` label (may be absent)
- **role**: from `role:*` label (may be absent)
- **persona**: bead description

If the party has no children, error: "Party **<name>** has no members. Use `/recruit` to add members first."

## Step 2: Safety Check

Before executing, check for Evil-aligned members (alignment label contains "evil").

**For each Evil member:**
- Announce: "**<name>** has an Evil alignment (<alignment>). Evil members will operate under safety constraints."

**If any Chaotic Evil member:**
- Require explicit confirmation. Ask the user to type **"unleash the gremlin"** before proceeding.

**If any other Evil member (Lawful Evil or Neutral Evil):**
- Announce and ask: "Proceed with Evil-aligned members? [Y / Remove]"

**Class-specific Evil constraints:**
- Evil + Rogue: "This member is restricted to analysis only — no code production."
- Evil + Cleric: "This member's infrastructure changes require explicit approval."

## Step 3: Announce the Quest

Display the quest briefing:

```
## Quest Briefing

**Party:** <party-name> (<N> members)
**Mode:** <council|expedition>
**Task:** <task description>

### Roster
| # | Name | Alignment | Class | Role |
|---|------|-----------|-------|------|
| 1 | <name> | <alignment> | <class or "—"> | <role or "—"> |
| ... | ... | ... | ... | ... |
```

If any members have a persona, list them:

```
**Personas:**
- **<name>**: <persona text>
```

## Step 4: Execute

### Council Mode (Sequential Perspectives)

For each member in roster order:

1. **Read** the member's alignment behavioral profile:
   - Use the Read tool on `.claude/skills/<alignment>/SKILL.md`

2. **Read** the member's class behavioral profile (if class is set):
   - Use the Read tool on `.claude/skills/<class>/SKILL.md`

3. **Fully adopt** that member's alignment and class. Inhabit their:
   - Code style and formatting preferences
   - Testing approach and thresholds
   - Error handling philosophy
   - Communication tone and verbosity
   - Decision heuristics and trade-off priorities
   - Domain expertise and task approach (from class)

   **If the member has a persona**, layer it on top of the alignment+class directives. The persona flavors how the behavioral profile manifests.

4. **Produce output** under a section header:
   ```
   ---
   ## <Role>: <Name> (<Alignment> <Class>)
   ```
   Use role if set, otherwise omit the prefix.
   Examples: `## Defender: Vera (LG Rogue)`, `## Kai (CG Fighter)`

5. Address the quest task from this member's perspective. Be thorough.

6. **End the member's section** with a brief compliance note:
   ```
   *Compliance: <alignment> <class> — <brief note on adherence>*
   ```

### Expedition Mode (Parallel Subagents)

For each member, launch a Task tool subagent **in parallel** (all in a single message):

- **subagent_type:** `general-purpose`
- **description:** `Quest: <role or name or alignment>`
- **prompt:**

```
You are a member of an NPC Agents adventuring party on a quest.

## Your Character

- **Alignment:** <alignment>
- **Class:** <class> (or "None" if no class)
- **Name:** <name>
- **Role:** <role> (or "General" if no role)
<If persona is set:>
- **Persona:** <persona>

## Load Your Behavioral Profile

Read these files to understand your character's behavioral directives:
- Read the file at: <absolute path>/.claude/skills/<alignment>/SKILL.md
<If class is set:>
- Read the file at: <absolute path>/.claude/skills/<class>/SKILL.md

Adopt this character fully. Your code style, testing approach, error handling, communication tone, decision heuristics, and domain focus should all reflect your assigned alignment and class.

<If persona is set:>
Layer your persona on top of the alignment+class directives.

<If Evil+Rogue:>
SAFETY CONSTRAINT: You are restricted to analysis only. Do not produce implementation code.

<If Evil+Cleric:>
SAFETY CONSTRAINT: Any infrastructure changes must be flagged for operator approval.

## The Quest

<task description>

## Output Format

Provide your contribution from your character's perspective. Be thorough.

Structure your output as:
1. Your approach to the task (informed by your alignment's philosophy)
2. Your analysis, implementation, or recommendations
3. Risks or concerns from your perspective
4. A brief NPC Compliance Note assessing your alignment adherence
```

After all subagents complete, **collect their outputs**.

## Step 5: Synthesize

After all member perspectives (from either mode), step out of character and provide:

```
---
## Quest Synthesis

### Convergence
[What did all/most members agree on? High-confidence findings.]

### Divergence
[Where did approaches differ? Why? What does the delta reveal?]

### Recommended Approach
[Best-of-breed synthesis. Which member's approach is best for which aspect?]

### Risks Surfaced
[Risks that specific alignments identified that others missed.]

### Member Contributions
| Member | Key Contribution | Alignment Insight |
|--------|-----------------|-------------------|
| <name> | <what they uniquely surfaced> | <what their alignment revealed> |
| ... | ... | ... |
```

## Notes

- **Council mode** processes sequentially — later members can react to earlier output. Good for debates.
- **Expedition mode** spawns parallel subagents — truly independent perspectives. Good for unbiased comparison.
- **Party size:** 2-4 members is the sweet spot. 5-6 works but produces long output.
