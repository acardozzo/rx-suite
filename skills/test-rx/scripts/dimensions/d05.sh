#!/usr/bin/env bash
# D5: Performance & Load Testing — load tests, perf budgets, benchmarks, stress tests
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

PROJECT_ROOT="${1:-$(pwd)}"

# --------------------------------------------------------------------------
# M5.1 — Load test existence
# --------------------------------------------------------------------------

# k6
K6_FILES=$(find "$PROJECT_ROOT" -type f \( -name "*.k6.*" -o -name "k6.*" -o -name "load-test.*" -o -name "loadtest.*" \) "${EXCLUDE_DIRS[@]}" 2>/dev/null | wc -l | tr -d ' ')
K6_IMPORTS=$(grep -rl "from 'k6\|import.*k6\|require.*k6" "$PROJECT_ROOT" --include="*.js" --include="*.ts" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

# Artillery
ARTILLERY_FILES=$(find "$PROJECT_ROOT" -type f \( -name "artillery.*" -o -name "*.artillery.*" \) "${EXCLUDE_DIRS[@]}" 2>/dev/null | wc -l | tr -d ' ')
HAS_ARTILLERY_DEP=$(count_pattern "artillery" "package.json" "$PROJECT_ROOT")

# Locust (Python)
LOCUST_FILES=$(find "$PROJECT_ROOT" -type f -name "locustfile*" "${EXCLUDE_DIRS[@]}" 2>/dev/null | wc -l | tr -d ' ')
HAS_LOCUST=$(count_pattern "locust" "requirements*.txt" "$PROJECT_ROOT")

# Gatling (JVM)
GATLING_FILES=$(find "$PROJECT_ROOT" -type f -name "*.scala" -path "*/gatling/*" "${EXCLUDE_DIRS[@]}" 2>/dev/null | wc -l | tr -d ' ')

# vegeta (Go)
VEGETA_FILES=$(grep -rl "vegeta" "$PROJECT_ROOT" --include="*.go" --include="*.sh" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

# wrk/wrk2
WRK_FILES=$(find "$PROJECT_ROOT" -type f -name "*.wrk.*" "${EXCLUDE_DIRS[@]}" 2>/dev/null | wc -l | tr -d ' ')

LOAD_TEST_TOTAL=$((K6_FILES + K6_IMPORTS + ARTILLERY_FILES + LOCUST_FILES + GATLING_FILES + VEGETA_FILES + WRK_FILES))

# --------------------------------------------------------------------------
# M5.2 — Performance budgets
# --------------------------------------------------------------------------

# Lighthouse CI
LHCI_CONFIG=$(find "$PROJECT_ROOT" -maxdepth 3 \( -name "lighthouserc.*" -o -name ".lighthouserc.*" -o -name "lighthouse-ci.*" \) "${EXCLUDE_DIRS[@]}" 2>/dev/null | wc -l | tr -d ' ')
HAS_LHCI_DEP=$(count_pattern "@lhci/cli\|lighthouse-ci" "package.json" "$PROJECT_ROOT")

# Bundle size limits
HAS_BUNDLESIZE=$(count_pattern "bundlesize\|size-limit\|@size-limit" "package.json" "$PROJECT_ROOT")
BUNDLESIZE_CONFIG=$(find "$PROJECT_ROOT" -maxdepth 3 \( -name ".size-limit.*" -o -name "bundlesize.*" \) "${EXCLUDE_DIRS[@]}" 2>/dev/null | wc -l | tr -d ' ')

# Next.js bundle analyzer
HAS_BUNDLE_ANALYZER=$(count_pattern "@next/bundle-analyzer\|webpack-bundle-analyzer" "package.json" "$PROJECT_ROOT")

# Performance budget in CI
PERF_IN_CI=$(grep -rl "lighthouse\|size-limit\|bundlesize\|performance" "$PROJECT_ROOT" --include="*.yml" --include="*.yaml" -path "*/.github/*" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

# --------------------------------------------------------------------------
# M5.3 — Benchmark tests
# --------------------------------------------------------------------------

# vitest bench
VITEST_BENCH=$(find "$PROJECT_ROOT" -type f -name "*.bench.*" "${EXCLUDE_DIRS[@]}" 2>/dev/null | wc -l | tr -d ' ')

# Go benchmarks
GO_BENCH=$(grep -rl "func Benchmark" "$PROJECT_ROOT" --include="*_test.go" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

# criterion (Rust)
CRITERION_FILES=$(grep -rl "criterion" "$PROJECT_ROOT" --include="*.rs" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

# JMH (Java)
JMH_FILES=$(grep -rl "@Benchmark\|jmh" "$PROJECT_ROOT" --include="*.java" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

# hyperfine / bench scripts
BENCH_SCRIPTS=$(find "$PROJECT_ROOT" -type f \( -name "*benchmark*" -o -name "*bench*" \) \( -name "*.sh" -o -name "*.js" -o -name "*.ts" \) "${EXCLUDE_DIRS[@]}" 2>/dev/null | wc -l | tr -d ' ')

BENCHMARK_TOTAL=$((VITEST_BENCH + GO_BENCH + CRITERION_FILES + JMH_FILES + BENCH_SCRIPTS))

# --------------------------------------------------------------------------
# M5.4 — Stress & soak tests
# --------------------------------------------------------------------------

STRESS_FILES=$(find "$PROJECT_ROOT" -type f \( -name "*stress*" -o -name "*soak*" -o -name "*endurance*" \) "${EXCLUDE_DIRS[@]}" 2>/dev/null | wc -l | tr -d ' ')
STRESS_IN_SCRIPTS=$(grep -rl "stress\|soak\|endurance\|breaking.point" "$PROJECT_ROOT" --include="*.k6.*" --include="*.artillery.*" --include="locustfile*" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

# Memory leak detection
MEMORY_LEAK_TESTS=$(grep -rl "memoryUsage\|heapUsed\|memory_profiler\|tracemalloc\|pprof" "$PROJECT_ROOT" --include="*.test.*" --include="*.spec.*" --include="*_test.*" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

# --------------------------------------------------------------------------
# Output JSON
# --------------------------------------------------------------------------

cat << EOF
{
  "load_testing": {
    "total_load_test_files": $LOAD_TEST_TOTAL,
    "k6_files": $K6_FILES,
    "k6_imports": $K6_IMPORTS,
    "artillery_files": $ARTILLERY_FILES,
    "artillery_dep": $HAS_ARTILLERY_DEP,
    "locust_files": $LOCUST_FILES,
    "locust_dep": $HAS_LOCUST,
    "gatling_files": $GATLING_FILES,
    "vegeta_files": $VEGETA_FILES,
    "wrk_files": $WRK_FILES
  },
  "performance_budgets": {
    "lighthouse_ci_config": $LHCI_CONFIG,
    "lighthouse_ci_dep": $HAS_LHCI_DEP,
    "bundlesize_dep": $HAS_BUNDLESIZE,
    "bundlesize_config": $BUNDLESIZE_CONFIG,
    "bundle_analyzer": $HAS_BUNDLE_ANALYZER,
    "perf_in_ci": $PERF_IN_CI
  },
  "benchmarks": {
    "total_benchmark_files": $BENCHMARK_TOTAL,
    "vitest_bench": $VITEST_BENCH,
    "go_bench": $GO_BENCH,
    "criterion_files": $CRITERION_FILES,
    "jmh_files": $JMH_FILES,
    "bench_scripts": $BENCH_SCRIPTS
  },
  "stress_soak": {
    "stress_files": $STRESS_FILES,
    "stress_in_load_scripts": $STRESS_IN_SCRIPTS,
    "memory_leak_tests": $MEMORY_LEAK_TESTS
  }
}
EOF
