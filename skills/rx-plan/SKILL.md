---
name: rx-plan
description: >
  Generates versioned improvement plans from rx report results. Creates one plan per dimension
  that scores below A+ (97). Plans are saved to docs/rx-plans/{domain}/{dimension}/v{N}-{date}-plan.md.
  Use after running any rx skill, or when the user says "create plan from report", "rx plan",
  "plan improvements", "generate improvement plan", "what should I fix first", "create roadmap",
  "improvement plan", "plan from audit", or "next steps from rx".
---

# rx-plan -- Versioned Improvement Plan Generator

Reads rx report results and generates actionable, versioned improvement plans for every dimension
scoring below A+ (97). Each plan is traceable to a specific report, ordered by impact, and includes
measurable acceptance criteria.

**Announce at start:** "I'm using rx-plan to generate improvement plans from the {domain} report. Creating plans for dimensions below A+ (97)."

## Inputs

Accepts one of:
- A **domain name** (e.g., `arch-rx`, `sec-rx`, `code-rx`) to read the latest report for that domain
- A **report file path** (e.g., `docs/audits/2026-03-15-arch-rx-all.md`) to use a specific report
- No argument -- uses the most recent rx report from conversation context or `docs/audits/`

```
/rx-plan arch-rx
/rx-plan docs/audits/2026-03-15-sec-rx-report.md
/rx-plan
```

## Process Overview

1. **Locate the rx report** -- Find the most recent report for the given domain
2. **Parse scores** -- Extract dimension scores, sub-metric scores, and existing recommendations
3. **Filter dimensions** -- Identify all dimensions scoring below 97 (not yet A+)
4. **Check existing plans** -- Look in `docs/rx-plans/{domain}/{dimension}/` for previous versions
5. **Generate plans** -- Create one plan per below-A+ dimension, versioned correctly
6. **Save report snapshot** -- Copy the rx report as `v{N}-{date}-report.md` alongside the plan
7. **Update summary** -- Refresh `docs/rx-plans/{domain}/summary.md` with current progress
8. **Update dashboard** -- Refresh `docs/rx-plans/dashboard.md` with global state

## Step 1: Locate the Report

Search for the report in this order:
1. If a file path is given, read it directly
2. If a domain name is given, find the most recent file matching `docs/audits/*-{domain}-*.md`
3. If no argument, check conversation context for the last rx report output
4. If still nothing, list `docs/audits/` sorted by date descending and pick the newest

Extract from the report:
- Domain name (e.g., `arch-rx`)
- Overall score and grade
- Per-dimension scores and grades
- Per-sub-metric scores
- Existing ADR recommendations or improvement suggestions

## Step 2: Determine Versions

For each dimension scoring below 97:

1. Check if `docs/rx-plans/{domain}/{dimension-slug}/` exists
2. If it exists, find the highest version number `v{N}` from existing plan filenames
3. New version = `v{N+1}`
4. If no previous plans exist, new version = `v1`

Dimension slug convention: lowercase, dash-separated, prefixed with dimension number.
Examples: `d01-communication`, `d02-async-event`, `d03-resilience`

## Step 3: Generate Plan Files

For each below-A+ dimension, create `docs/rx-plans/{domain}/{dimension-slug}/v{N}-{date}-plan.md`:

```markdown
# Improvement Plan: {Domain} / {Dimension}

**Version**: v{N}
**Date**: {YYYY-MM-DD}
**Domain**: {rx skill name} (e.g., arch-rx)
**Dimension**: {dimension name} (e.g., D2: Async & Event Architecture)
**Current Score**: {score} ({grade})
**Target Score**: 97+ (A+)
**Gap**: {delta} points

## Previous Versions
| Version | Date | Score | Delta | Status |
|---------|------|-------|-------|--------|
| v1 | 2026-03-15 | 40 (F) | -- | Completed |
| v2 | 2026-03-20 | 72 (C-) | +32 | Completed |
| v{N} (this) | {date} | {score} ({grade}) | {delta from prev} | Planning |

> If this is v1, the table has only one row with Delta = "--".

## Gap Analysis

| Sub-Metric | Current | Target | Gap | Key Blocker |
|------------|---------|--------|-----|-------------|
| M{X}.1 {name} | {score} | 97+ | {delta} | {specific blocker} |
| M{X}.2 {name} | {score} | 97+ | {delta} | {specific blocker} |
| M{X}.3 {name} | {score} | 97+ | {delta} | {specific blocker} |
| M{X}.4 {name} | {score} | 97+ | {delta} | {specific blocker} |

## Steps (ordered by impact)

### Step 1: {Action} -> +{N} points on M{X}.{Y}
- **What**: {Concrete action -- what exactly to implement or change}
- **Where**: {File paths -- specific files/directories to modify}
- **Why**: {Framework reference -- POSA/EIP/WCAG/OWASP/12-Factor/etc.}
- **How**:
  ```
  {Code example, command, or configuration snippet}
  ```
- **Acceptance Criteria**:
  - [ ] {Measurable criterion 1}
  - [ ] {Measurable criterion 2}
- **Effort**: {S/M/L}
- **Depends on**: {Step N or "none"}

### Step 2: {Action} -> +{N} points on M{X}.{Y}
...

> Steps are ordered by point impact descending. If two steps have equal impact,
> order by effort ascending (quick wins first). Include ALL steps needed to reach 97+.

## After Completing This Plan
- Run `/{domain}` to re-evaluate this dimension
- Expected new score: {projected score based on step impacts}
- If score >= 97: dimension is A+, archive this plan
- If score < 97: auto-generate v{N+1} plan with remaining gaps
- Related rx skills to run: {list of complementary rx skills}

## Notes
{Any context from the rx report that's relevant -- detected stack, N/A dimensions,
dependencies on other dimensions, external constraints, etc.}
```

## Step 4: Save Report Snapshot

Copy (or extract) the relevant rx report data to:
`docs/rx-plans/{domain}/{dimension-slug}/v{N}-{date}-report.md`

This file contains the full rx report (or the relevant dimension section) that generated
the plan. This creates an immutable audit trail: every plan version links to the exact
report that prompted it.

## Step 5: Update Summary

Create or update `docs/rx-plans/{domain}/summary.md`:

```markdown
# {Domain} Progress Tracker

**Last evaluated**: {date}
**Overall score**: {score} ({grade})

| Dimension | Current | Target | Plans | Latest | Status |
|-----------|---------|--------|-------|--------|--------|
| D1 {name} | {score} ({grade}) | 97 (A+) | v{N} | {date} | {In Progress/Planning/Complete} |
| D2 {name} | {score} ({grade}) | 97 (A+) | v{N} | {date} | {status} |
| ... | ... | ... | ... | ... | ... |

> Dimensions at 97+ show Status = "Complete" with no plan version needed.

## Timeline
| Date | Event | Score Change |
|------|-------|-------------|
| {date} | Initial rx report | {score} ({grade}) |
| {date} | v1 plans completed | {score} ({grade}) {+/-delta} |
| ... | ... | ... |
```

## Step 6: Update Dashboard

Create or update `docs/rx-plans/dashboard.md`:

```markdown
# rx-suite Dashboard

**Last updated**: {date}

## Overall Progress
| Domain | Score | Grade | Dimensions at A+ | Total | Progress |
|--------|-------|-------|-------------------|-------|----------|
| arch-rx | {score} | {grade} | {count}/{total} | {total} | {progress bar} |
| sec-rx | {score} | {grade} | {count}/{total} | {total} | {progress bar} |
| code-rx | {score} | {grade} | {count}/{total} | {total} | {progress bar} |
| ... | ... | ... | ... | ... | ... |

> Progress bar: use filled/empty blocks proportional to A+ percentage.
> Example: 3/11 = 27% -> block chars approximating that percentage

## Active Plans
| Domain | Dimension | Version | Status | Next Action |
|--------|-----------|---------|--------|-------------|
| {domain} | {dimension} | v{N} | {In Progress/Planning} | {Step 1 action summary} |
| ... | ... | ... | ... | ... |

## Completed Dimensions (A+)
| Domain | Dimension | Achieved | Date |
|--------|-----------|----------|------|
| {domain} | {dimension} | {score} (A+) | {date} |
| ... | ... | ... | ... |

## Recommendations
- **Next rx to run**: {domain with stalest report or most active plans}
- **Highest-impact plan**: {domain/dimension with largest gap and smallest effort}
- **Quick wins**: {plans with S effort and significant point gains}
```

Progress bar rendering:
- Calculate percentage: `(dimensions_at_aplus / total_dimensions) * 100`
- Use 10 block characters total
- Filled blocks = round(percentage / 10)
- Empty blocks = 10 - filled blocks
- Format: `{filled}{empty} {percentage}%`

## Rules

1. **Plans are always versioned -- never overwrite.** Each new plan for the same dimension
   gets an incremented version number (v1, v2, v3...). Previous versions remain untouched
   as an audit trail.

2. **Each plan traces to a specific rx report.** The report snapshot (`v{N}-{date}-report.md`)
   is saved alongside the plan. This creates full traceability from plan to evidence.

3. **Steps are ordered by point impact.** The step that yields the most score improvement
   comes first. If two steps have equal impact, the one with less effort comes first (quick wins).

4. **Acceptance criteria must be measurable.** Every step's acceptance criteria must be
   verifiable by re-running the rx skill or by checking a concrete artifact (file exists,
   test passes, config value is set). No subjective criteria like "code is cleaner".

5. **After completing a plan, re-run the rx skill to verify.** The plan explicitly states
   which rx skill to run. The new report feeds into the next plan version if gaps remain.

6. **Auto-increment version when re-planning.** When `rx-plan` runs against a dimension
   that already has plans, it reads the previous version's score, computes the delta,
   and generates `v{N+1}` with updated gap analysis.

7. **Dashboard is always updated.** Every invocation of `rx-plan` must update both the
   domain summary and the global dashboard. These files are the single source of truth
   for progress tracking.

8. **One plan per dimension.** Never combine multiple dimensions into a single plan file.
   Each dimension gets its own directory and its own plan versions.

9. **Preserve previous version history.** When generating a new plan, the "Previous Versions"
   table includes ALL prior versions with their scores and deltas, not just the immediately
   preceding one.

10. **Score 97+ means complete.** Dimensions scoring 97 or above are considered A+ and
    do not get plans. They appear in the dashboard's "Completed Dimensions" table.

11. **Gap analysis is per-sub-metric.** The gap analysis table breaks down the dimension
    score into its constituent sub-metrics, showing exactly where points are lost.

12. **Steps include file paths.** Every step must reference specific files or directories
    in the project. Generic advice like "add error handling" is not acceptable without
    pointing to where.

13. **Framework references are mandatory.** Every step must cite the framework, standard,
    or pattern that justifies the recommendation (POSA, EIP, OWASP, 12-Factor, CNCF, etc.).

14. **Effort estimates use S/M/L.** Small = less than 2 hours, Medium = 2-8 hours,
    Large = more than 8 hours. These are rough guides for prioritization.

15. **Dependencies between steps are explicit.** If Step 3 requires Step 1 to be done first,
    the dependency is stated. This prevents wasted effort from out-of-order execution.

16. **Report snapshots are dimension-scoped.** The saved report snapshot includes the full
    report context but highlights the specific dimension being planned. If the full report
    is very large, extract just the relevant dimension section plus the overall scorecard.

17. **N/A dimensions are skipped.** If a dimension is scored N/A (100 by convention) in the
    rx report, no plan is generated for it.

18. **Cross-domain dependencies are noted.** If an improvement in one domain (e.g., arch-rx D9
    Security) would also improve another domain (e.g., sec-rx D1 Injection), note this in
    the plan's Notes section.

19. **Projected scores are conservative.** When estimating the score after completing a plan,
    use the lower bound of the expected improvement range. Overpromising undermines trust
    in the planning system.
