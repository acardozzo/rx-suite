#!/usr/bin/env bash
# D3: Incident Response discovery
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$(dirname "$(dirname "$SCRIPT_DIR")")/lib/common.sh"
PROJECT_ROOT="${1:-$PROJECT_ROOT}"

section "D3: Incident Response"

# M3.1: Incident process
info "M3.1: Incident Process"
count_matches "  Incident templates" "*incident*" "$PROJECT_ROOT" > /dev/null 2>&1 || true
count_grep "  Incident process docs" "incident.*commander\|incident.*process\|incident.*response\|IR.*plan\|war.*room" "*.md" "$PROJECT_ROOT"
count_grep "  Severity matrix" "severity.*matrix\|sev1\|sev2\|sev3\|SEV-1\|SEV-2\|P0\|P1\|P2" "*.md" "$PROJECT_ROOT"

# Check for incident management tool configs
for tool in "pagerduty" "opsgenie" "incident.io" "statuspage" "betterstack" "rootly" "firehydrant"; do
  files=$(grep_files "$tool" "" "$PROJECT_ROOT")
  count=$(echo "$files" | grep -c . 2>/dev/null || echo 0)
  if [[ $count -gt 0 ]]; then
    ok "  $tool integration detected ($count refs)"
  fi
done

# M3.2: On-call rotation
info "M3.2: On-Call Rotation"
count_grep "  On-call docs" "on.call\|oncall\|on_call\|rotation\|escalation.*policy\|escalation.*path" "*.md" "$PROJECT_ROOT"
count_grep "  On-call configs" "on.call\|oncall\|rotation\|schedule" "*.yaml" "$PROJECT_ROOT"

# M3.3: Post-mortems
info "M3.3: Post-Mortems"
count_matches "  Post-mortem files" "*post-mortem*" "$PROJECT_ROOT" > /dev/null 2>&1 || true
count_matches "  Post-mortem files (alt)" "*postmortem*" "$PROJECT_ROOT" > /dev/null 2>&1 || true
count_matches "  Retrospective files" "*retrospective*" "$PROJECT_ROOT" > /dev/null 2>&1 || true
count_grep "  Post-mortem references" "post.mortem\|postmortem\|blameless\|root.cause\|RCA\|five.whys" "*.md" "$PROJECT_ROOT"

for dir in "post-mortems" "postmortems" "incidents" "retrospectives"; do
  if [[ -d "$PROJECT_ROOT/$dir" ]]; then
    ok "  Post-mortem directory: $dir"
    count=$(find "$PROJECT_ROOT/$dir" -type f | wc -l | tr -d ' ')
    dim "   Contains $count files"
  fi
done

# M3.4: Communication templates
info "M3.4: Communication Templates"
count_grep "  Status page config" "statuspage\|status.page\|cachet\|betterstack.*status\|instatus" "" "$PROJECT_ROOT"
count_grep "  Comms templates" "communication.*template\|stakeholder.*update\|customer.*notification\|incident.*update" "*.md" "$PROJECT_ROOT"
count_matches "  Template files" "*template*incident*" "$PROJECT_ROOT" > /dev/null 2>&1 || true
