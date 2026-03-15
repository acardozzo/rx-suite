# ops-rx Output Templates

## Template 1: Executive Summary

```markdown
# ops-rx — Operational Maturity Diagnostic

**Project:** {{project_name}}
**Date:** {{date}}
**Overall Grade:** {{overall_grade}} ({{overall_score}}/100)

## Radar Chart

```mermaid
%%{init: {'theme': 'dark'}}%%
radar-beta
  title ops-rx Dimensional Scores
  axis D1["SLI/SLO"] D2["Alerting"] D3["Incident Response"] D4["DORA"] D5["Runbooks"] D6["Capacity"] D7["DR"] D8["Cost"]
  line "Current" : [{{d1_score}}, {{d2_score}}, {{d3_score}}, {{d4_score}}, {{d5_score}}, {{d6_score}}, {{d7_score}}, {{d8_score}}]
  line "Target" : [85, 85, 85, 85, 85, 85, 85, 85]
``​`

## Scorecard

| Dim | Dimension              | Weight | Score | Grade | Status |
|-----|------------------------|--------|-------|-------|--------|
| D1  | SLI/SLO/Error Budget   | 15%    | {{d1_score}} | {{d1_grade}} | {{d1_status}} |
| D2  | Alerting Quality       | 15%    | {{d2_score}} | {{d2_grade}} | {{d2_status}} |
| D3  | Incident Response      | 15%    | {{d3_score}} | {{d3_grade}} | {{d3_status}} |
| D4  | DORA Metrics           | 10%    | {{d4_score}} | {{d4_grade}} | {{d4_status}} |
| D5  | Runbook Coverage       | 10%    | {{d5_score}} | {{d5_grade}} | {{d5_status}} |
| D6  | Capacity & Scaling     | 10%    | {{d6_score}} | {{d6_grade}} | {{d6_status}} |
| D7  | Disaster Recovery      | 10%    | {{d7_score}} | {{d7_grade}} | {{d7_status}} |
| D8  | Cost & Efficiency      | 15%    | {{d8_score}} | {{d8_grade}} | {{d8_status}} |
| **Overall** |                | **100%** | **{{overall_score}}** | **{{overall_grade}}** | |
```

Status icons: pass = meets target, warn = near target, fail = below target, skip = not applicable

---

## Template 2: Dimension Detail Card

```markdown
### {{dimension_id}}: {{dimension_name}} — {{dimension_grade}} ({{dimension_score}}/100)

| Sub-metric | Description | Score | Grade | Evidence |
|------------|-------------|-------|-------|----------|
| {{m_id_1}} | {{m_desc_1}} | {{m_score_1}} | {{m_grade_1}} | {{m_evidence_1}} |
| {{m_id_2}} | {{m_desc_2}} | {{m_score_2}} | {{m_grade_2}} | {{m_evidence_2}} |
| {{m_id_3}} | {{m_desc_3}} | {{m_score_3}} | {{m_grade_3}} | {{m_evidence_3}} |
| {{m_id_4}} | {{m_desc_4}} | {{m_score_4}} | {{m_grade_4}} | {{m_evidence_4}} |

**Findings:**
- {{finding_1}}
- {{finding_2}}

**Prescription (current {{current_grade}} -> target {{target_grade}}):**
1. {{action_1}}
2. {{action_2}}
3. {{action_3}}
```

---

## Template 3: Top-5 Priority Prescriptions

```markdown
## Top-5 Priority Prescriptions

Ranked by (risk x reversibility x effort). Higher risk and lower effort = higher priority.

| # | Dimension | Sub-metric | Current | Target | Action | Effort | Impact |
|---|-----------|------------|---------|--------|--------|--------|--------|
| 1 | {{dim}}   | {{metric}} | {{cur}} | {{tgt}} | {{action}} | {{effort}} | {{impact}} |
| 2 | {{dim}}   | {{metric}} | {{cur}} | {{tgt}} | {{action}} | {{effort}} | {{impact}} |
| 3 | {{dim}}   | {{metric}} | {{cur}} | {{tgt}} | {{action}} | {{effort}} | {{impact}} |
| 4 | {{dim}}   | {{metric}} | {{cur}} | {{tgt}} | {{action}} | {{effort}} | {{impact}} |
| 5 | {{dim}}   | {{metric}} | {{cur}} | {{tgt}} | {{action}} | {{effort}} | {{impact}} |

Effort: S (< 1 day), M (1–5 days), L (1–4 weeks), XL (> 1 month)
Impact: Critical, High, Medium, Low
```

---

## Template 4: Discovery Summary

```markdown
## Discovery Results

Scan completed at {{timestamp}}.

### Artifacts Found

| Category | Pattern | Files Found | Path |
|----------|---------|-------------|------|
| SLO definitions | `slo*.yaml`, `sli*.yaml` | {{count}} | {{paths}} |
| Alert configs | `alerts/*.yaml`, PagerDuty/OpsGenie configs | {{count}} | {{paths}} |
| Incident templates | `incident*.md`, post-mortem templates | {{count}} | {{paths}} |
| Runbooks | `runbook*`, `playbook*` | {{count}} | {{paths}} |
| Load test configs | `k6*.js`, `artillery*.yaml` | {{count}} | {{paths}} |
| Scaling configs | HPA, ASG, scaling policies | {{count}} | {{paths}} |
| Backup configs | backup scripts, retention policies | {{count}} | {{paths}} |
| DR docs | DR plans, RTO/RPO docs | {{count}} | {{paths}} |
| Cost configs | budget alerts, tagging policies | {{count}} | {{paths}} |
| CI/CD pipelines | deployment configs, pipeline definitions | {{count}} | {{paths}} |

### Signals Summary

- **Strong signals:** {{strong_signals}}
- **Weak signals:** {{weak_signals}}
- **Missing signals:** {{missing_signals}}
```

---

## Template 5: DORA Metrics Benchmark

```markdown
### DORA Metrics Benchmark

| Metric | Your Value | Elite | High | Medium | Low |
|--------|-----------|-------|------|--------|-----|
| Deployment Frequency | {{df_value}} | On-demand (multiple/day) | Daily–Weekly | Weekly–Monthly | Monthly–Quarterly |
| Lead Time for Changes | {{lt_value}} | <1 hour | 1 day–1 week | 1 week–1 month | 1–6 months |
| Change Failure Rate | {{cfr_value}} | 0–5% | 5–10% | 10–15% | 15–50% |
| MTTR | {{mttr_value}} | <15 min | <1 hour | <4 hours | 1–7 days |

**Your DORA classification:** {{dora_class}} performer
```

---

## Template 6: Comparison (Before/After)

```markdown
## ops-rx Comparison: {{before_date}} vs {{after_date}}

| Dimension | Before | After | Delta | Trend |
|-----------|--------|-------|-------|-------|
| D1: SLI/SLO/Error Budget | {{b_d1}} | {{a_d1}} | {{delta_d1}} | {{trend_d1}} |
| D2: Alerting Quality | {{b_d2}} | {{a_d2}} | {{delta_d2}} | {{trend_d2}} |
| D3: Incident Response | {{b_d3}} | {{a_d3}} | {{delta_d3}} | {{trend_d3}} |
| D4: DORA Metrics | {{b_d4}} | {{a_d4}} | {{delta_d4}} | {{trend_d4}} |
| D5: Runbook Coverage | {{b_d5}} | {{a_d5}} | {{delta_d5}} | {{trend_d5}} |
| D6: Capacity & Scaling | {{b_d6}} | {{a_d6}} | {{delta_d6}} | {{trend_d6}} |
| D7: Disaster Recovery | {{b_d7}} | {{a_d7}} | {{delta_d7}} | {{trend_d7}} |
| D8: Cost & Efficiency | {{b_d8}} | {{a_d8}} | {{delta_d8}} | {{trend_d8}} |
| **Overall** | **{{b_overall}}** | **{{a_overall}}** | **{{delta_overall}}** | {{trend_overall}} |

Trend: up_arrow = improved, down_arrow = regressed, dash = unchanged
```
