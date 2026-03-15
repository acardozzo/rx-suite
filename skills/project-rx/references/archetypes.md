# Project Archetypes — Detection & Weight Configuration

> Defines the 8 project archetypes recognized by project-rx. Each archetype adjusts dimension
> weights and defines which components are blockers vs N/A. The archetype is detected automatically
> from codebase signals before scoring begins.

---

## Archetype 1: SaaS Web App

**Description**: Multi-tenant web application with user management, subscription billing,
dashboards, and team collaboration. The classic "B2B/B2C software product."

**Detection signals**:
- Billing/payment dependency present (`stripe`, `paddle`, `lemonsqueezy`, `@stripe/stripe-js`)
- Multi-tenant schema (tables with `org_id`, `team_id`, or `tenant_id` foreign keys)
- Subscription/plan tables in database migrations (`subscriptions`, `plans`, `pricing`)
- Dashboard routes (`/dashboard`, `/app`, `/admin`)
- User management routes (`/settings`, `/account`, `/team`, `/invite`)
- Auth library present (`next-auth`, `clerk`, `auth0`, `supabase auth`)
- Email transactional dependency (`resend`, `sendgrid`, `postmark`, `nodemailer`)

**Weight adjustments** (multiply dimension weight by factor):

| Dimension | Default Weight | Adjustment | Effective Weight | Reason |
|-----------|---------------|------------|-----------------|--------|
| D1 Identity & Docs | 10% | 0.8x | 8% | Important but not differentiating |
| D2 Auth & Session | 12% | 1.3x | 15.6% | Multi-tenancy demands robust auth, RBAC, session isolation |
| D3 Data Layer | 12% | 1.1x | 13.2% | Tenant isolation, migrations, and data integrity are critical |
| D4 Business Logic | 12% | 1.5x | 18% | Billing, subscriptions, and workflows ARE the product |
| D5 API & Integration | 10% | 0.9x | 9% | Mostly internal API; webhooks matter for billing |
| D6 UI & UX | 10% | 1.1x | 11% | Dashboard UX directly impacts retention |
| D7 Error & Resilience | 8% | 1.0x | 8% | Standard importance |
| D8 Testing & QA | 8% | 1.0x | 8% | Standard importance |
| D9 DevOps & Infra | 10% | 0.8x | 8% | Standard deployment; not the differentiator |
| D10 Growth & Scale | 8% | 1.0x | 8% | Analytics and monitoring matter for growth |

**Critical components** (Blocker if missing):
- Authentication system (registration, login, sessions)
- Authorization / tenant isolation
- Subscription billing integration
- Core CRUD for primary domain entities
- User settings / account management
- Email transactional (welcome, password reset, billing receipts)
- Database migrations with tenant-aware schema

**N/A components** (score as 100):
- Push notifications (web notifications optional, not core)
- Offline sync (SaaS assumes connectivity)
- SDK / client library publishing
- CLI interface

---

## Archetype 2: API Platform

**Description**: Developer-facing API product with authentication via API keys, rate limiting,
usage metering, developer portal, SDK, and comprehensive documentation. Revenue from API usage.

**Detection signals**:
- API key management code (generation, storage, validation, rotation)
- Rate limiting middleware (`express-rate-limit`, `@upstash/ratelimit`, custom token bucket)
- API versioning in routes (`/v1/`, `/v2/`, version headers)
- OpenAPI/Swagger specification files (`openapi.yaml`, `swagger.json`)
- SDK or client library in repository (`/sdk`, `/packages/client`, `/clients`)
- Usage metering / billing per-call (`usage`, `metering`, `credits`, `quota`)
- Developer portal or docs site (`/docs`, `/developer`, Mintlify, ReadMe)
- API key tables in database (`api_keys`, `tokens`, `credentials`)

**Weight adjustments**:

| Dimension | Default Weight | Adjustment | Effective Weight | Reason |
|-----------|---------------|------------|-----------------|--------|
| D1 Identity & Docs | 10% | 1.5x | 15% | API docs ARE the product experience; developers judge by docs |
| D2 Auth & Session | 12% | 1.2x | 14.4% | API key auth, OAuth for third parties, scoped permissions |
| D3 Data Layer | 12% | 0.9x | 10.8% | Important but simpler than multi-tenant SaaS |
| D4 Business Logic | 12% | 1.3x | 15.6% | Usage metering, rate limiting, quota enforcement are core |
| D5 API & Integration | 10% | 2.0x | 20% | The API IS the product. Design, versioning, errors = everything |
| D6 UI & UX | 10% | 0.4x | 4% | Minimal UI — developer portal and dashboard only |
| D7 Error & Resilience | 8% | 1.2x | 9.6% | API consumers need consistent, informative error responses |
| D8 Testing & QA | 8% | 1.0x | 8% | Standard importance |
| D9 DevOps & Infra | 10% | 1.0x | 10% | Uptime is critical for API platform |
| D10 Growth & Scale | 8% | 0.8x | 6.4% | Developer adoption > traditional growth metrics |

**Critical components** (Blocker if missing):
- API key management (generation, validation, revocation)
- Rate limiting / throttling
- API versioning strategy
- Comprehensive API documentation (OpenAPI spec)
- Consistent error response format
- Usage metering / logging
- Authentication (API key + OAuth)
- Health check endpoint

**N/A components** (score as 100):
- Complex UI/UX flows (no end-user dashboard needed)
- Onboarding wizard (developer quickstart guide instead)
- Push notifications
- Offline sync
- Social OAuth for end users (API key auth instead)

---

## Archetype 3: Marketplace

**Description**: Two-sided platform connecting buyers and sellers (or providers and consumers).
Payments/escrow, reviews/ratings, search/discovery, matching algorithms, and trust systems.

**Detection signals**:
- Two distinct user types in schema (`buyers`/`sellers`, `providers`/`consumers`, `hosts`/`guests`)
- Payment splitting / escrow (`stripe connect`, `paypal marketplace`, escrow tables)
- Reviews/ratings tables (`reviews`, `ratings`, `feedback`, star-based scoring)
- Search/filtering with multiple facets (location, price, category, availability)
- Listing/product creation by sellers (not admin-only catalog)
- Messaging between parties (`messages`, `conversations`, `chat`)
- Trust/verification system (`verified`, `identity_check`, `background_check`)
- Commission/fee calculation logic

**Weight adjustments**:

| Dimension | Default Weight | Adjustment | Effective Weight | Reason |
|-----------|---------------|------------|-----------------|--------|
| D1 Identity & Docs | 10% | 0.7x | 7% | Less critical; marketplace is self-explanatory |
| D2 Auth & Session | 12% | 1.2x | 14.4% | Dual user types, verification, trust |
| D3 Data Layer | 12% | 1.2x | 14.4% | Complex relational model — listings, orders, reviews, messages |
| D4 Business Logic | 12% | 1.5x | 18% | Matching, escrow, commission, dispute resolution ARE the product |
| D5 API & Integration | 10% | 0.9x | 9% | Internal API; payment gateway integration matters |
| D6 UI & UX | 10% | 1.5x | 15% | Search, browsing, booking UX = conversion rate |
| D7 Error & Resilience | 8% | 1.0x | 8% | Standard; payment error handling critical |
| D8 Testing & QA | 8% | 0.8x | 6.4% | Important but not the differentiator |
| D9 DevOps & Infra | 10% | 0.8x | 8% | Standard deployment |
| D10 Growth & Scale | 8% | 1.2x | 9.6% | Network effects, SEO, referrals drive marketplace growth |

**Critical components** (Blocker if missing):
- Dual user type registration and profiles
- Listing/service creation and management
- Search and discovery with filters
- Payment processing with seller payouts
- Order/booking management
- Reviews and ratings system
- Messaging between parties
- Basic dispute resolution flow

**N/A components** (score as 100):
- API key management (not a developer product)
- SDK publishing
- CLI interface
- Subscription billing (transaction-based instead)
- Feature flags (useful but not critical for MVP)

---

## Archetype 4: Internal Tool

**Description**: Enterprise internal application for employees or specific departments. SSO/LDAP
integration, role-based access, audit logging, data export, dashboards, and workflow automation.
Not public-facing.

**Detection signals**:
- SSO/LDAP/SAML integration (`saml`, `ldap`, `okta`, `azure-ad`, `@auth0/nextjs-auth0`)
- Audit log tables (`audit_logs`, `activity_log`, event sourcing patterns)
- Data export functionality (CSV, Excel, PDF export routes or utilities)
- Admin-heavy UI (tables, forms, bulk actions, no marketing pages)
- RBAC with multiple granular roles (`admin`, `manager`, `viewer`, `analyst`)
- No public signup — invite-only or SSO-only flow
- Dashboard/reporting focus (charts, KPIs, data visualization)
- Internal domain naming (intranet references, internal service URLs)

**Weight adjustments**:

| Dimension | Default Weight | Adjustment | Effective Weight | Reason |
|-----------|---------------|------------|-----------------|--------|
| D1 Identity & Docs | 10% | 0.6x | 6% | Internal tool; minimal public docs needed |
| D2 Auth & Session | 12% | 1.5x | 18% | SSO, RBAC, audit = core enterprise requirements |
| D3 Data Layer | 12% | 1.2x | 14.4% | Data integrity, exports, reporting queries are central |
| D4 Business Logic | 12% | 1.0x | 12% | Workflow automation, approvals, business rules |
| D5 API & Integration | 10% | 1.0x | 10% | Internal API + integration with enterprise systems |
| D6 UI & UX | 10% | 1.0x | 10% | Productivity UX — data tables, forms, bulk actions |
| D7 Error & Resilience | 8% | 1.0x | 8% | Standard importance |
| D8 Testing & QA | 8% | 1.0x | 8% | Standard importance |
| D9 DevOps & Infra | 10% | 1.0x | 10% | On-prem or VPN deployment may add complexity |
| D10 Growth & Scale | 8% | 0.5x | 4% | No public growth; fixed user base |

**Critical components** (Blocker if missing):
- SSO / LDAP integration (enterprise auth)
- Role-based access control (granular permissions)
- Audit logging (who did what, when)
- Data tables with sort/filter/pagination
- Data export (CSV minimum, Excel preferred)
- Form-based CRUD operations
- Basic dashboard with KPIs

**N/A components** (score as 100):
- Public marketing pages / landing page
- SEO optimization
- Social OAuth (SSO instead)
- Subscription billing (internal tool = no billing)
- Public API documentation
- Push notifications
- Analytics / growth tracking (fixed user base)
- Onboarding wizard (training replaces self-serve onboarding)

---

## Archetype 5: Mobile Backend

**Description**: Backend service powering mobile applications. Push notifications, device management,
offline sync, media upload/processing, and mobile-optimized API responses. May also serve a
companion web app.

**Detection signals**:
- Push notification dependencies (`firebase-admin`, `@parse/node-apn`, `expo-server-sdk`, `onesignal`)
- Device registration tables (`devices`, `push_tokens`, `device_id` columns)
- Media upload/processing (`multer`, `sharp`, `@aws-sdk/client-s3`, image resize logic)
- Offline sync patterns (conflict resolution, `last_modified` timestamps, version vectors)
- Mobile-optimized API (pagination cursors, sparse fieldsets, compressed responses)
- Deep link / universal link configuration
- App version management / force-update logic
- React Native, Flutter, or Swift/Kotlin companion code in monorepo

**Weight adjustments**:

| Dimension | Default Weight | Adjustment | Effective Weight | Reason |
|-----------|---------------|------------|-----------------|--------|
| D1 Identity & Docs | 10% | 0.7x | 7% | API docs for mobile team; less public-facing |
| D2 Auth & Session | 12% | 1.2x | 14.4% | Token refresh, device-bound sessions, biometric support |
| D3 Data Layer | 12% | 1.3x | 15.6% | Offline sync, conflict resolution, media storage |
| D4 Business Logic | 12% | 1.0x | 12% | Standard business logic |
| D5 API & Integration | 10% | 1.5x | 15% | Mobile API design is critical — latency, payloads, versioning |
| D6 UI & UX | 10% | 0.3x | 3% | Backend only; UI is in mobile app |
| D7 Error & Resilience | 8% | 1.3x | 10.4% | Mobile networks are unreliable; backend must be resilient |
| D8 Testing & QA | 8% | 1.0x | 8% | Standard importance |
| D9 DevOps & Infra | 10% | 1.0x | 10% | CDN for media, auto-scaling for traffic spikes |
| D10 Growth & Scale | 8% | 0.8x | 6.4% | Push notifications handle re-engagement |

**Critical components** (Blocker if missing):
- Push notification system (FCM/APNs)
- Device registration and management
- Token-based auth with refresh flow
- Media upload and processing pipeline
- Paginated API responses (cursor-based)
- Offline-aware data sync strategy
- API versioning (mobile apps can't force-update instantly)
- Health check and status endpoint

**N/A components** (score as 100):
- Complex web UI/UX (backend only)
- Marketing/landing pages
- Server-side rendering
- CSS/styling system
- Web-specific analytics (mobile analytics via SDK instead)

---

## Archetype 6: AI Product

**Description**: Product built around AI/LLM capabilities. Prompt management, model evaluation,
usage metering, streaming responses, and intelligent features. May be a standalone AI tool or
AI-enhanced SaaS.

**Detection signals**:
- LLM SDK dependency (`openai`, `anthropic`, `@ai-sdk/core`, `langchain`, `llama-index`)
- Prompt templates or management (`/prompts`, prompt versioning, template strings with variables)
- Evaluation/benchmarking code (`evals`, `benchmarks`, scoring functions, judge prompts)
- Streaming response handling (SSE, `ReadableStream`, `TextDecoder`, streaming chat UI)
- Token/usage counting or metering (`tokens`, `usage`, `credits`, cost tracking)
- Vector database / embeddings (`pgvector`, `pinecone`, `weaviate`, `chromadb`, embedding generation)
- RAG pipeline (document ingestion, chunking, retrieval, context assembly)
- Model configuration (model selection, temperature, max_tokens in config)

**Weight adjustments**:

| Dimension | Default Weight | Adjustment | Effective Weight | Reason |
|-----------|---------------|------------|-----------------|--------|
| D1 Identity & Docs | 10% | 0.8x | 8% | Important for explaining AI capabilities and limitations |
| D2 Auth & Session | 12% | 1.0x | 12% | Standard auth; usage limits tied to user identity |
| D3 Data Layer | 12% | 1.3x | 15.6% | Vector stores, embeddings, conversation history, knowledge bases |
| D4 Business Logic | 12% | 1.5x | 18% | Prompt engineering, RAG pipelines, evals, usage metering ARE the product |
| D5 API & Integration | 10% | 1.2x | 12% | Streaming API, LLM provider integration, webhook for async |
| D6 UI & UX | 10% | 1.0x | 10% | Chat UI, streaming display, prompt playground |
| D7 Error & Resilience | 8% | 1.3x | 10.4% | LLM APIs are flaky; fallbacks, retries, timeout handling critical |
| D8 Testing & QA | 8% | 0.8x | 6.4% | Non-deterministic outputs make traditional testing harder |
| D9 DevOps & Infra | 10% | 0.7x | 7% | Standard deployment; GPU not usually self-hosted |
| D10 Growth & Scale | 8% | 0.8x | 6.4% | Usage-based growth; cost management matters more |

**Critical components** (Blocker if missing):
- LLM provider integration with proper error handling
- Prompt management (templates, versioning, or at minimum centralized prompts)
- Streaming response handling (SSE or WebSocket)
- Usage tracking / token metering
- Conversation history storage
- Rate limiting / cost controls (prevent runaway API costs)
- Model fallback strategy (primary model down -> fallback model)
- Input validation / prompt injection prevention

**N/A components** (score as 100):
- Traditional subscription billing (usage-based instead, or combined)
- Push notifications
- Offline sync
- Complex RBAC (unless enterprise AI product)
- SEO (unless content-generation product)

---

## Archetype 7: CLI Tool

**Description**: Command-line interface tool distributed via npm/brew/cargo. Commands, arguments,
configuration, output formatting, plugins, and shell integration. No web UI, no server,
no database (typically).

**Detection signals**:
- CLI framework dependency (`commander`, `yargs`, `oclif`, `clap`, `cobra`, `inquirer`)
- Binary/entry point in package.json `bin` field
- Command pattern files (`/commands`, `/cmd`, command registration)
- Help text / usage strings in code
- Terminal output formatting (`chalk`, `ora`, `boxen`, `cli-table`, ANSI codes)
- Configuration file handling (`.foorc`, `foo.config.js`, XDG config paths)
- Shell completion scripts
- No web framework dependency (no `express`, `next`, `react`)

**Weight adjustments**:

| Dimension | Default Weight | Adjustment | Effective Weight | Reason |
|-----------|---------------|------------|-----------------|--------|
| D1 Identity & Docs | 10% | 1.5x | 15% | README with usage examples IS the docs; `--help` quality matters |
| D2 Auth & Session | 12% | 0.2x | 2.4% | Minimal; maybe API key storage in config file |
| D3 Data Layer | 12% | 0.3x | 3.6% | Local config/cache at most; no database |
| D4 Business Logic | 12% | 1.5x | 18% | Commands, argument parsing, business logic = the product |
| D5 API & Integration | 10% | 0.8x | 8% | May call external APIs; no server to expose |
| D6 UI & UX | 10% | 1.3x | 13% | Terminal UX: colors, progress bars, tables, interactive prompts |
| D7 Error & Resilience | 8% | 1.2x | 9.6% | Helpful error messages, graceful failures, exit codes |
| D8 Testing & QA | 8% | 1.3x | 10.4% | CLI testing is critical — command output, exit codes, edge cases |
| D9 DevOps & Infra | 10% | 1.2x | 12% | Publishing, versioning, cross-platform builds, installation |
| D10 Growth & Scale | 8% | 0.5x | 4% | Adoption via package managers; no traditional growth |

**Critical components** (Blocker if missing):
- Command structure with subcommands
- Argument and flag parsing with validation
- Help text (`--help`) for every command
- Version flag (`--version`)
- Configuration file support
- Meaningful exit codes (0 = success, 1 = error, 2 = usage error)
- Error messages with actionable guidance
- Output formatting (human-readable default, `--json` for scripting)

**N/A components** (score as 100):
- Web UI / frontend components
- Authentication system (web-based)
- Database / migrations
- Server / API routes
- Session management
- Push notifications
- SEO / marketing pages
- Billing / subscriptions
- Monitoring / APM (package download stats instead)

---

## Archetype 8: Library / Package

**Description**: Reusable code library or package published to a registry (npm, PyPI, crates.io).
Clean exports, TypeScript types, comprehensive docs, examples, and publishing automation.
No server, no UI, no database.

**Detection signals**:
- Library-style exports in package.json (`main`, `module`, `exports`, `types` fields)
- Build configuration for library output (`tsup`, `rollup`, `esbuild`, `tsc` with declaration)
- No web framework dependency (no `next`, `express`, `react` as dependency — may be peerDep)
- TypeScript declaration generation (`declaration: true`, `.d.ts` output)
- `/examples` or `/playground` directory
- Published to registry (npmjs.com link, `publishConfig` in package.json)
- Peer dependencies (consumer provides the framework)
- Extensive JSDoc / TSDoc comments on exports
- `prepublishOnly` or `prepack` scripts

**Weight adjustments**:

| Dimension | Default Weight | Adjustment | Effective Weight | Reason |
|-----------|---------------|------------|-----------------|--------|
| D1 Identity & Docs | 10% | 2.0x | 20% | Documentation IS the product for a library. API docs, examples, README |
| D2 Auth & Session | 12% | 0.0x | 0% | Libraries don't have auth |
| D3 Data Layer | 12% | 0.0x | 0% | Libraries don't have databases |
| D4 Business Logic | 12% | 1.5x | 18% | Exports, API surface, type safety = the product |
| D5 API & Integration | 10% | 1.3x | 13% | Public API design, backwards compatibility, semver |
| D6 UI & UX | 10% | 0.0x | 0% | No UI (unless it's a UI component library — then 1.5x) |
| D7 Error & Resilience | 8% | 1.0x | 8% | Error types, validation, graceful degradation |
| D8 Testing & QA | 8% | 2.0x | 16% | Testing is CRITICAL for libraries — consumers depend on correctness |
| D9 DevOps & Infra | 10% | 1.5x | 15% | Publishing automation, CI, cross-platform builds, bundling |
| D10 Growth & Scale | 8% | 0.5x | 4% | Downloads, npm stats; not traditional growth |

**Critical components** (Blocker if missing):
- Clean, well-typed exports (index.ts with explicit public API)
- TypeScript declarations (.d.ts files generated)
- Comprehensive README with installation, usage, and API reference
- Unit tests with high coverage (>80%)
- Package.json metadata (name, version, description, keywords, license, repository)
- LICENSE file
- Build pipeline producing ESM + CJS outputs
- CHANGELOG with version history
- Examples (at least 3 usage examples)

**N/A components** (score as 100):
- Authentication / sessions
- Database / migrations
- Server / API routes
- Web UI / frontend
- Push notifications
- Billing / subscriptions
- Monitoring / APM
- Admin panel
- Email / transactional messaging
- Search / discovery

---

## Archetype Detection Algorithm

### Step 1: Signal Collection

Scan the codebase for signals from ALL 8 archetypes. Count matches per archetype.

```
signals = {
  "SaaS Web App": 0,
  "API Platform": 0,
  "Marketplace": 0,
  "Internal Tool": 0,
  "Mobile Backend": 0,
  "AI Product": 0,
  "CLI Tool": 0,
  "Library/Package": 0
}

For each signal detected, increment the matching archetype counter.
```

### Step 2: Confidence Scoring

| Signal Count | Confidence |
|-------------|------------|
| >= 4 signals | HIGH |
| 2-3 signals | MEDIUM |
| 1 signal | LOW |
| 0 signals | UNKNOWN — default to SaaS Web App |

### Step 3: Conflict Resolution

If two archetypes have similar signal counts:
1. **Hybrid detection**: Some projects are combinations (e.g., "AI-enhanced SaaS"). Use the primary archetype's weights but add blocker components from the secondary.
2. **Prefer specificity**: If "SaaS Web App" and "AI Product" both match, prefer "AI Product" (more specific weight adjustments).
3. **Check exclusion signals**: CLI Tool and Library/Package exclude each other from web archetypes (no `next`, `express`, `react` as dependency).

### Step 4: Weight Normalization

After selecting an archetype and applying weight adjustments:
1. Multiply each dimension's default weight by the adjustment factor.
2. Sum all effective weights.
3. Normalize: `final_weight = effective_weight / sum_of_all_effective_weights * 100%`
4. Final weights MUST sum to exactly 100%.

### Step 5: N/A Handling

For components marked N/A by the archetype:
1. Score the sub-metric as 100 (full marks).
2. Note it as "N/A — not applicable for [archetype]" in the evidence column.
3. This prevents penalizing a CLI tool for not having a database.

---

## Quick Reference: Archetype Comparison Matrix

| Dimension | SaaS | API Platform | Marketplace | Internal | Mobile BE | AI Product | CLI | Library |
|-----------|------|-------------|-------------|----------|-----------|-----------|-----|---------|
| D1 Docs | 0.8x | 1.5x | 0.7x | 0.6x | 0.7x | 0.8x | 1.5x | 2.0x |
| D2 Auth | 1.3x | 1.2x | 1.2x | 1.5x | 1.2x | 1.0x | 0.2x | 0.0x |
| D3 Data | 1.1x | 0.9x | 1.2x | 1.2x | 1.3x | 1.3x | 0.3x | 0.0x |
| D4 Business | 1.5x | 1.3x | 1.5x | 1.0x | 1.0x | 1.5x | 1.5x | 1.5x |
| D5 API | 0.9x | 2.0x | 0.9x | 1.0x | 1.5x | 1.2x | 0.8x | 1.3x |
| D6 UI/UX | 1.1x | 0.4x | 1.5x | 1.0x | 0.3x | 1.0x | 1.3x | 0.0x |
| D7 Errors | 1.0x | 1.2x | 1.0x | 1.0x | 1.3x | 1.3x | 1.2x | 1.0x |
| D8 Testing | 1.0x | 1.0x | 0.8x | 1.0x | 1.0x | 0.8x | 1.3x | 2.0x |
| D9 DevOps | 0.8x | 1.0x | 0.8x | 1.0x | 1.0x | 0.7x | 1.2x | 1.5x |
| D10 Growth | 1.0x | 0.8x | 1.2x | 0.5x | 0.8x | 0.8x | 0.5x | 0.5x |

> Use this matrix for quick weight lookup. Detailed reasoning is in each archetype section above.
