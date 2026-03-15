#!/usr/bin/env bash
# D1: Test Pyramid Balance — counts unit, integration, and E2E test files
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

PROJECT_ROOT="${1:-$(pwd)}"

# --------------------------------------------------------------------------
# M1.1 — Unit test ratio
# --------------------------------------------------------------------------

# Count test files by type patterns
# Unit tests: *.test.ts, *.spec.ts, *.test.js, *_test.go, test_*.py (excluding integration/e2e patterns)
TOTAL_TEST_FILES=0
UNIT_TEST_FILES=0
INTEGRATION_TEST_FILES=0
E2E_TEST_FILES=0

# JS/TS test files
JS_TEST_COUNT=$(find "$PROJECT_ROOT" -type f \( -name "*.test.ts" -o -name "*.test.tsx" -o -name "*.test.js" -o -name "*.test.jsx" -o -name "*.spec.ts" -o -name "*.spec.tsx" -o -name "*.spec.js" -o -name "*.spec.jsx" \) "${EXCLUDE_DIRS[@]}" 2>/dev/null | wc -l | tr -d ' ')

# Go test files
GO_TEST_COUNT=$(find "$PROJECT_ROOT" -type f -name "*_test.go" "${EXCLUDE_DIRS[@]}" 2>/dev/null | wc -l | tr -d ' ')

# Python test files
PY_TEST_COUNT=$(find "$PROJECT_ROOT" -type f \( -name "test_*.py" -o -name "*_test.py" \) "${EXCLUDE_DIRS[@]}" 2>/dev/null | wc -l | tr -d ' ')

# Rust test files (tests/ directory)
RS_TEST_COUNT=$(find "$PROJECT_ROOT" -type f -name "*.rs" -path "*/tests/*" "${EXCLUDE_DIRS[@]}" 2>/dev/null | wc -l | tr -d ' ')

# Java/Kotlin test files
JVM_TEST_COUNT=$(find "$PROJECT_ROOT" -type f \( -name "*Test.java" -o -name "*Test.kt" -o -name "*Spec.java" -o -name "*Spec.kt" \) "${EXCLUDE_DIRS[@]}" 2>/dev/null | wc -l | tr -d ' ')

TOTAL_TEST_FILES=$((JS_TEST_COUNT + GO_TEST_COUNT + PY_TEST_COUNT + RS_TEST_COUNT + JVM_TEST_COUNT))

# Integration test files (files with integration/api in name or path)
INTEGRATION_TEST_FILES=$(find "$PROJECT_ROOT" -type f \( -name "*.test.*" -o -name "*.spec.*" -o -name "*_test.*" -o -name "test_*" \) "${EXCLUDE_DIRS[@]}" 2>/dev/null | grep -iE "(integration|api\.test|api\.spec|api_test|\.integration\.|/integration/)" | wc -l | tr -d ' ')

# E2E test files
E2E_TEST_FILES=$(find "$PROJECT_ROOT" -type f \( -name "*.e2e.*" -o -name "*.e2e-spec.*" -o -name "*.playwright.*" -o -name "*.cy.*" \) "${EXCLUDE_DIRS[@]}" 2>/dev/null | wc -l | tr -d ' ')

# Also check for Playwright test directory
PLAYWRIGHT_E2E=$(find "$PROJECT_ROOT" -type f \( -name "*.spec.ts" -o -name "*.spec.js" \) -path "*/e2e/*" "${EXCLUDE_DIRS[@]}" 2>/dev/null | wc -l | tr -d ' ')
PLAYWRIGHT_E2E2=$(find "$PROJECT_ROOT" -type f \( -name "*.spec.ts" -o -name "*.spec.js" \) -path "*/tests/*" "${EXCLUDE_DIRS[@]}" 2>/dev/null | grep -v __tests__ | wc -l | tr -d ' ')

# Check Cypress
CYPRESS_E2E=$(find "$PROJECT_ROOT" -type f -name "*.cy.*" "${EXCLUDE_DIRS[@]}" 2>/dev/null | wc -l | tr -d ' ')

E2E_TEST_FILES=$((E2E_TEST_FILES + PLAYWRIGHT_E2E + PLAYWRIGHT_E2E2 + CYPRESS_E2E))

# Deduplicate: unit = total - integration - e2e
UNIT_TEST_FILES=$((TOTAL_TEST_FILES - INTEGRATION_TEST_FILES - E2E_TEST_FILES))
if [[ $UNIT_TEST_FILES -lt 0 ]]; then UNIT_TEST_FILES=0; fi

# Calculate ratio
if [[ $TOTAL_TEST_FILES -gt 0 ]]; then
  UNIT_RATIO=$((UNIT_TEST_FILES * 100 / TOTAL_TEST_FILES))
  INTEGRATION_RATIO=$((INTEGRATION_TEST_FILES * 100 / TOTAL_TEST_FILES))
  E2E_RATIO=$((E2E_TEST_FILES * 100 / TOTAL_TEST_FILES))
else
  UNIT_RATIO=0
  INTEGRATION_RATIO=0
  E2E_RATIO=0
fi

# --------------------------------------------------------------------------
# M1.2 — Integration test coverage signals
# --------------------------------------------------------------------------

HAS_SUPERTEST=$(count_pattern "supertest" "*.ts" "$PROJECT_ROOT")
HAS_HTTPX=$(count_pattern "httpx" "*.py" "$PROJECT_ROOT")
HAS_TESTCONTAINERS=$(count_pattern "testcontainers" "*" "$PROJECT_ROOT")
HAS_HTTP_TEST=$(count_pattern "request(app)" "*.ts" "$PROJECT_ROOT")

# --------------------------------------------------------------------------
# M1.3 — E2E coverage signals
# --------------------------------------------------------------------------

HAS_PLAYWRIGHT_CONFIG=$(find "$PROJECT_ROOT" -maxdepth 3 -name "playwright.config.*" "${EXCLUDE_DIRS[@]}" 2>/dev/null | wc -l | tr -d ' ')
HAS_CYPRESS_CONFIG=$(find "$PROJECT_ROOT" -maxdepth 3 \( -name "cypress.config.*" -o -name "cypress.json" \) "${EXCLUDE_DIRS[@]}" 2>/dev/null | wc -l | tr -d ' ')

# --------------------------------------------------------------------------
# M1.4 — Pyramid shape analysis
# --------------------------------------------------------------------------

if [[ $TOTAL_TEST_FILES -eq 0 ]]; then
  SHAPE="none"
elif [[ $UNIT_TEST_FILES -ge $INTEGRATION_TEST_FILES ]] && [[ $INTEGRATION_TEST_FILES -ge $E2E_TEST_FILES ]] && [[ $UNIT_TEST_FILES -gt $E2E_TEST_FILES ]]; then
  SHAPE="pyramid"
elif [[ $INTEGRATION_TEST_FILES -gt $UNIT_TEST_FILES ]] && [[ $INTEGRATION_TEST_FILES -gt $E2E_TEST_FILES ]]; then
  SHAPE="diamond"
elif [[ $E2E_TEST_FILES -gt $UNIT_TEST_FILES ]]; then
  SHAPE="ice_cream_cone"
else
  SHAPE="unbalanced"
fi

# --------------------------------------------------------------------------
# Output JSON
# --------------------------------------------------------------------------

cat << EOF
{
  "total_test_files": $TOTAL_TEST_FILES,
  "unit_test_files": $UNIT_TEST_FILES,
  "integration_test_files": $INTEGRATION_TEST_FILES,
  "e2e_test_files": $E2E_TEST_FILES,
  "unit_ratio_pct": $UNIT_RATIO,
  "integration_ratio_pct": $INTEGRATION_RATIO,
  "e2e_ratio_pct": $E2E_RATIO,
  "pyramid_shape": "$SHAPE",
  "signals": {
    "supertest_usage": $HAS_SUPERTEST,
    "httpx_usage": $HAS_HTTPX,
    "testcontainers_usage": $HAS_TESTCONTAINERS,
    "http_test_usage": $HAS_HTTP_TEST,
    "playwright_config": $HAS_PLAYWRIGHT_CONFIG,
    "cypress_config": $HAS_CYPRESS_CONFIG
  },
  "breakdown": {
    "js_ts_tests": $JS_TEST_COUNT,
    "go_tests": $GO_TEST_COUNT,
    "python_tests": $PY_TEST_COUNT,
    "rust_tests": $RS_TEST_COUNT,
    "jvm_tests": $JVM_TEST_COUNT
  }
}
EOF
