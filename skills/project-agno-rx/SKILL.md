---
name: project-agno-rx
description: Specialist evaluation for Agno AI agent projects. Evaluates agent design, tool usage, knowledge/RAG setup, memory management, team coordination, workflow orchestration, deployment readiness, and observability against Agno best practices. Use when building with Agno, auditing agent quality, or when the user says "agno audit", "run project-agno-rx", "evaluate my agents", "agno best practices", or "agent quality check". Measures 10 dimensions (40 sub-metrics) specific to the Agno framework.
---

## Prerequisites

Optional: `pyright` for type-aware analysis (`pip install pyright`)

Check all dependencies: `bash scripts/rx-deps.sh` or `bash scripts/rx-deps.sh --install`


# project-agno-rx — Agno AI Agent Quality Inspector

> "Is this Agno project using the framework correctly and leveraging all available capabilities for a world-class A+ agentic system?"

This is a SPECIALIST skill for projects built with the Agno AI framework (https://github.com/agno-agi/agno). Unlike general-purpose rx skills, every metric here references specific Agno classes, methods, and patterns.

---

## How It Works

1. **Confirm** the project uses Agno (look for `agno` imports, `Agent` class usage, `pyproject.toml` with agno dependency)
2. **Scan** all 10 dimensions using 5 parallel agents
3. **Score** each of 40 sub-metrics on presence + maturity (0 / 40 / 70 / 85 / 100)
4. **Generate** a quality scorecard + improvement plan
5. **Recommend** Agno-native solutions before suggesting external libraries

---

## Phase 1: Project Confirmation

Before scoring, confirm the project is Agno-based:

```
1. Check pyproject.toml / requirements.txt / setup.py for `agno` dependency
2. Scan for `from agno.agent import Agent` or similar Agno imports
3. Look for Agent() instantiation patterns
4. Check for agno config files, AGENTS.md, .cursorrules referencing Agno
```

If Agno is not detected, abort with: "This project does not appear to use the Agno framework. Use project-rx for general project evaluation instead."

---

## Phase 2: The 10 Dimensions (40 Sub-Metrics)

### Base Weights

| Dimension | Weight |
|-----------|--------|
| D1: Agent Design & Configuration | 12% |
| D2: Tool Integration | 12% |
| D3: Knowledge & RAG | 10% |
| D4: Memory & Learning | 10% |
| D5: Team & Multi-Agent | 10% |
| D6: Workflow Orchestration | 8% |
| D7: Model & Provider Management | 10% |
| D8: Safety & Guardrails | 10% |
| D9: Deployment & Runtime | 10% |
| D10: Testing & Evaluation | 8% |

---

## Phase 3: Discovery & Scanning

Deploy **5 parallel agents** to scan the codebase:

### Agent Assignments

| Agent | Dimensions | What to Scan |
|-------|-----------|--------------|
| **Agent 1: Agent Design & Tools** | D1 + D2 | Agent() definitions, model config, instructions, output_schema, tool imports, @tool decorators, Toolkit subclasses |
| **Agent 2: Knowledge & Memory** | D3 + D4 | VectorDb config, knowledge bases, chunking, embedders, MemoryManager setup, memory types, learning patterns |
| **Agent 3: Teams & Workflows** | D5 + D6 | Team() definitions, coordination modes, Workflow() classes, Step/Steps/Parallel/Loop usage, state management |
| **Agent 4: Models & Safety** | D7 + D8 | Model provider usage, fallback patterns, streaming config, guardrail definitions, input/output validation, rate limiting |
| **Agent 5: Deploy & Test** | D9 + D10 | AgentOS/FastAPI setup, database config, env vars, tracing/observability, test files, eval framework, CI/CD |

### What Each Agent Does

For every sub-metric in their assigned dimensions:

1. **Search** for the component using Agno-specific patterns (imports, class usage, config)
2. **Classify** presence level:
   - `NOT_PRESENT (0)` -- No evidence whatsoever
   - `MINIMAL (40)` -- Placeholder, stub, or extremely partial
   - `BASIC (70)` -- Works for MVP, missing advanced features
   - `PRODUCTION (85)` -- Solid, covers main use cases
   - `WORLD_CLASS (100)` -- Fully featured, best-in-class
3. **Document** evidence (file paths, code snippets, config entries)
4. **Note** Agno-specific recommendations for improvement

### Discovery Patterns Per Sub-Metric

**D1: Agent Design & Configuration** -- Source: `libs/agno/agno/agent/agent.py`, `AGENTS.md`
- M1.1 Agent definition quality: `Agent(`, `name=`, `description=`, `instructions=`, `model=`, `markdown=True`
- M1.2 Structured I/O: `output_schema=`, `response_model=`, Pydantic model classes used with agents
- M1.3 Context management: `num_history_runs=`, `add_history_to_messages=`, `session_id=`, `storage=`
- M1.4 Agent reuse: Check agents NOT created inside loops/request handlers, module-level or factory pattern

**D2: Tool Integration** -- Source: `libs/agno/agno/tools/toolkit.py`, built-in tools
- M2.1 Tool selection: `from agno.tools` imports, using built-in (DuckDuckGoTools, YFinanceTools, etc.) vs custom
- M2.2 Tool configuration: `cache_results=`, `show_result=`, `confirm=`, tool-level settings
- M2.3 Custom tool quality: `@tool` decorator usage, docstrings, type hints, error handling in custom tools
- M2.4 Tool composition: Toolkit subclasses, `register()` method usage, factory functions for dynamic tool sets

**D3: Knowledge & RAG** -- Source: `libs/agno/agno/knowledge/protocol.py`, vector DB integrations
- M3.1 Vector store setup: `PgVector`, `Pinecone`, `Qdrant`, `Weaviate`, `LanceDb` (not in-memory for prod)
- M3.2 Chunking strategy: `SemanticChunking`, `RecursiveChunking`, `AgenticChunking`, `FixedSizeChunking`
- M3.3 Embedding configuration: `OpenAIEmbedder`, `OllamaEmbedder`, dimension settings, model selection
- M3.4 Search quality: `hybrid_search=True`, `reranker=`, `search_type=`, `limit=`, `score_threshold=`

**D4: Memory & Learning** -- Source: `libs/agno/agno/memory/manager.py`
- M4.1 Memory manager setup: `MemoryManager(`, `db=`, PostgreSQL/SQLite backend
- M4.2 Memory types: `create_user_memories=True`, `create_session_summary=True`, entity memories
- M4.3 Memory optimization: `update_user_memories_after_run=`, summarization config, memory cleanup
- M4.4 Learning integration: Decision logging, user preference tracking, `learnings=` context injection

**D5: Team & Multi-Agent** -- Source: `libs/agno/agno/team/team.py`
- M5.1 Team design: `Team(`, `mode="broadcast"/"router"/"coordinate"`, appropriate mode for use case
- M5.2 Member specialization: Each team member has distinct `name`, `role`, `instructions`, `tools`
- M5.3 Shared resources: `shared_memory=`, distributed knowledge, session context sharing
- M5.4 Coordination quality: Clear team `instructions`, delegation rules, `enable_agentic_context=True`

**D6: Workflow Orchestration** -- Source: `libs/agno/agno/workflow/workflow.py`
- M6.1 Workflow structure: `Workflow(`, `Step`, `Steps`, `Parallel`, `Loop`, `Condition`, `Router`
- M6.2 Error handling: `on_error=`, retry logic, `OnError` handlers, fallback steps
- M6.3 Human-in-the-loop: Pause/resume, `input_required=`, approval gates at steps
- M6.4 State management: `session_state`, state passing between steps, `storage=` for persistence

**D7: Model & Provider Management** -- Source: Agno Models system
- M7.1 Model selection: Appropriate model for task (small model for routing, large for reasoning)
- M7.2 Provider abstraction: Using `"openai:gpt-4"` string format or `OpenAIResponses(id=...)`, not raw API calls
- M7.3 Fallback & redundancy: Backup models, provider failover patterns, `model_fallback=`
- M7.4 Streaming & performance: `stream=True`, `stream_intermediate_steps=True`, response format config

**D8: Safety & Guardrails** -- Source: `libs/agno/agno/guardrails/`
- M8.1 Input guardrails: `input_guardrails=`, prompt injection detection, PII filtering
- M8.2 Output guardrails: `output_guardrails=`, content moderation, response validation
- M8.3 Tool guardrails: `confirm=True` on dangerous tools, approval workflows, tool-level access control
- M8.4 Rate limiting & cost: Token budgets, request limits, cost tracking, `max_tokens=`

**D9: Deployment & Runtime** -- Source: `libs/agno/agno/os/app.py`, FastAPI patterns
- M9.1 AgentOS setup: `AgnoApi(`, FastAPI integration, proper routing, health endpoints
- M9.2 Database configuration: PostgreSQL for prod (not SQLite), migrations, proper connection pooling
- M9.3 Environment configuration: `os.getenv()`, `.env` files, no hardcoded API keys/credentials
- M9.4 Observability: `monitoring=True`, Langfuse integration, OpenTelemetry, structured logging

**D10: Testing & Evaluation** -- Source: `libs/agno/agno/eval/`, cookbook patterns
- M10.1 Agent tests: `pytest` files testing agent behavior, mock tools, response validation
- M10.2 Evaluation framework: `Eval`, `AccuracyEval`, `ReliabilityEval`, LLM-as-judge scoring
- M10.3 Cookbook/examples: Runnable examples per agent, README with setup instructions
- M10.4 CI integration: Tests in CI pipeline, `./scripts/format.sh`, `./scripts/validate.sh`, pre-commit

---

## Phase 4: Scoring

### Scoring Scale (Presence + Maturity)

| Score | Level | Meaning |
|-------|-------|---------|
| **100** | World-class | Fully leverages Agno capabilities, best-in-class patterns |
| **85** | Production-ready | Solid Agno usage, covers main use cases properly |
| **70** | Basic / MVP | Uses Agno correctly for basics, missing advanced features |
| **40** | Minimal | Agno imported but barely configured, default everything |
| **0** | Not present | Feature not used at all |

### Dimension Score Calculation

Each dimension has 4 sub-metrics, equally weighted (25% each within the dimension):

```
dimension_score = (M_x.1 + M_x.2 + M_x.3 + M_x.4) / 4
```

### Overall Score

```
overall_score = sum(dimension_score_i * weight_i) for i in 1..10
```

### Grade Scale

| Grade | Range | Meaning |
|-------|-------|---------|
| A+ | 97-100 | Exemplary Agno usage |
| A  | 93-96  | Excellent, near-complete framework leverage |
| A- | 90-92  | Very strong |
| B+ | 87-89  | Strong |
| B  | 83-86  | Good framework usage |
| B- | 80-82  | Above average |
| C+ | 77-79  | Fair |
| C  | 73-76  | Adequate for early stage |
| C- | 70-72  | Below expectations |
| D+ | 67-69  | Significant gaps |
| D  | 63-66  | Many missed Agno capabilities |
| D- | 60-62  | Barely using the framework |
| F  | 0-59   | Critical -- not leveraging Agno properly |

---

## Phase 5: Output -- The Agno Quality Scorecard

### Scorecard Format

```
================================================================
  PROJECT-AGNO-RX QUALITY SCORECARD
  Project: {project_name}
  Framework: Agno {version}
  Date: {date}
================================================================

  OVERALL SCORE: {score}/100 ({grade})

  ┌─────────────────────────────────────────┬───────┬───────┐
  │ Dimension                               │ Score │ Grade │
  ├─────────────────────────────────────────┼───────┼───────┤
  │ D1: Agent Design & Config (12%)         │ {s}   │ {g}   │
  │   M1.1 Agent Definition Quality        │ {s}   │       │
  │   M1.2 Structured I/O                  │ {s}   │       │
  │   M1.3 Context Management              │ {s}   │       │
  │   M1.4 Agent Reuse                     │ {s}   │       │
  ├─────────────────────────────────────────┼───────┼───────┤
  │ D2: Tool Integration (12%)              │ {s}   │ {g}   │
  │   M2.1 Tool Selection                  │ {s}   │       │
  │   M2.2 Tool Configuration              │ {s}   │       │
  │   M2.3 Custom Tool Quality             │ {s}   │       │
  │   M2.4 Tool Composition                │ {s}   │       │
  ├─────────────────────────────────────────┼───────┼───────┤
  │ D3: Knowledge & RAG (10%)               │ {s}   │ {g}   │
  │   M3.1 Vector Store Setup              │ {s}   │       │
  │   M3.2 Chunking Strategy               │ {s}   │       │
  │   M3.3 Embedding Configuration         │ {s}   │       │
  │   M3.4 Search Quality                  │ {s}   │       │
  ├─────────────────────────────────────────┼───────┼───────┤
  │ D4: Memory & Learning (10%)             │ {s}   │ {g}   │
  │   M4.1 Memory Manager Setup            │ {s}   │       │
  │   M4.2 Memory Types Used               │ {s}   │       │
  │   M4.3 Memory Optimization             │ {s}   │       │
  │   M4.4 Learning Integration            │ {s}   │       │
  ├─────────────────────────────────────────┼───────┼───────┤
  │ D5: Team & Multi-Agent (10%)            │ {s}   │ {g}   │
  │   M5.1 Team Design                     │ {s}   │       │
  │   M5.2 Member Specialization           │ {s}   │       │
  │   M5.3 Shared Resources                │ {s}   │       │
  │   M5.4 Coordination Quality            │ {s}   │       │
  ├─────────────────────────────────────────┼───────┼───────┤
  │ D6: Workflow Orchestration (8%)         │ {s}   │ {g}   │
  │   M6.1 Workflow Structure              │ {s}   │       │
  │   M6.2 Error Handling                  │ {s}   │       │
  │   M6.3 Human-in-the-Loop              │ {s}   │       │
  │   M6.4 State Management               │ {s}   │       │
  ├─────────────────────────────────────────┼───────┼───────┤
  │ D7: Model & Provider Mgmt (10%)         │ {s}   │ {g}   │
  │   M7.1 Model Selection                 │ {s}   │       │
  │   M7.2 Provider Abstraction            │ {s}   │       │
  │   M7.3 Fallback & Redundancy           │ {s}   │       │
  │   M7.4 Streaming & Performance         │ {s}   │       │
  ├─────────────────────────────────────────┼───────┼───────┤
  │ D8: Safety & Guardrails (10%)           │ {s}   │ {g}   │
  │   M8.1 Input Guardrails                │ {s}   │       │
  │   M8.2 Output Guardrails               │ {s}   │       │
  │   M8.3 Tool Guardrails                 │ {s}   │       │
  │   M8.4 Rate Limiting & Cost            │ {s}   │       │
  ├─────────────────────────────────────────┼───────┼───────┤
  │ D9: Deployment & Runtime (10%)          │ {s}   │ {g}   │
  │   M9.1 AgentOS Setup                   │ {s}   │       │
  │   M9.2 Database Configuration          │ {s}   │       │
  │   M9.3 Environment Configuration       │ {s}   │       │
  │   M9.4 Observability                   │ {s}   │       │
  ├─────────────────────────────────────────┼───────┼───────┤
  │ D10: Testing & Evaluation (8%)          │ {s}   │ {g}   │
  │   M10.1 Agent Tests                    │ {s}   │       │
  │   M10.2 Evaluation Framework           │ {s}   │       │
  │   M10.3 Cookbook / Examples             │ {s}   │       │
  │   M10.4 CI Integration                 │ {s}   │       │
  └─────────────────────────────────────────┴───────┴───────┘
```

### Improvement Plan Section

For every sub-metric scoring below 85, output:

```
================================================================
  IMPROVEMENT PLAN
================================================================

  Priority Legend: [BLOCKER] [CRITICAL] [HIGH] [MEDIUM] [LOW]
  Effort Legend:   S (< 1 day)  M (1-3 days)  L (3-7 days)  XL (1-2 weeks)

  ┌────┬───────────────────────────────┬──────────┬────────┬─────────────────────────────────────────────┐
  │ #  │ Sub-Metric                    │ Priority │ Effort │ Agno-Native Solution                        │
  ├────┼───────────────────────────────┼──────────┼────────┼─────────────────────────────────────────────┤
  │ 1  │ M3.1 Vector Store Setup       │ CRITICAL │ M      │ Switch to PgVector2 with pgvector extension │
  │ 2  │ M8.1 Input Guardrails         │ HIGH     │ S      │ Add input_guardrails=[ModerateInput()]       │
  │ ...│                               │          │        │                                             │
  └────┴───────────────────────────────┴──────────┴────────┴─────────────────────────────────────────────┘
```

### Priority Assignment Rules

| Condition | Priority |
|-----------|----------|
| Score 0 in a dimension weighted >= 12% | **BLOCKER** |
| Score 0 in a dimension weighted >= 10% | **CRITICAL** |
| Score 40 in a dimension weighted >= 10% | **HIGH** |
| Score 40 in a dimension weighted >= 8% | **MEDIUM** |
| Score 70 in any dimension | **LOW** |

### Improvement Plan Ordering

Sort items by:
1. Priority (BLOCKER first)
2. Within same priority: lower effort first (quick wins)
3. Within same priority + effort: dimension order (D1 before D2, etc.)

---

## Phase 6: Recommendations Summary

After the scorecard, provide:

### Quick Wins (This Sprint)

List the top 3-5 improvements that can be done in under a day using Agno built-in features.

### Architecture Improvements (Next 2-4 Sprints)

Group larger improvements into logical phases (e.g., "Add RAG pipeline", "Implement team coordination", "Production hardening").

### Agno Features Not Yet Leveraged

List Agno capabilities the project is not using at all that could add value.

### Technical Debt Warning

Flag any patterns that contradict Agno best practices (agents in loops, raw API calls instead of model abstraction, in-memory storage in production).

---

## Rules

1. **Always confirm Agno usage first.** If the project does not use Agno, abort immediately. Do not force-fit this evaluation on non-Agno projects.

2. **Evidence-based scoring only.** Every score must cite specific files, imports, and code patterns. No guessing. If uncertain, score lower and note the uncertainty.

3. **Score 0 means the feature is not used.** The Agno capability exists but the project does not use it at all. Document what you searched for.

4. **Score 40 requires visible code.** A TODO comment or empty file counts as 0. There must be actual Agno class instantiation, even if minimal (e.g., `Agent()` with no instructions).

5. **Score 70 requires working functionality.** The Agno feature is used correctly for the basic case. An agent with name, model, and instructions but no tools scores 70 on M1.1.

6. **Score 85 requires production patterns.** Error handling, configuration externalized, appropriate model selection, tested behavior.

7. **Score 100 is rare and earned.** Must demonstrate advanced Agno patterns, comprehensive use of framework features, monitoring, documentation. Almost never given.

8. **Agno-native solutions FIRST.** Before recommending any external library, check if Agno has a built-in solution. Agno has 100+ built-in tools, 15+ vector DBs, 40+ model providers, guardrails, evals, and more. Always reference the built-in option.

9. **Never inflate scores for potential.** Score what EXISTS, not what is planned or easy to add. The improvement plan handles what to add next.

10. **The improvement plan is mandatory.** Even if the project scores well, there are always Agno features that could be leveraged further. Always produce the improvement plan.

11. **Parallel agents must not overlap.** Each agent scans only their assigned dimensions. No duplicate scanning.

12. **Check AGENTS.md anti-patterns.** Specifically flag: agents created in loops, not reusing agent instances, using SQLite in production, making raw LLM API calls instead of using Agno's model abstraction.

13. **Effort estimates are for reaching score 70.** The effort to go from current state to basic working implementation, not to world-class.

14. **Respect the project's deployment context.** If it is a simple script/demo, do not penalize for missing production deployment (D9). Adjust expectations based on project maturity signals.

15. **Cross-reference with Agno cookbook.** When suggesting improvements, reference relevant Agno cookbook examples or documentation patterns where applicable.

16. **Use LSP when available.** If LSP tools are active (pyright for Python), leverage them for deeper analysis beyond grep:
    - **Go-to-definition** to trace Agent() instantiation sources and verify model types
    - **Find-references** to count how many places reuse an Agent instance (M1.4 reuse detection)
    - **Type checking** to verify output_schema is a valid Pydantic model (M1.2)
    - **Diagnostics** to detect type errors in tool functions, missing return types
    - **Call hierarchy** to trace sync chain depth through agent.run() → tool → external call
    LSP provides ground-truth type information that grep patterns cannot — prefer LSP findings over grep when both are available.

## Auto-Plan Integration

After generating the scorecard and saving the report to `docs/audits/`:
1. Save a copy of the report to `docs/rx-plans/{this-skill-name}/{date}-report.md`
2. For each dimension scoring below 97, invoke the `rx-plan` skill to create or update the improvement plan at `docs/rx-plans/{this-skill-name}/{dimension}/v{N}-{date}-plan.md`
3. Update `docs/rx-plans/{this-skill-name}/summary.md` with current scores
4. Update `docs/rx-plans/dashboard.md` with overall progress

This happens automatically — the user does not need to run `/rx-plan` separately.
