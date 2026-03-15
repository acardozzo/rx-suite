#!/usr/bin/env bash
# D1: Injection Prevention — OWASP A03:2021, CWE-79/89/78
# Scans for SQL injection, XSS, command injection, and NoSQL injection vectors

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

PROJECT_ROOT="${1:-.}"
detect_stack "$PROJECT_ROOT"

section_header "D1" "Injection Prevention (15%)"

# ─── M1.1: SQL Injection ───
metric_header "M1.1" "SQL Injection"

# String concatenation in SQL queries
SQL_CONCAT=$(search_source_files "$PROJECT_ROOT" \
  "(query|execute|exec|raw)\s*\(\s*['\"\`].*\+|\.query\s*\(\s*['\"\`].*\$\{|\.query\s*\(\s*f['\"]|format\s*\(\s*['\"].*SELECT|format\s*\(\s*['\"].*INSERT|format\s*\(\s*['\"].*UPDATE|format\s*\(\s*['\"].*DELETE" \
  "-rn")
if [[ -n "$SQL_CONCAT" ]]; then
  while IFS= read -r line; do
    file=$(echo "$line" | cut -d: -f1)
    lineno=$(echo "$line" | cut -d: -f2)
    finding "CRITICAL" "M1.1" "SQL string concatenation — possible SQL injection" "$file" "$lineno"
  done <<< "$SQL_CONCAT"
else
  finding "INFO" "M1.1" "No SQL string concatenation patterns detected"
fi

# Check for parameterized query usage
PARAM_QUERIES=$(search_source_files "$PROJECT_ROOT" \
  "(\?\s*,|\$[0-9]+|:[\w]+|@[\w]+|%s.*params|\.prepare\(|parameterized|placeholder)" \
  "-rl")
if [[ -n "$PARAM_QUERIES" ]]; then
  finding "INFO" "M1.1" "Parameterized queries found in $(echo "$PARAM_QUERIES" | wc -l | tr -d ' ') files"
fi

# Check for ORM usage
ORM_USAGE=$(search_source_files "$PROJECT_ROOT" \
  "(prisma|sequelize|typeorm|knex|drizzle|sqlalchemy|django\.db|ActiveRecord|gorm|ent\.)" \
  "-rl")
if [[ -n "$ORM_USAGE" ]]; then
  finding "INFO" "M1.1" "ORM detected — reduces SQL injection risk"
fi

# ─── M1.2: XSS Prevention ───
metric_header "M1.2" "XSS Prevention"

# dangerouslySetInnerHTML
DANGEROUS_HTML=$(search_source_files "$PROJECT_ROOT" "dangerouslySetInnerHTML" "-rn")
if [[ -n "$DANGEROUS_HTML" ]]; then
  while IFS= read -r line; do
    file=$(echo "$line" | cut -d: -f1)
    lineno=$(echo "$line" | cut -d: -f2)
    finding "HIGH" "M1.2" "dangerouslySetInnerHTML usage — potential XSS vector" "$file" "$lineno"
  done <<< "$DANGEROUS_HTML"
fi

# innerHTML assignment
INNER_HTML=$(search_source_files "$PROJECT_ROOT" "\.innerHTML\s*=" "-rn")
if [[ -n "$INNER_HTML" ]]; then
  while IFS= read -r line; do
    file=$(echo "$line" | cut -d: -f1)
    lineno=$(echo "$line" | cut -d: -f2)
    finding "HIGH" "M1.2" "innerHTML assignment — potential XSS vector" "$file" "$lineno"
  done <<< "$INNER_HTML"
fi

# document.write
DOC_WRITE=$(search_source_files "$PROJECT_ROOT" "document\.write\s*\(" "-rn")
if [[ -n "$DOC_WRITE" ]]; then
  while IFS= read -r line; do
    file=$(echo "$line" | cut -d: -f1)
    lineno=$(echo "$line" | cut -d: -f2)
    finding "HIGH" "M1.2" "document.write() usage — XSS risk" "$file" "$lineno"
  done <<< "$DOC_WRITE"
fi

# Check for sanitization libraries
SANITIZE=$(search_source_files "$PROJECT_ROOT" "(DOMPurify|sanitize-html|xss|escape-html|bleach|html\.escape)" "-rl")
if [[ -n "$SANITIZE" ]]; then
  finding "INFO" "M1.2" "Sanitization library detected"
else
  finding "MEDIUM" "M1.2" "No HTML sanitization library detected"
fi

# Check CSP header configuration
CSP_CONFIG=$(search_source_files "$PROJECT_ROOT" "(Content-Security-Policy|contentSecurityPolicy|csp)" "-rl")
CSP_NEXT=$(search_config_files "$PROJECT_ROOT" "(Content-Security-Policy|contentSecurityPolicy)" "-rl")
if [[ -n "$CSP_CONFIG" || -n "$CSP_NEXT" ]]; then
  finding "INFO" "M1.2" "CSP configuration detected"
else
  finding "MEDIUM" "M1.2" "No Content-Security-Policy configuration found"
fi

# ─── M1.3: Command Injection ───
metric_header "M1.3" "Command Injection"

# exec/spawn/system with potential user input
CMD_EXEC=$(search_source_files "$PROJECT_ROOT" \
  "(child_process|exec\s*\(|execSync\s*\(|spawn\s*\(|spawnSync\s*\(|os\.system\s*\(|subprocess\.\w+\s*\(|Runtime\.getRuntime\(\)\.exec|Process\.Start|syscall\.Exec)" \
  "-rn")
if [[ -n "$CMD_EXEC" ]]; then
  while IFS= read -r line; do
    file=$(echo "$line" | cut -d: -f1)
    lineno=$(echo "$line" | cut -d: -f2)
    finding "HIGH" "M1.3" "Shell/process execution found — verify no user input flows here" "$file" "$lineno"
  done <<< "$CMD_EXEC"
else
  finding "INFO" "M1.3" "No shell execution patterns detected"
fi

# eval() usage
EVAL_USAGE=$(search_source_files "$PROJECT_ROOT" "\beval\s*\(" "-rn")
if [[ -n "$EVAL_USAGE" ]]; then
  while IFS= read -r line; do
    file=$(echo "$line" | cut -d: -f1)
    lineno=$(echo "$line" | cut -d: -f2)
    finding "HIGH" "M1.3" "eval() usage — code injection risk" "$file" "$lineno"
  done <<< "$EVAL_USAGE"
fi

# new Function()
NEW_FUNC=$(search_source_files "$PROJECT_ROOT" "new\s+Function\s*\(" "-rn")
if [[ -n "$NEW_FUNC" ]]; then
  while IFS= read -r line; do
    file=$(echo "$line" | cut -d: -f1)
    lineno=$(echo "$line" | cut -d: -f2)
    finding "HIGH" "M1.3" "new Function() usage — code injection risk" "$file" "$lineno"
  done <<< "$NEW_FUNC"
fi

# ─── M1.4: NoSQL Injection ───
metric_header "M1.4" "NoSQL Injection"

# MongoDB $where or operator patterns
NOSQL_WHERE=$(search_source_files "$PROJECT_ROOT" '(\$where|\$gt|\$ne|\$regex|\$expr)' "-rn")
if [[ -n "$NOSQL_WHERE" ]]; then
  while IFS= read -r line; do
    file=$(echo "$line" | cut -d: -f1)
    lineno=$(echo "$line" | cut -d: -f2)
    finding "MEDIUM" "M1.4" "MongoDB query operator in source — verify not from user input" "$file" "$lineno"
  done <<< "$NOSQL_WHERE"
fi

# Check for mongo-sanitize
MONGO_SANITIZE=$(search_source_files "$PROJECT_ROOT" "(mongo-sanitize|express-mongo-sanitize|sanitize)" "-rl")
if [[ -n "$MONGO_SANITIZE" ]]; then
  finding "INFO" "M1.4" "MongoDB sanitization library detected"
fi

# Schema validation (Mongoose, Joi, Zod, Yup)
SCHEMA_VAL=$(search_source_files "$PROJECT_ROOT" "(mongoose\.Schema|Joi\.|zod|z\.\w+\(\)|yup\.\w+|class-validator|ajv)" "-rl")
if [[ -n "$SCHEMA_VAL" ]]; then
  finding "INFO" "M1.4" "Schema validation library detected in $(echo "$SCHEMA_VAL" | wc -l | tr -d ' ') files"
else
  finding "LOW" "M1.4" "No schema validation library detected"
fi

print_summary
