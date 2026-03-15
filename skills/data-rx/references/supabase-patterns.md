# Supabase Anti-Patterns & Best Practices

Reference for data-rx scoring. Fixed stack: **Supabase (PostgreSQL + Auth + Storage + Edge Functions + Realtime + RLS)**.

---

## Anti-Patterns

### AP-1: USING(true) on Sensitive Tables (Wide-Open RLS)

**Severity:** CRITICAL
**Dimensions:** D4 (M4.3)

```sql
-- BAD: Anyone can read all user data
CREATE POLICY "allow all" ON profiles FOR SELECT USING (true);

-- GOOD: Users can only read their own profile
CREATE POLICY "users read own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);
```

**Why:** `USING(true)` negates the purpose of RLS. Any authenticated (or anonymous) user can access all rows.

### AP-2: No RLS on Tables Accessible via Anon Key

**Severity:** CRITICAL
**Dimensions:** D4 (M4.1)

```sql
-- BAD: Table has no RLS but is accessible via Supabase client
CREATE TABLE messages (id uuid PRIMARY KEY, content text, user_id uuid);
-- Missing: ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- GOOD:
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages FORCE ROW LEVEL SECURITY;
```

**Why:** Without RLS, the anon key can read/write all data. Supabase PostgREST exposes all tables via the API.

### AP-3: SELECT * in Supabase Client Queries

**Severity:** MEDIUM
**Dimensions:** D3 (M3.4)

```typescript
// BAD: Fetches all columns including large JSONB blobs
const { data } = await supabase.from('documents').select();
const { data } = await supabase.from('documents').select('*');

// GOOD: Fetch only needed columns
const { data } = await supabase.from('documents').select('id, title, created_at');
```

**Why:** Fetches unnecessary data over the network; prevents Supabase from optimizing the query; larger payloads.

### AP-4: Manual DDL Without Migrations

**Severity:** HIGH
**Dimensions:** D5 (M5.1)

```bash
# BAD: Running SQL directly in Supabase dashboard or via psql
psql $DATABASE_URL -c "ALTER TABLE users ADD COLUMN avatar_url text;"

# GOOD: Use Supabase CLI
supabase migration new add_avatar_url
# Then edit the migration file, then:
supabase db push
```

**Why:** Manual DDL is not tracked, not reproducible, creates drift between environments.

### AP-5: Stale Generated Types

**Severity:** HIGH
**Dimensions:** D9 (M9.1)

```bash
# BAD: Types generated months ago, schema has changed since
# supabase/types.ts was last generated 2025-01-01
# Latest migration is 2025-03-15

# GOOD: Regenerate after every migration
supabase gen types typescript --local > supabase/types.ts
# Or in CI:
supabase gen types typescript --project-id $PROJECT_ID > supabase/types.ts
```

**Why:** Stale types mean TypeScript won't catch column mismatches, missing columns, or type changes.

### AP-6: Service Role Key on Client-Side

**Severity:** CRITICAL
**Dimensions:** D4 (M4.4)

```typescript
// BAD: service_role key in browser/client code
const supabase = createClient(url, process.env.NEXT_PUBLIC_SUPABASE_SERVICE_ROLE_KEY);

// GOOD: anon key on client, service_role only server-side
// Client:
const supabase = createBrowserClient(url, process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY);
// Server:
const supabase = createServerClient(url, process.env.SUPABASE_SERVICE_ROLE_KEY, { ... });
```

**Why:** Service role bypasses ALL RLS. Exposing it on client gives any user full database access.

### AP-7: No FK Constraints (Implicit Relationships)

**Severity:** HIGH
**Dimensions:** D2 (M2.1)

```sql
-- BAD: Column references another table but no FK constraint
CREATE TABLE comments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id uuid, -- no REFERENCES!
  content text
);

-- GOOD:
CREATE TABLE comments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id uuid NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  content text NOT NULL
);
```

**Why:** Without FKs, orphaned records accumulate, joins may silently return no results, data integrity relies entirely on application code.

### AP-8: No Indexes on FK Columns

**Severity:** MEDIUM
**Dimensions:** D3 (M3.1)

```sql
-- BAD: FK exists but no index (PostgreSQL does NOT auto-index FKs)
ALTER TABLE comments ADD CONSTRAINT fk_post FOREIGN KEY (post_id) REFERENCES posts(id);
-- Missing: CREATE INDEX idx_comments_post_id ON comments(post_id);

-- GOOD:
ALTER TABLE comments ADD CONSTRAINT fk_post FOREIGN KEY (post_id) REFERENCES posts(id);
CREATE INDEX idx_comments_post_id ON comments(post_id);
```

**Why:** PostgreSQL does NOT automatically create indexes on FK columns (unlike MySQL). Joins and ON DELETE CASCADE become slow without them.

### AP-9: Storing Files in DB Instead of Supabase Storage

**Severity:** MEDIUM
**Dimensions:** D7 (M7.1)

```sql
-- BAD: Storing file content in database
CREATE TABLE documents (
  id uuid PRIMARY KEY,
  file_content bytea, -- binary data in DB
  file_name text
);

-- GOOD: Store in Supabase Storage, reference in DB
CREATE TABLE documents (
  id uuid PRIMARY KEY,
  storage_path text NOT NULL, -- path in Supabase Storage bucket
  file_name text NOT NULL
);
```

**Why:** Binary data bloats the database, increases backup size, prevents CDN caching, and is slower than object storage.

### AP-10: Not Using Supabase Auth (Custom Auth)

**Severity:** HIGH
**Dimensions:** D6 (M6.1)

```typescript
// BAD: Rolling custom auth when using Supabase
import bcrypt from 'bcrypt';
// Custom login, custom JWT, custom session management...

// GOOD: Use Supabase Auth
const { data, error } = await supabase.auth.signInWithPassword({
  email: 'user@example.com',
  password: 'password',
});
```

**Why:** Custom auth misses RLS integration (auth.uid()), session management, provider support, email verification, rate limiting, and security updates from Supabase.

---

## Best Practices

### BP-1: RLS on Every Table with auth.uid() Check

```sql
-- Minimum viable RLS for any user-data table
ALTER TABLE user_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_data FORCE ROW LEVEL SECURITY;

CREATE POLICY "users manage own data" ON user_data
  FOR ALL USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
```

**Applies to:** D4 (M4.1, M4.2, M4.3)

### BP-2: Generated Types Always Fresh

```bash
# In CI pipeline or pre-commit hook:
supabase gen types typescript --local > src/lib/database.types.ts

# Or with project ID for remote:
supabase gen types typescript --project-id "$SUPABASE_PROJECT_ID" > src/lib/database.types.ts

# Pre-commit hook example (.husky/pre-commit):
supabase gen types typescript --local > src/lib/database.types.ts
git add src/lib/database.types.ts
```

**Applies to:** D9 (M9.1)

### BP-3: Migrations via Supabase CLI

```bash
# Create new migration
supabase migration new add_documents_table

# Diff existing schema changes
supabase db diff --use-migra -f add_documents_table

# Apply locally
supabase db reset

# Push to remote
supabase db push
```

**Applies to:** D5 (M5.1, M5.4)

### BP-4: Typed Supabase Client

```typescript
import { createClient } from '@supabase/supabase-js';
import type { Database } from './database.types';

// Typed client — all queries are type-safe
export const supabase = createClient<Database>(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
);

// Typed query — TypeScript catches column mismatches
const { data } = await supabase
  .from('profiles')
  .select('id, display_name, avatar_url')
  .eq('id', userId)
  .single();
// data is typed as { id: string; display_name: string; avatar_url: string | null }
```

**Applies to:** D9 (M9.2)

### BP-5: Server-Side Client for Mutations

```typescript
// app/actions.ts (Next.js Server Action)
'use server';
import { createServerClient } from '@supabase/ssr';
import { cookies } from 'next/headers';

export async function createDocument(title: string) {
  const cookieStore = await cookies();
  const supabase = createServerClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    { cookies: { getAll: () => cookieStore.getAll() } }
  );

  const { data, error } = await supabase
    .from('documents')
    .insert({ title })
    .select()
    .single();

  return { data, error };
}
```

**Applies to:** D9 (M9.4)

### BP-6: Client-Side Client for Reads Only

```typescript
// lib/supabase-browser.ts
import { createBrowserClient } from '@supabase/ssr';
import type { Database } from './database.types';

export const supabase = createBrowserClient<Database>(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
);

// Use for reads, subscriptions, and auth state
const { data } = await supabase.from('documents').select('id, title');
```

**Applies to:** D9 (M9.4)

### BP-7: Proper FK with Appropriate ON DELETE

```sql
-- Owned entities: CASCADE (delete comments when post is deleted)
post_id uuid NOT NULL REFERENCES posts(id) ON DELETE CASCADE

-- Optional references: SET NULL (keep order if customer is deleted)
customer_id uuid REFERENCES customers(id) ON DELETE SET NULL

-- Critical references: RESTRICT (don't delete department if employees exist)
department_id uuid NOT NULL REFERENCES departments(id) ON DELETE RESTRICT
```

**Applies to:** D2 (M2.2)

### BP-8: Indexes on All FK Columns

```sql
-- After every FK, create an index
ALTER TABLE comments ADD COLUMN post_id uuid REFERENCES posts(id);
CREATE INDEX idx_comments_post_id ON comments(post_id);

-- For composite patterns:
CREATE INDEX idx_comments_user_post ON comments(user_id, post_id);
```

**Applies to:** D3 (M3.1, M3.2)

### BP-9: Storage with Per-User Bucket Paths and RLS

```sql
-- Storage RLS: users can only access their own folder
CREATE POLICY "users access own files" ON storage.objects
  FOR ALL USING (
    bucket_id = 'user-files' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Upload pattern: /user-files/{user_id}/filename.ext
```

```typescript
const { data } = await supabase.storage
  .from('user-files')
  .upload(`${userId}/${fileName}`, file);
```

**Applies to:** D7 (M7.1, M7.2)

### BP-10: Edge Functions for Server-Side Logic

```typescript
// supabase/functions/process-payment/index.ts
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')! // OK here — server-side
  );

  // Process payment logic with third-party API
  // Use secrets: Deno.env.get('STRIPE_SECRET_KEY')

  return new Response(JSON.stringify({ success: true }), {
    headers: { 'Content-Type': 'application/json' },
  });
});
```

```bash
# Set secrets (never hardcode)
supabase secrets set STRIPE_SECRET_KEY=sk_live_...
```

**Applies to:** D8 (M8.3)
