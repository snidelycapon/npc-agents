---
name: recruit
description: "Add a member to a party. Usage: /recruit <alignment> [class] [--name label] [--persona text] [--role label] [--party name]"
argument-hint: "<alignment> [class] [--name label] [--persona text] [--role label] [--party name]"
---

# Recruit Party Member

Add a new member to an adventuring party.

## Arguments

`$ARGUMENTS`

## Parse Arguments

Extract from the argument string:

- **alignment** (required): First positional argument. Must be one of the 9 valid alignments.
- **class** (optional): Second positional argument, if it matches a valid class name.
- **--name "label"**: Optional custom name for this member (e.g., "Vera", "Old Jin"). If omitted, defaults to `null`.
- **--persona "text"**: Optional 1-3 sentence persona describing expertise, background, or point of view. Flavors how the alignment+class behavioral profile manifests. If omitted, defaults to `null`.
- **--role "label"**: Optional role label for this member (used as section header in quest output).
- **--party name**: Target party. If omitted, uses the active party from `.npc-state.json`.

## Valid Names

**Alignments:** `lawful-good`, `neutral-good`, `chaotic-good`, `lawful-neutral`, `true-neutral`, `chaotic-neutral`, `lawful-evil`, `neutral-evil`, `chaotic-evil`

**Classes:** `fighter`, `wizard`, `rogue`, `cleric`, `bard`, `ranger`

## Steps

1. **Resolve target party.**
   If `--party` provided, use that name. Otherwise:
   ```bash
   jq -r '.activeParty // empty' "$CLAUDE_PROJECT_DIR/.npc-state.json" 2>/dev/null
   ```
   If no active party, error: "No active party. Use `/party active <name>` or specify `--party <name>`."

2. **Verify the party file exists:**
   ```bash
   test -f "$CLAUDE_PROJECT_DIR/.claude/parties/<party-name>.json"
   ```

3. **Validate alignment.** Must be one of the 9 valid alignment names. Error if not.

4. **Validate class** (if provided). Must be one of the 6 valid class names. Error if not.

5. **Check member count.** Read the party file and check `members | length`. If already 6 members, warn that this is the maximum recommended size (but allow override).

6. **Build the member object:**
   ```json
   {
     "alignment": "<alignment>",
     "class": "<class or null>",
     "name": "<name or null>",
     "persona": "<persona or null>",
     "role": "<role label or null>"
   }
   ```

7. **Append to the party file:**
   ```bash
   jq --argjson member '<member JSON>' '.members += [$member]' "$CLAUDE_PROJECT_DIR/.claude/parties/<party-name>.json" > /tmp/npc-party.json && mv /tmp/npc-party.json "$CLAUDE_PROJECT_DIR/.claude/parties/<party-name>.json"
   ```

8. **Safety warning.** If the alignment is Evil, note:
   - "This member has an Evil alignment. Evil members require operator confirmation when a quest is dispatched."
   - If Chaotic Evil: "Chaotic Evil members require the phrase 'unleash the gremlin' to participate in quests."

9. **Announce:**
   ```
   Recruited **<name or alignment+class>** to **<party-name>**.
   Role: <role or "unassigned">
   Party now has <N> members.
   ```

   Display format for the member: use `name` if set, otherwise `<alignment> <class>` (e.g., "LG Rogue" or "Vera").

10. **Show updated roster** as a table.
