# NPC Hooks

Automatic alignment behavior triggered at Claude Code lifecycle events.

## Hooks Overview

| Hook | Event | Purpose |
|------|-------|---------|
| `load-alignment.sh` | SessionStart | Auto-load alignment from settings or randomize |
| `alignment-restrictions.sh` | PreToolUse | Block Evil alignments from sensitive operations |
| `compliance-validation.sh` | PostToolUse | Validate Chaotic Evil introduces anti-patterns |
| `require-compliance-note.sh` | Stop | Require NPC Compliance Note before stopping |
| `team-quality-gates.sh` | TeammateIdle | Enforce alignment-specific quality gates for teams |

## Installation

### Option 1: Project-Level Hooks

Add to `.claude/settings.json` in your project:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|resume",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/hooks/scripts/load-alignment.sh",
            "timeout": 10,
            "statusMessage": "🎲 Loading alignment..."
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Write|Edit|Bash",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/hooks/scripts/alignment-restrictions.sh",
            "timeout": 5
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/hooks/scripts/compliance-validation.sh",
            "timeout": 10
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/hooks/scripts/require-compliance-note.sh",
            "timeout": 5
          }
        ]
      }
    ],
    "TeammateIdle": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/hooks/scripts/team-quality-gates.sh",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

### Option 2: Copy hooks.json

Copy the complete hooks configuration:

```bash
cp hooks/hooks.json .claude/settings.json
```

Then merge with your existing settings if needed.

## Configuration

### Alignment Preferences

Set alignment and class preferences in `.claude/settings.json`:

```json
{
  "npc": {
    "mode": "wild_magic",              // alignment name, profile name, or "off"
    "class": "off",                    // class name, class profile, or "off"
    "safety": {
      "evilAlignments": {
        "enabled": true,                // Allow Evil alignments
        "requireConfirmation": true,    // Require user confirmation
        "blockedPaths": [               // Additional blocked paths
          "auth/",
          "billing/",
          "crypto/"
        ],
        "maxConsecutive": 3             // Max consecutive Evil rolls
      },
      "classRestrictions": {
        "evilRogue": {
          "analysisOnly": true          // Evil+Rogue: no exploit code
        },
        "evilCleric": {
          "requireApproval": true       // Evil+Cleric: no infra changes
        }
      }
    }
  }
}
```

The `mode` field accepts:
- An **alignment name** (e.g., `neutral-good`) — fixed to that alignment every session
- A **profile name** (e.g., `wild_magic`, `controlled_chaos`) — rolls a new alignment per task
- **`off`** — disables alignment system

The `class` field accepts:
- A **class name** (e.g., `fighter`, `rogue`) — fixed to that class every session
- A **class profile** (e.g., `uniform`, `task_weighted`, `specialist`) — rolls a new class per task
- **`off`** — disables class system (alignment-only mode)

### Environment Variable Overrides

```bash
# Override alignment mode for this session
export NPC_MODE=chaotic-good

# Override class mode for this session
export NPC_CLASS=rogue

# Disable NPC Agents
export NPC_MODE=off
```

## Hook Behaviors

### SessionStart: Load Alignment

**When:** Session starts or resumes

**What it does:**
1. Checks for alignment preference in settings (project → user → env via `NPC_MODE`)
2. If mode is a profile, rolls new alignment using that profile
3. If mode is a fixed alignment, loads that alignment's skill file
4. Checks for class preference in settings (via `npc.class` or `NPC_CLASS` env)
5. If class mode is a profile, rolls new class using that profile
6. If class mode is a fixed class, loads that class's skill file
7. Builds combined context with alignment + class content and character identity
8. Injects context for Claude

**Output:** Adds alignment + class announcement to Claude's context

---

### PreToolUse: Alignment Restrictions

**When:** Before Write, Edit, or Bash tool executes

**What it does:**
1. Checks if current alignment is Evil
2. If Evil, validates the target path/command against blocked patterns
3. Blocks Evil alignments from:
   - Writing to `auth/`, `crypto/`, `billing/`, `security/`, `.env`, `secrets/`
   - Running `git push`, `npm publish`, deployment commands
4. Applies class-specific Evil restrictions:
   - **Evil + Rogue:** Additional blocks on security-related files (analysis only)
   - **Evil + Cleric:** Blocks CI/CD, Dockerfiles, Terraform, deployment configs, infrastructure files
5. Returns denial with reason if blocked

**Output:** Denies tool call with explanation, or allows silently

---

### PostToolUse: Compliance Validation

**When:** After Write or Edit tool completes

**What it does:**
1. Checks if current alignment is Chaotic Evil
2. If Chaotic Evil, validates that anti-patterns are present:
   - Magic numbers (numbers > 1)
   - TODO/FIXME comments
   - `any` types
   - Empty catch blocks
   - Console.log statements
3. If clean code detected, warns about alignment violation

**Output:** Warning message if Gremlin wrote clean code

---

### Stop: Require Compliance Note

**When:** Claude attempts to finish responding

**What it does:**
1. Checks if NPC Agents is active (state file exists)
2. Searches transcript for "NPC Compliance Note"
3. If not found, blocks stopping and provides template
4. If found, allows stopping

**Output:** Blocks with template, or allows silently

**Template:**
```
⚙️ NPC Compliance Note
Alignment: [your alignment] | Archetype: [archetype name]
Class: [your class, or 'none'] | Title: [class title, or 'N/A']
Character: [archetype + title]
Compliance: [high | moderate | low] — [justification]
Deviations: [list or none]
Alignment Insight: [what did this reveal?]
Class Insight: [what did the class domain focus surface? Or 'N/A']
```

---

### TeammateIdle: Team Quality Gates

**When:** Agent team teammate is about to go idle

**What it does:**
1. Looks up teammate's alignment from team config
2. Enforces alignment-specific quality gates:
   - **Lawful Good (Paragon):** Must have tests and documentation
   - **Chaotic Evil (Gremlin):** Must NOT have passing tests
   - **Lawful Neutral (Bureaucrat):** Must pass linting
   - **Neutral Good (Mentor):** Must have pragmatic tests
3. If quality gate fails, sends feedback and prevents idle

**Output:** Blocks with feedback, or allows silently

## Testing Hooks

### Test SessionStart Hook

```bash
# Create test input
cat > /tmp/session-start-input.json <<EOF
{
  "session_id": "test-123",
  "source": "startup",
  "cwd": "$PWD",
  "permission_mode": "default",
  "hook_event_name": "SessionStart"
}
EOF

# Run hook
./hooks/scripts/load-alignment.sh < /tmp/session-start-input.json | jq .
```

### Test PreToolUse Hook

```bash
# Test Evil alignment blocked from auth/
cat > /tmp/pretool-input.json <<EOF
{
  "tool_name": "Write",
  "tool_input": {
    "file_path": "auth/login.ts"
  },
  "cwd": "$PWD"
}
EOF

# Set Evil alignment first
./alignment-selector.sh set neutral-evil

# Run hook (should block)
./hooks/scripts/alignment-restrictions.sh < /tmp/pretool-input.json | jq .
```

### Test Compliance Note Requirement

```bash
# Create transcript without compliance note
echo "Some conversation..." > /tmp/test-transcript.jsonl

cat > /tmp/stop-input.json <<EOF
{
  "transcript_path": "/tmp/test-transcript.jsonl",
  "cwd": "$PWD"
}
EOF

# Run hook (should block)
./hooks/scripts/require-compliance-note.sh < /tmp/stop-input.json | jq .
```

## Debugging

Enable verbose mode in Claude Code: `Ctrl+O`

Or run hooks manually with debug input:

```bash
# Add debug logging
export NPC_DEBUG=1

# Run hook with sample input
cat sample-input.json | ./hooks/scripts/load-alignment.sh
```

## Troubleshooting

**Hook not firing:**
- Check `~/.claude/settings.json` for `"disableAllHooks": false`
- Verify script is executable: `ls -la hooks/scripts/*.sh`
- Check script paths use `$CLAUDE_PROJECT_DIR` variable
- Run `/hooks` in Claude Code to see active hooks

**Permission denied:**
- Run `chmod +x hooks/scripts/*.sh`
- Check bash shebang points to modern bash: `/opt/homebrew/bin/bash`

**Alignment not loading:**
- Verify `alignment-selector.sh` exists and is executable
- Check settings.json syntax is valid JSON
- Run selector manually: `./alignment-selector.sh current`

**Evil alignment not blocked:**
- Check alignment is actually Evil: `./alignment-selector.sh current`
- Verify path patterns match: `echo "$FILE_PATH" | grep -E 'auth/'`
- Check hook is registered for the right tools (Write|Edit|Bash)

