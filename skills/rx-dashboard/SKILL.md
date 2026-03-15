---
name: rx-dashboard
description: >
  Shows the rx-suite progress dashboard across all domains and dimensions. Displays which
  dimensions are at A+, which have active improvement plans, and what to work on next.
  Use when the user says "rx dashboard", "show progress", "rx status", "what's next",
  "improvement status", "plan status", "show dashboard", "rx overview", or "what should I work on".
---

# rx-dashboard -- Global Progress Dashboard

Aggregates and displays the current state of all rx-suite evaluations and improvement plans.
Shows which dimensions are at A+, which have active plans, and recommends what to work on next.

**Announce at start:** "I'm using rx-dashboard to show the current rx-suite progress across all domains."

## Inputs

Accepts optional filters:
- No argument -- show full dashboard across all domains
- A **domain name** (e.g., `arch-rx`) -- show detailed progress for that domain only
- `active` -- show only domains/dimensions with active (non-complete) plans
- `next` -- show only the single highest-priority next action

```
/rx-dashboard
/rx-dashboard arch-rx
/rx-dashboard active
/rx-dashboard next
```

## Process Overview

1. **Read existing dashboard** -- Check `docs/rx-plans/dashboard.md` for cached state
2. **Scan audit reports** -- List all files in `docs/audits/` to find rx reports
3. **Scan plan directories** -- Walk `docs/rx-plans/*/` to find all domain summaries and plans
4. **Reconcile state** -- Merge report data with plan data to build current picture
5. **Compute recommendations** -- Determine stalest reports, highest-impact plans, quick wins
6. **Display dashboard** -- Render the dashboard to the user (and update the file if stale)

## Step 1: Read Existing Dashboard

Check if `docs/rx-plans/dashboard.md` exists:
- If it exists and was updated today, display it directly (fast path)
- If it exists but is stale, use it as a starting point and refresh
- If it does not exist, build from scratch

## Step 2: Scan Audit Reports

List all files in `docs/audits/` and parse filenames:
- Pattern: `{YYYY-MM-DD}-{domain}-{target}.md`
- Extract: date, domain, target scope
- Group by domain, sort by date descending
- Identify the latest report per domain

For each report found, extract:
- Overall score and grade
- Per-dimension scores and grades
- Date of evaluation

## Step 3: Scan Plan Directories

Walk `docs/rx-plans/` directory structure:
- For each domain directory, read `summary.md` if it exists
- For each dimension directory, find all `v{N}-{date}-plan.md` files
- Determine: latest version, latest date, current status

Plan status determination:
- If the plan's score matches the latest report's score for that dimension: "Planning" (not started)
- If the plan's score is lower than the latest report's score: "In Progress" (some steps done)
- If the latest report shows 97+ for that dimension: "Complete"

## Step 4: Reconcile and Compute

Build the unified state:

```
For each domain found in audits or plans:
  - latest_report: date and scores from most recent audit
  - dimensions: list with current score, plan version, plan status
  - overall_score: from latest report
  - aplus_count: dimensions scoring 97+
  - total_dimensions: total dimension count for that domain
  - staleness: days since last report
```

## Step 5: Compute Recommendations

Generate three recommendation categories:

**Next rx to run** (staleness-based):
- Domain with the oldest report (most days since last evaluation)
- If no reports exist yet, recommend the most foundational: `code-rx` first, then `arch-rx`

**Highest-impact plan** (gap-based):
- Among active plans, find the one with the largest score gap AND smallest effort
- Formula: `priority = gap_points / effort_multiplier` where S=1, M=3, L=8

**Quick wins** (effort-based):
- Plans where Step 1 has effort = S and point impact >= 5
- These are the "do this in an hour, gain 5+ points" items

## Step 6: Render Output

### Full Dashboard (no filter)

```markdown
# rx-suite Dashboard

**Last updated**: {date}

## Overall Progress
| Domain | Score | Grade | Dimensions at A+ | Total | Progress |
|--------|-------|-------|-------------------|-------|----------|
| {domain} | {score} | {grade} | {count}/{total} | {total} | {bar} {pct}% |
| ... | ... | ... | ... | ... | ... |

## Active Plans
| Domain | Dimension | Version | Status | Next Action |
|--------|-----------|---------|--------|-------------|
| {domain} | {dim} | v{N} | {status} | {next step summary} |
| ... | ... | ... | ... | ... |

## Completed Dimensions (A+)
| Domain | Dimension | Achieved | Date |
|--------|-----------|----------|------|
| {domain} | {dim} | {score} (A+) | {date} |
| ... | ... | ... | ... |

## Recommendations
- **Next rx to run**: `/{domain}` -- last evaluated {N} days ago
- **Highest-impact plan**: {domain}/{dimension} -- {gap} point gap, effort {S/M/L}
- **Quick wins**:
  - {domain}/{dim} Step 1: {action} (+{N} pts, effort S)
  - ...

## Report Freshness
| Domain | Last Report | Days Ago | Recommendation |
|--------|------------|----------|----------------|
| {domain} | {date} | {N} | {Re-run / Current / Never run} |
| ... | ... | ... | ... |
```

### Domain Detail (filtered by domain)

When a specific domain is given, show the full summary.md content plus:
- All dimension plan versions with dates
- Expanded gap analysis for each active plan
- The complete step list for the highest-priority dimension

### Active Only (filter: `active`)

Show only the "Active Plans" table and "Recommendations" section.

### Next Only (filter: `next`)

Show a single focused output:

```markdown
## Next Action

**Domain**: {domain}
**Dimension**: {dimension}
**Plan**: v{N} ({date})
**Step**: {step number} -- {action summary}
**Effort**: {S/M/L}
**Expected Impact**: +{N} points on {sub-metric}

### Details
{Full step content from the plan}
```

## Rules

1. **Dashboard reflects reality.** If `docs/rx-plans/dashboard.md` is stale (reports or plans
   have been added since last update), regenerate it from source files before displaying.

2. **Never fabricate scores.** All scores come from actual rx report files. If no report exists
   for a domain, show "Not evaluated" instead of a score.

3. **Staleness drives recommendations.** The domain with the oldest (or missing) report is
   always the top recommendation for "next rx to run".

4. **Progress bars are visual.** Use block characters to render progress proportional to
   the percentage of dimensions at A+. 10 characters total width.

5. **Active plans are actionable.** The "Next Action" column in the Active Plans table
   must contain a concrete, specific action from the plan's step list -- not generic text.

6. **Quick wins are always surfaced.** If any plan has a Step with effort S and impact >= 5
   points, it appears in the Quick Wins section regardless of other filters.

7. **Domain ordering is by score ascending.** Lowest-scoring domains appear first in the
   dashboard -- they need the most attention.

8. **Handle missing data gracefully.** If `docs/rx-plans/` does not exist, state that no
   plans have been generated yet and recommend running an rx skill first. If `docs/audits/`
   does not exist, state that no evaluations have been run.

9. **Update the file when regenerating.** When the dashboard is rebuilt from source files,
   write the updated content to `docs/rx-plans/dashboard.md` so it serves as a cache for
   future fast-path reads.

10. **Cross-reference reports and plans.** If a report exists but no plan has been generated
    for its below-A+ dimensions, flag this in the dashboard with a note: "Plans pending --
    run `/rx-plan {domain}` to generate."

11. **Show timeline when available.** If domain summaries contain timeline data, include
    a condensed version in the domain detail view showing score progression over time.

12. **Completed dimensions are celebrated.** Dimensions that have reached A+ are shown in
    a dedicated "Completed" section. This provides positive reinforcement and shows progress.

13. **Filter combinations are allowed.** `rx-dashboard arch-rx active` shows only active
    plans for arch-rx. Filters compose naturally.

14. **Date formatting is ISO 8601.** All dates are `YYYY-MM-DD`. No relative dates in
    stored files (relative dates like "3 days ago" are acceptable only in live display).

15. **Dashboard creation is idempotent.** Running `rx-dashboard` twice with no changes
    produces identical output. No timestamps or random values affect the content beyond
    the "Last updated" field.
