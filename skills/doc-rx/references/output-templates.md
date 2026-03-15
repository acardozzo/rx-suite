# Output Templates — doc-rx

## Template 1: Executive Summary

```
# doc-rx Report — {project_name}

**Date:** {date}
**Scope:** {scope_description}
**Overall Grade:** {grade} ({score}/100)

## Score Breakdown

| # | Dimension                        | Weight | Score | Grade |
|---|----------------------------------|--------|-------|-------|
| 1 | README & Project Overview        | 15%    | {s1}  | {g1}  |
| 2 | API Documentation                | 15%    | {s2}  | {g2}  |
| 3 | Code Documentation               | 10%    | {s3}  | {g3}  |
| 4 | Architecture Decision Records    | 15%    | {s4}  | {g4}  |
| 5 | Onboarding & Contributing        | 15%    | {s5}  | {g5}  |
| 6 | Changelog & Versioning           | 10%    | {s6}  | {g6}  |
| 7 | Tutorials & Guides               | 10%    | {s7}  | {g7}  |
| 8 | Error Messages & User-Facing Text| 10%    | {s8}  | {g8}  |
|   | **Weighted Total**               |        |**{t}**|**{tg}**|

## Top 3 Strengths
1. {strength_1}
2. {strength_2}
3. {strength_3}

## Top 3 Risks
1. {risk_1}
2. {risk_2}
3. {risk_3}

## Priority Actions (Next Sprint)
1. {action_1} — expected impact: +{pts_1} pts
2. {action_2} — expected impact: +{pts_2} pts
3. {action_3} — expected impact: +{pts_3} pts
```

---

## Template 2: Dimension Scorecard

Use one per dimension (D1-D8).

```
### D{n}: {dimension_name} — {grade} ({score}%)

| ID    | Sub-Metric              | Score | Evidence |
|-------|-------------------------|-------|----------|
| M{n}.1 | {metric_name}          | {s}/5 | {evidence_summary} |
| M{n}.2 | {metric_name}          | {s}/5 | {evidence_summary} |
| M{n}.3 | {metric_name}          | {s}/5 | {evidence_summary} |
| M{n}.4 | {metric_name}          | {s}/5 | {evidence_summary} |

**Dimension Average:** {avg}/5 ({pct}%)

**Findings:**
- {finding_1}
- {finding_2}

**Prescriptions:**
- [ ] {prescription_1} (target: +{pts} pts)
- [ ] {prescription_2} (target: +{pts} pts)
```

---

## Template 3: Evidence Log

Used during discovery to record raw signals.

```
## Evidence: M{n}.{m} — {metric_name}

**Score:** {score}/5
**Confidence:** {high|medium|low}

### Signals Found
- File: `{path}` — {observation}
- File: `{path}` — {observation}
- Pattern: {pattern_description} — {count} occurrences

### Signals Missing
- Expected: {what_was_expected}
- Searched: {where_searched}

### Notes
{free_text_notes}
```

---

## Template 4: Improvement Roadmap

```
## Documentation Improvement Roadmap

### Phase 1: Quick Wins (1-2 weeks) — Target: +{pts} pts
| Priority | Action | Dimension | Expected Impact |
|----------|--------|-----------|-----------------|
| P0       | {action} | D{n}    | +{pts} pts      |
| P0       | {action} | D{n}    | +{pts} pts      |

### Phase 2: Foundation (2-4 weeks) — Target: +{pts} pts
| Priority | Action | Dimension | Expected Impact |
|----------|--------|-----------|-----------------|
| P1       | {action} | D{n}    | +{pts} pts      |
| P1       | {action} | D{n}    | +{pts} pts      |

### Phase 3: Excellence (1-2 months) — Target: +{pts} pts
| Priority | Action | Dimension | Expected Impact |
|----------|--------|-----------|-----------------|
| P2       | {action} | D{n}    | +{pts} pts      |
| P2       | {action} | D{n}    | +{pts} pts      |

**Current Score:** {current}/100 ({current_grade})
**Target Score:** {target}/100 ({target_grade})
```

---

## Template 5: Comparison Table

For comparing documentation quality across multiple projects or services.

```
## Documentation Quality Comparison

| Dimension                  | {project_a} | {project_b} | {project_c} |
|----------------------------|-------------|-------------|-------------|
| D1: README                 | {g}         | {g}         | {g}         |
| D2: API Docs               | {g}         | {g}         | {g}         |
| D3: Code Docs              | {g}         | {g}         | {g}         |
| D4: ADRs                   | {g}         | {g}         | {g}         |
| D5: Onboarding             | {g}         | {g}         | {g}         |
| D6: Changelog              | {g}         | {g}         | {g}         |
| D7: Tutorials              | {g}         | {g}         | {g}         |
| D8: Error Messages         | {g}         | {g}         | {g}         |
| **Overall**                | **{g}**     | **{g}**     | **{g}**     |
```
