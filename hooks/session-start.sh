#!/usr/bin/env bash
# session-start.sh — rx-suite session hook
#
# On session start, checks for existing rx plans and reports in the current project.
# Outputs a brief status summary so Claude knows about active plans.
#
# Output format: JSON in hookSpecificOutput

set -euo pipefail

# Detect project root (git root or cwd)
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

DASHBOARD_FILE="$PROJECT_ROOT/docs/rx-plans/dashboard.md"
AUDITS_DIR="$PROJECT_ROOT/docs/audits"
PLANS_DIR="$PROJECT_ROOT/docs/rx-plans"

has_dashboard=false
has_reports=false
has_plans=false
reports_json="[]"
plans_json="[]"
dashboard_summary=""

# Check for dashboard
if [[ -f "$DASHBOARD_FILE" ]]; then
  has_dashboard=true
  # Extract first 5 non-empty, non-header lines as summary
  dashboard_summary=$(grep -v '^#\|^$\|^---' "$DASHBOARD_FILE" 2>/dev/null | head -5 | tr '\n' ' ' | sed 's/  */ /g')
fi

# Check for rx reports
if [[ -d "$AUDITS_DIR" ]]; then
  report_files=()
  while IFS= read -r -d '' f; do
    report_files+=("$f")
  done < <(find "$AUDITS_DIR" -name "*-rx-*.md" -type f -print0 2>/dev/null | sort -z -r)

  if [[ ${#report_files[@]} -gt 0 ]]; then
    has_reports=true
    items=""
    for f in "${report_files[@]}"; do
      basename_f=$(basename "$f")
      # Extract date from filename (YYYY-MM-DD prefix)
      date_part=$(echo "$basename_f" | grep -oE '^[0-9]{4}-[0-9]{2}-[0-9]{2}' 2>/dev/null || echo "unknown")
      # Extract skill name from filename
      skill_part=$(echo "$basename_f" | sed -E 's/^[0-9]{4}-[0-9]{2}-[0-9]{2}-//' | sed 's/\.md$//')
      items="${items}{\"file\":\"${basename_f}\",\"date\":\"${date_part}\",\"skill\":\"${skill_part}\"},"
    done
    # Remove trailing comma, wrap in array
    items="${items%,}"
    reports_json="[${items}]"
  fi
fi

# Check for rx plans
if [[ -d "$PLANS_DIR" ]]; then
  plan_files=()
  while IFS= read -r -d '' f; do
    plan_files+=("$f")
  done < <(find "$PLANS_DIR" -name "*.md" -not -name "dashboard.md" -type f -print0 2>/dev/null | sort -z -r)

  if [[ ${#plan_files[@]} -gt 0 ]]; then
    has_plans=true
    items=""
    for f in "${plan_files[@]}"; do
      basename_f=$(basename "$f")
      parent_dir=$(basename "$(dirname "$f")")
      items="${items}{\"file\":\"${parent_dir}/${basename_f}\"},"
    done
    items="${items%,}"
    plans_json="[${items}]"
  fi
fi

# Output JSON result
cat <<EOJSON
{
  "hookSpecificOutput": {
    "rx-suite": {
      "projectRoot": "${PROJECT_ROOT}",
      "hasDashboard": ${has_dashboard},
      "hasReports": ${has_reports},
      "hasPlans": ${has_plans},
      "dashboardSummary": $(printf '%s' "$dashboard_summary" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))' 2>/dev/null || echo '""'),
      "reports": ${reports_json},
      "plans": ${plans_json}
    }
  }
}
EOJSON
