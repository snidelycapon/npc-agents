---
name: npc
description: "Configure NPC Agents — set alignment, class, profiles, or disable. Usage: /npc [alignment|profile] [class|class-profile|off]"
argument-hint: "[alignment|profile|off] [class|class-profile]"
---

# Configure NPC Agents

Set alignment mode, class mode, or both. Show current state if no arguments given.

## Argument Sets

All names belong to distinct, non-overlapping sets:

- **Alignments:** `lawful-good`, `neutral-good`, `chaotic-good`, `lawful-neutral`, `true-neutral`, `chaotic-neutral`, `lawful-evil`, `neutral-evil`, `chaotic-evil`
- **Alignment profiles:** `controlled_chaos`, `conservative`, `heroic`, `wild_magic`, `adversarial`
- **Classes:** `fighter`, `wizard`, `rogue`, `cleric`, `bard`, `ranger`
- **Class profiles:** `uniform`, `task_weighted`, `specialist`
- **Special:** `off`

## Parse Arguments

- No arguments → show current state
- One argument:
  - An alignment name → set fixed alignment
  - An alignment profile → set rolling alignment profile
  - A class name → set fixed class (alignment unchanged)
  - A class profile → set rolling class profile (alignment unchanged)
  - `off` → disable NPC Agents entirely (both alignment and class)
- Two arguments:
  - First is alignment/profile, second is class/class-profile → set both
  - Any combination of the above sets

## Commands

### Show Current State (no arguments)

1. Read the state file:
   ```bash
   cat "$CLAUDE_PROJECT_DIR/.npc-state.json" 2>/dev/null || echo "No NPC state file found"
   ```

2. Read settings:
   ```bash
   jq '.npc' "$CLAUDE_PROJECT_DIR/.claude/settings.json" 2>/dev/null
   ```

3. Report: current alignment mode, alignment, class mode, and class.

### Set Alignment: `<alignment>`

Valid alignments: `lawful-good`, `neutral-good`, `chaotic-good`, `lawful-neutral`, `true-neutral`, `chaotic-neutral`, `lawful-evil`, `neutral-evil`, `chaotic-evil`

1. Validate the alignment name.

2. Update `settings.json`:
   ```bash
   jq '.npc.mode = "<ALIGNMENT>"' "$CLAUDE_PROJECT_DIR/.claude/settings.json" > /tmp/npc-settings.json && mv /tmp/npc-settings.json "$CLAUDE_PROJECT_DIR/.claude/settings.json"
   ```

3. Write the runtime state:
   ```bash
   echo '{"mode":"<ALIGNMENT>","timestamp":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' > "$CLAUDE_PROJECT_DIR/.npc-state.json"
   ```

4. Invoke the alignment skill to load the behavioral profile:
   ```
   /<alignment>
   ```

5. Announce: "Switched to **<Alignment>**."

### Set Class: `<class>`

Valid classes: `fighter`, `wizard`, `rogue`, `cleric`, `bard`, `ranger`

1. Validate the class name.

2. Update `settings.json`:
   ```bash
   jq '.npc.class = "<CLASS>"' "$CLAUDE_PROJECT_DIR/.claude/settings.json" > /tmp/npc-settings.json && mv /tmp/npc-settings.json "$CLAUDE_PROJECT_DIR/.claude/settings.json"
   ```

3. Update the runtime state:
   ```bash
   jq --arg class "<CLASS>" --arg classMode "<CLASS>" '.class = $class | .classMode = $classMode' "$CLAUDE_PROJECT_DIR/.npc-state.json" > /tmp/npc-state.json && mv /tmp/npc-state.json "$CLAUDE_PROJECT_DIR/.npc-state.json"
   ```

4. Invoke the class skill to load the domain profile:
   ```
   /<class>
   ```

5. Announce: "Switched to **<Class>**."

### Set Both: `<alignment> <class>`

1. Follow the alignment steps above.
2. Follow the class steps above.
3. Announce both changes together.

### Set Rolling Alignment Profile: `<profile>`

Valid profiles: `controlled_chaos`, `conservative`, `heroic`, `wild_magic`, `adversarial`

1. Update `settings.json`:
   ```bash
   jq '.npc.mode = "<PROFILE>"' "$CLAUDE_PROJECT_DIR/.claude/settings.json" > /tmp/npc-settings.json && mv /tmp/npc-settings.json "$CLAUDE_PROJECT_DIR/.claude/settings.json"
   ```

2. Roll an initial alignment:
   ```bash
   "$CLAUDE_PROJECT_DIR"/hooks/scripts/roll.sh <PROFILE>
   ```

3. Invoke the rolled alignment skill to load the behavioral profile.

4. Announce: "Switched to **<profile>** profile. Will roll a new alignment before each task. Initial roll: **<Alignment>**."

### Set Rolling Class Profile: `<class-profile>`

Valid class profiles: `uniform`, `task_weighted`, `specialist`

1. Update `settings.json`:
   ```bash
   jq '.npc.class = "<CLASS_PROFILE>"' "$CLAUDE_PROJECT_DIR/.claude/settings.json" > /tmp/npc-settings.json && mv /tmp/npc-settings.json "$CLAUDE_PROJECT_DIR/.claude/settings.json"
   ```

2. Roll an initial class:
   ```bash
   "$CLAUDE_PROJECT_DIR"/hooks/scripts/roll-class.sh <CLASS_PROFILE>
   ```

3. Invoke the rolled class skill to load the domain profile.

4. Announce: "Switched to **<class-profile>** class profile. Will roll a new class before each task. Initial roll: **<Class>**."

### Disable: `off`

1. Update `settings.json`:
   ```bash
   jq '.npc.mode = "off" | .npc.class = "off"' "$CLAUDE_PROJECT_DIR/.claude/settings.json" > /tmp/npc-settings.json && mv /tmp/npc-settings.json "$CLAUDE_PROJECT_DIR/.claude/settings.json"
   ```

2. Clear the runtime state:
   ```bash
   echo '{"mode":"off","timestamp":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' > "$CLAUDE_PROJECT_DIR/.npc-state.json"
   ```

3. Announce: "NPC Agents disabled. Operating normally."

## Reference

### Alignments

`lawful-good`, `neutral-good`, `chaotic-good`, `lawful-neutral`, `true-neutral`, `chaotic-neutral`, `lawful-evil`, `neutral-evil`, `chaotic-evil`

### Alignment Profiles

| Profile | Distribution |
|---|---|
| controlled_chaos | 55% Good, 33% Neutral, 7% Evil, 5% Operator's Choice |
| conservative | No Evil alignments |
| heroic | Good-only with Law/Chaos variance |
| wild_magic | Near-uniform, anything goes |
| adversarial | Evil-heavy, sandboxed stress testing only |

### Classes

`fighter`, `wizard`, `rogue`, `cleric`, `bard`, `ranger`

### Class Profiles

| Profile | Distribution |
|---|---|
| uniform | Equal probability across all 6 classes |
| task_weighted | Weighted by task type (requires `--task-type`) |
| specialist | Heavily favors the primary class for each task type |
