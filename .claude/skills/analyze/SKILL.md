---
name: analyze
description: Compare how different alignments would approach a task. Use for understanding trade-offs and alternative perspectives.
argument-hint: "[alignment1] [alignment2]"
disable-model-invocation: true
---

# Alignment Comparative Analysis

Analyze how **$0** and **$1** would approach the current task differently.

## Steps

1. Read both alignment directives from `.claude/skills/$0/SKILL.md` and `.claude/skills/$1/SKILL.md`

2. For each alignment, analyze:
   - **Implementation strategy** they would choose
   - **What they prioritize** (speed, safety, simplicity, correctness, etc.)
   - **What they de-prioritize** or skip entirely
   - **Specific code/design decisions** that would differ
   - **Testing approach** (exhaustive, pragmatic, minimal, stress-test)
   - **Documentation style** (comprehensive, pragmatic, minimal, condescending)
   - **Error handling** (defensive, pragmatic, happy-path-only, deliberately broken)
   - **Trade-offs** each alignment would make

3. Synthesize key insights:
   - What does each alignment reveal about the problem?
   - What risks does each surface?
   - What opportunities does each see?
   - What's the delta that matters?

4. Provide a recommendation based on:
   - Current task context
   - Risk level
   - Time constraints
   - Maintenance concerns

## Output Format

```
# Comparative Analysis: [Alignment 1] vs [Alignment 2]

## [Alignment 1 Name] — [Archetype]

Implementation Approach:
[How they would solve this]

Priorities:
- [What matters most to this alignment]

Code Style:
[Concrete examples of code decisions]

Strengths:
- [What this alignment does well for this task]

Weaknesses:
- [What this alignment misses]

---

## [Alignment 2 Name] — [Archetype]
[Same structure]

---

## Delta Analysis

Key Differences:
1. [Most significant difference]
2. [Second most significant]
3. [Third most significant]

Insights Revealed:
- [Alignment 1] surfaces: [specific insight]
- [Alignment 2] surfaces: [specific insight]

Recommended Approach:
[Based on context, recommend one alignment or a hybrid approach]
```

## Advanced: Three-Way Analysis

For complex decisions, compare three alignments:
```
/analyze lawful-good neutral-good chaotic-good
```

This shows the Good-axis spectrum with Law/Chaos variance.
