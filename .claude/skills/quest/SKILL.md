---
name: quest
description: "Dispatch a task to a party. Usage: /quest <task> [--mode council|expedition] [--party name] [--bead id] [--create]"
argument-hint: "<task description> [--mode council|expedition] [--party name] [--bead id] [--create]"
disable-model-invocation: true
---

# Quest — Dispatch Task to Party

> **Context:** The `skill-context` hook injects NPC state when this skill is invoked. Use the `Project dir` value as `$PROJECT_DIR` in bash commands below. The active party name is available directly from hook context.

Send a task to an adventuring party. Each party member approaches the task from their alignment+class perspective, then the results are synthesized.

Quests can operate in three ways:
- **Analysis** (default): Party members give perspectives on a task. Nothing persistent is created.
- **Work a bead** (`--bead <id>`): Party members claim and execute tasks from an existing epic's ready front.
- **Create work** (`--create`): After analysis, persist the recommendations as a beads epic with tasks.

## Arguments

`$ARGUMENTS`

## Parse Arguments

- **task** (required): Everything that isn't a flag. This is the quest description.
- **--mode council|expedition**: Execution mode. Default: `council`.
  - `council`: Single agent inhabits each member's perspective sequentially.
  - `expedition`: Each member runs as a parallel subagent via the Task tool.
- **--party name**: Target party. If omitted, uses the active party.
- **--bead id**: An existing epic or task bead ID. Party members work its ready front instead of giving analysis.
- **--create**: After analysis, create a beads epic with child tasks from the synthesis recommendations.

`--bead` and `--create` are mutually exclusive. If both are provided, error: "Use `--bead` to work existing beads or `--create` to generate new ones, not both."

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
**Mode:** <council|expedition>
**Task:** <task description>
```

If `--bead` is set, also show:
```
**Working bead:** <bead-id> — <bead title>
```
And run `bd swarm status <bead-id>` to show the current ready front.

```
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

3. **Produce output** under a section header:
   ```
   ---
   ## <Role>: <Name> (<Alignment> <Class>)
   ```
   Use role if set, otherwise omit the prefix.
   Examples: `## Defender: Vera (LG Rogue)`, `## Kai (CG Fighter)`

5. Address the quest task from this member's perspective. Be thorough.

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

- **Council mode** processes sequentially — later members can react to earlier output. Good for debates.
- **Expedition mode** spawns parallel subagents — truly independent perspectives. Good for unbiased comparison.
- **Party size:** 2-4 members is the sweet spot. 5-6 works but produces long output.
- **`--bead` mode** is for working through existing tracked work. The party executes, not just analyzes.
- **`--create` mode** turns analysis into tracked beads. Good when a quest surfaces work that should be persistent.
- **Default mode** (no flags) is the original one-shot analysis. Still useful for quick perspectives without beads overhead.
