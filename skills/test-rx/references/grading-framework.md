# test-rx Grading Framework

Complete threshold tables for all 32 sub-metrics. Each sub-metric is scored 0-10.

---

## D1: Test Pyramid Balance (15%)

### M1.1 — Unit Test Ratio

| Score | Threshold | Evidence |
|-------|----------|---------|
| 10 | >= 70% of all tests are true unit tests (no I/O) | Count unit vs integration/E2E files |
| 8 | 55-69% unit tests | |
| 6 | 40-54% unit tests | |
| 4 | 25-39% unit tests | |
| 2 | 10-24% unit tests | |
| 0 | < 10% or no tests at all | |

### M1.2 — Integration Test Coverage

| Score | Threshold | Evidence |
|-------|----------|---------|
| 10 | All API endpoints and DB operations have integration tests; test containers or real DB used | Look for supertest, httpx, testcontainers |
| 8 | >= 80% of critical paths covered | |
| 6 | >= 50% of critical paths covered | |
| 4 | Some integration tests exist but gaps in critical paths | |
| 2 | Minimal integration tests (1-3 files) | |
| 0 | No integration tests | |

### M1.3 — E2E Test Coverage

| Score | Threshold | Evidence |
|-------|----------|---------|
| 10 | All critical user journeys have E2E tests; Playwright/Cypress with defined scenarios | Look for *.spec.ts, *.e2e.ts, playwright.config |
| 8 | >= 80% of critical journeys covered | |
| 6 | >= 50% of critical journeys covered | |
| 4 | Some E2E tests but major journeys missing | |
| 2 | Minimal E2E (smoke test only) | |
| 0 | No E2E tests | |

### M1.4 — Pyramid Shape

| Score | Threshold | Evidence |
|-------|----------|---------|
| 10 | Classic pyramid: unit >> integration >> E2E (ratio >= 5:3:1) | Compare test counts by type |
| 8 | Healthy pyramid (ratio >= 3:2:1) | |
| 6 | Slight imbalance but unit tests still dominate | |
| 4 | Diamond shape (integration heavy) | |
| 2 | Ice cream cone (E2E > unit) or hourglass | |
| 0 | Single layer only or no tests | |

---

## D2: Test Effectiveness (15%)

### M2.1 — Mutation Score

| Score | Threshold | Evidence |
|-------|----------|---------|
| 10 | Mutation testing configured and running in CI; score >= 80% | Stryker config, pitest, mutmut |
| 8 | Mutation testing configured; score >= 60% | |
| 6 | Mutation testing configured but not in CI; score >= 40% | |
| 4 | Mutation testing attempted but not maintained | |
| 2 | No mutation testing but high assertion density (>3 per test) | |
| 0 | No mutation testing, low assertion density | |

### M2.2 — Assertion Density

| Score | Threshold | Evidence |
|-------|----------|---------|
| 10 | Average >= 3 assertions per test; mix of value, type, and behavior assertions | Count expect/assert per test block |
| 8 | Average >= 2.5 assertions; meaningful assertions | |
| 6 | Average >= 2 assertions per test | |
| 4 | Average >= 1.5 assertions; some tests with only 1 | |
| 2 | Many tests with single assertion or snapshot-only | |
| 0 | Tests with no assertions (smoke tests only) or trivial assertions | |

### M2.3 — Test-to-Code Coupling

| Score | Threshold | Evidence |
|-------|----------|---------|
| 10 | Tests verify behavior/output, not implementation; no mocking of internals; refactor-safe | Review test patterns |
| 8 | Mostly behavior-based; < 10% test implementation details | |
| 6 | Mixed approach; some implementation coupling present | |
| 4 | Significant coupling to internal methods/state | |
| 2 | Heavy use of spyOn internal methods, testing private APIs | |
| 0 | Tests are mirrors of implementation; break on any refactor | |

### M2.4 — False Positive Rate (Flaky Tests)

| Score | Threshold | Evidence |
|-------|----------|---------|
| 10 | Flaky test tracking; quarantine process; < 1% flaky rate; retry policy documented | Look for .flaky, quarantine dirs |
| 8 | Retry mechanism in CI; known flaky tests tracked | |
| 6 | Some retry config; occasional flakiness acknowledged | |
| 4 | No formal tracking but timeouts/retries configured | |
| 2 | Known flaky tests not addressed | |
| 0 | No awareness of flaky tests; tests randomly fail in CI | |

---

## D3: Contract & API Testing (10%)

### M3.1 — Contract Test Coverage

| Score | Threshold | Evidence |
|-------|----------|---------|
| 10 | Pact or similar consumer-driven contract tests for all API boundaries | pact*.json, contract test files |
| 8 | Contract tests for >= 80% of API boundaries | |
| 6 | Contract tests for critical APIs | |
| 4 | Some contract awareness but incomplete | |
| 2 | Manual API compatibility checking | |
| 0 | No contract testing | |

### M3.2 — Schema Validation Tests

| Score | Threshold | Evidence |
|-------|----------|---------|
| 10 | All API responses validated against OpenAPI/Zod/JSON Schema in tests | Look for schema imports in test files |
| 8 | >= 80% of endpoints have schema validation | |
| 6 | Critical endpoints have schema validation | |
| 4 | Some schema validation but inconsistent | |
| 2 | Schema exists but not used in tests | |
| 0 | No schema validation in tests | |

### M3.3 — API Integration Tests

| Score | Threshold | Evidence |
|-------|----------|---------|
| 10 | Real HTTP calls in tests (supertest/httpx); full request-response cycle tested | Look for supertest, request(), httpx |
| 8 | >= 80% of endpoints tested with real HTTP | |
| 6 | Critical endpoints have real HTTP tests | |
| 4 | Mix of real HTTP and mocked handlers | |
| 2 | Mostly mocked HTTP handlers (msw without integration layer) | |
| 0 | No API integration tests; all handlers mocked | |

### M3.4 — Backward Compatibility Tests

| Score | Threshold | Evidence |
|-------|----------|---------|
| 10 | Automated breaking change detection (openapi-diff, buf breaking); CI enforced | Look for diff tools in CI |
| 8 | Breaking change detection configured | |
| 6 | Manual review process for API changes | |
| 4 | Versioned APIs but no automated detection | |
| 2 | Awareness of compatibility but no process | |
| 0 | No backward compatibility consideration | |

---

## D4: UI & Visual Testing (10%)

### M4.1 — Component Tests

| Score | Threshold | Evidence |
|-------|----------|---------|
| 10 | All shared/reusable components have isolated tests (Testing Library/Storybook interaction tests) | *.stories.tsx, render() in tests |
| 8 | >= 80% of shared components tested | |
| 6 | >= 50% of components tested | |
| 4 | Some component tests but major gaps | |
| 2 | Minimal component tests (< 20%) | |
| 0 | No component-level tests | |

### M4.2 — Visual Regression

| Score | Threshold | Evidence |
|-------|----------|---------|
| 10 | Chromatic/Percy/Playwright visual comparison in CI; baseline management process | chromatic config, percy config |
| 8 | Visual regression configured and running | |
| 6 | Visual regression configured but not in CI | |
| 4 | Manual visual review process | |
| 2 | Storybook exists but no visual comparison | |
| 0 | No visual regression testing | |

### M4.3 — Accessibility Testing in Tests

| Score | Threshold | Evidence |
|-------|----------|---------|
| 10 | axe-core/jest-axe integrated; all component tests include a11y checks; CI enforced | toHaveNoViolations, axe import |
| 8 | a11y testing for >= 80% of components | |
| 6 | a11y testing for critical components/pages | |
| 4 | Some a11y tests but inconsistent | |
| 2 | a11y tool installed but rarely used in tests | |
| 0 | No accessibility testing | |

### M4.4 — Cross-Browser Testing

| Score | Threshold | Evidence |
|-------|----------|---------|
| 10 | Playwright multi-browser (chromium, firefox, webkit); all E2E run cross-browser in CI | playwright.config projects |
| 8 | >= 2 browsers configured and tested | |
| 6 | Multiple browsers configured but only 1 in CI | |
| 4 | Single browser with plans for more | |
| 2 | Chromium-only testing | |
| 0 | No browser testing or no cross-browser consideration | |

---

## D5: Performance & Load Testing (10%)

### M5.1 — Load Test Existence

| Score | Threshold | Evidence |
|-------|----------|---------|
| 10 | k6/Artillery/Locust/Gatling scripts; integrated in CI; thresholds defined | *.k6.js, artillery.yml, locustfile.py |
| 8 | Load test scripts present and maintained; run periodically | |
| 6 | Load test scripts present but not in CI | |
| 4 | Basic load test scripts, not maintained | |
| 2 | Load testing planned but not implemented | |
| 0 | No load testing | |

### M5.2 — Performance Budgets

| Score | Threshold | Evidence |
|-------|----------|---------|
| 10 | Lighthouse CI with thresholds; bundle size limits in CI; auto-fail on regression | lighthouserc, bundlesize config |
| 8 | Performance budgets configured and enforced | |
| 6 | Performance budgets configured but not enforced | |
| 4 | Manual performance checks | |
| 2 | Awareness of performance but no budgets | |
| 0 | No performance budgets | |

### M5.3 — Benchmark Tests

| Score | Threshold | Evidence |
|-------|----------|---------|
| 10 | Benchmark suite (vitest bench, criterion, go bench); baseline tracking; regression detection | bench files, benchmark configs |
| 8 | Benchmarks for critical paths; run in CI | |
| 6 | Some benchmarks present but not tracked | |
| 4 | Ad hoc performance measurements | |
| 2 | Console.time or manual timing only | |
| 0 | No benchmarks | |

### M5.4 — Stress & Soak Tests

| Score | Threshold | Evidence |
|-------|----------|---------|
| 10 | Stress tests document breaking points; soak tests detect memory leaks; results tracked | stress test scripts, soak configs |
| 8 | Stress tests exist; breaking points documented | |
| 6 | Some stress testing done but not automated | |
| 4 | Manual stress testing occasionally | |
| 2 | Awareness of need but not implemented | |
| 0 | No stress or soak testing | |

---

## D6: Test Data Management (15%)

### M6.1 — Test Factories

| Score | Threshold | Evidence |
|-------|----------|---------|
| 10 | Factory library (fishery, factory_bot, AutoFixture) or well-structured factory modules; all tests use factories | factory files, builder patterns |
| 8 | Factory pattern widely used (>= 80% of tests) | |
| 6 | Factories for critical entities; some inline literals remain | |
| 4 | Mix of factories and inline literals | |
| 2 | Mostly inline object literals with some shared fixtures | |
| 0 | All test data inline; copy-paste between tests | |

### M6.2 — Database Isolation

| Score | Threshold | Evidence |
|-------|----------|---------|
| 10 | Testcontainers or per-test transactions; automatic cleanup; parallel-safe | testcontainers config, transaction wrapping |
| 8 | Per-test cleanup with truncation; parallel-safe | |
| 6 | beforeEach/afterEach cleanup present but not comprehensive | |
| 4 | Shared test database with manual cleanup | |
| 2 | Some cleanup but tests depend on order | |
| 0 | No database isolation; tests share state | |

### M6.3 — Seed Data Management

| Score | Threshold | Evidence |
|-------|----------|---------|
| 10 | Versioned seed scripts; environment-specific; reproducible; documented | seed files, migration-style seeds |
| 8 | Seed scripts present and versioned | |
| 6 | Seed scripts present but not versioned | |
| 4 | SQL dumps or manual seeding | |
| 2 | Hard-coded test data in test files | |
| 0 | No seed data management | |

### M6.4 — Mock & Stub Quality

| Score | Threshold | Evidence |
|-------|----------|---------|
| 10 | Mock factories; contract-based mocks; mocks validated against real implementations; no over-mocking | mock factory files, mock validation |
| 8 | Well-structured mocks; mostly contract-based | |
| 6 | Organized mocks but some over-mocking | |
| 4 | Mix of quality; some mocks too broad | |
| 2 | Heavy mocking; mocks not maintained with source changes | |
| 0 | Mocks everywhere; no connection to real implementations | |

---

## D7: CI Integration (15%)

### M7.1 — Test Parallelization

| Score | Threshold | Evidence |
|-------|----------|---------|
| 10 | Sharded test runs (Jest --shard, Playwright --shard); CI matrix; optimal worker count | CI config with shard/parallel |
| 8 | Parallel test execution configured | |
| 6 | Some parallelization (multi-worker) | |
| 4 | Default parallelization only | |
| 2 | Sequential test execution | |
| 0 | No CI test execution | |

### M7.2 — Fail-Fast Strategy

| Score | Threshold | Evidence |
|-------|----------|---------|
| 10 | Tiered pipeline: lint -> unit -> integration -> E2E; each stage gates the next | CI pipeline stages |
| 8 | At least 3 stages with gating | |
| 6 | 2 stages (fast/slow split) | |
| 4 | All tests in single stage but bail on first failure | |
| 2 | All tests in single stage, no bail | |
| 0 | No CI pipeline or no test stage | |

### M7.3 — Test Caching

| Score | Threshold | Evidence |
|-------|----------|---------|
| 10 | Affected-only test runs (nx affected, turbo); dependency-aware caching | nx.json, turbo.json with test caching |
| 8 | Test result caching configured | |
| 6 | Build caching that speeds up test prep | |
| 4 | Dependency caching (node_modules) only | |
| 2 | No caching but reasonable test speed | |
| 0 | No caching; full test suite on every commit | |

### M7.4 — Test Reporting

| Score | Threshold | Evidence |
|-------|----------|---------|
| 10 | JUnit XML + coverage reports + trend tracking (Codecov/Coveralls); PR comments with delta | reporter config, codecov.yml |
| 8 | JUnit XML + coverage reports uploaded | |
| 6 | Coverage reports generated but not tracked | |
| 4 | Basic pass/fail reporting only | |
| 2 | Console output only | |
| 0 | No test reporting | |

---

## D8: Test Organization & Maintainability (10%)

### M8.1 — Test File Structure

| Score | Threshold | Evidence |
|-------|----------|---------|
| 10 | Consistent structure: co-located (__tests__/) or mirror (tests/); all test types organized | File tree analysis |
| 8 | Mostly consistent with minor deviations | |
| 6 | Identifiable pattern but some files misplaced | |
| 4 | Mixed patterns across the codebase | |
| 2 | No clear pattern; tests scattered | |
| 0 | No test organization | |

### M8.2 — Test Naming Conventions

| Score | Threshold | Evidence |
|-------|----------|---------|
| 10 | Behavior-focused names ("should return X when Y"); consistent across codebase; describe blocks organized | Analyze test names |
| 8 | Mostly behavior-focused; consistent naming | |
| 6 | Mix of behavior and implementation names | |
| 4 | Inconsistent naming; some cryptic names | |
| 2 | Implementation-focused ("test method X") | |
| 0 | No naming convention; generic names ("test1", "test2") | |

### M8.3 — Shared Test Utilities

| Score | Threshold | Evidence |
|-------|----------|---------|
| 10 | Custom matchers, render helpers, API test utils, fixture loaders; well-documented | test-utils/, helpers/, custom matchers |
| 8 | Good set of shared utilities used across tests | |
| 6 | Some shared utilities but not comprehensive | |
| 4 | Basic setup files only (setupTests.ts) | |
| 2 | Minimal sharing; copy-paste between test files | |
| 0 | No shared test utilities | |

### M8.4 — Test Documentation

| Score | Threshold | Evidence |
|-------|----------|---------|
| 10 | Test plan document; coverage requirements defined; testing guide for contributors; ADRs for test decisions | TESTING.md, test plan files |
| 8 | Testing guide present; coverage requirements documented | |
| 6 | Some testing documentation (README section) | |
| 4 | Comments in test config only | |
| 2 | Minimal documentation | |
| 0 | No test documentation | |

---

## Grade Scale

| Grade | Score | Interpretation |
|-------|-------|---------------|
| A | 90-100 | Exemplary testing strategy; minor polish only |
| B | 80-89 | Strong strategy with minor gaps |
| C | 70-79 | Adequate; clear areas for improvement |
| D | 60-69 | Significant strategy gaps; action required |
| F | < 60 | Testing strategy needs fundamental overhaul |

## Scoring Notes

- Each sub-metric scores 0-10
- Dimension score = average of its 4 sub-metrics (0-10)
- Final score = weighted sum of dimension scores, scaled to 0-100
- Formula: `FINAL = SUM(D_i_avg * weight_i) * 10`
- Context adjustment: Mark dimensions as N/A if not applicable (e.g., D4 for CLI tools, D5 for static sites) and redistribute weight proportionally
