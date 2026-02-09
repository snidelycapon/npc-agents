# AAF Hooks

Automatic alignment behavior triggered at Claude Code lifecycle events.

## Hooks Overview

| Hook | Event | Purpose |
|------|-------|---------|
| `load-alignment.sh` | SessionStart | Auto-load alignment from settings or randomize |
| `alignment-restrictions.sh` | PreToolUse | Block Evil alignments from sensitive operations |
| `compliance-validation.sh` | PostToolUse | Validate Chaotic Evil introduces anti-patterns |
| `require-compliance-note.sh` | Stop | Require AAF Compliance Note before stopping |
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

Set alignment preferences in `.claude/settings.json`:

```json
{
  "aaf": {
    "alignment": "neutral-good",        // Specific alignment to use
    "profile": "controlled_chaos",      // Profile for randomization
    "rotation": {
      "enabled": true,                  // Enable automatic rotation
      "interval": "hourly",             // Rotation frequency
      "schedule": "9-17"                // Active hours (optional)
    },
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
      }
    }
  }
}
```

### Environment Variable Overrides

```bash
# Override alignment for this session
export AAF_ALIGNMENT=chaotic-good

# Override profile
export AAF_PROFILE=wild_magic

# Disable AAF
export AAF_DISABLED=1
```

## Hook Behaviors

### SessionStart: Load Alignment

**When:** Session starts or resumes

**What it does:**
1. Checks for alignment preference in settings (project → user → env)
2. If no preference, checks rotation schedule
3. If rotation enabled, rolls new alignment using specified profile
4. If rotation disabled, uses existing alignment or default (neutral-good)
5. Activates alignment via `alignment-selector.sh`
6. Injects alignment context for Claude

**Output:** Adds alignment announcement to Claude's context

---

### PreToolUse: Alignment Restrictions

**When:** Before Write, Edit, or Bash tool executes

**What it does:**
1. Checks if current alignment is Evil
2. If Evil, validates the target path/command
3. Blocks Evil alignments from:
   - Writing to `auth/`, `crypto/`, `billing/`, `security/`, `.env`, `secrets/`
   - Running `git push`, `npm publish`, deployment commands
4. Returns denial with reason if blocked

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
1. Checks if AAF is active (CLAUDE.md exists)
2. Searches transcript for "AAF Compliance Note"
3. If not found, blocks stopping and provides template
4. If found, allows stopping

**Output:** Blocks with template, or allows silently

**Template:**
```
⚙️ AAF Compliance Note
Alignment: [your alignment]
Archetype: [archetype name]
Compliance: [high | moderate | low] — [justification]
Deviations: [list or none]
Alignment Insight: [what did this reveal?]
```

---

### TeammateIdle: Team Quality Gates

**When:** Agent team teammate is about to go idle

**What it does:**
1. Looks up teammate's alignment from team config
2. Enforces alignment-specific quality gates:
   - **Lawful Good (Paladin):** Must have tests and documentation
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
export AAF_DEBUG=1

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

