# Integration Guide

## Claude Code (Full Support)

Claude Code gets the full experience: skills, hooks, characters, parties, systems, and builders.

### Skills

All NPC management is handled through slash commands:

```
/npc create vera developer lawful-good rogue --persona "Security architect"
/npc vera              # Assume a character
/npc set neutral-good  # Anonymous mode
/character             # View character sheet
/quest "task"          # Dispatch to party
/build                 # Interactive character builder
/build system          # Interactive system builder
```

### Hooks

Two lifecycle hooks run automatically when configured in `.claude/settings.json`. See [hooks/README.md](../hooks/README.md) for setup.

| Hook | Event | Purpose |
|---|---|---|
| `skill-context.sh` | PreToolUse (Skill) | Injects NPC state into skill context |
| `alignment-restrictions.sh` | PreToolUse (Write/Edit/Bash) | Blocks Evil from sensitive paths |

### Configuration Priority

The `bin/npc` CLI and hooks read config from these sources (highest priority first):

1. `NPC_MODE` / `NPC_CLASS` environment variables
2. `.claude/settings.json` -> `npc.mode` / `npc.class` / `npc.system` (project-level)
3. `~/.claude/settings.json` -> `npc.mode` / `npc.class` / `npc.system` (user-level)
4. Falls back to `neutral-good` alignment, `alignment-grid` system

## Other Agents (Cursor, Windsurf, Aider)

The behavioral profiles are agent-agnostic markdown — any agent that supports project-level instructions can use them.

### How To

1. Pick a disposition profile from `systems/alignment-grid/dispositions/<value>.md`
2. Optionally pick a domain profile from `systems/alignment-grid/domains/<value>.md`
3. Optionally pick a stance profile from `systems/alignment-grid/stances/<value>.md`
4. Copy the content into your agent's project instructions:
   - **Cursor:** `.cursorrules` or project settings
   - **Windsurf:** Project instructions
   - **Aider:** Project instructions

### What You Lose

Without Claude Code, you don't get:

- Slash command skills (`/npc`, `/quest`, `/build`, `/oracle`)
- Lifecycle hooks (context injection, Evil path blocking)
- Named characters with full depth (convictions, reflexes, history, perspectives)
- Parties and quest dispatch (council, expedition, debate modes)
- Interactive builders (character, party, system)
- Extensible behavioral systems
- Beads-based state tracking

You still get the core value: a coherent behavioral profile governing code style, testing, documentation, error handling, and communication.
