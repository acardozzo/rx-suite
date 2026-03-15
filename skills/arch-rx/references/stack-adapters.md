# Stack Adapters — Pattern-to-Implementation Mapping

> Maps abstract architectural patterns to concrete implementations per runtime stack.
> Read this file after detecting the project's stack in Step 1.

---

## Stack Detection

| Indicator File | Stack | Common Frameworks |
|---|---|---|
| `package.json` | Node.js/TypeScript | Express, Fastify, Hono, NestJS, Next.js |
| `go.mod` | Go | Gin, Fiber, Echo, Chi, stdlib net/http |
| `pom.xml` / `build.gradle` | Java/Kotlin (JVM) | Spring Boot, Quarkus, Micronaut, Ktor |
| `Cargo.toml` | Rust | Actix-web, Axum, Rocket, Warp |
| `requirements.txt` / `pyproject.toml` | Python | FastAPI, Django, Flask, Starlette |
| `*.csproj` / `*.fsproj` | .NET | ASP.NET Core, Minimal APIs |

---

## D2: Async & Event — Queue Infrastructure

| Pattern | Node.js | Go | JVM | Python | Rust | .NET |
|---|---|---|---|---|---|---|
| **Task Queue** | BullMQ, Agenda | Asynq, Machinery | Spring Batch, Quartz | Celery, RQ, Dramatiq | Tokio tasks + Redis | Hangfire, MassTransit |
| **Message Broker** | AMQP (amqplib), Kafka (kafkajs) | Sarama, Watermill | Spring AMQP, Spring Kafka | Kombu, confluent-kafka | Lapin, rdkafka | MassTransit, NServiceBus |
| **Event Bus (in-process)** | EventEmitter, RxJS | Go channels | Spring Events, Guava EventBus | Blinker, PyPubSub | tokio::broadcast | MediatR, EventAggregator |
| **Managed Queue** | SQS (aws-sdk), Cloud Tasks | SQS (aws-sdk-go), Pub/Sub | SQS (aws-sdk-java), SNS | Boto3 (SQS), Cloud Tasks | Rusoto/aws-sdk, Pub/Sub | AWS SDK, Azure Service Bus |

---

## D3: Resilience — Circuit Breaker & Retry

| Pattern | Node.js | Go | JVM | Python | Rust | .NET |
|---|---|---|---|---|---|---|
| **Circuit Breaker** | opossum, cockatiel | sony/gobreaker, hystrix-go | Resilience4j, Spring Circuit Breaker | pybreaker, tenacity | recloser, failsafe-rs | Polly |
| **Retry + Backoff** | p-retry, cockatiel | cenkalti/backoff, avast/retry-go | Resilience4j Retry, Spring Retry | tenacity, backoff | again, tokio-retry | Polly Retry |
| **Bulkhead** | p-limit, bottleneck | semaphore (sync pkg), errgroup | Resilience4j Bulkhead, Hystrix | asyncio.Semaphore | tokio::sync::Semaphore | Polly Bulkhead |
| **Rate Limiter** | rate-limiter-flexible, bottleneck | golang.org/x/time/rate | Bucket4j, Resilience4j RateLimiter | limits, slowapi | governor | Polly RateLimit |

---

## D4: Scalability — Concurrency Patterns

| Pattern | Node.js | Go | JVM | Python | Rust | .NET |
|---|---|---|---|---|---|---|
| **Concurrent I/O** | Promise.all/allSettled | goroutines + errgroup | CompletableFuture, Virtual Threads | asyncio.gather, TaskGroup | tokio::join!, futures::join_all | Task.WhenAll |
| **CPU-bound work** | worker_threads, child_process | goroutines (natively parallel) | ForkJoinPool, parallel streams | multiprocessing, ProcessPoolExecutor | rayon, tokio::spawn_blocking | Parallel.ForEach, Task.Run |
| **Bounded concurrency** | p-limit, p-queue | semaphore + errgroup | Semaphore, ThreadPoolExecutor | asyncio.Semaphore, ThreadPoolExecutor | tokio::sync::Semaphore | SemaphoreSlim, Channel |
| **Streaming** | Node Streams, AsyncIterator | io.Reader/Writer, channels | Reactor Flux, RxJava | async generators, aiostream | tokio::io, futures::Stream | IAsyncEnumerable, Channel |
| **Worker Pool** | workerpool, piscina | ants, gammazero/workerpool | ExecutorService, ForkJoinPool | concurrent.futures | rayon::ThreadPool | System.Threading.Channels |

---

## D4: Scalability — Caching

| Pattern | Node.js | Go | JVM | Python | Rust | .NET |
|---|---|---|---|---|---|---|
| **In-process L1** | node-cache, lru-cache | bigcache, ristretto, freecache | Caffeine, Guava Cache | cachetools, lru_cache | moka, cached | MemoryCache, LazyCache |
| **Distributed L2** | ioredis, redis | go-redis/redis | Redisson, Lettuce, Spring Cache | redis-py, aiocache | redis-rs, deadpool-redis | StackExchange.Redis |
| **Cache-aside** | Manual get/set pattern | Manual get/set pattern | Spring @Cacheable | Django cache framework | Manual with redis-rs | IDistributedCache |

---

## D6: Observability

| Pattern | Node.js | Go | JVM | Python | Rust | .NET |
|---|---|---|---|---|---|---|
| **Structured Logging** | pino, winston | zerolog, zap, slog | SLF4J + Logback/Log4j2 | structlog, python-json-logger | tracing, slog | Serilog, NLog |
| **Tracing** | @opentelemetry/sdk-node | go.opentelemetry.io/otel | OpenTelemetry Java, Micrometer Tracing | opentelemetry-python | opentelemetry-rust, tracing | OpenTelemetry .NET |
| **Metrics** | prom-client, @opentelemetry/metrics | prometheus/client_golang | Micrometer, Prometheus Java | prometheus_client | prometheus, metrics | prometheus-net, App Metrics |
| **Health Checks** | terminus, lightship | heptio/healthcheck | Spring Actuator, MicroProfile Health | django-health-check, py-healthcheck | actix-web health, custom | AspNetCore.Diagnostics.HealthChecks |

---

## D9: Security Architecture

| Pattern | Node.js | Go | JVM | Python | Rust | .NET |
|---|---|---|---|---|---|---|
| **mTLS / Service Mesh** | Istio/Linkerd sidecar, node-forge | Istio/Linkerd sidecar, crypto/tls | Istio/Linkerd sidecar, Netty SSL | Istio/Linkerd sidecar, ssl module | Istio/Linkerd sidecar, rustls | Istio/Linkerd sidecar, Kestrel mTLS |
| **Secrets Manager** | @aws-sdk/secrets-manager, node-vault | aws-sdk-go (Secrets Manager), hashicorp/vault | Spring Vault, AWS SDK | boto3 (Secrets Manager), hvac | aws-sdk, vaultrs | Azure.Security.KeyVault, AWS SDK |
| **Dependency Scanning** | npm audit, Snyk, Socket | govulncheck, nancy | OWASP Dependency-Check, Snyk | pip-audit, Safety, Bandit | cargo-audit, cargo-deny | dotnet-outdated, Snyk |
| **Policy Engine** | @open-policy-agent/opa-wasm, cerbos | OPA Go SDK, Casbin | OPA Java, Spring Security + custom | OPA Python, Casbin, django-rules | opa-wasm, casbin-rs | Casbin.NET, PolicyServer |

---

## D10: Multi-Tenancy

| Pattern | Node.js | Go | JVM | Python | Rust | .NET |
|---|---|---|---|---|---|---|
| **RLS / Row-Level Security** | Supabase RLS, Prisma middleware | sqlc + custom middleware | Hibernate Filters, Spring @TenantId | Django-tenants, SQLAlchemy events | SeaORM scopes, Diesel custom | EF Core Global Query Filters |
| **Tenant Context Middleware** | cls-hooked, AsyncLocalStorage | context.Context propagation | Spring ThreadLocal, MDC | contextvars, Django middleware | tokio::task_local | AsyncLocal, HttpContext |
| **Per-Tenant Rate Limiting** | rate-limiter-flexible (key=tenant) | golang.org/x/time/rate per key | Bucket4j (key=tenant) | slowapi (key=tenant) | governor (keyed) | Polly RateLimit (keyed) |
| **Tenant Provisioning** | Custom + migration runner | Custom + golang-migrate | Flyway/Liquibase multi-tenant | Django-tenants auto-provisioning | Custom + refinery | EF Core migrations per tenant |

---

## D11: AI/ML Integration

| Pattern | Node.js | Go | JVM | Python | Rust | .NET |
|---|---|---|---|---|---|---|
| **LLM Provider Abstraction** | LiteLLM, AI SDK (Vercel), langchain.js | go-openai, langchaingo | LangChain4j, Spring AI | LiteLLM, LangChain, Anthropic SDK | llm-chain, async-openai | Semantic Kernel, LangChain.NET |
| **Vector Store** | Pinecone SDK, pgvector (pg), Qdrant | pgvector (pgx), Qdrant client | pgvector (JDBC), Weaviate, Milvus | pgvector (asyncpg), ChromaDB, FAISS | qdrant-client, pgvector | Qdrant.NET, pgvector (Npgsql) |
| **Prompt Management** | Handlebars/Mustache, promptfoo | Go templates, promptfoo | Thymeleaf, JMustache | Jinja2, promptfoo, LangSmith | tera templates | Scriban, Semantic Kernel templates |
| **Evaluation & Monitoring** | promptfoo, Langfuse, Braintrust | Langfuse Go client, custom | LangSmith, Langfuse Java | promptfoo, Langfuse, Braintrust, Ragas | custom metrics | Langfuse .NET, custom |
| **Guardrails** | Guardrails AI (JS), Zod schemas | custom validation | Guardrails Java, Spring Validation | Guardrails AI, NeMo Guardrails | custom validation | Semantic Kernel filters |
| **Streaming LLM** | Vercel AI SDK streams, ReadableStream | SSE with io.Reader | Spring WebFlux SSE, Reactor | FastAPI StreamingResponse, aiohttp | axum SSE, tokio streams | IAsyncEnumerable, SignalR |

---

## D1: Communication — Protocol Libraries

| Protocol | Node.js | Go | JVM | Python | Rust | .NET |
|---|---|---|---|---|---|---|
| **gRPC** | @grpc/grpc-js, nice-grpc | google.golang.org/grpc | grpc-java, Spring gRPC | grpcio, grpclib | tonic | Grpc.Net.Client |
| **GraphQL** | Apollo Server, Mercurius | gqlgen, graphql-go | Spring GraphQL, Netflix DGS | Strawberry, Ariadne | async-graphql, juniper | HotChocolate |
| **WebSocket** | ws, socket.io | gorilla/websocket, nhooyr.io | Spring WebSocket, Netty | websockets, FastAPI WebSocket | tokio-tungstenite | SignalR |
| **SSE** | Native Response stream | r3labs/sse, custom | Spring WebFlux SSE | sse-starlette, aiohttp | axum SSE, actix-web | ASP.NET SSE |
| **Message Queue Client** | amqplib, kafkajs, bullmq | Watermill, Sarama | Spring AMQP/Kafka | Celery, Kombu | Lapin, rdkafka | MassTransit, NServiceBus |

---

## Usage in ADRs

When generating ADR recommendations, use this table to populate the **Stack Implementation** field.

Example for a Node.js project:
```
### ADR-003: Add Circuit Breaker to External API Calls
- **Pattern**: Circuit Breaker (POSA)
- **Stack Implementation**: `opossum` with `cockatiel` for retry+backoff composition
- ...
```

Example for a Go project:
```
### ADR-003: Add Circuit Breaker to External API Calls
- **Pattern**: Circuit Breaker (POSA)
- **Stack Implementation**: `sony/gobreaker` with `cenkalti/backoff` for retry composition
- ...
```

Always prefer the most actively maintained and widely adopted library for the detected stack.
When multiple options exist, recommend the one with the best fit for the project's existing
dependency tree and framework conventions.
