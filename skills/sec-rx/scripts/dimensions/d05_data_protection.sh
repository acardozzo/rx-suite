#!/usr/bin/env bash
# D5: Data Protection & Privacy — OWASP A02:2021, GDPR Technical Measures
# Scans for encryption at rest, PII handling, logging sanitization, data retention

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

PROJECT_ROOT="${1:-.}"
detect_stack "$PROJECT_ROOT"

section_header "D5" "Data Protection & Privacy (10%)"

# ─── M5.1: Encryption at Rest ───
metric_header "M5.1" "Encryption at Rest"

# Hardcoded secrets in source
HARDCODED_SECRETS=$(search_source_files "$PROJECT_ROOT" \
  "(API_KEY\s*=\s*['\"][A-Za-z0-9]{16,}|SECRET_KEY\s*=\s*['\"][^'\"]{8,}|password\s*[:=]\s*['\"][^'\"]{8,}['\"]|apiKey\s*[:=]\s*['\"][A-Za-z0-9]{16,})" \
  "-rn")
if [[ -n "$HARDCODED_SECRETS" ]]; then
  while IFS= read -r line; do
    file=$(echo "$line" | cut -d: -f1)
    lineno=$(echo "$line" | cut -d: -f2)
    # Skip .env.example, test files, docs
    if ! echo "$file" | grep -qE "(\.example|\.sample|test|spec|mock|__test__|\.md)"; then
      finding "CRITICAL" "M5.1" "Potential hardcoded secret in source" "$file" "$lineno"
    fi
  done <<< "$HARDCODED_SECRETS"
fi

# .env files committed
ENV_FILES=$(find "$PROJECT_ROOT" -name ".env" -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null)
if [[ -n "$ENV_FILES" ]]; then
  while IFS= read -r file; do
    finding "HIGH" "M5.1" ".env file found — verify not committed to git" "$file"
  done <<< "$ENV_FILES"
fi

# Encryption library usage
ENCRYPTION=$(search_source_files "$PROJECT_ROOT" \
  "(crypto\.createCipher|AES|aes-256|encrypt|decrypt|cryptography|Cipher|javax\.crypto|pgcrypto)" \
  "-rl")
if [[ -n "$ENCRYPTION" ]]; then
  finding "INFO" "M5.1" "Encryption library usage detected"
else
  finding "MEDIUM" "M5.1" "No encryption library usage detected for data at rest"
fi

# KMS/HSM usage
KMS=$(search_source_files "$PROJECT_ROOT" "(KMS|aws-kms|google-kms|azure-keyvault|vault|hashicorp)" "-rli")
if [[ -n "$KMS" ]]; then
  finding "INFO" "M5.1" "Key management service integration detected"
fi

# ─── M5.2: PII Handling ───
metric_header "M5.2" "PII Handling"

# PII fields in code
PII_FIELDS=$(search_source_files "$PROJECT_ROOT" \
  "(social.security|ssn|date.of.birth|dob|credit.card|cardNumber|phone.number|address|passport|national.id)" \
  "-rli")
if [[ -n "$PII_FIELDS" ]]; then
  PII_COUNT=$(echo "$PII_FIELDS" | wc -l | tr -d ' ')
  finding "MEDIUM" "M5.2" "PII fields detected in $PII_COUNT files — verify proper handling"
fi

# GDPR/consent patterns
CONSENT=$(search_source_files "$PROJECT_ROOT" "(consent|gdpr|privacy.*policy|data.*subject|right.*erasure|right.*forget|dsar)" "-rli")
if [[ -n "$CONSENT" ]]; then
  finding "INFO" "M5.2" "GDPR/consent handling patterns detected"
else
  finding "LOW" "M5.2" "No GDPR/consent handling patterns detected"
fi

# Data deletion capability
DELETION=$(search_source_files "$PROJECT_ROOT" "(deleteAccount|delete.*user|remove.*user|purge.*data|anonymize|pseudonymize)" "-rli")
if [[ -n "$DELETION" ]]; then
  finding "INFO" "M5.2" "Data deletion/anonymization capability detected"
fi

# ─── M5.3: Logging Sanitization ───
metric_header "M5.3" "Logging Sanitization"

# Passwords/tokens in logs
LOG_SECRETS=$(search_source_files "$PROJECT_ROOT" \
  "(console\.log.*password|logger.*password|log\.\w+.*password|print.*password|console\.log.*token|logger.*token|log\.\w+.*secret|console\.log.*apiKey)" \
  "-rn")
if [[ -n "$LOG_SECRETS" ]]; then
  while IFS= read -r line; do
    file=$(echo "$line" | cut -d: -f1)
    lineno=$(echo "$line" | cut -d: -f2)
    if ! echo "$file" | grep -qE "(test|spec|mock|__test__)"; then
      finding "HIGH" "M5.3" "Sensitive data potentially logged" "$file" "$lineno"
    fi
  done <<< "$LOG_SECRETS"
fi

# Request body logging
REQ_BODY_LOG=$(search_source_files "$PROJECT_ROOT" "(console\.log.*req\.body|logger.*req\.body|log.*request\.body)" "-rn")
if [[ -n "$REQ_BODY_LOG" ]]; then
  while IFS= read -r line; do
    file=$(echo "$line" | cut -d: -f1)
    lineno=$(echo "$line" | cut -d: -f2)
    finding "MEDIUM" "M5.3" "Request body logged — may contain sensitive data" "$file" "$lineno"
  done <<< "$REQ_BODY_LOG"
fi

# Log redaction/masking
LOG_REDACT=$(search_source_files "$PROJECT_ROOT" "(redact|mask|sanitize.*log|pino.*redact|winston.*redact|scrub)" "-rli")
if [[ -n "$LOG_REDACT" ]]; then
  finding "INFO" "M5.3" "Log redaction/masking pattern detected"
else
  finding "MEDIUM" "M5.3" "No log redaction/masking pattern detected"
fi

# ─── M5.4: Data Retention ───
metric_header "M5.4" "Data Retention"

# Retention policies/jobs
RETENTION=$(search_source_files "$PROJECT_ROOT" "(retention|cleanup|purge|ttl|time.to.live|expire.*data|cron.*delete|scheduled.*cleanup)" "-rli")
if [[ -n "$RETENTION" ]]; then
  finding "INFO" "M5.4" "Data retention/cleanup patterns detected"
else
  finding "MEDIUM" "M5.4" "No data retention/cleanup patterns detected"
fi

# Soft delete vs hard delete
SOFT_DELETE=$(search_source_files "$PROJECT_ROOT" "(soft.*delete|deleted_at|deletedAt|is_deleted|isDeleted|paranoid)" "-rli")
if [[ -n "$SOFT_DELETE" ]]; then
  finding "INFO" "M5.4" "Soft delete pattern detected — verify hard delete capability exists for GDPR"
fi

print_summary
