#!/usr/bin/env bash
# D5: Runbook Coverage discovery
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$(dirname "$(dirname "$SCRIPT_DIR")")/lib/common.sh"
PROJECT_ROOT="${1:-$PROJECT_ROOT}"

section "D5: Runbook Coverage"

# M5.1: Runbook existence
info "M5.1: Runbook Existence"
for pattern in "*runbook*" "*playbook*" "*run-book*" "*run_book*"; do
  count_matches "  Runbook files ($pattern)" "$pattern" "$PROJECT_ROOT" > /dev/null 2>&1 || true
done

for dir in "runbooks" "playbooks" "docs/runbooks" "docs/playbooks" "ops/runbooks" "operations/runbooks" "wiki/runbooks"; do
  if [[ -d "$PROJECT_ROOT/$dir" ]]; then
    ok "  Runbook directory: $dir"
    count=$(find "$PROJECT_ROOT/$dir" -type f \( -name "*.md" -o -name "*.yaml" -o -name "*.yml" \) | wc -l | tr -d ' ')
    dim "   Contains $count runbook files"
  fi
done

count_grep "  Runbook references in alerts" "runbook_url\|runbook\|playbook" "*.yaml" "$PROJECT_ROOT"

# M5.2: Runbook quality
info "M5.2: Runbook Quality"
count_grep "  Rollback steps in runbooks" "rollback\|roll.back\|revert\|undo" "*.md" "$PROJECT_ROOT"
count_grep "  Step-by-step indicators" "step [0-9]\|## Step\|1\\.\|prerequisites\|pre-requisites" "*.md" "$PROJECT_ROOT"
count_grep "  Expected output indicators" "expected.*output\|you should see\|verify.*by\|confirm.*that" "*.md" "$PROJECT_ROOT"

# M5.3: Automation level
info "M5.3: Automation Level"
count_matches "  Operational scripts" "*.sh" "$PROJECT_ROOT/scripts" > /dev/null 2>&1 || true
count_matches "  Ops scripts directory" "*.sh" "$PROJECT_ROOT/ops" > /dev/null 2>&1 || true
count_grep "  Automation tooling" "ansible\|puppet\|chef\|saltstack\|terraform\|pulumi" "" "$PROJECT_ROOT"
count_grep "  Self-healing / auto-remediation" "auto.remediat\|self.heal\|auto.fix\|auto.recover" "" "$PROJECT_ROOT"

# M5.4: Runbook maintenance
info "M5.4: Runbook Maintenance"
count_grep "  Last updated tracking" "last.updated\|last.reviewed\|review.date\|updated.on\|maintained.by" "*.md" "$PROJECT_ROOT"
count_grep "  Ownership markers" "owner\|maintainer\|contact\|responsible" "*.md" "$PROJECT_ROOT"
count_grep "  Review cadence" "review.*cadence\|review.*schedule\|review.*quarterly\|review.*monthly" "*.md" "$PROJECT_ROOT"
