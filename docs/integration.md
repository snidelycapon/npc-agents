# Integration Guide

How to use the Agentic Alignment Framework with different agents and workflows.

---

## Claude Code (Full Support)

Claude Code gets the full experience: skills, hooks, and the CLI selector.

### Skills

All alignments and utilities are invocable as slash commands. See [.claude/skills/README.md](../.claude/skills/README.md) for the complete list.

```
/neutral-good          # Activate The Mentor
/roll wild_magic       # Roll a random alignment
/war-council           # Spawn a three-perspective team
/current               # Check active alignment
```

Skills work by loading the alignment's behavioral directives into Claude's context for the session.

### Hooks

Five lifecycle hooks automate alignment behavior. See [hooks/README.md](../hooks/README.md) for setup and configuration.

| Hook | Event | What it does |
|---|---|---|
| `load-alignment.sh` | SessionStart | Loads alignment from settings, env var, or existing symlink |
| `alignment-restrictions.sh` | PreToolUse | Blocks Evil alignments from sensitive paths and deployment commands |
| `compliance-validation.sh` | PostToolUse | Warns if Chaotic Evil writes clean code |
| `require-compliance-note.sh` | Stop | Blocks stopping without an AAF Compliance Note |
| `team-quality-gates.sh` | TeammateIdle | Enforces alignment-specific quality gates for team workflows |

Hooks are configured in `.claude/settings.json` and run automatically.

### CLI Selector

The `alignment-selector.sh` script manages the `CLAUDE.md` symlink:

```bash
./alignment-selector.sh set neutral-good    # Set specific alignment
./alignment-selector.sh roll                # Roll random (controlled_chaos profile)
./alignment-selector.sh roll wild_magic     # Roll with a specific profile
./alignment-selector.sh arbiter             # Activate per-task randomization
./alignment-selector.sh current             # Check current alignment
./alignment-selector.sh list                # List all alignments and profiles
./alignment-selector.sh off                 # Remove CLAUDE.md symlink
```

### Configuration

The `load-alignment.sh` hook checks these sources in order:

1. `AAF_ALIGNMENT` environment variable (highest priority)
2. `.claude/settings.json` -> `aaf.alignment` (project-level)
3. `~/.claude/settings.json` -> `aaf.alignment` (user-level)
4. Existing `CLAUDE.md` symlink
5. Falls back to `neutral-good`

```bash
# Override alignment for a session via env var
export AAF_ALIGNMENT=chaotic-good
```

---

## Other Agents (Cursor, Windsurf, Aider, etc.)

The alignment directives themselves are agent-agnostic -- they're just markdown files that describe behavioral profiles. Any agent that supports project-level instructions can use them.

### Manual Integration

1. Pick an alignment from `.claude/skills/*/SKILL.md`
2. Copy its content into your agent's project instructions file:
   - **Cursor:** `.cursorrules` or project settings
   - **Windsurf:** Project instructions
   - **Aider:** Project instructions
3. The agent will operate under that alignment's behavioral directives

### What You Lose

Without Claude Code, you don't get:
- Slash command skills (Claude Code specific)
- Lifecycle hooks (SessionStart, PreToolUse, etc.)
- Automatic alignment loading and rotation
- Team quality gates
- The CLI selector's roll/symlink mechanism

You still get the core value: a coherent behavioral profile governing code style, testing, documentation, error handling, and communication.

---

## Using Alignments in Your Own Projects

To use AAF in another project:

1. Copy or symlink the alignment SKILL.md you want into your project as `CLAUDE.md`
2. Or install the hooks to get automatic alignment management

```bash
# Option A: Direct symlink from your project to an alignment
ln -s /path/to/agentic-alignment/.claude/skills/neutral-good/SKILL.md ./CLAUDE.md

# Option B: Copy the hooks config into your project's .claude/settings.json
# and point the hook commands to the agentic-alignment directory
```

The alignment directives reference no external files -- each SKILL.md is self-contained.
