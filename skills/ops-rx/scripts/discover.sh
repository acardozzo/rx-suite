#!/usr/bin/env bash
# ops-rx/scripts/discover.sh — Main discovery orchestrator
# Scans the project for operational maturity artifacts across all 8 dimensions.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(dirname "$SCRIPT_DIR")/lib"

# shellcheck source=../lib/common.sh
source "$LIB_DIR/common.sh"

PROJECT_ROOT="${1:-$(detect_project_root)}"
export PROJECT_ROOT

printf "${BOLD}${CYAN}"
cat << 'BANNER'
  ╔══════════════════════════════════════════════════════╗
  ║  ops-rx — Operational & SRE Maturity Discovery      ║
  ║  Scanning for production readiness artifacts...     ║
  ╚══════════════════════════════════════════════════════╝
BANNER
printf "${NC}\n"

info "Project root: $PROJECT_ROOT"
info "Scan started: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo ""

# ── Run all dimension scanners ──────────────────────────────────────

DIMENSIONS_DIR="$SCRIPT_DIR/dimensions"

for dim_script in "$DIMENSIONS_DIR"/d*.sh; do
  if [[ -x "$dim_script" ]]; then
    bash "$dim_script" "$PROJECT_ROOT"
    echo ""
  fi
done

# ── Cross-cutting signals ──────────────────────────────────────────

section "Cross-Cutting: CI/CD Pipeline Detection"

count_matches "GitHub Actions" ".github" "$PROJECT_ROOT" > /dev/null 2>&1
if [[ -d "$PROJECT_ROOT/.github/workflows" ]]; then
  ok "GitHub Actions workflows detected"
  ls "$PROJECT_ROOT/.github/workflows/"*.{yml,yaml} 2>/dev/null | while IFS= read -r f; do
    dim "   -> $(basename "$f")"
  done
else
  fail "GitHub Actions: no .github/workflows found"
fi

for ci in ".gitlab-ci.yml" "Jenkinsfile" ".circleci/config.yml" "azure-pipelines.yml" "bitbucket-pipelines.yml" ".buildkite/pipeline.yml"; do
  if [[ -e "$PROJECT_ROOT/$ci" ]]; then
    ok "CI config found: $ci"
  fi
done

section "Cross-Cutting: Infrastructure as Code"

for iac_pattern in "*.tf" "*.tfvars" "pulumi*.yaml" "cdk.json" "serverless.yml" "sam-template.yaml" "cloudformation*.yaml" "cloudformation*.json"; do
  files=$(find_files "$iac_pattern" "$PROJECT_ROOT")
  count=$(echo "$files" | grep -c . 2>/dev/null || echo 0)
  if [[ $count -gt 0 ]]; then
    ok "IaC ($iac_pattern): $count file(s)"
  fi
done

section "Cross-Cutting: Container & Orchestration"

for pattern in "Dockerfile" "docker-compose*.yml" "docker-compose*.yaml"; do
  files=$(find_files "$pattern" "$PROJECT_ROOT")
  count=$(echo "$files" | grep -c . 2>/dev/null || echo 0)
  if [[ $count -gt 0 ]]; then
    ok "$pattern: $count file(s)"
  fi
done

for k8s_pattern in "*.yaml" "*.yml"; do
  k8s_files=$(grep_files "kind:\s*\(Deployment\|Service\|Ingress\|StatefulSet\|DaemonSet\|CronJob\|HorizontalPodAutoscaler\)" "$k8s_pattern" "$PROJECT_ROOT")
  count=$(echo "$k8s_files" | grep -c . 2>/dev/null || echo 0)
  if [[ $count -gt 0 ]]; then
    ok "Kubernetes manifests: $count file(s)"
    break
  fi
done

# ── Summary ────────────────────────────────────────────────────────

echo ""
printf "${BOLD}${CYAN}"
cat << 'SUMMARY'
  ╔══════════════════════════════════════════════════════╗
  ║  Discovery complete. Feed results to Claude for     ║
  ║  grading against the ops-rx framework.              ║
  ╚══════════════════════════════════════════════════════╝
SUMMARY
printf "${NC}\n"

info "Scan completed: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
