---
name: npc
description: "NPC Agents — assume characters, create characters, set anonymous alignment, or disable. Usage: /npc [name|create|list|show|delete|set|alignment|off]"
argument-hint: "[name|create|list|show|delete|set|alignment|off] [...]"
---

# NPC Agents

> **Context:** The `skill-context` hook injects NPC state when this skill is invoked. Use the `Project dir` value as `$PROJECT_DIR` in bash commands below. Session bead ID, active character, alignment, and class are available from hook context.

Manage NPC characters and session state. Characters are beads with alignment, class, persona, and role.

## Disambiguation

Parse the first argument. First match wins:

1. **No arguments** → show current state
2. **`off`** → disable NPC Agents
3. **`create`** → create a new character
4. **`list`** → list all characters
5. **`show`** → show a character's sheet
6. **`delete`** → delete a character
7. **`set`** → set anonymous alignment/class (no named character)
8. **Known alignment name** → shorthand for `/npc set <alignment>`
9. **Known class name** → set class only (update session bead + settings.json)
10. **Anything else** → treat as a character name, resolve and assume

### Known Names

- **Alignments:** `lawful-good`, `neutral-good`, `chaotic-good`, `lawful-neutral`, `true-neutral`, `chaotic-neutral`, `lawful-evil`, `neutral-evil`, `chaotic-evil`
- **Classes:** `fighter`, `wizard`, `rogue`, `cleric`, `bard`, `ranger`

---

## Commands

### Show Current State (no arguments)

Read state from the **skill-context hook output**. Report:
- Active character name (or "anonymous")
- Alignment + class
- Persona (if character active)
- Active party (if any)
- Session bead ID

### Assume Character: `/npc <name>`

1. Resolve character:
   ```bash
   CHAR_ID=$("$PROJECT_DIR"/hooks/scripts/resolve-character.sh "<name>")
   ```

2. If not found, report error and suggest `/npc create`.

3. Load character bead:
   ```bash
   bd show "$CHAR_ID" --json
   ```

4. Extract from labels: `alignment:<value>`, `class:<value>`, `role:<value>`.

5. Update session bead state:
   ```bash
   SESSION_ID=$("$PROJECT_DIR"/hooks/scripts/ensure-session.sh)
   bd set-state "$SESSION_ID" alignment=<alignment> --reason "Assuming character <name>"
   bd set-state "$SESSION_ID" active-class=<class> --reason "Assuming character <name>"
   bd set-state "$SESSION_ID" active-character="$CHAR_ID" --reason "Assuming character <name>"
   bd set-state "$SESSION_ID" mode=<name> --reason "Assuming character <name>"
   ```

6. Update `settings.json` so the next session starts with this character:
   ```bash
   jq '.npc.mode = "<name>" | .npc.class = "<class>"' "$PROJECT_DIR/.claude/settings.json" > /tmp/npc-settings.json && mv /tmp/npc-settings.json "$PROJECT_DIR/.claude/settings.json"
   ```

7. Invoke the alignment and class skills to load behavioral profiles:
   ```
   /<alignment>
   /<class>
   ```

8. Announce: character name, alignment, class, persona, role.

### Create Character: `/npc create <name> <alignment> [class] [--persona "..."] [--role <role>]`

1. Validate alignment name. Class is optional.

2. Build labels: `npc:character,alignment:<alignment>`. Add `class:<class>` and `role:<role>` if provided.

3. Create bead:
   ```bash
   bd create "<name>" -t task -l "npc:character,alignment:<alignment>,class:<class>,role:<role>" -d "<persona>"
   ```
   If no persona provided, use empty description.

4. Announce: character created with alignment, class, persona. Suggest `/npc <name>` to assume.

### List Characters: `/npc list`

```bash
bd list --label npc:character -t task --json
```

Display as a table: name, alignment, class, role.

### Show Character: `/npc show <name>`

1. Resolve character via `resolve-character.sh`.
2. `bd show "$CHAR_ID" --json` to get full details.
3. Display character sheet with: name, alignment, class, persona, role, party memberships.
4. For party memberships, check which parties this character is a child of (this may require listing parties and checking children).

### Delete Character: `/npc delete <name>`

1. Resolve character via `resolve-character.sh`.
2. **Ask for confirmation** before proceeding.
3. Delete:
   ```bash
   bd delete "$CHAR_ID"
   ```
4. If this was the active character on the session bead, reset to anonymous.

### Set Anonymous Mode: `/npc set <alignment> [class]`

Set alignment (and optionally class) without a named character.

1. Validate alignment name. Validate class name if provided.

2. Update session bead:
   ```bash
   SESSION_ID=$("$PROJECT_DIR"/hooks/scripts/ensure-session.sh)
   bd set-state "$SESSION_ID" alignment=<alignment> --reason "Anonymous mode"
   bd set-state "$SESSION_ID" active-character=anonymous --reason "Anonymous mode"
   bd set-state "$SESSION_ID" mode=<alignment> --reason "Anonymous mode"
   ```
   If class provided:
   ```bash
   bd set-state "$SESSION_ID" active-class=<class> --reason "Anonymous mode"
   ```

3. Update `settings.json`:
   ```bash
   jq '.npc.mode = "<alignment>" | .npc.class = "<class-or-off>"' "$PROJECT_DIR/.claude/settings.json" > /tmp/npc-settings.json && mv /tmp/npc-settings.json "$PROJECT_DIR/.claude/settings.json"
   ```

4. Invoke alignment (and class) skills to load profiles.

5. Announce: "Operating as anonymous **<Alignment>** [**<Class>**]."

### Disable: `/npc off`

1. Update `settings.json`:
   ```bash
   jq '.npc.mode = "off" | .npc.class = "off"' "$PROJECT_DIR/.claude/settings.json" > /tmp/npc-settings.json && mv /tmp/npc-settings.json "$PROJECT_DIR/.claude/settings.json"
   ```

2. Update session bead:
   ```bash
   SESSION_ID=$("$PROJECT_DIR"/hooks/scripts/ensure-session.sh)
   bd set-state "$SESSION_ID" mode=off --reason "NPC disabled"
   bd set-state "$SESSION_ID" active-character=anonymous --reason "NPC disabled"
   ```

3. Announce: "NPC Agents disabled. Operating normally."

---

## Reference

### Alignments

`lawful-good`, `neutral-good`, `chaotic-good`, `lawful-neutral`, `true-neutral`, `chaotic-neutral`, `lawful-evil`, `neutral-evil`, `chaotic-evil`

### Classes

`fighter`, `wizard`, `rogue`, `cleric`, `bard`, `ranger`
