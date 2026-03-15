# Grading Framework — doc-rx

All 32 sub-metrics are scored on a 0-5 scale. This document defines the exact
thresholds for each score level per sub-metric.

---

## D1: README & Project Overview (15%)

### M1.1 Quick Start

| Score | Criteria |
|-------|----------|
| 5 | Setup works in <= 3 commands; single `make dev` or `docker compose up`; zero manual config |
| 4 | Setup works in <= 5 commands; minor env config needed (copy `.env.example`) |
| 3 | Setup documented but requires 6-10 steps or manual dependency installation |
| 2 | Setup section exists but is incomplete, outdated, or fails on first try |
| 1 | Setup mentioned in passing, key steps missing |
| 0 | No setup instructions |

### M1.2 Architecture Overview

| Score | Criteria |
|-------|----------|
| 5 | Visual diagram (Mermaid/image) + module descriptions + data flow explanation |
| 4 | Text-based architecture description with module listing and relationships |
| 3 | High-level description of major components, no diagram |
| 2 | Brief mention of architecture in README or scattered docs |
| 1 | Only folder structure visible, no explanation |
| 0 | No architecture documentation |

### M1.3 Prerequisites Listed

| Score | Criteria |
|-------|----------|
| 5 | Exact versions, all tools/runtimes/services listed, version validation script included |
| 4 | All prerequisites listed with version ranges, includes external services |
| 3 | Runtime and main tools listed, missing some env vars or services |
| 2 | Partial list, missing critical dependencies |
| 1 | Mentions "you'll need Node" or similar vague statement |
| 0 | No prerequisites documented |

### M1.4 Badges & Status

| Score | Criteria |
|-------|----------|
| 5 | Build status, test coverage, version, license, dependency status, last commit badges |
| 4 | Build status, coverage, and version badges present and up-to-date |
| 3 | 2-3 badges present (e.g., build + license) |
| 2 | Single badge (e.g., license only) |
| 1 | Badges present but broken/outdated |
| 0 | No badges |

---

## D2: API Documentation (15%)

### M2.1 OpenAPI/Swagger Spec

| Score | Criteria |
|-------|----------|
| 5 | Complete spec (all endpoints), auto-generated from code, published UI (Swagger UI/Redoc), versioned |
| 4 | Complete spec, published UI, manual maintenance |
| 3 | Spec exists but missing some endpoints or schemas |
| 2 | Partial spec, not published, or significantly out of date |
| 1 | Skeleton spec or abandoned OpenAPI file |
| 0 | No OpenAPI/Swagger spec |

### M2.2 Endpoint Documentation

| Score | Criteria |
|-------|----------|
| 5 | All endpoints documented with request/response examples, edge cases, rate limits |
| 4 | All endpoints documented with request/response examples |
| 3 | Most endpoints documented, some missing examples |
| 2 | Key endpoints documented, many gaps |
| 1 | A few endpoints documented, inconsistent format |
| 0 | No endpoint documentation |

### M2.3 Authentication Guide

| Score | Criteria |
|-------|----------|
| 5 | Step-by-step auth flow, code examples in 3+ languages/frameworks, token lifecycle docs |
| 4 | Step-by-step guide with code examples in primary language |
| 3 | Auth mechanism described, basic code example |
| 2 | Auth mentioned but incomplete (e.g., "use Bearer token" with no setup steps) |
| 1 | Auth type stated but no guide |
| 0 | No authentication documentation |

### M2.4 Error Code Catalog

| Score | Criteria |
|-------|----------|
| 5 | All error codes documented, each with cause, fix suggestion, and code example |
| 4 | All error codes documented with descriptions and fix suggestions |
| 3 | Most error codes listed with descriptions |
| 2 | Some error codes documented, inconsistent |
| 1 | Generic error handling mentioned |
| 0 | No error code documentation |

---

## D3: Code Documentation (10%)

### M3.1 Public API Documentation

| Score | Criteria |
|-------|----------|
| 5 | >= 95% exported symbols have JSDoc/TSDoc with @param, @returns, @throws |
| 4 | >= 80% exported symbols have doc comments |
| 3 | >= 60% exported symbols have doc comments |
| 2 | >= 30% exported symbols have doc comments |
| 1 | < 30% but some doc comments exist |
| 0 | No doc comments on exported symbols |

### M3.2 Complex Logic Comments

| Score | Criteria |
|-------|----------|
| 5 | All non-obvious algorithms, regex, bitwise ops, business rules have explanatory comments |
| 4 | Most complex code blocks have comments explaining intent |
| 3 | Some complex sections documented, pattern is inconsistent |
| 2 | Occasional comments on complex code |
| 1 | Very rare comments, mostly trivial ones |
| 0 | No explanatory comments anywhere |

### M3.3 Type Documentation

| Score | Criteria |
|-------|----------|
| 5 | All interfaces/types have JSDoc descriptions, properties documented, generics explained |
| 4 | >= 80% of interfaces/types have descriptions |
| 3 | >= 50% of interfaces/types have descriptions |
| 2 | Some types documented, most are bare |
| 1 | Rare type documentation |
| 0 | No type documentation |

### M3.4 Example Usage

| Score | Criteria |
|-------|----------|
| 5 | Key functions have @example tags with runnable code snippets |
| 4 | Most public functions have usage examples in comments |
| 3 | Some functions have examples, inconsistent |
| 2 | A few examples exist |
| 1 | One or two examples in the entire codebase |
| 0 | No code examples in doc comments |

---

## D4: Architecture Decision Records (15%)

### M4.1 ADR Practice

| Score | Criteria |
|-------|----------|
| 5 | Numbered ADRs in docs/adr/ or docs/decisions/, template defined, >= 10 ADRs |
| 4 | ADR directory exists with 5+ numbered records |
| 3 | ADR directory exists with 2-4 records |
| 2 | Decision docs exist but not in ADR format |
| 1 | Scattered decision notes in wiki or issues |
| 0 | No decision records |

### M4.2 ADR Completeness

| Score | Criteria |
|-------|----------|
| 5 | All ADRs have Status, Context, Decision, Consequences, Alternatives Considered |
| 4 | All ADRs have Context, Decision, Consequences |
| 3 | Most ADRs have the core sections, some incomplete |
| 2 | ADRs exist but missing key sections |
| 1 | ADRs are brief notes without structure |
| 0 | No ADRs or empty templates only |

### M4.3 ADR Currency

| Score | Criteria |
|-------|----------|
| 5 | ADRs added within last 3 months, reflects recent architectural changes |
| 4 | ADRs added within last 6 months |
| 3 | Most recent ADR is 6-12 months old |
| 2 | Most recent ADR is 1-2 years old |
| 1 | ADRs are all > 2 years old |
| 0 | No ADRs or no dates |

### M4.4 ADR Discoverability

| Score | Criteria |
|-------|----------|
| 5 | Index file, linked from README, searchable, cross-referenced in code comments |
| 4 | Index file exists, linked from README |
| 3 | Index file or README link (not both) |
| 2 | ADRs exist but not linked from anywhere |
| 1 | ADRs buried in deep directory, hard to find |
| 0 | No ADRs |

---

## D5: Onboarding & Contributing (15%)

### M5.1 CONTRIBUTING.md

| Score | Criteria |
|-------|----------|
| 5 | Covers PR process, code style, commit conventions, review SLA, testing requirements |
| 4 | Covers PR process, code style, and review expectations |
| 3 | Basic contribution steps documented |
| 2 | Brief CONTRIBUTING.md or section in README |
| 1 | "PRs welcome" or similar minimal statement |
| 0 | No contribution guide |

### M5.2 Development Setup Automation

| Score | Criteria |
|-------|----------|
| 5 | Dev containers + docker-compose + Makefile; `make dev` gets full environment running |
| 4 | docker-compose or dev container with working setup |
| 3 | Setup scripts exist (shell scripts, npm scripts) |
| 2 | Partial automation, still requires manual steps |
| 1 | Script exists but is broken or incomplete |
| 0 | No setup automation |

### M5.3 First-Contribution Guide

| Score | Criteria |
|-------|----------|
| 5 | Good-first-issue labels, step-by-step first PR guide, mentoring process documented |
| 4 | Good-first-issue labels actively used, basic guide for first contributors |
| 3 | Good-first-issue labels exist, no guide |
| 2 | Some issues labeled but inconsistently |
| 1 | Mentioned but not practiced |
| 0 | No first-contribution support |

### M5.4 Code Review Guidelines

| Score | Criteria |
|-------|----------|
| 5 | Review checklist, turnaround SLA, CODEOWNERS, review assignment automation |
| 4 | Review guidelines documented, CODEOWNERS file exists |
| 3 | Basic review expectations documented |
| 2 | Review process implied but not documented |
| 1 | "Please review" mentioned somewhere |
| 0 | No review guidelines |

---

## D6: Changelog & Versioning (10%)

### M6.1 Changelog Maintenance

| Score | Criteria |
|-------|----------|
| 5 | CHANGELOG.md follows Keep a Changelog format, updated every release, auto-generated option |
| 4 | CHANGELOG.md exists, updated regularly, clear format |
| 3 | CHANGELOG.md exists, sometimes updated |
| 2 | Release notes in GitHub releases only |
| 1 | Sporadic notes, no consistent changelog |
| 0 | No changelog |

### M6.2 Conventional Commits

| Score | Criteria |
|-------|----------|
| 5 | >= 95% commits follow conventional format, enforced via commitlint/husky |
| 4 | >= 80% commits follow convention, tooling configured |
| 3 | >= 60% commits follow convention, no enforcement |
| 2 | Some commits follow convention, inconsistent |
| 1 | Rare conventional commits |
| 0 | No conventional commit pattern |

### M6.3 Semantic Versioning

| Score | Criteria |
|-------|----------|
| 5 | SemVer followed strictly, breaking changes trigger major, documented in CHANGELOG |
| 4 | SemVer followed, versions correlate with change types |
| 3 | SemVer used but occasionally incorrect bump type |
| 2 | Version numbers exist but do not follow SemVer |
| 1 | Arbitrary versioning |
| 0 | No versioning |

### M6.4 Release Notes

| Score | Criteria |
|-------|----------|
| 5 | Human-readable notes, breaking changes highlighted, migration guide, per-release |
| 4 | Clear release notes with breaking change callouts |
| 3 | Release notes exist, basic descriptions |
| 2 | Auto-generated commit lists only |
| 1 | Tags exist with no notes |
| 0 | No release notes |

---

## D7: Tutorials & Guides (10%)

### M7.1 Tutorial Exists

| Score | Criteria |
|-------|----------|
| 5 | Step-by-step tutorials for top 3+ use cases, tested, includes expected output |
| 4 | At least 2 tutorials covering primary use cases |
| 3 | One tutorial for the main use case |
| 2 | Partial tutorial or walkthrough in README |
| 1 | Example code without narrative |
| 0 | No tutorials |

### M7.2 How-To Guides

| Score | Criteria |
|-------|----------|
| 5 | Task-oriented guides for common operations, searchable, maintained |
| 4 | Multiple how-to guides covering key tasks |
| 3 | A few how-to guides |
| 2 | FAQ section that partially serves as how-to |
| 1 | Scattered tips in README |
| 0 | No how-to guides |

### M7.3 Explanation Docs

| Score | Criteria |
|-------|----------|
| 5 | Conceptual docs explaining "why" for all major design decisions, linked from code |
| 4 | Explanation docs for core concepts |
| 3 | Some conceptual documentation |
| 2 | Brief explanations scattered in comments |
| 1 | Design rationale mentioned in PRs only |
| 0 | No explanation documentation |

### M7.4 Reference Docs

| Score | Criteria |
|-------|----------|
| 5 | Complete reference, auto-generated (TypeDoc/JSDoc), up-to-date, searchable |
| 4 | Reference docs cover all public APIs, manually maintained |
| 3 | Partial reference docs |
| 2 | README serves as sole reference |
| 1 | Inline code is the only reference |
| 0 | No reference documentation |

---

## D8: Error Messages & User-Facing Text (10%)

### M8.1 Error Message Quality

| Score | Criteria |
|-------|----------|
| 5 | All errors are actionable, include fix hints, no raw stack traces to end users |
| 4 | Most errors are actionable with fix hints |
| 3 | Errors have human-readable messages, some lack fix hints |
| 2 | Mix of good and cryptic error messages |
| 1 | Mostly generic errors ("Something went wrong") |
| 0 | Raw errors/stack traces exposed to users |

### M8.2 CLI/Terminal UX

| Score | Criteria |
|-------|----------|
| 5 | Comprehensive --help, colored output, progress bars, tab completion, man pages |
| 4 | Good --help text, colored output, progress indicators |
| 3 | Basic --help, some formatting |
| 2 | Minimal help text |
| 1 | --help exists but is unhelpful |
| 0 | No CLI help text or not applicable |

### M8.3 Log Message Quality

| Score | Criteria |
|-------|----------|
| 5 | Structured logging (JSON), request IDs, correlation IDs, log levels correct |
| 4 | Structured logging, includes context (user, request) |
| 3 | Consistent log format, some context |
| 2 | Mix of console.log and structured logging |
| 1 | Mostly console.log/print statements |
| 0 | No logging or purely debug output |

### M8.4 User-Facing Copy

| Score | Criteria |
|-------|----------|
| 5 | Consistent tone, no jargon, i18n-ready (all strings in locale files), style guide followed |
| 4 | Consistent tone, i18n setup exists, most strings externalized |
| 3 | Generally consistent tone, some strings hardcoded |
| 2 | Inconsistent tone, jargon present |
| 1 | Developer-oriented language in user-facing text |
| 0 | No attention to user-facing copy |

---

## Aggregate Scoring

**Dimension Score** = average of its 4 sub-metric scores (0-5) converted to percentage

**Weighted Total** = sum of (dimension_score_pct x weight) for all 8 dimensions

| Grade | Score Range | Interpretation |
|-------|-------------|----------------|
| A+    | 95-100      | Exemplary documentation — sets the standard |
| A     | 85-94       | Excellent — minor gaps only |
| B     | 70-84       | Good — clear areas to improve |
| C     | 55-69       | Fair — significant documentation debt |
| D     | 40-54       | Poor — onboarding is painful |
| F     | 0-39        | Failing — docs are missing or misleading |
