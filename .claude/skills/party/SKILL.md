---
name: party
description: "Manage adventuring parties. Create, list, show, delete, and set active party."
argument-hint: "[name | create <name> | delete <name> | active [name]]"
---

# Party Management

> **Context:** The `skill-context` hook injects NPC state when this skill is invoked. Use the `Project dir` value as `$PROJECT_DIR` in bash commands below. The active party name is available directly from hook context.

Manage adventuring parties — teams of NPC character beads organized as epics.

Parties are beads of type `epic` with label `npc:party`. Members are character beads (type `task`, label `npc:character`) linked via parent-child dependencies.

## Arguments

`$ARGUMENTS`

## Parse Arguments

- No arguments → list all parties
- `create <name> [description...]` → create a new party
- `delete <name>` → delete a party (confirm first)
- `active` (no name) → show the currently active party
- `active <name>` → set the active party
- Any other single word → show that party's roster

## Commands

### List All Parties (no arguments)

1. List all party beads:
   ```bash
   bd list --label npc:party -t epic --json
   ```

2. For each party, display a summary line:
   ```
   - **<title>** — <description> (<N> members)
   ```
   To get member count, use `bd children <party-id> --json` and count results.

3. Show which party is currently active (from skill-context hook output).

4. If no parties exist, say so and suggest `/party create <name>`.

### Show Party Roster: `<name>`

1. Resolve party:
   ```bash
   PARTY_ID=$("$PROJECT_DIR"/hooks/scripts/resolve-party.sh "<name>")
   ```

2. If not found, error and stop.

3. Get party details:
   ```bash
   bd show "$PARTY_ID" --json
   ```

4. Get members (children):
   ```bash
   bd children "$PARTY_ID" --json
   ```

5. For each child bead, extract alignment/class/role from labels, name from title, persona from description.

6. Display as a formatted roster:

   ```
   ## <Party Name>
   <description>

   | # | Name | Alignment | Class | Role | Persona |
   |---|------|-----------|-------|------|---------|
   | 1 | Vera | LG | Rogue | Defender | Battle-scarred security architect... |
   | 2 | Kai  | NE | Rogue | Attacker | — |
   ```

   - **Alignment**: use short form (LG, NG, CG, LN, TN, CN, LE, NE, CE)
   - **Persona**: truncated preview (~40 chars) or "—"

7. Show if this is the active party.

### Create Party: `create <name> [description...]`

1. Validate name: must be kebab-case (`[a-z0-9-]+`).

2. Check if party already exists:
   ```bash
   EXISTING=$("$PROJECT_DIR"/hooks/scripts/resolve-party.sh "<name>")
   ```
   If found, error and stop.

3. Create the party bead:
   ```bash
   bd create "<name>" -t epic -l "npc:party" -d "<description>"
   ```

4. If no active party is set, set this one active on the session bead:
   ```bash
   SESSION_ID=$("$PROJECT_DIR"/hooks/scripts/ensure-session.sh)
   "$PROJECT_DIR"/hooks/scripts/set-session-state.sh "$SESSION_ID" active-party=<name>
   ```

5. Announce: "Created party **<name>**. Use `/recruit` to add members."

### Delete Party: `delete <name>`

1. Resolve party via `resolve-party.sh`.

2. Show the roster (using `bd children`).

3. **Confirm with the user** before deleting.

4. If confirmed, delete:
   ```bash
   bd delete "$PARTY_ID"
   ```
   Note: This only deletes the party epic. Character beads survive — they're independent entities.

5. If this was the active party, clear it on the session bead:
   ```bash
   SESSION_ID=$("$PROJECT_DIR"/hooks/scripts/ensure-session.sh)
   "$PROJECT_DIR"/hooks/scripts/set-session-state.sh "$SESSION_ID" active-party=none
   ```

6. Announce: "Deleted party **<name>**. Character beads are preserved."

### Show Active Party: `active` (no name)

1. Read the active party from skill-context hook output.
2. If set, show that party's roster.
3. If not set, say "No active party. Use `/party active <name>` to set one."

### Set Active Party: `active <name>`

1. Resolve party via `resolve-party.sh`. Verify it exists.

2. Update session bead:
   ```bash
   SESSION_ID=$("$PROJECT_DIR"/hooks/scripts/ensure-session.sh)
   "$PROJECT_DIR"/hooks/scripts/set-session-state.sh "$SESSION_ID" active-party=<name>
   ```

3. Show the party's roster.

4. Announce: "**<name>** is now the active party."
