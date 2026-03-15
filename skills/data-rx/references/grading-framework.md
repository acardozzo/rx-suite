# data-rx Grading Framework

All sub-metrics are scored on a 0-100 scale. This document defines the threshold criteria for each score level across all 40 sub-metrics. Fixed stack: **Supabase (PostgreSQL)**.

---

## Score Scale

| Score | Label | Meaning |
|-------|-------|---------|
| 0 | Critical | Fundamental flaw, no implementation |
| 40 | Poor | Minimal implementation, major gaps |
| 70 | Adequate | Basic implementation, some gaps remain |
| 85 | Good | Solid implementation, minor improvements possible |
| 100 | Excellent | Best-practice implementation, fully aligned with Supabase patterns |

## Letter Grade Mapping

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

---

## D1: Schema Design & Normalization (12%)

### M1.1 — Table Naming Conventions

| Score | Criteria |
|-------|----------|
| 100 | All tables use snake_case, plural form, consistent prefixes for domain groups; matches Supabase conventions (e.g., `public.profiles`, `public.documents`) |
| 85 | All tables snake_case, mostly plural; 1-2 inconsistencies in prefix grouping |
| 70 | Most tables snake_case; some camelCase or singular names; no consistent prefix strategy |
| 40 | Mixed naming (camelCase, PascalCase, snake_case); no convention apparent |
| 0 | Random naming, spaces in names, reserved word conflicts, no convention |

### M1.2 — Column Types & Constraints

| Score | Criteria |
|-------|----------|
| 100 | All columns use proper PostgreSQL types (uuid, timestamptz, text, jsonb); NOT NULL on all required fields; CHECK constraints for enums/ranges; DEFAULT values for timestamps/UUIDs (`gen_random_uuid()`, `now()`) |
| 85 | Proper types throughout; NOT NULL on most required fields; some CHECK constraints; DEFAULT on timestamps |
| 70 | Generally correct types; some missing NOT NULL; no CHECK constraints; DEFAULT on PKs only |
| 40 | Some type mismatches (varchar(255) instead of text, timestamp instead of timestamptz); many nullable columns that should be required |
| 0 | Widespread type issues; storing dates as text, using integer for boolean, no constraints at all |

### M1.3 — Normalization Level

| Score | Criteria |
|-------|----------|
| 100 | 3NF minimum across all tables; any denormalization is intentional, documented in migration comments, and uses materialized views or JSONB columns with clear justification |
| 85 | 3NF on core entities; 1-2 intentional denormalizations without documentation |
| 70 | Mostly 2NF; some repeated data groups; partial normalization |
| 40 | Significant 1NF violations; CSV-in-columns, repeated column groups (address1, address2, address3) |
| 0 | Flat tables with massive column counts; no relational structure; spreadsheet-in-database |

### M1.4 — Primary Keys & Identity

| Score | Criteria |
|-------|----------|
| 100 | All tables use `uuid` PK with `DEFAULT gen_random_uuid()`; composite keys only for junction tables; `id` column naming convention consistent |
| 85 | UUID PKs on most tables; `bigint generated always as identity` where sequential needed; consistent naming |
| 70 | Mix of UUID and serial; inconsistent PK naming (some `id`, some `table_id`, some `table_name_id`) |
| 40 | Mostly serial/integer PKs; some tables missing explicit PK; inconsistent naming |
| 0 | Missing PKs on tables; natural keys only; no identity strategy |

---

## D2: Relationships & Foreign Keys (10%)

### M2.1 — Foreign Key Coverage

| Score | Criteria |
|-------|----------|
| 100 | All relationships have FK constraints; `REFERENCES` on every column referencing another table; FKs reference `id` columns consistently |
| 85 | FKs on all core relationships; 1-2 lookup/config references missing FK |
| 70 | FKs on most tables; some implicit relationships (column named `user_id` without FK constraint) |
| 40 | Few FK constraints; most relationships implicit; relying on application-level enforcement |
| 0 | No FK constraints at all; all relationships implicit |

### M2.2 — Cascade Rules

| Score | Criteria |
|-------|----------|
| 100 | Every FK has explicit ON DELETE (CASCADE for owned entities, SET NULL for optional refs, RESTRICT for critical refs); ON UPDATE CASCADE where needed |
| 85 | ON DELETE specified on most FKs; appropriate choice per relationship type; 1-2 using default NO ACTION |
| 70 | ON DELETE on core relationships; some using default NO ACTION where CASCADE would be appropriate |
| 40 | Few explicit cascade rules; mostly relying on PostgreSQL defaults |
| 0 | No cascade rules specified; orphaned records likely on deletion |

### M2.3 — Junction Tables for M:N

| Score | Criteria |
|-------|----------|
| 100 | All M:N relationships use proper junction tables with composite PK or UUID PK + unique constraint; no array columns for relationships; junction tables have `created_at` and any needed metadata |
| 85 | Junction tables for most M:N; proper structure; 1-2 using array columns where a junction would be cleaner |
| 70 | Some junction tables; some M:N modeled as arrays or JSONB; mixed approach |
| 40 | Most M:N use array columns or comma-separated values; few proper junction tables |
| 0 | No junction tables; M:N stored as arrays, JSONB blobs, or comma-separated strings |

### M2.4 — Self-Referential & Polymorphic Patterns

| Score | Criteria |
|-------|----------|
| 100 | Tree structures use proper `parent_id` self-ref FK with ON DELETE CASCADE/SET NULL; polymorphic associations use separate FK columns (not type+id pattern) or proper PostgreSQL inheritance; ltree for deep hierarchies |
| 85 | Self-referential FKs correct; polymorphic patterns work but could be cleaner |
| 70 | Self-refs present but missing FK constraints; polymorphic uses type+id pattern without check constraints |
| 40 | Tree structures without FK constraints; polymorphic patterns with no referential integrity |
| 0 | No pattern for hierarchies; orphan references; broken tree structures |

---

## D3: Indexing & Query Performance (12%)

### M3.1 — Index Coverage

| Score | Criteria |
|-------|----------|
| 100 | Indexes on ALL FK columns; indexes on all columns used in WHERE/ORDER BY in Supabase client `.select().eq()`/`.order()` calls; unique indexes for unique business rules |
| 85 | Indexes on all FK columns; most query columns indexed; unique indexes present |
| 70 | Indexes on most FK columns; some frequently queried columns missing indexes |
| 40 | Few explicit indexes; only PK indexes; FK columns not indexed |
| 0 | No indexes beyond auto-created PK indexes |

### M3.2 — Composite Indexes

| Score | Criteria |
|-------|----------|
| 100 | Multi-column indexes match query patterns (e.g., `(user_id, created_at DESC)` for user timelines); covering indexes for hot queries; proper column order |
| 85 | Composite indexes for main query patterns; correct column order |
| 70 | Some composite indexes; column order may not be optimal |
| 40 | No composite indexes; single-column indexes only |
| 0 | N/A — no indexes at all |

### M3.3 — Index Types

| Score | Criteria |
|-------|----------|
| 100 | B-tree for equality/range; GIN for JSONB columns and array columns; GiST for geo data; pg_trgm + GIN for text search; partial indexes where appropriate |
| 85 | Correct index types for most use cases; GIN for JSONB where needed |
| 70 | All B-tree indexes; JSONB columns queried but not GIN-indexed |
| 40 | Only default B-tree; specialized types not used where needed |
| 0 | No awareness of index types |

### M3.4 — Query Patterns

| Score | Criteria |
|-------|----------|
| 100 | No N+1 patterns; Supabase client uses `.select('col1, col2, relation(col1)')` with specific columns; no `SELECT *`; proper joins via `.select()` with relation syntax; pagination via `.range()` |
| 85 | Specific column selection in most queries; proper relations; pagination present; 1-2 broad selects |
| 70 | Some `.select('*')` or no `.select()` (defaults to all); some N+1 patterns in loops |
| 40 | Widespread `SELECT *`; N+1 patterns common; no pagination |
| 0 | All queries fetch everything; `.select()` never used with specific columns; loops making individual queries |

---

## D4: Row-Level Security (12%)

### M4.1 — RLS Enabled

| Score | Criteria |
|-------|----------|
| 100 | RLS enabled on ALL tables with user data; `ALTER TABLE ... ENABLE ROW LEVEL SECURITY` + `ALTER TABLE ... FORCE ROW LEVEL SECURITY` on all; no public tables without explicit justification documented in migration comments |
| 85 | RLS enabled on all user-facing tables; 1-2 config/lookup tables without RLS (documented reason) |
| 70 | RLS on most tables; some gaps in less critical tables; no FORCE ROW LEVEL SECURITY |
| 40 | RLS on a few core tables; many user-data tables without RLS |
| 0 | RLS not enabled on any table; or enabled but no policies defined |

### M4.2 — Policy Completeness

| Score | Criteria |
|-------|----------|
| 100 | Every RLS-enabled table has SELECT + INSERT + UPDATE + DELETE policies for each applicable role (anon, authenticated); policies cover both USING and WITH CHECK; no operations left unrestricted |
| 85 | All CRUD policies on core tables; 1-2 tables missing DELETE policy; WITH CHECK present on INSERT/UPDATE |
| 70 | SELECT and INSERT policies on most tables; UPDATE/DELETE policies inconsistent |
| 40 | Only SELECT policies; INSERT/UPDATE/DELETE open or missing |
| 0 | No policies defined; RLS enabled but all operations blocked (or no RLS at all) |

### M4.3 — Policy Quality

| Score | Criteria |
|-------|----------|
| 100 | All policies use `auth.uid() = user_id` or similar precise checks; role-based policies use `auth.jwt()->>'role'`; no `USING(true)` on any sensitive table; policies are specific per operation (different logic for SELECT vs UPDATE) |
| 85 | auth.uid() checks on most policies; role checks present; 1-2 overly broad policies on non-sensitive tables |
| 70 | auth.uid() on core policies; some `USING(true)` on lookup tables; no role differentiation |
| 40 | Many `USING(true)` policies; auth.uid() only on a few tables; weak security posture |
| 0 | All policies are `USING(true)` (wide open); or no auth.uid() checks anywhere |

### M4.4 — Service Role Separation

| Score | Criteria |
|-------|----------|
| 100 | `service_role` key used only server-side (Edge Functions, server components); `anon` key on client; `createServerClient` for mutations; `createBrowserClient` for client reads; no `SUPABASE_SERVICE_ROLE_KEY` in client bundles |
| 85 | Proper separation; service_role server-side only; 1-2 mutations on client using anon key (acceptable if RLS covers it) |
| 70 | Mostly separated; some server-side operations using anon key unnecessarily |
| 40 | Service role and anon key usage mixed; unclear separation |
| 0 | `service_role` key exposed in client-side code; or hardcoded in frontend bundle |

---

## D5: Migrations & Schema Evolution (10%)

### M5.1 — Migration Discipline

| Score | Criteria |
|-------|----------|
| 100 | All schema changes via `supabase migration new` or `supabase db diff`; no manual DDL; migration files in `supabase/migrations/`; CI runs `supabase db push` or `supabase db reset` for validation |
| 85 | All changes via migrations; supabase CLI used; no CI validation step |
| 70 | Most changes via migrations; some manual DDL detected (e.g., via dashboard) |
| 40 | Mix of migration files and manual changes; some SQL files outside `supabase/migrations/` |
| 0 | No migration files; all changes manual via Supabase dashboard or raw SQL |

### M5.2 — Migration Quality

| Score | Criteria |
|-------|----------|
| 100 | Migrations are idempotent (`IF NOT EXISTS`, `IF EXISTS`); backward-compatible (expand-and-contract for breaking changes); each migration is atomic and focused on one change; comments explain intent |
| 85 | Mostly idempotent; focused migrations; some missing IF NOT EXISTS guards |
| 70 | Migrations work but not idempotent; some large combined migrations |
| 40 | Fragile migrations; breaking changes without compatibility period; re-running fails |
| 0 | Migrations fail on re-run; destructive changes without safeguards |

### M5.3 — Seed Data

| Score | Criteria |
|-------|----------|
| 100 | `supabase/seed.sql` with reproducible test data; environment-specific seeds (dev/test); covers all tables with required references; idempotent (can re-run safely) |
| 85 | Seed file exists and covers core tables; not all relationships seeded; idempotent |
| 70 | Basic seed file; covers some tables; may fail on re-run |
| 40 | Minimal or empty seed file; developers create data manually |
| 0 | No seed file; no reproducible way to set up test data |

### M5.4 — Schema Versioning

| Score | Criteria |
|-------|----------|
| 100 | Migration files have proper timestamps (YYYYMMDDHHMMSS format); no conflicts; linear history; `supabase migration list` shows clean state; `schema_migrations` table consistent |
| 85 | Proper timestamps; linear history; minor timestamp gaps |
| 70 | Timestamps present but some out of order; generally works |
| 40 | Inconsistent naming; some migrations with manual names; ordering issues |
| 0 | No versioning; random file names; migration order unclear |

---

## D6: Supabase Auth Integration (10%)

### M6.1 — Auth Setup

| Score | Criteria |
|-------|----------|
| 100 | Auth providers configured in `supabase/config.toml`; email templates customized; redirect URLs properly set for all environments; rate limiting configured; PKCE flow for SPAs |
| 85 | Providers configured; email templates mostly customized; redirect URLs set; default rate limits |
| 70 | Basic email/password auth working; default templates; redirect URLs for main environment only |
| 40 | Auth enabled but minimal configuration; default everything |
| 0 | Not using Supabase Auth; custom auth implementation; or Auth not configured |

### M6.2 — User Metadata & Profiles

| Score | Criteria |
|-------|----------|
| 100 | `profiles` table in public schema linked to `auth.users` via FK on `id`; RLS on profiles; trigger to create profile on signup; `raw_user_meta_data` used only for provider data, app data in profiles |
| 85 | Profiles table exists with FK; RLS present; trigger works; some app data in user_metadata |
| 70 | Profiles table exists; no FK to auth.users (application-level link); basic RLS |
| 40 | User data scattered; no dedicated profiles table; user_metadata overloaded |
| 0 | No profiles table; all user data in auth.users metadata; no structure |

### M6.3 — Auth Hooks & Triggers

| Score | Criteria |
|-------|----------|
| 100 | `handle_new_user` function and trigger on `auth.users` INSERT; additional hooks for role assignment, team creation, etc.; triggers are in migrations; error handling in trigger functions |
| 85 | handle_new_user trigger present and in migrations; basic functionality; minimal error handling |
| 70 | Trigger exists but not in migrations (manual creation); works but fragile |
| 40 | No trigger; profile creation handled in application code (race conditions possible) |
| 0 | No hooks or triggers; user setup not automated |

### M6.4 — Session Management

| Score | Criteria |
|-------|----------|
| 100 | JWT expiry configured appropriately (short-lived access, long-lived refresh); custom JWT claims via hooks for roles/permissions; MFA enabled for admin users; proper `onAuthStateChange` handling in client |
| 85 | JWT expiry configured; basic onAuthStateChange; no custom claims; no MFA |
| 70 | Default JWT config; onAuthStateChange partially handled; some auth state edge cases |
| 40 | Default everything; auth state not properly managed in client |
| 0 | No session management; no refresh handling; users get logged out unexpectedly |

---

## D7: Supabase Storage (8%)

### M7.1 — Bucket Configuration

| Score | Criteria |
|-------|----------|
| 100 | Buckets created via migrations; public vs private properly separated; file size limits set; allowed MIME types restricted per bucket; bucket names follow convention |
| 85 | Buckets configured; size limits set; MIME types restricted; created via migration or config |
| 70 | Buckets exist; basic configuration; no MIME type restriction; no size limits |
| 40 | Single bucket for everything; no configuration; manual creation |
| 0 | Not using Supabase Storage; or no bucket configuration at all |

### M7.2 — Storage RLS

| Score | Criteria |
|-------|----------|
| 100 | RLS policies on `storage.objects` for each bucket; per-user path policies (e.g., `auth.uid()::text = (storage.foldername(name))[1]`); separate policies for upload/download/delete; no public access to private files |
| 85 | RLS on storage.objects; per-user paths; most operations covered; 1-2 gaps |
| 70 | Basic RLS on storage; authenticated users can access; not per-user scoped |
| 40 | Minimal storage RLS; overly permissive policies |
| 0 | No RLS on storage.objects; all files publicly accessible |

### M7.3 — Image Transformations

| Score | Criteria |
|-------|----------|
| 100 | Using Supabase image transform API for thumbnails/resizing; proper sizing for different viewports; WebP/AVIF format optimization; CDN caching headers |
| 85 | Image transforms used for common sizes; basic format optimization |
| 70 | Some image processing; not using Supabase transforms (external library) |
| 40 | No image optimization; serving original files directly |
| 0 | N/A (no images) or serving unoptimized images causing performance issues |

### M7.4 — Cleanup & Lifecycle

| Score | Criteria |
|-------|----------|
| 100 | Orphan file detection (files referenced by deleted records); cleanup Edge Function or cron job; storage quotas monitored; old file archival strategy |
| 85 | Basic orphan detection; periodic cleanup; quotas tracked |
| 70 | Manual cleanup process; no automated orphan detection |
| 40 | No cleanup; orphan files accumulate; no monitoring |
| 0 | Storage growing unchecked; no awareness of orphan files; no cleanup process |

---

## D8: Supabase Realtime & Edge Functions (8%)

### M8.1 — Realtime Channels

| Score | Criteria |
|-------|----------|
| 100 | Proper channel setup with `supabase.channel()`; RLS-filtered subscriptions (Realtime respects RLS policies); proper cleanup on unmount (`channel.unsubscribe()`); error handling for connection drops |
| 85 | Channels properly set up; cleanup on unmount; basic error handling; RLS filtering works |
| 70 | Channels work; some cleanup missing; no error handling for reconnection |
| 40 | Basic subscription; no cleanup; memory leaks possible; no error handling |
| 0 | Not using Realtime; or subscriptions broken/leaking |

### M8.2 — Realtime Presence

| Score | Criteria |
|-------|----------|
| 100 | Presence tracking with `channel.track()`; proper state sync; conflict resolution for concurrent updates; untrack on disconnect; presence used appropriately (not overused) |
| 85 | Presence working; basic state sync; untrack on disconnect |
| 70 | Presence partially implemented; some sync issues |
| 40 | Presence attempted but not reliable |
| 0 | N/A (not using Presence) — score as 100 if Presence is genuinely not needed |

### M8.3 — Edge Functions

| Score | Criteria |
|-------|----------|
| 100 | Edge Functions in `supabase/functions/`; proper Deno setup; secrets via `supabase secrets set` (not hardcoded); CORS configured; proper error responses; typed request/response; deployed via CI |
| 85 | Edge Functions present; secrets managed; CORS set; basic typing; manual deploy |
| 70 | Edge Functions work; some secrets in code; CORS issues; no typing |
| 40 | Edge Functions present but poorly structured; secrets in code; no error handling |
| 0 | N/A (not using Edge Functions) — score as 100 if not needed; score as 0 if server-side logic needed but implemented insecurely on client |

### M8.4 — Database Webhooks & Triggers

| Score | Criteria |
|-------|----------|
| 100 | Database triggers for event-driven logic; `pg_notify` for custom events; webhook integration for external services via Edge Functions; triggers in migrations; proper error handling |
| 85 | Triggers in migrations; pg_notify for some events; basic webhook integration |
| 70 | Some triggers; not all in migrations; no webhook integration |
| 40 | Few triggers; manual creation; no event-driven patterns |
| 0 | No triggers or webhooks; all logic in application code even where triggers would be more reliable |

---

## D9: Type Safety & Client Integration (10%)

### M9.1 — Generated Types

| Score | Criteria |
|-------|----------|
| 100 | `supabase gen types typescript` output in project (e.g., `supabase/types.ts` or `database.types.ts`); types freshness matches latest migration; generation in CI/pre-commit hook; types committed to repo |
| 85 | Generated types present and recent; no CI step; manually regenerated |
| 70 | Generated types exist but stale (schema changed since last generation) |
| 40 | Types file exists but very outdated; many tables missing |
| 0 | No generated types; Supabase client untyped |

### M9.2 — Client Typing

| Score | Criteria |
|-------|----------|
| 100 | `createClient<Database>(url, key)` with Database type parameter; no `any` in query results; typed `.select()`, `.insert()`, `.update()`; helper types for common patterns |
| 85 | Typed createClient; most queries typed; 1-2 `any` casts |
| 70 | Typed createClient; some queries losing types (intermediate `any`); type assertions common |
| 40 | Untyped createClient; `any` throughout; no type safety on queries |
| 0 | No TypeScript; or Supabase client used without any typing |

### M9.3 — Validation Schemas

| Score | Criteria |
|-------|----------|
| 100 | Zod/Valibot schemas matching DB types for form validation; schemas derived from or validated against generated types; server-side validation before insert/update; client-side validation for UX |
| 85 | Validation schemas present; match most DB types; both client and server validation |
| 70 | Some validation; schemas partially match DB types; mostly client-side only |
| 40 | Minimal validation; schemas don't match DB types; validation inconsistent |
| 0 | No validation schemas; data inserted without validation |

### M9.4 — API Layer Separation

| Score | Criteria |
|-------|----------|
| 100 | `createServerClient` (from `@supabase/ssr`) for server-side mutations; `createBrowserClient` for client-side reads; clear separation in code structure; no direct Supabase calls in UI components (abstracted via hooks/actions) |
| 85 | Server/client separation; most mutations server-side; some direct calls in components |
| 70 | Some separation; mutations happen on both client and server; inconsistent pattern |
| 40 | Single client everywhere; no server/client distinction |
| 0 | All operations via single browser client; no SSR consideration; mutations on client with anon key |

---

## D10: Observability & Maintenance (8%)

### M10.1 — Query Monitoring

| Score | Criteria |
|-------|----------|
| 100 | `pg_stat_statements` enabled; slow query identification process; Supabase dashboard performance tab used; query plans reviewed for critical paths; alerts for slow queries |
| 85 | pg_stat_statements aware; occasional query plan review; dashboard monitoring |
| 70 | Basic awareness of query performance; no systematic monitoring |
| 40 | No query monitoring; performance issues discovered by users |
| 0 | No awareness of query performance; no monitoring at all |

### M10.2 — Database Size & Bloat

| Score | Criteria |
|-------|----------|
| 100 | VACUUM monitoring; table bloat tracked; unused indexes identified and removed; table size monitoring; partitioning for large tables; pg_repack awareness |
| 85 | Basic VACUUM awareness; table sizes monitored; unused indexes occasionally reviewed |
| 70 | Autovacuum relied upon (default); no explicit bloat monitoring |
| 40 | No awareness of bloat; tables growing unchecked |
| 0 | Database performance degrading due to bloat; no maintenance |

### M10.3 — Connection Management

| Score | Criteria |
|-------|----------|
| 100 | Supabase connection pooler configured (transaction mode for serverless, session mode where needed); connection limits understood; pool size appropriate; pgBouncer settings in `supabase/config.toml` |
| 85 | Pooler used; transaction mode for most connections; basic configuration |
| 70 | Default pooler settings; connection mode not optimized for use case |
| 40 | Connection issues occurring; pool not properly configured |
| 0 | No pooler awareness; direct connections hitting limits; connection errors in production |

### M10.4 — Backup & Recovery

| Score | Criteria |
|-------|----------|
| 100 | Supabase PITR (point-in-time recovery) enabled (Pro plan+); restore procedure tested; backup monitoring; disaster recovery plan documented |
| 85 | PITR enabled; basic restore awareness; not recently tested |
| 70 | Daily backups (Supabase default); no PITR; not tested |
| 40 | Aware backups exist; never tested restore |
| 0 | No awareness of backup strategy; no restore testing; no recovery plan |

---

## Framework Sources

| Source | Used For | Dimensions |
|--------|----------|------------|
| PostgreSQL Official Documentation | Types, constraints, indexes, RLS syntax, VACUUM, pg_stat_statements | D1, D2, D3, D4, D10 |
| Supabase Official Documentation | Auth, Storage, Realtime, Edge Functions, CLI, RLS patterns | D4, D5, D6, D7, D8, D9 |
| Database Design by C.J. Date | Normalization theory, relational model fundamentals | D1, D2 |
| Use The Index, Luke (use-the-index-luke.com) | Index design, query optimization, composite indexes | D3 |
| Supabase CLI Reference | Migration commands, type generation, db diff | D5, D9 |
| OWASP (RLS/Auth patterns) | Security policies, role-based access | D4, D6 |
| Supabase Community Patterns | Profiles table, handle_new_user, storage policies | D6, D7 |
| PostgreSQL Wiki (Performance) | VACUUM, bloat, connection pooling, monitoring | D10 |
