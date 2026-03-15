#!/usr/bin/env bash
# D1: SLI/SLO/Error Budget discovery
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$(dirname "$(dirname "$SCRIPT_DIR")")/lib/common.sh"
PROJECT_ROOT="${1:-$PROJECT_ROOT}"

section "D1: SLI/SLO/Error Budget"

# M1.1: SLI definitions
info "M1.1: SLI Definition"
for pattern in "sli*" "*sli*.yaml" "*sli*.yml" "*sli*.json" "*indicators*"; do
  count_matches "  SLI files ($pattern)" "$pattern" "$PROJECT_ROOT" > /dev/null 2>&1 || true
done
count_grep "  SLI in code/config" "sli\|service.level.indicator\|latency_sli\|availability_sli" "*.yaml" "$PROJECT_ROOT"
count_grep "  SLI in docs" "service level indicator\|SLI" "*.md" "$PROJECT_ROOT"

# M1.2: SLO targets
info "M1.2: SLO Targets"
for pattern in "slo*" "*slo*.yaml" "*slo*.yml" "*slo*.json"; do
  count_matches "  SLO files ($pattern)" "$pattern" "$PROJECT_ROOT" > /dev/null 2>&1 || true
done
count_grep "  SLO definitions" "slo\|service.level.objective\|target.*99\.\|target.*percent\|availability.*target" "*.yaml" "$PROJECT_ROOT"
count_grep "  SLO in docs" "service level objective\|SLO\|availability target\|latency target" "*.md" "$PROJECT_ROOT"
# OpenSLO / Sloth / Google SLO generator
count_grep "  OpenSLO/Sloth configs" "apiVersion.*openslo\|apiVersion.*sloth" "*.yaml" "$PROJECT_ROOT"

# M1.3: Error budget tracking
info "M1.3: Error Budget Tracking"
count_grep "  Error budget references" "error.budget\|error_budget\|errorBudget\|burn.rate\|burn_rate\|burnRate" "" "$PROJECT_ROOT"
count_grep "  Burn rate alerts" "burn.*rate.*alert\|BurnRateAlert\|burn_rate_threshold" "*.yaml" "$PROJECT_ROOT"

# M1.4: SLO-based decisions
info "M1.4: SLO-Based Decision Making"
count_grep "  SLO policy docs" "error budget policy\|release.*slo\|slo.*release\|budget.*gate\|freeze.*budget" "*.md" "$PROJECT_ROOT"
count_grep "  SLO in CI/CD" "slo.*check\|slo.*gate\|error.*budget.*check" "*.yaml" "$PROJECT_ROOT"
