---
name: data-rx
description: >
  Prescriptive data model and Supabase evaluation producing scored opportunity maps.
  Evaluates schema design, RLS policies, migration quality, query patterns, Supabase
  Auth/Storage/Realtime/Edge Functions usage, and PostgreSQL best practices.
  Use when: auditing data model, reviewing Supabase setup, scoring database quality,
  or when the user says "data audit", "run data-rx", "schema review", "supabase check",
  "RLS audit", "migration review", "database quality", or "data model review".
  Measures 10 dimensions (40 sub-metrics) with exact thresholds from PostgreSQL docs,
  Supabase official patterns, Database Design (Date), and Use The Index Luke.
  Produces per-project scorecards with Supabase feature adoption matrix.
  Fixed stack: Supabase (PostgreSQL + Auth + Storage + Edge Functions + Realtime + RLS).
---

## Prerequisites

Recommended: `supabase` CLI. Optional: Supabase MCP

Check all dependencies: `bash scripts/rx-deps.sh` or `bash scripts/rx-deps.sh --install`


# Data Model & Supabase Quality Grading

Evaluate data model quality and Supabase usage using 10 weighted dimensions and 40
sub-metrics with exact, reproducible thresholds. No guessing — every score traces to
a measured value. Fixed stack: **Supabase**.

**Announce at start:** "I'm using the data-rx skill to evaluate [target] against 10 dimensions and 40 sub-metrics."

## Inputs

Accepts one argument: a **project path** or `all`.

```
/data-rx .
/data-rx /path/to/project
/data-rx all
```

## Process Overview

1. **Discover** — Verify Supabase project, list tables/migrations/RLS policies, scan client code
2. **Score** — Map raw findings to 0-100 scores using threshold tables (5 parallel agents)
3. **Report** — Generate scorecard with per-dimension and aggregate grades
4. **Auto-Plan** — Create improvement plans for dimensions below 97

## The 10 Dimensions

| # | Dimension | Weight | What It Measures |
|---|-----------|--------|------------------|
| D1 | Schema Design & Normalization | 12% | Table naming, column types, normalization, primary keys |
| D2 | Relationships & Foreign Keys | 10% | FK coverage, cascade rules, junction tables, polymorphic patterns |
| D3 | Indexing & Query Performance | 12% | Index coverage, composite indexes, index types, query patterns |
| D4 | Row-Level Security | 12% | RLS enabled, policy completeness, policy quality, service role separation |
| D5 | Migrations & Schema Evolution | 10% | Migration discipline, quality, seed data, schema versioning |
| D6 | Supabase Auth Integration | 10% | Auth setup, user metadata, auth hooks, session management |
| D7 | Supabase Storage | 8% | Bucket config, storage RLS, image transforms, cleanup |
| D8 | Supabase Realtime & Edge Functions | 8% | Channels, presence, edge functions, webhooks |
| D9 | Type Safety & Client Integration | 10% | Generated types, client typing, validation schemas, API layer |
| D10 | Observability & Maintenance | 8% | Query monitoring, bloat, connection management, backup |

Full metric tables and thresholds: read [references/grading-framework.md](references/grading-framework.md).

## Step 1: Collect Raw Metrics

Run the discovery scripts against the target project. The orchestrator (`scripts/discover.sh`)
dispatches dimension-specific scanners that collect raw data.

### D1 measurements (Schema Design)

```bash
# Scan migrations for CREATE TABLE statements
# Check table naming: snake_case, consistent prefixes
# Check column types: proper types, NOT NULL, CHECK, DEFAULT
# Check PK strategy: UUID vs serial, composite keys
bash scripts/discover.sh /path/to/project d01
```

### D2 measurements (Relationships)

```bash
# Scan for FOREIGN KEY constraints
# Check ON DELETE / ON UPDATE rules
# Identify junction tables (2+ FKs, few other columns)
# Find self-referential FKs (parent_id patterns)
bash scripts/discover.sh /path/to/project d02
```

### D3 measurements (Indexing)

```bash
# Scan for CREATE INDEX statements
# Check indexes on FK columns
# Check GIN/GiST/pg_trgm usage
# Scan client code for N+1 patterns, SELECT *
bash scripts/discover.sh /path/to/project d03
```

### D4 measurements (RLS)

```bash
# THE KEY DIMENSION — scan for:
# ENABLE ROW LEVEL SECURITY / FORCE ROW LEVEL SECURITY
# Policy count per table (SELECT/INSERT/UPDATE/DELETE)
# auth.uid() / auth.jwt() in policies
# USING(true) anti-pattern
# Tables without any RLS policies
bash scripts/discover.sh /path/to/project d04
```

### D5 measurements (Migrations)

```bash
# supabase/migrations/ directory existence and contents
# Migration file count and naming convention
# Seed files and environment-specific data
# supabase db diff usage
bash scripts/discover.sh /path/to/project d05
```

### D6 measurements (Auth)

```bash
# Auth provider config in supabase/config.toml
# handle_new_user trigger
# Profiles table linked to auth.users
# Auth hooks and session config
bash scripts/discover.sh /path/to/project d06
```

### D7 measurements (Storage)

```bash
# Storage bucket creation in migrations
# storage.objects RLS policies
# Supabase Storage client usage
# File upload patterns
bash scripts/discover.sh /path/to/project d07
```

### D8 measurements (Realtime & Edge Functions)

```bash
# Realtime channel subscriptions
# Presence usage
# supabase/functions/ directory
# Database webhooks/triggers
bash scripts/discover.sh /path/to/project d08
```

### D9 measurements (Type Safety)

```bash
# supabase/types.ts or database.types.ts
# createClient<Database> typed usage
# Zod schemas matching DB types
# Server vs client Supabase separation
bash scripts/discover.sh /path/to/project d09
```

### D10 measurements (Observability)

```bash
# pg_stat_statements references
# Connection pooler config
# Monitoring/alerting setup
# Backup configuration
bash scripts/discover.sh /path/to/project d10
```

## Step 2: Dispatch Parallel Scoring Agents

After collecting raw metrics, dispatch **5 parallel agents** to score the 10 dimensions:

**Agent 1 — D1 + D2 (Schema + Relationships):**
Receives raw metric data for table naming, column types, normalization, PKs, FKs, cascade rules, junction tables, polymorphic patterns. Reads the grading framework reference file. Applies threshold tables. Returns scored sub-metrics and dimension scores.

**Agent 2 — D3 + D4 (Indexing + RLS):**
Receives raw metric data for index coverage, composite indexes, index types, query patterns, RLS status, policy completeness, policy quality, service role separation. Reads the grading framework reference file. Applies threshold tables. Returns scored sub-metrics and dimension scores.

**Agent 3 — D5 + D6 (Migrations + Auth):**
Receives raw metric data for migration discipline, quality, seeds, versioning, auth setup, user metadata, hooks, session management. Reads the grading framework reference file. Applies threshold tables. Returns scored sub-metrics and dimension scores.

**Agent 4 — D7 + D8 (Storage + Realtime):**
Receives raw metric data for bucket config, storage RLS, image transforms, cleanup, channels, presence, edge functions, webhooks. Reads the grading framework reference file. Applies threshold tables. Returns scored sub-metrics and dimension scores.

**Agent 5 — D9 + D10 (Types + Observability):**
Receives raw metric data for generated types, client typing, validation schemas, API layer, query monitoring, bloat, connections, backup. Reads the grading framework reference file. Applies threshold tables. Returns scored sub-metrics and dimension scores.

## Step 3: Compute Final Scores

After all agents return, compute the overall score:

```
Overall = (D1 * 0.12) + (D2 * 0.10) + (D3 * 0.12) + (D4 * 0.12)
        + (D5 * 0.10) + (D6 * 0.10) + (D7 * 0.08) + (D8 * 0.08)
        + (D9 * 0.10) + (D10 * 0.08)
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
# Data Model Grade: [PROJECT_NAME]

**Overall: [SCORE] ([GRADE])**

| # | Dimension | Weight | Score | Grade | Weakest Sub-Metric |
|----|-----------|--------|-------|-------|---------------------|
| D1 | Schema Design & Normalization | 12% | [X] | [G] | [metric: raw value] |
| D2 | Relationships & Foreign Keys | 10% | [X] | [G] | [metric: raw value] |
| D3 | Indexing & Query Performance | 12% | [X] | [G] | [metric: raw value] |
| D4 | Row-Level Security | 12% | [X] | [G] | [metric: raw value] |
| D5 | Migrations & Schema Evolution | 10% | [X] | [G] | [metric: raw value] |
| D6 | Supabase Auth Integration | 10% | [X] | [G] | [metric: raw value] |
| D7 | Supabase Storage | 8% | [X] | [G] | [metric: raw value] |
| D8 | Realtime & Edge Functions | 8% | [X] | [G] | [metric: raw value] |
| D9 | Type Safety & Client Integration | 10% | [X] | [G] | [metric: raw value] |
| D10 | Observability & Maintenance | 8% | [X] | [G] | [metric: raw value] |

## Supabase Feature Adoption Matrix

| Feature | Status | Notes |
|---------|--------|-------|
| PostgreSQL RLS | [Adopted/Partial/Missing] | [details] |
| Supabase Auth | [Adopted/Partial/Missing] | [details] |
| Supabase Storage | [Adopted/Partial/Missing] | [details] |
| Supabase Realtime | [Adopted/Partial/Missing] | [details] |
| Edge Functions | [Adopted/Partial/Missing] | [details] |
| Generated Types | [Adopted/Partial/Missing] | [details] |
| Supabase CLI Migrations | [Adopted/Partial/Missing] | [details] |

## Sub-Metric Detail

### D1: Schema Design & Normalization ([SCORE])
| Sub-Metric | Weight | Raw Value | Score |
|------------|--------|-----------|-------|
| M1.1 Table Naming | 25% | [findings] | [S] |
| M1.2 Column Types & Constraints | 25% | [findings] | [S] |
| M1.3 Normalization Level | 25% | [findings] | [S] |
| M1.4 Primary Keys & Identity | 25% | [findings] | [S] |

[... repeat for D2-D10 with same table format ...]

## RLS Policy Audit

| Table | RLS Enabled | FORCE RLS | SELECT | INSERT | UPDATE | DELETE | Uses auth.uid() | Issues |
|-------|-------------|-----------|--------|--------|--------|--------|------------------|--------|
| [table] | [Y/N] | [Y/N] | [Y/N] | [Y/N] | [Y/N] | [Y/N] | [Y/N] | [details] |

## Migration Timeline

| # | Migration File | Tables Affected | Has Rollback | Issues |
|---|---------------|-----------------|--------------|--------|
| 1 | [filename] | [tables] | [Y/N] | [details] |

## Schema Diagram (Mermaid)

erDiagram
    [table relationships from migrations]

## Top 5 Issues (Highest Impact)

1. **[Issue]** — [dimension] — fixing raises score by ~[N] points
2. ...

## Recommendations

- To reach [NEXT_GRADE]: fix [specific issues]
- Estimated effort: [relative sizing]
```

## Output

Save scorecard to: `docs/audits/YYYY-MM-DD-data-rx.md`

## Rules

1. **Every sub-metric gets a raw value.** No "approximately" or "seems like". Measure it.
2. **Every score traces to a threshold table row.** State which row matched.
3. **Parallel agents for scoring.** Never serialize dimension scoring.
4. **N/A is allowed** when a metric genuinely does not apply (e.g., D7 Storage for a project not using files). Score N/A metrics as 100 with a note.
5. **Round scores to integers.** No decimals in the final scorecard.
6. **Show the math.** Include the weighted computation in the detail section.
7. **Top 5 issues must be actionable.** Include file paths and estimated point impact.
8. **Supabase CLI must be used for migrations** — not raw SQL files outside supabase/migrations/.
9. **RLS is non-negotiable** for any table with user data. Missing RLS = automatic score cap at 40 for D4.
10. **Generated types must be up-to-date** — check types.ts freshness vs latest migration timestamp.
11. **Always recommend Supabase-native features** before external solutions (e.g., Supabase Auth over custom auth, Storage over S3 direct).
12. **Service role key on client-side is a critical finding** — automatic 0 for M4.4.
13. **USING(true) on sensitive tables is a critical finding** — flag and cap M4.3 at 40.
14. **Schema changes outside migrations get flagged** — manual DDL detected = cap M5.1 at 40.
15. **Use discovery scripts when available.** Run `bash scripts/discover.sh` to collect raw data before scoring.

## Auto-Plan Integration

After generating the scorecard and saving the report to `docs/audits/`:
1. Save a copy of the report to `docs/rx-plans/data-rx/{date}-report.md`
2. For each dimension scoring below 97, invoke the `rx-plan` skill to create or update the improvement plan at `docs/rx-plans/data-rx/{dimension}/v{N}-{date}-plan.md`
3. Update `docs/rx-plans/data-rx/summary.md` with current scores
4. Update `docs/rx-plans/dashboard.md` with overall progress

This happens automatically — the user does not need to run `/rx-plan` separately.
