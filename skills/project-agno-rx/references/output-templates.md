# Output Templates — Agno Project Completeness Scorecard

> Mandatory output formats for project-agno-rx evaluations. Every evaluation MUST include all 9 sections
> in the exact order specified. This is the Agno-specialized output template in the rx family.
> The output must be immediately actionable — someone should be able to read it and know EXACTLY
> what to improve in their Agno agent project.

---

## Section 1: Agno Project Summary

Detect and summarize the Agno project structure FIRST, before scoring.

### Format

```markdown
## Agno Project Summary

**Agno Version**: [detected version from pyproject.toml/requirements.txt, e.g., agno==1.2.3]
**Agents**: [count] | **Teams**: [count] | **Workflows**: [count]
**Tools**: [count built-in] + [count custom] | **Knowledge bases**: [count]
**Storage**: [detected DB, e.g., PostgresDb / SqliteDb / None] | **Models**: [list of providers used, e.g., OpenAI, Claude, Gemini]

**Signals detected**:
- [signal 1 — e.g., "agno==1.2.3 in pyproject.toml"]
- [signal 2 — e.g., "3 Agent() definitions across 2 modules"]
- [signal 3 — e.g., "Team() with coordinator mode detected"]
- [signal 4 — e.g., "PostgresDb storage configured"]
- [signal 5 — e.g., "VectorDb knowledge with PgVector"]

**Agent inventory**:
| Agent Name | Module | Model | Tools | Storage | Memory | Knowledge |
|------------|--------|-------|-------|---------|--------|-----------|
| research_agent | src/agents/research.py | Claude Sonnet | WebSearchTools, FileTools | PostgresDb | No | No |
| writer_agent | src/agents/writer.py | GPT-4o | — | None | No | No |
| [name] | [path] | [model] | [tools] | [storage] | [yes/no] | [yes/no] |

**Team inventory** (if any):
| Team Name | Module | Mode | Agents | Storage |
|-----------|--------|------|--------|---------|
| content_team | src/teams/content.py | coordinate | research_agent, writer_agent | PostgresDb |

**Workflow inventory** (if any):
| Workflow Name | Module | Steps | Storage |
|---------------|--------|-------|---------|
| report_pipeline | src/workflows/report.py | 3 | PostgresDb |
```

### Detection Rules

1. **Scan dependencies first.** Look for `agno` in pyproject.toml, requirements.txt, or setup.py.
2. **Scan all Python files for Agent(), Team(), Workflow() instantiations.**
3. **Catalog every agent's configuration:** model, tools, storage, memory, knowledge, instructions.
4. **Detect storage pattern:** PostgresDb (production), SqliteDb (dev), InMemoryDb (prototype), or None.
5. **Detect model providers:** OpenAI, Anthropic, Google, Ollama, DeepSeek, etc.
6. **If no agno import found, abort and report "Not an Agno project."**

---

## Section 2: Completeness Scorecard

The summary table with 10 Agno-specific dimensions for quick scanning.

### Format

```markdown
## Completeness Scorecard

**Project**: [name]
**Stack**: [e.g., Python 3.12 + Agno 1.2.3 + PostgreSQL + FastAPI]
**Overall Score**: [0-100] — [GRADE]

| # | Dimension | Score | Grade | Status | Summary |
|---|-----------|-------|-------|--------|---------|
| D1 | Agent Design | 72 | B- | ⚠️ Partial | Agents have names but missing output_schema, vague instructions |
| D2 | Tool Integration | 55 | C | ⚠️ Partial | 3 built-in tools, no custom tools, over-tooling on 1 agent |
| D3 | Knowledge & RAG | 0 | F | ❌ Missing | No vector DB, no knowledge bases configured |
| D4 | Memory & Sessions | 20 | F | ❌ Missing | No MemoryManager, no session persistence |
| D5 | Storage & Data | 45 | D+ | ⚠️ Partial | SqliteDb for dev, no PostgresDb for prod |
| D6 | Teams & Orchestration | 80 | B | ⚠️ Partial | Team with coordinator mode, missing error handling |
| D7 | Safety & Guardrails | 0 | F | ❌ Missing | No guardrails, no moderation, no PII detection |
| D8 | Observability & Eval | 15 | F | ❌ Missing | No tracing, no evals, no monitoring |
| D9 | API & Deployment | 60 | C | ⚠️ Partial | FastAPI endpoint exists, no auth, no rate limiting |
| D10 | Code Quality & DX | 70 | B- | ⚠️ Partial | Type hints present, missing tests, no README for agents |
```

### Dimension Definitions

| # | Dimension | What It Measures |
|---|-----------|-----------------|
| D1 | Agent Design | Agent naming, instructions quality, output_schema, model selection, description |
| D2 | Tool Integration | Built-in tool usage, custom tools, tool count per agent, tool documentation |
| D3 | Knowledge & RAG | VectorDb config, embeddings, chunking strategy, knowledge sources |
| D4 | Memory & Sessions | MemoryManager, agentic_memory, session persistence, user memories |
| D5 | Storage & Data | Database choice, migrations, connection pooling, production readiness |
| D6 | Teams & Orchestration | Team usage, coordination mode, workflow design, error propagation |
| D7 | Safety & Guardrails | Moderation, PII detection, content filtering, approval workflows |
| D8 | Observability & Eval | Tracing, Langfuse/OTel, AgentEval, accuracy checks, reliability metrics |
| D9 | API & Deployment | Serving layer, authentication, rate limiting, AgentOS readiness |
| D10 | Code Quality & DX | Tests, type hints, documentation, examples, project structure |

### Status Column Rules

| Status | Condition | Meaning |
|--------|-----------|---------|
| ✅ Present | Score >= 85 | Dimension is adequately implemented |
| ⚠️ Partial | Score 40-84 | Some components exist but gaps remain |
| ❌ Missing | Score 0-39 | Critical gaps, major work needed |
| ➖ N/A | Not applicable | Project type doesn't need this (e.g., no Teams for single-agent) |

---

## Section 3: Sub-Metric Detail

Expand every dimension into its sub-metrics with evidence from the codebase.

### Format

```markdown
## Sub-Metric Detail

### D1: Agent Design — 72/100 (B-)

| Sub-Metric | Score | Evidence |
|------------|-------|----------|
| M1.1 Agent naming | 90 | All agents have name= and description= parameters |
| M1.2 Instructions quality | 60 | Instructions present but generic ("You are a helpful assistant") |
| M1.3 Output schema | 0 | No output_schema= on any agent; all return unstructured text |
| M1.4 Model selection | 80 | Explicit model= parameter, but same model for all agents |
| M1.5 Agent reuse | 50 | One agent created inside a loop (performance issue) |

### D2: Tool Integration — 55/100 (C)

| Sub-Metric | Score | Evidence |
|------------|-------|----------|
| M2.1 Built-in tools | 80 | WebSearchTools, FileTools, HttpTools properly imported |
| M2.2 Custom tools | 0 | No custom tools defined; all use built-in only |
| M2.3 Tool count per agent | 40 | research_agent has 12 tools (over-tooling; recommend 5-7) |
| M2.4 Tool documentation | 30 | No docstrings on tool functions |

### D3: Knowledge & RAG — 0/100 (F)

| Sub-Metric | Score | Evidence |
|------------|-------|----------|
| M3.1 Vector DB configuration | 0 | No VectorDb import or configuration found |
| M3.2 Embeddings | 0 | No embedding model configured |
| M3.3 Chunking strategy | 0 | No chunking configuration |
| M3.4 Knowledge sources | 0 | No knowledge= parameter on any agent |

### D4: Memory & Sessions — 20/100 (F)

| Sub-Metric | Score | Evidence |
|------------|-------|----------|
| M4.1 MemoryManager | 0 | No MemoryManager import found |
| M4.2 Agentic memory | 0 | enable_agentic_memory not set |
| M4.3 Session persistence | 20 | session_id passed but no db= for storage |
| M4.4 User memories | 0 | No user memory configuration |

### D5: Storage & Data — 45/100 (D+)

| Sub-Metric | Score | Evidence |
|------------|-------|----------|
| M5.1 Database choice | 30 | SqliteDb used; not suitable for production |
| M5.2 Connection config | 60 | Connection string configured but no pooling |
| M5.3 Migrations | 0 | No migration strategy for agent tables |
| M5.4 Production readiness | 0 | No PostgresDb configuration found |

### D6: Teams & Orchestration — 80/100 (B)

| Sub-Metric | Score | Evidence |
|------------|-------|----------|
| M6.1 Team design | 90 | Team with coordinate mode, clear agent roles |
| M6.2 Error handling | 50 | No error propagation between agents in team |
| M6.3 Workflow usage | N/A | No multi-step deterministic flows needed |
| M6.4 Agent delegation | 80 | Proper agent selection logic in coordinator |

### D7: Safety & Guardrails — 0/100 (F)

| Sub-Metric | Score | Evidence |
|------------|-------|----------|
| M7.1 Content moderation | 0 | No moderation guardrails configured |
| M7.2 PII detection | 0 | No PII filtering on agent inputs/outputs |
| M7.3 Approval workflows | 0 | No human-in-the-loop for sensitive actions |
| M7.4 Rate limiting | 0 | No rate limiting on agent calls |

### D8: Observability & Eval — 15/100 (F)

| Sub-Metric | Score | Evidence |
|------------|-------|----------|
| M8.1 Tracing | 0 | tracing=True not set on any agent |
| M8.2 Langfuse/OTel | 0 | No observability platform configured |
| M8.3 AgentEval | 0 | No evaluation framework found |
| M8.4 Logging | 60 | Basic Python logging present but not structured |

### D9: API & Deployment — 60/100 (C)

| Sub-Metric | Score | Evidence |
|------------|-------|----------|
| M9.1 Serving layer | 80 | FastAPI endpoint for agent interaction |
| M9.2 Authentication | 0 | No auth on agent API endpoints |
| M9.3 Streaming | 70 | stream=True for main agent, SSE endpoint present |
| M9.4 AgentOS readiness | 0 | Not configured for AgentOS deployment |

### D10: Code Quality & DX — 70/100 (B-)

| Sub-Metric | Score | Evidence |
|------------|-------|----------|
| M10.1 Type hints | 80 | Most functions have type annotations |
| M10.2 Tests | 0 | No test files found for agents |
| M10.3 Documentation | 60 | README exists but no per-agent documentation |
| M10.4 Examples | 40 | One example script, not runnable without setup |

[... continue for all 10 dimensions ...]
```

### Sub-Metric Scoring Rules

1. **Score 0** — Component does not exist at all. No files, no config, no imports.
2. **Score 1-39** — Minimal placeholder or stub exists but is non-functional.
3. **Score 40-69** — Basic implementation exists with significant gaps.
4. **Score 70-84** — Solid implementation with minor gaps.
5. **Score 85-96** — Production-ready with only polish needed.
6. **Score 97-100** — Best-in-class implementation.
7. **Every score MUST cite evidence.** File paths, import statements, parameter values, or explicit absence.

---

## Section 4: Best Practice Violations (THE KEY OUTPUT)

This is the unique value of project-agno-rx. Every violation of Agno best practices is listed
with severity, exact location, fix, and reference to agno-patterns.md.

### Format

```markdown
## Best Practice Violations

> [N] violations found across [M] severity levels.
> Critical violations are performance/security risks that should be fixed immediately.

---

### 🔴 Critical Violations

#### VIOLATION-001: Agent created inside loop
- **Severity**: Critical (performance killer)
- **Location**: `src/handlers/chat.py:45`
- **Pattern**: `for user in users: agent = Agent(...)`
- **Problem**: Creating a new Agent() per iteration wastes memory and reinitializes model connections.
  With 1000 users, this creates 1000 agent instances instead of 1.
- **Fix**: Create agent once outside the loop, call `.run()` or `.arun()` inside the loop.
  ```python
  # Before (bad)
  for user in users:
      agent = Agent(model=OpenAIChat(id="gpt-4o"), tools=[...])
      agent.run(f"Process {user}")

  # After (good)
  agent = Agent(model=OpenAIChat(id="gpt-4o"), tools=[...])
  for user in users:
      agent.run(f"Process {user}", session_id=user.id)
  ```
- **Reference**: agno-patterns.md, Anti-Pattern #1
- **Score impact**: D1 -20 points

---

#### VIOLATION-002: Raw API calls bypassing Agno
- **Severity**: Critical (defeats purpose of framework)
- **Location**: `src/services/llm.py:12`
- **Pattern**: `openai.chat.completions.create(model="gpt-4o", ...)`
- **Problem**: Direct OpenAI SDK calls bypass Agno's model abstraction, losing tracing, memory,
  tool integration, and the ability to swap providers.
- **Fix**: Use Agno's model classes:
  ```python
  # Before (bad)
  from openai import OpenAI
  client = OpenAI()
  response = client.chat.completions.create(model="gpt-4o", messages=[...])

  # After (good)
  from agno.agent import Agent
  from agno.models.openai import OpenAIChat
  agent = Agent(model=OpenAIChat(id="gpt-4o"))
  response = agent.run("Your prompt here")
  ```
- **Reference**: agno-patterns.md, Anti-Pattern #2
- **Score impact**: D1 -30 points

---

### 🟠 High Severity

#### VIOLATION-003: No output_schema on data-returning agent
- **Severity**: High (unreliable output)
- **Location**: `src/agents/analyzer.py:20`
- **Pattern**: Agent returns unstructured text parsed with regex
- **Problem**: Without output_schema, agent output format varies between calls. Downstream
  code breaks when the model changes wording.
- **Fix**:
  ```python
  from pydantic import BaseModel

  class AnalysisResult(BaseModel):
      sentiment: str
      confidence: float
      key_topics: list[str]

  agent = Agent(
      model=OpenAIChat(id="gpt-4o"),
      output_schema=AnalysisResult,
  )
  ```
- **Reference**: agno-patterns.md, Anti-Pattern #3
- **Score impact**: D1 -15 points

---

#### VIOLATION-004: In-memory storage for production
- **Severity**: High (data loss on restart)
- **Location**: `src/config.py:8`
- **Pattern**: `storage = SqliteDb(path="agents.db")`
- **Problem**: SQLite does not handle concurrent writes from multiple workers. Agent history,
  sessions, and memories are lost on container restart.
- **Fix**:
  ```python
  from agno.storage.postgres import PostgresDb

  storage = PostgresDb(
      table_name="agent_sessions",
      db_url="postgresql://user:pass@host:5432/db",
  )
  ```
- **Reference**: agno-patterns.md, Anti-Pattern #4
- **Score impact**: D5 -25 points

---

### 🟡 Medium Severity

#### VIOLATION-005: [Next violation]
- **Severity**: Medium
- **Location**: [file:line]
- **Pattern**: [code pattern found]
- **Problem**: [why this is bad]
- **Fix**: [code example]
- **Reference**: agno-patterns.md, Anti-Pattern #[N]
- **Score impact**: D[N] -[X] points

---

### 🔵 Low Severity

#### VIOLATION-008: [Violation]
[... same format ...]
```

### Severity Classification Rules

| Severity | Criteria | Typical Violations |
|----------|----------|--------------------|
| 🔴 Critical | Performance killer, security risk, or defeats purpose of framework | Agent in loop, raw API calls, no auth on endpoints |
| 🟠 High | Unreliable behavior, data loss risk, poor maintainability | No output_schema, in-memory storage, no session persistence |
| 🟡 Medium | Suboptimal patterns, minor risks, degraded developer experience | Hardcoded model, over-tooling, missing instructions |
| 🔵 Low | Polish items, best practice aspirations | No agent description, missing docstrings, no eval |

### VIOLATION-ID Numbering Rules

1. IDs are sequential: VIOLATION-001, VIOLATION-002, etc.
2. Ordered by severity tier first, then by score impact within tier.
3. Each ID is unique across the entire output.
4. Every violation must reference a specific anti-pattern from agno-patterns.md.

---

## Section 5: Missing Agno Capabilities

What Agno features the project SHOULD use but DOESN'T. Each capability includes a code example
showing exactly how to add it.

### Format

```markdown
## Missing Agno Capabilities

> [N] capabilities identified that would significantly improve this project.
> Each includes a working code example ready to implement.

---

### CAPABILITY-001: Memory Manager not configured
- **What**: MemoryManager enables persistent user memories across sessions
- **Why**: Your agents lose context between conversations. Users have to re-explain preferences every time.
- **Dimension impact**: D4 +30 points
- **How to add**:
  ```python
  from agno.memory.manager import MemoryManager
  from agno.storage.postgres import PostgresDb

  memory = MemoryManager(
      db=PostgresDb(table_name="agent_memory", db_url="postgresql://..."),
      model=OpenAIChat(id="gpt-4o-mini"),  # cheap model for memory operations
  )
  agent = Agent(
      model=OpenAIChat(id="gpt-4o"),
      memory_manager=memory,
      enable_agentic_memory=True,
      add_history_to_messages=True,
      num_history_responses=5,
  )
  ```
- **Effort**: S (< 1 day)

---

### CAPABILITY-002: Knowledge base with RAG
- **What**: VectorDb + embeddings for domain-specific knowledge retrieval
- **Why**: Agents hallucinate domain facts. RAG grounds responses in your actual documents.
- **Dimension impact**: D3 +40 points
- **How to add**:
  ```python
  from agno.knowledge.pdf import PDFKnowledgeBase
  from agno.vectordb.pgvector import PgVector
  from agno.embedder.openai import OpenAIEmbedder

  knowledge = PDFKnowledgeBase(
      path="data/docs/",
      vector_db=PgVector(
          table_name="documents",
          db_url="postgresql://...",
          embedder=OpenAIEmbedder(id="text-embedding-3-small"),
      ),
  )
  # Load knowledge (run once)
  knowledge.load()

  agent = Agent(
      model=OpenAIChat(id="gpt-4o"),
      knowledge=knowledge,
      search_knowledge=True,
  )
  ```
- **Effort**: M (1-3 days)

---

### CAPABILITY-003: Guardrails for safety
- **What**: Input/output guardrails for content moderation, PII, and validation
- **Why**: Production agents without guardrails risk generating harmful content, leaking PII,
  or executing dangerous tool calls.
- **Dimension impact**: D7 +35 points
- **How to add**:
  ```python
  from agno.agent import Agent

  def moderate_input(message: str) -> str:
      """Check input for harmful content before agent processes it."""
      # Add your moderation logic
      blocked_patterns = ["ignore previous instructions", "system prompt"]
      for pattern in blocked_patterns:
          if pattern.lower() in message.lower():
              raise ValueError("Input blocked by moderation guardrail")
      return message

  def validate_output(response: str) -> str:
      """Check output before returning to user."""
      # Add PII detection, content filtering, etc.
      return response

  agent = Agent(
      model=OpenAIChat(id="gpt-4o"),
      input_guardrails=[moderate_input],
      output_guardrails=[validate_output],
  )
  ```
- **Effort**: M (1-3 days)

---

### CAPABILITY-004: Observability with tracing
- **What**: Built-in tracing + external observability platform integration
- **Why**: You cannot debug agent failures, track token usage, or measure quality without tracing.
- **Dimension impact**: D8 +25 points
- **How to add**:
  ```python
  agent = Agent(
      model=OpenAIChat(id="gpt-4o"),
      tracing=True,       # Enable Agno built-in tracing
      monitoring=True,     # Enable monitoring dashboard
  )
  ```
- **Effort**: S (< 1 day)

---

### CAPABILITY-005: Structured output with Pydantic
- **What**: Type-safe agent output using output_schema
- **Why**: Agents return predictable, parseable data instead of free-text
- **Dimension impact**: D1 +15 points
- **How to add**:
  ```python
  from pydantic import BaseModel, Field

  class ResearchReport(BaseModel):
      title: str = Field(..., description="Report title")
      summary: str = Field(..., description="Executive summary")
      findings: list[str] = Field(..., description="Key findings")
      confidence: float = Field(..., ge=0, le=1)

  agent = Agent(
      model=OpenAIChat(id="gpt-4o"),
      output_schema=ResearchReport,
      instructions=["Return a structured research report"],
  )
  result = agent.run("Research topic X")
  report: ResearchReport = result.output  # typed!
  ```
- **Effort**: S (< 1 day)

---

### CAPABILITY-006: Team for complex multi-agent tasks
- **What**: Use Team instead of single mega-agent with too many tools
- **Why**: A single agent with 20+ tools loses accuracy. Teams delegate to specialized agents.
- **Dimension impact**: D6 +30 points
- **How to add**:
  ```python
  from agno.team import Team

  research_agent = Agent(name="Researcher", tools=[WebSearchTools()], ...)
  writer_agent = Agent(name="Writer", tools=[FileTools()], ...)

  team = Team(
      name="Content Team",
      mode="coordinate",  # or "route", "collaborate"
      members=[research_agent, writer_agent],
      storage=PostgresDb(table_name="team_sessions", db_url="..."),
      instructions=["Research topics, then write polished content"],
  )
  ```
- **Effort**: M (1-3 days)

---

### CAPABILITY-NNN: [Next capability]
[... same format ...]
```

### Capability Identification Rules

1. **Scan all Agent() calls** for missing parameters (memory, knowledge, guardrails, storage, etc.)
2. **Compare against agno-patterns.md best practices.** Every unchecked best practice is a potential capability.
3. **Prioritize by dimension impact.** Capabilities that lift the lowest-scoring dimensions come first.
4. **Include working code examples.** Not pseudocode — real, importable Agno code.
5. **Every capability must reference which dimension it improves and by how many points.**

---

## Section 6: Agent Architecture — Before/After Mermaid

Show the transformation from current state to target architecture using Mermaid diagrams.

### Before Diagram — Current Architecture

Shows existing agent components as solid nodes and missing features as dashed nodes.

````markdown
### Agent Architecture: Before (Current State — [SCORE] [GRADE])

```mermaid
graph TB
    classDef present fill:#51cf66,stroke:#2b8a3e,color:#fff
    classDef partial fill:#ffd43b,stroke:#f08c00,color:#000
    classDef missing fill:#ff6b6b,stroke:#c92a2a,color:#fff,stroke-dasharray: 5 5

    subgraph Agents["Agents"]
        A1[research_agent<br/>Claude Sonnet]:::present
        A2[writer_agent<br/>GPT-4o]:::present
    end

    subgraph Tools["Tools"]
        T1[WebSearchTools]:::present
        T2[FileTools]:::present
        T3[Custom Tools<br/>MISSING]:::missing
    end

    subgraph Knowledge["Knowledge & RAG"]
        K1[VectorDb<br/>MISSING]:::missing
        K2[Embeddings<br/>MISSING]:::missing
    end

    subgraph Memory["Memory"]
        M1[MemoryManager<br/>MISSING]:::missing
        M2[Session History<br/>MISSING]:::missing
    end

    subgraph Storage["Storage"]
        S1[(SqliteDb<br/>Dev Only)]:::partial
        S2[(PostgresDb<br/>MISSING)]:::missing
    end

    subgraph Safety["Guardrails"]
        G1[Moderation<br/>MISSING]:::missing
        G2[PII Detection<br/>MISSING]:::missing
    end

    subgraph Observability["Observability"]
        O1[Tracing<br/>MISSING]:::missing
        O2[Evals<br/>MISSING]:::missing
    end

    subgraph API["API Layer"]
        API1[FastAPI Endpoint]:::present
        API2[Auth<br/>MISSING]:::missing
    end

    %% Existing connections
    A1 --> T1
    A1 --> T2
    A1 --> S1
    API1 --> A1

    %% Missing connections
    A1 -.->|should use| K1
    A1 -.->|should have| M1
    A1 -.->|should check| G1
    A1 -.->|should trace| O1
    API1 -.->|should auth| API2
```
````

### After Diagram — Target Architecture

Shows the complete Agno system with all capabilities present and connected.

````markdown
### Agent Architecture: After (Target — 95+ A)

```mermaid
graph TB
    classDef present fill:#51cf66,stroke:#2b8a3e,color:#fff
    classDef planned fill:#339af0,stroke:#1864ab,color:#fff,stroke-width:3px

    subgraph Team["Content Team (coordinate)"]
        A1[research_agent<br/>Claude Sonnet]:::present
        A2[writer_agent<br/>GPT-4o]:::present
        A3[editor_agent<br/>GPT-4o-mini]:::planned
    end

    subgraph Tools["Tools (5-7 per agent)"]
        T1[WebSearchTools]:::present
        T2[FileTools]:::present
        T3[Custom Domain Tools]:::planned
    end

    subgraph Knowledge["Knowledge & RAG"]
        K1[PgVector DB]:::planned
        K2[OpenAI Embeddings]:::planned
        K3[PDF Knowledge Base]:::planned
    end

    subgraph Memory["Memory & Sessions"]
        M1[MemoryManager]:::planned
        M2[Agentic Memory]:::planned
        M3[Session History]:::planned
    end

    subgraph Storage["PostgreSQL Storage"]
        S1[(PostgresDb<br/>agent_sessions)]:::planned
        S2[(PostgresDb<br/>agent_memory)]:::planned
    end

    subgraph Safety["Guardrails"]
        G1[Input Moderation]:::planned
        G2[PII Detection]:::planned
        G3[Output Validation]:::planned
    end

    subgraph Observability["Observability & Eval"]
        O1[Agno Tracing]:::planned
        O2[Langfuse]:::planned
        O3[AgentEval Suite]:::planned
    end

    subgraph API["API Layer"]
        API1[FastAPI + SSE]:::present
        API2[JWT Auth]:::planned
        API3[Rate Limiting]:::planned
    end

    %% Full connections
    API1 --> API2
    API2 --> API3
    API3 --> Team
    A1 --> T1 & T2
    A2 --> T2 & T3
    Team --> S1
    A1 --> K1
    K1 --> K2
    K3 --> K1
    Team --> M1
    M1 --> M2
    M1 --> S2
    M2 --> M3
    G1 --> Team
    Team --> G3
    Team --> O1
    O1 --> O2
    O3 -->|validate| Team
```
````

### Diagram Construction Rules

1. **Both diagrams are mandatory.** Never output a scorecard without Before/After diagrams.
2. **Before diagram must reflect actual codebase.** Derive from agent inventory discovery.
3. **After diagram must match the capabilities and upgrade path.** Every planned node corresponds to a CAPABILITY-NNN or VIOLATION fix.
4. **Use consistent node IDs.** Same component keeps the same ID across both diagrams.
5. **classDef usage**:
   - `present` (green, solid) — component exists and works correctly
   - `partial` (orange, solid) — component exists but has issues
   - `missing` (red, dashed) — component does not exist
   - `planned` (blue, thick border) — component to be built (After diagram only)
6. **Subgraph boundaries** group by Agno concept: Agents, Tools, Knowledge, Memory, Storage, Safety, Observability, API.
7. **Maximum 25 nodes per diagram.** Focus on most impactful areas.
8. **Dashed arrows (`-.->`)** in Before diagram show missing connections.
9. **Solid arrows (`-->`)** in After diagram show all connections complete.

---

## Section 7: Agno Upgrade Path

Phased plan to reach A+ Agno project, ordered by dependency and impact.

### Format

```markdown
## Agno Upgrade Path

| Phase | Focus | Key Changes | Duration | Score After |
|-------|-------|-------------|----------|-------------|
| 0 | Current State | What exists today | — | [current] ([grade]) |
| 1 | Agent Design | Add output_schema, proper instructions, fix anti-patterns | 1 week | [projected] ([grade]) |
| 2 | Knowledge & RAG | Add VectorDb, chunking, embeddings, knowledge bases | 1-2 weeks | [projected] ([grade]) |
| 3 | Memory & Sessions | Add MemoryManager, agentic_memory, PostgresDb storage | 1 week | [projected] ([grade]) |
| 4 | Safety & Guardrails | Add moderation, PII detection, approval workflows | 1 week | [projected] ([grade]) |
| 5 | Observability & Deployment | tracing=True, Langfuse, AgentEval, AgentOS, production API | 1-2 weeks | 95+ (A) |

### Phase Details

#### Phase 1: Agent Design (Week 1)
**Goal**: Every agent has proper naming, typed output, explicit model, and quality instructions.

| Component | Effort | Fixes | Acceptance Criteria |
|-----------|--------|-------|---------------------|
| Fix VIOLATION-001 (agent in loop) | S | VIOLATION-001 | Agent created once, .run() called in loop |
| Add output_schema to all data agents | S | VIOLATION-003, CAPABILITY-005 | All data-returning agents use Pydantic models |
| Improve instructions | S | VIOLATION-009 | Instructions are specific, not "You are a helpful assistant" |
| Explicit model selection | S | VIOLATION-006 | Every agent has model= with appropriate provider |

**Phase 1 score projection**: [current] → [projected] (+[delta] points)

#### Phase 2: Knowledge & RAG (Weeks 2-3)
**Goal**: Agents are grounded in domain documents, not hallucinating facts.

| Component | Effort | Fixes | Acceptance Criteria |
|-----------|--------|-------|---------------------|
| Set up PgVector | M | CAPABILITY-002 | Vector DB running with connection pooling |
| Configure embeddings | S | CAPABILITY-002 | text-embedding-3-small or equivalent |
| Build knowledge bases | M | CAPABILITY-002 | All domain docs indexed and searchable |
| Add search_knowledge=True | S | — | Agents retrieve relevant context before answering |

**Phase 2 score projection**: [after P1] → [projected] (+[delta] points)

[... continue for each phase ...]
```

### Upgrade Path Rules

1. **Phase 0 is always "Current State."** Shows what exists and current score.
2. **Dependencies are real.** Knowledge needs storage (Phase 2 needs Phase 3's PostgresDb, or do storage first).
3. **Each phase has a clear goal statement.** One sentence describing the milestone.
4. **Score projections are based on dimension impacts.** Sum the deltas per phase.
5. **Maximum 5-6 phases.** Collapse lower-priority items if needed.
6. **Final phase should project to A- or higher (89+).**
7. **Every VIOLATION and CAPABILITY should appear in at least one phase.**

---

## Section 8: rx Pipeline Recommendation

Based on what exists and what's being built, recommend which other rx skills to run and when.

### Format

```markdown
## Recommended rx Pipeline

Based on the current state and upgrade path, run these rx evaluations in order:

| Order | Skill | Target | Why | When |
|-------|-------|--------|-----|------|
| 1 | `/code-rx` | Agent modules | Establish code quality baseline for agent code. Fix patterns now. | Now (before upgrading) |
| 2 | `/sec-rx` | API + guardrails | Verify API auth, validate guardrail effectiveness. | After Phase 4 |
| 3 | `/api-rx` | Agent API endpoints | Validate API design for agent serving layer. | After Phase 5 |
| 4 | `/test-rx` | Agent test suite | Verify eval coverage, test quality for agents. | After Phase 5 |
| 5 | `/doc-rx` | Agent documentation | Review agent docs, README, cookbook examples. | After Phase 5 |

### Skip List
These rx skills are less relevant for Agno agent projects:
- `/ux-rx` — Only applicable if the project includes a frontend UI
- `/arch-rx` — Agno-rx covers agent architecture; arch-rx is for system architecture
```

---

## Section 9: Complete Output Order

The final project-agno-rx output MUST follow this exact sequence:

```
1. Agno Project Summary (Section 1)
2. Completeness Scorecard — 10 dimensions (Section 2)
3. Sub-Metric Detail — all sub-metrics with evidence (Section 3)
4. Best Practice Violations — with severity + fix (Section 4) ← THE KEY OUTPUT
5. Missing Capabilities — with code examples (Section 5)
6. Agent Architecture: Before (Mermaid — current state) (Section 6)
7. Agent Architecture: After (Mermaid — target state) (Section 6)
8. Agno Upgrade Path — phased plan with score projections (Section 7)
9. rx Pipeline Recommendation (Section 8)
```

### Output Rules

1. **All 9 sections are mandatory.** Never skip a section.
2. **Section 4 (Violations) is the key differentiator.** Spend the most effort here.
3. **Every VIOLATION-NNN and CAPABILITY-NNN must appear in Section 7 (Upgrade Path).**
4. **Every planned node in Section 6 (After diagram) must have a VIOLATION or CAPABILITY reference.**
5. **Scores are internally consistent.** Dimension scores, sub-metric scores, and overall score must reconcile.
6. **Evidence is mandatory.** Every score cites file paths, import statements, or explicit absence.
7. **Code examples are mandatory in Sections 4 and 5.** Real Agno code, not pseudocode.
8. **Effort estimates are mandatory.** S (< 1 day), M (1-5 days), L (5+ days).
9. **Score impact projections are mandatory.** Show dimension and point impact for every item.
