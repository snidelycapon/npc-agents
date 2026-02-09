---
name: class-mode
description: "Switch NPC class mode. Usage: /class-mode <class|profile|off>"
argument-hint: "<class | profile | off>"
---

# Switch NPC Class Mode

Set the NPC class mode, or show the current class mode if no argument given.

The class mode is always one of:
- A **class name** (fixed mode): `fighter`, `wizard`, `rogue`, `cleric`, `bard`, `ranger`
- A **class profile** (roll each task): `uniform`, `task_weighted`, `specialist`
- **`off`** — disable class system (alignment-only mode)

## Parse Arguments

- No arguments → show current class mode
- A class name → switch to that fixed class
- A profile name → switch to that rolling profile
- `off` → disable class system

## Commands

### Show Current Class Mode (no arguments)

1. Read the state file:
   ```bash
   cat "$CLAUDE_PROJECT_DIR/.npc-state.json" 2>/dev/null || echo "No NPC state file found"
   ```

2. Report: current class mode, class, and title.

### Switch to a Fixed Class: `<class>`

Valid classes: `fighter`, `wizard`, `rogue`, `cleric`, `bard`, `ranger`

1. Validate the class name.

2. Update `settings.json`:
   ```bash
   jq '.npc.class = "<CLASS>"' "$CLAUDE_PROJECT_DIR/.claude/settings.json" > /tmp/npc-settings.json && mv /tmp/npc-settings.json "$CLAUDE_PROJECT_DIR/.claude/settings.json"
   ```

3. Update the runtime state:
   ```bash
   jq --arg class "<CLASS>" --arg title "<TITLE>" --arg classMode "<CLASS>" '.class = $class | .title = $title | .classMode = $classMode | .character = (.archetype + " " + $title)' "$CLAUDE_PROJECT_DIR/.npc-state.json" > /tmp/npc-state.json && mv /tmp/npc-state.json "$CLAUDE_PROJECT_DIR/.npc-state.json"
   ```

4. Invoke the class skill to load the domain profile:
   ```
   /class-<class>
   ```

5. Announce: "Switched to **<Class> — <Title>**. This class persists for the session and future sessions."

### Switch to a Rolling Class Profile: `<profile>`

Valid profiles: `uniform`, `task_weighted`, `specialist`

1. Update `settings.json`:
   ```bash
   jq '.npc.class = "<PROFILE>"' "$CLAUDE_PROJECT_DIR/.claude/settings.json" > /tmp/npc-settings.json && mv /tmp/npc-settings.json "$CLAUDE_PROJECT_DIR/.claude/settings.json"
   ```

2. Roll an initial class:
   ```bash
   "$CLAUDE_PROJECT_DIR"/hooks/scripts/roll-class.sh <PROFILE>
   ```

3. Invoke the rolled class skill to load the domain profile.

4. Announce: "Switched to **<profile>** class profile. Will roll a new class before each task. Initial roll: **<Class> — <Title>**."

### Disable Class System: `off`

1. Update `settings.json`:
   ```bash
   jq '.npc.class = "off"' "$CLAUDE_PROJECT_DIR/.claude/settings.json" > /tmp/npc-settings.json && mv /tmp/npc-settings.json "$CLAUDE_PROJECT_DIR/.claude/settings.json"
   ```

2. Clear class from runtime state:
   ```bash
   jq 'del(.class, .title, .character, .classMode)' "$CLAUDE_PROJECT_DIR/.npc-state.json" > /tmp/npc-state.json && mv /tmp/npc-state.json "$CLAUDE_PROJECT_DIR/.npc-state.json"
   ```

3. Announce: "Class system disabled. Operating with alignment only."

## Class Reference

| Class | Title |
|---|---|
| fighter | The Champion |
| wizard | The Arcanist |
| rogue | The Shadow |
| cleric | The Warden |
| bard | The Herald |
| ranger | The Tracker |

## Class Profile Reference

| Profile | Distribution |
|---|---|
| uniform | Equal probability across all 6 classes |
| task_weighted | Weighted by task type (requires `--task-type`) |
| specialist | Heavily favors the primary class for each task type |
