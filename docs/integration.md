# Integration Guide

## Claude Code (Full Support)

Claude Code gets the full experience: skills, hooks, characters, and parties.

### Skills

All alignments, classes, and utilities are slash commands:

```
/npc create vera lawful-good rogue --persona "Security architect"
/npc vera              # Assume a character
/npc set neutral-good  # Anonymous mode
/character             # View character sheet
/quest "task"          # Dispatch to party
```

### Hooks

Three lifecycle hooks run automatically when configured in `.claude/settings.json`. See [hooks/README.md](../hooks/README.md) for setup.

| Hook | Event | Purpose |
|---|---|---|
| `load-alignment.sh` | SessionStart | Loads character or alignment from config |
| `skill-context.sh` | PreToolUse (Skill) | Injects NPC state into skill context |
| `alignment-restrictions.sh` | PreToolUse (Write/Edit/Bash) | Blocks Evil from sensitive paths |

### Configuration Priority

The SessionStart hook reads config from these sources (highest priority first):

1. `NPC_MODE` / `NPC_CLASS` environment variables
2. `.claude/settings.json` → `npc.mode` / `npc.class` (project-level)
3. `~/.claude/settings.json` → `npc.mode` / `npc.class` (user-level)
4. Falls back to `neutral-good`

## Other Agents (Cursor, Windsurf, Aider)

The alignment and class directives are agent-agnostic markdown — any agent that supports project-level instructions can use them.

### How To

1. Pick an alignment from `.claude/skills/<alignment>/SKILL.md`
2. Optionally pick a class from `.claude/skills/<class>/SKILL.md`
3. Copy the content into your agent's project instructions:
   - **Cursor:** `.cursorrules` or project settings
   - **Windsurf:** Project instructions
   - **Aider:** Project instructions

### What You Lose

Without Claude Code, you don't get:

- Slash command skills
- Lifecycle hooks (auto-load, Evil path blocking)
- Named characters with personas
- Parties and quests
- Beads-based state tracking

You still get the core value: a coherent behavioral profile governing code style, testing, documentation, error handling, and communication.
