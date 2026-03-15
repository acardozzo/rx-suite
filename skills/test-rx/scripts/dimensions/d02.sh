#!/usr/bin/env bash
# D2: Test Effectiveness — mutation testing, assertion density, coupling, flakiness
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

PROJECT_ROOT="${1:-$(pwd)}"

# --------------------------------------------------------------------------
# M2.1 — Mutation testing configuration
# --------------------------------------------------------------------------

# Stryker (JS/TS)
HAS_STRYKER_CONFIG=$(find "$PROJECT_ROOT" -maxdepth 3 \( -name "stryker.conf.*" -o -name ".stryker*" -o -name "stryker.config.*" \) "${EXCLUDE_DIRS[@]}" 2>/dev/null | wc -l | tr -d ' ')
HAS_STRYKER_DEP=$(count_pattern "@stryker-mutator" "package.json" "$PROJECT_ROOT")

# Pitest (Java)
HAS_PITEST=$(count_pattern "pitest" "*" "$PROJECT_ROOT")

# mutmut (Python)
HAS_MUTMUT=$(count_pattern "mutmut" "*" "$PROJECT_ROOT")

# cargo-mutants (Rust)
HAS_CARGO_MUTANTS=$(count_pattern "cargo-mutants" "*" "$PROJECT_ROOT")

MUTATION_TESTING_CONFIGURED="false"
if [[ $HAS_STRYKER_CONFIG -gt 0 ]] || [[ $HAS_STRYKER_DEP -gt 0 ]] || [[ $HAS_PITEST -gt 0 ]] || [[ $HAS_MUTMUT -gt 0 ]] || [[ $HAS_CARGO_MUTANTS -gt 0 ]]; then
  MUTATION_TESTING_CONFIGURED="true"
fi

# --------------------------------------------------------------------------
# M2.2 — Assertion density (sample-based)
# --------------------------------------------------------------------------

# Count total expect/assert calls across test files
EXPECT_COUNT=$(grep -r "expect(" "$PROJECT_ROOT" --include="*.test.*" --include="*.spec.*" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | wc -l | tr -d ' ' || echo "0")
ASSERT_COUNT=$(grep -r "assert" "$PROJECT_ROOT" --include="*.test.*" --include="*.spec.*" --include="*_test.*" --include="test_*" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | grep -v "import\|require\|from\|#" | wc -l | tr -d ' ' || echo "0")
TOTAL_ASSERTIONS=$((EXPECT_COUNT + ASSERT_COUNT))

# Count test blocks (it/test/describe)
IT_COUNT=$(grep -rE "^\s*(it|test)\(" "$PROJECT_ROOT" --include="*.test.*" --include="*.spec.*" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | wc -l | tr -d ' ' || echo "0")
DEF_TEST_COUNT=$(grep -rE "^\s*def test_" "$PROJECT_ROOT" --include="*.py" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | wc -l | tr -d ' ' || echo "0")
FUNC_TEST_COUNT=$(grep -rE "^func Test" "$PROJECT_ROOT" --include="*_test.go" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

TOTAL_TEST_BLOCKS=$((IT_COUNT + DEF_TEST_COUNT + FUNC_TEST_COUNT))

if [[ $TOTAL_TEST_BLOCKS -gt 0 ]]; then
  ASSERTION_DENSITY=$(echo "scale=1; $TOTAL_ASSERTIONS / $TOTAL_TEST_BLOCKS" | bc 2>/dev/null || echo "0")
else
  ASSERTION_DENSITY="0"
fi

# Snapshot-only tests
SNAPSHOT_COUNT=$(grep -rc "toMatchSnapshot\|toMatchInlineSnapshot\|matchSnapshot" "$PROJECT_ROOT" --include="*.test.*" --include="*.spec.*" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | grep -v ":0$" | wc -l | tr -d ' ' || echo "0")

# --------------------------------------------------------------------------
# M2.3 — Test-to-code coupling signals
# --------------------------------------------------------------------------

# SpyOn internal methods (implementation coupling)
SPYON_COUNT=$(grep -rc "spyOn\|jest\.spyOn\|vi\.spyOn" "$PROJECT_ROOT" --include="*.test.*" --include="*.spec.*" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | grep -v ":0$" | awk -F: '{s+=$2} END {print s+0}' || echo "0")

# Mock implementation calls (potential over-coupling)
MOCK_IMPL_COUNT=$(grep -rc "mockImplementation\|mockReturnValue\|mockResolvedValue" "$PROJECT_ROOT" --include="*.test.*" --include="*.spec.*" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | grep -v ":0$" | awk -F: '{s+=$2} END {print s+0}' || echo "0")

# Testing private/internal methods
PRIVATE_TEST_COUNT=$(grep -rc "\.prototype\.\|__private\|\._" "$PROJECT_ROOT" --include="*.test.*" --include="*.spec.*" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | grep -v ":0$" | awk -F: '{s+=$2} END {print s+0}' || echo "0")

# --------------------------------------------------------------------------
# M2.4 — Flaky test signals
# --------------------------------------------------------------------------

# Retry configuration
HAS_RETRY=$(grep -rl "retries\|retry\|flaky\|quarantine" "$PROJECT_ROOT" --include="*.config.*" --include="*.json" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

# Flaky test markers
FLAKY_MARKERS=$(grep -rl "\.skip\|\.todo\|@flaky\|@unstable\|quarantine" "$PROJECT_ROOT" --include="*.test.*" --include="*.spec.*" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

# Timeout usage in tests (potential flakiness indicator)
TIMEOUT_IN_TESTS=$(grep -rc "setTimeout\|waitFor\|waitForTimeout\|sleep" "$PROJECT_ROOT" --include="*.test.*" --include="*.spec.*" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | grep -v ":0$" | wc -l | tr -d ' ' || echo "0")

# --------------------------------------------------------------------------
# Output JSON
# --------------------------------------------------------------------------

cat << EOF
{
  "mutation_testing": {
    "configured": $MUTATION_TESTING_CONFIGURED,
    "stryker_config": $HAS_STRYKER_CONFIG,
    "stryker_dep": $HAS_STRYKER_DEP,
    "pitest": $HAS_PITEST,
    "mutmut": $HAS_MUTMUT,
    "cargo_mutants": $HAS_CARGO_MUTANTS
  },
  "assertion_density": {
    "total_assertions": $TOTAL_ASSERTIONS,
    "total_test_blocks": $TOTAL_TEST_BLOCKS,
    "avg_per_test": $ASSERTION_DENSITY,
    "snapshot_only_files": $SNAPSHOT_COUNT
  },
  "coupling": {
    "spyon_calls": $SPYON_COUNT,
    "mock_implementation_calls": $MOCK_IMPL_COUNT,
    "private_method_tests": $PRIVATE_TEST_COUNT
  },
  "flakiness": {
    "retry_config_files": $HAS_RETRY,
    "flaky_markers": $FLAKY_MARKERS,
    "timeout_in_tests": $TIMEOUT_IN_TESTS
  }
}
EOF
