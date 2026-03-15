---
name: project-rx
description: Project completeness inspector — identifies missing components, capabilities, and infrastructure for your project type. Detects project archetype (SaaS, API Platform, Marketplace, Internal Tool, Mobile Backend, AI Product, CLI, Library) and evaluates against a mandatory component checklist. Use when starting a project, planning features, doing gap analysis, or when the user says "what's missing", "run project-rx", "project audit", "completeness check", "gap analysis", "what should I build next", or "inspect project". Produces a completeness scorecard with prioritized build plan.
---

# project-rx — Project Completeness Inspector

> "What does this project NEED but DOESN'T HAVE?"

While other rx skills grade the **quality** of what exists, project-rx identifies what's **MISSING** — like a building inspector checking if a house has all required components.

---

## How It Works

1. **Detect** the project archetype from codebase signals
2. **Load** archetype-specific weight adjustments
3. **Scan** for presence/absence of each component across 40 sub-metrics
4. **Score** each sub-metric on presence + maturity (0 / 40 / 70 / 85 / 100)
5. **Generate** a completeness scorecard + prioritized build plan for missing pieces

---

## Phase 1: Archetype Detection

Detect the project type by examining codebase signals. Assign exactly ONE primary archetype and optionally ONE secondary archetype.

### The 8 Archetypes

| # | Archetype | Key Signals |
|---|-----------|-------------|
| A1 | **SaaS** | Subscription logic, tenant isolation, billing integration, dashboard UI, pricing page |
| A2 | **API Platform** | OpenAPI/Swagger, API key management, rate limiting, developer docs, SDK generation |
| A3 | **Marketplace** | Buyer/seller roles, listings, transactions, reviews, escrow/payment splits |
| A4 | **Internal Tool** | Admin panels, internal auth (SSO/LDAP), data tables, forms, reports, no public marketing |
| A5 | **Mobile Backend** | Push notification config, mobile-specific APIs, device tokens, app store references |
| A6 | **AI Product** | LLM/ML imports, embeddings, vector DB, prompt templates, model config, inference endpoints |
| A7 | **CLI Tool** | CLI framework (commander/yargs/clap/cobra), no HTTP server, args parsing, terminal output |
| A8 | **Library/Package** | Exports-focused, no app entry point, published to registry, README-centric, minimal deps |

### Detection Script

Run these checks in parallel to classify the project:

```
1. Read package.json / Cargo.toml / pyproject.toml / go.mod for dependency signals
2. Scan for route definitions (pages/, routes/, controllers/)
3. Check for DB schema files (migrations/, prisma/, drizzle/, schema.sql)
4. Look for billing/payment code (stripe, paddle, billing, subscription)
5. Check for auth setup (auth/, login, signup, next-auth, clerk, supabase auth)
6. Look for API documentation (swagger, openapi, redoc)
7. Check for CLI entry points (bin/, cli.ts, main.rs with clap)
8. Scan for ML/AI imports (openai, langchain, transformers, embeddings)
9. Check for marketplace signals (listing, seller, buyer, review, cart)
10. Check for mobile signals (expo, react-native, push notification, FCM, APNs)
```

Assign the archetype with the strongest signal match. If ambiguous, default to **SaaS** (most common).

---

## Phase 2: Dimension Weight Adjustments

Each archetype adjusts the base weights. See `references/grading-framework.md` for the full adjustment tables.

### Base Weights (all archetypes start here)

| Dimension | Base Weight |
|-----------|-------------|
| D1: Identity & Access | 12% |
| D2: Data & Storage | 10% |
| D3: Communication & Notifications | 10% |
| D4: Business Logic & Domain | 12% |
| D5: API & Integration | 10% |
| D6: Reliability & Operations | 10% |
| D7: Security & Compliance | 10% |
| D8: Developer Experience & CI/CD | 8% |
| D9: User Experience Infrastructure | 10% |
| D10: Growth & Analytics | 8% |

---

## Phase 3: Discovery & Scanning

Deploy **5 parallel agents** to scan the codebase:

### Agent Assignments

| Agent | Dimensions | What to Scan |
|-------|-----------|--------------|
| **Agent 1: Identity & Security** | D1 + D7 | Auth files, middleware, guards, policies, session config, security headers, secrets management, audit logging |
| **Agent 2: Data & Communication** | D2 + D3 | Database config, migrations, models, cache config, search setup, email templates, WebSocket handlers, push config, webhooks |
| **Agent 3: Business & API** | D4 + D5 | Domain models, business rules, tenant logic, billing/payment code, API routes, API docs, integrations, API keys |
| **Agent 4: Ops & DX** | D6 + D8 | Health checks, monitoring config, error tracking setup, logging config, CI/CD files, dev scripts, linters, documentation |
| **Agent 5: UX & Growth** | D9 + D10 | Error pages, loading states, responsive setup, onboarding flows, analytics setup, feature flags, export/import, admin panels |

### What Each Agent Does

For every sub-metric in their assigned dimensions:

1. **Search** for the component using file patterns, imports, config, and code patterns
2. **Classify** presence level:
   - `NOT_PRESENT (0)` — No evidence whatsoever
   - `MINIMAL (40)` — Placeholder, stub, or extremely partial
   - `BASIC (70)` — Works for MVP, missing advanced features
   - `PRODUCTION (85)` — Solid, covers main use cases
   - `WORLD_CLASS (100)` — Fully featured, best-in-class
3. **Document** evidence (file paths, code snippets, config entries)
4. **Note** any archetype-specific adjustments (e.g., billing is N/A for a Library)

### Discovery Patterns Per Sub-Metric

Each agent uses these search patterns (non-exhaustive):

**D1: Identity & Access**
- M1.1 Auth: `auth/`, `login`, `signup`, `next-auth`, `clerk`, `supabase.auth`, `passport`, `@auth/*`
- M1.2 RBAC: `roles`, `permissions`, `guards`, `policies`, `can()`, `authorize`, `middleware/auth`
- M1.3 Sessions: `session`, `token`, `refresh`, `jwt`, `cookie`, `revoke`, `device`
- M1.4 User mgmt: `users/`, `profile`, `avatar`, `invite`, `disable`, `user.create`, `user.update`

**D2: Data & Storage**
- M2.1 Data store: `prisma/`, `drizzle/`, `migrations/`, `schema.sql`, `mongoose`, `typeorm`, `knex`
- M2.2 File storage: `upload`, `s3`, `storage`, `multer`, `sharp`, `cloudinary`, `CDN`
- M2.3 Caching: `redis`, `cache`, `memcached`, `lru-cache`, `unstable_cache`, `revalidate`
- M2.4 Search: `elasticsearch`, `algolia`, `meilisearch`, `typesense`, `full-text`, `search index`

**D3: Communication & Notifications**
- M3.1 Email: `email/`, `mailer`, `sendgrid`, `resend`, `postmark`, `ses`, `email template`
- M3.2 Real-time: `websocket`, `socket.io`, `pusher`, `ably`, `SSE`, `EventSource`, `realtime`
- M3.3 Push: `push notification`, `FCM`, `APNs`, `web-push`, `service-worker`, `notification preferences`
- M3.4 Webhooks: `webhook`, `event delivery`, `webhook.send`, `hmac`, `webhook dashboard`

**D4: Business Logic & Domain**
- M4.1 Domain model: `entities/`, `models/`, `domain/`, `aggregates`, `value-objects`
- M4.2 Business rules: `rules/`, `validators/`, `workflows/`, `state-machine`, `xstate`
- M4.3 Multi-tenancy: `tenant`, `organization`, `workspace`, `team`, `org_id`, `tenant_id`
- M4.4 Billing: `stripe`, `billing`, `subscription`, `plan`, `invoice`, `payment`, `metering`

**D5: API & Integration**
- M5.1 API layer: `routes/`, `controllers/`, `api/`, `trpc`, `graphql`, `grpc`, `versioning`
- M5.2 API docs: `swagger`, `openapi`, `redoc`, `api-docs`, `spec.yaml`, `spec.json`
- M5.3 Integrations: `integrations/`, `oauth`, `providers/`, `connectors/`, third-party SDKs
- M5.4 API keys: `api-key`, `developer portal`, `key management`, `usage tracking`, `rate limit`

**D6: Reliability & Operations**
- M6.1 Health checks: `health`, `readiness`, `liveness`, `/healthz`, `/ready`, `ping`
- M6.2 Monitoring: `prometheus`, `datadog`, `grafana`, `metrics`, `dashboard`, `alert`
- M6.3 Error tracking: `sentry`, `bugsnag`, `error boundary`, `source map`, `error reporting`
- M6.4 Logging: `winston`, `pino`, `bunyan`, `structured log`, `correlation-id`, `log level`

**D7: Security & Compliance**
- M7.1 Input validation: `zod`, `joi`, `yup`, `class-validator`, `ajv`, `sanitize`, `schema validation`
- M7.2 Security headers: `helmet`, `CSP`, `CORS`, `HSTS`, `X-Frame`, `security headers`
- M7.3 Secrets mgmt: `.env`, `vault`, `infisical`, `doppler`, `aws secretsmanager`, `.env.example`
- M7.4 Audit trail: `audit`, `activity log`, `who-what-when`, `changelog`, `event sourcing`

**D8: Developer Experience & CI/CD**
- M8.1 CI/CD: `.github/workflows/`, `Jenkinsfile`, `.gitlab-ci.yml`, `Dockerfile`, `deploy`
- M8.2 Dev setup: `docker-compose`, `Makefile`, `dev script`, `seed`, `.nvmrc`, `dev.sh`
- M8.3 Code quality: `eslint`, `prettier`, `biome`, `husky`, `lint-staged`, `tsconfig`, `type-check`
- M8.4 Documentation: `README.md`, `docs/`, `ADR`, `ARCHITECTURE.md`, `CONTRIBUTING.md`

**D9: User Experience Infrastructure**
- M9.1 Error states: `404`, `500`, `error.tsx`, `not-found.tsx`, `empty-state`, `fallback`
- M9.2 Loading & feedback: `loading.tsx`, `Skeleton`, `toast`, `progress`, `spinner`, `Suspense`
- M9.3 Responsive & a11y: `@media`, `sm:`, `md:`, `aria-`, `role=`, `sr-only`, `keyboard`
- M9.4 Onboarding: `onboarding`, `welcome`, `getting-started`, `setup wizard`, `tour`, `tooltip`

**D10: Growth & Analytics**
- M10.1 Analytics: `analytics`, `posthog`, `mixpanel`, `amplitude`, `gtag`, `segment`, `track(`
- M10.2 Feature flags: `feature flag`, `launchdarkly`, `flagsmith`, `unleash`, `growthbook`, `flag`
- M10.3 Data export: `export`, `import`, `CSV`, `download`, `data portability`, `GDPR`
- M10.4 Admin panel: `admin/`, `back-office`, `dashboard/admin`, `manage users`, `admin route`

---

## Phase 4: Scoring

### Scoring Scale (Presence + Maturity)

Unlike other rx skills that measure quality, project-rx measures existence and completeness:

| Score | Level | Meaning |
|-------|-------|---------|
| **100** | World-class | Fully featured, best-in-class, nothing missing |
| **85** | Production-ready | Solid implementation, covers main use cases |
| **70** | Basic / MVP | Works, but missing advanced features |
| **40** | Minimal | Placeholder, stub, or extremely partial |
| **0** | Not present | No evidence of this component |

### Dimension Score Calculation

Each dimension has 4 sub-metrics, equally weighted (25% each within the dimension):

```
dimension_score = (M_x.1 + M_x.2 + M_x.3 + M_x.4) / 4
```

### Overall Score

```
overall_score = sum(dimension_score_i * archetype_weight_i) for i in 1..10
```

### Grade Scale

| Grade | Range | Meaning |
|-------|-------|---------|
| A+ | 97-100 | Exemplary completeness |
| A  | 93-96  | Excellent completeness |
| A- | 90-92  | Very strong |
| B+ | 87-89  | Strong |
| B  | 83-86  | Good completeness |
| B- | 80-82  | Above average |
| C+ | 77-79  | Fair |
| C  | 73-76  | Adequate for early stage |
| C- | 70-72  | Below expectations |
| D+ | 67-69  | Significant gaps |
| D  | 63-66  | Many missing components |
| D- | 60-62  | Barely functional |
| F  | 0-59   | Critical completeness failures |

---

## Phase 5: Output — The Completeness Scorecard

### Scorecard Format

```
================================================================
  PROJECT-RX COMPLETENESS SCORECARD
  Project: {project_name}
  Archetype: {detected_archetype} ({confidence}%)
  Date: {date}
================================================================

  OVERALL SCORE: {score}/100 ({grade})

  ┌─────────────────────────────────────────┬───────┬───────┐
  │ Dimension                               │ Score │ Grade │
  ├─────────────────────────────────────────┼───────┼───────┤
  │ D1: Identity & Access ({weight}%)       │ {s}   │ {g}   │
  │   M1.1 Authentication                  │ {s}   │       │
  │   M1.2 Authorization / RBAC            │ {s}   │       │
  │   M1.3 Session Management              │ {s}   │       │
  │   M1.4 User Management                 │ {s}   │       │
  ├─────────────────────────────────────────┼───────┼───────┤
  │ D2: Data & Storage ({weight}%)          │ {s}   │ {g}   │
  │   M2.1 Primary Data Store              │ {s}   │       │
  │   M2.2 File/Media Storage              │ {s}   │       │
  │   M2.3 Caching Layer                   │ {s}   │       │
  │   M2.4 Search Capability               │ {s}   │       │
  ├─────────────────────────────────────────┼───────┼───────┤
  │ D3: Communication ({weight}%)           │ {s}   │ {g}   │
  │   M3.1 Email System                    │ {s}   │       │
  │   M3.2 Real-time Updates               │ {s}   │       │
  │   M3.3 Push Notifications              │ {s}   │       │
  │   M3.4 Webhook Outbound                │ {s}   │       │
  ├─────────────────────────────────────────┼───────┼───────┤
  │ D4: Business Logic ({weight}%)          │ {s}   │ {g}   │
  │   M4.1 Core Domain Model               │ {s}   │       │
  │   M4.2 Business Rules Engine           │ {s}   │       │
  │   M4.3 Multi-tenancy                   │ {s}   │       │
  │   M4.4 Billing & Subscription          │ {s}   │       │
  ├─────────────────────────────────────────┼───────┼───────┤
  │ D5: API & Integration ({weight}%)       │ {s}   │ {g}   │
  │   M5.1 API Layer                       │ {s}   │       │
  │   M5.2 API Documentation               │ {s}   │       │
  │   M5.3 Third-party Integrations        │ {s}   │       │
  │   M5.4 API Keys & Developer Portal     │ {s}   │       │
  ├─────────────────────────────────────────┼───────┼───────┤
  │ D6: Reliability & Ops ({weight}%)       │ {s}   │ {g}   │
  │   M6.1 Health Checks                   │ {s}   │       │
  │   M6.2 Monitoring & Alerting           │ {s}   │       │
  │   M6.3 Error Tracking                  │ {s}   │       │
  │   M6.4 Logging                         │ {s}   │       │
  ├─────────────────────────────────────────┼───────┼───────┤
  │ D7: Security & Compliance ({weight}%)   │ {s}   │ {g}   │
  │   M7.1 Input Validation                │ {s}   │       │
  │   M7.2 Security Headers                │ {s}   │       │
  │   M7.3 Secrets Management              │ {s}   │       │
  │   M7.4 Audit Trail                     │ {s}   │       │
  ├─────────────────────────────────────────┼───────┼───────┤
  │ D8: Developer Experience ({weight}%)    │ {s}   │ {g}   │
  │   M8.1 CI/CD Pipeline                  │ {s}   │       │
  │   M8.2 Development Setup               │ {s}   │       │
  │   M8.3 Code Quality Tooling            │ {s}   │       │
  │   M8.4 Documentation                   │ {s}   │       │
  ├─────────────────────────────────────────┼───────┼───────┤
  │ D9: UX Infrastructure ({weight}%)       │ {s}   │ {g}   │
  │   M9.1 Error & Empty States            │ {s}   │       │
  │   M9.2 Loading & Feedback              │ {s}   │       │
  │   M9.3 Responsive & Accessible         │ {s}   │       │
  │   M9.4 Onboarding Flow                 │ {s}   │       │
  ├─────────────────────────────────────────┼───────┼───────┤
  │ D10: Growth & Analytics ({weight}%)     │ {s}   │ {g}   │
  │   M10.1 Analytics Tracking             │ {s}   │       │
  │   M10.2 Feature Flags                  │ {s}   │       │
  │   M10.3 Data Export / Import           │ {s}   │       │
  │   M10.4 Admin Panel                    │ {s}   │       │
  └─────────────────────────────────────────┴───────┴───────┘
```

### Missing Components Section

For every sub-metric scoring **0 (Not Present)**, output:

```
================================================================
  MISSING COMPONENTS — BUILD PLAN
================================================================

  Priority Legend: [BLOCKER] [CRITICAL] [HIGH] [MEDIUM] [LOW]
  Effort Legend:   S (< 1 day)  M (1-3 days)  L (3-7 days)  XL (1-2 weeks)

  ┌────┬─────────────────────────┬──────────┬────────┬─────────────────────────────────┬──────────────┐
  │ #  │ Component               │ Priority │ Effort │ Suggested Approach              │ Follow-up RX │
  ├────┼─────────────────────────┼──────────┼────────┼─────────────────────────────────┼──────────────┤
  │ 1  │ M1.1 Authentication     │ BLOCKER  │ M      │ Implement NextAuth/Clerk/...    │ sec-rx       │
  │ 2  │ M6.1 Health Checks      │ HIGH     │ S      │ Add /healthz endpoint with...   │ ops-rx       │
  │ ...│                         │          │        │                                 │              │
  └────┴─────────────────────────┴──────────┴────────┴─────────────────────────────────┴──────────────┘
```

### Priority Assignment Rules

Priority is determined by archetype + dimension weight:

| Condition | Priority |
|-----------|----------|
| Sub-metric is in a dimension with archetype weight >= 15% | **BLOCKER** |
| Sub-metric is in a dimension with archetype weight >= 12% | **CRITICAL** |
| Sub-metric is in a dimension with archetype weight >= 10% | **HIGH** |
| Sub-metric is in a dimension with archetype weight >= 8% | **MEDIUM** |
| Sub-metric is in a dimension with archetype weight < 8% or marked N/A | **LOW** |

### Build Plan Ordering

Sort missing components by:
1. Priority (BLOCKER first)
2. Within same priority: lower effort first (quick wins)
3. Within same priority + effort: dimension order (D1 before D2, etc.)

### Follow-up RX Mapping

After building a component, recommend the appropriate rx skill for quality assessment:

| Component Area | Follow-up RX |
|----------------|-------------|
| Auth, sessions, RBAC | sec-rx |
| API layer, docs, integrations | api-rx (if available), code-rx |
| Domain model, business rules | code-rx, arch-rx |
| Database, storage, caching | code-rx, ops-rx |
| CI/CD, dev setup, tooling | ops-rx |
| UI states, responsiveness, a11y | ux-rx |
| Monitoring, logging, health | ops-rx |
| Tests (after building anything) | test-rx |
| Documentation | doc-rx |
| Security headers, secrets, audit | sec-rx |
| Analytics, feature flags, admin | code-rx |

---

## Phase 6: Recommendations Summary

After the scorecard, provide:

### Immediate Actions (This Sprint)

List the top 3-5 BLOCKER/CRITICAL missing components with concrete next steps.

### Short-term Roadmap (Next 2-4 Sprints)

Group HIGH/MEDIUM missing components into logical build phases.

### Technical Debt Warning

Flag any components at score 40 (minimal) that need upgrading before production.

---

## Rules

1. **Always detect archetype first.** The archetype determines weight adjustments and priority assignments. Never skip detection.

2. **Evidence-based scoring only.** Every score must cite specific files, config entries, or code patterns. No guessing. If uncertain, score lower and note the uncertainty.

3. **Score 0 means truly absent.** Not "I couldn't find it" but "I searched comprehensively and confirmed it doesn't exist." Document what you searched for.

4. **Score 40 requires visible code.** A TODO comment or empty file counts as 0, not 40. There must be actual functioning (even if minimal) code.

5. **Score 70 requires working functionality.** The component must actually work end-to-end for the basic case. Untested code that might work scores 40.

6. **Score 85 requires production evidence.** Error handling, edge cases covered, configuration externalized, tested.

7. **Score 100 is rare and earned.** Must demonstrate advanced features, comprehensive testing, monitoring, documentation. Almost never given.

8. **Archetype N/A components score 100.** If a component is not applicable to the archetype (e.g., billing for a Library), score it 100 and mark as "N/A — not applicable to {archetype}". This prevents penalizing projects for things they don't need.

9. **Never inflate scores for potential.** Score what EXISTS, not what's planned or easy to add. The build plan handles what to add next.

10. **The build plan is mandatory.** Even if the project scores well, there are always improvements. Always produce the build plan section.

11. **Parallel agents must not overlap.** Each agent scans only their assigned dimensions. No duplicate scanning.

12. **Cross-reference dependencies.** When listing missing components, note dependencies (e.g., "M4.4 Billing requires M1.1 Authentication first").

13. **Effort estimates are for MVP-level (score 70).** The effort to go from 0 to 70 (basic working implementation), not to 100.

14. **Respect the project's tech stack.** Suggestions in the build plan must use the project's existing framework, language, and tooling. Don't suggest Django solutions for a Next.js project.

15. **Run this skill before other rx skills.** project-rx identifies WHAT to build; other rx skills assess HOW WELL it's built. The recommended workflow is: project-rx first, build missing components, then run specific rx skills for quality assessment.
