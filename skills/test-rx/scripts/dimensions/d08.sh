#!/usr/bin/env bash
# D8: Test Organization & Maintainability — file structure, naming, utilities, documentation
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

PROJECT_ROOT="${1:-$(pwd)}"

# --------------------------------------------------------------------------
# M8.1 — Test file structure
# --------------------------------------------------------------------------

# Co-located tests (test file next to source)
COLOCATED_TESTS=$(find "$PROJECT_ROOT" -type f \( -name "*.test.ts" -o -name "*.test.tsx" -o -name "*.test.js" -o -name "*.spec.ts" -o -name "*.spec.tsx" \) "${EXCLUDE_DIRS[@]}" 2>/dev/null | grep -v "__tests__\|/tests/\|/test/\|/e2e/" | wc -l | tr -d ' ')

# __tests__ directory pattern
DUNDER_TEST_DIRS=$(find "$PROJECT_ROOT" -type d -name "__tests__" "${EXCLUDE_DIRS[@]}" 2>/dev/null | wc -l | tr -d ' ')
DUNDER_TEST_FILES=$(find "$PROJECT_ROOT" -type f -path "*/__tests__/*" "${EXCLUDE_DIRS[@]}" 2>/dev/null | wc -l | tr -d ' ')

# Separate test directory (mirror structure)
SEPARATE_TEST_DIR=$(find "$PROJECT_ROOT" -maxdepth 2 -type d \( -name "tests" -o -name "test" -o -name "spec" \) "${EXCLUDE_DIRS[@]}" 2>/dev/null | wc -l | tr -d ' ')
SEPARATE_TEST_FILES=$(find "$PROJECT_ROOT" -type f \( -path "*/tests/*" -o -path "*/test/*" -o -path "*/spec/*" \) \( -name "*.test.*" -o -name "*.spec.*" -o -name "*_test.*" -o -name "test_*" \) "${EXCLUDE_DIRS[@]}" 2>/dev/null | grep -v __tests__ | wc -l | tr -d ' ')

# Determine dominant pattern
if [[ $COLOCATED_TESTS -gt $DUNDER_TEST_FILES ]] && [[ $COLOCATED_TESTS -gt $SEPARATE_TEST_FILES ]]; then
  TEST_STRUCTURE="colocated"
elif [[ $DUNDER_TEST_FILES -gt $SEPARATE_TEST_FILES ]]; then
  TEST_STRUCTURE="__tests__"
elif [[ $SEPARATE_TEST_FILES -gt 0 ]]; then
  TEST_STRUCTURE="separate"
else
  TEST_STRUCTURE="none"
fi

# --------------------------------------------------------------------------
# M8.2 — Test naming conventions
# --------------------------------------------------------------------------

# Behavior-focused names (should/when/given patterns)
BEHAVIOR_NAMES=$(grep -rEc "(should|when|given|returns|throws|renders|displays|navigates|creates|updates|deletes)" "$PROJECT_ROOT" --include="*.test.*" --include="*.spec.*" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | awk '{s+=$1} END {print s+0}' || echo "0")

# describe block organization
DESCRIBE_BLOCKS=$(grep -rc "describe(" "$PROJECT_ROOT" --include="*.test.*" --include="*.spec.*" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | grep -v ":0$" | awk -F: '{s+=$2} END {print s+0}' || echo "0")

# it/test block names
IT_BLOCKS=$(grep -rc "it(\|test(" "$PROJECT_ROOT" --include="*.test.*" --include="*.spec.*" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | grep -v ":0$" | awk -F: '{s+=$2} END {print s+0}' || echo "0")

# Generic/poor names (test1, test2, works, etc.)
GENERIC_NAMES=$(grep -rEc "(test[0-9]|it works|test works|should work$)" "$PROJECT_ROOT" --include="*.test.*" --include="*.spec.*" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | awk '{s+=$1} END {print s+0}' || echo "0")

# --------------------------------------------------------------------------
# M8.3 — Shared test utilities
# --------------------------------------------------------------------------

# Test utility directories
TEST_UTILS_DIRS=$(find "$PROJECT_ROOT" -type d \( -name "test-utils" -o -name "test-helpers" -o -name "testing" -o -name "test-support" \) "${EXCLUDE_DIRS[@]}" 2>/dev/null | wc -l | tr -d ' ')

# Test utility files
TEST_UTILS_FILES=$(find "$PROJECT_ROOT" -type f \( -name "test-utils.*" -o -name "test-helpers.*" -o -name "testing-utils.*" -o -name "testUtils.*" -o -name "setupTests.*" -o -name "setup.*" -o -name "helpers.*" \) "${EXCLUDE_DIRS[@]}" 2>/dev/null | grep -i "test\|spec\|setup" | wc -l | tr -d ' ')

# Custom matchers
CUSTOM_MATCHERS=$(grep -rl "expect\.extend\|addMatcher\|custom.*matcher\|toCustom" "$PROJECT_ROOT" --include="*.ts" --include="*.js" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

# Custom render functions (Testing Library)
CUSTOM_RENDER=$(grep -rl "customRender\|renderWithProviders\|renderWith\|AllTheProviders\|wrapper:" "$PROJECT_ROOT" --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

# Shared fixtures
SHARED_FIXTURES=$(find "$PROJECT_ROOT" -type d \( -name "fixtures" -o -name "__fixtures__" -o -name "conftest" \) "${EXCLUDE_DIRS[@]}" 2>/dev/null | wc -l | tr -d ' ')
CONFTEST_FILES=$(find "$PROJECT_ROOT" -type f -name "conftest.py" "${EXCLUDE_DIRS[@]}" 2>/dev/null | wc -l | tr -d ' ')

# --------------------------------------------------------------------------
# M8.4 — Test documentation
# --------------------------------------------------------------------------

# TESTING.md or test documentation
TESTING_DOC=$(find "$PROJECT_ROOT" -maxdepth 2 -type f \( -name "TESTING.md" -o -name "TESTING.rst" -o -name "testing.md" -o -name "TEST_PLAN.md" -o -name "test-plan.md" \) 2>/dev/null | wc -l | tr -d ' ')

# Testing section in README
README_TEST_SECTION=$(grep -cl "## Testing\|## Tests\|## Test\|## Running Tests\|## How to Test" "$PROJECT_ROOT"/README* 2>/dev/null | wc -l | tr -d ' ' || echo "0")

# Contributing guide with test instructions
CONTRIBUTING_TEST=$(grep -cl "test\|Test" "$PROJECT_ROOT"/CONTRIBUTING* 2>/dev/null | wc -l | tr -d ' ' || echo "0")

# Coverage requirements documented
COVERAGE_DOC=$(grep -rl "coverage requirement\|minimum coverage\|coverage threshold\|test coverage" "$PROJECT_ROOT" --include="*.md" --include="*.rst" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

# --------------------------------------------------------------------------
# Output JSON
# --------------------------------------------------------------------------

cat << EOF
{
  "file_structure": {
    "dominant_pattern": "$TEST_STRUCTURE",
    "colocated_tests": $COLOCATED_TESTS,
    "dunder_test_dirs": $DUNDER_TEST_DIRS,
    "dunder_test_files": $DUNDER_TEST_FILES,
    "separate_test_dirs": $SEPARATE_TEST_DIR,
    "separate_test_files": $SEPARATE_TEST_FILES
  },
  "naming": {
    "behavior_focused_names": $BEHAVIOR_NAMES,
    "describe_blocks": $DESCRIBE_BLOCKS,
    "it_test_blocks": $IT_BLOCKS,
    "generic_poor_names": $GENERIC_NAMES
  },
  "shared_utilities": {
    "test_utils_dirs": $TEST_UTILS_DIRS,
    "test_utils_files": $TEST_UTILS_FILES,
    "custom_matchers": $CUSTOM_MATCHERS,
    "custom_render": $CUSTOM_RENDER,
    "shared_fixtures": $SHARED_FIXTURES,
    "conftest_files": $CONFTEST_FILES
  },
  "documentation": {
    "testing_doc": $TESTING_DOC,
    "readme_test_section": $README_TEST_SECTION,
    "contributing_test": $CONTRIBUTING_TEST,
    "coverage_doc": $COVERAGE_DOC
  }
}
EOF
