---
name: roll
description: "Roll a random alignment and class. Use for behavioral variation and chaos engineering."
argument-hint: "[alignment-profile] [class-profile]"
---

# Roll Random Character

Roll a random alignment and class using probability profiles.

## Arguments

- No arguments → roll both using current profiles from `settings.json`
- One argument → alignment profile override (class uses current profile)
- Two arguments → alignment profile + class profile override

## Steps

1. Read current profile settings:
   ```bash
   jq -r '.npc.mode // "controlled_chaos"' "$CLAUDE_PROJECT_DIR/.claude/settings.json"
   jq -r '.npc.class // "uniform"' "$CLAUDE_PROJECT_DIR/.claude/settings.json"
   ```

   Use arguments to override if provided. Default alignment profile: `controlled_chaos`. Default class profile: `uniform`.

2. Roll alignment:
   ```bash
   "$CLAUDE_PROJECT_DIR"/hooks/scripts/roll.sh <alignment-profile>
   ```

   The script returns JSON:
   ```json
   {"roll": 42, "profile": "controlled_chaos", "alignment": "neutral-good"}
   ```
   It also updates `.npc-state.json` and logs to `.npc-ledger.jsonl`.

3. Roll class:
   ```bash
   "$CLAUDE_PROJECT_DIR"/hooks/scripts/roll-class.sh <class-profile>
   ```

   The script returns JSON:
   ```json
   {"roll": 72, "profile": "uniform", "class": "ranger"}
   ```

4. Invoke the rolled alignment skill:
   ```
   /<alignment-name>
   ```
   For example, if the roll returned `neutral-good`, invoke `/neutral-good`.

5. Invoke the rolled class skill:
   ```
   /<class-name>
   ```
   For example, if the roll returned `ranger`, invoke `/ranger`.

6. Announce the full roll:
   - Both d100 roll results
   - Alignment name
   - Class name
   - What perspective this combination brings
   - How your approach will change

## Available Alignment Profiles

- **controlled_chaos** (default): 55% Good, 33% Neutral, 7% Evil, 5% Operator's Choice
- **conservative**: Production-safe, no Evil alignments
- **heroic**: Good-only with high Law/Chaos variance
- **wild_magic**: Near-uniform distribution, anything goes
- **adversarial**: Evil-heavy for sandboxed stress testing

## Available Class Profiles

- **uniform** (default): Equal probability across all 6 classes
- **task_weighted**: Weighted by task type affinity
- **specialist**: Heavily favors the primary class for each task type

## Important

- The roll uses bash RANDOM for genuine randomness
- Evil alignments require operator confirmation before proceeding
- Chaotic Evil requires the "unleash the gremlin" phrase
- All rolls are logged to `.npc-ledger.jsonl`
- Commit fully to whatever alignment and class is rolled
