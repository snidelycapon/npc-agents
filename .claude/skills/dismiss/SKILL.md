---
name: dismiss
description: "Remove a member from a party. Usage: /dismiss <index|role> [--party name]"
argument-hint: "<index|role> [--party name]"
---

# Dismiss Party Member

Remove a member from an adventuring party.

## Arguments

`$ARGUMENTS`

## Parse Arguments

- **identifier** (required): Either a 1-based index number or a role name (case-insensitive match on the `role` field).
- **--party name**: Target party. If omitted, uses the active party from `.npc-state.json`.

## Steps

1. **Resolve target party.**
   If `--party` provided, use that name. Otherwise:
   ```bash
   jq -r '.activeParty // empty' "$CLAUDE_PROJECT_DIR/.npc-state.json" 2>/dev/null
   ```
   If no active party, error: "No active party. Use `/party active <name>` or specify `--party <name>`."

2. **Read the party file:**
   ```bash
   cat "$CLAUDE_PROJECT_DIR/.claude/parties/<party-name>.json"
   ```

3. **Resolve the member:**
   - If the identifier is a number (1-6), use it as a 1-based index into the members array.
   - If the identifier is a string, match it case-insensitively against each member's `role` field.
   - If no match found, error: "No member at index <N>" or "No member with role '<role>'."

4. **Show the member** to be dismissed (use `name` if set, otherwise `<alignment> <class>`):
   ```
   Dismissing **<name or alignment+class>** from **<party-name>**.
   ```

5. **Confirm with the user** before removing.

6. **Remove the member** (convert to 0-based index for jq):
   ```bash
   jq 'del(.members[<0-based-index>])' "$CLAUDE_PROJECT_DIR/.claude/parties/<party-name>.json" > /tmp/npc-party.json && mv /tmp/npc-party.json "$CLAUDE_PROJECT_DIR/.claude/parties/<party-name>.json"
   ```

7. **Announce:**
   ```
   Dismissed **<name or alignment+class>** from **<party-name>**.
   Party now has <N> members.
   ```

8. **Show updated roster** as a table. If the party is now empty, note: "Party is empty. Use `/recruit` to add members."
