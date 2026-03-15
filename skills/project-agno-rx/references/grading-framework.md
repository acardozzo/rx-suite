# project-agno-rx Grading Framework

Complete threshold tables for all 40 sub-metrics with Agno-specific criteria, plus framework source references.

---

## Table of Contents

1. [Sub-Metric Threshold Tables (All 40)](#1-sub-metric-threshold-tables)
2. [Framework Sources](#2-framework-sources)

---

## 1. Sub-Metric Threshold Tables

### D1: Agent Design & Configuration (12%)

#### M1.1: Agent Definition Quality

| Score | Criteria |
|-------|----------|
| 100 | Agent has `name`, `description`, `model` (appropriate for task), `instructions` (detailed, multi-line), `markdown=True`, appropriate `tools`, `output_schema` when structured output needed, `add_datetime_to_instructions=True`, `reasoning_model` for complex tasks |
| 85 | Agent has `name`, `model`, `instructions` (clear and specific), `tools` configured, `markdown=True` |
| 70 | Agent has `model` and basic `instructions`, at least one tool assigned |
| 40 | `Agent()` created with minimal config -- default model, no instructions or generic one-liner |
| 0 | No `Agent` class usage found; raw API calls to LLM providers instead |

#### M1.2: Structured I/O

| Score | Criteria |
|-------|----------|
| 100 | `output_schema` with well-documented Pydantic models, `response_model` for typed responses, input validation via Pydantic, consistent structured output across all agents, field descriptions and validators |
| 85 | `output_schema` used with Pydantic models that have proper field types and descriptions |
| 70 | `output_schema` used with basic Pydantic model (fields but minimal validation/descriptions) |
| 40 | Pydantic models defined but not connected to agents via `output_schema`; or agents parse JSON manually from string responses |
| 0 | No structured output; agents return raw strings, caller parses manually |

#### M1.3: Context Management

| Score | Criteria |
|-------|----------|
| 100 | `num_history_runs` tuned per agent, `add_history_to_messages=True`, `session_id` managed properly, `storage` configured with PostgreSQL, session persistence across restarts, context window management with summarization |
| 85 | `num_history_runs` set, `session_id` used, `storage` configured (PostgreSQL or SQLite), history enabled |
| 70 | `add_history_to_messages=True` with default settings, basic session tracking |
| 40 | No explicit context config; relying on Agno defaults without understanding implications |
| 0 | No context management; each agent call is stateless with no history |

#### M1.4: Agent Reuse

| Score | Criteria |
|-------|----------|
| 100 | Agents defined at module level or via factory pattern, shared across requests, `session_id` parameterized per user/request, agent registry pattern, lazy initialization |
| 85 | Agents defined at module level or in a dedicated agents module, not recreated per request |
| 70 | Agents created once per application lifecycle (e.g., in `__init__` or startup), reused within scope |
| 40 | Agents created in request handlers but at least factored into helper functions |
| 0 | Agents created inside loops or recreated on every single request/call -- violates AGENTS.md anti-pattern |

---

### D2: Tool Integration (12%)

#### M2.1: Tool Selection

| Score | Criteria |
|-------|----------|
| 100 | Uses Agno built-in tools where available (DuckDuckGoTools, YFinanceTools, FileTools, ShellTools, etc.), custom tools only for domain-specific needs, tool selection matches agent purpose, no redundant tools |
| 85 | Uses several built-in Agno tools appropriately, custom tools for domain needs, good tool-agent fit |
| 70 | Uses at least one Agno built-in tool, some tools assigned to agents |
| 40 | Tools imported but from external libraries when Agno built-in exists; or tools assigned but not relevant to agent purpose |
| 0 | No tools used; agents have no tool capabilities, or all tool calls are hardcoded outside the agent |

#### M2.2: Tool Configuration

| Score | Criteria |
|-------|----------|
| 100 | `cache_results=True` for expensive tools, `show_result=True/False` configured per tool, `confirm=True` for dangerous operations, tool timeout settings, result post-processing |
| 85 | `cache_results` and `show_result` configured where appropriate, `confirm` on write operations |
| 70 | Tools used with some configuration beyond defaults (e.g., `show_result=False` for internal tools) |
| 40 | All tools used with default configuration, no customization |
| 0 | No tools configured on any agent |

#### M2.3: Custom Tool Quality

| Score | Criteria |
|-------|----------|
| 100 | `@tool` decorator with comprehensive docstrings (description, args, returns), full type hints, proper error handling with meaningful messages, retry logic for external calls, logging |
| 85 | `@tool` decorator with good docstrings and type hints, try/except error handling |
| 70 | `@tool` decorator used, basic docstring present, type hints on parameters |
| 40 | Custom functions passed as tools but missing `@tool` decorator, or no docstrings (LLM cannot understand tool purpose) |
| 0 | No custom tools; or custom tools implemented outside Agno's tool system (raw function calls in instructions) |

#### M2.4: Tool Composition

| Score | Criteria |
|-------|----------|
| 100 | Custom `Toolkit` subclasses with `register()` for related tools, factory functions for dynamic tool sets based on context, tool inheritance patterns, composable toolkit combinations |
| 85 | Custom `Toolkit` subclass grouping related tools, `register()` used properly |
| 70 | Tools organized in separate modules, logically grouped even if not using Toolkit class |
| 40 | All tools defined in a single file with no organization, flat list on agent |
| 0 | No tool composition; single tools scattered across codebase with no pattern |

---

### D3: Knowledge & RAG (10%)

#### M3.1: Vector Store Setup

| Score | Criteria |
|-------|----------|
| 100 | Production vector DB (`PgVector2`, `Pinecone`, `Qdrant`, `Weaviate`) with proper connection pooling, index configuration, collection management, backup strategy, separate collections per knowledge domain |
| 85 | Production vector DB configured with proper connection settings, appropriate index type |
| 70 | Vector DB configured (can be `LanceDb` or `ChromaDb` for dev), knowledge base loads documents |
| 40 | Vector DB imported but not properly configured; or using in-memory vector store for what appears to be a production app |
| 0 | No vector store; no RAG capability; knowledge not used |

#### M3.2: Chunking Strategy

| Score | Criteria |
|-------|----------|
| 100 | `AgenticChunking` or `SemanticChunking` with tuned parameters, different strategies per document type, chunking evaluation/testing, overlap configured, metadata preservation |
| 85 | `SemanticChunking` or `RecursiveChunking` with configured chunk size and overlap |
| 70 | `RecursiveChunking` or `FixedSizeChunking` with reasonable chunk size (not default) |
| 40 | `FixedSizeChunking` with default parameters, no consideration of document structure |
| 0 | No chunking configured; documents loaded as-is or knowledge not used |

#### M3.3: Embedding Configuration

| Score | Criteria |
|-------|----------|
| 100 | Embedding model chosen for domain (e.g., code embeddings for code, multilingual for international), dimension explicitly set, batch processing configured, embedding cache, model version pinned |
| 85 | Appropriate embedder (`OpenAIEmbedder`, `OllamaEmbedder`, etc.) with model specified and dimensions set |
| 70 | Embedder configured with explicit model selection (not just defaults) |
| 40 | Using default embedder without explicit configuration; dimension mismatch possible |
| 0 | No embedder configured; or knowledge system not used |

#### M3.4: Search Quality

| Score | Criteria |
|-------|----------|
| 100 | `hybrid_search=True` with reranking (`CohereReranker`, `CrossEncoderReranker`), `score_threshold` tuned, agentic filtering, metadata filtering, search evaluation metrics tracked |
| 85 | `hybrid_search=True`, reranker configured, reasonable `limit` and `score_threshold` |
| 70 | Vector search with `limit` configured, basic similarity search working |
| 40 | Default search with no tuning; returning too many or too few results |
| 0 | No search configured; knowledge base exists but agent does not search it |

---

### D4: Memory & Learning (10%)

#### M4.1: Memory Manager Setup

| Score | Criteria |
|-------|----------|
| 100 | `MemoryManager` with PostgreSQL backend (`PgMemoryDb`), connection pooling, memory namespacing per user/agent, TTL configuration, memory migration strategy |
| 85 | `MemoryManager` with persistent DB backend (PostgreSQL or dedicated store), proper initialization |
| 70 | `MemoryManager` configured with SQLite or basic persistent storage |
| 40 | Memory mentioned in code but using in-memory storage; or `MemoryManager` imported but not connected to agents |
| 0 | No `MemoryManager`; agents have no memory capabilities |

#### M4.2: Memory Types Used

| Score | Criteria |
|-------|----------|
| 100 | `create_user_memories=True`, `create_session_summary=True`, entity memories, user profiles, memory categorization, memory retrieval strategies per context |
| 85 | User memories and session summaries enabled, at least two memory types active |
| 70 | `create_user_memories=True` or `create_session_summary=True` -- at least one memory type |
| 40 | MemoryManager exists but only default memory types, no explicit configuration of what to remember |
| 0 | No memory types configured; or no MemoryManager |

#### M4.3: Memory Optimization

| Score | Criteria |
|-------|----------|
| 100 | `update_user_memories_after_run` configured, memory summarization for long sessions, cleanup of stale memories, memory deduplication, size limits, relevance scoring |
| 85 | Memory update frequency configured, summarization enabled for long conversations |
| 70 | Basic memory management with `update_user_memories_after_run=True` |
| 40 | Memory grows unbounded; no cleanup or optimization strategy |
| 0 | No memory optimization; or no memory system |

#### M4.4: Learning Integration

| Score | Criteria |
|-------|----------|
| 100 | Decision logging for agent choices, user preference tracking across sessions, `learnings` context injection, feedback loops where user corrections update agent behavior, A/B preference learning |
| 85 | User preferences tracked and injected into agent context, learnings from past interactions |
| 70 | Basic preference tracking; agent adapts based on stored user memories |
| 40 | Memory stores data but agent does not use past learnings to improve responses |
| 0 | No learning integration; every interaction starts from scratch |

---

### D5: Team & Multi-Agent (10%)

#### M5.1: Team Design

| Score | Criteria |
|-------|----------|
| 100 | `Team` mode matches use case perfectly (`"coordinate"` for collaborative tasks, `"router"` for classification/routing, `"broadcast"` for parallel independent tasks), team `instructions` explain delegation strategy, `enable_agentic_context=True` |
| 85 | Appropriate `Team` mode selected with clear `instructions`, members well-defined |
| 70 | `Team` used with appropriate mode, basic member assignment |
| 40 | `Team` created but mode does not match use case (e.g., `"broadcast"` when `"router"` needed) |
| 0 | No `Team` usage; single agents only (acceptable for simple projects -- mark N/A if project is genuinely single-agent) |

#### M5.2: Member Specialization

| Score | Criteria |
|-------|----------|
| 100 | Each team member has distinct `name`, `role`, `description`, `instructions`, specialized `tools`, appropriate `model` per complexity, no overlapping capabilities, clear handoff boundaries |
| 85 | Members have distinct roles, specialized tools, clear instructions differentiating their purpose |
| 70 | Members have different names and tools but instructions/roles could overlap |
| 40 | Team members are nearly identical; same tools and generic instructions |
| 0 | No team members; or team has only one agent (not actually multi-agent) |

#### M5.3: Shared Resources

| Score | Criteria |
|-------|----------|
| 100 | Shared memory across team, distributed knowledge bases with per-agent filtering, session context sharing, shared state management, team-level memory summaries |
| 85 | Shared memory or knowledge configured, session context shared between members |
| 70 | Basic resource sharing (e.g., same knowledge base assigned to multiple agents) |
| 40 | Team members operate in isolation; no shared context or resources |
| 0 | No shared resources; or no team |

#### M5.4: Coordination Quality

| Score | Criteria |
|-------|----------|
| 100 | Team `instructions` with clear delegation rules, error handling for failed member tasks, fallback delegation, conversation threading, result aggregation logic, inter-agent communication patterns |
| 85 | Clear team instructions, delegation works reliably, basic error handling |
| 70 | Team coordinates but instructions are generic; delegation mostly works |
| 40 | Team created but coordination is poor; members get confused about responsibilities |
| 0 | No coordination; or no team |

---

### D6: Workflow Orchestration (8%)

#### M6.1: Workflow Structure

| Score | Criteria |
|-------|----------|
| 100 | `Workflow` with complex topology using `Step`, `Steps`, `Parallel`, `Loop`, `Condition`, `Router` -- matches business process accurately, reusable workflow components, workflow composition |
| 85 | `Workflow` with multiple step types (sequential + parallel or conditional), clear flow logic |
| 70 | `Workflow` with basic `Step` sequence, linear flow working correctly |
| 40 | `Workflow` class imported but only wraps a single agent call; adds complexity without value |
| 0 | No `Workflow` usage; all orchestration is ad-hoc Python code (acceptable for simple single-agent apps -- mark N/A) |

#### M6.2: Error Handling

| Score | Criteria |
|-------|----------|
| 100 | `on_error` handlers on critical steps, retry with exponential backoff, fallback steps, circuit breaker patterns, error logging with context, graceful degradation |
| 85 | `on_error` handlers, retry logic on external-facing steps, error logging |
| 70 | Basic try/except in workflow steps, errors caught and logged |
| 40 | No error handling in workflow; failures crash the entire flow |
| 0 | No workflow error handling; or no workflow |

#### M6.3: Human-in-the-Loop

| Score | Criteria |
|-------|----------|
| 100 | Pause/resume workflow support, `input_required` at decision points, approval gates for high-stakes actions, user feedback incorporated mid-flow, timeout handling for human input |
| 85 | Human input at key decision points, approval gates for important actions |
| 70 | Basic human input capability; workflow can pause and wait for user |
| 40 | Human interaction exists but outside the workflow (manual intervention, not integrated) |
| 0 | No human-in-the-loop; fully autonomous with no oversight (may be appropriate -- mark N/A for batch/automated workflows) |

#### M6.4: State Management

| Score | Criteria |
|-------|----------|
| 100 | `session_state` with typed state objects, state persistence via `storage`, state validation between steps, state snapshots for debugging, rollback capability |
| 85 | `session_state` used, persistence configured, state passed cleanly between steps |
| 70 | Basic state passing between steps using `session_state` |
| 40 | State managed via global variables or function parameters outside Agno's state system |
| 0 | No state management; or no workflow |

---

### D7: Model & Provider Management (10%)

#### M7.1: Model Selection

| Score | Criteria |
|-------|----------|
| 100 | Different models per agent based on task complexity (small/fast for routing, large for reasoning), cost-optimized selection, `reasoning_model` for complex tasks, model benchmarking for specific use cases |
| 85 | Multiple models used appropriately; routing/simple agents use smaller models, complex agents use capable models |
| 70 | Appropriate model chosen for the project's primary use case, explicitly configured |
| 40 | Single model used everywhere regardless of task; or default model not overridden |
| 0 | No model configuration; using Agno defaults or hardcoded API calls bypassing Agno |

#### M7.2: Provider Abstraction

| Score | Criteria |
|-------|----------|
| 100 | Uses Agno's string format (`"openai:gpt-4"`) or model classes (`OpenAIResponses(id="gpt-4")`), model config externalized to env/config, easy to swap providers, multiple providers used |
| 85 | Uses Agno model classes or string format consistently, model IDs configurable |
| 70 | Uses Agno model classes but hardcoded model IDs in agent definitions |
| 40 | Mixed usage: some agents use Agno abstraction, others make raw API calls |
| 0 | Raw API calls to OpenAI/Anthropic/etc. bypassing Agno's model layer entirely |

#### M7.3: Fallback & Redundancy

| Score | Criteria |
|-------|----------|
| 100 | Fallback model chain (primary -> backup -> local), provider health monitoring, automatic failover, cost-based routing (expensive model only when needed), graceful degradation |
| 85 | Backup model configured, failover logic for primary provider outage |
| 70 | At least one fallback model defined for critical agents |
| 40 | Awareness of fallback need (comments/TODOs) but not implemented |
| 0 | No fallback; single provider, single model, no redundancy |

#### M7.4: Streaming & Performance

| Score | Criteria |
|-------|----------|
| 100 | `stream=True` for user-facing agents, `stream_intermediate_steps=True` for transparency, response format optimized per use case, token usage tracking, latency monitoring |
| 85 | Streaming enabled for user-facing agents, intermediate steps visible where useful |
| 70 | `stream=True` used on at least the primary user-facing agent |
| 40 | Streaming available but not enabled; all responses are blocking |
| 0 | No streaming; no performance consideration; synchronous-only operation |

---

### D8: Safety & Guardrails (10%)

#### M8.1: Input Guardrails

| Score | Criteria |
|-------|----------|
| 100 | `input_guardrails=` with prompt injection detection, PII filtering (`PiiGuardrail`), content moderation (`ModerateInput`), custom domain-specific input validation, guardrail logging and alerting |
| 85 | `input_guardrails` with at least two types (e.g., moderation + PII), proper configuration |
| 70 | `input_guardrails` with at least one guardrail (e.g., `ModerateInput()`) |
| 40 | Input validation exists but outside Agno's guardrail system (manual string checks) |
| 0 | No input guardrails; user input passed directly to LLM without any safety checks |

#### M8.2: Output Guardrails

| Score | Criteria |
|-------|----------|
| 100 | `output_guardrails=` with content moderation, PII detection in responses, factual grounding checks, custom domain validators, toxic content filtering, guardrail metrics |
| 85 | `output_guardrails` with moderation and at least one custom validator |
| 70 | `output_guardrails` with basic content moderation |
| 40 | Output checked manually after agent response; not using Agno guardrail system |
| 0 | No output guardrails; agent responses returned to user without any safety checks |

#### M8.3: Tool Guardrails

| Score | Criteria |
|-------|----------|
| 100 | `confirm=True` on all write/delete/destructive tools, approval workflows for high-stakes operations, tool-level access control per user role, tool usage audit logging, sandboxed execution |
| 85 | `confirm=True` on destructive tools, approval gates for important operations |
| 70 | `confirm=True` on at least the most dangerous tools (delete, execute, send) |
| 40 | Tools exist but no confirmation or approval on any operation, including destructive ones |
| 0 | No tool guardrails; or no tools |

#### M8.4: Rate Limiting & Cost Control

| Score | Criteria |
|-------|----------|
| 100 | `max_tokens` set per agent, request rate limiting, per-user/per-session cost tracking, budget alerts, automatic downgrade to cheaper model at budget threshold, usage dashboard |
| 85 | `max_tokens` configured, basic rate limiting, cost awareness in configuration |
| 70 | `max_tokens` set on agents, basic awareness of costs |
| 40 | No token limits; some agents could generate unbounded responses |
| 0 | No cost controls; no `max_tokens`; no rate limiting; open-ended token usage |

---

### D9: Deployment & Runtime (10%)

#### M9.1: AgentOS Setup

| Score | Criteria |
|-------|----------|
| 100 | `AgnoApi` with FastAPI, proper route organization, health endpoints, WebSocket support for streaming, JWT/API key authentication, CORS configured, OpenAPI docs, middleware chain |
| 85 | `AgnoApi` or FastAPI with agent endpoints, health check, authentication, proper error responses |
| 70 | FastAPI app serving agent endpoints, basic routing works |
| 40 | Agent accessible via HTTP but setup is ad-hoc (plain Flask/FastAPI without Agno runtime patterns) |
| 0 | No HTTP/API serving; agent only runs as a script or CLI |

#### M9.2: Database Configuration

| Score | Criteria |
|-------|----------|
| 100 | PostgreSQL with connection pooling (asyncpg/psycopg pool), migrations managed, separate databases for agent storage/knowledge/memory, proper indexing, backup configuration, read replicas for search |
| 85 | PostgreSQL configured for all persistent data (storage, knowledge, memory), connection pooling |
| 70 | PostgreSQL or SQLite configured, at least agent storage persisted to DB |
| 40 | SQLite used in what appears to be a production configuration; or DB configured but not for all components |
| 0 | No database; all state in-memory; or no persistence whatsoever |

#### M9.3: Environment Configuration

| Score | Criteria |
|-------|----------|
| 100 | All secrets via `os.getenv()`, `.env.example` with all required vars, validation on startup (fail fast if missing), per-environment configs (dev/staging/prod), secrets in vault/manager for prod |
| 85 | `os.getenv()` for all API keys and secrets, `.env.example` present, startup validation |
| 70 | `os.getenv()` for API keys, `.env` file used, no hardcoded secrets in code |
| 40 | Mixed: some env vars, some hardcoded strings; or `.env` committed to repo |
| 0 | Hardcoded API keys/secrets in source code; no environment configuration |

#### M9.4: Observability

| Score | Criteria |
|-------|----------|
| 100 | `monitoring=True` on agents, Langfuse or Agno Cloud tracing, OpenTelemetry integration, structured logging with correlation IDs, metrics dashboard, alerting on agent failures, token usage tracking |
| 85 | `monitoring=True`, tracing integration (Langfuse or similar), structured logging |
| 70 | Basic logging of agent interactions, `monitoring=True` enabled |
| 40 | Print statements for debugging; no structured observability |
| 0 | No observability; agent operates as a black box; no logging |

---

### D10: Testing & Evaluation (8%)

#### M10.1: Agent Tests

| Score | Criteria |
|-------|----------|
| 100 | Comprehensive pytest suite: unit tests with mocked tools, integration tests with real models, behavior tests validating agent follows instructions, edge case coverage, snapshot tests for output schema |
| 85 | pytest files testing agent behavior, mock tools for unit tests, real model integration tests |
| 70 | Basic tests that run agents and check responses are non-empty and reasonable |
| 40 | Test files exist but are incomplete; or tests only check imports/instantiation |
| 0 | No test files for agents |

#### M10.2: Evaluation Framework

| Score | Criteria |
|-------|----------|
| 100 | Agno `Eval` classes with `AccuracyEval`, `ReliabilityEval`, LLM-as-judge scoring, custom eval metrics, eval dataset management, regression detection, eval results tracked over time |
| 85 | Agno eval classes used, accuracy and reliability checks, eval runs in CI |
| 70 | Basic eval setup: at least one eval metric defined and runnable |
| 40 | Eval code exists but is not runnable or not connected to actual agents |
| 0 | No evaluation framework; no quality measurement for agent outputs |

#### M10.3: Cookbook / Examples

| Score | Criteria |
|-------|----------|
| 100 | Runnable examples for each agent/workflow, README with setup instructions, example inputs/outputs documented, Jupyter notebooks for exploration, quickstart guide |
| 85 | Runnable examples, README with setup and usage instructions |
| 70 | At least one runnable example, basic README present |
| 40 | README exists but examples are not runnable; or no usage instructions |
| 0 | No examples; no README; no documentation on how to run agents |

#### M10.4: CI Integration

| Score | Criteria |
|-------|----------|
| 100 | CI pipeline runs tests, evals, `./scripts/format.sh`, `./scripts/validate.sh`, type checking, lint, pre-commit hooks, PR checks, deployment gating on eval scores |
| 85 | CI runs tests and format/validate scripts, type checking included |
| 70 | CI pipeline exists with at least test execution |
| 40 | CI file exists but does not run agent tests; or only runs linting |
| 0 | No CI integration; no automated checks |

---

## 2. Framework Sources

These are the authoritative source files in the Agno repository that define the patterns evaluated by this skill.

| Source File | Dimensions | What It Defines |
|-------------|-----------|-----------------|
| `libs/agno/agno/agent/agent.py` | D1, D7, D8 | Agent dataclass, model config, guardrails, streaming, output_schema, instructions, memory integration |
| `libs/agno/agno/team/team.py` | D5 | Team class, coordination modes (broadcast/router/coordinate), member management, shared resources |
| `libs/agno/agno/workflow/workflow.py` | D6 | Workflow class, Step/Steps/Parallel/Loop/Condition/Router, state management, error handling |
| `libs/agno/agno/tools/toolkit.py` | D2 | Toolkit base class, `register()` method, tool configuration (cache, confirm, show_result) |
| `libs/agno/agno/tools/` (directory) | D2 | 100+ built-in tools: DuckDuckGo, YFinance, File, Shell, SQL, API, etc. |
| `libs/agno/agno/knowledge/protocol.py` | D3 | Knowledge protocol, vector DB interface, search configuration |
| `libs/agno/agno/knowledge/chunking/` | D3 | Chunking strategies: Semantic, Recursive, Agentic, FixedSize |
| `libs/agno/agno/vectordb/` | D3 | Vector DB integrations: PgVector2, Pinecone, Qdrant, Weaviate, LanceDb, ChromaDb |
| `libs/agno/agno/embedder/` | D3 | Embedding providers: OpenAI, Ollama, HuggingFace, Cohere, etc. |
| `libs/agno/agno/memory/manager.py` | D4 | MemoryManager class, memory types, user memories, session summaries, learning |
| `libs/agno/agno/memory/db/` | D4 | Memory storage backends: PostgreSQL, SQLite, MongoDB |
| `libs/agno/agno/models/` | D7 | Model providers: OpenAI, Anthropic, Google, Ollama, Groq, Mistral, etc. (40+) |
| `libs/agno/agno/guardrails/` | D8 | Guardrail system: input/output guardrails, moderation, PII, custom validators |
| `libs/agno/agno/eval/` | D10 | Evaluation framework: Eval, AccuracyEval, ReliabilityEval, LLM-as-judge |
| `libs/agno/agno/os/app.py` | D9 | AgentOS/AgnoApi: FastAPI integration, routing, health checks, runtime config |
| `libs/agno/agno/storage/` | D1, D9 | Storage backends: PostgreSQL, SQLite, MongoDB, DynamoDB, Redis, Firestore, JSON |
| `AGENTS.md` | D1, D2, D7 | Official best practices, anti-patterns (no agents in loops), recommended patterns |
| `.cursorrules` | All | Framework conventions, import patterns, development workflow |
| `cookbook/` | D10 | Reference implementations, runnable examples, pattern demonstrations |
| `libs/agno/agno/run/response.py` | D1, D7 | Run response types, streaming response handling, structured output |

### Key Anti-Patterns (from AGENTS.md)

These patterns should be flagged whenever detected, regardless of other scores:

| Anti-Pattern | Impact | What to Look For |
|-------------|--------|------------------|
| Agents created in loops | Performance degradation, memory leaks | `for` / `while` loops containing `Agent(` |
| Raw API calls instead of Agno models | Loses framework benefits, no tracing | Direct `openai.ChatCompletion.create()` or `anthropic.messages.create()` |
| SQLite in production | Data loss risk, concurrency issues | `SqliteStorage` or `sqlite` in production config |
| No instructions on agents | Poor agent behavior, unpredictable | `Agent(` without `instructions=` parameter |
| In-memory storage for production | State lost on restart | No `storage=` on agents handling user sessions |
| Reinventing built-in tools | Wasted effort, worse quality | Custom implementations of DuckDuckGo search, file operations, etc. when Agno has built-in |
| Hardcoded API keys | Security vulnerability | Strings like `sk-...` or `api_key="..."` in source |
| No guardrails on user-facing agents | Safety risk | User-facing agents without `input_guardrails` or `output_guardrails` |
