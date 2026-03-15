# Stack-Specific Cleanup Guides

Three separate guides for Python, Next.js/TypeScript, and Supabase cleanup operations.

---

## Python Cleanup Guide

### Detection

A Python project is detected when any of these exist:
- `pyproject.toml`
- `requirements.txt` / `requirements-*.txt`
- `setup.py` / `setup.cfg`
- `Pipfile` / `Pipfile.lock`
- `.py` files in src/ or root

### Tools

| Tool | Purpose | Install | Auto-detected |
|------|---------|---------|---------------|
| `vulture` | Dead code detection (functions, vars, imports) | `pip install vulture` | `which vulture` |
| `ruff` | Fast linter — unused imports (F401), unused vars (F841) | `pip install ruff` | `which ruff` |
| `pip-autoremove` | Find unused installed packages | `pip install pip-autoremove` | `which pip-autoremove` |
| `mypy` | Type checking, unused type: ignore | `pip install mypy` | `which mypy` |
| `pyright` (LSP) | Ground-truth unused symbol detection | Already installed | LSP active check |

### Key Patterns to Detect

**Unused imports:**
```bash
# Best: use ruff
ruff check --select F401 --output-format json .

# Fallback: grep for import lines, then check if symbol is used
grep -rn "^import \|^from .* import " --include="*.py" .
```

**Dead code (functions/classes):**
```bash
# Best: use vulture
vulture . --min-confidence 80

# Fallback: find function defs, grep for callers
grep -rn "^def \|^class " --include="*.py" .
# Then for each name, check if it appears elsewhere
```

**Unused variables:**
```bash
# Best: use ruff
ruff check --select F841 --output-format json .
```

**Empty __init__.py:**
```bash
# Find __init__.py files with 0 bytes or only comments/whitespace
find . -name "__init__.py" -size 0
find . -name "__init__.py" -exec sh -c 'grep -cve "^\s*#\|^\s*$" "$1" | grep -q "^0$" && echo "$1"' _ {} \;
```

### Safe Deletion Rules

1. **Always check `__all__`** — A symbol listed in `__all__` is public API even if not imported internally
2. **Check decorators** — `@app.route`, `@celery.task`, `@pytest.fixture` make functions callable without direct imports
3. **Check dynamic imports** — `importlib.import_module()`, `__import__()`, `getattr(module, name)`
4. **Check string references** — Django URL patterns, Celery task names, plugin registries
5. **Check `if __name__ == "__main__"`** — Entry point functions are not dead even without callers

### Common False Positives

| Pattern | Why it looks dead | Why it is not |
|---------|-------------------|---------------|
| `@pytest.fixture` functions | No direct callers | Injected by pytest |
| `@app.route` handlers | No direct callers | Called by framework |
| `__all__` exports | Not imported internally | Public API contract |
| Celery tasks | Not called directly | Invoked by `.delay()` or string name |
| Django models | Not imported in views | Used by ORM, migrations, admin |
| `conftest.py` fixtures | Not imported | Auto-discovered by pytest |
| Protocol/ABC methods | Not called | Implemented by subclasses |

---

## Next.js / TypeScript Cleanup Guide

### Detection

A Next.js/TypeScript project is detected when:
- `next.config.js` / `next.config.mjs` / `next.config.ts` exists
- `package.json` contains `"next"` in dependencies
- `app/` or `pages/` directory exists with `.tsx` files
- `tsconfig.json` exists

### Tools

| Tool | Purpose | Install | Auto-detected |
|------|---------|---------|---------------|
| `knip` | All-in-one: unused exports, files, deps, types | `npm i -g knip` | `which knip` |
| `depcheck` | Unused npm dependencies | `npm i -g depcheck` | `which depcheck` |
| `madge` | Circular imports, orphan files, dependency graph | `npm i -g madge` | `which madge` |
| `next-bundle-analyzer` | Bundle size, unused code in bundles | devDependency | package.json check |
| `eslint` (unused-imports) | Unused import detection | devDependency | `.eslintrc` check |
| `vtsls` (LSP) | Ground-truth unused symbol detection | Already installed | LSP active check |

### Key Patterns to Detect

**Unused exports:**
```bash
# Best: use knip
npx knip --reporter json

# Fallback: find exports, check if imported
grep -rn "^export " --include="*.ts" --include="*.tsx" .
```

**Unused dependencies:**
```bash
# Best: use depcheck
npx depcheck --json

# Fallback: parse package.json deps, grep each in source
node -e "const p=require('./package.json'); Object.keys({...p.dependencies,...p.devDependencies}).forEach(d=>console.log(d))"
# Then grep each package name in source files
```

**Orphan files:**
```bash
# Best: use madge
npx madge --orphans --extensions ts,tsx src/

# Fallback: for each .ts/.tsx, check if its path appears in any import statement
```

**Circular imports:**
```bash
npx madge --circular --extensions ts,tsx src/
```

**Unused components:**
```bash
# Find component files, check if component name appears in JSX elsewhere
# Component = file in components/ exporting a PascalCase function
```

**Unused pages/routes:**
```bash
# List all page.tsx/route.tsx paths in app/
# Convert to URL paths
# Grep for those paths in Link href, router.push, fetch calls
```

**Dead CSS / Tailwind:**
```bash
# Check tailwind.config content paths cover all source files
# For CSS modules: check if .module.css class names are used in their co-located component
```

### Safe Deletion Rules

1. **Check dynamic imports** — `dynamic(() => import(...))`, `React.lazy(() => import(...))`
2. **Check string-based routes** — `router.push('/path')` with template literals or variables
3. **Check Next.js magic files** — `layout.tsx`, `loading.tsx`, `error.tsx`, `not-found.tsx`, `middleware.ts` are auto-used
4. **Check barrel exports** — `index.ts` re-exports may look unused but serve as public API
5. **Check `getServerSideProps` / `getStaticProps`** — Framework-called, not directly imported
6. **Check metadata exports** — `export const metadata`, `export function generateMetadata`

### Common False Positives

| Pattern | Why it looks dead | Why it is not |
|---------|-------------------|---------------|
| `layout.tsx` | Not imported | Auto-used by Next.js App Router |
| `loading.tsx` / `error.tsx` | Not imported | Auto-used by Next.js App Router |
| `middleware.ts` | Not imported | Auto-invoked by Next.js |
| `[slug]/page.tsx` | No static Link | Dynamic routes |
| CSS module classes | Not in JS grep | Used via `styles.className` |
| Tailwind config plugins | Not imported | Used by PostCSS pipeline |
| `global.css` | Not imported in most files | Imported once in root layout |
| Image files in `public/` | Not in import statements | Referenced via `/image.png` URL |
| `env.d.ts` / `*.d.ts` | Not imported | Auto-included by TypeScript |
| Server Actions (`"use server"`) | No direct import | Called via form action binding |

---

## Supabase Cleanup Guide

### Detection

A Supabase project is detected when:
- `supabase/` directory exists
- `supabase/config.toml` exists
- `supabase/migrations/` contains `.sql` files
- Source code contains `createClient` from `@supabase/supabase-js`
- `.env` contains `SUPABASE_URL` or `NEXT_PUBLIC_SUPABASE_URL`

### Tools

| Tool | Purpose | Install | Auto-detected |
|------|---------|---------|---------------|
| `supabase` CLI | Migration management, schema inspection | `brew install supabase/tap/supabase` | `which supabase` |
| `pg_stat_user_tables` | Table usage statistics (if DB access) | PostgreSQL built-in | DB connection check |
| Migration file analysis | Static analysis of .sql files | Built-in (grep) | Always available |

### Key Patterns to Detect

**Unused tables:**
```bash
# 1. Extract table names from migrations (CREATE TABLE statements)
grep -rh "CREATE TABLE" supabase/migrations/ | sed 's/.*CREATE TABLE\s\+\(IF NOT EXISTS\s\+\)\?//' | sed 's/\s*(.*//' | sort -u

# 2. Check if each table name appears in client code
# Look for: .from('table_name'), .rpc('func_using_table'), SQL strings
grep -rn "from('table_name')\|\.from(\"table_name\")" --include="*.ts" --include="*.tsx" src/
```

**Orphan migrations:**
```bash
# Find tables that are CREATE'd then DROP'd in later migrations
# Extract CREATE TABLE and DROP TABLE statements with timestamps
grep -rn "CREATE TABLE\|DROP TABLE" supabase/migrations/ | sort
# Cross-reference: if a table is created and later dropped, both migrations are orphan-candidates
```

**Dead RLS policies:**
```bash
# Extract RLS policy targets (ON table_name)
grep -rn "CREATE POLICY\|ALTER POLICY" supabase/migrations/ | grep -oP "ON\s+\K\S+"
# Check if those tables still exist (not dropped in later migrations)
```

**Unused storage buckets:**
```bash
# Find bucket creation in migrations or code
grep -rn "createBucket\|insert.*storage.buckets\|INSERT INTO storage.buckets" supabase/migrations/ src/

# Find bucket usage in client code
grep -rn "storage.from\|\.upload\|\.download\|\.getPublicUrl" --include="*.ts" --include="*.tsx" src/
```

**Unused edge functions:**
```bash
# List edge functions
ls supabase/functions/

# Check if each function name is called from client code
# Look for: .functions.invoke('function_name'), fetch to /functions/v1/function_name
```

### Safe Deletion Rules

1. **Check for triggers** — A table may have no direct queries but be populated by triggers
2. **Check for views** — A table may be a source for materialized views
3. **Check for foreign keys** — A table may be referenced by FK constraints from active tables
4. **Check for RPC functions** — A table may be accessed via database functions, not direct .from()
5. **Check for external consumers** — Webhooks, external services, analytics pipelines
6. **Check for scheduled jobs** — pg_cron or Supabase scheduled functions may use tables
7. **Never auto-drop tables** — Always Tier 3 (needs investigation) unless confirmed empty + unreferenced

### Common False Positives

| Pattern | Why it looks unused | Why it is not |
|---------|---------------------|---------------|
| Audit/log tables | No client queries | Written by triggers, read by admin |
| Junction/join tables | Not in .from() | Accessed via joins or RPC |
| Auth schema tables | Not queried directly | Managed by Supabase Auth |
| Storage.objects | Not in migrations | Managed by Supabase Storage |
| Realtime subscriptions | No .from() query | Used via .channel().on() |
| Edge function secrets | Not in source | Injected at runtime |
| Migration-only tables | Not in app code | Used for data migration then kept for rollback |

### Migration Cleanup Strategy

When orphan migrations are found:

1. **Do NOT delete old migrations** — They represent history
2. **Create a new consolidation migration** that:
   - Drops confirmed-unused tables
   - Drops orphan RLS policies
   - Removes unused storage buckets
3. **Test on a branch database first:**
   ```bash
   supabase db reset   # on local
   supabase branches create cleanup-test  # on hosted
   ```
4. **Verify no data loss** — Check row counts before dropping
