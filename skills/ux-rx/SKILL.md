---
name: ux-rx
description: >
  Prescriptive UX/UI evaluation producing scored opportunity maps for Next.js + shadcn/ui projects.
  Evaluates user experience against Nielsen Heuristics, WCAG 2.2, Core Web Vitals, Laws of UX, and
  Atomic Design. Use when: auditing UX quality, evaluating accessibility, reviewing component usage,
  identifying missing shadcn components, improving form UX, or when the user says "ux audit",
  "run ux-rx", "evaluate UX", "accessibility check", "improve user experience", "shadcn review",
  "how to reach A+ UX", or "UX opportunities". Measures 11 dimensions (44 sub-metrics).
  Fixed stack: Next.js App Router + shadcn/ui + Tailwind CSS. Leverages shadcn registry to
  recommend ready-to-use components. Outputs per-page scorecards with before/after Mermaid diagrams.
---

# UX/UI Pattern Fitness Grading

Evaluate UX/UI pattern fitness using 11 weighted dimensions and 44 sub-metrics.
Fixed stack: **Next.js App Router + shadcn/ui + Tailwind CSS**.
Each recommendation includes ready-to-use shadcn registry components.

**Announce at start:** "I'm using ux-rx to evaluate [target] against 11 UX dimensions and 44 sub-metrics."

## Relationship to arch-rx

| | arch-rx | ux-rx |
|---|---|---|
| **Question** | "Are the right backend patterns in place?" | "Is the user experience world-class?" |
| **Perspective** | Runtime architecture | User-facing experience |
| **Stack** | Any (6 stacks) | Fixed: Next.js + shadcn/ui |
| **Frameworks** | POSA, EIP, 12-Factor | Nielsen, WCAG, Core Web Vitals, Laws of UX |
| **Output** | ADR opportunity map | UX opportunity map + shadcn registry components |

## Inputs

Accepts one argument: a **path**, a **route group**, or `all`.

```
/ux-rx app
/ux-rx app/(dashboard)
/ux-rx components
/ux-rx all
```

## Process Overview

1. **Run discovery scripts** — Execute `scripts/discover.sh [target]` to collect raw evidence
2. **Check shadcn registry** — Compare installed vs available components, identify gaps
3. **Assess each sub-metric** — Compare current patterns against threshold tables
4. **Compute dimension scores** — Weighted average of sub-metrics within each dimension
5. **Compute overall score** — Weighted average of 11 dimension scores
6. **Map to letter grade** — A+ (97-100) through F (0-59)
7. **Generate full output** — Scorecard + UX opportunity map + improvement plans + Before/After Mermaid diagrams

Read [references/grading-framework.md](references/grading-framework.md) for all threshold tables.
Read [references/shadcn-registry.md](references/shadcn-registry.md) for component recommendations.
Read [references/output-templates.md](references/output-templates.md) for mandatory output formats.

## The 11 Dimensions

| # | Dimension | Weight | What It Evaluates | Primary Framework |
|---|-----------|--------|-------------------|-------------------|
| D1 | Accessibility & Inclusivity | 12% | WCAG 2.2 AA, ARIA, keyboard nav, focus management, screen reader, contrast | WCAG 2.2, WAI-ARIA 1.2 |
| D2 | Performance & Web Vitals | 12% | LCP, INP, CLS, TTFB, bundle size, code splitting, image optimization | Core Web Vitals, Lighthouse |
| D3 | Component & Design System | 10% | shadcn adoption rate, registry utilization, composition patterns, design tokens | Atomic Design, shadcn best practices |
| D4 | Responsive & Adaptive | 10% | Mobile-first, breakpoints, touch targets, fluid typography, container queries | Mobile-First (Luke W.), WCAG 2.5 |
| D5 | Interaction & Motion | 10% | Transitions, micro-interactions, loading states, skeletons, optimistic UI | Laws of UX, Material Motion |
| D6 | Navigation & Wayfinding | 8% | Route structure, breadcrumbs, search, deep linking, URL design | Nielsen #7 (Flexibility), IA best practices |
| D7 | Form & Input UX | 10% | Validation, error messages, progressive disclosure, autofill, multi-step | Nielsen #9 (Error Recovery), Baymard |
| D8 | Error & Edge States | 8% | Empty states, error boundaries, offline, 404/500, retry UX, loading fallbacks | Nielsen #9, Defensive Design |
| D9 | Visual Consistency & Polish | 8% | Spacing system, typography scale, color palette, dark mode, animation coherence | Gestalt, Laws of UX |
| D10 | Internationalization | 5% | i18n readiness, RTL support, locale-aware formatting, content externalization | W3C i18n, ICU MessageFormat |
| D11 | Data Display & Search | 7% | Tables, pagination, filtering, search UX, data visualization, sorting | NNGroup, Baymard search UX |

## Step 1: Automated Discovery

Run the discovery orchestrator:

```bash
# All dimensions
bash scripts/discover.sh app

# Specific dimensions
bash scripts/discover.sh app d01 d02    # Accessibility + Performance only
bash scripts/discover.sh components d03  # Component system only
```

Script structure:
```
scripts/
├── discover.sh                    # Orchestrator: parallel dispatch
├── lib/common.sh                  # Shared helpers
└── dimensions/
    ├── d01-accessibility.sh        # WCAG, ARIA, keyboard, contrast
    ├── d02-performance.sh          # Web Vitals, bundle, images, fonts
    ├── d03-components.sh           # shadcn adoption, registry gaps
    ├── d04-responsive.sh           # Breakpoints, touch, fluid type
    ├── d05-interaction.sh          # Motion, loading, skeletons, optimistic
    ├── d06-navigation.sh           # Routes, breadcrumbs, search, URLs
    ├── d07-forms.sh                # Validation, errors, autofill
    ├── d08-edge-states.sh          # Empty, error, offline, 404
    ├── d09-visual.sh               # Spacing, typography, color, dark mode
    ├── d10-i18n.sh                 # i18n, RTL, locale formatting
    └── d11-data-display.sh         # Tables, pagination, search, filters
```

Optional tools (auto-detected):
- `lighthouse` — Core Web Vitals + accessibility audit (D1, D2)
- `pa11y` — Accessibility testing (D1)
- `next-bundle-analyzer` — Bundle analysis (D2)

## Step 2: Dispatch Parallel Scoring Agents

After discovery, dispatch **6 parallel agents**:

**Agent 1 — D1 + D2 (Accessibility + Performance)**
**Agent 2 — D3 + D4 (Components + Responsive)**
**Agent 3 — D5 + D6 (Interaction + Navigation)**
**Agent 4 — D7 + D8 (Forms + Edge States)**
**Agent 5 — D9 + D10 (Visual + i18n)**
**Agent 6 — D11 (Data Display)**

Each agent reads grading-framework.md and shadcn-registry.md.

## Step 3: Compute Final Scores

```
Overall = (D1 * 0.12) + (D2 * 0.12) + (D3 * 0.10) + (D4 * 0.10)
        + (D5 * 0.10) + (D6 * 0.08) + (D7 * 0.10) + (D8 * 0.08)
        + (D9 * 0.08) + (D10 * 0.05) + (D11 * 0.07)
```

## Step 4: Generate Full Output

Read [references/output-templates.md](references/output-templates.md) for mandatory formats.

Output structure:
```
1. Header (target, overall score/grade)
2. Dimension Summary Table (11 rows)
3. Sub-Metric Detail (all 44 sub-metrics)
4. shadcn Registry Opportunity Map (components to add/replace)
5. UX Opportunity Map (ordered by score impact)
6. Per-Dimension Improvement Plans
7. Before/After Mermaid Diagrams (user flow, not infra)
8. Roadmap to A+
```

### Scorecard Format

```markdown
# UX Pattern Fitness: [TARGET]

**Stack: Next.js App Router + shadcn/ui + Tailwind CSS**
**Overall: [SCORE] ([GRADE])**

| # | Dimension | Weight | Score | Grade | Biggest Opportunity |
|----|-----------|--------|-------|-------|---------------------|
| D1 | Accessibility & Inclusivity | 12% | [X] | [G] | [opportunity] |
| D2 | Performance & Web Vitals | 12% | [X] | [G] | [opportunity] |
| D3 | Component & Design System | 10% | [X] | [G] | [opportunity] |
| D4 | Responsive & Adaptive | 10% | [X] | [G] | [opportunity] |
| D5 | Interaction & Motion | 10% | [X] | [G] | [opportunity] |
| D6 | Navigation & Wayfinding | 8% | [X] | [G] | [opportunity] |
| D7 | Form & Input UX | 10% | [X] | [G] | [opportunity] |
| D8 | Error & Edge States | 8% | [X] | [G] | [opportunity] |
| D9 | Visual Consistency & Polish | 8% | [X] | [G] | [opportunity] |
| D10 | Internationalization | 5% | [X] | [G] | [opportunity] |
| D11 | Data Display & Search | 7% | [X] | [G] | [opportunity] |

## shadcn Registry Opportunities

| Component | Status | Impact | Install Command |
|-----------|--------|--------|-----------------|
| [name] | NOT INSTALLED | D[N] +[X] pts | `npx shadcn@latest add [name]` |
| [name] | INSTALLED, UNDERUSED | D[N] +[X] pts | Use in [file paths] |
```

### UX Opportunity Format

```markdown
### UX-001: [Title — e.g., "Add skeleton loaders to dashboard cards"]
- **Heuristic**: [e.g., Nielsen #1 Visibility of System Status]
- **Framework**: [e.g., Laws of UX — Doherty Threshold]
- **Current**: [what users experience now]
- **Proposed**: [specific UX improvement]
- **shadcn Component**: [registry component to use, with install command]
- **Impact**: Score +[N] points on D[X]
- **Effort**: [S/M/L]
- **Affected routes**: [list of pages impacted]
```

## Rules

1. **Every sub-metric gets evidence.** Cite the file, route, or component evaluated.
2. **Every score traces to a threshold table row.** State which row matched.
3. **Parallel agents for scoring.** Never serialize dimension scoring.
4. **Every UX recommendation cites a heuristic.** Nielsen, WCAG, Laws of UX, or Core Web Vitals.
5. **shadcn registry first.** Always check if a registry component solves the problem before recommending custom code.
6. **N/A is allowed** when a metric doesn't apply (e.g., D10 i18n for single-language apps). Score as 100.
7. **Round scores to integers.**
8. **Show the math.**
9. **"Instead of" is mandatory.** Every UX opportunity must state current UX and why the proposed pattern is better.
10. **Roadmap to A+ is mandatory.**
11. **Per-dimension improvement plans are mandatory.** Every D below 97 gets a plan.
12. **Before/After Mermaid diagrams are mandatory.** Show user flow transformation, not infrastructure.
13. **Run discovery script first.** Execute `scripts/discover.sh` before manual analysis.
14. **Include install commands.** Every shadcn recommendation includes the exact `npx shadcn@latest add` command.
