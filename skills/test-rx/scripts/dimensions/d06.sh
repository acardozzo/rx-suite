#!/usr/bin/env bash
# D6: Test Data Management — factories, DB isolation, seed data, mock quality
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

PROJECT_ROOT="${1:-$(pwd)}"

# --------------------------------------------------------------------------
# M6.1 — Test factories
# --------------------------------------------------------------------------

# Factory files
FACTORY_FILES=$(find "$PROJECT_ROOT" -type f \( -name "*factory*" -o -name "*Factory*" -o -name "*builder*" -o -name "*Builder*" -o -name "*fixture*" -o -name "*Fixture*" \) \( -name "*.ts" -o -name "*.js" -o -name "*.py" -o -name "*.go" -o -name "*.java" -o -name "*.rb" \) "${EXCLUDE_DIRS[@]}" 2>/dev/null | wc -l | tr -d ' ')

# Factory libraries
HAS_FISHERY=$(count_pattern "fishery" "package.json" "$PROJECT_ROOT")
HAS_FACTORY_BOT=$(count_pattern "factory_bot\|factorybot" "*" "$PROJECT_ROOT")
HAS_FAKER=$(count_pattern "faker\|@faker-js" "package.json" "$PROJECT_ROOT")
HAS_CHANCE=$(count_pattern "chance" "package.json" "$PROJECT_ROOT")
HAS_AUTOFIXTURE=$(count_pattern "AutoFixture\|autofixture" "*" "$PROJECT_ROOT")

# Factory usage in tests (createUser, buildOrder, etc.)
FACTORY_USAGE=$(grep -rl "create\(\|build\(\|make\(\|generate\(" "$PROJECT_ROOT" --include="*.test.*" --include="*.spec.*" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

# Inline object literals in tests (anti-pattern signal)
INLINE_LITERALS=$(grep -rEc "const .+ = \{|let .+ = \{" "$PROJECT_ROOT" --include="*.test.*" --include="*.spec.*" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | awk '{s+=$1} END {print s+0}' || echo "0")

# --------------------------------------------------------------------------
# M6.2 — Database isolation
# --------------------------------------------------------------------------

# Testcontainers
HAS_TESTCONTAINERS=$(count_pattern "testcontainers\|@testcontainers" "*" "$PROJECT_ROOT")
TESTCONTAINER_FILES=$(grep -rl "testcontainers\|GenericContainer\|PostgreSQLContainer\|MongoDBContainer" "$PROJECT_ROOT" --include="*.test.*" --include="*.spec.*" --include="*_test.*" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

# Transaction rollback patterns
TRANSACTION_ROLLBACK=$(grep -rl "rollback\|ROLLBACK\|savepoint\|BEGIN\|transaction" "$PROJECT_ROOT" --include="*.test.*" --include="*.spec.*" --include="*_test.*" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

# beforeEach/afterEach cleanup
CLEANUP_HOOKS=$(grep -rl "beforeEach\|afterEach\|setUp\|tearDown\|beforeAll\|afterAll\|setup\|cleanup" "$PROJECT_ROOT" --include="*.test.*" --include="*.spec.*" --include="*_test.*" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

# Truncate/delete cleanup
TRUNCATE_CLEANUP=$(grep -rl "truncate\|TRUNCATE\|deleteMany\|deleteAll\|destroy_all\|clear()" "$PROJECT_ROOT" --include="*.test.*" --include="*.spec.*" --include="*_test.*" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

# --------------------------------------------------------------------------
# M6.3 — Seed data management
# --------------------------------------------------------------------------

SEED_FILES=$(find "$PROJECT_ROOT" -type f \( -name "*seed*" -o -name "*Seed*" \) \( -name "*.ts" -o -name "*.js" -o -name "*.py" -o -name "*.sql" -o -name "*.go" \) "${EXCLUDE_DIRS[@]}" 2>/dev/null | wc -l | tr -d ' ')
SEED_DIRS=$(find "$PROJECT_ROOT" -type d -name "*seed*" "${EXCLUDE_DIRS[@]}" 2>/dev/null | wc -l | tr -d ' ')
FIXTURE_DIRS=$(find "$PROJECT_ROOT" -type d \( -name "fixtures" -o -name "__fixtures__" -o -name "test-fixtures" \) "${EXCLUDE_DIRS[@]}" 2>/dev/null | wc -l | tr -d ' ')
FIXTURE_FILES=$(find "$PROJECT_ROOT" -type f -path "*/fixtures/*" "${EXCLUDE_DIRS[@]}" 2>/dev/null | wc -l | tr -d ' ')

# --------------------------------------------------------------------------
# M6.4 — Mock & stub quality
# --------------------------------------------------------------------------

# Mock files/directories
MOCK_FILES=$(find "$PROJECT_ROOT" -type f \( -name "*mock*" -o -name "*Mock*" -o -name "__mocks__/*" \) \( -name "*.ts" -o -name "*.js" -o -name "*.py" -o -name "*.go" \) "${EXCLUDE_DIRS[@]}" 2>/dev/null | wc -l | tr -d ' ')
MOCK_DIRS=$(find "$PROJECT_ROOT" -type d \( -name "__mocks__" -o -name "mocks" -o -name "mock" \) "${EXCLUDE_DIRS[@]}" 2>/dev/null | wc -l | tr -d ' ')

# jest.mock / vi.mock usage
AUTO_MOCK_COUNT=$(grep -rc "jest\.mock\|vi\.mock\|mock\.patch\|@patch\|@mock" "$PROJECT_ROOT" --include="*.test.*" --include="*.spec.*" --include="*_test.*" --include="test_*" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | grep -v ":0$" | awk -F: '{s+=$2} END {print s+0}' || echo "0")

# Over-mocking signal: more mocks than assertions
MOCK_TO_ASSERT_SIGNAL="healthy"
if [[ $AUTO_MOCK_COUNT -gt 0 ]]; then
  TOTAL_ASSERTIONS=$(grep -rc "expect(\|assert\.\|should\.\|toBe\|toEqual\|toHave" "$PROJECT_ROOT" --include="*.test.*" --include="*.spec.*" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | grep -v ":0$" | awk -F: '{s+=$2} END {print s+0}' || echo "0")
  if [[ $AUTO_MOCK_COUNT -gt $TOTAL_ASSERTIONS ]] && [[ $TOTAL_ASSERTIONS -gt 0 ]]; then
    MOCK_TO_ASSERT_SIGNAL="over_mocking"
  elif [[ $AUTO_MOCK_COUNT -gt $((TOTAL_ASSERTIONS / 2)) ]] && [[ $TOTAL_ASSERTIONS -gt 0 ]]; then
    MOCK_TO_ASSERT_SIGNAL="heavy_mocking"
  fi
fi

# --------------------------------------------------------------------------
# Output JSON
# --------------------------------------------------------------------------

cat << EOF
{
  "factories": {
    "factory_files": $FACTORY_FILES,
    "fishery": $HAS_FISHERY,
    "factory_bot": $HAS_FACTORY_BOT,
    "faker": $HAS_FAKER,
    "chance": $HAS_CHANCE,
    "autofixture": $HAS_AUTOFIXTURE,
    "factory_usage_in_tests": $FACTORY_USAGE,
    "inline_literals_in_tests": $INLINE_LITERALS
  },
  "db_isolation": {
    "testcontainers_dep": $HAS_TESTCONTAINERS,
    "testcontainer_files": $TESTCONTAINER_FILES,
    "transaction_rollback": $TRANSACTION_ROLLBACK,
    "cleanup_hooks": $CLEANUP_HOOKS,
    "truncate_cleanup": $TRUNCATE_CLEANUP
  },
  "seed_data": {
    "seed_files": $SEED_FILES,
    "seed_dirs": $SEED_DIRS,
    "fixture_dirs": $FIXTURE_DIRS,
    "fixture_files": $FIXTURE_FILES
  },
  "mock_quality": {
    "mock_files": $MOCK_FILES,
    "mock_dirs": $MOCK_DIRS,
    "auto_mock_count": $AUTO_MOCK_COUNT,
    "mock_to_assert_signal": "$MOCK_TO_ASSERT_SIGNAL"
  }
}
EOF
