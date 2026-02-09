---
name: alignment-mode
description: "Switch NPC operating mode. Usage: /alignment-mode <alignment|profile|off>"
argument-hint: "<alignment | profile | off>"
---

# Switch NPC Mode

Set the NPC mode, or show the current mode if no argument given.

The mode is always one of:
- An **alignment name** (fixed mode): `lawful-good`, `neutral-good`, `chaotic-good`, `lawful-neutral`, `true-neutral`, `chaotic-neutral`, `lawful-evil`, `neutral-evil`, `chaotic-evil`
- A **probability profile** (roll each task): `controlled_chaos`, `conservative`, `heroic`, `wild_magic`, `adversarial`
- **`off`** — disable NPC Agents entirely

## Parse Arguments

- No arguments → show current mode
- An alignment name → switch to that fixed alignment
- A profile name → switch to that rolling profile
- `off` → disable NPC Agents

## Commands

### Show Current Mode (no arguments)

1. Read the state file:
   ```bash
   cat "$CLAUDE_PROJECT_DIR/.npc-state.json" 2>/dev/null || echo "No NPC state file found"
   ```

2. Report: current mode, alignment, and archetype.

### Switch to a Fixed Alignment: `<alignment>`

Valid alignments: `lawful-good`, `neutral-good`, `chaotic-good`, `lawful-neutral`, `true-neutral`, `chaotic-neutral`, `lawful-evil`, `neutral-evil`, `chaotic-evil`

1. Validate the alignment name.

2. Update `settings.json`:
   ```bash
   jq '.npc.mode = "<ALIGNMENT>"' "$CLAUDE_PROJECT_DIR/.claude/settings.json" > /tmp/npc-settings.json && mv /tmp/npc-settings.json "$CLAUDE_PROJECT_DIR/.claude/settings.json"
   ```

3. Write the runtime state:
   ```bash
   echo '{"mode":"<ALIGNMENT>","archetype":"<ARCHETYPE>","timestamp":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' > "$CLAUDE_PROJECT_DIR/.npc-state.json"
   ```

4. Invoke the alignment skill to load the behavioral profile:
   ```
   /<alignment>
   ```

5. Announce: "Switched to **<Alignment> — <Archetype>**. This alignment persists for the session and future sessions."

### Switch to a Rolling Profile: `<profile>`

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

4. Announce: "Switched to **<profile>** profile. Will roll a new alignment before each task. Initial roll: **<Alignment> — <Archetype>**."

### Disable NPC Agents: `off`

1. Update `settings.json`:
   ```bash
   jq '.npc.mode = "off"' "$CLAUDE_PROJECT_DIR/.claude/settings.json" > /tmp/npc-settings.json && mv /tmp/npc-settings.json "$CLAUDE_PROJECT_DIR/.claude/settings.json"
   ```

2. Clear the runtime state:
   ```bash
   echo '{"mode":"off","timestamp":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' > "$CLAUDE_PROJECT_DIR/.npc-state.json"
   ```

3. Announce: "NPC Agents disabled. Operating normally."

## Archetype Reference

| Alignment | Archetype |
|---|---|
| lawful-good | The Paladin |
| neutral-good | The Mentor |
| chaotic-good | The Maverick |
| lawful-neutral | The Bureaucrat |
| true-neutral | The Mercenary |
| chaotic-neutral | The Wildcard |
| lawful-evil | The Architect |
| neutral-evil | The Opportunist |
| chaotic-evil | The Gremlin |

## Profile Reference

| Profile | Distribution |
|---|---|
| controlled_chaos | 55% Good, 33% Neutral, 7% Evil, 5% Operator's Choice |
| conservative | No Evil alignments |
| heroic | Good-only with Law/Chaos variance |
| wild_magic | Near-uniform, anything goes |
| adversarial | Evil-heavy, sandboxed stress testing only |
