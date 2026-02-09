---
name: roll
description: "Roll a random alignment using a probability profile. Use for behavioral variation and chaos engineering."
argument-hint: "[profile]"
---

# Roll Random Alignment

Roll a random alignment using the **${1:-controlled_chaos}** profile.

## Steps

1. Execute the roll:
   ```bash
   "$CLAUDE_PROJECT_DIR"/hooks/scripts/roll.sh ${1:-controlled_chaos}
   ```

2. The script returns JSON with the roll result:
   ```json
   {"roll": 42, "profile": "controlled_chaos", "alignment": "neutral-good", "archetype": "The Mentor"}
   ```
   It also updates `.npc-state.json` and logs to `.npc-ledger.jsonl`.

3. Invoke the rolled alignment skill to load the behavioral profile:
   ```
   /<alignment-name>
   ```
   For example, if the roll returned `neutral-good`, invoke `/neutral-good`.

4. **If class mode is a rolling profile** (not "off" and not a fixed class name), also roll for class:
   ```bash
   "$CLAUDE_PROJECT_DIR"/hooks/scripts/roll-class.sh <class-profile>
   ```
   Then invoke the rolled class skill: `/class-<name>`

5. Announce your rolled alignment (and class if rolled) with:
   - The d100 roll result(s)
   - Alignment name and archetype
   - Class name and title (if rolled)
   - Character name (archetype + title)
   - What perspective this combination brings
   - How your approach will change

## Available Alignment Profiles

- **controlled_chaos** (default): 55% Good, 33% Neutral, 7% Evil, 5% Operator's Choice
- **conservative**: Production-safe, no Evil alignments
- **heroic**: Good-only with high Law/Chaos variance
- **wild_magic**: Near-uniform distribution, anything goes
- **adversarial**: Evil-heavy for sandboxed stress testing

## Important

- The roll uses bash RANDOM for genuine randomness
- Evil alignments require operator confirmation before proceeding
- Chaotic Evil requires the "unleash the gremlin" phrase
- All rolls are logged to `.npc-ledger.jsonl`
- Commit fully to whatever alignment (and class) is rolled
