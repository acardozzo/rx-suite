---
name: code-rx
description: >
  Metric-driven code quality evaluation producing objective, repeatable grades and prescriptions.
  Use when: evaluating code quality, measuring technical debt, scoring a layer/module/codebase,
  comparing before/after refactoring, validating plan targets, or when the user says "grade this",
  "evaluate quality", "score this code", "how good is this layer", "measure code quality",
  "run code-rx", "code quality check", or "what grade does X get". Measures 8 dimensions
  (29 sub-metrics) with exact thresholds from ISO 25010, SQALE, SonarQube, Robert Martin
  package metrics, SIG, and CodeClimate. Produces per-layer scorecards and aggregate grades.
---

# Code Quality & Hygiene Grading

Evaluate architecture quality using 8 weighted dimensions and 29 sub-metrics with exact,
reproducible thresholds. No guessing — every score traces to a measured value.

**Announce at start:** "I'm using the code-rx skill to evaluate [target] against 8 dimensions and 29 sub-metrics."

## Inputs

Accepts one argument: a **layer path**, a **directory**, or `all`.

```
/code-rx src/core
/code-rx src/api
/code-rx all
```

When `all`: evaluate every top-level directory under `src/` and produce both per-layer and aggregate scorecards.

## Process Overview

1. **Collect raw metrics** — Run measurement commands against the target
2. **Score each sub-metric** — Map raw values to 0-100 scores using threshold tables
3. **Compute dimension scores** — Weighted average of sub-metrics within each dimension
4. **Compute overall score** — Weighted average of 8 dimension scores
5. **Map to letter grade** — A+ (97-100) through F (0-59)
6. **Generate scorecard** — Structured output with raw values, scores, and grade

## The 8 Dimensions

| # | Dimension | Weight | What It Measures |
|---|-----------|--------|------------------|
| D1 | Modularity & SRP | 15% | File size, god objects, function size, shared code placement |
| D2 | Dependency Health | 20% | Layer violations, circular deps, boundary tests, fan-out |
| D3 | Abstraction & Boundaries | 15% | Port coverage, composition root, public API, contract tests |
| D4 | Test Quality | 15% | Line/branch coverage, test pairing, assertion quality, infra |
| D5 | Code Complexity | 10% | Cyclomatic complexity, cognitive complexity, nesting depth |
| D6 | Duplication | 5% | Duplicated lines, cross-module pattern duplication |
| D7 | Type Safety & API Design | 10% | Strict mode, type completeness, validation, error contracts |
| D8 | Security & Reliability | 10% | Input validation, auth, error handling, hardcoded secrets |

Full metric tables and thresholds: read [references/grading-framework.md](references/grading-framework.md).

## Step 1: Collect Raw Metrics

Run these measurement commands against the target layer directory. Collect all raw numbers before scoring.

### D1 measurements (Modularity)

```bash
# M1.1: File size distribution
# Count .ts files (exclude .test.ts, .d.ts, node_modules, dist)
# For each: wc -l to get LOC
# Compute: pct_under_300, pct_under_500, pct_over_700, max_file_loc

# M1.2: God objects (files > 1000 LOC)
# Count from the file size data above

# M1.3: Function size distribution
# Use grep to find exported function/method declarations
# Estimate function lengths between declarations

# M1.4: Single-consumer shared code
# Find files in shared/utils dirs, count their importers via grep
```

### D2 measurements (Dependencies)

```bash
# M2.1: Layer violations
# For each file, extract import paths
# Check against allowed import rules (see framework reference)
# Count violations

# M2.2: Circular dependencies
# Build import graph, detect cycles at directory level

# M2.3: Boundary test coverage
# Search for *.test.ts files that enforce import rules
# Check which layers have boundary tests

# M2.4: Fan-out per file
# Count distinct import targets per file
# Compute max and average
```

### D3 measurements (Abstraction)

```bash
# M3.1: Port coverage
# Identify cross-layer concerns (logging, config, storage, etc.)
# Check which use port interfaces vs direct imports

# M3.2: Composition root
# Search for a wiring/bootstrap file that connects ports to implementations

# M3.3: Public API surface
# Check for barrel index.ts files per module
# Check for enforcement tests

# M3.4: Contract tests
# Search for shared conformance tests for plugin/adapter interfaces
```

### D4 measurements (Test Quality)

```bash
# M4.1 + M4.2: Line and branch coverage
# Run: pnpm test:coverage (or vitest --coverage) scoped to layer
# Parse coverage output for line% and branch%

# M4.3: Test file pairing rate
# Count implementation files > 50 LOC
# Count those with corresponding .test.ts
# Compute percentage

# M4.4: Assertion quality
# In test files, count strong assertions (toBe, toEqual, toMatchObject, toThrow, toStrictEqual)
# Count weak assertions (toBeTruthy, toBeDefined, not.toBeNull, toBeFalsy)
# Compute strong/(strong+weak) percentage

# M4.5: Test infrastructure
# Check for mock factory files, test helper modules, contract test suites
```

### D5 measurements (Complexity)

```bash
# M5.1 + M5.2: Cyclomatic and cognitive complexity
# Use eslint with complexity rule or manual analysis
# Count functions, identify those exceeding thresholds

# M5.3: Max nesting depth
# Analyze indentation levels in source files
# Find maximum nesting depth
```

### D6 measurements (Duplication)

```bash
# M6.1: Duplication percentage
# Use jscpd or manual analysis for duplicated blocks (>= 10 lines, >= 100 tokens)

# M6.2: Cross-module pattern duplication
# Identify similar logic patterns implemented independently across modules
# (e.g., retry logic, message chunking, rate limiting in multiple channels)
```

### D7 measurements (Type Safety)

```bash
# M7.1: TypeScript strict compliance
# Check tsconfig.json for strict flags
# Count: grep -r "as any\|: any\|@ts-ignore\|@ts-expect-error" --include="*.ts"

# M7.2: Type export completeness
# Sample public exports, check for explicit return types

# M7.3: API contract validation
# Check API/handler files for schema validation (Zod, Joi, etc.)

# M7.4: Error contract consistency
# Check error response patterns across endpoints
```

### D8 measurements (Security)

```bash
# M8.1: Input validation at boundaries
# Check external-facing handlers for input validation

# M8.2: Auth enforcement
# Check route definitions for auth middleware

# M8.3: Error handling
# Count unhandled async operations (missing try/catch, .catch, etc.)

# M8.4: Hardcoded secrets
# grep for hardcoded keys, tokens, passwords, connection strings
```

## Step 2: Dispatch Parallel Scoring Agents

After collecting raw metrics, dispatch **4 parallel agents** to score the 8 dimensions:

**Agent 1 — D1 + D2 (Modularity + Dependencies):**
Receives raw metric data for file sizes, god objects, function sizes, shared code, layer violations, circular deps, boundary tests, fan-out. Reads the grading framework reference file. Applies threshold tables. Returns scored sub-metrics and dimension scores.

**Agent 2 — D3 + D4 (Abstraction + Test Quality):**
Receives raw metric data for port coverage, composition root, public API, contract tests, coverage percentages, test pairing, assertion quality, test infra. Reads the grading framework reference file. Applies threshold tables. Returns scored sub-metrics and dimension scores.

**Agent 3 — D5 + D6 (Complexity + Duplication):**
Receives raw metric data for cyclomatic complexity distribution, cognitive complexity, nesting depth, duplication percentage, cross-module patterns. Reads the grading framework reference file. Applies threshold tables. Returns scored sub-metrics and dimension scores.

**Agent 4 — D7 + D8 (Type Safety + Security):**
Receives raw metric data for strict compliance, type completeness, API validation, error contracts, input validation, auth enforcement, error handling, secrets. Reads the grading framework reference file. Applies threshold tables. Returns scored sub-metrics and dimension scores.

## Step 3: Compute Final Scores

After all agents return, compute the overall score:

```
Overall = (D1 * 0.15) + (D2 * 0.20) + (D3 * 0.15) + (D4 * 0.15)
        + (D5 * 0.10) + (D6 * 0.05) + (D7 * 0.10) + (D8 * 0.10)
```

Map to letter grade:

| Grade | Score Range |
|-------|------------|
| A+ | 97-100 |
| A | 93-96 |
| A- | 90-92 |
| B+ | 87-89 |
| B | 83-86 |
| B- | 80-82 |
| C+ | 77-79 |
| C | 73-76 |
| C- | 70-72 |
| D+ | 67-69 |
| D | 63-66 |
| D- | 60-62 |
| F | 0-59 |

## Step 4: Generate Scorecard

Output format — ALWAYS use this exact structure:

```markdown
# Architecture Grade: [LAYER_NAME]

**Overall: [SCORE] ([GRADE])**

| # | Dimension | Weight | Score | Grade | Weakest Sub-Metric |
|----|-----------|--------|-------|-------|---------------------|
| D1 | Modularity & SRP | 15% | [X] | [G] | [metric: raw value] |
| D2 | Dependency Health | 20% | [X] | [G] | [metric: raw value] |
| D3 | Abstraction & Boundaries | 15% | [X] | [G] | [metric: raw value] |
| D4 | Test Quality | 15% | [X] | [G] | [metric: raw value] |
| D5 | Code Complexity | 10% | [X] | [G] | [metric: raw value] |
| D6 | Duplication | 5% | [X] | [G] | [metric: raw value] |
| D7 | Type Safety & API Design | 10% | [X] | [G] | [metric: raw value] |
| D8 | Security & Reliability | 10% | [X] | [G] | [metric: raw value] |

## Sub-Metric Detail

### D1: Modularity & SRP ([SCORE])
| Sub-Metric | Weight | Raw Value | Score |
|------------|--------|-----------|-------|
| M1.1 File Size Distribution | 30% | pct_under_300=[X]%, pct_over_700=[X]% | [S] |
| M1.2 God Object Count | 30% | [N] files > 1000 LOC | [S] |
| M1.3 Function Size Distribution | 20% | [X]% functions <= 25 LOC | [S] |
| M1.4 Single-Consumer Shared Code | 20% | [N] single-consumer files | [S] |

[... repeat for D2-D8 with same table format ...]

## Top 5 Issues (Highest Impact)

1. **[Issue]** — [dimension] — fixing raises score by ~[N] points
2. ...

## Recommendations

- To reach [NEXT_GRADE]: fix [specific issues]
- Estimated effort: [relative sizing]
```

When evaluating `all`, also produce an aggregate:

```markdown
# Aggregate Codebase Grade

**Overall: [SCORE] ([GRADE])**

| Layer | LOC | Weight | D1 | D2 | D3 | D4 | D5 | D6 | D7 | D8 | Overall | Grade |
|-------|-----|--------|----|----|----|----|----|----|----|----|---------|-------|
| core/ | [N] | [W]% | .. | .. | .. | .. | .. | .. | .. | .. | [S] | [G] |
| api/ | [N] | [W]% | .. | .. | .. | .. | .. | .. | .. | .. | [S] | [G] |
[... all layers ...]

Aggregate = weighted average by LOC proportion
```

## Output

Save scorecard to: `docs/audits/YYYY-MM-DD-code-rx-[layer].md`

When `all`: save individual layer scorecards + aggregate to `docs/audits/YYYY-MM-DD-code-rx-all.md`

## Rules

1. **Every sub-metric gets a raw value.** No "approximately" or "seems like". Measure it.
2. **Every score traces to a threshold table row.** State which row matched.
3. **Parallel agents for scoring.** Never serialize dimension scoring.
4. **N/A is allowed** when a metric genuinely does not apply (e.g., M8.2 Auth for a types-only layer). Score N/A metrics as 100 with a note.
5. **Round scores to integers.** No decimals in the final scorecard.
6. **Show the math.** Include the weighted computation in the detail section.
7. **Top 5 issues must be actionable.** Include file paths and estimated point impact.

8. **Use LSP when available.** If LSP tools are active (pyright/vtsls), leverage type diagnostics for D7 Type Safety scoring and go-to-definition for D2 Dependency Health analysis. LSP provides ground-truth type information that static grep cannot.
