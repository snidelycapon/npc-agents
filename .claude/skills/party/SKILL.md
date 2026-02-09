---
name: party
description: "Manage adventuring parties. Create, list, show, delete, and set active party."
argument-hint: "[name | create <name> | delete <name> | active [name]]"
---

# Party Management

Manage saved adventuring parties — teams of NPC agents with specific alignment+class compositions.

Parties are stored as JSON files in `.claude/parties/<name>.json`.

## Arguments

`$ARGUMENTS`

## Parse Arguments

- No arguments → list all saved parties
- `create <name> [description...]` → create a new empty party
- `delete <name>` → delete a party (confirm first)
- `active` (no name) → show the currently active party
- `active <name>` → set the active party
- Any other single word → show that party's roster

## Commands

### List All Parties (no arguments)

1. List all party files:
   ```bash
   ls "$CLAUDE_PROJECT_DIR"/.claude/parties/*.json 2>/dev/null
   ```

2. For each file, read it and display a summary line:
   ```
   - **<name>** — <description> (<N> members)
   ```

3. Also show which party is currently active:
   ```bash
   jq -r '.activeParty // "none"' "$CLAUDE_PROJECT_DIR/.npc-state.json" 2>/dev/null
   ```

4. If no parties exist, say so and suggest `/party create <name>`.

### Show Party Roster: `<name>`

1. Read the party file:
   ```bash
   cat "$CLAUDE_PROJECT_DIR/.claude/parties/<name>.json"
   ```

2. Display the party as a formatted roster:

   ```
   ## <Party Name>
   <description>

   | # | Name | Alignment | Class | Role | Persona |
   |---|------|-----------|-------|------|---------|
   | 1 | Vera | LG | Rogue | Defender | Battle-scarred security architect... |
   | 2 | — | NE | Rogue | Attacker | — |
   ```

   - **Name** column: show the member's `name` if set, otherwise "—"
   - **Persona** column: show a truncated preview (first ~40 chars) if set, otherwise "—"
   - **Alignment**: use the short form (LG, NG, CG, LN, TN, CN, LE, NE, CE)

3. Show if this is the active party.

### Create Party: `create <name> [description...]`

1. Validate the name: must be kebab-case (`[a-z0-9-]+`). No spaces.

2. Check if the party file already exists:
   ```bash
   test -f "$CLAUDE_PROJECT_DIR/.claude/parties/<name>.json"
   ```
   If it exists, report error and stop.

3. Ensure the parties directory exists:
   ```bash
   mkdir -p "$CLAUDE_PROJECT_DIR/.claude/parties"
   ```

4. Write the party file:
   ```json
   {
     "name": "<name>",
     "description": "<description or empty string>",
     "created": "<ISO 8601 timestamp>",
     "members": []
   }
   ```

5. If no active party is set, automatically set this as active:
   ```bash
   jq --arg party "<name>" '.activeParty = $party' "$CLAUDE_PROJECT_DIR/.npc-state.json" > /tmp/npc-state.json && mv /tmp/npc-state.json "$CLAUDE_PROJECT_DIR/.npc-state.json"
   ```

6. Announce: "Created party **<name>**. Use `/recruit <alignment> [class]` to add members."

### Delete Party: `delete <name>`

1. Check the party file exists.

2. Read it and show the roster.

3. **Confirm with the user** before deleting. This is a destructive action.

4. If confirmed, delete the file:
   ```bash
   rm "$CLAUDE_PROJECT_DIR/.claude/parties/<name>.json"
   ```

5. If this was the active party, clear the `activeParty` field:
   ```bash
   jq 'del(.activeParty)' "$CLAUDE_PROJECT_DIR/.npc-state.json" > /tmp/npc-state.json && mv /tmp/npc-state.json "$CLAUDE_PROJECT_DIR/.npc-state.json"
   ```

6. Announce: "Deleted party **<name>**."

### Show Active Party: `active` (no name)

1. Read active party from state:
   ```bash
   jq -r '.activeParty // "none"' "$CLAUDE_PROJECT_DIR/.npc-state.json" 2>/dev/null
   ```

2. If set, show that party's roster (same as Show Party Roster above).
3. If not set, say "No active party. Use `/party active <name>` to set one."

### Set Active Party: `active <name>`

1. Verify the party file exists:
   ```bash
   test -f "$CLAUDE_PROJECT_DIR/.claude/parties/<name>.json"
   ```

2. Update state:
   ```bash
   jq --arg party "<name>" '.activeParty = $party' "$CLAUDE_PROJECT_DIR/.npc-state.json" > /tmp/npc-state.json && mv /tmp/npc-state.json "$CLAUDE_PROJECT_DIR/.npc-state.json"
   ```

3. Show the party's roster.

4. Announce: "**<name>** is now the active party."
