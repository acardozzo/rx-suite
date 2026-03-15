#!/usr/bin/env bash
# D6: Dependency & Supply Chain — OWASP A06:2021, SLSA Framework
# Scans for vulnerability scanning, CVE response, lockfile integrity, SBOM

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

PROJECT_ROOT="${1:-.}"
detect_stack "$PROJECT_ROOT"

section_header "D6" "Dependency & Supply Chain (10%)"

# ─── M6.1: Vulnerability Scanning ───
metric_header "M6.1" "Vulnerability Scanning"

# Check CI config for audit/scanning commands
CI_SCAN=$(search_config_files "$PROJECT_ROOT" \
  "(npm audit|yarn audit|pnpm audit|pip audit|safety check|snyk|trivy|grype|dependabot|renovate|security.*scan)" \
  "-rli")
if [[ -n "$CI_SCAN" ]]; then
  finding "INFO" "M6.1" "Vulnerability scanning configured"
else
  finding "HIGH" "M6.1" "No vulnerability scanning detected in CI/config"
fi

# Dependabot or Renovate config
DEPENDABOT=$(has_file "$PROJECT_ROOT" "dependabot.yml")
RENOVATE=$(has_file "$PROJECT_ROOT" "renovate.json")
RENOVATE2=$(has_file "$PROJECT_ROOT" ".renovaterc")
if [[ -n "$DEPENDABOT" || -n "$RENOVATE" || -n "$RENOVATE2" ]]; then
  finding "INFO" "M6.1" "Automated dependency update tool configured (Dependabot/Renovate)"
else
  finding "MEDIUM" "M6.1" "No automated dependency update tool (Dependabot/Renovate) detected"
fi

# Snyk config
SNYK=$(has_file "$PROJECT_ROOT" ".snyk")
if [[ -n "$SNYK" ]]; then
  finding "INFO" "M6.1" "Snyk configuration detected"
fi

# ─── M6.2: Critical CVE Response ───
metric_header "M6.2" "Critical CVE Response"

# Security policy
SECURITY_MD=$(has_file "$PROJECT_ROOT" "SECURITY.md")
if [[ -n "$SECURITY_MD" ]]; then
  finding "INFO" "M6.2" "SECURITY.md found — may contain CVE response process"
else
  finding "MEDIUM" "M6.2" "No SECURITY.md found"
fi

# Check for known vulnerable package versions (basic check)
if [[ -f "$PROJECT_ROOT/package.json" ]]; then
  # Check for very old/known vulnerable packages
  VULN_PKGS=$(search_config_files "$PROJECT_ROOT/package.json" \
    "(\"lodash\":\s*\"[0-3]\.|\"express\":\s*\"[0-3]\.|\"axios\":\s*\"0\.[0-1])" \
    "-n")
  if [[ -n "$VULN_PKGS" ]]; then
    finding "HIGH" "M6.2" "Potentially outdated packages with known CVEs detected"
  fi
fi

# ─── M6.3: Lockfile Integrity ───
metric_header "M6.3" "Lockfile Integrity"

# Check for lockfile existence
LOCKFILE=""
[[ -f "$PROJECT_ROOT/package-lock.json" ]] && LOCKFILE="package-lock.json"
[[ -f "$PROJECT_ROOT/yarn.lock" ]] && LOCKFILE="yarn.lock"
[[ -f "$PROJECT_ROOT/pnpm-lock.yaml" ]] && LOCKFILE="pnpm-lock.yaml"
[[ -f "$PROJECT_ROOT/Pipfile.lock" ]] && LOCKFILE="Pipfile.lock"
[[ -f "$PROJECT_ROOT/poetry.lock" ]] && LOCKFILE="poetry.lock"
[[ -f "$PROJECT_ROOT/go.sum" ]] && LOCKFILE="go.sum"
[[ -f "$PROJECT_ROOT/Gemfile.lock" ]] && LOCKFILE="Gemfile.lock"

if [[ -n "$LOCKFILE" ]]; then
  finding "INFO" "M6.3" "Lockfile detected: $LOCKFILE"
else
  finding "HIGH" "M6.3" "No lockfile detected — dependency versions not pinned"
fi

# Check for --frozen-lockfile in CI
FROZEN=$(search_config_files "$PROJECT_ROOT" "(frozen-lockfile|ci\b|npm ci|--immutable)" "-rli")
if [[ -n "$FROZEN" ]]; then
  finding "INFO" "M6.3" "Frozen lockfile enforcement detected in CI"
else
  finding "MEDIUM" "M6.3" "No frozen lockfile enforcement detected in CI"
fi

# Check .gitignore for lockfile (should NOT be gitignored)
if [[ -f "$PROJECT_ROOT/.gitignore" ]]; then
  IGNORED_LOCK=$(grep -E "(package-lock|yarn\.lock|pnpm-lock)" "$PROJECT_ROOT/.gitignore" 2>/dev/null || true)
  if [[ -n "$IGNORED_LOCK" ]]; then
    finding "HIGH" "M6.3" "Lockfile appears to be gitignored — should be committed"
  fi
fi

# ─── M6.4: SBOM & Provenance ───
metric_header "M6.4" "SBOM & Provenance"

# SBOM generation
SBOM=$(search_config_files "$PROJECT_ROOT" "(sbom|cyclonedx|spdx|syft|bom)" "-rli")
SBOM_FILE=$(has_file "$PROJECT_ROOT" "*.sbom.*")
SBOM_FILE2=$(has_file "$PROJECT_ROOT" "bom.json")
if [[ -n "$SBOM" || -n "$SBOM_FILE" || -n "$SBOM_FILE2" ]]; then
  finding "INFO" "M6.4" "SBOM generation detected"
else
  finding "LOW" "M6.4" "No SBOM generation detected"
fi

# Build provenance / signing
PROVENANCE=$(search_config_files "$PROJECT_ROOT" "(provenance|cosign|sigstore|slsa|attestation|npm.*provenance)" "-rli")
if [[ -n "$PROVENANCE" ]]; then
  finding "INFO" "M6.4" "Build provenance/signing detected"
else
  finding "LOW" "M6.4" "No build provenance or artifact signing detected"
fi

# Docker image scanning
DOCKER_SCAN=$(search_config_files "$PROJECT_ROOT" "(docker.*scan|trivy|grype|docker scout|container.*scan)" "-rli")
if [[ -n "$DOCKER_SCAN" ]]; then
  finding "INFO" "M6.4" "Container image scanning detected"
fi

print_summary
