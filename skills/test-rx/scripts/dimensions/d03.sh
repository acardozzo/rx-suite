#!/usr/bin/env bash
# D3: Contract & API Testing — Pact, schema validation, HTTP integration, backward compat
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

PROJECT_ROOT="${1:-$(pwd)}"

# --------------------------------------------------------------------------
# M3.1 — Contract test coverage (Pact / consumer-driven)
# --------------------------------------------------------------------------

PACT_FILES=$(find "$PROJECT_ROOT" -type f \( -name "*.pact.*" -o -name "pact*.json" -o -name "*pact*" \) "${EXCLUDE_DIRS[@]}" 2>/dev/null | grep -v node_modules | wc -l | tr -d ' ')
HAS_PACT_DEP=$(count_pattern "@pact-foundation\|pact-python\|pact-go\|pact-jvm" "package.json" "$PROJECT_ROOT")
PACT_TEST_FILES=$(grep -rl "Pact\|PactV3\|PactV4\|pact\.\|from pact" "$PROJECT_ROOT" --include="*.test.*" --include="*.spec.*" --include="*_test.*" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

# Spring Cloud Contract (JVM)
SPRING_CONTRACT=$(count_pattern "spring-cloud-contract\|@AutoConfigureStubRunner" "*" "$PROJECT_ROOT")

# --------------------------------------------------------------------------
# M3.2 — Schema validation tests
# --------------------------------------------------------------------------

# Zod schema usage in tests
ZOD_IN_TESTS=$(grep -rl "z\.\|zod\|\.parse(\|\.safeParse(" "$PROJECT_ROOT" --include="*.test.*" --include="*.spec.*" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

# OpenAPI/Swagger validation
OPENAPI_FILES=$(find "$PROJECT_ROOT" -maxdepth 4 -type f \( -name "openapi.*" -o -name "swagger.*" -o -name "*.openapi.*" \) "${EXCLUDE_DIRS[@]}" 2>/dev/null | wc -l | tr -d ' ')
OPENAPI_VALIDATION=$(count_pattern "openapi\|swagger\|ajv\|json-schema\|jsonschema" "*.test.*" "$PROJECT_ROOT")

# JSON Schema validation
JSON_SCHEMA_IN_TESTS=$(grep -rl "jsonschema\|ajv\|json-schema\|validateSchema" "$PROJECT_ROOT" --include="*.test.*" --include="*.spec.*" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

# --------------------------------------------------------------------------
# M3.3 — API integration tests (real HTTP)
# --------------------------------------------------------------------------

# supertest (Node.js)
SUPERTEST_FILES=$(grep -rl "supertest\|request(app)" "$PROJECT_ROOT" --include="*.test.*" --include="*.spec.*" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

# httpx/requests (Python)
HTTPX_FILES=$(grep -rl "httpx\|requests\.get\|requests\.post\|TestClient" "$PROJECT_ROOT" --include="test_*" --include="*_test.py" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

# net/http/httptest (Go)
HTTPTEST_FILES=$(grep -rl "httptest\|http\.NewRequest" "$PROJECT_ROOT" --include="*_test.go" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

# MSW (Mock Service Worker) — counts as mocked, not real HTTP
MSW_FILES=$(grep -rl "msw\|setupServer\|setupWorker\|http\.get\|http\.post" "$PROJECT_ROOT" --include="*.test.*" --include="*.spec.*" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

# nock (Node.js mock)
NOCK_FILES=$(grep -rl "nock(" "$PROJECT_ROOT" --include="*.test.*" --include="*.spec.*" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

REAL_HTTP_TESTS=$((SUPERTEST_FILES + HTTPX_FILES + HTTPTEST_FILES))
MOCKED_HTTP_TESTS=$((MSW_FILES + NOCK_FILES))

# --------------------------------------------------------------------------
# M3.4 — Backward compatibility
# --------------------------------------------------------------------------

# openapi-diff, buf breaking, api-diff tools
HAS_OPENAPI_DIFF=$(count_pattern "openapi-diff\|api-diff\|swagger-diff" "*" "$PROJECT_ROOT")
HAS_BUF=$(find "$PROJECT_ROOT" -maxdepth 3 \( -name "buf.yaml" -o -name "buf.gen.yaml" \) "${EXCLUDE_DIRS[@]}" 2>/dev/null | wc -l | tr -d ' ')
HAS_API_VERSIONING=$(grep -rl "/v[0-9]\|/api/v[0-9]\|@Version\|api-version" "$PROJECT_ROOT" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" --include="*.java" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

# --------------------------------------------------------------------------
# Output JSON
# --------------------------------------------------------------------------

cat << EOF
{
  "contract_testing": {
    "pact_files": $PACT_FILES,
    "pact_dependency": $HAS_PACT_DEP,
    "pact_test_files": $PACT_TEST_FILES,
    "spring_contract": $SPRING_CONTRACT
  },
  "schema_validation": {
    "zod_in_tests": $ZOD_IN_TESTS,
    "openapi_files": $OPENAPI_FILES,
    "openapi_validation_in_tests": $OPENAPI_VALIDATION,
    "json_schema_in_tests": $JSON_SCHEMA_IN_TESTS
  },
  "api_integration": {
    "real_http_tests": $REAL_HTTP_TESTS,
    "supertest_files": $SUPERTEST_FILES,
    "httpx_files": $HTTPX_FILES,
    "httptest_files": $HTTPTEST_FILES,
    "mocked_http_tests": $MOCKED_HTTP_TESTS,
    "msw_files": $MSW_FILES,
    "nock_files": $NOCK_FILES
  },
  "backward_compatibility": {
    "openapi_diff": $HAS_OPENAPI_DIFF,
    "buf_config": $HAS_BUF,
    "api_versioning_files": $HAS_API_VERSIONING
  }
}
EOF
