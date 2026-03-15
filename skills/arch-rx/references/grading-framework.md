# Architectural Pattern Fitness — Full Metric Reference

> Based on Pattern-Oriented Software Architecture (POSA, Buschmann et al.), Enterprise Integration
> Patterns (EIP, Hohpe & Woolf), The Twelve-Factor App (Wiggins), Cloud Native Computing Foundation
> (CNCF) landscape, Reactive Manifesto, AWS Well-Architected Framework + SaaS Lens, GCP Architecture
> Framework, Microsoft Azure Well-Architected Framework, NIST SP 800-207 (Zero Trust Architecture),
> SLSA Supply Chain Framework, OWASP Application Security Architecture Guide, Azure Multi-Tenant
> Architecture Guidance, Google MLOps Maturity Model, and CNCF AI Whitepaper.

---

## Grading Scale

| Grade | Score | Interpretation |
|-------|-------|----------------|
| A+ | 97-100 | World-class — SOTA patterns, fully event-driven, resilient, observable, zero-trust |
| A | 93-96 | Excellent — mature patterns, minor gaps in edge cases |
| A- | 90-92 | Very Good — strong pattern adoption, few missing pieces |
| B+ | 87-89 | Good — solid patterns, some synchronous bottlenecks remain |
| B | 83-86 | Above Average — key patterns in place, gaps in resilience/observability |
| B- | 80-82 | Adequate — basic patterns, significant async/resilience opportunities |
| C+ | 77-79 | Below Average — mostly synchronous, some patterns emerging |
| C | 73-76 | Mediocre — ad-hoc patterns, no systematic approach |
| C- | 70-72 | Poor — monolithic patterns limiting velocity |
| D+ | 67-69 | Bad — synchronous everywhere, no resilience patterns |
| D | 63-66 | Very Bad — direct coupling, no separation of concerns at runtime |
| D- | 60-62 | Critical — fragile, unscalable, no operational visibility |
| F | 0-59 | Failing — architecture actively prevents reliability and growth |

---

## D1: Communication & Protocol Fitness (Weight: 10%)

**Source:** EIP (Hohpe & Woolf, 2003), gRPC/REST selection criteria, API Gateway patterns (POSA Vol. 4)

### M1.1: Synchronous Chain Depth (25% of D1)

Maximum number of synchronous hops in any single request path (A->B->C = depth 3).

| Score | Criteria |
|-------|----------|
| 100 | Max sync depth <= 2 for all flows |
| 90 | Max sync depth <= 3, 90%+ flows <= 2 |
| 80 | Max sync depth <= 4, 80%+ flows <= 3 |
| 70 | Max sync depth <= 5 |
| 60 | Max sync depth <= 7 |
| 50 | Max sync depth <= 10 |
| 30 | Max sync depth > 10 |

### M1.2: Protocol Fit (30% of D1)

Percentage of integrations using the optimal protocol for their access pattern.

Protocol fit rules:
- **REST/HTTP**: CRUD operations, public APIs, browser clients, cacheable reads
- **gRPC/Protobuf**: Internal service-to-service, high-throughput, bidirectional streaming, strict contracts
- **WebSocket**: Real-time bidirectional (chat, collaboration, live updates requiring client push)
- **SSE**: Server-to-client streaming (live feeds, progress, notifications)
- **Message Queue**: Fire-and-forget, workload leveling, retry-heavy flows
- **GraphQL**: Client-driven aggregation across multiple entities, mobile bandwidth optimization

| Score | Criteria |
|-------|----------|
| 100 | 95%+ integrations use optimal protocol, documented rationale |
| 90 | 85%+ optimal, remaining have acceptable alternatives |
| 80 | 75%+ optimal |
| 70 | 65%+ optimal |
| 60 | 50%+ optimal |
| 40 | 30%+ optimal |
| 20 | < 30% optimal, mostly default REST everywhere |

### M1.3: API Gateway & Edge Patterns (25% of D1)

| Score | Criteria |
|-------|----------|
| 100 | Gateway with rate limiting, auth, routing, circuit breaking, request coalescing |
| 90 | Gateway with rate limiting, auth, routing |
| 80 | Gateway with auth and routing |
| 70 | Basic reverse proxy with auth |
| 60 | Auth at application layer, no gateway |
| 40 | No centralized edge handling |

### M1.4: Contract Evolution & Versioning (20% of D1)

| Score | Criteria |
|-------|----------|
| 100 | Schema registry, backward-compatible evolution, consumer-driven contracts |
| 90 | Versioned APIs, deprecation policy, contract tests |
| 80 | API versioning with backward compatibility |
| 70 | URL-based versioning, no contract tests |
| 60 | Informal versioning |
| 40 | No versioning strategy |
| 20 | Breaking changes without versioning |

**D1 formula:** `D1 = (M1.1 * 0.25) + (M1.2 * 0.30) + (M1.3 * 0.25) + (M1.4 * 0.20)`

---

## D2: Async & Event Architecture (Weight: 14%)

**Source:** EIP (Hohpe & Woolf), Reactive Manifesto (2014), CQRS (Young, 2010), Event Sourcing (Fowler)

### M2.1: Async Coverage for Long Operations (30% of D2)

Percentage of operations > 5s that are handled asynchronously (queue, event, background job).

| Score | Criteria |
|-------|----------|
| 100 | 100% of operations > 5s are async, with progress feedback |
| 90 | 95%+ async, progress feedback for user-facing |
| 80 | 85%+ async |
| 70 | 70%+ async |
| 60 | 50%+ async |
| 40 | 30%+ async |
| 20 | < 30% async, most long ops block the request thread |

### M2.2: Event-Driven Decoupling (25% of D2)

Degree to which side effects are decoupled from primary flows via events/messages.

| Score | Criteria |
|-------|----------|
| 100 | All side effects event-driven, dead letter queues, idempotent consumers |
| 90 | 90%+ side effects event-driven, DLQ for critical paths |
| 80 | 75%+ side effects event-driven |
| 70 | 60%+ event-driven, some inline side effects |
| 60 | 40%+ event-driven |
| 40 | Some events but most side effects inline |
| 20 | No event-driven patterns, all side effects synchronous/inline |

### M2.3: Queue & Message Infrastructure (25% of D2)

| Score | Criteria |
|-------|----------|
| 100 | Managed queue service, DLQ, retry policies, backpressure, monitoring, idempotency keys |
| 90 | Queue with DLQ, retry policies, monitoring |
| 80 | Queue with DLQ, basic retry |
| 70 | Queue without DLQ, manual retry |
| 60 | Basic queue with default configuration |
| 40 | In-process queue or timer-based deferral |
| 20 | No queue infrastructure |

### M2.4: CQRS / Read-Write Separation (20% of D2)

| Score | Criteria |
|-------|----------|
| 100 | Full CQRS with separate read/write models, event sourcing optional, projections |
| 90 | CQRS with read replicas, optimized query models |
| 80 | Separate read endpoints with caching, write endpoints direct |
| 70 | Query optimization layer (materialized views, denormalized reads) |
| 60 | Some read-path optimization (caching, computed columns) |
| 40 | Same model for read and write, no optimization |
| 20 | N+1 queries, no read optimization, write-path contention |

**D2 formula:** `D2 = (M2.1 * 0.30) + (M2.2 * 0.25) + (M2.3 * 0.25) + (M2.4 * 0.20)`

---

## D3: Resilience & Fault Tolerance (Weight: 10%)

**Source:** POSA Vol. 1-4 (Buschmann et al.), Reactive Manifesto, Release It! (Nygard, 2018), Netflix Hystrix patterns

### M3.1: Circuit Breaker Coverage (25% of D3)

| Score | Criteria |
|-------|----------|
| 100 | All external calls circuit-breaker protected, half-open testing, fallbacks |
| 90 | 90%+ protected, fallbacks for critical paths |
| 80 | 80%+ protected |
| 70 | 60%+ protected, critical paths covered |
| 60 | Some circuit breakers on most critical integrations |
| 40 | 1-2 circuit breakers, ad hoc |
| 20 | No circuit breakers |

### M3.2: Retry & Backoff Strategy (25% of D3)

| Score | Criteria |
|-------|----------|
| 100 | Exponential backoff + jitter on all retryable ops, idempotency enforced, retry budgets |
| 90 | Exponential backoff + jitter, idempotency on writes |
| 80 | Exponential backoff, most ops idempotent |
| 70 | Fixed-interval retry with limits |
| 60 | Basic retry (1-3 attempts, no backoff) |
| 40 | Retry on some operations, inconsistent |
| 20 | No retry strategy, or infinite retries |

### M3.3: Bulkhead & Isolation Patterns (25% of D3)

| Score | Criteria |
|-------|----------|
| 100 | Thread/connection pool isolation per dependency, queue-based load leveling, resource limits |
| 90 | Connection pool isolation, resource limits per service |
| 80 | Separate connection pools for critical vs non-critical |
| 70 | Basic connection pooling with limits |
| 60 | Shared connection pool with some limits |
| 40 | Shared resources, no isolation |
| 20 | Unbounded resource usage, no pooling |

### M3.4: Graceful Degradation & Fallbacks (25% of D3)

| Score | Criteria |
|-------|----------|
| 100 | Defined degradation modes per feature, stale-data fallbacks, feature flags for graceful disable |
| 90 | Degradation modes for critical features, cached fallbacks |
| 80 | Cached fallbacks for main flows |
| 70 | Some fallback logic for critical paths |
| 60 | Basic error pages / default responses |
| 40 | Generic error handling, no fallback data |
| 20 | Failures cascade, no degradation strategy |

**D3 formula:** `D3 = (M3.1 * 0.25) + (M3.2 * 0.25) + (M3.3 * 0.25) + (M3.4 * 0.25)`

---

## D4: Scalability & Performance Patterns (Weight: 10%)

**Source:** CNCF landscape, AWS Well-Architected Performance Pillar, POSA Vol. 2

### M4.1: Caching Strategy (25% of D4)

| Score | Criteria |
|-------|----------|
| 100 | Multi-tier cache (L1 in-process + L2 distributed), cache-aside/write-through per pattern, TTL strategy, invalidation events, cache warming |
| 90 | Distributed cache + in-process for hot paths, TTL strategy, event invalidation |
| 80 | Distributed cache for main entities, TTL-based |
| 70 | In-process cache for frequent reads, some TTL |
| 60 | Basic memoization or simple cache for specific endpoints |
| 40 | Ad-hoc caching, no consistent strategy |
| 20 | No caching, every request hits origin |

### M4.2: Connection Pooling & Resource Management (25% of D4)

| Score | Criteria |
|-------|----------|
| 100 | All external connections pooled, sized per load profile, health-checked, metrics-instrumented |
| 90 | All DB/cache/queue connections pooled with health checks |
| 80 | DB connections pooled, other connections managed |
| 70 | DB connection pool with defaults |
| 60 | Basic pooling, some connections unmanaged |
| 40 | Minimal pooling |
| 20 | No connection pooling, new connections per request |

### M4.3: Parallelism & Concurrency Patterns (25% of D4)

Evaluate using the stack's idiomatic concurrency model (see stack-adapters.md).

| Score | Criteria |
|-------|----------|
| 100 | Systematic concurrent execution for independent I/O, dedicated workers/threads for CPU-bound, streaming for large data, bounded concurrency |
| 90 | Concurrent I/O for independent operations, workers for CPU-bound tasks |
| 80 | Concurrent I/O in most places, some sequential-where-parallel-possible |
| 70 | Selective parallelism for known bottlenecks |
| 60 | Some concurrency usage, mostly sequential |
| 40 | Mostly sequential processing |
| 20 | Fully sequential, no concurrency awareness |

### M4.4: Horizontal Scaling Readiness (25% of D4)

| Score | Criteria |
|-------|----------|
| 100 | Stateless processes, externalized sessions, shared-nothing, sticky sessions unnecessary, auto-scaling configured |
| 90 | Stateless, externalized state, auto-scaling ready |
| 80 | Mostly stateless, externalized sessions |
| 70 | Some in-process state but non-critical |
| 60 | In-process state for sessions/cache, could externalize |
| 40 | Significant in-process state, scaling requires refactoring |
| 20 | Process-bound state (file locks, in-process queues, singleton patterns) |

**D4 formula:** `D4 = (M4.1 * 0.25) + (M4.2 * 0.25) + (M4.3 * 0.25) + (M4.4 * 0.25)`

---

## D5: Data Architecture & Flow (Weight: 8%)

**Source:** CQRS (Young), polyglot persistence (Fowler), Designing Data-Intensive Applications (Kleppmann), saga pattern (Garcia-Molina & Salem)

### M5.1: Storage Fit (30% of D5)

Storage fit rules:
- **Relational (PostgreSQL/MySQL)**: Transactional data, complex queries, referential integrity
- **Document (MongoDB/DynamoDB)**: Schema-flexible entities, denormalized reads, variable structure
- **Key-Value (Redis/Memcached)**: Session data, caches, counters, rate limiters
- **Time-Series (TimescaleDB/InfluxDB)**: Metrics, logs, IoT events, telemetry
- **Search (Elasticsearch/OpenSearch)**: Full-text search, log aggregation, faceted queries
- **Object Store (S3/GCS)**: Files, media, backups, large blobs
- **Graph (Neo4j/Neptune)**: Relationship-heavy queries, social networks, recommendation engines

| Score | Criteria |
|-------|----------|
| 100 | All stores optimal for access patterns, documented rationale |
| 90 | 90%+ optimal, polyglot where beneficial |
| 80 | 80%+ optimal |
| 70 | 70%+ optimal, some square-peg/round-hole |
| 60 | Single store for everything, but it fits most patterns |
| 40 | Single store with clear mismatches |
| 20 | Store choice actively hurts performance/correctness |

### M5.2: Data Flow Patterns (30% of D5)

| Score | Criteria |
|-------|----------|
| 100 | Clear data ownership per service, event-carried state transfer, CDC where needed, no shared DB |
| 90 | Data ownership defined, events for cross-boundary sync |
| 80 | Mostly clear ownership, some shared access with contracts |
| 70 | Data ownership emerging, shared DB with schema separation |
| 60 | Shared database, separated by convention |
| 40 | Shared database, no separation conventions |
| 20 | Spaghetti data access, any component queries anything |

### M5.3: Schema Evolution & Migration (20% of D5)

| Score | Criteria |
|-------|----------|
| 100 | Expand-and-contract migrations, automated rollback, backward-compatible changes, schema registry |
| 90 | Versioned migrations, backward-compatible, rollback tested |
| 80 | Versioned migrations, mostly backward-compatible |
| 70 | Migration tool in use, some breaking changes managed |
| 60 | Manual migrations with some process |
| 40 | Ad-hoc schema changes |
| 20 | No migration strategy, manual DDL |

### M5.4: Distributed Transaction Patterns (20% of D5)

| Score | Criteria |
|-------|----------|
| 100 | Saga pattern (orchestration or choreography), compensating transactions, idempotency |
| 90 | Saga for critical flows, compensation defined |
| 80 | Eventual consistency with manual compensation |
| 70 | Two-phase commit where needed, timeouts |
| 60 | Single-DB transactions, awareness of distributed limits |
| 40 | Implicit assumptions about transaction scope |
| 20 | No transaction strategy, data inconsistency possible |

**D5 formula:** `D5 = (M5.1 * 0.30) + (M5.2 * 0.30) + (M5.3 * 0.20) + (M5.4 * 0.20)`

---

## D6: Observability & Operational Maturity (Weight: 5%)

**Source:** OpenTelemetry specification, Google SRE book (Beyer et al.), Distributed Systems Observability (Sridharan)

### M6.1: Structured Logging (25% of D6)

| Score | Criteria |
|-------|----------|
| 100 | JSON/structured logs, correlation IDs propagated, log levels enforced, PII redaction, centralized aggregation |
| 90 | Structured logs with correlation IDs, centralized |
| 80 | Structured logs, some correlation IDs |
| 70 | Consistent log format, basic levels |
| 60 | Logging present but inconsistent format |
| 40 | Unstructured logging scattered throughout codebase |
| 20 | Minimal or no logging |

### M6.2: Distributed Tracing (25% of D6)

| Score | Criteria |
|-------|----------|
| 100 | OpenTelemetry with auto-instrumentation, custom spans for business ops, trace-based alerting |
| 90 | Tracing with auto-instrumentation, custom spans for key paths |
| 80 | Tracing on main request paths |
| 70 | Basic tracing for HTTP requests |
| 60 | Request ID propagation, no tracing system |
| 40 | Some request tracking, no distributed context |
| 20 | No tracing or request tracking |

### M6.3: Metrics & Dashboards (25% of D6)

| Score | Criteria |
|-------|----------|
| 100 | RED/USE metrics, business KPIs, SLI/SLO dashboards, anomaly detection |
| 90 | RED metrics (Rate, Error, Duration) + business metrics, SLO tracking |
| 80 | RED metrics, basic dashboards |
| 70 | Response time and error rate metrics |
| 60 | Basic uptime/health metrics |
| 40 | Some metrics, no dashboards |
| 20 | No metrics collection |

### M6.4: Health Checks & Readiness (25% of D6)

| Score | Criteria |
|-------|----------|
| 100 | Liveness + readiness + startup probes, deep health (DB, cache, queue), dependency map in health |
| 90 | Liveness + readiness probes, dependency health checks |
| 80 | Health endpoint checking critical dependencies |
| 70 | Basic health endpoint (200 OK) |
| 60 | Process-level health only |
| 40 | No health checks |

**D6 formula:** `D6 = (M6.1 * 0.25) + (M6.2 * 0.25) + (M6.3 * 0.25) + (M6.4 * 0.25)`

---

## D7: 12-Factor Compliance (Weight: 7%)

**Source:** The Twelve-Factor App (Wiggins, 2011), CNCF App Delivery SIG

All 12 factors evaluated. Grouped into 4 sub-metrics for scoring efficiency.

### M7.1: Codebase, Dependencies & Build (25% of D7)

Covers Factor I (Codebase), Factor II (Dependencies), Factor V (Build/Release/Run).

| Score | Criteria |
|-------|----------|
| 100 | One codebase per deployable, all deps declared + locked, strict build/release/run separation, reproducible builds |
| 90 | One repo per service, deps locked, clear build pipeline |
| 80 | Monorepo with proper workspace isolation, deps declared |
| 70 | Clear build process, most deps declared, some implicit |
| 60 | Build exists but release/run not separated |
| 40 | Manual build steps, undeclared system dependencies |
| 20 | No defined build process, deps installed ad-hoc |

### M7.2: Config, Backing Services & Port Binding (25% of D7)

Covers Factor III (Config), Factor IV (Backing Services), Factor VII (Port Binding).

| Score | Criteria |
|-------|----------|
| 100 | All config via env/config service + validated at startup, all backing services swappable via config, self-contained with port binding |
| 90 | Config from env + validated, backing services swappable, port binding |
| 80 | Config from env, most services swappable |
| 70 | Most config from env, some hardcoded, port binding present |
| 60 | Mix of env and config files, some services hardcoded |
| 40 | Mostly config files, provider-specific code |
| 20 | Hardcoded values, hardcoded connections, no port binding |

### M7.3: Processes, Concurrency & Disposability (25% of D7)

Covers Factor VI (Processes), Factor VIII (Concurrency), Factor IX (Disposability).

| Score | Criteria |
|-------|----------|
| 100 | Stateless processes, scale-out via process model, startup < 5s, graceful shutdown drains all connections, in-flight work completed |
| 90 | Stateless, process-model concurrency, graceful shutdown with drain |
| 80 | Mostly stateless, graceful shutdown |
| 70 | Some in-process state, SIGTERM handled |
| 60 | Moderate state, basic signal handling |
| 40 | Significant state, abrupt shutdown possible |
| 20 | Stateful processes, no shutdown handling, slow startup |

### M7.4: Dev/Prod Parity, Logs & Admin (25% of D7)

Covers Factor X (Dev/Prod Parity), Factor XI (Logs), Factor XII (Admin Processes).

| Score | Criteria |
|-------|----------|
| 100 | Dev mirrors prod (containers), logs as event streams to stdout, admin tasks as one-off processes in same environment |
| 90 | Same backing services locally, structured stdout logging, admin scripts versioned |
| 80 | Same service types locally, logging to stdout |
| 70 | Local substitutes for some services, file-based logging |
| 60 | Significant env differences, mixed logging targets |
| 40 | Major env differences, logging to files, manual admin tasks |
| 20 | Dev fundamentally different, no log strategy, SSH-and-pray admin |

**D7 formula:** `D7 = (M7.1 * 0.25) + (M7.2 * 0.25) + (M7.3 * 0.25) + (M7.4 * 0.25)`

---

## D8: Deployment & Runtime Architecture (Weight: 6%)

**Source:** CNCF Trail Map, GitOps (Weaveworks), Continuous Delivery (Humble & Farley), Infrastructure as Code (Morris)

### M8.1: Containerization & Packaging (25% of D8)

| Score | Criteria |
|-------|----------|
| 100 | Multi-stage build, minimal base image, non-root, layer caching, security scanning, SBOM |
| 90 | Multi-stage build, security scanning |
| 80 | Container with good practices |
| 70 | Basic container |
| 60 | Containerized but unoptimized |
| 40 | Process manager but no container |
| 20 | Manual deployment, no packaging |

### M8.2: CI/CD Pipeline Maturity (25% of D8)

| Score | Criteria |
|-------|----------|
| 100 | Trunk-based dev, automated test/build/deploy, deployment gates, rollback automation, pipeline as code |
| 90 | Automated pipeline, test gates, rollback support |
| 80 | CI/CD with automated tests and deploy |
| 70 | CI with tests, manual deploy |
| 60 | CI with tests, scripted deploy |
| 40 | Some CI, manual deploy process |
| 20 | No CI/CD, manual everything |

### M8.3: Release Strategy (25% of D8)

| Score | Criteria |
|-------|----------|
| 100 | Canary + blue/green, automated rollback on metrics, feature flags for progressive rollout |
| 90 | Blue/green deployment, feature flags |
| 80 | Rolling updates with health checks |
| 70 | Rolling updates, basic health checks |
| 60 | Full replacement with maintenance window |
| 40 | Manual deployment with downtime |
| 20 | No release strategy, cowboy deploys |

### M8.4: Infrastructure as Code (25% of D8)

| Score | Criteria |
|-------|----------|
| 100 | All infra in code (Terraform/Pulumi/CDK), GitOps workflow, drift detection, state locking |
| 90 | IaC for all resources, PR-based changes |
| 80 | IaC for main resources, some manual |
| 70 | IaC for compute/network, storage manual |
| 60 | Partial IaC, significant manual config |
| 40 | Mostly manual with some scripts |
| 20 | All manual, no infrastructure code |

**D8 formula:** `D8 = (M8.1 * 0.25) + (M8.2 * 0.25) + (M8.3 * 0.25) + (M8.4 * 0.25)`

---

## D9: Security Architecture (Weight: 10%)

**Source:** NIST SP 800-207 (Zero Trust Architecture, 2020), SLSA Supply Chain Framework (Google, 2021), OWASP Application Security Architecture Guide (2023), BeyondCorp (Google, 2014), HashiCorp Vault Architecture Patterns

### M9.1: Zero Trust & Service-to-Service Auth (30% of D9)

| Score | Criteria |
|-------|----------|
| 100 | mTLS between all services (service mesh or native), identity-based policies, no implicit trust from network position |
| 90 | mTLS for critical paths, service identity verified, network policies enforced |
| 80 | Service-to-service JWT/token auth, network segmentation |
| 70 | Shared API keys between services, basic network isolation |
| 60 | API keys with rotation, flat network |
| 40 | Hardcoded service credentials, no network segmentation |
| 20 | No service-to-service auth, trust based on network position |

### M9.2: Secrets Management (25% of D9)

| Score | Criteria |
|-------|----------|
| 100 | Centralized vault (HashiCorp Vault/AWS Secrets Manager), dynamic credentials, automatic rotation, lease-based access, audit trail |
| 90 | Vault for all secrets, automatic rotation for critical credentials |
| 80 | Vault for most secrets, manual rotation policy |
| 70 | Cloud provider secrets manager, rotation for some credentials |
| 60 | Encrypted env files, no rotation |
| 40 | Plain env vars, no rotation, shared credentials |
| 20 | Secrets in code, config files, or unencrypted storage |

### M9.3: Supply Chain Security (25% of D9)

| Score | Criteria |
|-------|----------|
| 100 | SLSA Level 3+, signed artifacts, SBOM generated, dependency scanning in CI, pinned + verified deps, provenance attestation |
| 90 | Signed artifacts, SBOM, dependency scanning, pinned deps |
| 80 | Dependency scanning in CI, lockfile enforced, base image pinned |
| 70 | Dependency scanning periodic, lockfile present |
| 60 | Lockfile present, occasional manual audit |
| 40 | Lockfile present, no scanning |
| 20 | No lockfile, no dependency scanning, unpinned base images |

### M9.4: Authorization Architecture (20% of D9)

| Score | Criteria |
|-------|----------|
| 100 | Policy-as-code (OPA/Cedar), centralized policy engine, ABAC, audit trail, least-privilege enforced, row-level security |
| 90 | Centralized authorization service, RBAC with granular roles, audit trail |
| 80 | RBAC with role hierarchy, authorization middleware consistent |
| 70 | Basic RBAC, roles per endpoint, some gaps |
| 60 | Simple role checks, inconsistent enforcement |
| 40 | Binary auth (authenticated vs not), no granular permissions |
| 20 | No authorization strategy, or auth checks scattered ad-hoc |

**D9 formula:** `D9 = (M9.1 * 0.30) + (M9.2 * 0.25) + (M9.3 * 0.25) + (M9.4 * 0.20)`

---

## D10: Multi-Tenancy & Isolation (Weight: 10%)

**Source:** AWS SaaS Lens (Well-Architected, 2023), Azure Multi-Tenant Architecture Guide (Microsoft, 2023), SaaS Architecture Fundamentals (AWS, 2022), Multi-Tenant Data Architecture (Chong et al.)

### M10.1: Tenant Isolation Strategy (30% of D10)

| Score | Criteria |
|-------|----------|
| 100 | Isolation enforced at infra level (separate DBs/schemas + network policies + compute isolation), isolation validated by automated tests, blast radius = single tenant |
| 90 | Separate schemas per tenant, network isolation, compute shared with resource limits |
| 80 | Separate schemas, shared compute with tenant-aware resource quotas |
| 70 | Row-level security with tenant_id, shared schema, enforced at DB level |
| 60 | Application-level tenant filtering (WHERE tenant_id =), no DB-level enforcement |
| 40 | Tenant filtering in some queries, inconsistent enforcement |
| 20 | No tenant isolation, shared data without filtering |

### M10.2: Tenant Context Propagation (25% of D10)

| Score | Criteria |
|-------|----------|
| 100 | Tenant context injected at edge, propagated through all layers (middleware, queues, events, cron), validated at every boundary, immutable after injection |
| 90 | Tenant context in middleware, propagated to queues and events, validated at entry |
| 80 | Tenant context middleware, propagated to most async flows |
| 70 | Tenant context in request scope, some async flows lose context |
| 60 | Tenant ID extracted per-request, manual propagation |
| 40 | Tenant ID passed as parameter, inconsistent |
| 20 | No systematic tenant context, derived from data ad-hoc |

### M10.3: Noisy Neighbor Protection (25% of D10)

| Score | Criteria |
|-------|----------|
| 100 | Per-tenant rate limits, per-tenant resource quotas (CPU/memory/connections/storage), per-tenant queue priority, fairness scheduling, tenant-level circuit breakers |
| 90 | Per-tenant rate limits, resource quotas, queue fairness |
| 80 | Per-tenant rate limits, basic resource quotas |
| 70 | Per-tenant rate limits, shared resources with monitoring |
| 60 | Global rate limits, per-tenant usage monitoring |
| 40 | Global rate limits only, no per-tenant visibility |
| 20 | No rate limiting, no resource quotas, one tenant can starve others |

### M10.4: Tenant Lifecycle Management (20% of D10)

| Score | Criteria |
|-------|----------|
| 100 | Automated provisioning/deprovisioning, data export (GDPR), tenant-specific config (feature flags, limits), tenant migration between tiers, usage metering |
| 90 | Automated provisioning, data export, per-tenant feature flags |
| 80 | Automated provisioning, manual data export, some per-tenant config |
| 70 | Semi-automated provisioning, basic tenant config |
| 60 | Manual provisioning with scripts, minimal tenant config |
| 40 | Manual provisioning, no data export capability |
| 20 | Ad-hoc tenant setup, no lifecycle management |

**D10 formula:** `D10 = (M10.1 * 0.30) + (M10.2 * 0.25) + (M10.3 * 0.25) + (M10.4 * 0.20)`

---

## D11: AI/ML Integration Patterns (Weight: 10%)

**Source:** Google MLOps Maturity Model (2021), CNCF AI Whitepaper (2024), Designing Machine Learning Systems (Huyen, 2022), LLMOps patterns (emerging consensus), Anthropic/OpenAI best practices for production LLM systems

### M11.1: Model Serving & Inference Architecture (25% of D11)

| Score | Criteria |
|-------|----------|
| 100 | Model gateway with provider abstraction, A/B testing, shadow mode, automatic failover between providers, response caching, streaming support, cost tracking per request |
| 90 | Provider abstraction layer, failover between providers, streaming, cost tracking |
| 80 | Provider abstraction, basic failover, streaming support |
| 70 | Single provider with retry logic, streaming support |
| 60 | Direct API calls with error handling, basic retry |
| 40 | Direct API calls, minimal error handling |
| 20 | Hardcoded API calls, no abstraction, no error handling |

### M11.2: RAG & Embedding Pipeline (25% of D11)

| Score | Criteria |
|-------|----------|
| 100 | Vector store with hybrid search (dense + sparse), chunking strategy documented, embedding versioning, incremental indexing, relevance evaluation pipeline, re-ranking |
| 90 | Vector store with semantic search, documented chunking, embedding versioning, incremental index |
| 80 | Vector store with semantic search, consistent chunking strategy |
| 70 | Vector store, basic chunking, full re-index on update |
| 60 | Simple embedding search, ad-hoc chunking |
| 40 | Text similarity without proper embeddings |
| 20 | No retrieval augmentation, or context stuffing without relevance |

### M11.3: Prompt Engineering & LLM Management (25% of D11)

| Score | Criteria |
|-------|----------|
| 100 | Prompt versioning + registry, structured output schemas, guardrails (input/output validation), token budget management, prompt testing suite, observability (token usage, latency, quality scores) |
| 90 | Prompt versioning, structured outputs, guardrails, token tracking |
| 80 | Prompt templates versioned, structured outputs, basic guardrails |
| 70 | Prompt templates in code, some output validation |
| 60 | Prompts in code, manual testing |
| 40 | Inline prompts, no validation or versioning |
| 20 | Ad-hoc prompts, no structure, no validation |

### M11.4: MLOps Lifecycle & Feedback (25% of D11)

| Score | Criteria |
|-------|----------|
| 100 | Automated evaluation pipeline, human-in-the-loop feedback collection, model performance monitoring, data flywheel (feedback -> fine-tuning/RAG improvement), A/B testing framework, cost optimization |
| 90 | Evaluation pipeline, feedback collection, performance monitoring, cost tracking |
| 80 | Basic evaluation metrics, feedback collection, monitoring |
| 70 | Manual evaluation, some feedback collection |
| 60 | Ad-hoc evaluation, no systematic feedback |
| 40 | No evaluation beyond manual testing |
| 20 | No evaluation, no monitoring, no feedback loop |

**D11 formula:** `D11 = (M11.1 * 0.25) + (M11.2 * 0.25) + (M11.3 * 0.25) + (M11.4 * 0.25)`

---

## Overall Score Formula

```
Overall = (D1 * 0.10) + (D2 * 0.14) + (D3 * 0.10) + (D4 * 0.10)
        + (D5 * 0.08) + (D6 * 0.05) + (D7 * 0.07) + (D8 * 0.06)
        + (D9 * 0.10) + (D10 * 0.10) + (D11 * 0.10)
```

---

## Framework Sources

| Dimension | Primary Source | Key Reference |
|-----------|---------------|---------------|
| D1 | Enterprise Integration Patterns (Hohpe & Woolf, 2003) | Ch. 3-4: Messaging Patterns, Protocol Selection |
| D2 | EIP + Reactive Manifesto (2014) | Message Channel, Competing Consumers, Event Sourcing |
| D3 | POSA Vol. 1-4 + Release It! (Nygard, 2018) | Circuit Breaker, Bulkhead, Stability Patterns |
| D4 | CNCF + AWS Well-Architected (Performance Pillar) | Cache-Aside, Connection Pooling, Auto-Scaling |
| D5 | Designing Data-Intensive Applications (Kleppmann, 2017) | Ch. 5-9: Replication, Partitioning, Transactions |
| D6 | Google SRE Book + OpenTelemetry Spec | Ch. 6: Monitoring, Distributed Tracing, SLI/SLO |
| D7 | The Twelve-Factor App (Wiggins, 2011) | All 12 Factors |
| D8 | Continuous Delivery (Humble & Farley, 2010) + CNCF Trail Map | Deployment Pipeline, IaC, Progressive Delivery |
| D9 | NIST SP 800-207 + SLSA + OWASP Architecture Guide | Zero Trust, Supply Chain Levels, Security Patterns |
| D10 | AWS SaaS Lens + Azure Multi-Tenant Guide | Tenant Isolation, Noisy Neighbor, Lifecycle |
| D11 | Google MLOps Maturity + Designing ML Systems (Huyen) | Model Serving, RAG, Prompt Mgmt, Feedback Loops |

---

## ADR Template Reference

Each ADR in the opportunity map should follow this structure:

```
### ADR-NNN: [Decision Title]

- **Status**: Proposed
- **Pattern**: [Pattern name from framework catalog]
- **Framework**: [Source framework and specific pattern reference]
- **Context**: [Current state — what exists, what problem it causes]
- **Decision**: [Proposed pattern with specific components/tools]
- **Stack Implementation**: [Concrete library/tool for the detected stack]
- **Consequences**:
  - Score impact: +[N] points on D[X] ([current] -> [projected])
  - Positive: [benefits]
  - Negative: [tradeoffs, added complexity]
  - Risk: [migration risk, learning curve]
- **Effort**: [S/M/L] — [sizing rationale]
- **Affected paths**: [list of request flows impacted]
```

This follows the ADR format from Michael Nygard's "Documenting Architecture Decisions" (2011),
extended with score impact tracking and stack-specific implementation guidance.
