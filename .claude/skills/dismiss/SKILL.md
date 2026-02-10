---
name: dismiss
description: "Remove a character from a party. Usage: /dismiss <name|index|role> [--party name]"
argument-hint: "<name|index|role> [--party name]"
---

# Dismiss Party Member

> **Context:** The `skill-context` hook injects NPC state when this skill is invoked. Use the `Project dir` value as `$PROJECT_DIR` in bash commands below. The active party name is available directly from hook context.

Remove a character's membership from a party. The character bead itself survives — only the party link is removed.

## Arguments

`$ARGUMENTS`

## Parse Arguments

- **identifier** (required): One of:
  - A 1-based index number (position in roster)
  - A character name (matched against child bead titles)
  - A role label (matched against `role:*` labels on child beads)
- **--party name**: Target party. If omitted, uses the active party.

## Steps

1. **Resolve target party.**
   If `--party` provided, resolve via `resolve-party.sh`. Otherwise use active party from hook context and resolve.
   If no active party, error: "No active party. Use `/party active <name>` or specify `--party <name>`."

2. **Get party members:**
   ```bash
   bd children "$PARTY_ID" --json
   ```

3. **Resolve the member:**
   - If identifier is a number (1-N), use it as a 1-based index into the children array.
   - If identifier is a string, match case-insensitively against:
     1. Child bead titles (character names)
     2. `role:*` labels on child beads
   - If no match found, error: "No member matching '<identifier>' in party."

4. **Show the member** to be dismissed:
   ```
   Dismissing **<character name>** from **<party-name>**.
   ```

5. **Confirm with the user** before removing.

6. **Remove the parent-child dependency** (character stays, link removed):
   ```bash
   bd dep remove "$CHAR_ID" "$PARTY_ID"
   ```

7. **Announce:**
   ```
   Dismissed **<character name>** from **<party-name>**.
   The character bead is preserved — they can be recruited to another party.
   Party now has <N> members.
   ```

8. **Show updated roster.** If the party is now empty, note: "Party is empty. Use `/recruit` to add members."
