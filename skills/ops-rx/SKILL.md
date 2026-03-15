---
name: ops-rx
description: >
  Prescriptive operational and SRE maturity evaluation producing scored diagnostic maps.
  Evaluates whether you can OPERATE a system reliably in production — beyond architecture
  and code quality. Measures 8 dimensions (32 sub-metrics) against Google SRE, DORA,
  FinOps, and AWS Well-Architected frameworks. Produces per-dimension scorecards with
  actionable prescriptions and aggregate grades.
triggers:
  - "run ops-rx"
  - "SRE audit"
  - "operational maturity"
  - "production readiness"
  - "ops review"
  - "operations review"
  - "SRE maturity"
  - "production readiness review"
---

## Prerequisites

None (POSIX only)

Check all dependencies: `bash scripts/rx-deps.sh` or `bash scripts/rx-deps.sh --install`


# ops-rx — Operational & SRE Maturity Diagnostic

## Purpose

Evaluate operational maturity across 8 dimensions with 32 sub-metrics. Produces
objective, repeatable grades and actionable prescriptions for reaching production
excellence.

## Dimensions & Weights

| Dim | Name                   | Weight | Sub-metrics | Source                                        |
|-----|------------------------|--------|-------------|-----------------------------------------------|
| D1  | SLI/SLO/Error Budget   | 15%    | M1.1–M1.4   | Google SRE Book (ch. 4-5), SLO Workbook       |
| D2  | Alerting Quality       | 15%    | M2.1–M2.4   | Google SRE Book (ch. 6), Ewaschuk philosophy  |
| D3  | Incident Response      | 15%    | M3.1–M3.4   | PagerDuty IR Guide, Google SRE Book (ch. 14)  |
| D4  | DORA Metrics           | 10%    | M4.1–M4.4   | Accelerate (Forsgren, Humble, Kim)            |
| D5  | Runbook Coverage       | 10%    | M5.1–M5.4   | SRE Workbook, Runbook best practices          |
| D6  | Capacity & Scaling     | 10%    | M6.1–M6.4   | AWS Well-Architected Reliability Pillar       |
| D7  | Disaster Recovery      | 10%    | M7.1–M7.4   | AWS DR whitepaper, RTO/RPO patterns           |
| D8  | Cost & Efficiency      | 15%    | M8.1–M8.4   | FinOps Foundation, AWS Cost Optimization      |

## Sub-metrics

### D1: SLI/SLO/Error Budget (15%)
- **M1.1: SLI definition** — latency, availability, throughput, correctness defined
- **M1.2: SLO targets** — documented, measurable, stakeholder-agreed
- **M1.3: Error budget tracking** — budget calculated, burn rate alerts configured
- **M1.4: SLO-based decision making** — budget informs release velocity and toil prioritization

### D2: Alerting Quality (15%)
- **M2.1: Signal-to-noise ratio** — alerts are actionable, not noisy
- **M2.2: Alert severity levels** — paging vs ticket vs info, proper routing
- **M2.3: Alert documentation** — every alert links to a runbook
- **M2.4: Alert testing** — alerts verified in staging, dead alert cleanup process

### D3: Incident Response (15%)
- **M3.1: Incident process** — defined roles: IC, scribe, comms lead
- **M3.2: On-call rotation** — fair rotation, escalation paths, handoff process
- **M3.3: Post-mortems** — blameless, action items tracked, SLO impact noted
- **M3.4: Communication templates** — status page, stakeholder updates, customer comms

### D4: DORA Metrics (10%)
- **M4.1: Deployment frequency** — how often code ships to production
- **M4.2: Lead time for changes** — commit to production duration
- **M4.3: Change failure rate** — % of deployments causing incidents
- **M4.4: Mean time to recover** — MTTR from incident detection to resolution

### D5: Runbook Coverage (10%)
- **M5.1: Runbook existence** — every service and alert has a runbook
- **M5.2: Runbook quality** — steps are testable, not stale, include rollback
- **M5.3: Automation level** — runbook steps automated where possible
- **M5.4: Runbook maintenance** — review cadence, last-updated tracking

### D6: Capacity & Scaling (10%)
- **M6.1: Load testing** — regular baseline testing, regression tracked
- **M6.2: Auto-scaling configured** — policies, min/max, cool-down tuned
- **M6.3: Resource monitoring** — CPU/memory/disk/connections tracked with thresholds
- **M6.4: Capacity planning** — growth projections, headroom policy documented

### D7: Disaster Recovery (10%)
- **M7.1: Backup strategy** — automated, tested, offsite, encrypted
- **M7.2: Recovery testing** — DR drills executed, RTO/RPO verified
- **M7.3: Multi-region readiness** — failover configured, data replication active
- **M7.4: Business continuity** — degraded mode definitions, priority services identified

### D8: Cost & Efficiency (15%)
- **M8.1: Resource tagging** — all resources tagged, cost allocation enabled
- **M8.2: Right-sizing** — instance sizing matches load, spot/preemptible usage
- **M8.3: Budget alerts** — cost anomaly detection, threshold alerts configured
- **M8.4: Waste elimination** — idle resources, unused storage, over-provisioned instances

## Workflow

1. **Discover** — Run `scripts/discover.sh` to scan the repo for ops artifacts
2. **Grade** — Apply thresholds from `references/grading-framework.md` to each sub-metric
3. **Report** — Use `references/output-templates.md` to produce the scorecard
4. **Prescribe** — For each sub-metric scoring below A, prescribe concrete next steps

## Grading Scale

| Grade | Range     | Meaning                                      |
|-------|-----------|----------------------------------------------|
| A+    | 95–100    | Elite — exemplary operational maturity        |
| A     | 85–94     | Strong — production-ready with minor gaps     |
| B     | 70–84     | Adequate — functional but improvement needed  |
| C     | 50–69     | Weak — significant operational risk           |
| D     | 30–49     | Poor — not production-ready                   |
| F     | 0–29      | Failing — critical operational gaps           |

## Output

The skill produces:
1. Per-dimension scorecard with letter grade and numeric score
2. Aggregate weighted score and overall grade
3. Top-5 priority prescriptions ranked by risk × effort
4. Mermaid radar chart of all 8 dimensions

## Auto-Plan Integration

After generating the scorecard and saving the report to `docs/audits/`:
1. Save a copy of the report to `docs/rx-plans/{this-skill-name}/{date}-report.md`
2. For each dimension scoring below 97, invoke the `rx-plan` skill to create or update the improvement plan at `docs/rx-plans/{this-skill-name}/{dimension}/v{N}-{date}-plan.md`
3. Update `docs/rx-plans/{this-skill-name}/summary.md` with current scores
4. Update `docs/rx-plans/dashboard.md` with overall progress

This happens automatically — the user does not need to run `/rx-plan` separately.
