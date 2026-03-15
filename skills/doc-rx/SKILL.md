---
name: doc-rx
description: >
  Evaluates documentation quality and developer experience across 8 dimensions
  and 32 sub-metrics. Assesses whether someone new can understand, onboard, and
  contribute to a project. Covers README, API docs, code docs, ADRs, onboarding,
  changelog, tutorials, and error messages. Produces a scored report with
  actionable recommendations.
---

## Prerequisites

None (POSIX only)

Check all dependencies: `bash scripts/rx-deps.sh` or `bash scripts/rx-deps.sh --install`


# doc-rx — Documentation & Developer Experience Audit

## Purpose

A world-class project is not just well-built — it is well-documented. This skill
evaluates if someone new can understand, onboard, and contribute to a codebase by
auditing documentation quality across 8 dimensions.

## Triggers

Activate this skill when the user says any of the following:

- "run doc-rx"
- "documentation audit"
- "evaluate docs"
- "onboarding review"
- "DX check"
- "developer experience"

## Execution

1. Run `scripts/discover.sh` from the project root to collect raw signals.
2. Score each of the 32 sub-metrics using the thresholds in
   `references/grading-framework.md`.
3. Produce output following the templates in `references/output-templates.md`.

## Dimensions & Sub-Metrics (32 total)

### D1: README & Project Overview (15%)

Source: GitHub Open Source Guide, Make a README

| ID   | Sub-Metric                | What to Look For                                      |
|------|---------------------------|-------------------------------------------------------|
| M1.1 | Quick start               | Setup in < 5 commands, works first try                |
| M1.2 | Architecture overview     | High-level diagram, module descriptions               |
| M1.3 | Prerequisites listed      | Runtime, tools, env vars, services                    |
| M1.4 | Badges & status           | Build status, coverage, version, license              |

### D2: API Documentation (15%)

Source: Divio Documentation System, Stripe Docs model

| ID   | Sub-Metric                | What to Look For                                      |
|------|---------------------------|-------------------------------------------------------|
| M2.1 | OpenAPI/Swagger spec      | Complete, up-to-date, published                       |
| M2.2 | Endpoint documentation    | All endpoints, request/response examples              |
| M2.3 | Authentication guide      | Step-by-step, code examples per language              |
| M2.4 | Error code catalog        | All error codes documented with fix suggestions       |

### D3: Code Documentation (10%)

Source: JSDoc/TSDoc standards, Clean Code (Robert C. Martin)

| ID   | Sub-Metric                | What to Look For                                      |
|------|---------------------------|-------------------------------------------------------|
| M3.1 | Public API documentation  | Exported functions/types have JSDoc/TSDoc             |
| M3.2 | Complex logic comments    | Non-obvious code has explanatory comments             |
| M3.3 | Type documentation        | Interfaces/types have description fields              |
| M3.4 | Example usage             | Code examples in doc comments for key functions       |

### D4: Architecture Decision Records (15%)

Source: Michael Nygard ADR format, adr-tools

| ID   | Sub-Metric                | What to Look For                                      |
|------|---------------------------|-------------------------------------------------------|
| M4.1 | ADR practice              | Numbered decisions, stored in docs/adr/               |
| M4.2 | ADR completeness          | Context, decision, consequences documented            |
| M4.3 | ADR currency              | Recent decisions recorded, not just historical        |
| M4.4 | ADR discoverability       | Indexed, searchable, linked from README               |

### D5: Onboarding & Contributing (15%)

Source: InnerSource Patterns, GitHub Contributing Guide

| ID   | Sub-Metric                | What to Look For                                      |
|------|---------------------------|-------------------------------------------------------|
| M5.1 | CONTRIBUTING.md           | PR process, code style, review expectations           |
| M5.2 | Dev setup automation      | Dev containers, docker-compose, scripts               |
| M5.3 | First-contribution guide  | good-first-issue labels, mentoring process            |
| M5.4 | Code review guidelines    | What reviewers look for, turnaround SLA               |

### D6: Changelog & Versioning (10%)

Source: Keep a Changelog, Semantic Versioning

| ID   | Sub-Metric                | What to Look For                                      |
|------|---------------------------|-------------------------------------------------------|
| M6.1 | Changelog maintenance     | CHANGELOG.md, updated per release                     |
| M6.2 | Conventional commits      | Commit messages follow convention                     |
| M6.3 | Semantic versioning       | Major/minor/patch correctly applied                   |
| M6.4 | Release notes             | Human-readable, highlights breaking changes           |

### D7: Tutorials & Guides (10%)

Source: Divio Documentation System (tutorials vs how-to vs reference)

| ID   | Sub-Metric                | What to Look For                                      |
|------|---------------------------|-------------------------------------------------------|
| M7.1 | Tutorial exists           | Step-by-step for common use cases                     |
| M7.2 | How-to guides             | Task-oriented, problem-solving                        |
| M7.3 | Explanation docs          | Conceptual, why decisions were made                   |
| M7.4 | Reference docs            | Complete, auto-generated where possible               |

### D8: Error Messages & User-Facing Text (10%)

Source: Write the Docs, Nielsen Error Heuristic

| ID   | Sub-Metric                | What to Look For                                      |
|------|---------------------------|-------------------------------------------------------|
| M8.1 | Error message quality     | Actionable, includes fix hint, no stack traces to users |
| M8.2 | CLI/terminal UX           | Help text, colored output, progress indicators        |
| M8.3 | Log message quality       | Structured, includes context, not cryptic             |
| M8.4 | User-facing copy          | Consistent tone, no jargon, i18n-ready                |

## Scoring

Each sub-metric is scored 0-5. Dimension scores are the average of their
sub-metrics multiplied by the dimension weight. The final score is the sum of
all weighted dimension scores, yielding a value between 0 and 100.

| Grade | Score Range | Meaning                                    |
|-------|-------------|--------------------------------------------|
| A+    | 95-100      | Exemplary — sets the standard              |
| A     | 85-94       | Excellent — minor gaps only                |
| B     | 70-84       | Good — clear areas to improve              |
| C     | 55-69       | Fair — significant documentation debt      |
| D     | 40-54       | Poor — onboarding is painful               |
| F     | 0-39        | Failing — docs are missing or misleading   |

## Auto-Plan Integration

After generating the scorecard and saving the report to `docs/audits/`:
1. Save a copy of the report to `docs/rx-plans/{this-skill-name}/{date}-report.md`
2. For each dimension scoring below 97, invoke the `rx-plan` skill to create or update the improvement plan at `docs/rx-plans/{this-skill-name}/{dimension}/v{N}-{date}-plan.md`
3. Update `docs/rx-plans/{this-skill-name}/summary.md` with current scores
4. Update `docs/rx-plans/dashboard.md` with overall progress

This happens automatically — the user does not need to run `/rx-plan` separately.
