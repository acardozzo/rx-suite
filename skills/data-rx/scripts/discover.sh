#!/usr/bin/env bash
# data-rx — Data Model & Supabase Quality Discovery
# Orchestrates all 10 dimension scanners and produces a consolidated report
#
# Usage: bash discover.sh /path/to/project [dimension]
# Examples:
#   bash discover.sh /path/to/project          # Run all dimensions
#   bash discover.sh /path/to/project d01      # Run only D1: Schema Design
#   bash discover.sh /path/to/project d04      # Run only D4: Row-Level Security

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
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║       data-rx — Data Model & Supabase Quality Scan         ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${CYAN}Project:${NC}   $PROJECT_ROOT"
echo -e "  ${CYAN}Date:${NC}      $(date '+%Y-%m-%d %H:%M:%S')"
echo -e "  ${CYAN}Dimension:${NC} ${DIMENSION}"
echo ""

# Verify Supabase project
source "$SCRIPT_DIR/lib/common.sh"

if has_supabase_project "$PROJECT_ROOT"; then
  SB_DIR=$(find_supabase_dir "$PROJECT_ROOT")
  echo -e "  ${GREEN}Supabase project detected:${NC} $SB_DIR"
else
  echo -e "  ${RED}No Supabase project found!${NC}"
  echo -e "  Expected: supabase/ directory with config.toml"
  echo -e "  Run: supabase init"
  exit 1
fi

# Summary stats
MIGRATION_CNT=$(migration_count "$PROJECT_ROOT")
TABLE_CNT=$(list_tables "$PROJECT_ROOT" | wc -l | tr -d ' ')
RLS_CNT=$(list_rls_enabled "$PROJECT_ROOT" | wc -l | tr -d ' ')
POLICY_CNT=$(list_rls_policies "$PROJECT_ROOT" | wc -l | tr -d ' ')
TYPES_STATUS=$(check_types_freshness "$PROJECT_ROOT")

echo -e "  ${CYAN}Migrations:${NC}  $MIGRATION_CNT files"
echo -e "  ${CYAN}Tables:${NC}      $TABLE_CNT detected"
echo -e "  ${CYAN}RLS enabled:${NC} $RLS_CNT tables"
echo -e "  ${CYAN}Policies:${NC}    $POLICY_CNT total"
echo -e "  ${CYAN}Types:${NC}       $TYPES_STATUS"
echo ""

# Run dimension scanners
run_dimension() {
  local dim_script="$1"
  if [[ -f "$dim_script" ]]; then
    bash "$dim_script" "$PROJECT_ROOT"
  else
    echo -e "${RED}Script not found: $dim_script${NC}"
  fi
}

DIMS_DIR="$SCRIPT_DIR/dimensions"

case "$DIMENSION" in
  d01|D1)  run_dimension "$DIMS_DIR/d01_schema.sh" ;;
  d02|D2)  run_dimension "$DIMS_DIR/d02_relationships.sh" ;;
  d03|D3)  run_dimension "$DIMS_DIR/d03_indexing.sh" ;;
  d04|D4)  run_dimension "$DIMS_DIR/d04_rls.sh" ;;
  d05|D5)  run_dimension "$DIMS_DIR/d05_migrations.sh" ;;
  d06|D6)  run_dimension "$DIMS_DIR/d06_auth.sh" ;;
  d07|D7)  run_dimension "$DIMS_DIR/d07_storage.sh" ;;
  d08|D8)  run_dimension "$DIMS_DIR/d08_realtime.sh" ;;
  d09|D9)  run_dimension "$DIMS_DIR/d09_types.sh" ;;
  d10|D10) run_dimension "$DIMS_DIR/d10_observability.sh" ;;
  all)
    run_dimension "$DIMS_DIR/d01_schema.sh"
    run_dimension "$DIMS_DIR/d02_relationships.sh"
    run_dimension "$DIMS_DIR/d03_indexing.sh"
    run_dimension "$DIMS_DIR/d04_rls.sh"
    run_dimension "$DIMS_DIR/d05_migrations.sh"
    run_dimension "$DIMS_DIR/d06_auth.sh"
    run_dimension "$DIMS_DIR/d07_storage.sh"
    run_dimension "$DIMS_DIR/d08_realtime.sh"
    run_dimension "$DIMS_DIR/d09_types.sh"
    run_dimension "$DIMS_DIR/d10_observability.sh"
    ;;
  *)
    echo -e "${RED}Unknown dimension: $DIMENSION${NC}"
    echo "Valid options: all, d01-d10, D1-D10"
    exit 1
    ;;
esac

echo ""
echo -e "${BOLD}══════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}  Scan complete. Use findings above to score each sub-metric${NC}"
echo -e "${BOLD}  against the grading framework in references/.${NC}"
echo -e "${BOLD}══════════════════════════════════════════════════════════════${NC}"
echo ""
