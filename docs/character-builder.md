# Character Builder

> **Status:** Design specification. The character builder and party assembly flows are fully implemented as of v3.0.0 via `/build`.

Agent-driven interactive flows for creating characters, assembling parties, and scaffolding teams. The builder is the conversational layer that sits above the `bin/npc` CLI — it elicits, suggests, and refines, then persists everything through CLI commands.

## Why a Builder

With the depth introduced in the [Character Depth](character-depth.md) spec — history, convictions, reflexes, perspectives — raw CLI flags become unwieldy. A Lawful Good Rogue with full depth needs ~10 flags:

```
bin/npc create vera developer lawful-good rogue \
  --persona "Security architect, three breaches survived" \
  --role defender \
  --history "Junior dev at fintech — learned compliance and fear of prod" \
  --history "Security consultant for 4 years — learned threat modeling" \
  --history "Led incident response for supply chain breach" \
  --conviction "Every endpoint must validate auth tokens" \
  --conviction "Test coverage numbers lie — mutation testing reveals truth" \
  --conviction "The simplest fix is usually the right fix" \
  --reflex "Always check for injection when I see string interpolation" \
  --reflex "Never approve removing error handling without a replacement" \
  --reflex "Always ask what happens when this fails before approving I/O"
```

Nobody wants to author that by hand. The builder interviews the user, derives most of these from conversation, and runs the CLI call at the end. It also handles the harder design problems: party composition, perspective balance, conviction derivation from context.

---

## Entry Points

### `/build` — Interactive Character Builder

```
/build                                    # Start guided flow from scratch
/build vera lawful-good rogue             # Start with known basics, fill in depth
/build customer for our developer CLI     # Start with intent, derive everything
/build party for security review          # Party assembly flow
```

### `/build` vs. `/npc create`

| | `/npc create` (CLI bridge) | `/build` |
|---|---|---|
| **For** | Users who know exactly what they want | Users who want guidance |
| **Input** | All flags up front | Conversational, iterative |
| **Output** | One CLI call, character created | Interview → preview → approval → CLI call |
| **Depth** | Only what you specify | Suggests history, derives convictions/reflexes |
| **Time** | Instant | 2-5 minutes of conversation |

Both persist through the same `bin/npc` CLI. The builder is not a separate storage path — it's a guided front-end.

---

## Character Builder Flow

### Phase 1: Intent

The builder starts by understanding what the character is *for*.

**If invoked bare** (`/build`):
> "What do you need this character for? Examples: security review, architecture analysis, feature planning, representing a user persona, adversarial testing, documentation review."

**If invoked with context** (`/build customer for our SaaS API`):
> The builder extracts intent from the arguments and confirms: "Building a customer-perspective character to evaluate your SaaS API. Correct?"

**If invoked with basics** (`/build vera lawful-good rogue`):
> The builder skips to Phase 4 (history elicitation), using the provided name/alignment/class.

The intent shapes all subsequent suggestions. "Security review" biases toward Rogue class, Lawful alignment, developer perspective. "Representing our free-tier users" biases toward customer perspective with a specific history pattern.

### Phase 2: Perspective

> "Will this character be **building and reviewing** code (developer), or **using and evaluating** the product (customer)?"

If obvious from intent, the builder states its assumption and moves on. The user can always override.

For customer perspective, the builder asks a follow-up:
> "What kind of user? Power user? New adopter? Administrator? Someone evaluating the tool for their team?"

This shapes the class suggestion in the next phase.

### Phase 3: Alignment + Class

**Alignment** — The builder can suggest based on intent, or elicit through diagnostic questions:

Diagnostic approach (optional — the builder should offer this as an alternative to direct selection):

> "When this character encounters unclear requirements, do they:
> - (a) Stop and ask for clarification before proceeding → Lawful
> - (b) Make a pragmatic judgment call and move forward → Neutral
> - (c) Prototype something to make the question concrete → Chaotic"

> "When this character sees code that works but is poorly structured, do they:
> - (a) Fix it or flag it, even if it's not their task → Good
> - (b) Note it and move on — not their scope → Neutral
> - (c) Exploit it for speed — messy code is easier to hack on → Evil"

The builder crosses the two answers to suggest an alignment, explains what it means for agent behavior, and asks the user to confirm or adjust.

**Class** — Usually obvious from intent + perspective. The builder suggests and explains:

> "For a security-focused developer, I'd suggest **Rogue** — security analysis, adversarial testing, boundary awareness. They'll review code for vulnerabilities, write tests that target weak points, and flag missing error handling. Does that fit?"

For customer perspective, the builder translates the class meaning:

> "For a power user evaluating the product, I'd suggest **Fighter** — in customer terms, this is someone who uses the tool daily to build real things. They'll evaluate features from the perspective of hands-on daily use, not theoretical assessment."

### Phase 4: History

This is the most conversational phase. The builder interviews the user to construct a narrative history that will ground the character's behavior.

**Opening prompt:**
> "Tell me about this character's background. What experiences shaped their current perspective? I'll help turn this into structured history entries."
>
> "For example: 'They spent 5 years doing backend work at a fintech company, then moved to a startup where they had to do everything.' I'll extract the formative experiences and what each one taught them."

**The builder's job is to extract and structure**, not just transcribe. If the user says:

> "She's been doing security work for about 10 years, started at a bank, then went independent."

The builder proposes structured entries:

> Based on that, here's what I'd suggest for her history:
>
> 1. "Security analyst at a bank for 4 years — learned compliance frameworks, regulatory thinking, and that most breaches start with social engineering"
> 2. "Independent security consultant for 6 years — learned to assess unfamiliar codebases quickly, client communication, and that the scariest vulnerabilities are the ones everyone assumes someone else is handling"
>
> Want to adjust, add, or refine these?

**For customer characters**, the builder asks about the user's *experience with the product category*, not their career:

> "What's this user's history with tools like yours? Have they used alternatives? Are they technical? What's their comfort level with CLIs vs. GUIs?"

### Phase 5: Convictions

The builder **derives** convictions from the history and intent, then presents them for refinement.

> "Based on Vera's history in security consulting and her supply chain breach experience, I'd suggest these convictions:
>
> 1. **'Every API endpoint must validate auth tokens — no exceptions'** — from her compliance background
> 2. **'Transitive dependencies are the real attack surface'** — from the supply chain incident
> 3. **'The simplest fix is usually the right fix'** — from years of seeing over-engineered security solutions create new vulnerabilities
>
> These are her active priorities — they'll shape what she notices and flags first. Adjust?"

The builder should tie each conviction back to the history that motivates it. This is what makes convictions feel grounded rather than arbitrary.

**For quest-specific characters**, the builder can also ask about the current project:

> "Is there anything specific about *your* codebase or project that should shape her convictions? For example: 'We handle healthcare data' or 'Our test suite is unreliable.'"

### Phase 6: Reflexes

The builder **derives** reflexes from history + convictions, focusing on automatic trigger behaviors.

> "Given her background, here are the reflexes I'd suggest — automatic behaviors she'd exhibit before even thinking about it:
>
> 1. **'Always check for injection when I see string interpolation in queries'** — muscle memory from security consulting
> 2. **'Never approve removing error handling without a replacement'** — the bank taught her that swallowed errors cause breaches
> 3. **'Always ask what happens when this fails before approving any I/O operation'** — post-incident thinking baked into reflex
>
> These should feel like habits — things she does without being asked. Adjust?"

### Phase 7: Persona Synthesis

The builder synthesizes a 1-2 sentence persona from all the accumulated context:

> "Here's the persona summary: **'Security architect with a decade of consulting experience and one career-defining supply chain breach. Trusts nothing, verifies everything, and believes the simplest fix is usually the safest.'**"

### Phase 8: Preview + Confirmation

The builder displays the complete character sheet and asks for approval:

```
## Character Preview

**Name:**        Vera
**Perspective:**  Developer
**Alignment:**    Lawful Good
**Class:**        Rogue
**Role:**         Defender

**Persona:** Security architect with a decade of consulting experience and one
career-defining supply chain breach. Trusts nothing, verifies everything, and
believes the simplest fix is usually the safest.

**History:**
1. Security analyst at a bank for 4 years — learned compliance frameworks and
   that most breaches start with social engineering
2. Independent security consultant for 6 years — learned to assess unfamiliar
   codebases quickly and that the scariest vulnerabilities are the ones everyone
   assumes someone else is handling
3. Led incident response for a supply chain breach through a transitive dependency —
   career-defining event that shaped everything after

**Convictions:**
1. Every API endpoint must validate auth tokens — no exceptions
2. Transitive dependencies are the real attack surface
3. The simplest fix is usually the right fix

**Reflexes:**
1. Always check for injection when I see string interpolation in queries
2. Never approve removing error handling without a replacement
3. Always ask "what happens when this fails?" before approving any I/O operation

Create this character? [Yes / Adjust / Start over]
```

On approval, the builder runs the `bin/npc create` command with all flags and confirms creation.

---

## Party Assembly Flow

Invoked via `/build party` or `/build party for <purpose>`.

### Phase 1: Goal

> "What's this party for? Examples: security review, feature planning, architecture evaluation, product feedback, red team/blue team testing."

The goal drives composition suggestions.

### Phase 2: Composition Suggestion

Based on the goal, the builder suggests a party structure with reasoning:

> **Suggested party for: Security Review**
>
> | # | Perspective | Alignment | Class | Role | Reasoning |
> |---|---|---|---|---|---|
> | 1 | Developer | Lawful Good | Rogue | Defender | Systematic security analysis, comprehensive threat modeling |
> | 2 | Developer | Chaotic Good | Rogue | Attacker | Creative adversarial thinking, finds unexpected vectors |
> | 3 | Developer | Neutral Good | Wizard | Architect | Evaluates whether the architecture enables or prevents security |
> | 4 | Customer | Chaotic Good | Rogue | User | Tries unexpected inputs, finds edge cases as a real user would |
>
> **Why this composition:**
> - Two Rogues with different alignments create attacker/defender tension
> - The Wizard provides architectural context the Rogues might miss
> - The customer Rogue surfaces the kind of accidental abuse that real users produce
>
> Accept this composition, adjust it, or describe what you'd prefer?

### Phase 3: Build or Recruit

For each suggested slot, the builder checks existing characters:

> "You already have **Vera** (Lawful Good Rogue, Developer) — she fits the Defender slot perfectly. Recruit her?"
>
> "No existing character fits the Attacker slot. Want to build one now, or create a quick character with defaults?"

**Recruit existing:** `bin/npc recruit vera --party <name> --role defender`

**Build new:** Enters the character builder flow (Phases 4-8 above) for the missing member, then recruits.

**Quick create:** The builder generates a reasonable character from the slot description with minimal input — name, alignment, class, and auto-generated history/convictions/reflexes based on the party goal. Shows preview, user approves, creates and recruits.

### Phase 4: Party Review

```
## Party Preview: security-review

**Goal:** Security review of authentication and authorization layer

| # | Name | Alignment | Class | Perspective | Role |
|---|------|-----------|-------|-------------|------|
| 1 | Vera | Lawful Good | Rogue | Developer | Defender |
| 2 | Slink | Chaotic Good | Rogue | Developer | Attacker |
| 3 | Marcus | Neutral Good | Wizard | Developer | Architect |
| 4 | Kai | Chaotic Good | Rogue | Customer | User |

Create this party? [Yes / Adjust / Add member / Remove member]
```

On approval, the builder runs `bin/npc party create` + `bin/npc recruit` for each member.

---

## Quick Mode

For experienced users who want depth without a full interview. The builder generates everything from minimal input + stated purpose.

```
/build quick vera lawful-good rogue --for "security review of our auth service"
```

The builder:
1. Infers perspective: developer (since "security review")
2. Generates 3 history entries from alignment + class + purpose
3. Derives 3 convictions from the generated history + stated purpose
4. Derives 3 reflexes from history + convictions
5. Writes a persona from all of the above
6. Shows the preview (Phase 8)
7. On approval, runs `bin/npc create` with all flags

Quick mode takes ~30 seconds (one preview → approve cycle) instead of the 2-5 minute conversational flow. The results are less tailored but still meaningfully deeper than a bare `bin/npc create` with just a persona string.

**Quick party mode:**

```
/build quick party security-review --for "auth service review" --size 4
```

Generates a full party composition with auto-built characters. Shows one combined preview. Creates everything on approval.

---

## Template Library

Over time, common character archetypes and party compositions emerge. The builder can offer templates as starting points.

### Character Templates

Templates are not stored as beads — they're patterns the builder knows about and offers when relevant. Each template is a starting point, not a fixed output — the builder still runs through the phases but pre-fills suggestions.

**Developer templates:**
- **The Guardian** — Lawful Good Rogue. Systematic security reviewer. History emphasizes compliance, incident response, and institutional knowledge.
- **The Hacker** — Chaotic Good Rogue. Creative adversarial tester. History emphasizes independent research, CTF competitions, and unconventional approaches.
- **The Architect** — Neutral Good Wizard. Principled system designer. History emphasizes large-scale systems, migration projects, and design trade-offs.
- **The Pragmatist** — Chaotic Good Fighter. Ship-fast implementer. History emphasizes startups, tight deadlines, and iteration over planning.
- **The Skeptic** — Lawful Evil Wizard. Devil's advocate for architecture. History emphasizes working with overly complex systems and seeing abstraction fail.

**Customer templates:**
- **The Power User** — Chaotic Good Fighter. Uses the tool daily, expects speed and keyboard-first UX. History emphasizes years of tool expertise and strong opinions about workflow.
- **The New Adopter** — Lawful Good Bard. Just started using the tool, needs everything explained. History emphasizes learning new tools and onboarding frustration.
- **The Administrator** — Lawful Neutral Cleric. Deploys and configures for a team. History emphasizes ops work, team management, and reliability requirements.
- **The Evaluator** — Neutral Good Wizard. Comparing this tool to alternatives for a team decision. History emphasizes technical leadership, vendor evaluation, and integration concerns.
- **The Reluctant User** — True Neutral Fighter. Was assigned this tool, didn't choose it. History emphasizes existing workflows that work fine and resistance to change.

**Offering templates:**
> "For a security review, I'd suggest starting from **The Guardian** template — a Lawful Good Rogue with compliance and incident response experience. Want to customize from there, or build from scratch?"

### Party Templates

- **Red Team / Blue Team** — 2 Rogues (LG Defender + CG/NE Attacker), 1 Wizard (Architect), 1 Ranger (Investigator)
- **Architecture Review** — 2 Wizards (LG + CG for structure vs. simplicity tension), 1 Fighter (implementer reality check), 1 Rogue (security implications)
- **Feature Planning** — 1 Wizard (architecture), 1 Fighter (implementation), 1 Customer/Fighter (power user), 1 Customer/Bard (new user)
- **Product Feedback** — 3-4 customer characters with varied histories, alignments, and classes. No developers. Pure user perspective.
- **Devil's Advocate** — 1 primary character (user's actual alignment), 1 Lawful Evil Wizard (over-engineers), 1 Neutral Evil Fighter (cuts corners), 1 Chaotic Good Fighter (simplifies aggressively)

---

## Agent Behavior During Building

The builder skill needs specific behavioral guidance to produce good results:

### Derivation, Not Transcription

The builder's primary job is to **derive** depth from conversation, not transcribe user input into fields. When the user says "she's been doing security for 10 years," the builder doesn't write `--history "Been doing security for 10 years"`. It asks follow-up questions, identifies formative moments, and structures entries that will produce situated behavior from the LLM.

### Suggest, Don't Interrogate

The builder should default to suggesting and asking for adjustments rather than asking open-ended questions at every step. Open-ended questions stall the flow. Suggestions with "adjust?" keep momentum.

Bad:
> "What are Vera's three convictions?"

Good:
> "Based on her incident response background, I'd suggest these convictions: [1, 2, 3]. Adjust, or do these fit?"

### Explain the Impact

When suggesting alignment, class, history, or convictions, the builder should briefly explain *how* the choice affects agent behavior:

> "Lawful Good alignment means she'll push back when asked to cut corners, quantify risk when she sees shortcuts, and refuse to skip tests. This is your 'hold the line' reviewer."

> "This conviction — 'transitive dependencies are the real attack surface' — means she'll flag dependency chains and question indirect imports that other reviewers would ignore."

### Respect Expertise

Some users know exactly what alignment/class they want. The builder shouldn't force them through diagnostic questions when they've already decided. If the user says `/build vera lawful-good rogue`, skip Phases 2-3 and go straight to history.

### Keep It Moving

The full flow should take 2-5 minutes, not 15. The builder batches related questions where possible (alignment + class in one step if the user seems decisive), skips phases when information is already provided, and moves to preview as soon as it has enough to generate the remaining fields.

---

## Implementation

### Skill File

New skill: `.claude/skills/build/SKILL.md`

The build skill is a full SKILL.md procedure (not a thin CLI bridge) because the value is in the conversational elicitation, not the command execution. It:

1. Parses arguments to determine entry point (bare, with basics, with intent, party mode, quick mode)
2. Runs through the appropriate phases conversationally
3. Accumulates character/party data
4. Renders the preview
5. On approval, runs `bin/npc` CLI commands to persist

### CLI Dependencies

The build skill depends on `bin/npc` supporting all the character depth fields:

```
bin/npc create <name> [perspective] <alignment> [class] \
  [--persona "..."] [--role role] \
  [--history "..."] [--history "..."] \
  [--conviction "..."] [--conviction "..."] [--conviction "..."] \
  [--reflex "..."] [--reflex "..."] [--reflex "..."]
```

And party commands:
```
bin/npc party create <name> [description]
bin/npc recruit <name> --party <name> [--role role]
```

### Template Storage

Templates don't need external storage for an initial version — they can be embedded in the build SKILL.md as reference patterns. If the template library grows large enough to bloat the skill file, templates can move to a `templates/` directory that the builder reads on demand.

### Relationship to Other Skills

| Skill | Purpose | Relationship |
|---|---|---|
| `/npc create` | Direct CLI creation (thin bridge) | Builder calls this at the end |
| `/npc` | General NPC management | Builder is a specialized alternative to `npc create` |
| `/party` | Party management (thin bridge) | Builder calls this for party assembly |
| `/recruit` | Recruitment (thin bridge) | Builder calls this for party member recruitment |
| `/quest` | Quest dispatch | Consumes the characters/parties the builder creates |
| `/build` | **This skill** — guided creation | Front-end for `/npc create` + `/party` + `/recruit` |
