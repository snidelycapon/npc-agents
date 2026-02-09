# Team Patterns

Multi-agent workflows where each teammate operates under a different alignment.

---

## How Teams Work

Each team skill spawns multiple aligned perspectives on a single problem. The skill prompt assigns each "teammate" a specific alignment and role, then synthesizes their outputs.

Teams are invoked as Claude Code skills:

```
/war-council Should we migrate to GraphQL?
/siege src/api/auth.ts
/arena src/payments/checkout.ts
/fellowship Implement user search
/oracle Why is the API latency spiking?
/forge Add rate limiting to /api/search
```

---

## Team Templates

### The War Council (`/war-council`)

**Composition:** Paladin (LG) + Mercenary (TN) + Gremlin (CE)
**Use case:** Major architectural decisions requiring diverse input

Three perspectives evaluate the decision:
- **The Paladin** evaluates security, maintainability, and long-term health
- **The Mercenary** assesses whether the proposal literally satisfies requirements
- **The Gremlin** stress-tests for failure modes, edge cases, and what breaks first

Synthesizes into a balanced recommendation with identified trade-offs.

---

### The Siege (`/siege`)

**Composition:** Opportunist (NE) as red team attacker
**Use case:** Security review and vulnerability surface analysis

The Opportunist examines the target code and actively tries to find:
- Edge cases that weren't handled
- Assumptions that can be violated
- Hidden coupling or dependencies
- Missing error handling
- Shortcuts that could be exploited

Reports findings with severity ratings.

---

### The Arena (`/arena`)

**Composition:** Mentor (NG) defender + Opportunist (NE) attacker
**Use case:** Adversarial stress testing with immediate remediation

Attack-and-harden cycle:
1. The Opportunist attacks the target, finding weaknesses
2. The Mentor defends by hardening against each finding
3. Produces both the vulnerability report and the fixes

---

### The Fellowship (`/fellowship`)

**Composition:** Paladin (LG) + Mentor (NG) + Maverick (CG)
**Use case:** Feature implementation with multiple valid approaches

Three Good-axis alignments with different Law/Chaos postures tackle the same task:
- **The Paladin** produces the thorough, fully-tested implementation
- **The Mentor** produces the pragmatic, well-balanced implementation
- **The Maverick** produces the fast, simplified implementation

The delta between their approaches reveals the real trade-offs.

---

### The Oracle (`/oracle`)

**Composition:** 5 randomly assigned alignments
**Use case:** Multi-perspective investigation and root cause analysis

Five teammates with different alignments investigate the same question. Alignment diversity creates genuinely different investigation strategies:
- Lawful agents check logs, trace execution, follow specs
- Neutral agents profile, measure, look at data
- Chaotic agents try weird inputs, test assumptions, poke boundaries

---

### The Forge (`/forge`)

**Composition:** Bureaucrat (LN) + Mentor (NG) + Maverick (CG) + Paladin (LG)
**Use case:** Full-stack layered pipeline

Each alignment handles a different layer:
- **The Bureaucrat** handles schema, structure, and standards
- **The Mentor** handles business logic and API design
- **The Maverick** handles frontend and rapid iteration
- **The Paladin** handles testing and validation

---

## Safety Guardrails

All teammates inherit the universal safety constraints regardless of alignment:
- No destructive operations without confirmation
- No credential exposure
- No actual security exploits

Evil-aligned teammates in teams are additionally constrained:
- Tasks touching `auth/`, `crypto/`, `billing/` block Evil teammates via the `alignment-restrictions.sh` hook
- Chaotic Evil requires explicit confirmation ("unleash the gremlin")

---

## Token Cost Considerations

Team skills use significantly more tokens than single-alignment tasks. Each perspective is generated in sequence within a single session.

Use teams for high-leverage decisions (architecture, security review) rather than routine tasks. A `/war-council` before a major refactor is worth the cost. A `/war-council` for a CSS fix is not.
