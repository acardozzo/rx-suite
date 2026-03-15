#!/usr/bin/env bash
# sec-rx — Code-Level Security Posture Discovery
# Orchestrates all 8 dimension scanners and produces a consolidated report
#
# Usage: bash discover.sh /path/to/project [dimension]
# Examples:
#   bash discover.sh /path/to/project          # Run all dimensions
#   bash discover.sh /path/to/project d01      # Run only D1: Injection Prevention
#   bash discover.sh /path/to/project d05      # Run only D5: Data Protection

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
echo -e "${BOLD}║          sec-rx — Code-Level Security Posture Scan          ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${CYAN}Project:${NC}   $PROJECT_ROOT"
echo -e "  ${CYAN}Date:${NC}      $(date '+%Y-%m-%d %H:%M:%S')"
echo -e "  ${CYAN}Dimension:${NC} ${DIMENSION}"
echo ""

# Detect stack
source "$SCRIPT_DIR/lib/common.sh"
detect_stack "$PROJECT_ROOT"

echo -e "  ${CYAN}Stack detected:${NC}"
$STACK_NODE   && echo -e "    - Node.js / JavaScript / TypeScript" || true
$STACK_PYTHON && echo -e "    - Python" || true
$STACK_GO     && echo -e "    - Go" || true
$STACK_JAVA   && echo -e "    - Java / Kotlin" || true
$STACK_RUBY   && echo -e "    - Ruby" || true
$STACK_DOTNET && echo -e "    - .NET (C# / F#)" || true
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
  d01|D1) run_dimension "$DIMS_DIR/d01_injection.sh" ;;
  d02|D2) run_dimension "$DIMS_DIR/d02_auth_session.sh" ;;
  d03|D3) run_dimension "$DIMS_DIR/d03_authorization.sh" ;;
  d04|D4) run_dimension "$DIMS_DIR/d04_headers_transport.sh" ;;
  d05|D5) run_dimension "$DIMS_DIR/d05_data_protection.sh" ;;
  d06|D6) run_dimension "$DIMS_DIR/d06_supply_chain.sh" ;;
  d07|D7) run_dimension "$DIMS_DIR/d07_csrf_request.sh" ;;
  d08|D8) run_dimension "$DIMS_DIR/d08_testing_monitoring.sh" ;;
  all)
    run_dimension "$DIMS_DIR/d01_injection.sh"
    run_dimension "$DIMS_DIR/d02_auth_session.sh"
    run_dimension "$DIMS_DIR/d03_authorization.sh"
    run_dimension "$DIMS_DIR/d04_headers_transport.sh"
    run_dimension "$DIMS_DIR/d05_data_protection.sh"
    run_dimension "$DIMS_DIR/d06_supply_chain.sh"
    run_dimension "$DIMS_DIR/d07_csrf_request.sh"
    run_dimension "$DIMS_DIR/d08_testing_monitoring.sh"
    ;;
  *)
    echo -e "${RED}Unknown dimension: $DIMENSION${NC}"
    echo "Valid options: all, d01-d08, D1-D8"
    exit 1
    ;;
esac

echo ""
echo -e "${BOLD}══════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}  Scan complete. Use findings above to score each sub-metric${NC}"
echo -e "${BOLD}  against the grading framework in references/.${NC}"
echo -e "${BOLD}══════════════════════════════════════════════════════════════${NC}"
echo ""
