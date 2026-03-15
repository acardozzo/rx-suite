# Architecture Grading Framework — Full Metric Reference

> Based on ISO/IEC 25010 (2023 revision), SQALE, SonarQube, Robert C. Martin package metrics,
> SIG quality model, CodeClimate, and Architecture Fitness Functions.

---

## Grading Scale

| Grade | Score | Interpretation |
|-------|-------|----------------|
| A+ | 97-100 | Exceptional — exemplary architecture, open-source showcase quality |
| A | 93-96 | Excellent — clean, well-tested, well-bounded |
| A- | 90-92 | Very Good — minor issues, no structural problems |
| B+ | 87-89 | Good — solid foundation, some improvement areas |
| B | 83-86 | Above Average — functional but has notable gaps |
| B- | 80-82 | Adequate — works but has clear technical debt |
| C+ | 77-79 | Below Average — multiple quality issues |
| C | 73-76 | Mediocre — significant refactoring needed |
| C- | 70-72 | Poor — structural problems affecting velocity |
| D+ | 67-69 | Bad — architecture actively impedes development |
| D | 63-66 | Very Bad — fundamental redesign needed |
| D- | 60-62 | Critical — barely maintainable |
| F | 0-59 | Failing — unmaintainable, high risk |

---

## D1: Modularity & SRP (Weight: 15%)

### M1.1: File Size Distribution (30% of D1)

Count `.ts` implementation files (exclude `.test.ts`, `.d.ts`, `node_modules`).

| Score | Criteria |
|-------|----------|
| 100 | pct_under_300 >= 90% AND pct_over_700 = 0% |
| 90 | pct_under_300 >= 80% AND pct_over_700 <= 1% |
| 80 | pct_under_500 >= 85% AND pct_over_700 <= 3% |
| 70 | pct_under_500 >= 75% AND pct_over_700 <= 5% |
| 60 | pct_under_500 >= 65% AND pct_over_700 <= 10% |
| 50 | pct_under_500 >= 55% |
| 40 | pct_under_500 >= 45% |
| 30 | pct_under_500 < 45% |

### M1.2: God Object Count (30% of D1)

A god object = file with > 1,000 LOC.

| Score | Criteria |
|-------|----------|
| 100 | 0 god objects |
| 90 | 1 god object, max 1,200 LOC |
| 80 | 1-2 god objects, max 1,500 LOC |
| 70 | 3-4 god objects |
| 60 | 5-7 god objects |
| 50 | 8-10 god objects |
| 40 | 11-15 god objects |
| 30 | 16-20 god objects |
| 20 | 21-30 god objects |
| 10 | 31+ god objects |

### M1.3: Function Size Distribution (20% of D1)

| Score | Criteria |
|-------|----------|
| 100 | 95%+ functions <= 25 LOC, max function <= 50 LOC |
| 90 | 90%+ functions <= 30 LOC, max function <= 60 LOC |
| 80 | 85%+ functions <= 40 LOC |
| 70 | 80%+ functions <= 50 LOC |
| 60 | 70%+ functions <= 50 LOC |
| 50 | 60%+ functions <= 50 LOC |
| 40 | < 60% functions <= 50 LOC |

### M1.4: Single-Consumer Shared Code (20% of D1)

Files in `shared/` or `utils/` imported by only 1-2 consumers.

| Score | Criteria |
|-------|----------|
| 100 | 0 single-consumer shared files |
| 90 | 1-2 |
| 80 | 3-5 |
| 70 | 6-10 |
| 60 | 11-15 |
| 50 | 16-20 |
| 40 | 21+ |

**D1 formula:** `D1 = (M1.1 * 0.30) + (M1.2 * 0.30) + (M1.3 * 0.20) + (M1.4 * 0.20)`

---

## D2: Dependency Health (Weight: 20%)

### M2.1: Layer Violation Count (35% of D2)

Allowed import rules per layer:

```
core/     -> MAY: shared/, types/
            MUST NOT: api/, infra/, channels/, jobs/, worker/, providers/

api/      -> MAY: core/, shared/, infra/, types/
            MUST NOT: (varies by design)

channels/ -> MAY: core/, shared/, infra/config/, infra/logging/
            MUST NOT: api/, jobs/, worker/

infra/    -> MAY: shared/, types/
            MUST NOT: core/ (except via ports), api/

jobs/     -> MAY: core/, shared/, infra/
            MUST NOT: api/ (except protocol types)

worker/   -> MAY: all (dispatch layer)
            connection.ts/events.ts MUST NOT import domain layers

providers/ -> MUST NOT: core/, api/, channels/, jobs/, worker/
```

| Score | Criteria |
|-------|----------|
| 100 | 0 violations |
| 95 | 1-2 violations, all documented exceptions |
| 90 | 3-5 violations |
| 80 | 6-10 violations |
| 70 | 11-20 violations |
| 60 | 21-40 violations |
| 50 | 41-60 violations |
| 40 | 61-100 violations |
| 20 | 100+ violations |

### M2.2: Circular Dependency Count (25% of D2)

| Score | Criteria |
|-------|----------|
| 100 | 0 circular dependencies |
| 80 | 1 circular dependency |
| 60 | 2-3 circular dependencies |
| 40 | 4-5 circular dependencies |
| 20 | 6+ circular dependencies |

### M2.3: Boundary Test Coverage (20% of D2)

| Score | Criteria |
|-------|----------|
| 100 | All layers have boundary enforcement tests |
| 80 | 80%+ of layers |
| 60 | 50%+ of layers |
| 40 | At least 1 boundary test exists |
| 20 | No boundary tests |

### M2.4: Fan-Out per File (20% of D2)

| Score | Criteria |
|-------|----------|
| 100 | Max fan-out <= 7, average <= 4 |
| 90 | Max fan-out <= 10, average <= 5 |
| 80 | Max fan-out <= 15, average <= 7 |
| 70 | Max fan-out <= 20, average <= 10 |
| 60 | Max fan-out <= 30 |
| 40 | Max fan-out > 30 |

**D2 formula:** `D2 = (M2.1 * 0.35) + (M2.2 * 0.25) + (M2.3 * 0.20) + (M2.4 * 0.20)`

---

## D3: Abstraction & Boundaries (Weight: 15%)

### M3.1: Port Coverage (40% of D3)

Cross-layer concerns: logging, config, process exec, storage, outbound delivery, embedding, TTS, file system, network.

| Score | Criteria |
|-------|----------|
| 100 | All cross-layer concerns use ports |
| 90 | 90%+ use ports |
| 80 | 75%+ use ports |
| 70 | 60%+ use ports |
| 60 | 50%+ use ports |
| 50 | 30%+ use ports |
| 30 | < 30% use ports |

### M3.2: Composition Root Exists (20% of D3)

| Score | Criteria |
|-------|----------|
| 100 | Single composition root, all ports wired, documented |
| 80 | Composition root exists, most ports wired |
| 60 | Partial composition root |
| 40 | No composition root but some DI |
| 20 | No DI, all dependencies hardcoded |

### M3.3: Public API Surface Enforcement (20% of D3)

| Score | Criteria |
|-------|----------|
| 100 | Barrel exports + enforcement tests (no-wildcard, resolve, no-self-import) |
| 80 | Barrel exports, some tests |
| 60 | Barrel exports but no enforcement tests |
| 40 | Some barrel exports, inconsistent |
| 20 | No defined public API |

### M3.4: Contract Test Coverage (20% of D3)

| Score | Criteria |
|-------|----------|
| 100 | All plugin types have shared contract tests, all pass |
| 80 | 80%+ plugin types have contract tests |
| 60 | 50%+ have contract tests |
| 40 | Some contract tests exist |
| 20 | No contract tests |

**D3 formula:** `D3 = (M3.1 * 0.40) + (M3.2 * 0.20) + (M3.3 * 0.20) + (M3.4 * 0.20)`

---

## D4: Test Quality (Weight: 15%)

### M4.1: Line Coverage (30% of D4)

| Score | Coverage |
|-------|----------|
| 100 | >= 90% |
| 90 | 80-89% |
| 80 | 70-79% |
| 70 | 60-69% |
| 60 | 50-59% |
| 50 | 40-49% |
| 40 | 30-39% |
| 20 | < 30% |

### M4.2: Branch Coverage (20% of D4)

| Score | Coverage |
|-------|----------|
| 100 | >= 85% |
| 90 | 75-84% |
| 80 | 65-74% |
| 70 | 55-64% |
| 60 | 45-54% |
| 50 | 35-44% |
| 40 | < 35% |

### M4.3: Test File Pairing Rate (25% of D4)

Percentage of implementation files (> 50 LOC) with corresponding `.test.ts`.

| Score | Criteria |
|-------|----------|
| 100 | 95%+ |
| 90 | 85-94% |
| 80 | 75-84% |
| 70 | 65-74% |
| 60 | 55-64% |
| 50 | 45-54% |
| 40 | 35-44% |
| 20 | < 35% |

### M4.4: Assertion Quality (15% of D4)

Strong assertions: `toBe`, `toEqual`, `toMatchObject`, `toThrow`, `toStrictEqual`, `toHaveBeenCalledWith`, `toMatchInlineSnapshot`.
Weak assertions: `toBeTruthy`, `toBeDefined`, `not.toBeNull`, `toBeFalsy`, `toBeUndefined`.

| Score | Strong Assertion Rate |
|-------|-----------------------|
| 100 | >= 90% strong |
| 80 | 75-89% |
| 60 | 60-74% |
| 40 | < 60% |

### M4.5: Test Infrastructure (10% of D4)

| Score | Criteria |
|-------|----------|
| 100 | Mock factories, test helpers, contract tests, documented |
| 80 | Mock factories + test helpers exist |
| 60 | Some shared test helpers |
| 40 | Tests fully standalone |
| 20 | Missing critical test infrastructure |

**D4 formula:** `D4 = (M4.1 * 0.30) + (M4.2 * 0.20) + (M4.3 * 0.25) + (M4.4 * 0.15) + (M4.5 * 0.10)`

---

## D5: Code Complexity (Weight: 10%)

### M5.1: Cyclomatic Complexity Distribution (50% of D5)

Percentage of functions with CC <= 10 (NIST threshold).

| Score | Criteria |
|-------|----------|
| 100 | 98%+ functions CC <= 10, max CC <= 15 |
| 90 | 95%+ functions CC <= 10, max CC <= 20 |
| 80 | 90%+ functions CC <= 10 |
| 70 | 85%+ functions CC <= 10 |
| 60 | 80%+ functions CC <= 10 |
| 50 | 70%+ functions CC <= 10 |
| 40 | < 70% |

### M5.2: Cognitive Complexity (30% of D5)

Percentage of functions with CogC <= 15 (SonarQube default).

| Score | Criteria |
|-------|----------|
| 100 | 98%+ functions CogC <= 15 |
| 90 | 95%+ functions CogC <= 15 |
| 80 | 90%+ functions CogC <= 15 |
| 70 | 85%+ functions CogC <= 15 |
| 60 | 80%+ functions CogC <= 15 |
| 40 | < 80% |

### M5.3: Max Nesting Depth (20% of D5)

| Score | Criteria |
|-------|----------|
| 100 | Max nesting <= 3 in all files |
| 80 | Max nesting <= 4, 95%+ files <= 3 |
| 60 | Max nesting <= 5 |
| 40 | Max nesting <= 6 |
| 20 | Max nesting > 6 |

**D5 formula:** `D5 = (M5.1 * 0.50) + (M5.2 * 0.30) + (M5.3 * 0.20)`

---

## D6: Duplication (Weight: 5%)

### M6.1: Duplication Percentage (60% of D6)

SonarQube definition: >= 100 tokens AND >= 10 lines.

| Score | Duplication % |
|-------|---------------|
| 100 | < 1% |
| 90 | 1-3% |
| 80 | 3-5% |
| 70 | 5-7% |
| 60 | 7-10% |
| 50 | 10-15% |
| 40 | 15-20% |
| 20 | > 20% |

### M6.2: Cross-Module Pattern Duplication (40% of D6)

Count of duplicated logic patterns across modules.

| Score | Criteria |
|-------|----------|
| 100 | 0 cross-module duplicated patterns |
| 80 | 1-2 duplicated patterns |
| 60 | 3-5 duplicated patterns |
| 40 | 6-10 duplicated patterns |
| 20 | 11+ duplicated patterns |

**D6 formula:** `D6 = (M6.1 * 0.60) + (M6.2 * 0.40)`

---

## D7: Type Safety & API Design (Weight: 10%)

### M7.1: TypeScript Strict Compliance (30% of D7)

| Score | Criteria |
|-------|----------|
| 100 | All strict flags, 0 `any` casts, 0 `@ts-ignore` |
| 90 | All strict flags, <= 5 `any` casts |
| 80 | All strict flags, <= 15 `any` casts |
| 70 | Most strict flags |
| 50 | Partial strict compliance |
| 30 | Strict mode disabled |

### M7.2: Type Export Completeness (30% of D7)

| Score | Criteria |
|-------|----------|
| 100 | All exports fully typed, no implicit any |
| 90 | 95%+ exports fully typed |
| 80 | 90%+ exports fully typed |
| 70 | 80%+ exports fully typed |
| 50 | 70%+ exports fully typed |
| 30 | < 70% exports fully typed |

### M7.3: API Contract Validation (20% of D7)

| Score | Criteria |
|-------|----------|
| 100 | All endpoints use schema validation (Zod/Joi/etc), typed responses |
| 80 | 80%+ endpoints validated |
| 60 | 50%+ endpoints validated |
| 40 | Some validation, inconsistent |
| 20 | No systematic validation |

### M7.4: Error Contract Consistency (20% of D7)

| Score | Criteria |
|-------|----------|
| 100 | Single error contract, all endpoints use it, typed error codes |
| 80 | Error contract exists, 80%+ compliance |
| 60 | Multiple error patterns, partially consistent |
| 40 | Inconsistent error handling |
| 20 | No error contract |

**D7 formula:** `D7 = (M7.1 * 0.30) + (M7.2 * 0.30) + (M7.3 * 0.20) + (M7.4 * 0.20)`

---

## D8: Security & Reliability (Weight: 10%)

### M8.1: Input Validation at Boundaries (30% of D8)

| Score | Criteria |
|-------|----------|
| 100 | All external inputs validated before processing |
| 80 | 90%+ boundary inputs validated |
| 60 | 70%+ boundary inputs validated |
| 40 | Some validation, gaps exist |
| 20 | Minimal or no input validation |

### M8.2: Auth Enforcement (25% of D8)

| Score | Criteria |
|-------|----------|
| 100 | All protected routes have auth middleware, no bypass paths |
| 80 | Auth middleware present, minor gaps |
| 60 | Auth present but inconsistent |
| 40 | Auth gaps on sensitive endpoints |
| 20 | Major auth gaps |

### M8.3: Error Handling & Recovery (25% of D8)

| Score | Criteria |
|-------|----------|
| 100 | All async ops handled, resources cleaned, graceful degradation |
| 80 | 90%+ async ops handled, most resources cleaned |
| 60 | 70%+ async ops handled |
| 40 | Error handling inconsistent |
| 20 | Many unhandled promises/errors |

### M8.4: Hardcoded Secrets & Sensitive Data (20% of D8)

| Score | Criteria |
|-------|----------|
| 100 | 0 hardcoded secrets, credentials via env/config only, no sensitive data in logs |
| 90 | 0 hardcoded secrets, minor logging concerns |
| 70 | 1-2 hardcoded values (non-secret but should be configurable) |
| 50 | Multiple hardcoded values |
| 20 | Hardcoded secrets or credentials found |

**D8 formula:** `D8 = (M8.1 * 0.30) + (M8.2 * 0.25) + (M8.3 * 0.25) + (M8.4 * 0.20)`

---

## Overall Score Formula

```
Overall = (D1 * 0.15) + (D2 * 0.20) + (D3 * 0.15) + (D4 * 0.15)
        + (D5 * 0.10) + (D6 * 0.05) + (D7 * 0.10) + (D8 * 0.10)
```

---

## Framework Sources

| Dimension | Primary Source | Year | Secondary Source |
|-----------|---------------|------|-----------------|
| D1 | SIG Unit Size model (2024 benchmark) | 2024 | ISO 25010:2023 Modularity, CodeClimate |
| D2 | Robert Martin Ca/Ce/I/A/D (Agile Principles, 2002) | 2002+ | Clean Architecture Dependency Rule (2017) |
| D3 | Clean Architecture DIP/ISP (2017) | 2017 | Fitness Functions (Ford/Parsons/Kua, 2017+) |
| D4 | SonarQube Quality Gates (2024) | 2024 | SQALE Testability, Mutation Testing |
| D5 | McCabe CC (1976) + SonarSource CogC (2017) | 2017 | SIG Unit Complexity (2024 benchmark) |
| D6 | SonarQube duplication detection (2024) | 2024 | SIG Duplication metric |
| D7 | TypeScript strict mode, CISQ Maintainability (2024) | 2024 | ESLint/Oxlint rules |
| D8 | OWASP Risk Rating (2023), CISQ Security (2024) | 2023-24 | ISO 25010:2023 Security |
