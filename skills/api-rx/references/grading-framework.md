# API Surface Design Grading Framework — Full Metric Reference

> Based on Richardson Maturity Model, REST API Design Rulebook (Masse), JSON:API, Google AIP,
> Microsoft REST Guidelines, Stripe API model, OAuth 2.1, IETF Rate Limiting headers,
> OpenAPI 3.1, Standard Webhooks spec, HTTP Caching (RFC 7234), Stripe/Twilio documentation standards.

---

## Grading Scale

| Grade | Score | Interpretation |
|-------|-------|----------------|
| A+ | 97-100 | Exceptional — Stripe/Twilio-tier API design, gold standard DX |
| A | 93-96 | Excellent — clean, consistent, well-documented API surface |
| A- | 90-92 | Very Good — minor issues, no structural design problems |
| B+ | 87-89 | Good — solid foundation, some consumer friction areas |
| B | 83-86 | Above Average — functional but has notable DX gaps |
| B- | 80-82 | Adequate — works but consumers face clear pain points |
| C+ | 77-79 | Below Average — multiple design quality issues |
| C | 73-76 | Mediocre — significant API surface redesign needed |
| C- | 70-72 | Poor — structural problems affecting integration velocity |
| D+ | 67-69 | Bad — API actively impedes consumer adoption |
| D | 63-66 | Very Bad — fundamental redesign needed |
| D- | 60-62 | Critical — barely integrable |
| F | 0-59 | Failing — unusable API surface, high integration risk |

---

## Overall Formula

```
Overall = (D1 * 0.15) + (D2 * 0.15) + (D3 * 0.10) + (D4 * 0.15)
        + (D5 * 0.10) + (D6 * 0.10) + (D7 * 0.15) + (D8 * 0.10)
```

---

## D1: REST Maturity & Resource Design (Weight: 15%)

### M1.1: Resource Naming (25% of D1)

Evaluate URL patterns for plural nouns, hierarchical structure, no verbs in paths.

| Score | Criteria |
|-------|----------|
| 100 | 100% plural nouns, all hierarchical (e.g., `/users/{id}/orders`), zero verb-in-URL violations |
| 90 | 95%+ correct naming, at most 1 verb-in-URL, consistent hierarchy |
| 80 | 90%+ correct naming, 2-3 verb-in-URL violations (e.g., `/getUsers`) |
| 70 | 80%+ correct naming, some inconsistent hierarchy |
| 60 | 70%+ correct naming, mixed singular/plural, several verbs in URLs |
| 40 | 50-69% correct naming, no consistent pattern |
| 20 | < 50% correct naming, RPC-style URLs dominate |

### M1.2: HTTP Method Semantics (25% of D1)

Correct verb usage: GET=read, POST=create, PUT/PATCH=update, DELETE=remove. Idempotency of PUT/DELETE.

| Score | Criteria |
|-------|----------|
| 100 | All endpoints use correct verbs, PUT/DELETE are idempotent, PATCH for partial updates |
| 90 | 95%+ correct verb usage, minor idempotency gaps |
| 80 | 90%+ correct, POST used for some updates that should be PUT/PATCH |
| 70 | 80%+ correct, some GET endpoints with side effects |
| 60 | 70%+ correct, POST-for-everything in some areas |
| 40 | 50-69% correct, significant verb misuse |
| 20 | < 50% correct, mostly POST-for-everything or GET-for-everything |

### M1.3: Status Code Accuracy (25% of D1)

Correct HTTP status codes, not 200-for-everything.

| Score | Criteria |
|-------|----------|
| 100 | 10+ distinct status codes used correctly (200, 201, 204, 400, 401, 403, 404, 409, 422, 500) |
| 90 | 8-9 distinct codes, all semantically correct |
| 80 | 6-7 distinct codes, minor misuse (e.g., 200 for create instead of 201) |
| 70 | 4-5 distinct codes, some 200-for-errors in response body |
| 60 | 3 distinct codes (200, 400, 500), basic differentiation |
| 40 | 2 codes (200, 500), errors encoded in response body |
| 20 | 200-for-everything, status code in JSON body only |

### M1.4: HATEOAS / Hypermedia (25% of D1)

Links to related resources, self/next/prev, discoverability.

| Score | Criteria |
|-------|----------|
| 100 | Full hypermedia (self, related, actions links), API root discovery endpoint, media type links |
| 90 | Self + related links on all resources, pagination links present |
| 80 | Self links on resources, pagination links (next/prev) present |
| 70 | Pagination links present, some self links |
| 60 | Only pagination links (next/prev), no resource links |
| 40 | URLs in responses but not structured as links, no rel attributes |
| 20 | No hypermedia, all links must be constructed by the consumer |

**D1 formula:** `D1 = (M1.1 * 0.25) + (M1.2 * 0.25) + (M1.3 * 0.25) + (M1.4 * 0.25)`

---

## D2: Response Consistency & Contracts (Weight: 15%)

### M2.1: Response Envelope Consistency (25% of D2)

Uniform response structure across all endpoints.

| Score | Criteria |
|-------|----------|
| 100 | 100% endpoints use identical envelope (`{data, meta, links}` or `{data, error, pagination}`), enforced by middleware |
| 90 | 95%+ consistent, envelope enforced, 1-2 legacy endpoints differ |
| 80 | 90%+ consistent, shared response builder used |
| 70 | 80%+ consistent, some endpoints return raw arrays or unwrapped objects |
| 60 | 70%+ consistent, no enforced pattern but convention followed |
| 40 | Mixed — some wrapped, some raw, no consistent structure |
| 20 | No envelope pattern, every endpoint returns a different shape |

### M2.2: Error Response Format (25% of D2)

Structured, machine-readable errors with codes and i18n readiness.

| Score | Criteria |
|-------|----------|
| 100 | RFC 7807 Problem Details (or equivalent), error codes, field-level errors, i18n keys, trace ID |
| 90 | Structured format with code + message + details, field-level errors for validation |
| 80 | Consistent error shape with code + message, field errors for forms |
| 70 | Consistent error shape with message, no error codes |
| 60 | String messages, mostly consistent format |
| 40 | Mixed error formats, some plain strings, some objects |
| 20 | Unstructured error strings, inconsistent across endpoints |

### M2.3: Pagination Pattern (25% of D2)

Cursor vs offset, total count, navigation links.

| Score | Criteria |
|-------|----------|
| 100 | Cursor-based pagination with total count, next/prev links, configurable page size, stable ordering |
| 90 | Cursor-based with next/prev links and total count |
| 80 | Offset pagination with total count and next/prev links |
| 70 | Offset pagination with total count, no navigation links |
| 60 | Offset pagination, no total count, basic limit/offset params |
| 40 | Inconsistent pagination across endpoints, some unpaginated lists |
| 20 | No pagination on list endpoints, all data returned at once |

### M2.4: Sparse Fields & Filtering (25% of D2)

Field selection, filtering operators, sorting.

| Score | Criteria |
|-------|----------|
| 100 | Field selection (`?fields=`), rich filter operators (eq, gt, lt, in, like), multi-field sort, search |
| 90 | Field selection + filter operators + single-field sort |
| 80 | Filter operators + sort, no field selection |
| 70 | Basic equality filters + sort parameter |
| 60 | Simple query params for filtering (e.g., `?status=active`), sort |
| 40 | Only search/keyword filter, no field-level filtering |
| 20 | No filtering, no sorting, no field selection |

**D2 formula:** `D2 = (M2.1 * 0.25) + (M2.2 * 0.25) + (M2.3 * 0.25) + (M2.4 * 0.25)`

---

## D3: Versioning & Evolution (Weight: 10%)

### M3.1: Versioning Strategy (25% of D3)

Header vs URL versioning, consistency.

| Score | Criteria |
|-------|----------|
| 100 | Consistent strategy (URL or header), documented policy, version negotiation supported |
| 90 | Consistent URL or header versioning across all endpoints |
| 80 | Versioning present and mostly consistent, minor gaps |
| 70 | Versioning on major endpoints, some unversioned routes |
| 60 | Version prefix present (/v1/) but not consistently applied |
| 40 | Partial versioning, mixed strategies |
| 20 | No versioning strategy, all endpoints unversioned |

### M3.2: Deprecation Policy (25% of D3)

Sunset headers, deprecation notices, migration guides.

| Score | Criteria |
|-------|----------|
| 100 | Sunset headers (RFC 8594), deprecation warnings in responses, migration guide per deprecated endpoint, automated alerts |
| 90 | Sunset headers + deprecation annotations + migration docs |
| 80 | Deprecation annotations in code + migration docs |
| 70 | @deprecated annotations in code/specs, basic migration notes |
| 60 | Deprecation mentioned in changelogs only |
| 40 | Informal deprecation (comments, Slack messages) |
| 20 | No deprecation process, breaking changes without notice |

### M3.3: Backward Compatibility (25% of D3)

Additive changes only, no breaking changes without version bump.

| Score | Criteria |
|-------|----------|
| 100 | Automated breaking change detection (CI), additive-only policy enforced, compatibility tests |
| 90 | Breaking change detection in CI, additive-only policy documented |
| 80 | Manual review process for breaking changes, compatibility tests |
| 70 | Additive-only convention followed but not enforced |
| 60 | Most changes are backward compatible, occasional breaks |
| 40 | Breaking changes with version bumps but no detection |
| 20 | Breaking changes shipped without version bumps |

### M3.4: Changelog & Migration (25% of D3)

Documented changes, automated detection.

| Score | Criteria |
|-------|----------|
| 100 | Automated changelog generation, per-version migration guides, diff viewer, notification system |
| 90 | CHANGELOG file, per-version migration guides, notification |
| 80 | CHANGELOG file, migration guides for breaking changes |
| 70 | CHANGELOG file with dated entries, no migration guides |
| 60 | Release notes with API changes mentioned |
| 40 | Git commit history as only change record |
| 20 | No changelog, no release notes, no change documentation |

**D3 formula:** `D3 = (M3.1 * 0.25) + (M3.2 * 0.25) + (M3.3 * 0.25) + (M3.4 * 0.25)`

---

## D4: Authentication & Rate Limiting DX (Weight: 15%)

### M4.1: Auth Flow Clarity (25% of D4)

Documented, standard protocols, token lifecycle.

| Score | Criteria |
|-------|----------|
| 100 | OAuth 2.1 / OIDC, documented flow with sequence diagrams, token refresh, PKCE, scopes documented |
| 90 | Standard OAuth 2.0 with documented flows, token refresh, scopes |
| 80 | JWT/Bearer with documented lifecycle, refresh mechanism |
| 70 | API key or Bearer token with basic documentation |
| 60 | Auth mechanism documented but no token lifecycle guidance |
| 40 | Auth exists but poorly documented, trial-and-error integration |
| 20 | Undocumented auth, custom non-standard protocol |

### M4.2: Rate Limit Headers (25% of D4)

X-RateLimit-Limit/Remaining/Reset, Retry-After.

| Score | Criteria |
|-------|----------|
| 100 | All 3 rate limit headers + Retry-After on 429 + per-endpoint limits documented + dashboard |
| 90 | All 3 rate limit headers + Retry-After, limits documented in spec |
| 80 | X-RateLimit-Limit + Remaining + Reset headers present |
| 70 | X-RateLimit-Remaining + Retry-After on 429 |
| 60 | Retry-After header on 429 responses only |
| 40 | 429 status code returned but no headers, limits undocumented |
| 20 | No rate limiting headers, no 429 responses, silent throttling or crashes |

### M4.3: API Key Management (25% of D4)

Rotation, scoping, environment separation.

| Score | Criteria |
|-------|----------|
| 100 | Key rotation without downtime, granular scopes, env separation (test/prod), key creation API, audit log |
| 90 | Key rotation, scopes, env separation, self-service key management |
| 80 | Key rotation available, basic scopes, separate test/prod keys |
| 70 | Multiple keys supported, basic environment separation |
| 60 | Single API key per consumer, can be regenerated |
| 40 | API keys exist but no rotation, no scoping |
| 20 | Hardcoded shared credentials or no API key management |

### M4.4: Error UX for Auth Failures (25% of D4)

Clear 401 vs 403, token refresh guidance.

| Score | Criteria |
|-------|----------|
| 100 | Distinct 401/403 with actionable messages, token refresh hint in 401, scope listing in 403, WWW-Authenticate header |
| 90 | Distinct 401/403, actionable error messages, WWW-Authenticate header |
| 80 | Distinct 401/403 with descriptive messages |
| 70 | 401 vs 403 differentiated, generic messages |
| 60 | 401 used correctly, 403 sometimes used for 401 scenarios |
| 40 | Only 401 used for all auth failures, generic "Unauthorized" |
| 20 | 400 or 500 for auth failures, no distinction, no guidance |

**D4 formula:** `D4 = (M4.1 * 0.25) + (M4.2 * 0.25) + (M4.3 * 0.25) + (M4.4 * 0.25)`

---

## D5: OpenAPI & SDK Readiness (Weight: 10%)

### M5.1: OpenAPI Spec Completeness (25% of D5)

All endpoints documented, examples, schemas.

| Score | Criteria |
|-------|----------|
| 100 | OpenAPI 3.1, 100% endpoint coverage, all schemas referenced, examples on every operation, tags organized |
| 90 | OpenAPI 3.0+, 95%+ coverage, schemas and examples on most operations |
| 80 | OpenAPI 3.0+, 85%+ coverage, request/response schemas present |
| 70 | OpenAPI spec exists, 70%+ coverage, some missing schemas |
| 60 | OpenAPI spec exists but < 70% coverage or many missing schemas |
| 40 | Partial spec or Swagger 2.0, major gaps |
| 20 | No OpenAPI spec, or auto-generated stub with no descriptions/examples |

### M5.2: Code Generation Compatibility (25% of D5)

SDK-friendly naming, no ambiguities.

| Score | Criteria |
|-------|----------|
| 100 | Unique operationIds, consistent naming convention, all types referenceable, tested with 3+ generators |
| 90 | Unique operationIds, consistent naming, tested with at least 1 generator |
| 80 | operationIds present and unique, consistent naming convention |
| 70 | operationIds present, some naming inconsistencies |
| 60 | Some operationIds, auto-generated names for others |
| 40 | No operationIds, generators produce unusable names |
| 20 | Spec incompatible with standard generators |

### M5.3: Request/Response Examples (25% of D5)

Realistic examples for every endpoint.

| Score | Criteria |
|-------|----------|
| 100 | Multiple examples per endpoint (success, error, edge case), realistic data, runnable |
| 90 | Example for every endpoint (success case), realistic data |
| 80 | Examples on 80%+ endpoints, mostly realistic |
| 70 | Examples on 60-79% endpoints |
| 60 | Examples on 40-59% endpoints |
| 40 | Examples on < 40% endpoints or placeholder data |
| 20 | No examples in spec |

### M5.4: Schema Validation (25% of D5)

Zod/Joi at boundaries, typed responses.

| Score | Criteria |
|-------|----------|
| 100 | Runtime validation on all inputs (Zod/Joi/AJV), typed responses, validation errors include field paths |
| 90 | Runtime validation on 90%+ inputs, typed responses |
| 80 | Runtime validation on 80%+ inputs, most responses typed |
| 70 | Runtime validation on critical endpoints, some typed responses |
| 60 | Ad-hoc validation (manual if-checks), some schema usage |
| 40 | Minimal validation, mostly trusting input |
| 20 | No input validation at API boundaries |

**D5 formula:** `D5 = (M5.1 * 0.25) + (M5.2 * 0.25) + (M5.3 * 0.25) + (M5.4 * 0.25)`

---

## D6: Webhook & Event API (Weight: 10%)

### M6.1: Delivery Guarantees (25% of D6)

At-least-once delivery, idempotency keys.

| Score | Criteria |
|-------|----------|
| 100 | At-least-once with idempotency keys, delivery status API, redelivery endpoint, exactly-once option |
| 90 | At-least-once with idempotency keys, delivery status tracking |
| 80 | At-least-once delivery, idempotency keys in events |
| 70 | At-least-once delivery, no idempotency keys |
| 60 | Best-effort delivery with retry, no guarantees documented |
| 40 | Fire-and-forget, retry on failure only |
| 20 | No delivery guarantees, no retry, events may be silently lost |

### M6.2: Signature Verification (25% of D6)

HMAC signing, timestamp validation.

| Score | Criteria |
|-------|----------|
| 100 | HMAC-SHA256 signature, timestamp validation (replay prevention), secret rotation, SDK helpers for verification |
| 90 | HMAC signature + timestamp validation + documented verification steps |
| 80 | HMAC signature with documented verification, no timestamp check |
| 70 | Signature present, basic documentation |
| 60 | Shared secret for basic auth on webhook URL |
| 40 | IP allowlist only, no cryptographic verification |
| 20 | No signature verification, open webhook endpoints |

### M6.3: Retry Policy (25% of D6)

Exponential backoff, dead letter, manual retry.

| Score | Criteria |
|-------|----------|
| 100 | Exponential backoff + jitter, dead letter queue, manual retry API, retry history visible, configurable policy |
| 90 | Exponential backoff, dead letter queue, manual retry endpoint |
| 80 | Exponential backoff, dead letter, retry visible in dashboard |
| 70 | Fixed retry schedule (e.g., 5 retries over 24h), no dead letter |
| 60 | Basic retry (2-3 attempts), no backoff |
| 40 | Single retry, no dead letter, no visibility |
| 20 | No retry mechanism |

### M6.4: Event Schema & Versioning (25% of D6)

Typed events, schema evolution.

| Score | Criteria |
|-------|----------|
| 100 | Typed event catalog, versioned schemas, backward-compatible evolution, schema registry, event type filtering |
| 90 | Typed event catalog with versions, event type filtering on subscription |
| 80 | Typed events with documented schemas, version field in payload |
| 70 | Event types defined, basic schema documentation |
| 60 | Event types exist but schemas undocumented |
| 40 | Generic event payload, no type distinction |
| 20 | Unstructured webhook payloads, no event typing |

**D6 formula:** `D6 = (M6.1 * 0.25) + (M6.2 * 0.25) + (M6.3 * 0.25) + (M6.4 * 0.25)`

---

## D7: Performance & Caching DX (Weight: 15%)

### M7.1: Cache Headers (25% of D7)

Cache-Control, ETag, Last-Modified on GET endpoints.

| Score | Criteria |
|-------|----------|
| 100 | Cache-Control + ETag + Last-Modified on all GET endpoints, Vary header, CDN-friendly, immutable for versioned assets |
| 90 | Cache-Control + ETag on all GET endpoints, appropriate max-age values |
| 80 | Cache-Control on 80%+ GET endpoints, ETag on resource endpoints |
| 70 | Cache-Control on critical endpoints, some ETags |
| 60 | Cache-Control on some endpoints, inconsistent |
| 40 | no-cache/no-store everywhere, or no Cache-Control headers |
| 20 | No caching headers on any endpoint |

### M7.2: Conditional Requests (25% of D7)

If-None-Match, If-Modified-Since, 304 support.

| Score | Criteria |
|-------|----------|
| 100 | If-None-Match + If-Modified-Since supported, 304 responses, If-Match for optimistic concurrency |
| 90 | If-None-Match supported with 304 responses, If-Match for writes |
| 80 | If-None-Match supported with 304 responses |
| 70 | ETag returned but conditional requests not handled (always 200) |
| 60 | Last-Modified returned, basic If-Modified-Since support |
| 40 | Timestamps in responses but no conditional request support |
| 20 | No conditional request support |

### M7.3: Bulk Operations (25% of D7)

Batch endpoints, reduced round-trips.

| Score | Criteria |
|-------|----------|
| 100 | Batch create/update/delete endpoints, multi-resource GET, partial success handling, streaming for large batches |
| 90 | Batch endpoints for CRUD, partial success with per-item status |
| 80 | Batch create and update, partial success handling |
| 70 | Batch create endpoint, all-or-nothing semantics |
| 60 | Bulk delete only, or single batch endpoint |
| 40 | No batch endpoints but list endpoints accept multiple IDs |
| 20 | No bulk operations, every operation requires a separate request |

### M7.4: Response Time & Payload Optimization (25% of D7)

Gzip, field selection, lazy relations.

| Score | Criteria |
|-------|----------|
| 100 | Gzip/Brotli compression, field selection, lazy/eager relation loading, response size limits, streaming for large payloads |
| 90 | Compression enabled, field selection, configurable relation depth |
| 80 | Compression enabled, basic field selection or relation expansion |
| 70 | Compression enabled, fixed response shapes |
| 60 | Compression enabled but no payload optimization options |
| 40 | No compression, full objects always returned |
| 20 | No compression, deeply nested full objects, over-fetching by default |

**D7 formula:** `D7 = (M7.1 * 0.25) + (M7.2 * 0.25) + (M7.3 * 0.25) + (M7.4 * 0.25)`

---

## D8: Documentation & Developer Experience (Weight: 10%)

### M8.1: Interactive Documentation (25% of D8)

Swagger UI / Redoc, try-it functionality.

| Score | Criteria |
|-------|----------|
| 100 | Interactive docs (Swagger UI/Redoc), try-it with auth, environment switcher, response validation, hosted + versioned |
| 90 | Interactive docs with try-it, auth pre-filled, environment support |
| 80 | Interactive docs (Swagger UI or Redoc) with try-it functionality |
| 70 | Interactive docs available but try-it not configured |
| 60 | Static rendered API docs (HTML from spec) |
| 40 | Raw OpenAPI spec viewable, no rendered docs |
| 20 | No API documentation site or viewer |

### M8.2: Code Examples (25% of D8)

Multi-language, copy-pasteable, runnable.

| Score | Criteria |
|-------|----------|
| 100 | Examples in 5+ languages, copy-paste ready, tested in CI, Postman/Insomnia collection, SDK quickstart |
| 90 | Examples in 3-4 languages, copy-paste ready, Postman collection |
| 80 | Examples in 2 languages (curl + 1 SDK), copy-paste ready |
| 70 | Curl examples for all endpoints |
| 60 | Curl examples for some endpoints |
| 40 | Pseudo-code or incomplete examples |
| 20 | No code examples |

### M8.3: Getting Started Guide (25% of D8)

Time-to-first-successful-call < 5 min.

| Score | Criteria |
|-------|----------|
| 100 | < 5 min to first call, step-by-step guide, sandbox environment, pre-built credentials, video walkthrough |
| 90 | < 5 min guide, sandbox environment, pre-built test credentials |
| 80 | Getting started guide with sandbox, requires signup |
| 70 | Getting started guide, clear steps, no sandbox |
| 60 | README with basic usage, manual setup required |
| 40 | Scattered docs, no clear starting point |
| 20 | No getting started guide, consumer must reverse-engineer |

### M8.4: Error Catalog (25% of D8)

All error codes documented, fix suggestions, search.

| Score | Criteria |
|-------|----------|
| 100 | Complete error catalog, searchable, fix suggestions per error, example triggers, linked from error responses |
| 90 | Complete error catalog with fix suggestions, linked from error responses |
| 80 | Error catalog covering all error codes, basic fix guidance |
| 70 | Error codes documented in API spec, some guidance |
| 60 | Common errors documented, many undocumented |
| 40 | Errors listed but no descriptions or fix guidance |
| 20 | No error documentation |

**D8 formula:** `D8 = (M8.1 * 0.25) + (M8.2 * 0.25) + (M8.3 * 0.25) + (M8.4 * 0.25)`

---

## Framework Sources

| Source | Dimensions Informed |
|--------|---------------------|
| Richardson Maturity Model (Leonard Richardson) | D1 (REST maturity levels 0-3) |
| REST API Design Rulebook (Mark Masse, O'Reilly) | D1 (resource naming, URI design) |
| JSON:API Specification (jsonapi.org) | D2 (response envelope, error format, pagination) |
| Google API Improvement Proposals (AIP) | D2, D3 (contracts, versioning) |
| Microsoft REST API Guidelines | D2, D7 (consistency, caching) |
| Stripe API Versioning Model | D3 (versioning, evolution, changelog) |
| OAuth 2.1 (RFC 6749 + updates) | D4 (auth flows, token lifecycle) |
| IETF Rate Limiting Headers (draft-ietf-httpapi-ratelimit-headers) | D4 (rate limit headers) |
| OpenAPI 3.1 Specification | D5 (spec completeness, codegen) |
| Smithy (AWS) / gRPC Service Definitions | D5 (SDK readiness, code generation) |
| Standard Webhooks Specification (standard-webhooks.dev) | D6 (delivery, signatures, retry) |
| Stripe Webhooks Model | D6 (event schema, versioning) |
| HTTP Caching RFC 7234 / RFC 9111 | D7 (cache headers, conditional requests) |
| ETags and Conditional Requests (RFC 7232) | D7 (conditional requests, 304) |
| Stripe Docs / Twilio Docs | D8 (gold standard documentation DX) |
| Postman API Landscape Report | D8 (developer experience benchmarks) |
