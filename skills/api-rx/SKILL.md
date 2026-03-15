---
name: api-rx
description: >
  Metric-driven API surface design quality evaluation from a consumer's perspective.
  Use when: evaluating REST API quality, scoring endpoint design, reviewing response contracts,
  comparing API versions, validating developer experience, or when the user says "grade this API",
  "evaluate API", "API design review", "score this API", "REST quality", "run api-rx",
  "API quality check", or "how good is this API". Measures 8 dimensions (32 sub-metrics)
  with exact thresholds from Richardson Maturity Model, JSON:API, Google AIP, Stripe API model,
  OAuth 2.1, OpenAPI 3.1, Standard Webhooks, and HTTP Caching RFCs. Produces scorecards
  with actionable prescriptions.
---

# API Surface Design Quality Grading

Evaluate API design quality using 8 weighted dimensions and 32 sub-metrics with exact,
reproducible thresholds. No guessing — every score traces to a measured value.

**Announce at start:** "I'm using the api-rx skill to evaluate [target] against 8 dimensions and 32 sub-metrics."

## Inputs

Accepts one argument: a **directory path** containing API route/controller files, or `all`.

```
/api-rx src/api
/api-rx apps/backend
/api-rx all
```

When `all`: evaluate every API surface directory and produce both per-module and aggregate scorecards.

## Process Overview

1. **Discover API surface** — Run `scripts/discover.sh` to detect route files, middleware, controllers, OpenAPI specs
2. **Collect raw metrics** — Run dimension scripts to measure each sub-metric
3. **Score each sub-metric** — Map raw values to 0-100 scores using threshold tables
4. **Compute dimension scores** — Weighted average of sub-metrics within each dimension
5. **Compute overall score** — Weighted average of 8 dimension scores
6. **Map to letter grade** — A+ (97-100) through F (0-59)
7. **Generate scorecard** — Structured output with raw values, scores, and grade

## The 8 Dimensions

| # | Dimension | Weight | What It Measures | Source |
|---|-----------|--------|------------------|--------|
| D1 | REST Maturity & Resource Design | 15% | Resource naming, HTTP methods, status codes, HATEOAS | Richardson Maturity Model, REST API Design Rulebook (Masse) |
| D2 | Response Consistency & Contracts | 15% | Envelope uniformity, error format, pagination, filtering | JSON:API, Google AIP, Microsoft REST Guidelines |
| D3 | Versioning & Evolution | 10% | Version strategy, deprecation, backward compat, changelog | Stripe API model, API Changelog patterns |
| D4 | Authentication & Rate Limiting DX | 15% | Auth flow, rate limit headers, API key mgmt, auth errors | OAuth 2.1, IETF Rate Limiting headers |
| D5 | OpenAPI & SDK Readiness | 10% | Spec completeness, codegen compat, examples, validation | OpenAPI 3.1, Smithy, gRPC service definitions |
| D6 | Webhook & Event API | 10% | Delivery guarantees, signatures, retry, event schema | Standard Webhooks spec, Stripe Webhooks model |
| D7 | Performance & Caching DX | 15% | Cache headers, conditional requests, bulk ops, payload opt | HTTP Caching (RFC 7234), ETags, Conditional Requests |
| D8 | Documentation & Developer Experience | 10% | Interactive docs, code examples, getting started, error catalog | Stripe Docs, Twilio Docs as gold standards |

Full metric tables and thresholds: read [references/grading-framework.md](references/grading-framework.md).

## Step 1: Collect Raw Metrics

Run `scripts/discover.sh [target_dir]` to scan the codebase. The orchestrator dispatches 8 dimension scripts in parallel, each collecting raw measurements.

### D1 measurements (REST Maturity & Resource Design)

```bash
# M1.1: Resource naming
# Scan route definitions for plural nouns, hierarchical patterns, verb-in-URL violations

# M1.2: HTTP method semantics
# Check correct verb usage per route, idempotency of PUT/DELETE

# M1.3: Status code accuracy
# Count distinct status codes used, check for 200-for-everything anti-pattern

# M1.4: HATEOAS / Hypermedia
# Search for link generation in responses, self/next/prev links, rel attributes
```

### D2 measurements (Response Consistency & Contracts)

```bash
# M2.1: Response envelope consistency
# Check if responses follow a uniform structure (data/meta/links or similar)

# M2.2: Error response format
# Scan error handlers for structured errors, machine-readable codes, i18n support

# M2.3: Pagination pattern
# Detect cursor vs offset pagination, total count, next/prev links

# M2.4: Sparse fields & filtering
# Check for field selection params, filter operators, sort params
```

### D3 measurements (Versioning & Evolution)

```bash
# M3.1: Versioning strategy
# Detect version prefixes in routes (/v1/, /v2/) or version headers

# M3.2: Deprecation policy
# Search for Sunset headers, deprecation notices, @deprecated annotations

# M3.3: Backward compatibility
# Check for additive-only changes, no field removals without version bump

# M3.4: Changelog & migration
# Look for CHANGELOG files, migration guides, version diff docs
```

### D4 measurements (Authentication & Rate Limiting DX)

```bash
# M4.1: Auth flow clarity
# Detect auth middleware, token lifecycle, documented auth flows

# M4.2: Rate limit headers
# Search for X-RateLimit-Limit/Remaining/Reset, Retry-After in responses

# M4.3: API key management
# Check for key rotation logic, scoping, environment separation

# M4.4: Error UX for auth failures
# Verify 401 vs 403 distinction, token refresh guidance in responses
```

### D5 measurements (OpenAPI & SDK Readiness)

```bash
# M5.1: OpenAPI spec completeness
# Find openapi.yaml/json, check endpoint coverage, examples, schemas

# M5.2: Code generation compatibility
# Check for SDK-friendly naming, no ambiguous operationIds

# M5.3: Request/response examples
# Count endpoints with example request/response bodies

# M5.4: Schema validation
# Detect Zod/Joi/Yup at boundaries, typed responses
```

### D6 measurements (Webhook & Event API)

```bash
# M6.1: Delivery guarantees
# Search for at-least-once logic, idempotency keys in webhook handlers

# M6.2: Signature verification
# Detect HMAC signing, timestamp validation in webhook delivery

# M6.3: Retry policy
# Check for exponential backoff, dead letter, manual retry endpoints

# M6.4: Event schema & versioning
# Look for typed event definitions, schema evolution patterns
```

### D7 measurements (Performance & Caching DX)

```bash
# M7.1: Cache headers
# Search for Cache-Control, ETag, Last-Modified on GET endpoints

# M7.2: Conditional requests
# Detect If-None-Match, If-Modified-Since handling, 304 responses

# M7.3: Bulk operations
# Find batch/bulk endpoints, reduced round-trip patterns

# M7.4: Response time & payload optimization
# Check for gzip/compression, field selection, lazy relation loading
```

### D8 measurements (Documentation & Developer Experience)

```bash
# M8.1: Interactive documentation
# Detect Swagger UI, Redoc, try-it configs

# M8.2: Code examples
# Count multi-language examples, copy-pasteable snippets

# M8.3: Getting started guide
# Find quickstart/getting-started docs, time-to-first-call estimate

# M8.4: Error catalog
# Check for documented error codes, fix suggestions, searchable index
```

## Step 2: Dispatch Parallel Scoring Agents

After collecting raw metrics, dispatch **4 parallel agents** to score the 8 dimensions:

**Agent 1 — D1 + D2 (REST Design + Response Contracts):**
Receives raw metric data for resource naming, HTTP methods, status codes, HATEOAS, envelope consistency, error format, pagination, filtering. Reads the grading framework reference file. Applies threshold tables. Returns scored sub-metrics and dimension scores.

**Agent 2 — D3 + D4 (Versioning + Auth & Rate Limiting):**
Receives raw metric data for version strategy, deprecation, backward compat, changelog, auth flows, rate limit headers, API key management, auth error UX. Reads the grading framework reference file. Applies threshold tables. Returns scored sub-metrics and dimension scores.

**Agent 3 — D5 + D6 (OpenAPI & SDK + Webhooks):**
Receives raw metric data for spec completeness, codegen compat, examples, schema validation, delivery guarantees, signatures, retry policy, event schemas. Reads the grading framework reference file. Applies threshold tables. Returns scored sub-metrics and dimension scores.

**Agent 4 — D7 + D8 (Performance & Caching + Documentation):**
Receives raw metric data for cache headers, conditional requests, bulk ops, payload optimization, interactive docs, code examples, getting started, error catalog. Reads the grading framework reference file. Applies threshold tables. Returns scored sub-metrics and dimension scores.

## Step 3: Compute Final Scores

After all agents return, compute the overall score:

```
Overall = (D1 * 0.15) + (D2 * 0.15) + (D3 * 0.10) + (D4 * 0.15)
        + (D5 * 0.10) + (D6 * 0.10) + (D7 * 0.15) + (D8 * 0.10)
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
# API Design Grade: [TARGET]

**Overall: [SCORE] ([GRADE])**

| # | Dimension | Weight | Score | Grade | Weakest Sub-Metric |
|----|-----------|--------|-------|-------|---------------------|
| D1 | REST Maturity & Resource Design | 15% | [X] | [G] | [metric: raw value] |
| D2 | Response Consistency & Contracts | 15% | [X] | [G] | [metric: raw value] |
| D3 | Versioning & Evolution | 10% | [X] | [G] | [metric: raw value] |
| D4 | Authentication & Rate Limiting DX | 15% | [X] | [G] | [metric: raw value] |
| D5 | OpenAPI & SDK Readiness | 10% | [X] | [G] | [metric: raw value] |
| D6 | Webhook & Event API | 10% | [X] | [G] | [metric: raw value] |
| D7 | Performance & Caching DX | 15% | [X] | [G] | [metric: raw value] |
| D8 | Documentation & Developer Experience | 10% | [X] | [G] | [metric: raw value] |

## Sub-Metric Detail

### D1: REST Maturity & Resource Design ([SCORE])
| Sub-Metric | Weight | Raw Value | Score |
|------------|--------|-----------|-------|
| M1.1 Resource Naming | 25% | [details] | [S] |
| M1.2 HTTP Method Semantics | 25% | [details] | [S] |
| M1.3 Status Code Accuracy | 25% | [details] | [S] |
| M1.4 HATEOAS / Hypermedia | 25% | [details] | [S] |

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
# Aggregate API Design Grade

**Overall: [SCORE] ([GRADE])**

| Module | Endpoints | Weight | D1 | D2 | D3 | D4 | D5 | D6 | D7 | D8 | Overall | Grade |
|--------|-----------|--------|----|----|----|----|----|----|----|----|---------|-------|
| users/ | [N] | [W]% | .. | .. | .. | .. | .. | .. | .. | .. | [S] | [G] |
| orders/ | [N] | [W]% | .. | .. | .. | .. | .. | .. | .. | .. | [S] | [G] |
[... all modules ...]

Aggregate = weighted average by endpoint count proportion
```

## Output

Save scorecard to: `docs/audits/YYYY-MM-DD-api-rx-[target].md`

When `all`: save individual module scorecards + aggregate to `docs/audits/YYYY-MM-DD-api-rx-all.md`

## Rules

1. **Every sub-metric gets a raw value.** No "approximately" or "seems like". Measure it.
2. **Every score traces to a threshold table row.** State which row matched.
3. **Parallel agents for scoring.** Never serialize dimension scoring.
4. **N/A is allowed** when a metric genuinely does not apply (e.g., D6 Webhooks for a read-only API). Score N/A metrics as 100 with a note.
5. **Round scores to integers.** No decimals in the final scorecard.
6. **Show the math.** Include the weighted computation in the detail section.
7. **Top 5 issues must be actionable.** Include file paths and estimated point impact.
8. **Stack agnostic.** Works with any backend — Express, Fastify, NestJS, Django, Rails, Go, etc.
9. **Consumer perspective.** Grade from the API consumer's viewpoint, not the implementer's.
10. **Scan both code and specs.** Check route handlers AND OpenAPI/Swagger specs if present.
11. **Before/After diagrams show request/response flows.** Not infrastructure, but what the consumer sees.
12. **Reference industry standards.** Every recommendation cites the specific standard or best practice source.

## Auto-Plan Integration

After generating the scorecard and saving the report to `docs/audits/`:
1. Save a copy of the report to `docs/rx-plans/{this-skill-name}/{date}-report.md`
2. For each dimension scoring below 97, invoke the `rx-plan` skill to create or update the improvement plan at `docs/rx-plans/{this-skill-name}/{dimension}/v{N}-{date}-plan.md`
3. Update `docs/rx-plans/{this-skill-name}/summary.md` with current scores
4. Update `docs/rx-plans/dashboard.md` with overall progress

This happens automatically — the user does not need to run `/rx-plan` separately.
