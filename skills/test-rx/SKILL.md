---
name: test-rx
description: "Evaluates testing strategy and completeness across 8 dimensions (32 sub-metrics): test pyramid balance, test effectiveness, contract/API testing, UI/visual testing, performance/load testing, test data management, CI integration, and test organization. Produces a scored diagnostic with actionable improvement plans."
triggers:
  - "run test-rx"
  - "test strategy"
  - "evaluate tests"
  - "testing audit"
  - "test quality review"
---

## Prerequisites

Recommended: `lighthouse`, `pa11y`

Check all dependencies: `bash scripts/rx-deps.sh` or `bash scripts/rx-deps.sh --install`


# test-rx: Testing Strategy Diagnostic

## Purpose

Evaluate whether a codebase tests **the right things at the right level**. This is not about coverage percentages — it is about testing architecture, strategy completeness, and long-term maintainability.

## Dimensions (8) and Sub-Metrics (32)

### D1: Test Pyramid Balance (15%)
**Source:** Test Pyramid (Martin Fowler), Practical Test Pyramid (Ham Vocke)

| ID | Sub-Metric | What It Measures |
|----|-----------|-----------------|
| M1.1 | Unit test ratio | % of tests that are true unit tests (no I/O, no network, no DB) |
| M1.2 | Integration test coverage | API/DB integration tests present and covering critical paths |
| M1.3 | E2E test coverage | Critical user journeys covered by end-to-end tests |
| M1.4 | Pyramid shape | unit > integration > E2E count (not ice cream cone anti-pattern) |

### D2: Test Effectiveness (15%)
**Source:** Mutation Testing (Pitest, Stryker), Google Testing Blog

| ID | Sub-Metric | What It Measures |
|----|-----------|-----------------|
| M2.1 | Mutation score | % of mutants killed (via Stryker, Pitest, or similar) |
| M2.2 | Assertion density | Assertions per test — strong vs weak assertions |
| M2.3 | Test-to-code coupling | Tests break for the right reasons, not tied to implementation details |
| M2.4 | False positive rate | Flaky test tracking, quarantine process, retry policy |

### D3: Contract & API Testing (10%)
**Source:** Consumer-Driven Contracts (Pact), Schemathesis

| ID | Sub-Metric | What It Measures |
|----|-----------|-----------------|
| M3.1 | Contract test coverage | Pact or consumer-driven contract tests for API boundaries |
| M3.2 | Schema validation tests | OpenAPI/Zod/JSON Schema compliance tests |
| M3.3 | API integration tests | Real HTTP calls testing (not mocked handlers) |
| M3.4 | Backward compatibility tests | Breaking change detection in APIs |

### D4: UI & Visual Testing (10%)
**Source:** Chromatic, Percy, Playwright Visual Comparisons

| ID | Sub-Metric | What It Measures |
|----|-----------|-----------------|
| M4.1 | Component tests | Storybook/Testing Library for isolated UI component tests |
| M4.2 | Visual regression | Screenshot comparison integrated in CI |
| M4.3 | Accessibility testing in tests | axe-core or similar a11y checks in test suite |
| M4.4 | Cross-browser testing | Playwright/Cypress multi-browser configuration |

### D5: Performance & Load Testing (10%)
**Source:** k6, Artillery, Lighthouse CI

| ID | Sub-Metric | What It Measures |
|----|-----------|-----------------|
| M5.1 | Load test existence | k6/Artillery/Locust/Gatling scripts present |
| M5.2 | Performance budgets | Lighthouse CI thresholds, bundle size limits enforced |
| M5.3 | Benchmark tests | Response time baselines with regression detection |
| M5.4 | Stress & soak tests | Breaking point documented, memory leak detection |

### D6: Test Data Management (15%)
**Source:** Test Data Management patterns, Factory pattern (fishery, factory_bot)

| ID | Sub-Metric | What It Measures |
|----|-----------|-----------------|
| M6.1 | Test factories | Factory functions used (not inline object literals everywhere) |
| M6.2 | Database isolation | Per-test cleanup via transactions, truncation, or containers |
| M6.3 | Seed data management | Reproducible, versioned, environment-specific seeds |
| M6.4 | Mock & stub quality | Mock factories, no over-mocking, contract-based mocks |

### D7: CI Integration (15%)
**Source:** Continuous Delivery (Humble & Farley), DORA Metrics

| ID | Sub-Metric | What It Measures |
|----|-----------|-----------------|
| M7.1 | Test parallelization | Sharded/split test runs in CI |
| M7.2 | Fail-fast strategy | Unit tests run first, E2E last in pipeline |
| M7.3 | Test caching | Only re-run affected/changed tests |
| M7.4 | Test reporting | JUnit XML output, coverage reports, trend tracking |

### D8: Test Organization & Maintainability (10%)
**Source:** xUnit Test Patterns (Gerard Meszaros)

| ID | Sub-Metric | What It Measures |
|----|-----------|-----------------|
| M8.1 | Test file structure | Co-located with source or consistent mirror structure |
| M8.2 | Test naming conventions | Descriptive, behavior-focused test names |
| M8.3 | Shared test utilities | Custom helpers, matchers, fixtures, test builders |
| M8.4 | Test documentation | Test plan, coverage requirements, testing guide present |

## Process Overview

```
1. DISCOVER  ─  Run discover.sh to scan the codebase
2. ANALYZE   ─  4 parallel agents score dimensions
3. SCORE     ─  Aggregate into weighted scorecard
4. PRESCRIBE ─  Generate improvement plan with priorities
```

### Step 1: Discovery

Run the discovery script to collect raw signals from the codebase:

```bash
bash ~/.claude/skills/test-rx/scripts/discover.sh "$PROJECT_ROOT"
```

This produces `test-rx-discovery.json` with counts, file lists, and pattern matches for all 32 sub-metrics.

### Step 2: Parallel Analysis (4 Agents)

Launch 4 agents in parallel, each covering 2 dimensions:

| Agent | Dimensions | Weight |
|-------|-----------|--------|
| Agent A | D1 (Pyramid Balance) + D2 (Effectiveness) | 30% |
| Agent B | D3 (Contract/API) + D4 (UI/Visual) | 20% |
| Agent C | D5 (Performance) + D6 (Data Management) | 25% |
| Agent D | D7 (CI Integration) + D8 (Organization) | 25% |

Each agent:
1. Reads the discovery JSON
2. Reads relevant source and test files
3. Scores each sub-metric 0-10 using the grading framework
4. Writes findings to `test-rx-d{N}.json`

### Step 3: Scorecard Aggregation

Combine all dimension scores into the final scorecard:

```
FINAL SCORE = SUM(dimension_score * dimension_weight)
```

### Step 4: Output

Generate the scorecard in this format:

```
============================================================
  TEST-RX DIAGNOSTIC SCORECARD
  Project: {project_name}
  Date: {date}
  Final Score: {score}/100 — Grade: {grade}
============================================================

  D1  Test Pyramid Balance     ████████░░  {score}/10  (15%)
  D2  Test Effectiveness       ██████░░░░  {score}/10  (15%)
  D3  Contract & API Testing   ████░░░░░░  {score}/10  (10%)
  D4  UI & Visual Testing      ██░░░░░░░░  {score}/10  (10%)
  D5  Performance & Load       ███░░░░░░░  {score}/10  (10%)
  D6  Test Data Management     ████████░░  {score}/10  (15%)
  D7  CI Integration           ███████░░░  {score}/10  (15%)
  D8  Test Organization        ██████░░░░  {score}/10  (10%)

  WEIGHTED TOTAL: {total}/100

  Grade Scale:
    90-100  A  Exemplary testing strategy
    80-89   B  Strong with minor gaps
    70-79   C  Adequate, clear improvement areas
    60-69   D  Significant strategy gaps
    <60     F  Testing strategy needs overhaul
============================================================
```

## Rules

1. **Score only what exists.** Do not give credit for intent or plans.
2. **Weigh strategy over quantity.** 50 good unit tests beat 500 trivial ones.
3. **Penalize anti-patterns.** Ice cream cone, over-mocking, snapshot-only testing, implementation-coupled tests.
4. **Credit test infrastructure.** Factories, custom matchers, CI integration are force multipliers.
5. **Context matters.** A CLI tool does not need visual regression tests. Adjust D4 expectations by project type.
6. **Flag risks.** No integration tests on a microservice is a critical risk regardless of unit coverage.
7. **Be specific.** Every finding must reference a concrete file, pattern, or configuration.
8. **Improvement plans are mandatory.** Every sub-metric scoring below 7 gets a concrete action item.

## Auto-Plan Integration

After generating the scorecard and saving the report to `docs/audits/`:
1. Save a copy of the report to `docs/rx-plans/{this-skill-name}/{date}-report.md`
2. For each dimension scoring below 97, invoke the `rx-plan` skill to create or update the improvement plan at `docs/rx-plans/{this-skill-name}/{dimension}/v{N}-{date}-plan.md`
3. Update `docs/rx-plans/{this-skill-name}/summary.md` with current scores
4. Update `docs/rx-plans/dashboard.md` with overall progress

This happens automatically — the user does not need to run `/rx-plan` separately.
