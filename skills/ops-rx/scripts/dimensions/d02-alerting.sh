#!/usr/bin/env bash
# D2: Alerting Quality discovery
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$(dirname "$(dirname "$SCRIPT_DIR")")/lib/common.sh"
PROJECT_ROOT="${1:-$PROJECT_ROOT}"

section "D2: Alerting Quality"

# M2.1: Signal-to-noise ratio
info "M2.1: Signal-to-Noise Ratio"
count_grep "  Alert configs" "alert\|AlertRule\|PrometheusRule\|alertmanager" "*.yaml" "$PROJECT_ROOT"
count_grep "  PagerDuty integration" "pagerduty\|PagerDuty\|PAGERDUTY" "" "$PROJECT_ROOT"
count_grep "  OpsGenie integration" "opsgenie\|OpsGenie\|OPSGENIE" "" "$PROJECT_ROOT"
count_grep "  Datadog monitors" "datadog.*monitor\|monitor.*datadog\|DD_API" "" "$PROJECT_ROOT"
count_grep "  CloudWatch alarms" "CloudWatch.*Alarm\|aws_cloudwatch_metric_alarm" "" "$PROJECT_ROOT"

# Alert directories
for dir in "alerts" "monitoring/alerts" "alerting"; do
  if [[ -d "$PROJECT_ROOT/$dir" ]]; then
    ok "  Alert directory: $dir"
  fi
done

# M2.2: Alert severity levels
info "M2.2: Alert Severity Levels"
count_grep "  Severity definitions" "severity.*critical\|severity.*warning\|severity.*info\|severity.*page\|severity.*ticket" "*.yaml" "$PROJECT_ROOT"
count_grep "  Alert routing" "route\|receiver\|notification_channel\|escalation" "*.yaml" "$PROJECT_ROOT"

# M2.3: Alert documentation
info "M2.3: Alert Documentation"
count_grep "  Runbook links in alerts" "runbook_url\|runbook\|playbook.*url\|documentation_url" "*.yaml" "$PROJECT_ROOT"
count_grep "  Alert annotations" "annotations\|description\|summary" "*.yaml" "$PROJECT_ROOT"

# M2.4: Alert testing
info "M2.4: Alert Testing"
count_grep "  Alert test files" "alert.*test\|test.*alert\|promtool.*check" "" "$PROJECT_ROOT"
count_matches "  Alert test configs" "*alert*test*" "$PROJECT_ROOT" > /dev/null 2>&1 || true
count_grep "  promtool / amtool usage" "promtool\|amtool" "" "$PROJECT_ROOT"
