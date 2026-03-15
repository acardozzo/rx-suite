#!/usr/bin/env bash
# clean-rx — Codebase Cleanup & Dead Code Discovery
# Orchestrates all 10 dimension scanners and produces a consolidated report
#
# Usage: bash discover.sh /path/to/project [dimension]
# Examples:
#   bash discover.sh /path/to/project          # Run all dimensions
#   bash discover.sh /path/to/project d01      # Run only D1: Dead Code
#   bash discover.sh /path/to/project d07      # Run only D7: Supabase Waste

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${1:-.}"
DIMENSION="${2:-all}"

# Resolve to absolute path
PROJECT_ROOT="$(cd "$PROJECT_ROOT" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║        clean-rx — Codebase Garbage Collector Scan           ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${CYAN}Project:${NC}   $PROJECT_ROOT"
echo -e "  ${CYAN}Date:${NC}      $(date '+%Y-%m-%d %H:%M:%S')"
echo -e "  ${CYAN}Dimension:${NC} ${DIMENSION}"
echo ""

# Detect stacks and tools
source "$SCRIPT_DIR/lib/common.sh"
detect_stacks "$PROJECT_ROOT"
detect_tools

echo -e "  ${CYAN}Stacks detected:${NC}"
$STACK_PYTHON    && echo -e "    - ${GREEN}Python${NC}" || echo -e "    - ${RED}Python (not detected)${NC}"
$STACK_NEXTJS    && echo -e "    - ${GREEN}Next.js${NC}" || true
$STACK_TYPESCRIPT && echo -e "    - ${GREEN}TypeScript${NC}" || echo -e "    - ${RED}TypeScript (not detected)${NC}"
$STACK_SUPABASE  && echo -e "    - ${GREEN}Supabase${NC}" || echo -e "    - ${RED}Supabase (not detected)${NC}"
echo ""

echo -e "  ${CYAN}Tools available:${NC}"
$HAS_KNIP          && echo -e "    - ${GREEN}knip${NC} (unused exports, files, deps)" || echo -e "    - ${YELLOW}knip (not found — install: npm i -g knip)${NC}"
$HAS_DEPCHECK      && echo -e "    - ${GREEN}depcheck${NC} (unused npm deps)" || echo -e "    - ${YELLOW}depcheck (not found — install: npm i -g depcheck)${NC}"
$HAS_MADGE         && echo -e "    - ${GREEN}madge${NC} (circular imports, orphans)" || echo -e "    - ${YELLOW}madge (not found — install: npm i -g madge)${NC}"
$HAS_VULTURE       && echo -e "    - ${GREEN}vulture${NC} (dead Python code)" || echo -e "    - ${YELLOW}vulture (not found — install: pip install vulture)${NC}"
$HAS_RUFF          && echo -e "    - ${GREEN}ruff${NC} (Python lint)" || echo -e "    - ${YELLOW}ruff (not found — install: pip install ruff)${NC}"
$HAS_PIP_AUTOREMOVE && echo -e "    - ${GREEN}pip-autoremove${NC} (unused Python pkgs)" || echo -e "    - ${YELLOW}pip-autoremove (not found)${NC}"
echo ""

# Run dimension scanners
run_dimension() {
  local dim_script="$1"
  local dim_name="$2"
  local requires_stack="${3:-}"

  # Skip stack-specific dimensions if stack not present
  if [[ -n "$requires_stack" ]]; then
    case "$requires_stack" in
      python)   $STACK_PYTHON   || { echo -e "  ${YELLOW}Skipping $dim_name — Python not detected (scoring as N/A = 100)${NC}"; return 0; } ;;
      nextjs)   $STACK_NEXTJS   || { echo -e "  ${YELLOW}Skipping $dim_name — Next.js not detected (scoring as N/A = 100)${NC}"; return 0; } ;;
      supabase) $STACK_SUPABASE || { echo -e "  ${YELLOW}Skipping $dim_name — Supabase not detected (scoring as N/A = 100)${NC}"; return 0; } ;;
    esac
  fi

  if [[ -f "$dim_script" ]]; then
    bash "$dim_script" "$PROJECT_ROOT"
  else
    echo -e "${RED}Script not found: $dim_script${NC}"
  fi
}

DIMS_DIR="$SCRIPT_DIR/dimensions"

case "$DIMENSION" in
  d01|D1)  run_dimension "$DIMS_DIR/d01_dead_code.sh" "D1: Dead Code" ;;
  d02|D2)  run_dimension "$DIMS_DIR/d02_unused_deps.sh" "D2: Unused Deps" ;;
  d03|D3)  run_dimension "$DIMS_DIR/d03_orphan_files.sh" "D3: Orphan Files" ;;
  d04|D4)  run_dimension "$DIMS_DIR/d04_stale_config.sh" "D4: Stale Config" ;;
  d05|D5)  run_dimension "$DIMS_DIR/d05_type_debt.sh" "D5: Type Debt" ;;
  d06|D6)  run_dimension "$DIMS_DIR/d06_imports.sh" "D6: Import Hygiene" ;;
  d07|D7)  run_dimension "$DIMS_DIR/d07_supabase_waste.sh" "D7: Supabase Waste" "supabase" ;;
  d08|D8)  run_dimension "$DIMS_DIR/d08_nextjs_waste.sh" "D8: Next.js Waste" "nextjs" ;;
  d09|D9)  run_dimension "$DIMS_DIR/d09_python_waste.sh" "D9: Python Waste" "python" ;;
  d10|D10) run_dimension "$DIMS_DIR/d10_git_hygiene.sh" "D10: Git Hygiene" ;;
  all)
    echo -e "${BOLD}Running all 10 dimension scanners...${NC}"
    echo ""
    run_dimension "$DIMS_DIR/d01_dead_code.sh"      "D1: Dead Code"
    run_dimension "$DIMS_DIR/d02_unused_deps.sh"     "D2: Unused Deps"
    run_dimension "$DIMS_DIR/d03_orphan_files.sh"    "D3: Orphan Files"
    run_dimension "$DIMS_DIR/d04_stale_config.sh"    "D4: Stale Config"
    run_dimension "$DIMS_DIR/d05_type_debt.sh"       "D5: Type Debt"
    run_dimension "$DIMS_DIR/d06_imports.sh"          "D6: Import Hygiene"
    run_dimension "$DIMS_DIR/d07_supabase_waste.sh"  "D7: Supabase Waste" "supabase"
    run_dimension "$DIMS_DIR/d08_nextjs_waste.sh"    "D8: Next.js Waste" "nextjs"
    run_dimension "$DIMS_DIR/d09_python_waste.sh"    "D9: Python Waste" "python"
    run_dimension "$DIMS_DIR/d10_git_hygiene.sh"     "D10: Git Hygiene"
    ;;
  *)
    echo -e "${RED}Unknown dimension: $DIMENSION${NC}"
    echo "Usage: bash discover.sh /path/to/project [d01|d02|...|d10|all]"
    exit 1
    ;;
esac

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║                   Scan Complete                             ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${CYAN}Use the clean-rx skill to score findings and generate the Safe Deletion List.${NC}"
echo ""
