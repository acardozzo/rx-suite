# data-rx Output Templates

## Report Header

```markdown
# data-rx Data Model & Supabase Report

**Project:** {{PROJECT_NAME}}
**Scan Date:** {{SCAN_DATE}}
**Scan Path:** {{SCAN_PATH}}
**Overall Score:** {{OVERALL_SCORE}} — {{OVERALL_GRADE}}
**Stack:** Supabase (PostgreSQL + Auth + Storage + Edge Functions + Realtime + RLS)

---
```

## Executive Summary

```markdown
## Executive Summary

| Rating | Score | Grade | Action |
|--------|-------|-------|--------|
| {{OVERALL_RATING}} | {{OVERALL_SCORE}}/100 | {{OVERALL_GRADE}} | {{ACTION_REQUIRED}} |

**Top Risks:**
1. {{RISK_1}}
2. {{RISK_2}}
3. {{RISK_3}}

**Key Strengths:**
1. {{STRENGTH_1}}
2. {{STRENGTH_2}}
```

## Dimension Scorecard

```markdown
## Dimension Scores

| # | Dimension | Weight | Score | Grade | Weakest Sub-Metric |
|---|-----------|--------|-------|-------|---------------------|
| D1 | Schema Design & Normalization | 12% | {{D1_SCORE}} | {{D1_GRADE}} | {{D1_WEAKEST}} |
| D2 | Relationships & Foreign Keys | 10% | {{D2_SCORE}} | {{D2_GRADE}} | {{D2_WEAKEST}} |
| D3 | Indexing & Query Performance | 12% | {{D3_SCORE}} | {{D3_GRADE}} | {{D3_WEAKEST}} |
| D4 | Row-Level Security | 12% | {{D4_SCORE}} | {{D4_GRADE}} | {{D4_WEAKEST}} |
| D5 | Migrations & Schema Evolution | 10% | {{D5_SCORE}} | {{D5_GRADE}} | {{D5_WEAKEST}} |
| D6 | Supabase Auth Integration | 10% | {{D6_SCORE}} | {{D6_GRADE}} | {{D6_WEAKEST}} |
| D7 | Supabase Storage | 8% | {{D7_SCORE}} | {{D7_GRADE}} | {{D7_WEAKEST}} |
| D8 | Realtime & Edge Functions | 8% | {{D8_SCORE}} | {{D8_GRADE}} | {{D8_WEAKEST}} |
| D9 | Type Safety & Client Integration | 10% | {{D9_SCORE}} | {{D9_GRADE}} | {{D9_WEAKEST}} |
| D10 | Observability & Maintenance | 8% | {{D10_SCORE}} | {{D10_GRADE}} | {{D10_WEAKEST}} |

**Weighted Total: {{OVERALL_SCORE}}/100 ({{OVERALL_GRADE}})**

Computation:
(D1 * 0.12) + (D2 * 0.10) + (D3 * 0.12) + (D4 * 0.12) + (D5 * 0.10)
+ (D6 * 0.10) + (D7 * 0.08) + (D8 * 0.08) + (D9 * 0.10) + (D10 * 0.08) = {{OVERALL_SCORE}}
```

## Sub-Metric Detail Block

Use this template for each dimension's detailed breakdown:

```markdown
### D{{N}}: {{DIMENSION_NAME}} — {{D_SCORE}} ({{D_GRADE}})

| ID | Sub-Metric | Weight | Raw Value | Score | Threshold Row |
|----|-----------|--------|-----------|-------|---------------|
| M{{N}}.1 | {{METRIC_NAME}} | 25% | {{RAW_VALUE}} | {{SCORE}} | {{THRESHOLD_ROW}} |
| M{{N}}.2 | {{METRIC_NAME}} | 25% | {{RAW_VALUE}} | {{SCORE}} | {{THRESHOLD_ROW}} |
| M{{N}}.3 | {{METRIC_NAME}} | 25% | {{RAW_VALUE}} | {{SCORE}} | {{THRESHOLD_ROW}} |
| M{{N}}.4 | {{METRIC_NAME}} | 25% | {{RAW_VALUE}} | {{SCORE}} | {{THRESHOLD_ROW}} |

Dimension Score: (M{{N}}.1 * 0.25) + (M{{N}}.2 * 0.25) + (M{{N}}.3 * 0.25) + (M{{N}}.4 * 0.25) = {{D_SCORE}}

**Findings:**
- {{FINDING_1}}: `{{FILE_PATH}}` — {{DESCRIPTION}}
- {{FINDING_2}}: `{{FILE_PATH}}` — {{DESCRIPTION}}

**Recommendations:**
1. {{REC_1}}
2. {{REC_2}}
```

## Supabase Feature Adoption Matrix

```markdown
## Supabase Feature Adoption Matrix

| Feature | Status | Evidence | Recommendation |
|---------|--------|----------|----------------|
| PostgreSQL RLS | {{STATUS}} | {{EVIDENCE}} | {{REC}} |
| Supabase Auth (GoTrue) | {{STATUS}} | {{EVIDENCE}} | {{REC}} |
| Supabase Storage | {{STATUS}} | {{EVIDENCE}} | {{REC}} |
| Supabase Realtime | {{STATUS}} | {{EVIDENCE}} | {{REC}} |
| Edge Functions (Deno) | {{STATUS}} | {{EVIDENCE}} | {{REC}} |
| Generated Types | {{STATUS}} | {{EVIDENCE}} | {{REC}} |
| CLI Migrations | {{STATUS}} | {{EVIDENCE}} | {{REC}} |
| Connection Pooler | {{STATUS}} | {{EVIDENCE}} | {{REC}} |
| Image Transforms | {{STATUS}} | {{EVIDENCE}} | {{REC}} |
| PITR Backup | {{STATUS}} | {{EVIDENCE}} | {{REC}} |

Status values: Adopted, Partial, Missing, N/A
```

## RLS Policy Audit Table

```markdown
## RLS Policy Audit

| Table | RLS Enabled | FORCE RLS | SELECT | INSERT | UPDATE | DELETE | Auth Check | Issues |
|-------|-------------|-----------|--------|--------|--------|--------|------------|--------|
| {{TABLE}} | {{Y/N}} | {{Y/N}} | {{POLICY_NAME}} | {{POLICY_NAME}} | {{POLICY_NAME}} | {{POLICY_NAME}} | {{auth.uid()/jwt()}} | {{ISSUES}} |

Summary:
- Tables with RLS: {{COUNT}} / {{TOTAL}}
- Tables with FORCE RLS: {{COUNT}} / {{TOTAL}}
- Tables with complete policies (all CRUD): {{COUNT}} / {{TOTAL}}
- Tables using auth.uid(): {{COUNT}} / {{TOTAL}}
- USING(true) violations: {{COUNT}}
```

## Migration Timeline

```markdown
## Migration Timeline

| # | Timestamp | Filename | Tables Created/Altered | RLS Policies | Indexes | Issues |
|---|-----------|----------|----------------------|--------------|---------|--------|
| 1 | {{TIMESTAMP}} | {{FILENAME}} | {{TABLES}} | {{RLS_COUNT}} | {{IDX_COUNT}} | {{ISSUES}} |

Summary:
- Total migrations: {{COUNT}}
- Migrations with RLS: {{COUNT}}
- Migrations with indexes: {{COUNT}}
- Seed file present: {{Y/N}}
```

## Schema Diagram (Mermaid)

```markdown
## Schema Diagram

### Before (Current State)

\`\`\`mermaid
erDiagram
    {{TABLE_1}} ||--o{ {{TABLE_2}} : "has many"
    {{TABLE_1}} {
        uuid id PK
        text name
        timestamptz created_at
    }
    {{TABLE_2}} {
        uuid id PK
        uuid table_1_id FK
        text content
    }
\`\`\`

### After (Recommended)

\`\`\`mermaid
erDiagram
    [diagram with recommended changes highlighted]
\`\`\`
```

## Top Issues & Recommendations

```markdown
## Top 5 Issues (Highest Impact)

1. **{{ISSUE}}** — D{{N}} (M{{N}}.{{X}}) — fixing raises overall score by ~{{POINTS}} points
   - File: `{{FILE_PATH}}`
   - Current: {{CURRENT_STATE}}
   - Fix: {{RECOMMENDED_FIX}}
   - Effort: {{EFFORT_ESTIMATE}}

2. ...
```

## Remediation Roadmap

```markdown
## Remediation Roadmap

### Immediate (This Sprint)
| Priority | Issue | Dimension | Effort | Score Impact |
|----------|-------|-----------|--------|--------------|
| P0 | {{ISSUE}} | D{{N}} | {{EFFORT}} | +{{POINTS}} |

### Short-Term (Next 2 Sprints)
| Priority | Issue | Dimension | Effort | Score Impact |
|----------|-------|-----------|--------|--------------|
| P1 | {{ISSUE}} | D{{N}} | {{EFFORT}} | +{{POINTS}} |

### Medium-Term (Next Quarter)
| Priority | Issue | Dimension | Effort | Score Impact |
|----------|-------|-----------|--------|--------------|
| P2 | {{ISSUE}} | D{{N}} | {{EFFORT}} | +{{POINTS}} |
```

## Score Projection

```markdown
## Score Projection

| Dimension | Current | After P0 | After P1 | After P2 | Target |
|-----------|---------|----------|----------|----------|--------|
| D1 Schema | {{C}} | {{P0}} | {{P1}} | {{P2}} | 97+ |
| D2 Relationships | {{C}} | {{P0}} | {{P1}} | {{P2}} | 97+ |
| D3 Indexing | {{C}} | {{P0}} | {{P1}} | {{P2}} | 97+ |
| D4 RLS | {{C}} | {{P0}} | {{P1}} | {{P2}} | 97+ |
| D5 Migrations | {{C}} | {{P0}} | {{P1}} | {{P2}} | 97+ |
| D6 Auth | {{C}} | {{P0}} | {{P1}} | {{P2}} | 97+ |
| D7 Storage | {{C}} | {{P0}} | {{P1}} | {{P2}} | 97+ |
| D8 Realtime/Edge | {{C}} | {{P0}} | {{P1}} | {{P2}} | 97+ |
| D9 Types | {{C}} | {{P0}} | {{P1}} | {{P2}} | 97+ |
| D10 Observability | {{C}} | {{P0}} | {{P1}} | {{P2}} | 97+ |
| **Overall** | **{{C}}** | **{{P0}}** | **{{P1}}** | **{{P2}}** | **97+** |
```

## Footer

```markdown
---
*Generated by data-rx v1.0 — Data Model & Supabase Quality Evaluation*
*Methodology: PostgreSQL docs, Supabase official patterns, Database Design (Date), Use The Index Luke*
*Fixed stack: Supabase (PostgreSQL + Auth + Storage + Edge Functions + Realtime + RLS)*
```
