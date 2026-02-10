---
name: quest
description: "Dispatch a task to a party. Usage: /quest <task> [--mode council|expedition|debate] [--party name] [--bead id] [--create] [--conviction \"...\"] [--rounds N]"
argument-hint: "<task description> [--mode council|expedition|debate] [--party name] [--bead id] [--create] [--conviction \"...\"] [--rounds N]"
disable-model-invocation: true
---

# Quest — Dispatch Task to Party

> **Context:** The `skill-context` hook injects NPC state when this skill is invoked. Use the `Project dir` value as `$PROJECT_DIR` in bash commands below. The active party name is available directly from hook context.

Send a task to an adventuring party. Each party member approaches the task from their alignment+class perspective, then the results are synthesized.

Quests can operate in three ways:
- **Analysis** (default): Party members give perspectives on a task. Nothing persistent is created.
- **Work a bead** (`--bead <id>`): Party members claim and execute tasks from an existing epic's ready front.
- **Create work** (`--create`): After analysis, persist the recommendations as a beads epic with tasks.

And in three execution modes:
- **Council** (default): Single agent inhabits each member sequentially. Later members react to earlier output.
- **Expedition**: Each member runs as a parallel subagent. Truly independent perspectives.
- **Debate**: Structured adversarial exchange with positions, exchange rounds, and arbiter synthesis.

## Arguments

`$ARGUMENTS`

## Parse Arguments

- **task** (required): Everything that isn't a flag. This is the quest description.
- **--mode council|expedition|debate**: Execution mode. Default: `council`.
  - `council`: Single agent inhabits each member's perspective sequentially.
  - `expedition`: Each member runs as a parallel subagent via the Task tool.
  - `debate`: Structured three-phase adversarial exchange with arbiter synthesis.
- **--party name**: Target party. If omitted, uses the active party.
- **--bead id**: An existing epic or task bead ID. Party members work its ready front instead of giving analysis.
- **--create**: After analysis, create a beads epic with child tasks from the synthesis recommendations.
- **--conviction "..."**: Repeatable. Quest-level conviction that applies to ALL party members for this quest. Supplements (does not replace) personal convictions. Works with all modes.
- **--rounds N**: Number of exchange rounds for debate mode. Default: 2. Range: 1-4. Ignored in council/expedition mode.

`--bead` and `--create` are mutually exclusive. If both are provided, error: "Use `--bead` to work existing beads or `--create` to generate new ones, not both."

`--mode debate` and `--bead` are mutually exclusive. Debate mode is for analysis, not execution. If both are provided, error: "Debate mode is for structured analysis. Use `--mode council` or `--mode expedition` with `--bead` to work existing beads."

`--mode debate` requires at least 2 party members. If the party has fewer than 2 members, error: "Debate mode requires at least 2 party members to exchange positions."

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
- **alignment**: from disposition label (e.g. `alignment:*` for default system)
- **class**: from domain label (e.g. `class:*` for default system)
- **role**: from `role:*` label (may be absent)
- **persona**: bead description
- **system**: from `system:*` label (default: `alignment-grid`)
- **perspective**: from stance label (e.g. `perspective:*` for default system, default: `developer`)
- **convictions**: from bead notes JSON `.convictions[]` (may be empty)

If the party has no children, error: "Party **<name>** has no members. Use `/recruit` to add members first."

## Step 2: Safety Check

Before executing, check for members with restricted dispositions per the active system's safety manifest.

Load the member's system manifest (`systems/<system>/.manifest.json`) and check `safety.restricted[]` for their disposition. If restricted:

**For each restricted member:**
- Announce: "**<name>** has a restricted disposition (<disposition>). This member will operate under safety constraints."

**If a member's restriction has `confirmPhrase`:**
- Require explicit confirmation. Ask the user to type the confirm phrase before proceeding.

**If a member's restriction has `requireConfirmation`:**
- Announce and ask: "Proceed with restricted members? [Y / Remove]"

**Cross-constraints** (`safety.crossConstraints[]`): Check disposition tag + domain combinations:
- `analysisOnly: true`: "This member is restricted to analysis only — no code production."
- `requireApproval: true`: "This member's changes in constrained paths require explicit approval."

## Step 3: Announce the Quest

Display the quest briefing:

```
## Quest Briefing

**Party:** <party-name> (<N> members)
**Mode:** <council|expedition|debate>
**Task:** <task description>
```

If `--mode debate`, also show:
```
**Rounds:** <N>
```

If `--bead` is set, also show:
```
**Working bead:** <bead-id> — <bead title>
```
And run `bd swarm status <bead-id>` to show the current ready front.

```
### Roster
| # | Name | Alignment | Class | Perspective | Role |
|---|------|-----------|-------|-------------|------|
| 1 | <name> | <alignment> | <class or "—"> | <perspective> | <role or "—"> |
| ... | ... | ... | ... | ... | ... |
```

If any members have a persona, list them:

```
**Personas:**
- **<name>**: <persona text>
```

If any members have convictions, list them:

```
**Member Convictions:**
- **<name>**: <conviction 1>; <conviction 2>; <conviction 3>
```

If `--conviction` flags were provided, show them:

```
**Quest Convictions (shared by all members):**
- <conviction 1>
- <conviction 2>
```

## Step 4: Execute

### If `--bead` is provided: Work the Ready Front

This replaces the normal analysis flow. The party works real beads tasks.

1. **Load the bead's work:**
   ```bash
   bd show <bead-id> --json
   bd children <bead-id> --json
   bd swarm status <bead-id>
   ```

2. **Identify ready tasks** — tasks that are open/unblocked and unclaimed (no assignee or status=open).

3. **Match tasks to party members** by class affinity:
   - Look at each task's type and content. Match to the party member whose class has the highest affinity for that kind of work.
   - If multiple members suit a task, prefer the one without active work.
   - If no clear match, assign to the member with the broadest affinities (typically Fighter).

4. **For each matched member-task pair**, execute using the chosen mode:

   **Council mode:** For each member sequentially:
   - Load their full context: `bin/npc ctx <member-name>`
   - Adopt their character fully (see "Council Mode" section below for details)
   - Claim: `bd update <task-id> --status=in_progress -a "<member-name>"`
   - Work the task from their perspective — actually produce the deliverable (code, analysis, design, tests, etc.)
   - Close: `bd close <task-id>`
   - Show updated swarm status: `bd swarm status <bead-id>`

   **Expedition mode:** For each member in parallel, launch a Task subagent whose prompt includes:
   - The character's full context (from `bin/npc ctx <member-name>`)
   - The specific task to work (bead ID, title, description)
   - Instructions to claim (`bd update <id> --claim`), work, and close (`bd close <id>`)

5. **After all ready tasks are worked**, show final swarm status.

6. **If more waves are now unblocked**, announce: "Wave complete. <N> new tasks unblocked. Run `/quest` again to continue, or let party members work `bd ready` directly."

### Council Mode (Sequential Perspectives)

For each member in roster order:

1. **Load** the member's full behavioral context:
   ```bash
   bin/npc ctx <member-name>
   ```
   This outputs the complete behavioral profile: alignment profile, class profile, perspective preamble, persona, convictions, reflexes, and history — all in one command.

2. **Fully adopt** that member's character. Inhabit their entire behavioral profile as output by the context command.

3. **Inject quest-level convictions** (if any `--conviction` flags were provided):
   After adopting the member's character context, apply quest convictions as supplementary focus:
   ```
   ## Quest Convictions (shared focus for this quest)
   These supplement your personal convictions for this quest:
   - <quest conviction 1>
   - <quest conviction 2>
   ```
   These layer on top of the member's personal convictions. Do not replace personal convictions.

4. **Produce output** under a section header:
   ```
   ---
   ## <Role>: <Name> (<Alignment> <Class>)
   ```
   Use role if set, otherwise omit the prefix.
   Examples: `## Defender: Vera (LG Rogue)`, `## Kai (CG Fighter)`

5. Address the quest task from this member's perspective. Be thorough. If quest convictions were provided, let them shape your focus alongside your personal convictions.

### Expedition Mode (Parallel Subagents)

For each member, launch a Task tool subagent **in parallel** (all in a single message):

- **subagent_type:** `general-purpose`
- **description:** `Quest: <role or name or alignment>`
- **prompt:**

```
You are a member of an NPC Agents adventuring party on a quest.

## Your Character

- **Name:** <name>
- **Alignment:** <alignment>
- **Class:** <class> (or "None" if no class)
- **Role:** <role> (or "General" if no role)

## Load Your Behavioral Profile

Run this command to get your full behavioral context:
```bash
bin/npc ctx <name>
```

This outputs your alignment profile, class profile, perspective preamble, persona, convictions, reflexes, and history. Adopt the character fully.

<If Evil+Rogue:>
SAFETY CONSTRAINT: You are restricted to analysis only. Do not produce implementation code.

<If Evil+Cleric:>
SAFETY CONSTRAINT: Any infrastructure changes must be flagged for operator approval.

<If --conviction flags provided:>
## Quest Convictions (shared focus for this quest)
These supplement your personal convictions for this quest:
- <quest conviction 1>
- <quest conviction 2>
...
Apply these alongside your character's own convictions.

## The Quest

<task description>

## Output Format

Provide your contribution from your character's perspective. Be thorough.

Structure your output as:
1. Your approach to the task (informed by your alignment's philosophy)
2. Your analysis, implementation, or recommendations
3. Risks or concerns from your perspective
```

After all subagents complete, **collect their outputs**.

### Debate Mode (Structured Adversarial Exchange)

Debate mode runs a three-phase structured exchange: Positions, Exchange, and Synthesis. It produces dialectic output where positions clash and merge through structured rounds, surfacing genuine disagreements and concessions.

**Debate is always analysis-only.** It cannot be combined with `--bead`. It can be combined with `--create` (the arbiter's synthesis recommendations become persisted beads).

Begin the debate output with:

```
---
## Debate: <quest task>

**Party:** <party-name> (<N> debaters + arbiter)
**Rounds:** <N>

---
```

#### Phase 1: Positions

Each party member states their core position on the quest task. Process members sequentially (council-style). For each member in roster order:

1. **Load** the member's full behavioral context:
   ```bash
   bin/npc ctx <member-name>
   ```

2. **Fully adopt** that member's character. Inhabit their entire behavioral profile as output by the context command.

3. **Inject quest-level convictions** (if any), same as in council mode.

4. **Produce a position statement** under the section:
   ```
   ### Positions

   #### <Name> (<Alignment> <Class> · <Perspective>)
   <2-4 sentence position statement. State what you think about the quest task and why.
   No rebuttals, no reactions to other members. Just your core position.>
   ```

**Critical constraint:** In the Positions phase, do NOT reference other members' positions. Each position must be independent. Even though earlier positions are visible in the output, pretend they do not exist yet. This prevents drift and ensures honest initial positions.

#### Phase 2: Exchange

Run the configured number of rounds (default: 2). Each round processes all members sequentially. For each round:

Output the round header:
```
---

### Exchange — Round <N>
```

For each member in roster order:

1. **Re-adopt** the member's character (reload context via `bin/npc ctx <member-name>` if needed for fresh grounding).

2. The full debate context so far — all positions from Phase 1 and all prior round outputs — is visible in the conversation. Use it.

3. **Produce a response** that:
   - Addresses at least one other member's position or prior response **by name**
   - Engages with substance, not just restating their own position
   - May concede points ("Marcus is right that..."), strengthen their position ("Sam's concern actually supports my point because..."), or challenge ("Vera's assumption that X doesn't hold because...")

4. **Output format:**
   ```
   #### <Name>
   <Response addressing other members' positions by name.
   Build on the full debate so far.
   Later rounds should reflect sharpened positions — narrower claims, specific concessions,
   direct rebuttals to the strongest opposing arguments.>
   ```

**Round dynamics:** Within a single round, each member responds based on all positions and all prior rounds. Members producing output later in the same round will naturally see earlier same-round responses — this is acceptable and adds richness. The key constraint is that each member must primarily engage with prior content, not just react to the member who spoke immediately before.

**Progression:** Round 1 should be exploratory — finding points of agreement and disagreement. Round 2 should sharpen — narrowing to the core tensions. Round 3+ (if configured) should converge — making final concessions and drawing lines.

#### Phase 3: Synthesis (Arbiter)

After all exchange rounds complete, **step out of all party member characters**. Adopt the Arbiter role:

```
---

### Synthesis (Arbiter)
```

**Arbiter Profile:**
- **Alignment:** Neutral Good
- **Class:** None
- **Role:** Synthesis only
- The arbiter did **not** participate in Phases 1 or 2
- The arbiter does **not** advocate for any position
- The arbiter reads all output and produces a fair merged recommendation

**The Concession Principle:** Every position that survived the exchange is represented in the final recommendation, proportional to how well it held up:
- **Strongest surviving points** get primary weight in the recommendation
- **Weaker points that weren't fully refuted** are acknowledged as caveats or secondary recommendations
- **Points convincingly defeated** are noted as considered-and-set-aside
- This prevents winner-take-all outcomes — a minority position that raised a legitimate concern still influences the recommendation

**Arbiter output:**

```
#### Recommendation
<Merged recommendation incorporating all surviving positions proportionally.
This is the debate's primary output — a balanced synthesis where every
surviving position has influence proportional to how well it held up.>

#### Surviving Points
| Member | Position | Outcome |
|--------|----------|---------|
| <name> | <core claim from their position> | Adopted / Adopted with modification / Acknowledged as caveat / Considered and set aside |
| ... | ... | ... |

#### Unresolved Tensions
<Disagreements the party could not settle — flagged for the operator to decide.
If none, state "None — all tensions were resolved through exchange.">

#### Concessions Made
<Specific points where the recommendation incorporates minority positions.
Name the member whose point was incorporated and explain how it shaped the recommendation.
If no minority positions were incorporated, state "None — recommendation reflects consensus.">
```

After the arbiter synthesis, if `--create` is set, proceed to the "Persist as Beads" step using the arbiter's recommendation as the source for task creation.

## Step 5: Synthesize

**If `--mode debate`:** Skip this step. Debate mode produces its own synthesis via the Arbiter in Phase 3. Proceed directly to "Persist as Beads" if `--create` is set.

After all member perspectives (from council or expedition mode), step out of character and provide:

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

### If `--create` is set: Persist as Beads

After synthesis, create tracked work from the recommendations:

1. **Create the epic:**
   ```bash
   EPIC_ID=$(bd create "<quest task summary>" -t epic -l "npc:quest,party:<party-name>" -d "<brief quest context>" --silent)
   ```

2. **Create child tasks** for each recommended action from the synthesis. For each:
   ```bash
   TASK_ID=$(bd create "<action title>" -t task --parent "$EPIC_ID" -l "assigned:<best-member>" -d "<description from synthesis>" --silent)
   ```
   Match task type to bead type where appropriate: use `-t bug` for identified defects, `-t feature` for new functionality, `-t task` for general work, `-t chore` for maintenance.

3. **Wire dependencies** based on the synthesis ordering. If task B should follow task A:
   ```bash
   bd dep add "$TASK_B_ID" "$TASK_A_ID"
   ```

4. **Show the result:**
   ```bash
   bd graph "$EPIC_ID"
   bd swarm validate "$EPIC_ID"
   ```

5. **Announce:** "Quest work created as **<epic-id>**: <title>. Party members can start with `bd ready`."

### If `--bead` is set: Show Progress

After working the ready front, show final status instead of the normal synthesis:

```
---
## Quest Progress: <bead-title>

<output of bd swarm status <bead-id>>

### Work Completed This Quest
| Task | Member | Status |
|------|--------|--------|
| <task title> | <member who worked it> | completed / in_progress |

### Next Steps
[What's now unblocked? Who should pick it up? Any new work discovered?]
```

## Notes

- **Council mode** processes sequentially — later members can react to earlier output. Good for iterative refinement.
- **Expedition mode** spawns parallel subagents — truly independent perspectives. Good for unbiased comparison.
- **Debate mode** runs structured adversarial exchange — positions clash and merge through rounds. Good for resolving disagreements, evaluating trade-offs, and feature planning.
- **Party size:** 2-4 members is the sweet spot. 5-6 works but produces long output. Debate mode with 4+ members and 3+ rounds produces very long output — consider 2-3 members for debates.
- **Quest convictions** (`--conviction`) work with ALL modes, not just debate. They focus the entire party's attention on context-specific concerns for the duration of the quest.
- **`--bead` mode** is for working through existing tracked work. The party executes, not just analyzes.
- **`--create` mode** turns analysis into tracked beads. Works with council, expedition, and debate modes. For debate, the arbiter's synthesis recommendations become the persisted work items.
- **Default mode** (no flags) is the original one-shot analysis. Still useful for quick perspectives without beads overhead.
- **Debate + `--create`** uses the arbiter's recommendation as the source for epic/task creation. The surviving points table maps naturally to individual tasks.
