# ops-rx Grading Framework

Complete threshold tables for all 32 sub-metrics across 8 dimensions.

---

## Grade Scale Reference

| Grade | Score Range | Operational Meaning                          |
|-------|-------------|----------------------------------------------|
| A+    | 95–100      | Elite — exemplary, could teach others        |
| A     | 85–94       | Strong — production-ready, minor polish      |
| B     | 70–84       | Adequate — works but gaps exist              |
| C     | 50–69       | Weak — significant risk in production        |
| D     | 30–49       | Poor — not ready for production traffic      |
| F     | 0–29        | Failing — critical gaps, immediate action    |

---

## D1: SLI/SLO/Error Budget (15%)

### M1.1: SLI Definition
| Grade | Criteria |
|-------|----------|
| A+    | All 4 SLI types (latency, availability, throughput, correctness) defined with precise measurement points and data sources. SLIs validated against user journey. |
| A     | 3+ SLI types defined, measurement points documented, data sources identified. |
| B     | 2 SLI types defined (typically latency + availability), basic measurement. |
| C     | 1 SLI type defined informally, no clear measurement methodology. |
| D     | SLIs mentioned in docs but not implemented or measured. |
| F     | No SLI definitions found. |

### M1.2: SLO Targets
| Grade | Criteria |
|-------|----------|
| A+    | SLOs documented per service, stakeholder-signed, reviewed quarterly, with historical compliance data. |
| A     | SLOs documented per service with clear numeric targets, stakeholder awareness. |
| B     | SLOs exist for critical services, targets defined but not formally agreed. |
| C     | Informal availability targets ("five nines") without measurement infrastructure. |
| D     | Targets mentioned in passing, no formal SLO documents. |
| F     | No SLO targets found. |

### M1.3: Error Budget Tracking
| Grade | Criteria |
|-------|----------|
| A+    | Error budgets calculated automatically, burn rate alerts (fast/slow), budget dashboard, policy for exhaustion. |
| A     | Error budgets calculated, burn rate monitored, alerts on high consumption. |
| B     | Error budgets calculated monthly, manual tracking, basic alerting. |
| C     | Concept understood but tracking is ad-hoc or incomplete. |
| D     | Error budgets mentioned but not calculated or tracked. |
| F     | No error budget tracking. |

### M1.4: SLO-Based Decision Making
| Grade | Criteria |
|-------|----------|
| A+    | Error budget explicitly gates releases, documented policy, exemption process, quarterly reviews. |
| A     | Error budget influences release decisions, documented in team processes. |
| B     | Team considers SLO compliance informally before releases. |
| C     | SLOs exist but do not influence operational decisions. |
| D     | Decisions are purely velocity-driven, SLOs are decorative. |
| F     | No connection between reliability data and decision making. |

---

## D2: Alerting Quality (15%)

### M2.1: Signal-to-Noise Ratio
| Grade | Criteria |
|-------|----------|
| A+    | <5% false positive rate, every alert leads to action, regular noise audits, alert fatigue metrics tracked. |
| A     | <10% false positive rate, most alerts actionable, periodic review. |
| B     | 10–25% noise, some non-actionable alerts, occasional review. |
| C     | 25–50% noise, significant alert fatigue reported by on-call. |
| D     | >50% noise, on-call regularly ignores alerts. |
| F     | No alerting or all alerts ignored. |

### M2.2: Alert Severity Levels
| Grade | Criteria |
|-------|----------|
| A+    | 3+ severity tiers (page/ticket/info), routing rules per severity, escalation automation, SLO-aligned thresholds. |
| A     | 3 severity tiers with proper routing, most alerts correctly classified. |
| B     | 2 tiers (page/non-page), basic routing, some misclassification. |
| C     | Single severity level, everything pages or everything is a ticket. |
| D     | Alerts exist but no severity distinction. |
| F     | No structured alerting. |

### M2.3: Alert Documentation
| Grade | Criteria |
|-------|----------|
| A+    | Every alert links to runbook, runbook includes context/impact/resolution steps/rollback, validated quarterly. |
| A     | >80% of alerts link to runbooks with resolution steps. |
| B     | 50–80% of alerts have some documentation. |
| C     | <50% documented, docs are stale or unhelpful. |
| D     | Few alerts documented, documentation is afterthought. |
| F     | No alert documentation. |

### M2.4: Alert Testing
| Grade | Criteria |
|-------|----------|
| A+    | Alerts tested in CI/staging, dead alert detection automated, alert coverage tracked, chaos-verified. |
| A     | Alerts tested in staging, dead alert cleanup quarterly. |
| B     | Some alerts manually tested, occasional cleanup. |
| C     | Alerts deployed without testing, cleanup rare. |
| D     | Unknown which alerts fire, no testing process. |
| F     | No alert testing or validation. |

---

## D3: Incident Response (15%)

### M3.1: Incident Process
| Grade | Criteria |
|-------|----------|
| A+    | Defined IR playbook with IC/scribe/comms roles, severity classification, automated war room creation, regular drills. |
| A     | Documented IR process with roles assigned, severity matrix, practiced at least annually. |
| B     | Basic IR process exists, roles loosely defined, inconsistently followed. |
| C     | Ad-hoc incident response, heroic individuals, no formal process. |
| D     | Incidents handled reactively with no coordination structure. |
| F     | No incident response process. |

### M3.2: On-Call Rotation
| Grade | Criteria |
|-------|----------|
| A+    | Fair rotation, compensation policy, primary/secondary, handoff docs, escalation automation, burnout tracking. |
| A     | Structured rotation, primary/secondary, documented escalation, handoff notes. |
| B     | Basic rotation exists, escalation paths mostly defined. |
| C     | Informal on-call, same people always respond, no escalation. |
| D     | On-call exists in name only, no structure. |
| F     | No on-call rotation. |

### M3.3: Post-Mortems
| Grade | Criteria |
|-------|----------|
| A+    | Blameless post-mortems for every SEV1/2, action items tracked to completion, SLO impact quantified, shared org-wide. |
| A     | Blameless post-mortems for major incidents, action items tracked, lessons shared. |
| B     | Post-mortems written for some incidents, action items created but not always completed. |
| C     | Post-mortems written occasionally, blame-oriented, action items ignored. |
| D     | Post-mortems rare, no standard template. |
| F     | No post-mortem practice. |

### M3.4: Communication Templates
| Grade | Criteria |
|-------|----------|
| A+    | Templates for status page, stakeholder updates, customer comms, regulatory notification, automated status page integration. |
| A     | Templates for status page and stakeholder updates, regularly used. |
| B     | Basic status page template, ad-hoc stakeholder communication. |
| C     | No templates, communication is improvised during incidents. |
| D     | Communication happens but is chaotic and inconsistent. |
| F     | No incident communication structure. |

---

## D4: DORA Metrics (10%)

### M4.1: Deployment Frequency
| Grade | Criteria |
|-------|----------|
| A+    | On-demand, multiple deploys per day, fully automated, any engineer can deploy. |
| A     | Daily to weekly deployments, automated pipeline. |
| B     | Weekly to monthly deployments, semi-automated. |
| C     | Monthly to quarterly, manual coordination required. |
| D     | Quarterly or less, deployment is a major event. |
| F     | No regular deployment cadence, ad-hoc releases. |

### M4.2: Lead Time for Changes
| Grade | Criteria |
|-------|----------|
| A+    | <1 hour commit to production, automated testing and deployment. |
| A     | <1 day, automated pipeline with minimal manual gates. |
| B     | 1 day to 1 week, some manual approvals. |
| C     | 1 week to 1 month, significant manual process. |
| D     | 1–6 months, heavy approval overhead. |
| F     | >6 months or unknown lead time. |

### M4.3: Change Failure Rate
| Grade | Criteria |
|-------|----------|
| A+    | <5% of changes cause incidents, with automated rollback. |
| A     | 5–10%, rollback process documented and practiced. |
| B     | 10–15%, rollback possible but manual. |
| C     | 15–30%, failures require significant effort to fix. |
| D     | 30–50%, deployments are high-risk events. |
| F     | >50% or unmeasured failure rate. |

### M4.4: Mean Time to Recover (MTTR)
| Grade | Criteria |
|-------|----------|
| A+    | <15 minutes, automated detection and remediation for common failures. |
| A     | <1 hour, rapid detection and practiced response. |
| B     | 1–4 hours, reasonable detection and response. |
| C     | 4–24 hours, slow detection or response. |
| D     | 1–7 days, major incidents drag on. |
| F     | >1 week or unknown recovery time. |

---

## D5: Runbook Coverage (10%)

### M5.1: Runbook Existence
| Grade | Criteria |
|-------|----------|
| A+    | Every service, alert, and operational procedure has a runbook, indexed and searchable, linked from alerts. |
| A     | >80% of services and critical alerts have runbooks. |
| B     | 50–80% coverage, critical services covered. |
| C     | <50% coverage, only some services documented. |
| D     | Few runbooks exist, mostly tribal knowledge. |
| F     | No runbooks. |

### M5.2: Runbook Quality
| Grade | Criteria |
|-------|----------|
| A+    | Steps are testable, include expected outputs, rollback procedures, escalation criteria, time estimates. |
| A     | Clear step-by-step, rollback included, recently validated. |
| B     | Reasonable steps but some ambiguity, rollback sometimes missing. |
| C     | High-level guidance only, not executable by a new team member. |
| D     | Runbooks exist but are outdated or misleading. |
| F     | No quality standards for runbooks. |

### M5.3: Automation Level
| Grade | Criteria |
|-------|----------|
| A+    | >80% of runbook steps automated, human judgment only where required, self-healing for known issues. |
| A     | 50–80% automated, common scenarios have scripts. |
| B     | 25–50% automated, key operations have tooling. |
| C     | <25% automated, mostly manual copy-paste commands. |
| D     | No automation, fully manual procedures. |
| F     | No runbooks to automate. |

### M5.4: Runbook Maintenance
| Grade | Criteria |
|-------|----------|
| A+    | Quarterly review cadence enforced, last-updated tracked, stale detection automated, ownership assigned. |
| A     | Semi-annual review, last-updated dates present, ownership clear. |
| B     | Annual review attempted, some staleness tracking. |
| C     | No review cadence, runbooks slowly decay. |
| D     | Runbooks written once and abandoned. |
| F     | No maintenance process. |

---

## D6: Capacity & Scaling (10%)

### M6.1: Load Testing
| Grade | Criteria |
|-------|----------|
| A+    | Regular load tests in CI/CD, baseline tracked over time, regression alerts, chaos engineering integrated. |
| A     | Quarterly load tests, baseline documented, results compared. |
| B     | Annual or ad-hoc load testing, basic results recorded. |
| C     | Load tested once, results not maintained. |
| D     | Load testing discussed but not performed. |
| F     | No load testing. |

### M6.2: Auto-Scaling Configured
| Grade | Criteria |
|-------|----------|
| A+    | Multi-metric scaling (CPU, memory, custom), policies tuned, cool-down optimized, scale-to-zero where appropriate. |
| A     | Auto-scaling on primary metric, min/max defined, tested under load. |
| B     | Basic auto-scaling configured, min/max set but not validated. |
| C     | Auto-scaling configured but never tested or tuned. |
| D     | Manual scaling, requires human intervention. |
| F     | No scaling strategy, fixed capacity. |

### M6.3: Resource Monitoring
| Grade | Criteria |
|-------|----------|
| A+    | CPU/memory/disk/connections/queue depth tracked, thresholds set, predictive alerts, capacity dashboards. |
| A     | Core resources monitored with threshold alerts, dashboards available. |
| B     | Basic monitoring (CPU/memory), some alerts. |
| C     | Monitoring exists but incomplete, limited alerting. |
| D     | Minimal monitoring, mostly reactive discovery. |
| F     | No resource monitoring. |

### M6.4: Capacity Planning
| Grade | Criteria |
|-------|----------|
| A+    | Growth projections modeled, headroom policy (e.g., 30% buffer), quarterly capacity reviews, cost-aware planning. |
| A     | Growth estimates documented, headroom maintained, annual planning. |
| B     | Informal capacity awareness, some headroom maintained. |
| C     | Reactive capacity management, scaling when problems arise. |
| D     | No capacity planning, surprises are frequent. |
| F     | No awareness of capacity limits. |

---

## D7: Disaster Recovery (10%)

### M7.1: Backup Strategy
| Grade | Criteria |
|-------|----------|
| A+    | Automated backups, tested monthly, offsite + cross-region, encrypted, retention policy, restore time validated. |
| A     | Automated backups, tested quarterly, offsite, encrypted. |
| B     | Automated backups, tested annually, basic offsite storage. |
| C     | Backups exist but rarely tested, single location. |
| D     | Backups configured but never validated. |
| F     | No backup strategy. |

### M7.2: Recovery Testing
| Grade | Criteria |
|-------|----------|
| A+    | Quarterly DR drills, RTO/RPO verified, results documented, findings remediated, game days. |
| A     | Semi-annual DR drills, RTO/RPO measured, documented. |
| B     | Annual DR drill, basic validation. |
| C     | DR drill attempted once, partial success. |
| D     | DR plan exists on paper, never tested. |
| F     | No DR testing. |

### M7.3: Multi-Region Readiness
| Grade | Criteria |
|-------|----------|
| A+    | Active-active multi-region, automated failover, data replication validated, regular failover tests. |
| A     | Active-passive multi-region, failover tested, replication monitored. |
| B     | Multi-region infrastructure exists, failover manual, replication configured. |
| C     | Single region with backup region planned. |
| D     | Single region, no multi-region plans. |
| F     | No consideration of regional failure. |

### M7.4: Business Continuity
| Grade | Criteria |
|-------|----------|
| A+    | Degraded mode defined per service, priority tiers documented, stakeholders informed, tested in drills. |
| A     | Degraded modes documented, priority services identified, basic stakeholder plan. |
| B     | Some degraded modes considered, priority services loosely defined. |
| C     | Business continuity discussed but not formalized. |
| D     | No degraded mode planning. |
| F     | No business continuity awareness. |

---

## D8: Cost & Efficiency (15%)

### M8.1: Resource Tagging
| Grade | Criteria |
|-------|----------|
| A+    | Mandatory tagging enforced in IaC/CI, cost allocation per team/service/env, tag compliance >95%. |
| A     | Tagging standard defined, >80% compliance, cost allocation enabled. |
| B     | Tagging exists for most resources, 50–80% compliance. |
| C     | Partial tagging, <50% compliance, cost allocation incomplete. |
| D     | Some resources tagged ad-hoc, no standard. |
| F     | No resource tagging. |

### M8.2: Right-Sizing
| Grade | Criteria |
|-------|----------|
| A+    | Regular right-sizing reviews, spot/preemptible for stateless, reserved instances optimized, savings tracked. |
| A     | Annual right-sizing, spot instances used, reserved instances for steady-state. |
| B     | Some right-sizing done, occasional spot usage. |
| C     | Instance sizes chosen at creation and never revisited. |
| D     | Over-provisioned as default strategy. |
| F     | No awareness of right-sizing. |

### M8.3: Budget Alerts
| Grade | Criteria |
|-------|----------|
| A+    | Cost anomaly detection automated, threshold alerts at 50/80/100%, budget per team/service, monthly reviews. |
| A     | Budget alerts configured, anomaly detection enabled, quarterly reviews. |
| B     | Basic budget alerts (e.g., 80% threshold), occasional review. |
| C     | Cloud billing monitored manually, alerts inconsistent. |
| D     | Cost reviewed only when bill spikes. |
| F     | No cost monitoring or alerts. |

### M8.4: Waste Elimination
| Grade | Criteria |
|-------|----------|
| A+    | Automated idle resource detection, unused storage cleanup, orphan resource scanning, savings >20% annually. |
| A     | Regular waste reviews, idle resources identified and cleaned, savings tracked. |
| B     | Occasional waste cleanup, some automated detection. |
| C     | Waste acknowledged but not systematically addressed. |
| D     | Waste suspected but not measured. |
| F     | No waste awareness. |

---

## Aggregate Scoring

The overall score is calculated as a weighted sum:

```
Overall = (D1 × 0.15) + (D2 × 0.15) + (D3 × 0.15) + (D4 × 0.10)
        + (D5 × 0.10) + (D6 × 0.10) + (D7 × 0.10) + (D8 × 0.15)
```

Each dimension score is the average of its 4 sub-metric scores (0–100).

Sub-metric numeric scores map from grades:
- A+ = 97, A = 89, B = 77, C = 59, D = 39, F = 15
