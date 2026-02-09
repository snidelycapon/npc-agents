---
name: roll-class
description: "Roll a random class using a probability profile. Usage: /roll-class [profile] [--task-type TYPE]"
argument-hint: "[profile] [--task-type TYPE]"
---

# Roll for Class

Roll a d100 to determine your class using a probability profile.

## Arguments

- **profile** (optional): `uniform` (default), `task_weighted`, `specialist`
- **--task-type TYPE** (optional): `feature`, `bugfix`, `refactor`, `spike`, `chore`, `docs`, `test`, `review`

If `task_weighted` or `specialist` is specified without a task type, falls back to `uniform`.

## Procedure

1. Call the roll script:
   ```bash
   "$CLAUDE_PROJECT_DIR"/hooks/scripts/roll-class.sh <PROFILE> [--task-type <TYPE>]
   ```

2. The script outputs JSON:
   ```json
   {"roll": 42, "profile": "task_weighted", "class": "ranger", "title": "The Tracker", "taskType": "bugfix"}
   ```

   The script also updates `.npc-state.json` and appends to `.npc-ledger.jsonl`.

3. Invoke the corresponding class skill:
   ```
   /class-<rolled-class>
   ```

4. Announce the roll:
   ```
   🎲 Class Roll: d100 = [roll] → [Class] — [Title]
   Profile: [profile] | Task Type: [task type or 'none']
   ```

## Class Probability Tables

### Uniform (default)
Equal probability: ~17% each class.

### Task-Weighted
Weighted by task type affinity:

| Task Type | Fighter | Wizard | Rogue | Cleric | Bard | Ranger |
|---|---|---|---|---|---|---|
| feature | 35% | 15% | 10% | 10% | 10% | 20% |
| bugfix | 15% | 10% | 15% | 10% | 5% | 45% |
| refactor | 10% | 40% | 10% | 5% | 10% | 25% |
| spike | 10% | 30% | 10% | 5% | 5% | 40% |
| chore | 15% | 5% | 5% | 45% | 10% | 20% |
| docs | 5% | 10% | 5% | 5% | 65% | 10% |
| test | 10% | 5% | 50% | 5% | 5% | 25% |
| review | 10% | 20% | 30% | 5% | 10% | 25% |

### Specialist
Heavily favors the primary class for each task type (60-80% for the top class).
