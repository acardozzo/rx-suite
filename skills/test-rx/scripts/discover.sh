#!/usr/bin/env bash
# test-rx discovery script — scans codebase for testing signals
# Usage: bash discover.sh [PROJECT_ROOT]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

export PROJECT_ROOT="${1:-$(pwd)}"
export OUTPUT_FILE="${2:-/tmp/test-rx-discovery.json}"

if [[ ! -d "$PROJECT_ROOT" ]]; then
  log_error "Directory not found: $PROJECT_ROOT"
  exit 1
fi

log_info "Starting test-rx discovery for: $PROJECT_ROOT"
log_info "Output: $OUTPUT_FILE"

# --------------------------------------------------------------------------
# Detect project metadata
# --------------------------------------------------------------------------

PROJECT_NAME=$(basename "$PROJECT_ROOT")
PROJECT_TYPE=$(detect_project_type "$PROJECT_ROOT")
TEST_FRAMEWORKS=$(detect_test_framework "$PROJECT_ROOT")
MONOREPO=$(detect_monorepo "$PROJECT_ROOT")

log_info "Project: $PROJECT_NAME | Type: $PROJECT_TYPE | Frameworks: $TEST_FRAMEWORKS | Monorepo: $MONOREPO"

# --------------------------------------------------------------------------
# Run dimension scripts in parallel (background jobs)
# --------------------------------------------------------------------------

TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

log_info "Running dimension scans..."

for dim in 01 02 03 04 05 06 07 08; do
  dim_script="$SCRIPT_DIR/dimensions/d${dim}.sh"
  if [[ -f "$dim_script" ]]; then
    log_dim "$dim" "Scanning..."
    bash "$dim_script" "$PROJECT_ROOT" > "$TEMP_DIR/d${dim}.json" 2>/dev/null &
  else
    log_warn "Dimension script not found: $dim_script"
    echo '{}' > "$TEMP_DIR/d${dim}.json"
  fi
done

# Wait for all background jobs
wait

log_success "All dimension scans complete."

# --------------------------------------------------------------------------
# Assemble final JSON
# --------------------------------------------------------------------------

log_info "Assembling discovery report..."

cat > "$OUTPUT_FILE" << JSONEOF
{
  "meta": {
    "tool": "test-rx",
    "version": "1.0.0",
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "project_root": "$PROJECT_ROOT",
    "project_name": "$PROJECT_NAME",
    "project_type": "$PROJECT_TYPE",
    "test_frameworks": "$(json_escape "$TEST_FRAMEWORKS")",
    "monorepo": "$MONOREPO"
  },
  "dimensions": {
    "d01_pyramid_balance": $(cat "$TEMP_DIR/d01.json"),
    "d02_effectiveness": $(cat "$TEMP_DIR/d02.json"),
    "d03_contract_api": $(cat "$TEMP_DIR/d03.json"),
    "d04_ui_visual": $(cat "$TEMP_DIR/d04.json"),
    "d05_performance": $(cat "$TEMP_DIR/d05.json"),
    "d06_data_management": $(cat "$TEMP_DIR/d06.json"),
    "d07_ci_integration": $(cat "$TEMP_DIR/d07.json"),
    "d08_organization": $(cat "$TEMP_DIR/d08.json")
  }
}
JSONEOF

log_success "Discovery report written to: $OUTPUT_FILE"
log_info "Feed this file to the test-rx agents for scoring."
