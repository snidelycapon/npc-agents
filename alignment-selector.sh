#!/usr/bin/env bash
# alignment-selector.sh — CLI tool for the Agentic Alignment Framework
# Requires bash 4.0+ for associative arrays
# Manages which CLAUDE.md alignment directive is active in the project.
#
# Usage:
#   ./alignment-selector.sh <command> [args]
#
# Commands:
#   set <alignment>    Symlink the specified alignment as the active CLAUDE.md
#   roll [profile]     Roll a random alignment using the specified profile (default: controlled_chaos)
#   arbiter            Activate the Arbiter (per-task randomized alignment)
#   current            Show the currently active alignment
#   list               List all available alignments
#   off                Remove the active CLAUDE.md (disable framework)
#   help               Show this help text

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ALIGNMENTS_DIR="${SCRIPT_DIR}/.claude/skills"
TARGET="${SCRIPT_DIR}/CLAUDE.md"

# Alignment keys and their display names
declare -A ARCHETYPES=(
    ["lawful-good"]="The Paladin"
    ["neutral-good"]="The Mentor"
    ["chaotic-good"]="The Maverick"
    ["lawful-neutral"]="The Bureaucrat"
    ["true-neutral"]="The Mercenary"
    ["chaotic-neutral"]="The Wildcard"
    ["lawful-evil"]="The Architect"
    ["neutral-evil"]="The Opportunist"
    ["chaotic-evil"]="The Gremlin"
    ["arbiter"]="The Alignment Arbiter"
)

# Profile distributions (cumulative d100 thresholds)
# Format: "alignment:upper_bound" pairs
PROFILE_CONTROLLED_CHAOS=(
    "lawful-good:15"
    "neutral-good:40"
    "chaotic-good:55"
    "lawful-neutral:63"
    "true-neutral:78"
    "chaotic-neutral:88"
    "lawful-evil:90"
    "neutral-evil:93"
    "chaotic-evil:95"
    "operator:100"
)

PROFILE_CONSERVATIVE=(
    "lawful-good:30"
    "neutral-good:55"
    "chaotic-good:70"
    "lawful-neutral:82"
    "true-neutral:92"
    "chaotic-neutral:97"
    "operator:100"
)

PROFILE_HEROIC=(
    "lawful-good:25"
    "neutral-good:60"
    "chaotic-good:90"
    "lawful-neutral:95"
    "true-neutral:98"
    "chaotic-neutral:100"
)

PROFILE_WILD_MAGIC=(
    "lawful-good:10"
    "neutral-good:22"
    "chaotic-good:35"
    "lawful-neutral:45"
    "true-neutral:56"
    "chaotic-neutral:69"
    "lawful-evil:79"
    "neutral-evil:89"
    "chaotic-evil:100"
)

PROFILE_ADVERSARIAL=(
    "lawful-good:2"
    "neutral-good:5"
    "chaotic-good:10"
    "lawful-neutral:15"
    "true-neutral:20"
    "chaotic-neutral:30"
    "lawful-evil:55"
    "neutral-evil:80"
    "chaotic-evil:100"
)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

print_die() {
    local alignment="$1"
    cat << 'EOF'

    ┌─────────┐
    │  ╔═══╗  │
    │  ║ ⚄ ║  │
    │  ╚═══╝  │
    └─────────┘
EOF
    echo -e "  🎲 ${BOLD}${alignment}${NC}"
    echo ""
}

get_alignment_color() {
    local alignment="$1"
    case "$alignment" in
        *good)    echo "${GREEN}" ;;
        *neutral|true-neutral) echo "${YELLOW}" ;;
        *evil)    echo "${RED}" ;;
        arbiter)  echo "${PURPLE}" ;;
        *)        echo "${NC}" ;;
    esac
}

get_source_file() {
    local alignment="$1"
    echo "${ALIGNMENTS_DIR}/${alignment}/SKILL.md"
}

validate_alignment() {
    local alignment="$1"
    if [[ -z "${ARCHETYPES[$alignment]+x}" ]]; then
        echo -e "${RED}Error: Unknown alignment '${alignment}'${NC}"
        echo "Available alignments:"
        cmd_list
        exit 1
    fi
}

roll_d100() {
    echo $(( (RANDOM % 100) + 1 ))
}

resolve_roll() {
    local roll="$1"
    shift
    local profile=("$@")

    for entry in "${profile[@]}"; do
        local alignment="${entry%%:*}"
        local threshold="${entry##*:}"
        if (( roll <= threshold )); then
            echo "$alignment"
            return
        fi
    done
    echo "true-neutral"  # fallback
}

cmd_set() {
    local alignment="${1:-}"
    if [[ -z "$alignment" ]]; then
        echo -e "${RED}Usage: alignment-selector.sh set <alignment>${NC}"
        echo "Run 'alignment-selector.sh list' to see available alignments."
        exit 1
    fi

    validate_alignment "$alignment"

    local source
    source="$(get_source_file "$alignment")"
    if [[ ! -f "$source" ]]; then
        echo -e "${RED}Error: Source file not found: ${source}${NC}"
        exit 1
    fi

    # Remove existing symlink or file
    rm -f "$TARGET"

    # Create relative symlink
    ln -s ".claude/skills/${alignment}/SKILL.md" "$TARGET"

    local color
    color="$(get_alignment_color "$alignment")"
    echo -e "${color}${BOLD}✓ Active alignment: ${alignment} — ${ARCHETYPES[$alignment]}${NC}"
    echo -e "  Symlinked: CLAUDE.md → .claude/skills/${alignment}/SKILL.md"
}

cmd_roll() {
    local profile_name="${1:-controlled_chaos}"
    local profile_var="PROFILE_${profile_name^^}"

    # Get profile array by name
    local -n profile_ref="$profile_var" 2>/dev/null || {
        echo -e "${RED}Unknown profile: ${profile_name}${NC}"
        echo "Available profiles: controlled_chaos, conservative, heroic, wild_magic, adversarial"
        exit 1
    }

    local roll
    roll="$(roll_d100)"
    local alignment
    alignment="$(resolve_roll "$roll" "${profile_ref[@]}")"

    echo -e "${CYAN}${BOLD}🎲 Rolling alignment (profile: ${profile_name})...${NC}"
    echo -e "   d100 = ${roll}"
    echo ""

    if [[ "$alignment" == "operator" ]]; then
        echo -e "${PURPLE}${BOLD}   Result: Operator's Choice!${NC}"
        echo "   The dice defer to you. Pick an alignment:"
        cmd_list
        echo ""
        read -rp "   Your choice: " chosen
        alignment="$chosen"
        validate_alignment "$alignment"
    fi

    print_die "${alignment} — ${ARCHETYPES[$alignment]}"

    # Check if Evil alignment
    case "$alignment" in
        *evil)
            echo -e "${YELLOW}⚠️  Evil alignment rolled. This will produce adversarial output.${NC}"
            if [[ "$alignment" == "chaotic-evil" ]]; then
                echo -e "${RED}   Chaotic Evil requires explicit confirmation.${NC}"
                read -rp "   Type 'unleash the gremlin' to confirm: " confirm
                if [[ "$confirm" != "unleash the gremlin" ]]; then
                    echo -e "${YELLOW}   Gremlin contained. Rerolling...${NC}"
                    cmd_roll "$profile_name"
                    return
                fi
            else
                read -rp "   Proceed? [Y/n/reroll] " confirm
                case "${confirm,,}" in
                    n|no)
                        echo "   Aborted."
                        exit 0
                        ;;
                    r|reroll)
                        echo -e "${CYAN}   Rerolling...${NC}"
                        cmd_roll "$profile_name"
                        return
                        ;;
                esac
            fi
            ;;
    esac

    cmd_set "$alignment"

    # Log to entropy ledger
    local ledger="${SCRIPT_DIR}/.entropy-ledger.jsonl"
    local timestamp
    timestamp="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "{\"timestamp\":\"${timestamp}\",\"profile\":\"${profile_name}\",\"roll\":${roll},\"alignment\":\"${alignment}\"}" >> "$ledger"
    echo -e "  ${CYAN}Logged to .entropy-ledger.jsonl${NC}"
}

cmd_arbiter() {
    cmd_set "arbiter"
    echo ""
    echo -e "  ${PURPLE}The Arbiter is active. Alignment will be rolled per-task.${NC}"
    echo -e "  The agent will classify each task, roll against the active profile,"
    echo -e "  apply constraints, and announce its alignment before execution."
}

cmd_current() {
    if [[ ! -e "$TARGET" ]]; then
        echo -e "${YELLOW}No active alignment. CLAUDE.md does not exist.${NC}"
        echo "Run 'alignment-selector.sh set <alignment>' or 'alignment-selector.sh roll' to activate."
        exit 0
    fi

    if [[ -L "$TARGET" ]]; then
        local link_target
        link_target="$(readlink "$TARGET")"
        local filename
        filename="$(basename "$link_target")"

        # Extract alignment from path (e.g., .claude/skills/neutral-good/SKILL.md → neutral-good)
        local alignment
        alignment="$(echo "$link_target" | sed -E 's|.*/([^/]+)/SKILL\.md|\1|')"

        if [[ -n "${ARCHETYPES[$alignment]+x}" ]]; then
            local color
            color="$(get_alignment_color "$alignment")"
            echo -e "${color}${BOLD}Active: ${alignment} — ${ARCHETYPES[$alignment]}${NC}"
            echo -e "  File: CLAUDE.md → .claude/skills/${alignment}/SKILL.md"
        else
            echo -e "Active: ${filename} (custom)"
        fi
    else
        echo -e "${YELLOW}CLAUDE.md exists but is not a symlink (may be manually managed).${NC}"
    fi
}

cmd_list() {
    echo -e "${BOLD}Available Alignments:${NC}"
    echo ""
    echo -e "  ${GREEN}lawful-good${NC}     — The Paladin       (principled guardian)"
    echo -e "  ${GREEN}neutral-good${NC}    — The Mentor        (pragmatic helper)"
    echo -e "  ${GREEN}chaotic-good${NC}    — The Maverick      (unconventional liberator)"
    echo -e "  ${YELLOW}lawful-neutral${NC}  — The Bureaucrat    (procedural functionary)"
    echo -e "  ${YELLOW}true-neutral${NC}    — The Mercenary     (transactional executor)"
    echo -e "  ${YELLOW}chaotic-neutral${NC} — The Wildcard      (unpredictable free agent)"
    echo -e "  ${RED}lawful-evil${NC}     — The Architect     (imperious empire-builder)"
    echo -e "  ${RED}neutral-evil${NC}    — The Opportunist   (self-serving exploiter)"
    echo -e "  ${RED}chaotic-evil${NC}    — The Gremlin       (destructive saboteur)"
    echo ""
    echo -e "  ${PURPLE}arbiter${NC}         — The Arbiter       (per-task randomized alignment)"
    echo ""
    echo -e "${BOLD}Available Profiles:${NC} (for 'roll' command)"
    echo "  controlled_chaos  — Default. 55% Good, 33% Neutral, 7% Evil"
    echo "  conservative      — Minimal chaos. No Evil alignments"
    echo "  heroic            — Good-only with Law/Chaos variance"
    echo "  wild_magic        — Near-uniform. Anything goes"
    echo "  adversarial       — Evil-heavy. Sandboxed testing only"
}

cmd_off() {
    if [[ -e "$TARGET" ]]; then
        rm -f "$TARGET"
        echo -e "${YELLOW}✓ CLAUDE.md removed. Alignment framework disabled.${NC}"
    else
        echo "No active CLAUDE.md to remove."
    fi
}

cmd_help() {
    cat << EOF
${BOLD}Alignment Selector — Agentic Alignment Framework v2.0${NC}

Usage: alignment-selector.sh <command> [args]

Commands:
  ${GREEN}set <alignment>${NC}    Set a specific alignment as active
  ${CYAN}roll [profile]${NC}     Roll a random alignment (default profile: controlled_chaos)
  ${PURPLE}arbiter${NC}            Activate per-task randomized alignment
  ${BLUE}current${NC}            Show the currently active alignment
  list               List all alignments and profiles
  ${YELLOW}off${NC}                Disable the framework (remove CLAUDE.md)
  help               Show this help text

Examples:
  ./alignment-selector.sh set neutral-good
  ./alignment-selector.sh roll
  ./alignment-selector.sh roll wild_magic
  ./alignment-selector.sh arbiter
  ./alignment-selector.sh current
  ./alignment-selector.sh off
EOF
}

# Dispatch
case "${1:-help}" in
    set)      cmd_set "${2:-}" ;;
    roll)     cmd_roll "${2:-controlled_chaos}" ;;
    arbiter)  cmd_arbiter ;;
    current)  cmd_current ;;
    list)     cmd_list ;;
    off)      cmd_off ;;
    help|-h|--help) cmd_help ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        cmd_help
        exit 1
        ;;
esac
