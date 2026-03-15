---
name: arch-rx
description: >
  Prescriptive architectural decision evaluation producing scored ADR opportunity maps. Complements
  code-rx by evaluating runtime architecture against POSA, EIP, 12-Factor, CNCF, NIST Zero Trust,
  SLSA, and Well-Architected Frameworks. Use when: identifying where to add queues, async processing,
  circuit breakers, caching, protocol changes, multi-tenancy, or AI/ML patterns; evaluating security
  architecture; or when the user says "prescribe architecture", "run arch-rx", "pattern fit",
  "architectural opportunities", or "how to reach A+ architecture". Measures 11 dimensions
  (44 sub-metrics). Stack-agnostic — adapts to Node.js, Go, JVM, Python, Rust, .NET.
---

## Prerequisites

Recommended: `madge`, `hadolint`, `syft`

Check all dependencies: `bash scripts/rx-deps.sh` or `bash scripts/rx-deps.sh --install`


# Architectural Decision & Pattern Fitness Grading

Evaluate architectural pattern fitness using 11 weighted dimensions and 44 sub-metrics.
Each recommendation traces to a proven framework and includes rationale.

**Announce at start:** "I'm using arch-rx to evaluate [target] against 11 architectural pattern dimensions and 44 sub-metrics."

## Relationship to code-rx

| | code-rx | arch-rx |
|---|---|---|
| **Question** | "How clean is this code?" | "Are the right patterns in place?" |
| **Perspective** | Retrospective (what IS) | Prescriptive (what SHOULD BE) |
| **Measures** | Static code quality | Runtime architecture fitness |
| **Output** | Score + fix list | Score + ADR opportunity map |
| **Frameworks** | ISO 25010, SonarQube, SIG | POSA, EIP, 12-Factor, CNCF, NIST, SLSA |

Run code-rx first to baseline code quality, then arch-rx to identify pattern opportunities.

## Inputs

Accepts one argument: a **layer path**, a **directory**, or `all`.

```
/arch-rx src/core
/arch-rx src/api
/arch-rx all
```

When `all`: evaluate every top-level directory under `src/` and produce both per-layer and aggregate scorecards.

## Stack Detection & Adaptation

Before scoring, detect the project's runtime stack from package.json, go.mod, pom.xml, Cargo.toml,
requirements.txt, *.csproj, or similar. Use the stack adapter reference to map abstract pattern
recommendations to concrete implementations for the detected stack.

Read [references/stack-adapters.md](references/stack-adapters.md) after detecting the stack.

## Process Overview

1. **Run discovery script** — Execute `scripts/discover-architecture.sh [target]` to collect raw evidence
2. **Detect stack** — Identify runtime language/framework from discovery output
3. **Assess each sub-metric** — Compare current patterns against threshold tables
4. **Compute dimension scores** — Weighted average of sub-metrics within each dimension
5. **Compute overall score** — Weighted average of 11 dimension scores
6. **Map to letter grade** — A+ (97-100) through F (0-59)
7. **Generate full output** — Scorecard + ADR map + per-dimension improvement plans + Before/After Mermaid diagrams + Roadmap to A+

## The 11 Dimensions

| # | Dimension | Weight | What It Evaluates | Primary Framework |
|---|-----------|--------|-------------------|-------------------|
| D1 | Communication & Protocol Fitness | 10% | Sync/async balance, protocol selection, API gateway patterns | EIP, gRPC/REST fitness |
| D2 | Async & Event Architecture | 14% | Queue usage, event-driven patterns, CQRS/ES, decoupling | EIP, Reactive Manifesto |
| D3 | Resilience & Fault Tolerance | 10% | Circuit breakers, retries, bulkheads, graceful degradation | POSA, Reactive Manifesto |
| D4 | Scalability & Performance Patterns | 10% | Caching, pooling, batching, parallelism, horizontal readiness | CNCF, Well-Architected |
| D5 | Data Architecture & Flow | 8% | Storage fit, read/write separation, schema evolution, data flow | CQRS, polyglot persistence |
| D6 | Observability & Operational Maturity | 5% | Structured logging, tracing, metrics, health checks, alerting | OpenTelemetry, SRE |
| D7 | 12-Factor Compliance | 7% | All 12 factors: codebase, deps, config, backing services, build/release/run, processes, port binding, concurrency, disposability, dev/prod parity, logs, admin | 12-Factor App |
| D8 | Deployment & Runtime Architecture | 6% | Containerization, CI/CD maturity, release strategy, IaC | CNCF, GitOps |
| D9 | Security Architecture | 10% | Zero trust, secrets management, supply chain, authorization | NIST SP 800-207, SLSA, OWASP |
| D10 | Multi-Tenancy & Isolation | 10% | Tenant isolation, data partitioning, noisy neighbor, tenant lifecycle | AWS SaaS Lens, Azure Multi-Tenant |
| D11 | AI/ML Integration Patterns | 10% | Model serving, RAG/embedding pipelines, AI gateway, MLOps lifecycle | MLOps maturity model, CNCF AI |

Full metric tables and thresholds: read [references/grading-framework.md](references/grading-framework.md).

## Step 1: Automated Discovery

Run the discovery orchestrator to collect raw evidence. It detects the stack, then runs 11 dimension scripts in parallel.

```bash
# All dimensions
bash scripts/discover.sh src

# Specific dimensions only
bash scripts/discover.sh src d02 d03      # Async + Resilience only
bash scripts/discover.sh apps/api d09     # Security only on apps/api/
```

Script structure:
```
scripts/
├── discover.sh              # Orchestrator: stack detection, parallel dispatch
├── lib/common.sh            # Shared helpers: src_list, src_count, has_tool
└── dimensions/
    ├── d01-communication.sh   # M1.1-M1.4 (uses madge for chain depth)
    ├── d02-async-event.sh     # M2.1-M2.4
    ├── d03-resilience.sh      # M3.1-M3.4
    ├── d04-scalability.sh     # M4.1-M4.4
    ├── d05-data.sh            # M5.1-M5.4 (uses madge for data flow)
    ├── d06-observability.sh   # M6.1-M6.4
    ├── d07-12factor.sh        # M7.1-M7.4
    ├── d08-deployment.sh      # M8.1-M8.4 (uses hadolint)
    ├── d09-security.sh        # M9.1-M9.4 (uses syft)
    ├── d10-multitenancy.sh    # M10.1-M10.4
    └── d11-ai-ml.sh           # M11.1-M11.4
```

Optional tools (auto-detected, enhance coverage):
- `madge` — import graph + circular deps (D1, D5)
- `dependency-cruiser` — layer violation detection (deep analysis)
- `hadolint` — Dockerfile quality linting (D8)
- `syft` — SBOM generation for supply chain (D9)

After running the script, supplement its output with manual analysis of:
- Synchronous chain depth (trace request paths through code)
- Protocol fit assessment (compare actual vs optimal per-flow)
- Data consistency requirements per flow
- Tenant context propagation completeness

## Step 2: Dispatch Parallel Scoring Agents

After discovery, dispatch **6 parallel agents** to score the 11 dimensions:

**Agent 1 — D1 + D2 (Communication + Async):**
Receives architecture map for protocols, integrations, sync chains, queue usage, event patterns.
Reads grading-framework.md and stack-adapters.md. Returns scored sub-metrics, dimension scores, and ADR opportunities.

**Agent 2 — D3 + D4 (Resilience + Scalability):**
Receives architecture map for error handling patterns, retry logic, circuit breakers, caching, pooling, parallelism, horizontal scaling indicators.
Reads grading-framework.md and stack-adapters.md. Returns scored sub-metrics, dimension scores, and ADR opportunities.

**Agent 3 — D5 + D6 (Data + Observability):**
Receives architecture map for storage patterns, data flows, logging, tracing, metrics, health checks.
Reads grading-framework.md. Returns scored sub-metrics, dimension scores, and ADR opportunities.

**Agent 4 — D7 + D8 (12-Factor + Deployment):**
Receives architecture map for config management, env handling, containerization, CI/CD, release strategy, all 12 factors.
Reads grading-framework.md. Returns scored sub-metrics, dimension scores, and ADR opportunities.

**Agent 5 — D9 + D10 (Security + Multi-Tenancy):**
Receives security inventory and tenancy inventory for zero trust, secrets, supply chain, authorization, tenant isolation, data partitioning, noisy neighbor protection.
Reads grading-framework.md and stack-adapters.md. Returns scored sub-metrics, dimension scores, and ADR opportunities.

**Agent 6 — D11 (AI/ML Integration):**
Receives AI/ML inventory for model serving, RAG pipelines, AI gateway, MLOps lifecycle.
Reads grading-framework.md and stack-adapters.md. Returns scored sub-metrics, dimension scores, and ADR opportunities.

## Step 3: Compute Final Scores

After all agents return, compute the overall score:

```
Overall = (D1 * 0.10) + (D2 * 0.14) + (D3 * 0.10) + (D4 * 0.10)
        + (D5 * 0.08) + (D6 * 0.05) + (D7 * 0.07) + (D8 * 0.06)
        + (D9 * 0.10) + (D10 * 0.10) + (D11 * 0.10)
```

Map to letter grade using the same scale as code-rx (see grading-framework.md).

## Step 4: Generate Full Output

Read [references/output-templates.md](references/output-templates.md) for mandatory output formats including:
- Per-dimension improvement plans (gap analysis + actionable steps for every D below 97)
- Before/After Mermaid architecture diagrams (color-coded by score)

Scorecard format — ALWAYS use this exact structure:

```markdown
# Architectural Pattern Fitness: [LAYER_NAME]

**Stack: [detected runtime/framework]**
**Overall: [SCORE] ([GRADE])**

| # | Dimension | Weight | Score | Grade | Biggest Opportunity |
|----|-----------|--------|-------|-------|---------------------|
| D1 | Communication & Protocol Fitness | 10% | [X] | [G] | [opportunity summary] |
| D2 | Async & Event Architecture | 14% | [X] | [G] | [opportunity summary] |
| D3 | Resilience & Fault Tolerance | 10% | [X] | [G] | [opportunity summary] |
| D4 | Scalability & Performance Patterns | 10% | [X] | [G] | [opportunity summary] |
| D5 | Data Architecture & Flow | 8% | [X] | [G] | [opportunity summary] |
| D6 | Observability & Operational Maturity | 5% | [X] | [G] | [opportunity summary] |
| D7 | 12-Factor Compliance | 7% | [X] | [G] | [opportunity summary] |
| D8 | Deployment & Runtime Architecture | 6% | [X] | [G] | [opportunity summary] |
| D9 | Security Architecture | 10% | [X] | [G] | [opportunity summary] |
| D10 | Multi-Tenancy & Isolation | 10% | [X] | [G] | [opportunity summary] |
| D11 | AI/ML Integration Patterns | 10% | [X] | [G] | [opportunity summary] |

## Sub-Metric Detail

### D1: Communication & Protocol Fitness ([SCORE])
| Sub-Metric | Weight | Current State | Score | Recommendation |
|------------|--------|---------------|-------|----------------|
| M1.1 Sync Chain Depth | 25% | max=[N] hops | [S] | [if < 100: what to change] |
| M1.2 Protocol Fit | 30% | [N]/[T] optimal | [S] | [if < 100: which protocol for which flow] |
| M1.3 API Gateway Patterns | 25% | [state] | [S] | [if < 100: what to add] |
| M1.4 Contract Evolution | 20% | [state] | [S] | [if < 100: versioning strategy] |

[... repeat for D2-D11 with same table format ...]

## ADR Opportunity Map

### ADR-001: [Title — e.g., "Introduce Message Queue for Eval Processing"]
- **Status**: Proposed
- **Pattern**: [e.g., EIP Competing Consumers + Dead Letter Queue]
- **Framework**: [e.g., Enterprise Integration Patterns, ch. 10]
- **Current**: [what exists now and why it's suboptimal]
- **Proposed**: [specific pattern with components]
- **Stack Implementation**: [concrete library/tool for detected stack — from stack-adapters.md]
- **Impact**: Score +[N] points ([current] -> [projected])
- **Effort**: [S/M/L] — [brief justification]
- **Affected flows**: [list of request paths impacted]

### ADR-002: [next opportunity...]
[... ordered by score impact, descending ...]

## Roadmap to A+

| Phase | Target Grade | Key ADRs | Estimated Effort |
|-------|-------------|----------|-----------------|
| 1 | [current] -> [next] | ADR-001, ADR-002 | [sizing] |
| 2 | [next] -> [next+1] | ADR-003, ADR-004 | [sizing] |
| 3 | [next+1] -> A+ | ADR-005+ | [sizing] |
```

When evaluating `all`, also produce an aggregate:

```markdown
# Aggregate Architectural Pattern Fitness

**Stack: [detected runtime/framework]**
**Overall: [SCORE] ([GRADE])**

| Layer | Flows | Wt | D1 | D2 | D3 | D4 | D5 | D6 | D7 | D8 | D9 | D10 | D11 | Overall | Grade |
|-------|-------|-----|----|----|----|----|----|----|----|----|----|----|-----|---------|-------|
| core/ | [N] | [W]% | .. | .. | .. | .. | .. | .. | .. | .. | .. | .. | .. | [S] | [G] |
| api/  | [N] | [W]% | .. | .. | .. | .. | .. | .. | .. | .. | .. | .. | .. | [S] | [G] |
[... all layers ...]

Aggregate = weighted average by flow count proportion
```

## Output

Save scorecard to: `docs/audits/YYYY-MM-DD-arch-rx-[layer].md`

When `all`: save individual layer scorecards + aggregate to `docs/audits/YYYY-MM-DD-arch-rx-all.md`

## Rules

1. **Every sub-metric gets evidence.** Cite the file, flow, or integration that was evaluated.
2. **Every score traces to a threshold table row.** State which row matched.
3. **Parallel agents for scoring.** Never serialize dimension scoring.
4. **Every ADR cites a framework.** No pattern recommendation without a source (POSA, EIP, 12-Factor, CNCF, NIST, SLSA, Well-Architected, AWS SaaS Lens, MLOps).
5. **ADRs are ordered by score impact.** Highest point gain first.
6. **N/A is allowed** when a metric genuinely does not apply (e.g., D10 for single-user CLI tools, D11 for projects with no AI/ML). Score N/A metrics as 100 with a note.
7. **Round scores to integers.** No decimals in the final scorecard.
8. **Show the math.** Include the weighted computation in the detail section.
9. **"Instead of" is mandatory.** Every ADR must state what currently exists and why the proposed pattern is better for THIS codebase.
10. **Roadmap to A+ is mandatory.** Always include a phased plan showing how to reach 97+.
11. **Stack-specific recommendations.** Every ADR must include a "Stack Implementation" field with concrete libraries/tools for the detected stack, sourced from stack-adapters.md.
12. **Pattern-level abstraction, stack-level prescription.** Threshold tables use abstract pattern names. ADR recommendations use concrete stack implementations.
13. **Per-dimension improvement plans are mandatory.** Every dimension scoring below 97 must have a detailed improvement plan with gap analysis, ordered steps, file paths, acceptance criteria, and effort sizing. See output-templates.md Section 1.
14. **Before/After Mermaid diagrams are mandatory.** Every scorecard must include a color-coded "Before" diagram showing current architecture problems and an "After" diagram showing the A+ target state. See output-templates.md Section 2.
15. **Run discovery script first.** Always execute `scripts/discover.sh` before manual analysis to collect raw evidence systematically. Use dimension-specific runs (`discover.sh src d09`) for focused re-evaluation after changes.

16. **Use LSP when available.** If LSP tools are active, use go-to-definition and find-references for M1.1 sync chain depth tracing and M5.2 data flow ownership analysis. LSP call hierarchy is more accurate than import graph tools for measuring actual call depth.

## Auto-Plan Integration

After generating the scorecard and saving the report to `docs/audits/`:
1. Save a copy of the report to `docs/rx-plans/{this-skill-name}/{date}-report.md`
2. For each dimension scoring below 97, invoke the `rx-plan` skill to create or update the improvement plan at `docs/rx-plans/{this-skill-name}/{dimension}/v{N}-{date}-plan.md`
3. Update `docs/rx-plans/{this-skill-name}/summary.md` with current scores
4. Update `docs/rx-plans/dashboard.md` with overall progress

This happens automatically — the user does not need to run `/rx-plan` separately.
