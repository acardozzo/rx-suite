---
name: clean-rx
description: >
  Codebase garbage collector — finds dead code, unused deps, orphan files, stale configs,
  and tech debt across Python, Next.js, and Supabase projects. Produces a prioritized cleanup
  plan with safe removal steps. Use when the user says "cleanup", "run clean-rx", "find dead code",
  "remove unused", "tech debt audit", "garbage collect", "what can I delete", "lixo", or
  "clean project". Leverages LSP, madge, depcheck, and knip for deep dead code detection.
---

## Prerequisites

Recommended: `knip`, `depcheck`, `madge`, `vulture`, `ruff`

Check all dependencies: `bash scripts/rx-deps.sh` or `bash scripts/rx-deps.sh --install`


# Codebase Cleanup & Dead Code Detection

Evaluate codebase waste using 10 weighted dimensions and 40 sub-metrics with exact,
reproducible thresholds. Every finding traces to a file, line, or config entry.

**Announce at start:** "I'm using the clean-rx skill to scan [target] across 10 dimensions and 40 sub-metrics."

## Inputs

Accepts one argument: a **project path**, a **directory**, or `all`.

```
/clean-rx .
/clean-rx src/
/clean-rx all
```

When `all`: scan the entire project root, detecting all stacks present.

## Process Overview

1. **Detect stacks** — Identify which of Python, Next.js/TypeScript, Supabase are present
2. **Detect tools** — Auto-detect knip, depcheck, madge, vulture, ruff availability
3. **Run dimension scanners** — 10 parallel dimension scripts collect raw findings
4. **Score each sub-metric** — Map raw counts to 0-100 scores using threshold tables
5. **Compute dimension scores** — Weighted average of sub-metrics within each dimension
6. **Compute overall score** — Weighted average of 10 dimension scores (N/A stacks score 100)
7. **Map to letter grade** — A+ (97-100) through F (0-59)
8. **Generate Safe Deletion List** — Tiered output with verification sources

## The 10 Dimensions

| # | Dimension | Weight | What It Measures |
|---|-----------|--------|------------------|
| D1 | Dead Code & Unreachable | 15% | Unused exports, dead functions, unreachable code, commented-out code |
| D2 | Unused Dependencies | 12% | Phantom deps, dev/prod misplacement, duplicates, deprecated pkgs |
| D3 | Orphan Files & Assets | 10% | Unreferenced source files, orphan tests, unused assets, stale artifacts |
| D4 | Stale Configuration | 10% | Unused env vars, stale configs, dead scripts, dead CI steps |
| D5 | Type & Lint Debt | 10% | `any` types, disabled lint rules, missing annotations, TODO/FIXME |
| D6 | Import Hygiene | 10% | Circular imports, unused imports, wildcard imports, deep relative paths |
| D7 | Supabase Waste | 8% | Unused tables, orphan migrations, dead RLS, unused storage buckets |
| D8 | Next.js / Frontend Waste | 8% | Unused pages/routes, dead components, dead CSS, unused API routes |
| D9 | Python Waste | 8% | Unused Python imports, dead functions, unused vars, empty __init__.py |
| D10 | Git & Repository Hygiene | 9% | Large files, secrets in history, .gitignore gaps, stale branches |

**Stack-conditional dimensions:** D7 (Supabase), D8 (Next.js), D9 (Python) score as N/A (100) if the respective stack is not detected. Their weight redistributes proportionally.

Full metric tables and thresholds: read [references/grading-framework.md](references/grading-framework.md).
Cleanup output format: read [references/output-templates.md](references/output-templates.md).
Stack-specific guides: read [references/stack-guides.md](references/stack-guides.md).

## Step 1: Detect Stacks & Tools

```bash
# Run the discovery orchestrator
bash scripts/discover.sh /path/to/project
```

The orchestrator auto-detects:
- **Stacks:** Python (pyproject.toml, requirements.txt, .py), Next.js (next.config.*, package.json with next), Supabase (supabase/ dir, migrations)
- **Tools:** knip, depcheck, madge, vulture, ruff, pip-autoremove (enhances detection when present)

## Step 2: Collect Raw Findings

Run all 10 dimension scripts. Each produces structured findings with file paths and line numbers.

### D1: Dead Code & Unreachable (15%)
- M1.1: Unused exports — knip or grep exported symbols, check if imported elsewhere
- M1.2: Dead functions — defined but never called (grep function name across codebase)
- M1.3: Unreachable code — code after return/throw/sys.exit
- M1.4: Commented-out code — `// function`, `// const`, `# def`, `# class` patterns

### D2: Unused Dependencies (12%)
- M2.1: Phantom deps — depcheck (JS) or grep package imports vs installed (Python)
- M2.2: Dev/prod misplacement — devDependencies imported in src/
- M2.3: Duplicate deps — same-purpose libs (moment+dayjs, lodash+ramda)
- M2.4: Deprecated packages — npm deprecation warnings

### D3: Orphan Files & Assets (10%)
- M3.1: Unreferenced source files — madge --orphans or import graph analysis
- M3.2: Orphan test files — test files whose source module no longer exists
- M3.3: Unused assets — images/fonts in public/ not referenced in code/CSS
- M3.4: Stale generated files — build artifacts that should be gitignored

### D4: Stale Configuration (10%)
- M4.1: Unused env vars — defined in .env but never read in code
- M4.2: Stale config files — configs for tools not in dependencies
- M4.3: Unused scripts — package.json/pyproject.toml scripts never called
- M4.4: Dead CI steps — CI jobs referencing deleted files/commands

### D5: Type & Lint Debt (10%)
- M5.1: `any` type count — `as any`, `: any`, `@ts-ignore`, `@ts-expect-error`
- M5.2: Disabled lint rules — eslint-disable, noqa, type: ignore
- M5.3: Missing type annotations — untyped functions
- M5.4: TODO/FIXME/HACK comment count

### D6: Import Hygiene (10%)
- M6.1: Circular imports — madge --circular
- M6.2: Unused imports — eslint/ruff F401
- M6.3: Wildcard imports — `import *` patterns
- M6.4: Deep relative imports — `../` depth > 3

### D7: Supabase Waste (8%) — if Supabase detected
- M7.1: Unused tables — tables in migrations not queried in client code
- M7.2: Orphan migrations — create then drop same object
- M7.3: Dead RLS policies — policies on dropped or non-existent tables
- M7.4: Unused storage buckets — bucket names not referenced in client

### D8: Next.js / Frontend Waste (8%) — if Next.js detected
- M8.1: Unused pages/routes — routes with no Link pointing to them
- M8.2: Unused components — components never rendered
- M8.3: Dead CSS/Tailwind classes — defined but never used
- M8.4: Unused API routes — API routes never called from client

### D9: Python Waste (8%) — if Python detected
- M9.1: Unused Python imports — ruff F401 or grep
- M9.2: Dead Python functions/classes — defined, never called
- M9.3: Unused Python variables — assigned but never read
- M9.4: Empty __init__.py — files with no content or purpose

### D10: Git & Repository Hygiene (9%)
- M10.1: Large files — files > 1MB in git tracking
- M10.2: Secrets patterns — API key patterns in tracked files
- M10.3: .gitignore gaps — common entries missing
- M10.4: Stale branches — merged/abandoned branches

## Step 3: Dispatch Parallel Scoring Agents

After collecting raw findings, dispatch **5 parallel agents** to score the 10 dimensions:

**Agent 1 — D1 + D2 (Dead Code + Unused Deps):**
Receives finding counts for unused exports, dead functions, unreachable code, phantom deps, duplicates. Reads grading framework. Returns scored sub-metrics.

**Agent 2 — D3 + D4 (Orphan Files + Stale Config):**
Receives orphan file list, unused env vars, stale configs, dead CI steps. Reads grading framework. Returns scored sub-metrics.

**Agent 3 — D5 + D6 (Type Debt + Import Hygiene):**
Receives `any` counts, disabled rules, circular imports, unused imports. Reads grading framework. Returns scored sub-metrics.

**Agent 4 — D7 + D8 + D9 (Stack-Specific Waste):**
Receives Supabase/Next.js/Python waste findings. Marks N/A for absent stacks. Reads grading framework. Returns scored sub-metrics.

**Agent 5 — D10 (Git Hygiene):**
Receives large file list, secret patterns, gitignore gaps, stale branches. Reads grading framework. Returns scored sub-metrics.

## Step 4: Compute Final Scores

```
Overall = (D1 * 0.15) + (D2 * 0.12) + (D3 * 0.10) + (D4 * 0.10)
        + (D5 * 0.10) + (D6 * 0.10) + (D7 * 0.08) + (D8 * 0.08)
        + (D9 * 0.08) + (D10 * 0.09)
```

When a stack-specific dimension is N/A, redistribute its weight proportionally among active dimensions.

Map to letter grade:

| Grade | Score Range |
|-------|------------|
| A+ | 97-100 |
| A | 93-96 |
| A- | 90-92 |
| B+ | 87-89 |
| B | 83-86 |
| B- | 80-82 |
| C+ | 77-79 |
| C | 73-76 |
| C- | 70-72 |
| D+ | 67-69 |
| D | 63-66 |
| D- | 60-62 |
| F | 0-59 |

## Step 5: Generate Safe Deletion List

The primary output is a **tiered safe deletion list** — see [references/output-templates.md](references/output-templates.md) for format.

- **Tier 1: Zero-Risk** — Verified by 2+ tools (e.g., knip + grep), safe to auto-delete
- **Tier 2: Likely Safe** — Verified by 1 tool, review before deleting
- **Tier 3: Needs Investigation** — Heuristic match, may have dynamic usage

## Output

Save report to: `docs/audits/YYYY-MM-DD-clean-rx.md`

## Tools Integration

The discovery scripts auto-detect and use these tools when available:

| Tool | What it finds | Stack | Install |
|---|---|---|---|
| `knip` | Unused exports, files, deps, types | Next.js/TS | `npm i -g knip` |
| `depcheck` | Unused npm dependencies | Next.js/TS | `npm i -g depcheck` |
| `madge` | Circular imports, orphan files | Next.js/TS | `npm i -g madge` |
| `vulture` | Dead Python code | Python | `pip install vulture` |
| `pip-autoremove` | Unused Python packages | Python | `pip install pip-autoremove` |
| `ruff` | Unused imports, lint issues | Python | `pip install ruff` |
| LSP (pyright/vtsls) | Type errors, unused symbols | Both | Already installed |

## Rules

1. **Every finding has a file path.** No vague "some files have issues". Cite exact paths and lines.
2. **Every score traces to a threshold table row.** State which row matched.
3. **Parallel agents for scoring.** Never serialize dimension scoring.
4. **N/A for absent stacks.** Score D7/D8/D9 as 100 when their stack is absent.
5. **Round scores to integers.** No decimals in the final scorecard.
6. **Tier 1 deletions must be verified by 2+ sources.** Never auto-delete based on grep alone.
7. **Show the math.** Include the weighted computation in the detail section.
8. **Use LSP when available.** pyright for Python unused symbols, vtsls for TypeScript dead code. LSP provides ground-truth unused detection that grep cannot match.

## Auto-Plan Integration

After generating the report and saving to `docs/audits/`:
1. Save a copy of the report to `docs/rx-plans/clean-rx/{date}-report.md`
2. For each dimension scoring below 97, invoke the `rx-plan` skill to create or update the improvement plan at `docs/rx-plans/clean-rx/{dimension}/v{N}-{date}-plan.md`
3. Update `docs/rx-plans/clean-rx/summary.md` with current scores
4. Update `docs/rx-plans/dashboard.md` with overall progress

This happens automatically — the user does not need to run `/rx-plan` separately.
