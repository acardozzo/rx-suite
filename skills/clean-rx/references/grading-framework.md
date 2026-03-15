# Clean-RX Grading Framework — Full Metric Reference

> Thresholds for 10 dimensions and 40 sub-metrics covering dead code, unused dependencies,
> orphan files, stale configs, type debt, import hygiene, and stack-specific waste.

---

## Grading Scale

| Grade | Score | Interpretation |
|-------|-------|----------------|
| A+ | 97-100 | Spotless — no detectable waste, exemplary hygiene |
| A | 93-96 | Excellent — minimal waste, well-maintained |
| A- | 90-92 | Very Good — minor cleanup items only |
| B+ | 87-89 | Good — some waste accumulated, manageable |
| B | 83-86 | Above Average — noticeable tech debt |
| B- | 80-82 | Adequate — cleanup sprint recommended |
| C+ | 77-79 | Below Average — significant waste accumulation |
| C | 73-76 | Mediocre — cleanup blocking velocity |
| C- | 70-72 | Poor — substantial dead code and waste |
| D+ | 67-69 | Bad — waste actively impedes development |
| D | 63-66 | Very Bad — major cleanup overhaul needed |
| D- | 60-62 | Critical — barely navigable codebase |
| F | 0-59 | Failing — waste exceeds functional code ratio |

---

## D1: Dead Code & Unreachable (Weight: 15%)

### M1.1: Unused Exports (25% of D1)

Exported functions, classes, types, or constants never imported anywhere in the codebase.

| Score | Criteria |
|-------|----------|
| 100 | 0 unused exports (verified by knip or LSP) |
| 90 | 1-3 unused exports |
| 80 | 4-10 unused exports |
| 70 | 11-20 unused exports |
| 60 | 21-40 unused exports |
| 40 | 41-80 unused exports |
| 20 | 80+ unused exports |

### M1.2: Dead Functions (25% of D1)

Functions/methods defined but never called anywhere (excluding entry points, event handlers, exports).

| Score | Criteria |
|-------|----------|
| 100 | 0 dead functions |
| 90 | 1-3 dead functions |
| 80 | 4-8 dead functions |
| 70 | 9-15 dead functions |
| 60 | 16-30 dead functions |
| 40 | 31-60 dead functions |
| 20 | 60+ dead functions |

### M1.3: Unreachable Code (25% of D1)

Code after return/throw/sys.exit, impossible conditions, dead branches.

| Score | Criteria |
|-------|----------|
| 100 | 0 unreachable code blocks |
| 90 | 1-2 unreachable blocks |
| 80 | 3-5 unreachable blocks |
| 70 | 6-10 unreachable blocks |
| 60 | 11-20 unreachable blocks |
| 40 | 20+ unreachable blocks |

### M1.4: Commented-Out Code (25% of D1)

Lines of commented-out code (not documentation comments). Patterns: `// function`, `// const`, `// let`, `# def`, `# class`, `/* ... */` blocks containing code.

| Score | Criteria |
|-------|----------|
| 100 | 0 commented-out code blocks |
| 90 | 1-5 blocks (< 20 lines total) |
| 80 | 6-10 blocks (< 50 lines total) |
| 70 | 11-20 blocks (< 100 lines total) |
| 60 | 21-40 blocks (< 200 lines total) |
| 40 | 41-80 blocks |
| 20 | 80+ blocks of commented-out code |

**D1 formula:** `D1 = (M1.1 * 0.25) + (M1.2 * 0.25) + (M1.3 * 0.25) + (M1.4 * 0.25)`

---

## D2: Unused Dependencies (Weight: 12%)

### M2.1: Phantom Dependencies (30% of D2)

Packages listed in package.json/pyproject.toml/requirements.txt but never imported in source code.

| Score | Criteria |
|-------|----------|
| 100 | 0 unused dependencies |
| 90 | 1-2 unused deps |
| 80 | 3-5 unused deps |
| 70 | 6-10 unused deps |
| 60 | 11-15 unused deps |
| 40 | 16-25 unused deps |
| 20 | 25+ unused deps |

### M2.2: Dev/Prod Misplacement (25% of D2)

devDependencies imported in production source files, or production deps only used in tests.

| Score | Criteria |
|-------|----------|
| 100 | 0 misplaced dependencies |
| 90 | 1-2 misplaced |
| 80 | 3-5 misplaced |
| 70 | 6-8 misplaced |
| 60 | 9-12 misplaced |
| 40 | 12+ misplaced |

### M2.3: Duplicate Dependencies (25% of D2)

Multiple libraries serving the same purpose (e.g., moment + dayjs, lodash + underscore, axios + got + node-fetch).

| Score | Criteria |
|-------|----------|
| 100 | 0 duplicate dependency pairs |
| 90 | 1 duplicate pair |
| 80 | 2 duplicate pairs |
| 70 | 3 duplicate pairs |
| 60 | 4-5 duplicate pairs |
| 40 | 6+ duplicate pairs |

### M2.4: Deprecated/Outdated Packages (20% of D2)

Packages with npm deprecation warnings or 2+ major versions behind.

| Score | Criteria |
|-------|----------|
| 100 | 0 deprecated, all within 1 major version |
| 90 | 0 deprecated, 1-3 outdated (2+ major behind) |
| 80 | 0 deprecated, 4-8 outdated |
| 70 | 1-2 deprecated packages |
| 60 | 3-5 deprecated packages |
| 40 | 6-10 deprecated packages |
| 20 | 10+ deprecated packages |

**D2 formula:** `D2 = (M2.1 * 0.30) + (M2.2 * 0.25) + (M2.3 * 0.25) + (M2.4 * 0.20)`

---

## D3: Orphan Files & Assets (Weight: 10%)

### M3.1: Unreferenced Source Files (30% of D3)

Source files (.ts/.tsx/.py) not imported by any other file in the project.

| Score | Criteria |
|-------|----------|
| 100 | 0 orphan source files |
| 90 | 1-3 orphan files |
| 80 | 4-8 orphan files |
| 70 | 9-15 orphan files |
| 60 | 16-25 orphan files |
| 40 | 26-50 orphan files |
| 20 | 50+ orphan files |

### M3.2: Orphan Test Files (25% of D3)

Test files whose corresponding source module has been deleted or renamed.

| Score | Criteria |
|-------|----------|
| 100 | 0 orphan test files |
| 90 | 1-2 orphan test files |
| 80 | 3-5 orphan test files |
| 70 | 6-10 orphan test files |
| 60 | 11-15 orphan test files |
| 40 | 15+ orphan test files |

### M3.3: Unused Assets (25% of D3)

Images, fonts, icons in public/static directories not referenced in source code or CSS.

| Score | Criteria |
|-------|----------|
| 100 | 0 unused assets |
| 90 | 1-3 unused assets (< 500KB total) |
| 80 | 4-8 unused assets (< 2MB total) |
| 70 | 9-15 unused assets (< 5MB total) |
| 60 | 16-25 unused assets |
| 40 | 25+ unused assets or > 10MB wasted |

### M3.4: Stale Generated Files (20% of D3)

Build artifacts, cached files, generated outputs that are tracked in git but should be gitignored.

| Score | Criteria |
|-------|----------|
| 100 | 0 tracked generated files |
| 90 | 1-3 tracked generated files |
| 80 | 4-8 tracked generated files |
| 70 | 9-15 tracked generated files |
| 60 | 16-25 tracked generated files |
| 40 | 25+ tracked generated files |

**D3 formula:** `D3 = (M3.1 * 0.30) + (M3.2 * 0.25) + (M3.3 * 0.25) + (M3.4 * 0.20)`

---

## D4: Stale Configuration (Weight: 10%)

### M4.1: Unused Environment Variables (30% of D4)

Variables defined in .env/.env.example but never referenced in source code via process.env or os.getenv.

| Score | Criteria |
|-------|----------|
| 100 | 0 unused env vars |
| 90 | 1-2 unused env vars |
| 80 | 3-5 unused env vars |
| 70 | 6-10 unused env vars |
| 60 | 11-15 unused env vars |
| 40 | 15+ unused env vars |

### M4.2: Stale Config Files (25% of D4)

Config files for tools that are no longer installed or used (e.g., .babelrc when using SWC, .eslintrc for removed eslint).

| Score | Criteria |
|-------|----------|
| 100 | 0 stale config files |
| 90 | 1 stale config file |
| 80 | 2-3 stale config files |
| 70 | 4-5 stale config files |
| 60 | 6-8 stale config files |
| 40 | 8+ stale config files |

### M4.3: Unused Scripts (25% of D4)

Scripts defined in package.json or pyproject.toml [tool.scripts] that are never run in CI, docs, or other scripts.

| Score | Criteria |
|-------|----------|
| 100 | 0 unused scripts |
| 90 | 1-2 unused scripts |
| 80 | 3-5 unused scripts |
| 70 | 6-8 unused scripts |
| 60 | 9-12 unused scripts |
| 40 | 12+ unused scripts |

### M4.4: Dead CI/CD Steps (20% of D4)

CI/CD jobs or steps that reference deleted files, non-existent scripts, or removed commands.

| Score | Criteria |
|-------|----------|
| 100 | 0 dead CI steps |
| 90 | 1 dead CI step |
| 80 | 2-3 dead CI steps |
| 70 | 4-5 dead CI steps |
| 60 | 6-8 dead CI steps |
| 40 | 8+ dead CI steps |

**D4 formula:** `D4 = (M4.1 * 0.30) + (M4.2 * 0.25) + (M4.3 * 0.25) + (M4.4 * 0.20)`

---

## D5: Type & Lint Debt (Weight: 10%)

### M5.1: `any` Type Usage (30% of D5)

Count of `as any`, `: any`, `@ts-ignore`, `@ts-expect-error` in TypeScript files. For Python: `Any` type usage.

| Score | Criteria |
|-------|----------|
| 100 | 0 `any` usages |
| 90 | 1-5 usages |
| 80 | 6-15 usages |
| 70 | 16-30 usages |
| 60 | 31-50 usages |
| 40 | 51-100 usages |
| 20 | 100+ usages |

### M5.2: Disabled Lint Rules (25% of D5)

Count of eslint-disable, eslint-disable-next-line, noqa, type: ignore, pylint: disable.

| Score | Criteria |
|-------|----------|
| 100 | 0 disabled rules |
| 90 | 1-5 disabled rules |
| 80 | 6-15 disabled rules |
| 70 | 16-30 disabled rules |
| 60 | 31-50 disabled rules |
| 40 | 51-100 disabled rules |
| 20 | 100+ disabled rules |

### M5.3: Missing Type Annotations (25% of D5)

Functions without return type annotations (TS implicit any, Python untyped).

| Score | Criteria |
|-------|----------|
| 100 | 0 untyped functions (or strict mode enforces) |
| 90 | 1-5 untyped public functions |
| 80 | 6-15 untyped functions |
| 70 | 16-30 untyped functions |
| 60 | 31-50 untyped functions |
| 40 | 50+ untyped functions |

### M5.4: TODO/FIXME/HACK Comments (20% of D5)

Tech debt markers: TODO, FIXME, HACK, XXX, TEMP, WORKAROUND.

| Score | Criteria |
|-------|----------|
| 100 | 0 tech debt markers |
| 90 | 1-5 markers |
| 80 | 6-15 markers |
| 70 | 16-30 markers |
| 60 | 31-50 markers |
| 40 | 51-100 markers |
| 20 | 100+ markers |

**D5 formula:** `D5 = (M5.1 * 0.30) + (M5.2 * 0.25) + (M5.3 * 0.25) + (M5.4 * 0.20)`

---

## D6: Import Hygiene (Weight: 10%)

### M6.1: Circular Imports (30% of D6)

Dependency cycles detected by madge or manual import graph analysis.

| Score | Criteria |
|-------|----------|
| 100 | 0 circular import chains |
| 80 | 1 circular chain |
| 60 | 2-3 circular chains |
| 40 | 4-6 circular chains |
| 20 | 7+ circular chains |

### M6.2: Unused Imports (30% of D6)

Import statements where the imported symbol is never used in the file.

| Score | Criteria |
|-------|----------|
| 100 | 0 unused imports |
| 90 | 1-5 unused imports |
| 80 | 6-15 unused imports |
| 70 | 16-30 unused imports |
| 60 | 31-50 unused imports |
| 40 | 51-100 unused imports |
| 20 | 100+ unused imports |

### M6.3: Wildcard Imports (20% of D6)

`import *` patterns (Python: `from x import *`, JS: `import * as x` used without namespace).

| Score | Criteria |
|-------|----------|
| 100 | 0 wildcard imports |
| 90 | 1-2 wildcard imports |
| 80 | 3-5 wildcard imports |
| 70 | 6-10 wildcard imports |
| 60 | 11-20 wildcard imports |
| 40 | 20+ wildcard imports |

### M6.4: Deep Relative Imports (20% of D6)

Import paths with more than 3 levels of `../` (should use path aliases).

| Score | Criteria |
|-------|----------|
| 100 | 0 deep relative imports (> 3 levels) |
| 90 | 1-3 deep relative imports |
| 80 | 4-8 deep relative imports |
| 70 | 9-15 deep relative imports |
| 60 | 16-25 deep relative imports |
| 40 | 25+ deep relative imports |

**D6 formula:** `D6 = (M6.1 * 0.30) + (M6.2 * 0.30) + (M6.3 * 0.20) + (M6.4 * 0.20)`

---

## D7: Supabase Waste (Weight: 8%) — N/A if no Supabase

### M7.1: Unused Tables (30% of D7)

Tables created in migrations but never queried in client code (no `.from('table_name')`, no FK references).

| Score | Criteria |
|-------|----------|
| 100 | 0 unused tables |
| 90 | 1 unused table |
| 80 | 2-3 unused tables |
| 70 | 4-5 unused tables |
| 60 | 6-8 unused tables |
| 40 | 8+ unused tables |

### M7.2: Orphan Migrations (25% of D7)

Migrations that create an object then a later migration drops it, or migrations with only DROP statements for non-existent objects.

| Score | Criteria |
|-------|----------|
| 100 | 0 orphan migration pairs |
| 90 | 1 orphan pair |
| 80 | 2-3 orphan pairs |
| 70 | 4-5 orphan pairs |
| 60 | 6+ orphan pairs |

### M7.3: Dead RLS Policies (25% of D7)

RLS policies defined on tables that no longer exist, or conflicting/redundant policies on the same table.

| Score | Criteria |
|-------|----------|
| 100 | 0 dead/conflicting RLS policies |
| 90 | 1-2 dead policies |
| 80 | 3-5 dead policies |
| 70 | 6-8 dead policies |
| 60 | 8+ dead policies |

### M7.4: Unused Storage Buckets (20% of D7)

Storage buckets created in migrations/config but never referenced in client code (no upload/download calls).

| Score | Criteria |
|-------|----------|
| 100 | 0 unused buckets |
| 90 | 1 unused bucket |
| 80 | 2 unused buckets |
| 70 | 3 unused buckets |
| 60 | 4+ unused buckets |

**D7 formula:** `D7 = (M7.1 * 0.30) + (M7.2 * 0.25) + (M7.3 * 0.25) + (M7.4 * 0.20)`

---

## D8: Next.js / Frontend Waste (Weight: 8%) — N/A if no Next.js

### M8.1: Unused Pages/Routes (30% of D8)

Pages in app/ or pages/ directory with no `<Link>` or `router.push` pointing to them.

| Score | Criteria |
|-------|----------|
| 100 | 0 unreferenced routes |
| 90 | 1-2 unreferenced routes |
| 80 | 3-5 unreferenced routes |
| 70 | 6-10 unreferenced routes |
| 60 | 11-15 unreferenced routes |
| 40 | 15+ unreferenced routes |

### M8.2: Unused Components (30% of D8)

React components defined but never rendered (never imported or used in JSX).

| Score | Criteria |
|-------|----------|
| 100 | 0 unused components |
| 90 | 1-3 unused components |
| 80 | 4-8 unused components |
| 70 | 9-15 unused components |
| 60 | 16-25 unused components |
| 40 | 25+ unused components |

### M8.3: Dead CSS/Tailwind Classes (20% of D8)

CSS classes or Tailwind utilities defined/configured but never used in markup.

| Score | Criteria |
|-------|----------|
| 100 | 0 dead CSS classes (purge-clean) |
| 90 | 1-10 dead classes |
| 80 | 11-25 dead classes |
| 70 | 26-50 dead classes |
| 60 | 51-100 dead classes |
| 40 | 100+ dead classes |

### M8.4: Unused API Routes (20% of D8)

API routes defined in app/api/ or pages/api/ never called from client-side code.

| Score | Criteria |
|-------|----------|
| 100 | 0 unused API routes |
| 90 | 1 unused API route |
| 80 | 2-3 unused API routes |
| 70 | 4-5 unused API routes |
| 60 | 6-8 unused API routes |
| 40 | 8+ unused API routes |

**D8 formula:** `D8 = (M8.1 * 0.30) + (M8.2 * 0.30) + (M8.3 * 0.20) + (M8.4 * 0.20)`

---

## D9: Python Waste (Weight: 8%) — N/A if no Python

### M9.1: Unused Python Imports (30% of D9)

Import statements where the symbol is never used. Detected by ruff F401 or vulture.

| Score | Criteria |
|-------|----------|
| 100 | 0 unused imports |
| 90 | 1-5 unused imports |
| 80 | 6-15 unused imports |
| 70 | 16-30 unused imports |
| 60 | 31-50 unused imports |
| 40 | 50+ unused imports |

### M9.2: Dead Python Functions/Classes (25% of D9)

Functions or classes defined but never called/instantiated anywhere.

| Score | Criteria |
|-------|----------|
| 100 | 0 dead functions/classes |
| 90 | 1-3 dead |
| 80 | 4-8 dead |
| 70 | 9-15 dead |
| 60 | 16-25 dead |
| 40 | 25+ dead |

### M9.3: Unused Python Variables (25% of D9)

Variables assigned but never read. Detected by ruff F841 or vulture.

| Score | Criteria |
|-------|----------|
| 100 | 0 unused variables |
| 90 | 1-5 unused vars |
| 80 | 6-15 unused vars |
| 70 | 16-30 unused vars |
| 60 | 31-50 unused vars |
| 40 | 50+ unused vars |

### M9.4: Empty __init__.py Files (20% of D9)

`__init__.py` files with no content or only comments (unnecessary in modern Python 3.3+).

| Score | Criteria |
|-------|----------|
| 100 | 0 empty __init__.py files |
| 90 | 1-3 empty __init__.py |
| 80 | 4-8 empty __init__.py |
| 70 | 9-15 empty __init__.py |
| 60 | 16-25 empty __init__.py |
| 40 | 25+ empty __init__.py |

**D9 formula:** `D9 = (M9.1 * 0.30) + (M9.2 * 0.25) + (M9.3 * 0.25) + (M9.4 * 0.20)`

---

## D10: Git & Repository Hygiene (Weight: 9%)

### M10.1: Large Files in Git (30% of D10)

Files > 1MB tracked in git that should be in LFS, cloud storage, or gitignored.

| Score | Criteria |
|-------|----------|
| 100 | 0 files > 1MB |
| 90 | 1 file > 1MB (< 5MB) |
| 80 | 2-3 files > 1MB (< 10MB total) |
| 70 | 4-5 files (< 20MB total) |
| 60 | 6-10 files or > 20MB total |
| 40 | 10+ large files or > 50MB total |

### M10.2: Secrets in Tracked Files (25% of D10)

API key patterns, passwords, tokens found in tracked source files (not .env).

| Score | Criteria |
|-------|----------|
| 100 | 0 secret patterns detected |
| 70 | 1-2 possible secrets (may be false positives) |
| 40 | 3-5 likely secrets |
| 20 | 5+ confirmed secret patterns |
| 0 | Active credentials found in tracked files |

### M10.3: .gitignore Gaps (25% of D10)

Common entries that should be in .gitignore but are missing.

Expected entries by stack:
- **All:** `.env`, `.env.local`, `.DS_Store`, `*.log`
- **Node:** `node_modules/`, `dist/`, `.next/`, `coverage/`, `.turbo/`
- **Python:** `__pycache__/`, `*.pyc`, `.venv/`, `venv/`, `.mypy_cache/`, `.ruff_cache/`
- **Supabase:** `.temp/`, `.branches/`

| Score | Criteria |
|-------|----------|
| 100 | All expected entries present |
| 90 | 1 missing entry |
| 80 | 2-3 missing entries |
| 70 | 4-5 missing entries |
| 60 | 6-8 missing entries |
| 40 | 8+ missing entries |

### M10.4: Stale Branches (20% of D10)

Branches that have been merged or abandoned (no commits in 30+ days, not main/develop).

| Score | Criteria |
|-------|----------|
| 100 | 0 stale branches |
| 90 | 1-3 stale branches |
| 80 | 4-8 stale branches |
| 70 | 9-15 stale branches |
| 60 | 16-25 stale branches |
| 40 | 25+ stale branches |

**D10 formula:** `D10 = (M10.1 * 0.30) + (M10.2 * 0.25) + (M10.3 * 0.25) + (M10.4 * 0.20)`

---

## Overall Score Formula

```
Overall = (D1 * 0.15) + (D2 * 0.12) + (D3 * 0.10) + (D4 * 0.10)
        + (D5 * 0.10) + (D6 * 0.10) + (D7 * 0.08) + (D8 * 0.08)
        + (D9 * 0.08) + (D10 * 0.09)
```

When a stack-specific dimension (D7/D8/D9) is N/A, score it as 100 and redistribute:

```
active_weight = sum of weights for dimensions that apply
adjusted_weight[Di] = original_weight[Di] / active_weight
```

---

## Framework Sources

| Dimension | Primary Source | Secondary Source |
|-----------|---------------|-----------------|
| D1 | knip, ESLint no-unused-vars, vulture | LSP unused symbol detection |
| D2 | depcheck, pip-autoremove | npm audit, pip check |
| D3 | madge --orphans, filesystem analysis | knip unused files |
| D4 | .env parsing, config file analysis | CI/CD yaml parsing |
| D5 | TypeScript strict mode, ruff, ESLint | SonarQube tech debt |
| D6 | madge --circular, ruff F401 | ESLint import plugin |
| D7 | Supabase migration analysis | pg_stat_user_tables |
| D8 | Next.js build analysis | bundle analyzer |
| D9 | vulture, ruff F401/F841 | mypy unused |
| D10 | git ls-files, git branch --merged | gitleaks, trufflehog |
