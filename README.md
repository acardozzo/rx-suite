# rx-suite

> 10 prescriptive evaluation skills for [Claude Code](https://claude.com/claude-code) — a complete diagnostic pipeline to reach A+ World-Class projects.

## What is rx-suite?

**rx** = prescription. Each skill diagnoses a specific dimension of your project and prescribes exactly what to improve, how, and in what order — backed by proven frameworks (POSA, EIP, OWASP, Nielsen, SRE, etc).

## The 10 Skills

| Skill | Question | Dimensions | Metrics | Trigger |
|---|---|---|---|---|
| **`project-rx`** | What's missing from this project? | 10D | 40 | `/project-rx` |
| **`project-agno-rx`** | Are Agno AI patterns used correctly? | 10D | 40 | `/project-agno-rx` |
| **`code-rx`** | Is the code clean? | 8D | 29 | `/code-rx` |
| **`arch-rx`** | Are the right architecture patterns in place? | 11D | 44 | `/arch-rx` |
| **`ux-rx`** | Is the UX world-class? | 11D | 44 | `/ux-rx` |
| **`api-rx`** | Is the API a joy to consume? | 8D | 32 | `/api-rx` |
| **`test-rx`** | Are we testing the right things? | 8D | 32 | `/test-rx` |
| **`sec-rx`** | Can this be breached? | 8D | 32 | `/sec-rx` |
| **`ops-rx`** | Can we operate this at scale? | 8D | 32 | `/ops-rx` |
| **`doc-rx`** | Can someone new understand this? | 8D | 32 | `/doc-rx` |
| | | **90D** | **357** | |

## Pipeline

```
/project-rx    →  First: what components are missing?
    ↓
/code-rx       →  Grade code quality
/arch-rx       →  Prescribe architecture patterns
/ux-rx         →  Prescribe UX improvements (Next.js + shadcn)
/api-rx        →  Prescribe API design improvements
/test-rx       →  Prescribe testing strategy
/sec-rx        →  Scan for vulnerabilities
/ops-rx        →  Evaluate production readiness
/doc-rx        →  Evaluate documentation quality
    ↓
/project-agno-rx  →  Specialist: Agno AI agent best practices
```

## Each Skill Produces

- **Scored scorecard** — Letter grade (A+ through F) with dimension breakdown
- **Opportunity map** — Prioritized recommendations with framework citations
- **Per-dimension improvement plans** — Gap analysis + actionable steps
- **Before/After Mermaid diagrams** — Visual transformation
- **Roadmap to A+** — Phased plan to reach world-class

## Framework Sources

| Skill | Frameworks |
|---|---|
| code-rx | ISO 25010, SonarQube, SQALE, SIG, CodeClimate |
| arch-rx | POSA, EIP, 12-Factor, CNCF, NIST SP 800-207, SLSA, Well-Architected |
| ux-rx | Nielsen Heuristics, WCAG 2.2, Core Web Vitals, Laws of UX, Atomic Design |
| api-rx | Richardson Maturity, JSON:API, Google AIP, Stripe model, OpenAPI 3.1 |
| test-rx | Test Pyramid (Fowler), Mutation Testing, xUnit Patterns, DORA |
| sec-rx | OWASP Top 10, OWASP ASVS, CWE/SANS Top 25, NIST CSF |
| ops-rx | Google SRE, DORA, FinOps, AWS Well-Architected |
| doc-rx | Divio System, Write the Docs, GitHub Open Source Guides |
| project-rx | All of the above + DDD, Clean Architecture |
| project-agno-rx | Agno AGENTS.md, Agno source code patterns |

## Installation

### As individual skills (current)

Skills are installed at `~/.claude/skills/`. Each folder contains a `SKILL.md` and optional `scripts/` + `references/`.

### Optional tools (enhance discovery scripts)

```bash
npm i -g madge dependency-cruiser
brew install hadolint syft
```

## License

MIT
