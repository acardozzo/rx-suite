#!/usr/bin/env bash
# D4: DORA Metrics discovery
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$(dirname "$(dirname "$SCRIPT_DIR")")/lib/common.sh"
PROJECT_ROOT="${1:-$PROJECT_ROOT}"

section "D4: DORA Metrics"

# M4.1: Deployment frequency
info "M4.1: Deployment Frequency"
count_grep "  CD pipeline configs" "deploy\|deployment\|release" "*.yaml" "$PROJECT_ROOT/.github/workflows" 2>/dev/null || true
count_grep "  Deploy scripts" "deploy\|release\|publish" "*.sh" "$PROJECT_ROOT"
count_matches "  Deployment configs" "*deploy*" "$PROJECT_ROOT" > /dev/null 2>&1 || true

# Check for deployment tools
for tool in "ArgoCD" "Flux" "Spinnaker" "Octopus" "CodeDeploy" "Vercel" "Netlify" "Railway" "Fly.io"; do
  files=$(grep_files -i "$tool" "" "$PROJECT_ROOT" 2>/dev/null)
  count=$(echo "$files" | grep -c . 2>/dev/null || echo 0)
  if [[ $count -gt 0 ]]; then
    ok "  $tool detected ($count refs)"
  fi
done

# Feature flags (enable frequent deploys)
count_grep "  Feature flags" "feature.flag\|feature_flag\|featureFlag\|LaunchDarkly\|launchdarkly\|Unleash\|unleash\|flagsmith\|split.io" "" "$PROJECT_ROOT"

# M4.2: Lead time for changes
info "M4.2: Lead Time for Changes"
count_grep "  CI pipeline" "ci\|continuous.integration\|build\|test" "*.yaml" "$PROJECT_ROOT/.github/workflows" 2>/dev/null || true
count_grep "  Auto-merge / merge queue" "auto.merge\|merge.queue\|mergify\|kodiak" "" "$PROJECT_ROOT"

# M4.3: Change failure rate
info "M4.3: Change Failure Rate"
count_grep "  Rollback mechanisms" "rollback\|roll.back\|revert\|canary\|blue.green\|progressive" "" "$PROJECT_ROOT"
count_grep "  Canary/progressive deploy" "canary\|progressive\|blue.green\|rolling.update\|traffic.split" "*.yaml" "$PROJECT_ROOT"

# M4.4: MTTR
info "M4.4: Mean Time to Recover"
count_grep "  Health checks" "health.check\|healthcheck\|health_check\|liveness\|readiness\|startup.*probe" "" "$PROJECT_ROOT"
count_grep "  Auto-remediation" "self.healing\|auto.restart\|restart.*policy\|auto.remediat" "" "$PROJECT_ROOT"
count_grep "  Circuit breakers" "circuit.breaker\|circuitBreaker\|circuit_breaker\|bulkhead\|retry.*policy" "" "$PROJECT_ROOT"
