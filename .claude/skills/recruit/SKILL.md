---
name: recruit
description: "Add a character to a party. Usage: /recruit <name|alignment> [class] [--persona text] [--role label] [--party name]"
argument-hint: "<name|alignment> [class] [--persona text] [--role label] [--party name]"
---

# Recruit Party Member

> **Context:** The `skill-context` hook injects NPC state when this skill is invoked. Use the `Project dir` value as `$PROJECT_DIR` in bash commands below. The active party name is available directly from hook context.

Add a character to a party. If the character already exists as a bead, links it. Otherwise creates a new character bead and links it.

## Arguments

`$ARGUMENTS`

## Parse Arguments

Extract from the argument string:

- **identifier** (required): First positional argument. Either:
  - A character name (resolves to existing bead)
  - An alignment name (creates a new anonymous or named character)
- **class** (optional): Second positional argument, if it matches a valid class name.
- **--name "label"**: Name for a new character (only when identifier is an alignment). If omitted and identifier is an alignment, creates an unnamed character bead.
- **--persona "text"**: 1-3 sentence persona. Sets the character bead's description.
- **--role "label"**: Role label for this character (e.g., "defender", "attacker").
- **--party name**: Target party. If omitted, uses the active party.

## Valid Names

**Alignments:** `lawful-good`, `neutral-good`, `chaotic-good`, `lawful-neutral`, `true-neutral`, `chaotic-neutral`, `lawful-evil`, `neutral-evil`, `chaotic-evil`

**Classes:** `fighter`, `wizard`, `rogue`, `cleric`, `bard`, `ranger`

## Steps

1. **Resolve target party.**
   If `--party` provided, resolve via `resolve-party.sh`. Otherwise use active party from hook context and resolve.
   If no active party, error: "No active party. Use `/party active <name>` or specify `--party <name>`."

2. **Resolve or create the character.**

   **If identifier is an existing character name** (not an alignment):
   ```bash
   CHAR_ID=$("$PROJECT_DIR"/hooks/scripts/resolve-character.sh "<identifier>")
   ```
   If found, use this existing character bead. Skip creation.
   If not found AND identifier is not an alignment, error: "Character '<identifier>' not found. Use `/npc create` first or provide an alignment."

   **If identifier is an alignment name:**
   Build the character bead. Use `--name` as the title if provided, otherwise use the alignment as the title.
   ```bash
   LABELS="npc:character,alignment:<alignment>"
   ```
   Add `class:<class>` if class provided. Add `role:<role>` if provided.
   ```bash
   CHAR_ID=$(bd create "<name-or-alignment>" -t task -l "$LABELS" -d "<persona or empty>" --silent)
   ```

3. **Link character to party** via parent-child dependency:
   ```bash
   bd dep add "$CHAR_ID" "$PARTY_ID" --type parent-child
   ```

4. **If role was provided**, add it as a label on the character bead if not already present:
   ```bash
   bd label add "$CHAR_ID" "role:<role>"
   ```

5. **Safety warning.** If the alignment is Evil, note:
   - "This character has an Evil alignment. Evil members require operator confirmation when a quest is dispatched."
   - If Chaotic Evil: "Chaotic Evil members require the phrase 'unleash the gremlin' to participate in quests."

6. **Announce:**
   ```
   Recruited **<name>** to **<party-name>**.
   Role: <role or "unassigned">
   Party now has <N> members.
   ```

7. **Show updated roster** (use `bd children "$PARTY_ID" --json`).
