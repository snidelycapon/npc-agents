# Hooks

Claude Code lifecycle hooks that automate NPC Agents behavior.

## Overview

| Script | Event | Purpose |
|---|---|---|
| `load-alignment.sh` | SessionStart | Loads character or alignment from config, sets session bead state |
| `skill-context.sh` | PreToolUse (Skill) | Injects NPC state into skill context |
| `alignment-restrictions.sh` | PreToolUse (Write/Edit/Bash) | Blocks Evil alignments from sensitive paths |
| `require-compliance-note.sh` | Stop | Requires NPC Compliance Note before session ends |

## Setup

Hooks are configured in `.claude/settings.json`. The project ships with hooks pre-configured — no setup needed if you're working within the NPC Agents repo.

To use hooks in another project, add to that project's `.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|resume",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/npc-agents/hooks/scripts/load-alignment.sh",
            "timeout": 10,
            "statusMessage": "Loading NPC character..."
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Skill",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/npc-agents/hooks/scripts/skill-context.sh",
            "timeout": 5
          }
        ]
      },
      {
        "matcher": "Write|Edit|Bash",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/npc-agents/hooks/scripts/alignment-restrictions.sh",
            "timeout": 5
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/npc-agents/hooks/scripts/require-compliance-note.sh",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

## Configuration

### Settings

Set character or alignment in `.claude/settings.json`:

```json
{
  "npc": {
    "mode": "vera",
    "class": "rogue",
    "safety": {
      "evilAlignments": {
        "enabled": true,
        "requireConfirmation": true,
        "blockedPaths": ["auth/", "billing/", "crypto/"]
      }
    }
  }
}
```

The `mode` field accepts:
- A **character name** (e.g., `vera`) — loads alignment, class, and persona from the character bead
- An **alignment name** (e.g., `neutral-good`) — anonymous mode with that alignment
- **`off`** — disabled

The `class` field accepts a class name (`fighter`) or `off`. Only used in anonymous mode — characters carry their own class.

### Environment Overrides

```bash
export NPC_MODE=chaotic-good   # Override alignment
export NPC_CLASS=rogue         # Override class
export NPC_MODE=off            # Disable
```

## Hook Details

### SessionStart: Load Alignment

Runs when a session starts or resumes. Reads config from settings, resolves the character or alignment, sets session bead state, and injects the behavioral profile into the session context.

- **Character mode**: Resolves character bead → loads alignment, class, persona → sets session bead state dimensions → injects alignment + class profiles
- **Anonymous mode**: Loads alignment (and optional class) directly → sets session bead state → injects profiles

### PreToolUse: Skill Context

Runs before any Skill tool call. Reads current NPC state from the session bead (with JSON fallback during transition) and injects it as `additionalContext` so skills don't need to read state files themselves.

### PreToolUse: Alignment Restrictions

Runs before Write, Edit, or Bash tool calls. If the current alignment is Evil:

- **Blocks writes** to `auth/`, `crypto/`, `billing/`, `security/`, `.env`, `secrets/`
- **Blocks commands** like `git push`, `npm publish`, deployment commands
- **Evil + Rogue:** Additional blocks on security-related files (analysis only)
- **Evil + Cleric:** Blocks CI/CD, Dockerfiles, Terraform, infrastructure files

### Stop: Require Compliance Note

Runs when the agent tries to finish responding. Blocks the session from ending unless the response includes an "NPC Compliance Note" section.

## Helper Scripts

Utility scripts used by hooks and skills:

| Script | Purpose |
|---|---|
| `ensure-session.sh` | Idempotently creates/returns the NPC session bead |
| `resolve-character.sh` | Resolves a character name to its bead ID |
| `resolve-party.sh` | Resolves a party name to its bead ID |

## Deprecated Scripts

| Script | Status |
|---|---|
| `roll.sh` | Deprecated — rolling removed in favor of characters |
| `roll-class.sh` | Deprecated — rolling removed in favor of characters |

## Troubleshooting

**Hook not firing:**
- Check `~/.claude/settings.json` for `"disableAllHooks": false`
- Verify scripts are executable: `chmod +x hooks/scripts/*.sh`
- Check paths use `$CLAUDE_PROJECT_DIR` variable
- Run `/hooks` in Claude Code to see active hooks

**Permission denied:**
- Run `chmod +x hooks/scripts/*.sh`
- Check bash shebang: macOS may need `/opt/homebrew/bin/bash`

**Beads not found:**
- Run `bd init` to initialize the beads database
- Ensure `bd` is in your PATH
