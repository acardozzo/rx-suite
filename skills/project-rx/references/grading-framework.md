# project-rx Grading Framework

Complete threshold tables for all 40 sub-metrics, archetype definitions, and weight adjustment tables.

---

## Table of Contents

1. [Archetype Definitions](#1-archetype-definitions)
2. [Archetype Weight Adjustment Tables](#2-archetype-weight-adjustment-tables)
3. [Sub-Metric Threshold Tables (All 40)](#3-sub-metric-threshold-tables)
4. [Framework Sources](#4-framework-sources)

---

## 1. Archetype Definitions

### A1: SaaS (Software as a Service)

**Characteristics:** Multi-tenant web application sold via subscription. Users sign up, manage their account, use features through a web UI, and pay monthly/annually.

**Key signals:** Subscription/billing logic, tenant isolation, pricing page, dashboard UI, user onboarding flows, plan management.

**Critical dimensions:** D1 (Identity), D4 (Business Logic — billing), D9 (UX — onboarding).

**Typically N/A:** None — SaaS needs everything.

**Examples:** Notion, Linear, Vercel, Supabase Dashboard.

---

### A2: API Platform

**Characteristics:** Developer-facing product where the primary interface is an API. May have a dashboard for key management but the core value is programmatic access.

**Key signals:** OpenAPI/Swagger specs, API key management, rate limiting, SDK generation, developer documentation, usage metering.

**Critical dimensions:** D5 (API & Integration), D8 (DX), D6 (Reliability).

**Typically N/A:** D9.4 (Onboarding — replaced by developer quickstart).

**Examples:** Stripe API, Twilio, SendGrid, OpenAI API.

---

### A3: Marketplace

**Characteristics:** Two-sided platform connecting buyers and sellers/providers. Handles listings, transactions, trust/reputation, and payment splits.

**Key signals:** Buyer/seller roles, listings/products, cart/checkout, reviews/ratings, escrow or payment splits, search/discovery.

**Critical dimensions:** D4 (Business Logic — transactions), D2 (Data — search), D7 (Security — financial).

**Typically N/A:** D5.4 (API Keys — unless also an API platform).

**Examples:** Airbnb, Etsy, Uber, Fiverr.

---

### A4: Internal Tool

**Characteristics:** Application used within an organization. Not customer-facing. Focuses on data management, workflows, and operational efficiency.

**Key signals:** Admin panels, SSO/LDAP auth, data tables, forms, reports, internal URLs, no public marketing pages.

**Critical dimensions:** D1 (Identity — SSO), D4 (Business Logic — workflows), D8 (DX).

**Typically N/A:** D4.4 (Billing), D10.1 (Public analytics), D10.2 (Feature flags — usually).

**Examples:** Retool apps, internal dashboards, ops tools, CRM backends.

---

### A5: Mobile Backend

**Characteristics:** API backend primarily serving mobile apps. Handles auth, push notifications, data sync, and mobile-specific concerns.

**Key signals:** Push notification config (FCM/APNs), mobile-specific API patterns, device token management, app store references, offline sync.

**Critical dimensions:** D3 (Communication — push), D5 (API), D1 (Identity — device sessions).

**Typically N/A:** D9 (UX Infrastructure — handled by mobile app).

**Examples:** Firebase alternatives, custom mobile backends, BaaS platforms.

---

### A6: AI Product

**Characteristics:** Product built around AI/ML capabilities. May include LLM integration, embeddings, vector search, model management, or inference endpoints.

**Key signals:** LLM/ML library imports, vector database config, prompt templates, model configuration, embeddings, RAG pipelines, inference endpoints.

**Critical dimensions:** D4 (Business Logic — AI pipeline), D2 (Data — vector storage), D6 (Reliability — model monitoring).

**Typically N/A:** D4.4 (Billing — unless monetized), varies widely.

**Examples:** ChatGPT wrappers, RAG applications, AI coding tools, ML platforms.

---

### A7: CLI Tool

**Characteristics:** Command-line application. No web server, no UI (beyond terminal). Distributed as a binary or npm/pip package.

**Key signals:** CLI framework (commander, yargs, clap, cobra), argument parsing, no HTTP server, terminal output formatting, man pages.

**Critical dimensions:** D8 (DX — installation, docs), D4 (Business Logic — core commands).

**Typically N/A:** D1 (Identity — unless SaaS CLI), D3 (Communication), D9 (UX Infrastructure), D10.4 (Admin panel).

**Examples:** gh CLI, Vercel CLI, eslint, prettier, ripgrep.

---

### A8: Library / Package

**Characteristics:** Reusable code meant to be imported by other projects. Exports-focused, minimal or no runtime, published to a package registry.

**Key signals:** Exports-heavy, no app entry point, published to npm/PyPI/crates.io, README-centric, minimal dependencies, extensive tests.

**Critical dimensions:** D8 (DX — docs, types, examples), D4 (Business Logic — core API design).

**Typically N/A:** D1 (Identity), D2 (Data — unless DB library), D3 (Communication), D6 (Ops), D9 (UX), D10 (Growth).

**Examples:** React, lodash, zod, Tailwind CSS, date-fns.

---

## 2. Archetype Weight Adjustment Tables

Weights must always sum to 100%. These tables show the adjusted weights per archetype.

### Master Weight Table

| Dimension | Base | SaaS | API Platform | Marketplace | Internal Tool | Mobile Backend | AI Product | CLI | Library |
|-----------|------|------|-------------|-------------|---------------|----------------|------------|-----|---------|
| D1: Identity & Access | 12% | 14% | 10% | 12% | 14% | 12% | 8% | 4% | 2% |
| D2: Data & Storage | 10% | 10% | 8% | 14% | 10% | 10% | 14% | 4% | 4% |
| D3: Communication | 10% | 10% | 6% | 8% | 6% | 16% | 6% | 2% | 2% |
| D4: Business Logic | 12% | 14% | 10% | 16% | 14% | 10% | 16% | 20% | 24% |
| D5: API & Integration | 10% | 8% | 18% | 10% | 8% | 14% | 10% | 4% | 4% |
| D6: Reliability & Ops | 10% | 10% | 12% | 10% | 10% | 10% | 12% | 8% | 6% |
| D7: Security | 10% | 10% | 12% | 12% | 10% | 10% | 8% | 6% | 4% |
| D8: DX & CI/CD | 8% | 6% | 10% | 6% | 8% | 6% | 8% | 20% | 30% |
| D9: UX Infrastructure | 10% | 12% | 6% | 8% | 12% | 4% | 10% | 2% | 2% |
| D10: Growth & Analytics | 8% | 6% | 8% | 4% | 8% | 8% | 8% | 30% | 22% |

> **Note on CLI and Library D10 weights:** For CLI tools, D10 is weighted high (30%) because it encompasses distribution, install experience, and plugin ecosystems — critical for CLI adoption. For Libraries, D10 captures documentation quality, examples, and ecosystem integration, which are similarly vital. The sub-metrics are interpreted differently for these archetypes:
> - M10.1 "Analytics" becomes "Usage telemetry / download stats"
> - M10.2 "Feature flags" becomes "Plugin/extension system"
> - M10.3 "Data export" becomes "Interoperability / format support"
> - M10.4 "Admin panel" becomes "Configuration management / RC files"

### Weight Verification

All columns sum to 100%:
- SaaS: 14+10+10+14+8+10+10+6+12+6 = 100
- API Platform: 10+8+6+10+18+12+12+10+6+8 = 100
- Marketplace: 12+14+8+16+10+10+12+6+8+4 = 100
- Internal Tool: 14+10+6+14+8+10+10+8+12+8 = 100
- Mobile Backend: 12+10+16+10+14+10+10+6+4+8 = 100
- AI Product: 8+14+6+16+10+12+8+8+10+8 = 100
- CLI: 4+4+2+20+4+8+6+20+2+30 = 100
- Library: 2+4+2+24+4+6+4+30+2+22 = 100

---

## 3. Sub-Metric Threshold Tables

### D1: Identity & Access

**Source:** OWASP ASVS v4.0, Auth0 Architecture Scenarios, NIST SP 800-63B

#### M1.1: Authentication System

| Score | Criteria |
|-------|----------|
| 100 | **World-class:** Multiple auth strategies (email/password, OAuth, magic link, passkeys, MFA/2FA). Brute-force protection, account lockout, suspicious login detection. Password policy enforcement. Passwordless options. Auth events logged and monitored. Session binding to device/IP. Comprehensive auth tests. |
| 85 | **Production-ready:** Email/password + at least one OAuth provider. Password reset flow. Email verification. Rate limiting on auth endpoints. MFA available. Login/signup pages styled and accessible. Auth state persisted correctly across refreshes. |
| 70 | **Basic:** Email/password login and signup working. Password reset functional. Basic session management (JWT or cookies). Auth middleware protecting routes. No MFA, limited OAuth. |
| 40 | **Minimal:** Auth library installed and configured but only partially working. Login page exists but incomplete flows (e.g., signup works but no password reset). Hardcoded test credentials. |
| 0 | **Not present:** No authentication system. No login/signup pages. No auth middleware. No user credentials storage. |

#### M1.2: Authorization / RBAC

| Score | Criteria |
|-------|----------|
| 100 | **World-class:** Fine-grained RBAC or ABAC with policy engine. Role hierarchy with inheritance. Dynamic permissions. Permission checks at API, UI, and data layers. Audit logging of authorization decisions. Permission management UI. Comprehensive test coverage for auth rules. |
| 85 | **Production-ready:** Role-based access control with multiple defined roles. Permissions enforced at both API and UI levels. Role assignment via admin interface. Guards/middleware on protected routes. Roles stored in database with proper schema. |
| 70 | **Basic:** At least 2 roles (e.g., user/admin) with route-level protection. Basic middleware checking roles. Admin-only routes protected. Role stored on user record. |
| 40 | **Minimal:** Single admin check (isAdmin boolean). Some routes have protection but inconsistent. No formal role system. |
| 0 | **Not present:** No authorization system. All authenticated users have the same access. No role or permission definitions. |

#### M1.3: Session Management

| Score | Criteria |
|-------|----------|
| 100 | **World-class:** Secure token rotation with short-lived access tokens and long-lived refresh tokens. Device tracking and management ("your active sessions"). Session revocation (logout all devices). Token binding. Sliding window expiry. Concurrent session limits. Session activity logging. |
| 85 | **Production-ready:** JWT or session-based auth with proper expiry. Refresh token rotation. Secure cookie settings (httpOnly, secure, sameSite). Token revocation on password change. Session stored server-side or in secure storage. |
| 70 | **Basic:** Working session management with token expiry. Login persists across page refreshes. Logout clears session. Basic cookie/token configuration. |
| 40 | **Minimal:** Tokens generated but no expiry or improper expiry. Sessions not properly invalidated on logout. Tokens stored in localStorage without security considerations. |
| 0 | **Not present:** No session management. No token generation. Users cannot maintain a logged-in state. |

#### M1.4: User Management

| Score | Criteria |
|-------|----------|
| 100 | **World-class:** Full user CRUD with admin controls. User invitation system. Account deactivation/reactivation. Profile management (avatar, display name, preferences). User search and filtering for admins. User activity history. Account deletion with data cleanup (GDPR). Bulk user operations. |
| 85 | **Production-ready:** User profile editing (name, email, avatar). Admin can view/edit/disable users. User invitation via email. Account settings page. Password change flow. |
| 70 | **Basic:** User profile page exists. Users can update basic info. Admin can list users. No invitation system or advanced management. |
| 40 | **Minimal:** User record exists in database but no profile UI. Can create users programmatically but no management interface. |
| 0 | **Not present:** No user management beyond auth. No profile pages. No admin user views. Users are just auth records with no additional data. |

---

### D2: Data & Storage

**Source:** "Designing Data-Intensive Applications" (Kleppmann), 12-Factor App, AWS Well-Architected Framework

#### M2.1: Primary Data Store

| Score | Criteria |
|-------|----------|
| 100 | **World-class:** Database fully configured with migration system, seeding, connection pooling, read replicas, automated backups. Schema well-designed with proper indexes, constraints, and relationships. Database monitoring. Query performance tracking. Schema versioning with rollback capability. Type-safe queries (ORM or query builder). |
| 85 | **Production-ready:** Database configured with migration system. Proper schema with indexes and foreign keys. Connection pooling. Seed data for development. Type-safe queries via ORM/query builder. Environment-based config. |
| 70 | **Basic:** Database connected and working. Migration system in place with initial schema. Basic models/tables defined. Queries work but may lack optimization. |
| 40 | **Minimal:** Database connected but no migration system. Schema defined ad-hoc or via raw SQL. Missing indexes. No seed data. |
| 0 | **Not present:** No database configured. Data stored in memory, files, or not stored at all. |

#### M2.2: File/Media Storage

| Score | Criteria |
|-------|----------|
| 100 | **World-class:** Cloud storage (S3/GCS/R2) with CDN. Upload with progress, drag-and-drop, multi-file. Image optimization (resize, format conversion, thumbnails). Virus scanning. Storage quotas. Signed URLs for private content. Cleanup of orphaned files. Content type validation. |
| 85 | **Production-ready:** Cloud storage configured. File upload with type/size validation. Image resizing/optimization. Signed URLs or proper access control. Upload progress indication. Files associated with records in database. |
| 70 | **Basic:** File upload working to cloud storage or local disk. Basic type validation. Files served correctly. No optimization or CDN. |
| 40 | **Minimal:** Upload endpoint exists but files stored locally only. No validation. No proper file serving strategy. |
| 0 | **Not present:** No file upload capability. No storage configuration. No media handling. |

#### M2.3: Caching Layer

| Score | Criteria |
|-------|----------|
| 100 | **World-class:** Multi-layer caching strategy (browser, CDN, application, database). Redis/Memcached for session and data caching. Cache invalidation strategy documented and implemented. Cache warming. Cache hit/miss metrics. Stale-while-revalidate patterns. Per-user and per-resource caching. |
| 85 | **Production-ready:** Redis or equivalent configured. Key application queries cached. Cache invalidation on data mutation. TTL-based expiry. Framework caching features used (e.g., Next.js ISR, unstable_cache). |
| 70 | **Basic:** Some caching in place (in-memory or framework-level). Key pages or queries cached. Basic TTL. No sophisticated invalidation. |
| 40 | **Minimal:** Cache library installed but barely used. One or two cached values. No invalidation strategy. |
| 0 | **Not present:** No caching layer. Every request hits the database. No CDN. No in-memory caching. |

#### M2.4: Search Capability

| Score | Criteria |
|-------|----------|
| 100 | **World-class:** Dedicated search engine (Elasticsearch/Meilisearch/Typesense). Full-text search with relevance ranking. Faceted search and filtering. Search suggestions/autocomplete. Typo tolerance. Search analytics. Indexing pipeline with real-time sync. |
| 85 | **Production-ready:** Search engine or database full-text search configured. Multi-field search working. Filtering and sorting. Indexed for performance. Handles reasonable data volumes. |
| 70 | **Basic:** Database LIKE/ILIKE queries or basic full-text search. Works for current data size. Single-field or simple multi-field search. Basic filtering. |
| 40 | **Minimal:** Search endpoint exists but only does exact match or very basic filtering. No indexing. Performance degrades with data. |
| 0 | **Not present:** No search functionality. Users cannot search or filter data. |

---

### D3: Communication & Notifications

**Source:** Enterprise Integration Patterns (Hohpe & Woolf), notification system design patterns

#### M3.1: Email System

| Score | Criteria |
|-------|----------|
| 100 | **World-class:** Email provider abstraction (can swap SendGrid/Resend/SES). HTML email templates with preview. Transactional emails (welcome, reset, invoice). Marketing email support. Email tracking (open, click). Bounce/complaint handling. Email queuing with retry. Template management UI. DKIM/SPF configured. |
| 85 | **Production-ready:** Email provider integrated (Resend/SendGrid/etc.). HTML templates for key flows. Transactional emails working (welcome, password reset, notifications). Provider abstraction layer. Error handling and retry. |
| 70 | **Basic:** Email sending works for critical flows (password reset, verification). Using a provider SDK directly. Basic HTML templates. |
| 40 | **Minimal:** Email dependency installed. Maybe one email sends (e.g., verification) but templating is raw strings or minimal. |
| 0 | **Not present:** No email system. No email provider. No transactional emails. |

#### M3.2: Real-time Updates

| Score | Criteria |
|-------|----------|
| 100 | **World-class:** WebSocket/SSE infrastructure with presence detection. Real-time data sync across clients. Optimistic updates with conflict resolution. Connection recovery and reconnection logic. Channel-based subscriptions. Horizontal scaling (pub/sub). Real-time typing indicators, cursors, or collaborative features. |
| 85 | **Production-ready:** WebSocket or SSE working for key features. Automatic reconnection. Proper cleanup on disconnect. Works across multiple server instances (via Redis pub/sub or equivalent). |
| 70 | **Basic:** Real-time updates working for at least one feature (e.g., live notifications, live data). Basic WebSocket or SSE implementation. Single-server only. |
| 40 | **Minimal:** WebSocket library installed. Maybe a basic connection established but not used meaningfully. Polling used instead. |
| 0 | **Not present:** No real-time capability. All data fetched via polling or manual refresh. |

#### M3.3: Push Notifications

| Score | Criteria |
|-------|----------|
| 100 | **World-class:** Push for web and mobile (FCM + APNs + Web Push). User notification preferences (per-channel, per-type). Rich notifications with actions. Notification center in-app. Push scheduling. Delivery tracking. Quiet hours. Notification grouping/batching. |
| 85 | **Production-ready:** Push notifications working on target platforms. User can manage preferences. Notification center showing history. Proper handling of token refresh and unsubscribe. |
| 70 | **Basic:** Push notifications working for at least one platform. Basic notification types. User can enable/disable. |
| 40 | **Minimal:** Push notification library installed. Service worker registered (web) or FCM configured (mobile) but not connected to business events. |
| 0 | **Not present:** No push notification capability. No service worker for web push. No FCM/APNs setup. |

#### M3.4: Webhook Outbound

| Score | Criteria |
|-------|----------|
| 100 | **World-class:** Webhook system with registration API. HMAC signature verification. Retry with exponential backoff. Delivery dashboard showing attempts/failures. Event type filtering. Webhook testing/debugging tools. Payload versioning. IP allowlisting. Rate limiting per endpoint. |
| 85 | **Production-ready:** Webhook delivery system with retry logic. HMAC signatures. Event type selection. Delivery logs viewable. Failed webhooks can be retried manually. |
| 70 | **Basic:** Webhooks fire on key events. Basic HTTP POST with JSON payload. Some retry logic. Signatures included. |
| 40 | **Minimal:** One or two webhook endpoints that fire-and-forget. No retry. No signatures. No delivery tracking. |
| 0 | **Not present:** No webhook capability. No outbound event delivery system. |

---

### D4: Business Logic & Domain

**Source:** Domain-Driven Design (Evans), Clean Architecture (Martin), Patterns of Enterprise Application Architecture (Fowler)

#### M4.1: Core Domain Model

| Score | Criteria |
|-------|----------|
| 100 | **World-class:** Well-defined bounded contexts. Entities and value objects with invariant enforcement. Aggregates with clear boundaries. Domain events published. Repository pattern or equivalent abstraction. Ubiquitous language reflected in code. Domain model tested independently of infrastructure. |
| 85 | **Production-ready:** Clear entity definitions with relationships. Business logic encapsulated in domain layer (not scattered in controllers). Validation at domain level. Domain separated from infrastructure concerns. |
| 70 | **Basic:** Core entities defined (database models with relationships). Business logic exists but may be mixed with controllers/routes. Basic validation on models. |
| 40 | **Minimal:** Database tables exist but no real domain modeling. Business logic scattered. Anemic domain model (just data containers). |
| 0 | **Not present:** No domain model. No entities defined. Logic is ad-hoc scripts or purely CRUD with no business rules. |

#### M4.2: Business Rules Engine

| Score | Criteria |
|-------|----------|
| 100 | **World-class:** Formalized business rules (validation, workflows, state machines). State machines for complex flows (xstate or equivalent). Workflow engine for multi-step processes. Rules externalized and configurable. Comprehensive edge case handling. Rules tested with property-based or scenario tests. |
| 85 | **Production-ready:** Business rules clearly defined and enforced. State management for key workflows. Validation rules centralized. Complex flows have defined states and transitions. |
| 70 | **Basic:** Key business rules implemented (validation, basic workflows). Some state management. Rules may be hardcoded but functional. |
| 40 | **Minimal:** A few validation rules. No formal workflow or state management. Business logic is mostly if/else chains in controllers. |
| 0 | **Not present:** No business rules beyond basic CRUD. No validation logic. No workflows. App is essentially a database UI. |

#### M4.3: Multi-tenancy / Org Isolation

| Score | Criteria |
|-------|----------|
| 100 | **World-class:** Complete tenant isolation (row-level security or schema-per-tenant). Tenant context propagated through all layers. Cross-tenant data access impossible by design. Tenant-specific configuration. Tenant admin capabilities. Usage metering per tenant. Tenant onboarding automation. Data export per tenant. |
| 85 | **Production-ready:** Tenant/org model with proper data isolation. All queries scoped to tenant. Tenant context in middleware. Users can belong to multiple orgs. Org management (invite, remove, roles). |
| 70 | **Basic:** Organization/workspace model exists. Data associated with org. Basic org switching. Queries mostly scoped but may have gaps. |
| 40 | **Minimal:** Org or tenant_id column exists on some tables but not consistently enforced. No org management UI. |
| 0 | **Not present:** No multi-tenancy. Single-tenant application. No organization concept. |

#### M4.4: Billing & Subscription

| Score | Criteria |
|-------|----------|
| 100 | **World-class:** Full billing system (Stripe/Paddle) with multiple plan tiers. Usage-based metering. Proration. Invoice generation. Payment method management. Dunning (failed payment recovery). Free trial with conversion. Plan comparison page. Billing portal. Revenue analytics. Tax handling. |
| 85 | **Production-ready:** Payment provider integrated. Multiple plans with upgrade/downgrade. Subscription lifecycle management. Webhook handling for payment events. Customer portal. Invoice access. |
| 70 | **Basic:** Payment provider connected. At least one paid plan. Checkout flow works. Basic subscription status tracking. Webhook for payment confirmation. |
| 40 | **Minimal:** Stripe/payment SDK installed. Maybe a checkout session created but no full lifecycle. No plan management. |
| 0 | **Not present:** No billing system. No payment integration. No subscription management. |

---

### D5: API & Integration

**Source:** REST API Design Rulebook, OpenAPI Specification, Richardson Maturity Model

#### M5.1: API Layer

| Score | Criteria |
|-------|----------|
| 100 | **World-class:** Well-designed API (REST Level 3 / GraphQL / gRPC) with versioning. Consistent error format. Pagination, filtering, sorting. Rate limiting. Request/response validation. API middleware stack (auth, logging, CORS). Hypermedia links (REST) or schema introspection (GraphQL). Comprehensive API tests. |
| 85 | **Production-ready:** API endpoints well-organized. Consistent response format. Validation on inputs. Pagination implemented. Error responses standardized. Versioning strategy in place. |
| 70 | **Basic:** API routes working and serving data. Basic request validation. JSON responses. No formal versioning but functional. |
| 40 | **Minimal:** A few API routes exist. Inconsistent response format. No validation. Errors return raw messages. |
| 0 | **Not present:** No API layer. Application is purely server-rendered with no programmatic access. |

#### M5.2: API Documentation

| Score | Criteria |
|-------|----------|
| 100 | **World-class:** OpenAPI 3.x spec auto-generated from code. Interactive documentation (Swagger UI / Redoc). Code examples in multiple languages. Authentication documented with examples. Changelog maintained. SDK generation from spec. |
| 85 | **Production-ready:** OpenAPI spec maintained. Interactive docs deployed. All endpoints documented with request/response schemas. Authentication documented. |
| 70 | **Basic:** API documentation exists (README, Notion, or basic OpenAPI). Most endpoints documented. May be partially out of date. |
| 40 | **Minimal:** Some API endpoints mentioned in README. No formal spec. Documentation is sparse or outdated. |
| 0 | **Not present:** No API documentation. Endpoints discoverable only by reading code. |

#### M5.3: Third-party Integrations

| Score | Criteria |
|-------|----------|
| 100 | **World-class:** Integration abstraction layer (provider pattern). Multiple OAuth providers. Payment gateway with fallback. Webhook ingestion for external events. Integration health monitoring. Graceful degradation when third-party is down. Integration testing suite. |
| 85 | **Production-ready:** Key integrations working (auth providers, payment, email). Provider abstraction for swappability. Error handling for API failures. Credentials managed securely. |
| 70 | **Basic:** Essential third-party integrations working (1-2 providers). Direct SDK usage without abstraction. Basic error handling. |
| 40 | **Minimal:** One integration partially working. SDK installed but integration is fragile or incomplete. |
| 0 | **Not present:** No third-party integrations. No external API calls. Application is entirely self-contained. |

#### M5.4: API Keys & Developer Portal

| Score | Criteria |
|-------|----------|
| 100 | **World-class:** Developer portal with registration. API key generation, rotation, and revocation. Per-key usage tracking and rate limits. Scoped permissions per key. Usage dashboard. Getting started guide. Sandbox environment. Key expiry and renewal. |
| 85 | **Production-ready:** API key generation and management. Usage tracking per key. Rate limiting per key. Key revocation. Basic developer documentation. |
| 70 | **Basic:** API keys can be generated. Basic auth via API key. Some usage tracking. No developer portal. |
| 40 | **Minimal:** API key auth exists but keys are manually provisioned. No management UI. No usage tracking. |
| 0 | **Not present:** No API key system. No developer-facing key management. |

---

### D6: Reliability & Operations

**Source:** Google SRE Book, 12-Factor App, AWS Well-Architected Reliability Pillar

#### M6.1: Health Checks

| Score | Criteria |
|-------|----------|
| 100 | **World-class:** Liveness, readiness, and startup probes. Dependency health checks (database, cache, external APIs). Health endpoint returns structured status. Automated health monitoring with alerts. Health dashboard. Graceful degradation when dependencies fail. Circuit breakers on external calls. |
| 85 | **Production-ready:** Health endpoint checking key dependencies (DB, cache, critical services). Separate liveness and readiness endpoints. Structured JSON response with component status. Used by load balancer/orchestrator. |
| 70 | **Basic:** Health check endpoint exists (`/health` or `/healthz`). Checks database connectivity. Returns 200/503. |
| 40 | **Minimal:** A simple ping endpoint that always returns 200. No dependency checking. |
| 0 | **Not present:** No health check endpoint. No way to programmatically verify application health. |

#### M6.2: Monitoring & Alerting

| Score | Criteria |
|-------|----------|
| 100 | **World-class:** Full observability stack (metrics, traces, logs correlated). Custom dashboards for business and technical metrics. SLO/SLI tracking. Alert rules with escalation. On-call rotation integration. Anomaly detection. Capacity planning metrics. Distributed tracing. |
| 85 | **Production-ready:** Monitoring solution deployed (Datadog/Grafana/etc.). Key metrics tracked (request rate, error rate, latency). Alert rules for critical conditions. Dashboard for system overview. |
| 70 | **Basic:** Basic monitoring in place (e.g., Vercel Analytics, basic Prometheus). Some metrics collected. At least error rate alerting. |
| 40 | **Minimal:** Monitoring tool configured but not meaningfully used. Default metrics only. No custom alerts. |
| 0 | **Not present:** No monitoring. No metrics collection. No alerting. Running blind. |

#### M6.3: Error Tracking

| Score | Criteria |
|-------|----------|
| 100 | **World-class:** Error tracking (Sentry/Bugsnag) with source maps. Error boundaries at UI level. Automatic issue grouping and deduplication. Error context (user, request, breadcrumbs). Release tracking. Performance monitoring. Alert on new error types. Error budget tracking. |
| 85 | **Production-ready:** Error tracking service integrated. Source maps uploaded for production. Error boundaries in UI. Errors grouped and triaged. Notifications on new errors. Release association. |
| 70 | **Basic:** Error tracking tool integrated. Errors reported from both client and server. Basic error boundaries. Some errors may lack context. |
| 40 | **Minimal:** Error tracking installed but not properly configured. Missing source maps. Only catching some errors. No error boundaries. |
| 0 | **Not present:** No error tracking. Errors visible only in server logs (if logging exists). No error boundaries. Errors fail silently. |

#### M6.4: Logging

| Score | Criteria |
|-------|----------|
| 100 | **World-class:** Structured logging (JSON) with consistent schema. Correlation IDs across requests. Log levels properly used. Centralized log aggregation (ELK/Loki/CloudWatch). Log-based alerting. PII redaction. Log retention policies. Request/response logging with sampling. |
| 85 | **Production-ready:** Structured logging library (pino/winston). Consistent log format. Correlation IDs. Logs shipped to aggregation service. Appropriate log levels. No sensitive data in logs. |
| 70 | **Basic:** Logging library configured. Structured output (JSON). Key operations logged. Logs available in hosting platform. |
| 40 | **Minimal:** Console.log/print statements. Some logging but unstructured. No log aggregation. |
| 0 | **Not present:** No logging strategy. No logging library. Minimal or no console output. |

---

### D7: Security & Compliance

**Source:** OWASP Top 10, OWASP ASVS, GDPR Technical Measures, CIS Benchmarks

#### M7.1: Input Validation & Sanitization

| Score | Criteria |
|-------|----------|
| 100 | **World-class:** Schema validation at all boundaries (API, forms, events). Type-safe validation (Zod/Joi/Yup with TypeScript). Sanitization for XSS prevention. SQL injection prevention verified. File upload validation (type, size, content). Request size limits. Validation errors return structured, helpful messages. Fuzz testing. |
| 85 | **Production-ready:** Validation library integrated (Zod/Joi/Yup). API inputs validated with schemas. Form validation (client + server). File upload validation. Structured validation error responses. |
| 70 | **Basic:** Input validation on key endpoints. Using a validation library. Server-side validation present. May have gaps in coverage. |
| 40 | **Minimal:** Some manual validation (if/else checks). Inconsistent across endpoints. No schema validation library. |
| 0 | **Not present:** No input validation. Raw user input passed directly to database/business logic. |

#### M7.2: Security Headers

| Score | Criteria |
|-------|----------|
| 100 | **World-class:** All recommended headers set (CSP, HSTS, X-Frame-Options, X-Content-Type-Options, Referrer-Policy, Permissions-Policy). CSP is strict and specific (not just 'unsafe-inline'). CORS properly restricted. Subresource Integrity for external scripts. Regular security header audit. A+ on securityheaders.com. |
| 85 | **Production-ready:** Security header middleware (helmet/equivalent) configured. CSP defined (may use 'unsafe-inline' for compatibility). CORS restricted to known origins. HSTS enabled. X-Frame-Options set. |
| 70 | **Basic:** Some security headers configured. CORS set up. Basic CSP. Using a security middleware but with default config. |
| 40 | **Minimal:** CORS configured but overly permissive (wildcard). One or two headers set. No CSP. |
| 0 | **Not present:** No security headers configured. Default browser behavior only. No CORS configuration. |

#### M7.3: Secrets Management

| Score | Criteria |
|-------|----------|
| 100 | **World-class:** Secrets in vault (HashiCorp Vault/Infisical/AWS Secrets Manager). Secret rotation automated. `.env.example` maintained. CI/CD secrets separate from local. No secrets in code or git history (verified with git-secrets or gitleaks). Different secrets per environment. Secrets audit trail. |
| 85 | **Production-ready:** Environment variables for all secrets. `.env.example` with all required vars. `.env` in `.gitignore`. CI/CD secrets configured in platform. No hardcoded secrets in code. |
| 70 | **Basic:** Using environment variables. `.env` file with `.gitignore` entry. Secrets not in code. May lack `.env.example`. |
| 40 | **Minimal:** Some secrets in env vars but inconsistent. May have some hardcoded values. `.env` exists but may not be gitignored. |
| 0 | **Not present:** Secrets hardcoded in source code. No `.env` file or environment variable usage. API keys in committed files. |

#### M7.4: Audit Trail

| Score | Criteria |
|-------|----------|
| 100 | **World-class:** Comprehensive audit log (who did what, when, to what, from where). Immutable audit store. Audit log viewer for admins. Compliance-ready format. Data access logging. Configuration change logging. Audit log retention policy. Export for compliance. Tamper-evident logging. |
| 85 | **Production-ready:** Audit logging for key actions (CRUD on sensitive data, auth events, admin actions). Stored in dedicated table/service. Queryable by admin. Includes actor, action, target, timestamp. |
| 70 | **Basic:** Some audit logging for critical actions (login, data changes). Stored in database. Basic query capability. |
| 40 | **Minimal:** A few log entries for some actions. Not systematic. No dedicated audit infrastructure. |
| 0 | **Not present:** No audit trail. No record of who did what. Actions are not logged beyond application logs. |

---

### D8: Developer Experience & CI/CD

**Source:** DORA Metrics, Continuous Delivery (Humble & Farley), Accelerate (Forsgren et al.)

#### M8.1: CI/CD Pipeline

| Score | Criteria |
|-------|----------|
| 100 | **World-class:** Full CI/CD with lint, type-check, test, build, deploy stages. Branch previews. Canary/blue-green deployments. Rollback automation. Deployment notifications. Pipeline as code. Multiple environments (dev, staging, prod). Deploy frequency: multiple times per day. Pipeline < 10 min. |
| 85 | **Production-ready:** CI runs lint, type-check, tests, build on every PR. CD deploys to staging automatically, production with approval. Preview deployments. Pipeline reliable and reasonably fast. |
| 70 | **Basic:** CI pipeline runs tests and build on PR. Deploys to production (manual trigger or on merge). Basic pipeline configuration. |
| 40 | **Minimal:** CI config file exists but only runs build (no tests). Or manual deployment scripts. Pipeline unreliable. |
| 0 | **Not present:** No CI/CD. No automated builds or deployments. Everything is manual. |

#### M8.2: Development Setup

| Score | Criteria |
|-------|----------|
| 100 | **World-class:** One-command dev setup (`make dev` or `docker-compose up`). Seed data for all scenarios. Dev/prod parity. Hot reload. Environment variable template. Dev documentation. Codespaces/devcontainer support. Database reset script. Mock external services for offline dev. |
| 85 | **Production-ready:** Docker-compose or equivalent for local services. Seed script. `.env.example`. Dev scripts documented. Hot reload working. Setup takes < 5 minutes for new developer. |
| 70 | **Basic:** README has setup instructions. Dev server works with hot reload. `.env.example` exists. Some seed data. Setup takes < 15 minutes. |
| 40 | **Minimal:** Can run the app locally but setup is undocumented or brittle. Missing seed data. Manual steps required. |
| 0 | **Not present:** No development setup instructions. Cannot easily run locally. No dev scripts. |

#### M8.3: Code Quality Tooling

| Score | Criteria |
|-------|----------|
| 100 | **World-class:** Linter + formatter + type checker + pre-commit hooks + pre-push hooks. Consistent config across monorepo. Editor config shared. Import sorting. Code complexity limits. Strict TypeScript (or equivalent). Automated code review (CodeRabbit, etc.). Dependency update automation (Renovate/Dependabot). |
| 85 | **Production-ready:** ESLint/Biome + Prettier + TypeScript strict mode. Pre-commit hooks (husky + lint-staged). Formatting enforced in CI. Import organization. |
| 70 | **Basic:** Linter and formatter configured. TypeScript or type checking enabled. Runs in CI. Not all rules strictly enforced. |
| 40 | **Minimal:** Linter installed but many warnings ignored. No formatter or not enforced. Loose TypeScript config. |
| 0 | **Not present:** No linter. No formatter. No type checking. No code quality tooling. |

#### M8.4: Documentation

| Score | Criteria |
|-------|----------|
| 100 | **World-class:** README with project overview, setup, architecture. API documentation. Architecture Decision Records (ADRs). CONTRIBUTING.md. Inline code documentation for complex logic. Runbook for operations. Onboarding guide for new developers. Auto-generated from code where possible. |
| 85 | **Production-ready:** Comprehensive README. API docs. Architecture overview. Key decisions documented. Contributing guide. Docs kept up to date. |
| 70 | **Basic:** README with setup instructions and basic overview. Some API documentation. May be partially outdated. |
| 40 | **Minimal:** README exists but is sparse or boilerplate (create-next-app default). No other documentation. |
| 0 | **Not present:** No README. No documentation. New developers must read all code to understand the project. |

---

### D9: User Experience Infrastructure

**Source:** Nielsen's 10 Usability Heuristics, WCAG 2.1 AA, Core Web Vitals, Material Design Guidelines

#### M9.1: Error & Empty States

| Score | Criteria |
|-------|----------|
| 100 | **World-class:** Custom 404 and 500 pages with helpful navigation. Error boundaries with recovery options. Empty states with calls-to-action. Inline error messages for forms. Network error handling with retry. Offline state handling. Error states tested and designed. Contextual help on errors. |
| 85 | **Production-ready:** Custom error pages (404, 500). Error boundaries in React/equivalent. Empty states for lists and data views. Form validation with inline errors. Network error handling. |
| 70 | **Basic:** Custom 404 page. Basic error boundary. Some empty states. Form errors shown. Default 500 page. |
| 40 | **Minimal:** Default framework error pages. One or two empty states. Some form errors but inconsistent. |
| 0 | **Not present:** Default browser/framework error pages. No empty states. No error boundaries. Raw error messages shown to users. |

#### M9.2: Loading & Feedback

| Score | Criteria |
|-------|----------|
| 100 | **World-class:** Skeleton screens for content loading. Optimistic updates for mutations. Toast/notification system for feedback. Progress indicators for long operations. Streaming/suspense for data loading. Button loading states. Smooth page transitions. Perceived performance optimized. |
| 85 | **Production-ready:** Loading skeletons or spinners for all async content. Toast system for user feedback. Button loading states. Suspense boundaries. Progress for uploads/long operations. |
| 70 | **Basic:** Loading spinners or indicators. Toast notifications for some actions. Basic Suspense/loading states. |
| 40 | **Minimal:** A few loading spinners. No toast system. Some pages have no loading state (flash of empty content). |
| 0 | **Not present:** No loading indicators. No feedback on actions. Content appears abruptly or pages hang during loading. |

#### M9.3: Responsive & Accessible

| Score | Criteria |
|-------|----------|
| 100 | **World-class:** Fully responsive (mobile, tablet, desktop). WCAG 2.1 AA compliant. Keyboard navigable throughout. Screen reader tested. Focus management. Skip links. ARIA attributes. Color contrast verified. Reduced motion support. Responsive images. Touch-friendly targets. Accessibility automated in CI. |
| 85 | **Production-ready:** Responsive layout works on all breakpoints. Good keyboard navigation. ARIA labels on interactive elements. Reasonable color contrast. Focus visible styles. Semantic HTML. |
| 70 | **Basic:** Layout is responsive (Tailwind breakpoints or media queries). Some ARIA attributes. Basic keyboard support. Semantic HTML partially used. |
| 40 | **Minimal:** Desktop-only or mobile has significant issues. Minimal accessibility consideration. Some responsive classes but broken on some screens. |
| 0 | **Not present:** Not responsive. No accessibility considerations. No ARIA attributes. Non-semantic HTML throughout. |

#### M9.4: Onboarding Flow

| Score | Criteria |
|-------|----------|
| 100 | **World-class:** Guided onboarding wizard. Progressive disclosure. Interactive tutorials or tooltips. Contextual help. Sample data for exploration. Onboarding checklist with progress. Personalization during onboarding. Re-triggerable walkthroughs. Onboarding analytics (completion rate, drop-off). |
| 85 | **Production-ready:** Onboarding flow for new users. Setup wizard or checklist. Helpful empty states guiding first actions. Getting started documentation. |
| 70 | **Basic:** Welcome screen or basic getting-started flow. Some guidance for new users. Not comprehensive. |
| 40 | **Minimal:** Simple welcome message. No guided flow. Users must figure out the app themselves. |
| 0 | **Not present:** No onboarding. New users land on an empty dashboard with no guidance. |

---

### D10: Growth & Analytics

**Source:** Product analytics patterns, "Lean Analytics" (Croll & Yoskovitz), A/B testing methodology

#### M10.1: Analytics Tracking

| Score | Criteria |
|-------|----------|
| 100 | **World-class:** Full analytics stack (PostHog/Mixpanel/Amplitude). Page views, custom events, user properties, session recording. Funnel analysis. Cohort analysis. Revenue tracking. Privacy-compliant (consent management). Server-side tracking for accuracy. Analytics dashboard. Data warehouse integration. |
| 85 | **Production-ready:** Analytics provider integrated. Key events tracked (signup, activation, key features). User identification. Custom event properties. Basic funnels configured. GDPR-compliant consent. |
| 70 | **Basic:** Analytics tracking on key pages and actions. User identification. Some custom events. May lack comprehensive coverage. |
| 40 | **Minimal:** Analytics script added (e.g., Google Analytics) but only tracking page views. No custom events. No user identification. |
| 0 | **Not present:** No analytics. No tracking of user behavior. No visibility into product usage. |

#### M10.2: Feature Flags

| Score | Criteria |
|-------|----------|
| 100 | **World-class:** Feature flag system (LaunchDarkly/Flagsmith/GrowthBook). Gradual rollouts by percentage. User targeting (by plan, role, cohort). A/B testing with statistical significance. Flag lifecycle management. Stale flag cleanup. Server and client-side evaluation. Flag audit trail. |
| 85 | **Production-ready:** Feature flag service integrated. Flags used for key features. Percentage-based rollouts. User targeting. Flags manageable without deployment. |
| 70 | **Basic:** Feature flags implemented (even if environment-variable based). Used for at least some features. Can toggle without redeployment. |
| 40 | **Minimal:** One or two hardcoded feature flags (if/else in code). Requires deployment to change. |
| 0 | **Not present:** No feature flag system. All features are all-or-nothing. No gradual rollout capability. |

#### M10.3: Data Export / Import

| Score | Criteria |
|-------|----------|
| 100 | **World-class:** CSV/JSON/PDF export for all major data views. Bulk import with validation and preview. GDPR data portability (full user data export). API-based export for automation. Scheduled exports. Import error handling with detailed feedback. Data transformation during import. |
| 85 | **Production-ready:** Export for key data (CSV/JSON). User data export for GDPR. Import capability for common formats. Validation on import. Progress feedback for large operations. |
| 70 | **Basic:** Export for some data views (CSV). Basic import for one or two entities. GDPR export exists but may be manual. |
| 40 | **Minimal:** One export button somewhere. No import. Or export exists but format is limited. |
| 0 | **Not present:** No data export or import. Users cannot get their data out. No GDPR data portability. |

#### M10.4: Admin Panel / Back-office

| Score | Criteria |
|-------|----------|
| 100 | **World-class:** Comprehensive admin panel with user management, content management, system configuration. Activity dashboards. Impersonation for debugging. Bulk operations. Admin audit trail. Feature flag management. System health dashboard. Support tools (search users, view activity). |
| 85 | **Production-ready:** Admin panel with user management and key entity management. Search and filter. Basic analytics dashboard. Configuration management. Admin-only features clearly separated. |
| 70 | **Basic:** Admin section with user list and basic management. Some entity management. Simple dashboard. |
| 40 | **Minimal:** Admin route exists with very limited functionality. Maybe just a user list. |
| 0 | **Not present:** No admin panel. All management done via database directly or CLI. |

---

## 4. Framework Sources

| Source | Used For | Reference |
|--------|----------|-----------|
| OWASP ASVS v4.0 | D1 (Identity), D7 (Security) | https://owasp.org/www-project-application-security-verification-standard/ |
| OWASP Top 10 (2021) | D7 (Security) | https://owasp.org/www-project-top-ten/ |
| Auth0 Architecture Scenarios | D1 (Identity) | https://auth0.com/docs/architecture-scenarios |
| NIST SP 800-63B | D1.3 (Sessions) | https://pages.nist.gov/800-63-3/sp800-63b.html |
| "Designing Data-Intensive Applications" (Kleppmann) | D2 (Data) | ISBN 978-1449373320 |
| 12-Factor App | D2, D6, D8 | https://12factor.net/ |
| Enterprise Integration Patterns (Hohpe & Woolf) | D3 (Communication) | ISBN 978-0321200686 |
| Domain-Driven Design (Evans) | D4 (Business Logic) | ISBN 978-0321125217 |
| Clean Architecture (Martin) | D4 (Business Logic) | ISBN 978-0134494166 |
| REST API Design Rulebook (Masse) | D5 (API) | ISBN 978-1449310509 |
| OpenAPI Specification 3.1 | D5.2 (API Docs) | https://spec.openapis.org/oas/v3.1.0 |
| Google SRE Book | D6 (Reliability) | https://sre.google/sre-book/table-of-contents/ |
| AWS Well-Architected Framework | D6 (Reliability) | https://docs.aws.amazon.com/wellarchitected/ |
| GDPR Technical Measures | D7.4 (Audit), D10.3 (Export) | https://gdpr-info.eu/ |
| CIS Benchmarks | D7 (Security) | https://www.cisecurity.org/cis-benchmarks |
| DORA Metrics | D8 (CI/CD) | https://dora.dev/research/ |
| "Continuous Delivery" (Humble & Farley) | D8 (CI/CD) | ISBN 978-0321601919 |
| "Accelerate" (Forsgren, Humble, Kim) | D8 (CI/CD) | ISBN 978-1942788331 |
| Nielsen's 10 Usability Heuristics | D9 (UX) | https://www.nngroup.com/articles/ten-usability-heuristics/ |
| WCAG 2.1 AA | D9.3 (Accessibility) | https://www.w3.org/TR/WCAG21/ |
| Core Web Vitals | D9 (UX) | https://web.dev/vitals/ |
| Material Design Guidelines | D9 (UX) | https://m3.material.io/ |
| "Lean Analytics" (Croll & Yoskovitz) | D10 (Growth) | ISBN 978-1449335670 |
| Product Analytics Patterns | D10 (Analytics) | Industry standard practices |

---

## Appendix: Quick Reference — Archetype Impact Matrix

This matrix shows which sub-metrics are typically N/A (scored 100 automatically) for each archetype:

| Sub-metric | SaaS | API | Mktplace | Internal | Mobile | AI | CLI | Library |
|------------|------|-----|----------|----------|--------|-----|-----|---------|
| M1.1 Auth | REQ | REQ | REQ | REQ | REQ | OPT | OPT | N/A |
| M1.2 RBAC | REQ | OPT | REQ | REQ | OPT | OPT | N/A | N/A |
| M1.3 Sessions | REQ | OPT | REQ | REQ | REQ | OPT | N/A | N/A |
| M1.4 User Mgmt | REQ | OPT | REQ | REQ | REQ | OPT | N/A | N/A |
| M2.1 Data Store | REQ | REQ | REQ | REQ | REQ | REQ | OPT | OPT |
| M2.2 File Storage | OPT | OPT | REQ | OPT | REQ | OPT | N/A | N/A |
| M2.3 Caching | REQ | REQ | REQ | OPT | REQ | OPT | N/A | N/A |
| M2.4 Search | OPT | OPT | REQ | OPT | OPT | OPT | N/A | N/A |
| M3.1 Email | REQ | OPT | REQ | OPT | OPT | OPT | N/A | N/A |
| M3.2 Real-time | OPT | OPT | OPT | OPT | REQ | OPT | N/A | N/A |
| M3.3 Push | OPT | N/A | OPT | N/A | REQ | N/A | N/A | N/A |
| M3.4 Webhooks | OPT | REQ | OPT | N/A | OPT | OPT | N/A | N/A |
| M4.1 Domain Model | REQ | REQ | REQ | REQ | REQ | REQ | REQ | REQ |
| M4.2 Business Rules | REQ | OPT | REQ | REQ | OPT | REQ | REQ | REQ |
| M4.3 Multi-tenancy | REQ | OPT | REQ | REQ | OPT | OPT | N/A | N/A |
| M4.4 Billing | REQ | REQ | REQ | N/A | OPT | OPT | N/A | N/A |
| M5.1 API Layer | REQ | REQ | REQ | REQ | REQ | REQ | N/A | N/A |
| M5.2 API Docs | OPT | REQ | OPT | OPT | OPT | OPT | N/A | N/A |
| M5.3 Integrations | REQ | REQ | REQ | OPT | REQ | REQ | OPT | N/A |
| M5.4 API Keys | N/A | REQ | N/A | N/A | OPT | OPT | N/A | N/A |
| M6.1 Health Checks | REQ | REQ | REQ | OPT | REQ | REQ | N/A | N/A |
| M6.2 Monitoring | REQ | REQ | REQ | OPT | REQ | REQ | N/A | N/A |
| M6.3 Error Tracking | REQ | REQ | REQ | OPT | REQ | REQ | OPT | OPT |
| M6.4 Logging | REQ | REQ | REQ | OPT | REQ | REQ | OPT | N/A |
| M7.1 Input Validation | REQ | REQ | REQ | REQ | REQ | REQ | REQ | REQ |
| M7.2 Security Headers | REQ | REQ | REQ | REQ | OPT | REQ | N/A | N/A |
| M7.3 Secrets Mgmt | REQ | REQ | REQ | REQ | REQ | REQ | OPT | OPT |
| M7.4 Audit Trail | OPT | OPT | REQ | REQ | OPT | OPT | N/A | N/A |
| M8.1 CI/CD | REQ | REQ | REQ | REQ | REQ | REQ | REQ | REQ |
| M8.2 Dev Setup | REQ | REQ | REQ | REQ | REQ | REQ | REQ | REQ |
| M8.3 Code Quality | REQ | REQ | REQ | REQ | REQ | REQ | REQ | REQ |
| M8.4 Documentation | REQ | REQ | REQ | REQ | REQ | REQ | REQ | REQ |
| M9.1 Error States | REQ | OPT | REQ | REQ | N/A | REQ | OPT | N/A |
| M9.2 Loading States | REQ | OPT | REQ | REQ | N/A | REQ | N/A | N/A |
| M9.3 Responsive/A11y | REQ | OPT | REQ | OPT | N/A | OPT | N/A | N/A |
| M9.4 Onboarding | REQ | OPT | REQ | OPT | N/A | OPT | N/A | N/A |
| M10.1 Analytics | REQ | OPT | REQ | OPT | REQ | OPT | OPT | N/A |
| M10.2 Feature Flags | OPT | OPT | OPT | OPT | OPT | OPT | N/A | N/A |
| M10.3 Data Export | OPT | OPT | OPT | REQ | OPT | OPT | OPT | N/A |
| M10.4 Admin Panel | REQ | OPT | REQ | REQ | OPT | OPT | N/A | N/A |

**Legend:**
- **REQ** = Required for this archetype (scored normally)
- **OPT** = Optional but beneficial (scored normally, lower priority in build plan)
- **N/A** = Not applicable (automatically scored 100, excluded from build plan)
