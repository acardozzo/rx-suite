#!/usr/bin/env bash
# D7: CI Integration — parallelization, fail-fast, caching, reporting
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

PROJECT_ROOT="${1:-$(pwd)}"

# --------------------------------------------------------------------------
# CI config detection
# --------------------------------------------------------------------------

# GitHub Actions
GHA_FILES=$(find "$PROJECT_ROOT/.github/workflows" -type f \( -name "*.yml" -o -name "*.yaml" \) 2>/dev/null | wc -l | tr -d ' ')
GHA_TEST_FILES=$(grep -rl "test\|jest\|vitest\|pytest\|go test\|cargo test" "$PROJECT_ROOT/.github/workflows/" --include="*.yml" --include="*.yaml" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

# GitLab CI
GITLAB_CI=$(find "$PROJECT_ROOT" -maxdepth 1 -name ".gitlab-ci.yml" 2>/dev/null | wc -l | tr -d ' ')

# CircleCI
CIRCLECI=$(find "$PROJECT_ROOT/.circleci" -name "config.yml" 2>/dev/null | wc -l | tr -d ' ')

# Jenkins
JENKINSFILE=$(find "$PROJECT_ROOT" -maxdepth 1 -name "Jenkinsfile" 2>/dev/null | wc -l | tr -d ' ')

# Azure Pipelines
AZURE_PIPELINES=$(find "$PROJECT_ROOT" -maxdepth 1 -name "azure-pipelines.yml" 2>/dev/null | wc -l | tr -d ' ')

CI_PLATFORM="none"
if [[ $GHA_FILES -gt 0 ]]; then CI_PLATFORM="github_actions"
elif [[ $GITLAB_CI -gt 0 ]]; then CI_PLATFORM="gitlab"
elif [[ $CIRCLECI -gt 0 ]]; then CI_PLATFORM="circleci"
elif [[ $JENKINSFILE -gt 0 ]]; then CI_PLATFORM="jenkins"
elif [[ $AZURE_PIPELINES -gt 0 ]]; then CI_PLATFORM="azure"
fi

# --------------------------------------------------------------------------
# M7.1 — Test parallelization
# --------------------------------------------------------------------------

# Shard config in CI
SHARD_IN_CI=$(grep -rl "shard\|split\|parallel\|matrix" "$PROJECT_ROOT/.github/workflows/" --include="*.yml" --include="*.yaml" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

# Jest/Vitest workers
WORKER_CONFIG=$(grep -rl "maxWorkers\|--workers\|maxConcurrency\|--shard" "$PROJECT_ROOT" --include="*.config.*" --include="package.json" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

# Playwright shard
PLAYWRIGHT_SHARD=$(grep -rl "shard\|workers\|fullyParallel" "$PROJECT_ROOT" --include="playwright.config.*" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

# pytest-xdist
PYTEST_XDIST=$(count_pattern "pytest-xdist\|xdist\|-n auto" "*" "$PROJECT_ROOT")

# Go test -parallel
GO_PARALLEL=$(grep -rl "t\.Parallel\|go test.*-parallel" "$PROJECT_ROOT" --include="*_test.go" --include="*.sh" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

# --------------------------------------------------------------------------
# M7.2 — Fail-fast strategy
# --------------------------------------------------------------------------

# Count CI stages/jobs
CI_STAGES=0
if [[ $GHA_FILES -gt 0 ]]; then
  CI_STAGES=$(grep -c "jobs:" "$PROJECT_ROOT/.github/workflows/"*.yml "$PROJECT_ROOT/.github/workflows/"*.yaml 2>/dev/null | awk -F: '{s+=$2} END {print s+0}' || echo "0")
fi

# bail/failFast config
BAIL_CONFIG=$(grep -rl "bail\|failFast\|fail-fast\|--bail" "$PROJECT_ROOT" --include="*.config.*" --include="package.json" --include="*.yml" --include="*.yaml" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

# Needs/depends_on between jobs (gating)
JOB_DEPENDENCIES=$(grep -c "needs:" "$PROJECT_ROOT/.github/workflows/"*.yml "$PROJECT_ROOT/.github/workflows/"*.yaml 2>/dev/null | awk -F: '{s+=$2} END {print s+0}' || echo "0")

# Lint step before tests
LINT_BEFORE_TEST=$(grep -rl "lint\|eslint\|prettier\|format" "$PROJECT_ROOT/.github/workflows/" --include="*.yml" --include="*.yaml" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

# --------------------------------------------------------------------------
# M7.3 — Test caching
# --------------------------------------------------------------------------

# Nx affected
HAS_NX_AFFECTED=$(grep -rl "nx affected\|nx:affected" "$PROJECT_ROOT" --include="*.yml" --include="*.yaml" --include="package.json" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

# Turbo cache
HAS_TURBO=$(find "$PROJECT_ROOT" -maxdepth 1 -name "turbo.json" 2>/dev/null | wc -l | tr -d ' ')
TURBO_CACHE=$(grep -c "cache" "$PROJECT_ROOT/turbo.json" 2>/dev/null || echo "0")

# CI cache steps
CI_CACHE_STEPS=$(grep -rc "actions/cache\|cache:\|restore_cache\|save_cache" "$PROJECT_ROOT/.github/workflows/"*.yml "$PROJECT_ROOT/.github/workflows/"*.yaml "$PROJECT_ROOT/.circleci/config.yml" 2>/dev/null | grep -v ":0$" | awk -F: '{s+=$2} END {print s+0}' || echo "0")

# --------------------------------------------------------------------------
# M7.4 — Test reporting
# --------------------------------------------------------------------------

# JUnit reporter config
JUNIT_REPORTER=$(grep -rl "junit\|JUnit\|--reporter.*junit\|JEST_JUNIT\|junit-reporter" "$PROJECT_ROOT" --include="*.config.*" --include="package.json" --include="*.yml" --include="*.yaml" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

# Coverage reporting
CODECOV=$(grep -rl "codecov\|Codecov\|CODECOV" "$PROJECT_ROOT" --include="*.yml" --include="*.yaml" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | wc -l | tr -d ' ' || echo "0")
COVERALLS=$(grep -rl "coveralls\|Coveralls" "$PROJECT_ROOT" --include="*.yml" --include="*.yaml" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | wc -l | tr -d ' ' || echo "0")
CODECOV_CONFIG=$(find "$PROJECT_ROOT" -maxdepth 2 \( -name "codecov.yml" -o -name ".codecov.yml" -o -name "codecov.yaml" \) 2>/dev/null | wc -l | tr -d ' ')

# Coverage thresholds in config
COVERAGE_THRESHOLDS=$(grep -rl "coverageThreshold\|--coverage\|--cov\|coverage.*minimum\|branches.*[0-9]" "$PROJECT_ROOT" --include="*.config.*" --include="package.json" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

# PR comment with test results
PR_COMMENT=$(grep -rl "test-results\|comment.*coverage\|coverage.*comment\|marocchino/sticky-pull-request-comment" "$PROJECT_ROOT/.github/workflows/" --include="*.yml" --include="*.yaml" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

# --------------------------------------------------------------------------
# Output JSON
# --------------------------------------------------------------------------

cat << EOF
{
  "ci_platform": "$CI_PLATFORM",
  "ci_files": {
    "github_actions": $GHA_FILES,
    "github_test_workflows": $GHA_TEST_FILES,
    "gitlab": $GITLAB_CI,
    "circleci": $CIRCLECI,
    "jenkins": $JENKINSFILE,
    "azure": $AZURE_PIPELINES
  },
  "parallelization": {
    "shard_in_ci": $SHARD_IN_CI,
    "worker_config": $WORKER_CONFIG,
    "playwright_shard": $PLAYWRIGHT_SHARD,
    "pytest_xdist": $PYTEST_XDIST,
    "go_parallel": $GO_PARALLEL
  },
  "fail_fast": {
    "ci_stages": $CI_STAGES,
    "bail_config": $BAIL_CONFIG,
    "job_dependencies": $JOB_DEPENDENCIES,
    "lint_before_test": $LINT_BEFORE_TEST
  },
  "caching": {
    "nx_affected": $HAS_NX_AFFECTED,
    "turbo_json": $HAS_TURBO,
    "turbo_cache": $TURBO_CACHE,
    "ci_cache_steps": $CI_CACHE_STEPS
  },
  "reporting": {
    "junit_reporter": $JUNIT_REPORTER,
    "codecov": $CODECOV,
    "coveralls": $COVERALLS,
    "codecov_config": $CODECOV_CONFIG,
    "coverage_thresholds": $COVERAGE_THRESHOLDS,
    "pr_comment": $PR_COMMENT
  }
}
EOF
