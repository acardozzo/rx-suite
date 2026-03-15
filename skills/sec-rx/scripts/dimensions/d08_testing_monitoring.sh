#!/usr/bin/env bash
# D8: Security Testing & Monitoring — OWASP Testing Guide, SAST/DAST
# Scans for SAST integration, DAST, security monitoring, incident response

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

PROJECT_ROOT="${1:-.}"
detect_stack "$PROJECT_ROOT"

section_header "D8" "Security Testing & Monitoring (15%)"

# ─── M8.1: SAST Integration ───
metric_header "M8.1" "SAST Integration"

# Semgrep
SEMGREP=$(has_file "$PROJECT_ROOT" ".semgrep*")
SEMGREP_CI=$(search_config_files "$PROJECT_ROOT" "semgrep" "-rli")
if [[ -n "$SEMGREP" || -n "$SEMGREP_CI" ]]; then
  finding "INFO" "M8.1" "Semgrep SAST configuration detected"
fi

# CodeQL
CODEQL=$(has_file "$PROJECT_ROOT" "codeql*")
CODEQL_CI=$(search_config_files "$PROJECT_ROOT" "codeql" "-rli")
if [[ -n "$CODEQL" || -n "$CODEQL_CI" ]]; then
  finding "INFO" "M8.1" "CodeQL analysis detected"
fi

# ESLint security plugin
ESLINT_SEC=$(search_config_files "$PROJECT_ROOT" "(eslint-plugin-security|plugin:security|@typescript-eslint/no-unsafe|no-eval)" "-rli")
if [[ -n "$ESLINT_SEC" ]]; then
  finding "INFO" "M8.1" "ESLint security rules detected"
fi

# SonarQube/SonarCloud
SONAR=$(has_file "$PROJECT_ROOT" "sonar-project*")
SONAR_CI=$(search_config_files "$PROJECT_ROOT" "(sonarqube|sonarcloud|sonar)" "-rli")
if [[ -n "$SONAR" || -n "$SONAR_CI" ]]; then
  finding "INFO" "M8.1" "SonarQube/SonarCloud integration detected"
fi

# Bandit (Python)
BANDIT=$(search_config_files "$PROJECT_ROOT" "bandit" "-rli")
if [[ -n "$BANDIT" ]]; then
  finding "INFO" "M8.1" "Bandit (Python SAST) detected"
fi

# Any SAST at all?
if [[ -z "$SEMGREP" && -z "$SEMGREP_CI" && -z "$CODEQL" && -z "$CODEQL_CI" && -z "$ESLINT_SEC" && -z "$SONAR" && -z "$SONAR_CI" && -z "$BANDIT" ]]; then
  finding "HIGH" "M8.1" "No SAST tool detected in project"
fi

# Pre-commit hooks
PRECOMMIT=$(has_file "$PROJECT_ROOT" ".pre-commit-config*")
HUSKY=$(has_file "$PROJECT_ROOT" ".husky")
LEFTHOOK=$(has_file "$PROJECT_ROOT" "lefthook*")
if [[ -n "$PRECOMMIT" || -n "$HUSKY" || -n "$LEFTHOOK" ]]; then
  finding "INFO" "M8.1" "Pre-commit hooks detected (can enforce SAST locally)"
fi

# ─── M8.2: DAST / Pen Testing ───
metric_header "M8.2" "DAST / Pen Testing"

# OWASP ZAP
ZAP=$(search_config_files "$PROJECT_ROOT" "(zap|owasp.*zap|zaproxy)" "-rli")
if [[ -n "$ZAP" ]]; then
  finding "INFO" "M8.2" "OWASP ZAP configuration detected"
fi

# Nuclei
NUCLEI=$(search_config_files "$PROJECT_ROOT" "nuclei" "-rli")
if [[ -n "$NUCLEI" ]]; then
  finding "INFO" "M8.2" "Nuclei scanner detected"
fi

# Burp Suite config
BURP=$(has_file "$PROJECT_ROOT" "*.burp")
if [[ -n "$BURP" ]]; then
  finding "INFO" "M8.2" "Burp Suite project file detected"
fi

# Security test files
SEC_TESTS=$(search_source_files "$PROJECT_ROOT" "(security.*test|test.*security|pen.*test|penetration.*test)" "-rli")
if [[ -n "$SEC_TESTS" ]]; then
  finding "INFO" "M8.2" "Security-focused test files detected"
fi

if [[ -z "$ZAP" && -z "$NUCLEI" && -z "$BURP" && -z "$SEC_TESTS" ]]; then
  finding "MEDIUM" "M8.2" "No DAST or penetration testing tools detected"
fi

# ─── M8.3: Security Monitoring ───
metric_header "M8.3" "Security Monitoring"

# Failed login tracking
FAILED_LOGIN=$(search_source_files "$PROJECT_ROOT" \
  "(failed.*login|login.*fail|invalid.*password.*log|auth.*fail.*log|loginAttempts|failedAttempts|failed_attempts)" \
  "-rli")
if [[ -n "$FAILED_LOGIN" ]]; then
  finding "INFO" "M8.3" "Failed login tracking detected"
else
  finding "MEDIUM" "M8.3" "No failed login tracking detected"
fi

# Audit trail / audit logging
AUDIT_LOG=$(search_source_files "$PROJECT_ROOT" \
  "(audit.*log|audit.*trail|AuditLog|audit_log|createAuditEntry|logActivity|activity.*log)" \
  "-rl")
if [[ -n "$AUDIT_LOG" ]]; then
  finding "INFO" "M8.3" "Audit logging detected"
else
  finding "MEDIUM" "M8.3" "No audit logging detected"
fi

# Alerting / monitoring integration
MONITORING=$(search_source_files "$PROJECT_ROOT" \
  "(sentry|datadog|newrelic|prometheus|grafana|pagerduty|opsgenie|cloudwatch.*alarm|alert.*security)" \
  "-rli")
if [[ -n "$MONITORING" ]]; then
  finding "INFO" "M8.3" "Monitoring/alerting platform integration detected"
else
  finding "LOW" "M8.3" "No monitoring/alerting platform integration detected"
fi

# Anomaly detection
ANOMALY=$(search_source_files "$PROJECT_ROOT" "(anomaly|suspicious|threat.*detect|intrusion|waf|WAF)" "-rli")
if [[ -n "$ANOMALY" ]]; then
  finding "INFO" "M8.3" "Anomaly/threat detection patterns detected"
fi

# ─── M8.4: Incident Response Readiness ───
metric_header "M8.4" "Incident Response Readiness"

# SECURITY.md
SECURITY_MD=$(has_file "$PROJECT_ROOT" "SECURITY.md")
if [[ -n "$SECURITY_MD" ]]; then
  finding "INFO" "M8.4" "SECURITY.md found"

  # Check for responsible disclosure
  DISCLOSURE=$(grep -li "disclosure\|responsible\|report.*vulnerability\|security@\|hackerone\|bugcrowd" "$SECURITY_MD" 2>/dev/null || true)
  if [[ -n "$DISCLOSURE" ]]; then
    finding "INFO" "M8.4" "Responsible disclosure policy detected in SECURITY.md"
  fi
else
  finding "HIGH" "M8.4" "No SECURITY.md — no public security contact or disclosure policy"
fi

# Incident response documentation
IR_DOCS=$(search_config_files "$PROJECT_ROOT" "(incident.*response|runbook|playbook|escalation|on.call)" "-rli")
if [[ -n "$IR_DOCS" ]]; then
  finding "INFO" "M8.4" "Incident response documentation detected"
else
  finding "MEDIUM" "M8.4" "No incident response documentation detected"
fi

# Security headers in error responses (don't leak stack traces)
STACK_TRACE=$(search_source_files "$PROJECT_ROOT" "(stackTrace|stack.*trace|showStack|NODE_ENV.*development.*error)" "-rli")
if [[ -n "$STACK_TRACE" ]]; then
  finding "MEDIUM" "M8.4" "Stack trace exposure patterns detected — verify disabled in production"
fi

print_summary
