---
name: alignment-mode
description: "Switch AAF operating mode. Usage: /alignment-mode fixed <alignment> | /alignment-mode arbiter [profile] | /alignment-mode (show current)"
argument-hint: "[fixed <alignment> | arbiter [profile]]"
---

# Switch AAF Mode

Switch between fixed and arbiter operating modes, or show current status.

## Parse Arguments

- No arguments → show current mode and alignment
- `fixed <alignment>` → switch to fixed mode with specified alignment
- `arbiter [profile]` → switch to arbiter mode with optional profile (default: controlled_chaos)

## Commands

### Show Current Mode (no arguments)

1. Read the state file:
   ```bash
   cat "$CLAUDE_PROJECT_DIR/.aaf-state.json" 2>/dev/null || echo "No AAF state file found"
   ```

2. Report: current mode, alignment, profile, and whether it matches `settings.json`.

### Switch to Fixed Mode: `fixed <alignment>`

Valid alignments: `lawful-good`, `neutral-good`, `chaotic-good`, `lawful-neutral`, `true-neutral`, `chaotic-neutral`, `lawful-evil`, `neutral-evil`, `chaotic-evil`

1. Validate the alignment name is one of the 9 valid alignments.

2. Update the runtime state:
   ```bash
   echo '{"mode":"fixed","alignment":"<ALIGNMENT>","profile":"controlled_chaos","archetype":"<ARCHETYPE>","timestamp":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' > "$CLAUDE_PROJECT_DIR/.aaf-state.json"
   ```

3. Update `settings.json` for persistence across sessions:
   ```bash
   jq '.aaf.mode = "fixed" | .aaf.alignment = "<ALIGNMENT>"' "$CLAUDE_PROJECT_DIR/.claude/settings.json" > /tmp/aaf-settings.json && mv /tmp/aaf-settings.json "$CLAUDE_PROJECT_DIR/.claude/settings.json"
   ```

4. Invoke the alignment skill to load the behavioral profile:
   ```
   /<alignment>
   ```

5. Announce: "Switched to **fixed mode** with **[Alignment] — [Archetype]**. This alignment persists for the remainder of this session and future sessions."

### Switch to Arbiter Mode: `arbiter [profile]`

Valid profiles: `controlled_chaos` (default), `conservative`, `heroic`, `wild_magic`, `adversarial`

1. Update `settings.json` for persistence:
   ```bash
   jq '.aaf.mode = "arbiter" | .aaf.profile = "<PROFILE>"' "$CLAUDE_PROJECT_DIR/.claude/settings.json" > /tmp/aaf-settings.json && mv /tmp/aaf-settings.json "$CLAUDE_PROJECT_DIR/.claude/settings.json"
   ```

2. Roll an initial alignment:
   ```bash
   "$CLAUDE_PROJECT_DIR"/hooks/scripts/roll.sh <PROFILE>
   ```

3. Invoke the rolled alignment skill to load the behavioral profile.

4. Announce: "Switched to **arbiter mode** with profile **[profile]**. Will roll a new alignment before each task. Initial roll: **[Alignment] — [Archetype]**."

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
