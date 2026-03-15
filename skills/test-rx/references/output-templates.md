# test-rx Output Templates

## Per-Dimension Improvement Plans

Each dimension scoring below 7/10 receives a structured improvement plan.

---

### Template: Dimension Improvement Plan

```markdown
## {Dimension Name} — Current Score: {score}/10

### Gap Analysis
- **Current state:** {description of what exists}
- **Target state:** {description of what good looks like}
- **Gap:** {specific missing capabilities}

### Priority Actions (ordered by impact)

1. **[HIGH] {Action title}**
   - What: {concrete action}
   - Why: {impact on testing strategy}
   - How: {implementation steps}
   - Effort: {S/M/L}
   - Files to create/modify: {list}

2. **[MEDIUM] {Action title}**
   - What: {concrete action}
   - Why: {impact}
   - How: {steps}
   - Effort: {S/M/L}

3. **[LOW] {Action title}**
   - What: {concrete action}
   - Why: {impact}
   - How: {steps}
   - Effort: {S/M/L}

### Quick Wins (< 1 day)
- [ ] {action}
- [ ] {action}

### Strategic Investments (1-2 weeks)
- [ ] {action}
- [ ] {action}
```

---

## Before/After Mermaid Diagrams

### Test Architecture Transformation

Use these diagram templates to visualize the current vs target test architecture.

#### Before: Current Test Architecture

```mermaid
graph TD
    subgraph "Current Test Architecture"
        direction TB
        A[Source Code] --> B[Tests]

        subgraph "Test Distribution"
            B --> U["Unit Tests<br/>{count} files<br/>{pct}%"]
            B --> I["Integration Tests<br/>{count} files<br/>{pct}%"]
            B --> E["E2E Tests<br/>{count} files<br/>{pct}%"]
        end

        subgraph "Missing Layers"
            M1["Contract Tests ❌"]
            M2["Visual Tests ❌"]
            M3["Load Tests ❌"]
            M4["Mutation Testing ❌"]
        end

        subgraph "Test Infrastructure"
            TI1["Factories: {status}"]
            TI2["CI Pipeline: {status}"]
            TI3["Coverage Reporting: {status}"]
            TI4["Test Utilities: {status}"]
        end
    end

    style M1 fill:#ff6b6b,color:#fff
    style M2 fill:#ff6b6b,color:#fff
    style M3 fill:#ff6b6b,color:#fff
    style M4 fill:#ff6b6b,color:#fff
```

#### After: Target Test Architecture

```mermaid
graph TD
    subgraph "Target Test Architecture"
        direction TB
        A[Source Code] --> B[Tests]

        subgraph "Test Pyramid ✅"
            B --> U["Unit Tests<br/>~70% of tests"]
            B --> I["Integration Tests<br/>~20% of tests"]
            B --> E["E2E Tests<br/>~10% of tests"]
        end

        subgraph "Specialized Testing ✅"
            S1["Contract Tests (Pact)"]
            S2["Visual Regression (Chromatic)"]
            S3["Load Tests (k6)"]
            S4["Mutation Testing (Stryker)"]
        end

        subgraph "Test Infrastructure ✅"
            TI1["Factories (fishery)"]
            TI2["Tiered CI Pipeline"]
            TI3["Codecov + JUnit XML"]
            TI4["Custom Matchers & Helpers"]
        end

        B --> S1
        B --> S2
        B --> S3
        B --> S4
    end

    style S1 fill:#51cf66,color:#fff
    style S2 fill:#51cf66,color:#fff
    style S3 fill:#51cf66,color:#fff
    style S4 fill:#51cf66,color:#fff
```

---

### Test Pyramid Shape Diagram

#### Before: Ice Cream Cone Anti-Pattern

```mermaid
graph TD
    subgraph "Current: Ice Cream Cone ❌"
        E2E["E2E Tests<br/>{count} — LARGEST"]
        INT["Integration Tests<br/>{count}"]
        UNIT["Unit Tests<br/>{count} — SMALLEST"]
    end

    style E2E fill:#ff6b6b,color:#fff,stroke-width:4px
    style INT fill:#ffa94d,color:#fff
    style UNIT fill:#ff6b6b,color:#fff
```

#### After: Healthy Pyramid

```mermaid
graph TD
    subgraph "Target: Healthy Pyramid ✅"
        E2E2["E2E Tests<br/>~10%"]
        INT2["Integration Tests<br/>~20%"]
        UNIT2["Unit Tests<br/>~70% — LARGEST"]
    end

    style E2E2 fill:#51cf66,color:#fff
    style INT2 fill:#51cf66,color:#fff
    style UNIT2 fill:#51cf66,color:#fff,stroke-width:4px
```

---

### CI Pipeline Transformation

#### Before: Single-Stage Pipeline

```mermaid
graph LR
    subgraph "Current CI ❌"
        C[Commit] --> ALL["All Tests<br/>Single Stage<br/>~15 min"]
        ALL --> D[Deploy]
    end

    style ALL fill:#ff6b6b,color:#fff
```

#### After: Tiered Pipeline

```mermaid
graph LR
    subgraph "Target CI ✅"
        C[Commit] --> L["Lint<br/>~30s"]
        L --> U["Unit Tests<br/>~2 min<br/>Sharded"]
        U --> I["Integration<br/>~5 min<br/>Parallel"]
        I --> E2E["E2E<br/>~8 min<br/>Sharded"]
        E2E --> PERF["Performance<br/>~3 min"]
        PERF --> D[Deploy]
    end

    style L fill:#51cf66,color:#fff
    style U fill:#51cf66,color:#fff
    style I fill:#51cf66,color:#fff
    style E2E fill:#51cf66,color:#fff
    style PERF fill:#51cf66,color:#fff
```

---

### Test Data Management Transformation

#### Before: Inline Data Chaos

```mermaid
graph TD
    subgraph "Current: Inline Data ❌"
        T1["test-a.ts<br/>const user = {'{'}name: 'John'...{'}'}"]
        T2["test-b.ts<br/>const user = {'{'}name: 'Jane'...{'}'}"]
        T3["test-c.ts<br/>const user = {'{'}name: 'Bob'...{'}'}"]
        DB["Shared DB<br/>No cleanup"]
        T1 --> DB
        T2 --> DB
        T3 --> DB
    end

    style DB fill:#ff6b6b,color:#fff
```

#### After: Factory-Based Data Management

```mermaid
graph TD
    subgraph "Target: Factories ✅"
        F["factories/<br/>user.factory.ts<br/>order.factory.ts"]
        T1["test-a.ts<br/>createUser()"]
        T2["test-b.ts<br/>createUser()"]
        T3["test-c.ts<br/>createUser()"]
        TC["Testcontainers<br/>Per-test isolation"]
        F --> T1
        F --> T2
        F --> T3
        T1 --> TC
        T2 --> TC
        T3 --> TC
    end

    style F fill:#51cf66,color:#fff
    style TC fill:#51cf66,color:#fff
```

---

## Full Scorecard Template

```markdown
============================================================
  TEST-RX DIAGNOSTIC SCORECARD
  Project: {project_name}
  Date: {date}
  Final Score: {score}/100 — Grade: {grade}
============================================================

  D1  Test Pyramid Balance     {bar}  {score}/10  (15%)
      M1.1 Unit test ratio ............ {score}/10
      M1.2 Integration test coverage .. {score}/10
      M1.3 E2E test coverage .......... {score}/10
      M1.4 Pyramid shape .............. {score}/10

  D2  Test Effectiveness       {bar}  {score}/10  (15%)
      M2.1 Mutation score ............. {score}/10
      M2.2 Assertion density .......... {score}/10
      M2.3 Test-to-code coupling ...... {score}/10
      M2.4 False positive rate ........ {score}/10

  D3  Contract & API Testing   {bar}  {score}/10  (10%)
      M3.1 Contract test coverage ..... {score}/10
      M3.2 Schema validation tests .... {score}/10
      M3.3 API integration tests ...... {score}/10
      M3.4 Backward compatibility ..... {score}/10

  D4  UI & Visual Testing      {bar}  {score}/10  (10%)
      M4.1 Component tests ............ {score}/10
      M4.2 Visual regression .......... {score}/10
      M4.3 Accessibility testing ...... {score}/10
      M4.4 Cross-browser testing ...... {score}/10

  D5  Performance & Load       {bar}  {score}/10  (10%)
      M5.1 Load test existence ........ {score}/10
      M5.2 Performance budgets ........ {score}/10
      M5.3 Benchmark tests ............ {score}/10
      M5.4 Stress & soak tests ........ {score}/10

  D6  Test Data Management     {bar}  {score}/10  (15%)
      M6.1 Test factories ............. {score}/10
      M6.2 Database isolation ......... {score}/10
      M6.3 Seed data management ....... {score}/10
      M6.4 Mock & stub quality ........ {score}/10

  D7  CI Integration           {bar}  {score}/10  (15%)
      M7.1 Test parallelization ....... {score}/10
      M7.2 Fail-fast strategy ......... {score}/10
      M7.3 Test caching ............... {score}/10
      M7.4 Test reporting ............. {score}/10

  D8  Test Organization        {bar}  {score}/10  (10%)
      M8.1 Test file structure ........ {score}/10
      M8.2 Test naming conventions .... {score}/10
      M8.3 Shared test utilities ...... {score}/10
      M8.4 Test documentation ......... {score}/10

  WEIGHTED TOTAL: {total}/100

  Grade Scale:
    90-100  A  Exemplary testing strategy
    80-89   B  Strong with minor gaps
    70-79   C  Adequate, clear improvement areas
    60-69   D  Significant strategy gaps
    <60     F  Testing strategy needs overhaul

============================================================
  TOP 3 CRITICAL FINDINGS
============================================================
  1. {finding with file references}
  2. {finding with file references}
  3. {finding with file references}

============================================================
  IMPROVEMENT ROADMAP
============================================================
  Phase 1 (Quick Wins — This Sprint):
    - [ ] {action}
    - [ ] {action}
    - [ ] {action}

  Phase 2 (Foundation — Next 2 Sprints):
    - [ ] {action}
    - [ ] {action}
    - [ ] {action}

  Phase 3 (Strategic — Next Quarter):
    - [ ] {action}
    - [ ] {action}
    - [ ] {action}
============================================================
```

---

## Dimension-Specific Output Sections

### D1 Output: Test Pyramid Analysis

```markdown
### Test Pyramid Analysis

| Layer | Count | Percentage | Target | Status |
|-------|-------|-----------|--------|--------|
| Unit | {n} | {pct}% | >= 70% | {ok/gap} |
| Integration | {n} | {pct}% | ~20% | {ok/gap} |
| E2E | {n} | {pct}% | ~10% | {ok/gap} |

Shape: {Pyramid / Diamond / Hourglass / Ice Cream Cone}
```

### D6 Output: Test Data Audit

```markdown
### Test Data Audit

| Pattern | Count | Files | Quality |
|---------|-------|-------|---------|
| Factory usage | {n} | {files} | {good/poor} |
| Inline literals | {n} | {files} | {concern level} |
| Mock factories | {n} | {files} | {good/poor} |
| DB cleanup hooks | {n} | {files} | {good/poor} |

Over-mocking risk: {LOW / MEDIUM / HIGH}
```

### D7 Output: CI Integration Audit

```markdown
### CI Pipeline Analysis

| Stage | Present | Order | Duration |
|-------|---------|-------|----------|
| Lint | {y/n} | {pos} | {est} |
| Unit Tests | {y/n} | {pos} | {est} |
| Integration | {y/n} | {pos} | {est} |
| E2E | {y/n} | {pos} | {est} |
| Performance | {y/n} | {pos} | {est} |

Parallelization: {none / basic / sharded}
Caching: {none / deps / results / affected-only}
Reporting: {none / console / junit / coverage+trends}
```
