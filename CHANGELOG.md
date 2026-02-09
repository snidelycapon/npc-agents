# Changelog

All notable changes to the Agentic Alignment Framework will be documented in this file.

## [0.1.0-alpha] - 2026-02-09

### Added

- **9 alignment directives** mapped to a 3x3 alignment grid (Law/Chaos x Good/Evil), each a complete behavioral profile governing code style, testing, documentation, error handling, and communication
  - Lawful Good (The Paladin), Neutral Good (The Mentor), Chaotic Good (The Maverick)
  - Lawful Neutral (The Bureaucrat), True Neutral (The Mercenary), Chaotic Neutral (The Wildcard)
  - Lawful Evil (The Architect), Neutral Evil (The Opportunist), Chaotic Evil (The Gremlin)
- **The Arbiter** — per-task randomized alignment with weighted probability profiles
- **CLI selector** (`alignment-selector.sh`) with 5 probability profiles: controlled_chaos, conservative, heroic, wild_magic, adversarial
- **19 slash commands** as Claude Code skills:
  - 9 alignment skills (`/lawful-good`, `/neutral-good`, `/chaotic-good`, etc.)
  - 1 meta skill (`/arbiter` — per-task randomized alignment)
  - 3 utility skills (`/roll`, `/current`, `/analyze`)
  - 6 team skills (`/war-council`, `/siege`, `/arena`, `/fellowship`, `/oracle`, `/forge`)
- **5 lifecycle hooks** for automatic behavior:
  - SessionStart: auto-load alignment
  - PreToolUse: block Evil from sensitive paths
  - PostToolUse: validate Gremlin anti-patterns
  - Stop: require AAF Compliance Note
  - TeammateIdle: alignment-specific quality gates
- **Safety guardrails**: hard floors for critical tasks, Evil alignment path blocking, circuit breakers, operator consent gates
- **Entropy ledger** (`.entropy-ledger.jsonl`) for auditing alignment rolls
