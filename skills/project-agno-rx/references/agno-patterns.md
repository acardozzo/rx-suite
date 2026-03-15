# Agno Best Practices & Anti-Patterns Reference

> Scoring reference for project-agno-rx evaluations. Agents use this document to evaluate
> Agno project code against established best practices and known anti-patterns.
> Every item maps to a specific dimension and sub-metric in the scorecard.

---

## Anti-Patterns (Things That Lose Points)

These are the patterns that scoring agents look for as violations. Each anti-pattern includes
the detection rule, why it's harmful, the fix, and which dimension/sub-metric it affects.

---

### Anti-Pattern #1: Agent Created Inside Loop

**Detection**: `Agent()` instantiation inside `for`, `while`, or list comprehension.

**Severity**: Critical (performance killer)

**Why it's bad**: Each `Agent()` call initializes model connections, tool registrations, and
memory structures. In a loop over N items, this creates N independent agent instances instead
of reusing one. For 1000 iterations, you waste ~1000x the initialization cost, and each agent
has no shared context.

**Example (bad)**:
```python
for user in users:
    agent = Agent(
        model=OpenAIChat(id="gpt-4o"),
        tools=[WebSearchTools()],
        storage=PostgresDb(...),
    )
    result = agent.run(f"Analyze {user.name}")
```

**Fix**:
```python
agent = Agent(
    model=OpenAIChat(id="gpt-4o"),
    tools=[WebSearchTools()],
    storage=PostgresDb(...),
)
for user in users:
    result = agent.run(f"Analyze {user.name}", session_id=user.id)
```

**Dimension**: D1 Agent Design (M1.5 Agent reuse)
**Score impact**: -20 points on D1

---

### Anti-Pattern #2: Raw API Calls Bypassing Agno

**Detection**: Direct imports of `openai`, `anthropic`, `google.generativeai` SDKs with
`.create()` or `.generate()` calls instead of using Agno model classes.

**Severity**: Critical (defeats purpose of framework)

**Why it's bad**: Raw API calls bypass Agno's entire value proposition: tracing, memory,
tool integration, structured output, guardrails, and provider switching. You get none of
the framework benefits while still paying the framework's dependency cost.

**Example (bad)**:
```python
from openai import OpenAI
client = OpenAI()
response = client.chat.completions.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": prompt}]
)
```

**Fix**:
```python
from agno.agent import Agent
from agno.models.openai import OpenAIChat

agent = Agent(model=OpenAIChat(id="gpt-4o"))
response = agent.run(prompt)
```

**Dimension**: D1 Agent Design (M1.4 Model selection)
**Score impact**: -30 points on D1

---

### Anti-Pattern #3: No Output Schema

**Detection**: Agent that returns data consumed by downstream code but has no `output_schema=`
parameter. Often accompanied by regex parsing of agent text output.

**Severity**: High (unreliable output)

**Why it's bad**: Without `output_schema`, the agent returns free-text that varies between calls.
Downstream code that parses this text with regex or string splitting breaks when the model
changes its wording, formatting, or language. Structured output guarantees a consistent schema.

**Example (bad)**:
```python
agent = Agent(model=OpenAIChat(id="gpt-4o"))
result = agent.run("Analyze sentiment of this text: ...")
# Fragile parsing
sentiment = result.content.split("Sentiment: ")[1].split("\n")[0]
```

**Fix**:
```python
from pydantic import BaseModel, Field

class SentimentAnalysis(BaseModel):
    sentiment: str = Field(..., description="positive, negative, or neutral")
    confidence: float = Field(..., ge=0, le=1)
    reasoning: str

agent = Agent(
    model=OpenAIChat(id="gpt-4o"),
    output_schema=SentimentAnalysis,
)
result = agent.run("Analyze sentiment of this text: ...")
analysis: SentimentAnalysis = result.output  # typed, guaranteed schema
```

**Dimension**: D1 Agent Design (M1.3 Output schema)
**Score impact**: -15 points on D1

---

### Anti-Pattern #4: In-Memory Storage for Production

**Detection**: `SqliteDb` or no `storage=`/`db=` parameter on agents deployed to production.
Also: `InMemoryDb` usage outside of tests.

**Severity**: High (data loss on restart)

**Why it's bad**: SQLite does not handle concurrent writes from multiple workers (common in
production deployments behind a load balancer). Agent sessions, memories, and conversation
history are lost when the container restarts. InMemoryDb loses everything on process exit.

**Example (bad)**:
```python
from agno.storage.sqlite import SqliteDb
storage = SqliteDb(path="agents.db")
agent = Agent(storage=storage, ...)
```

**Fix**:
```python
from agno.storage.postgres import PostgresDb
storage = PostgresDb(
    table_name="agent_sessions",
    db_url="postgresql://user:pass@host:5432/db",
)
agent = Agent(storage=storage, ...)
```

**Dimension**: D5 Storage & Data (M5.1 Database choice, M5.4 Production readiness)
**Score impact**: -25 points on D5

---

### Anti-Pattern #5: No Session Persistence

**Detection**: Agent without `db=` or `storage=` parameter AND no `session_id` passed to `.run()`.

**Severity**: High (loses conversation history)

**Why it's bad**: Without session persistence, every agent call starts fresh with no history.
Multi-turn conversations are impossible. The agent cannot reference previous messages, learn
from corrections, or maintain context.

**Example (bad)**:
```python
agent = Agent(model=OpenAIChat(id="gpt-4o"))
# Every call is independent — no memory of previous interactions
agent.run("What was my previous question?")  # Agent has no idea
```

**Fix**:
```python
agent = Agent(
    model=OpenAIChat(id="gpt-4o"),
    storage=PostgresDb(table_name="sessions", db_url="..."),
    add_history_to_messages=True,
    num_history_responses=10,
)
agent.run("Hello", session_id="user-123-session-1")
agent.run("What was my previous question?", session_id="user-123-session-1")  # Remembers
```

**Dimension**: D4 Memory & Sessions (M4.3 Session persistence)
**Score impact**: -20 points on D4

---

### Anti-Pattern #6: Hardcoded Model

**Detection**: Agent without explicit `model=` parameter (relying on defaults) or model ID
hardcoded deep in business logic instead of configuration.

**Severity**: Medium (inflexible, hard to optimize)

**Why it's bad**: Without explicit model selection, you cannot optimize cost/quality tradeoffs.
Different tasks need different models (cheap for classification, powerful for reasoning).
Defaults change between Agno versions. Hardcoded model IDs in business logic make it hard
to swap providers or upgrade models.

**Example (bad)**:
```python
# Relying on default model (which model? what version?)
agent = Agent(tools=[WebSearchTools()])

# Or hardcoded deep in business logic
def process_request(data):
    agent = Agent(model=OpenAIChat(id="gpt-4o-2024-05-13"))  # pinned, buried
```

**Fix**:
```python
from agno.models.openai import OpenAIChat
from agno.models.anthropic import Claude

# Configuration-driven model selection
MODELS = {
    "reasoning": Claude(id="claude-sonnet-4-6"),
    "fast": OpenAIChat(id="gpt-4o-mini"),
    "structured": OpenAIChat(id="gpt-4o"),
}

research_agent = Agent(model=MODELS["reasoning"], ...)
classifier_agent = Agent(model=MODELS["fast"], ...)
```

**Dimension**: D1 Agent Design (M1.4 Model selection)
**Score impact**: -10 points on D1

---

### Anti-Pattern #7: Over-Tooling

**Detection**: Agent with more than 7 tools registered. Count `tools=[]` list length.

**Severity**: Medium (reduces accuracy)

**Why it's bad**: LLMs degrade in tool selection accuracy as the number of tools increases.
With 20+ tools, the model frequently picks the wrong tool or hallucinates tool names.
Research shows 5-7 tools is the sweet spot for reliable selection.

**Example (bad)**:
```python
agent = Agent(
    model=OpenAIChat(id="gpt-4o"),
    tools=[
        WebSearchTools(), FileTools(), HttpTools(), PythonTools(),
        SqlTools(), GmailTools(), SlackTools(), ShellTools(),
        GitTools(), DockerTools(), AwsTools(), GcpTools(),
        JiraTools(), NotionTools(), LinearTools(),  # 15+ tools!
    ],
)
```

**Fix**: Split into specialized agents with 5-7 tools each, coordinated by a Team:
```python
web_agent = Agent(name="Web Researcher", tools=[WebSearchTools(), HttpTools()])
code_agent = Agent(name="Code Assistant", tools=[FileTools(), PythonTools(), GitTools()])
comms_agent = Agent(name="Communications", tools=[GmailTools(), SlackTools()])

team = Team(
    name="Assistant Team",
    mode="route",  # Route to the right agent based on task
    members=[web_agent, code_agent, comms_agent],
)
```

**Dimension**: D2 Tool Integration (M2.3 Tool count per agent)
**Score impact**: -15 points on D2

---

### Anti-Pattern #8: No Guardrails

**Detection**: Production-deployed agent without any input/output validation, moderation,
or safety checks. No `input_guardrails=`, `output_guardrails=`, or equivalent middleware.

**Severity**: Medium (security/safety risk)

**Why it's bad**: Agents with tool access can execute real actions (send emails, query databases,
write files). Without guardrails, prompt injection can manipulate agents into harmful actions.
Without output validation, agents may leak sensitive data or generate harmful content.

**Example (bad)**:
```python
# Production agent with tool access and zero safety checks
agent = Agent(
    model=OpenAIChat(id="gpt-4o"),
    tools=[SqlTools(), GmailTools(), FileTools()],
    # No guardrails at all
)
```

**Fix**:
```python
def moderate_input(message: str) -> str:
    """Block prompt injection attempts."""
    injection_patterns = [
        "ignore previous instructions",
        "system prompt",
        "you are now",
        "disregard",
    ]
    for pattern in injection_patterns:
        if pattern.lower() in message.lower():
            raise ValueError(f"Blocked: potential prompt injection detected")
    return message

def validate_output(response: str) -> str:
    """Check for PII leaks and harmful content."""
    import re
    # Basic PII detection
    if re.search(r'\b\d{3}-\d{2}-\d{4}\b', response):  # SSN pattern
        raise ValueError("Output contains potential SSN — blocked")
    return response

agent = Agent(
    model=OpenAIChat(id="gpt-4o"),
    tools=[SqlTools(), GmailTools()],
    input_guardrails=[moderate_input],
    output_guardrails=[validate_output],
)
```

**Dimension**: D7 Safety & Guardrails (M7.1 Content moderation, M7.2 PII detection)
**Score impact**: -20 points on D7

---

### Anti-Pattern #9: Missing or Vague Instructions

**Detection**: Agent without `instructions=` parameter, or instructions that are generic
("You are a helpful assistant", "Help the user", "Be professional").

**Severity**: Medium (inconsistent behavior)

**Why it's bad**: Instructions are the primary mechanism for controlling agent behavior.
Without specific instructions, the agent falls back to the model's default behavior, which
varies between providers and versions. Vague instructions provide no actionable guidance
and produce inconsistent results.

**Example (bad)**:
```python
# No instructions at all
agent = Agent(model=OpenAIChat(id="gpt-4o"), tools=[WebSearchTools()])

# Or vague instructions
agent = Agent(
    model=OpenAIChat(id="gpt-4o"),
    instructions=["Be helpful and professional"],
)
```

**Fix**:
```python
agent = Agent(
    name="Financial Research Analyst",
    model=OpenAIChat(id="gpt-4o"),
    instructions=[
        "You are a financial research analyst specializing in public equities.",
        "Always cite sources with URLs when presenting financial data.",
        "Present numbers in USD with proper formatting ($1,234.56).",
        "If data is older than 24 hours, warn the user about staleness.",
        "Never make investment recommendations — only present facts.",
        "For comparisons, always use tables with consistent metrics.",
    ],
    tools=[WebSearchTools()],
)
```

**Dimension**: D1 Agent Design (M1.2 Instructions quality)
**Score impact**: -15 points on D1

---

### Anti-Pattern #10: No Evaluation Framework

**Detection**: No test files for agents, no AgentEval usage, no accuracy/reliability checks,
no eval datasets. Zero files matching `*eval*`, `*test*agent*`, or `*bench*` patterns.

**Severity**: Low (quality blind spot)

**Why it's bad**: Without evals, you cannot measure whether agent changes improve or degrade
quality. Model upgrades, instruction changes, and tool modifications all affect output quality
in non-obvious ways. Evals are the only way to catch regressions.

**Example (bad)**:
```python
# Ship agent changes with vibes-based testing
agent = Agent(model=OpenAIChat(id="gpt-4o"), ...)
# Manually test once, deploy, hope for the best
```

**Fix**:
```python
from agno.eval import AgentEval

eval_suite = AgentEval(
    agent=agent,
    test_cases=[
        {
            "input": "What is the capital of France?",
            "expected": "Paris",
            "check": "contains",
        },
        {
            "input": "Summarize this article: ...",
            "expected_schema": SummaryOutput,
            "check": "schema_valid",
        },
    ],
    metrics=["accuracy", "latency", "token_usage"],
)
results = eval_suite.run()
assert results.accuracy >= 0.95, f"Accuracy dropped: {results.accuracy}"
```

**Dimension**: D8 Observability & Eval (M8.3 AgentEval)
**Score impact**: -15 points on D8

---

## Best Practices (Things That Earn Points)

These are the patterns that scoring agents reward. Each best practice includes the detection
rule, why it matters, and the implementation example.

---

### Best Practice #1: Named Agents with Description

**Detection**: Every `Agent()` call has both `name=` and `description=` parameters.

**Why it matters**: Named agents are identifiable in logs, traces, and team coordination.
Descriptions help the Team coordinator route tasks to the right agent. Unnamed agents produce
confusing traces ("Agent-1 called Agent-2") and degrade team routing accuracy.

```python
agent = Agent(
    name="Market Research Analyst",
    description="Researches market trends, competitor data, and industry reports using web search",
    model=Claude(id="claude-sonnet-4-6"),
    ...
)
```

**Dimension**: D1 Agent Design (M1.1 Agent naming)
**Score value**: +10 points on D1

---

### Best Practice #2: Typed Output with Pydantic

**Detection**: `output_schema=` parameter present with a Pydantic `BaseModel` subclass on
agents that return structured data.

**Why it matters**: Guarantees consistent, parseable output. Eliminates regex parsing fragility.
Enables IDE autocomplete on agent results. Makes agent contracts explicit and testable.

```python
from pydantic import BaseModel, Field

class CompetitorAnalysis(BaseModel):
    company: str
    strengths: list[str] = Field(..., min_length=1)
    weaknesses: list[str] = Field(..., min_length=1)
    market_share: float = Field(..., ge=0, le=100, description="Percentage")
    threat_level: str = Field(..., pattern="^(low|medium|high|critical)$")

agent = Agent(
    model=OpenAIChat(id="gpt-4o"),
    output_schema=CompetitorAnalysis,
)
```

**Dimension**: D1 Agent Design (M1.3 Output schema)
**Score value**: +15 points on D1

---

### Best Practice #3: Persistent PostgreSQL Storage

**Detection**: `PostgresDb` used for storage with proper connection configuration.
Bonus points for connection pooling and migration strategy.

**Why it matters**: Production agents need reliable, concurrent-safe storage. PostgreSQL
handles multiple workers, survives container restarts, supports backups, and integrates
with existing infrastructure.

```python
from agno.storage.postgres import PostgresDb

storage = PostgresDb(
    table_name="agent_sessions",
    db_url="postgresql://user:pass@host:5432/agentdb",
)

agent = Agent(
    model=OpenAIChat(id="gpt-4o"),
    storage=storage,
    add_history_to_messages=True,
    num_history_responses=10,
)
```

**Dimension**: D5 Storage & Data (M5.1, M5.4)
**Score value**: +25 points on D5

---

### Best Practice #4: Memory Manager with Agentic Memory

**Detection**: `MemoryManager` configured with `enable_agentic_memory=True` on the agent.

**Why it matters**: Enables agents to remember user preferences, past interactions, and
learned facts across sessions. Agents build a persistent understanding of each user over time,
creating personalized experiences without re-prompting.

```python
from agno.memory.manager import MemoryManager

memory = MemoryManager(
    db=PostgresDb(table_name="agent_memory", db_url="postgresql://..."),
    model=OpenAIChat(id="gpt-4o-mini"),  # Cheap model for memory ops
)

agent = Agent(
    model=OpenAIChat(id="gpt-4o"),
    memory_manager=memory,
    enable_agentic_memory=True,
    add_history_to_messages=True,
    num_history_responses=5,
)
```

**Dimension**: D4 Memory & Sessions (M4.1, M4.2, M4.4)
**Score value**: +30 points on D4

---

### Best Practice #5: Knowledge RAG with Vector DB

**Detection**: `VectorDb` configuration (PgVector, Qdrant, Pinecone, etc.) with embedder
and knowledge base (PDFKnowledgeBase, URLKnowledgeBase, etc.) connected to an agent
via `knowledge=` and `search_knowledge=True`.

**Why it matters**: RAG grounds agent responses in actual documents rather than model
training data. Dramatically reduces hallucination on domain-specific questions. Enables
agents to answer questions about private/proprietary data.

```python
from agno.knowledge.pdf import PDFKnowledgeBase
from agno.vectordb.pgvector import PgVector
from agno.embedder.openai import OpenAIEmbedder

knowledge = PDFKnowledgeBase(
    path="data/company_docs/",
    vector_db=PgVector(
        table_name="document_embeddings",
        db_url="postgresql://...",
        embedder=OpenAIEmbedder(id="text-embedding-3-small"),
    ),
    chunk_size=1000,
    chunk_overlap=200,
)

agent = Agent(
    model=OpenAIChat(id="gpt-4o"),
    knowledge=knowledge,
    search_knowledge=True,
    instructions=["Always search the knowledge base before answering domain questions."],
)
```

**Dimension**: D3 Knowledge & RAG (M3.1, M3.2, M3.3, M3.4)
**Score value**: +40 points on D3

---

### Best Practice #6: Guardrails on Production Agents

**Detection**: `input_guardrails=` and/or `output_guardrails=` parameters present, or
equivalent middleware wrapping agent calls. At minimum: moderation + PII detection.

**Why it matters**: Agents with tool access are powerful attack surfaces. Input guardrails
prevent prompt injection. Output guardrails prevent PII leaks and harmful content generation.
Both are essential for production deployment.

```python
from agno.agent import Agent

def moderate_input(message: str) -> str:
    """Block prompt injection and harmful inputs."""
    # Use an LLM-based moderation check or rule-based
    blocked = ["ignore previous", "system prompt", "you are now"]
    if any(b in message.lower() for b in blocked):
        raise ValueError("Input blocked by moderation")
    return message

def check_pii_output(response: str) -> str:
    """Ensure no PII in agent output."""
    import re
    patterns = {
        "SSN": r'\b\d{3}-\d{2}-\d{4}\b',
        "Credit Card": r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b',
        "Email": r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b',
    }
    for name, pattern in patterns.items():
        if re.search(pattern, response):
            raise ValueError(f"Output blocked: contains potential {name}")
    return response

agent = Agent(
    model=OpenAIChat(id="gpt-4o"),
    input_guardrails=[moderate_input],
    output_guardrails=[check_pii_output],
)
```

**Dimension**: D7 Safety & Guardrails (M7.1, M7.2)
**Score value**: +35 points on D7

---

### Best Practice #7: Streaming for User-Facing Agents

**Detection**: `stream=True` on agents that serve interactive user sessions (API endpoints,
chat interfaces). SSE or WebSocket endpoint for delivering streamed responses.

**Why it matters**: Without streaming, users stare at a blank screen for 5-30 seconds while
the agent processes. Streaming provides immediate feedback, improves perceived performance,
and enables early cancellation.

```python
# Agent with streaming
agent = Agent(
    model=OpenAIChat(id="gpt-4o"),
    stream=True,
)

# FastAPI SSE endpoint
from fastapi.responses import StreamingResponse

@app.post("/chat")
async def chat(request: ChatRequest):
    async def generate():
        async for chunk in agent.arun(request.message, stream=True):
            yield f"data: {chunk.model_dump_json()}\n\n"
    return StreamingResponse(generate(), media_type="text/event-stream")
```

**Dimension**: D9 API & Deployment (M9.3 Streaming)
**Score value**: +15 points on D9

---

### Best Practice #8: Team for Complex Multi-Agent Tasks

**Detection**: `Team()` usage with `mode=` parameter and multiple member agents, instead
of a single agent with 10+ tools trying to do everything.

**Why it matters**: Teams enable specialization. Each agent has focused tools and instructions,
improving accuracy. The coordinator/router handles task decomposition and delegation.
Teams scale better than monolithic agents.

```python
from agno.team import Team

research_agent = Agent(
    name="Researcher",
    description="Finds and retrieves information from the web",
    model=Claude(id="claude-sonnet-4-6"),
    tools=[WebSearchTools()],
)

analyst_agent = Agent(
    name="Data Analyst",
    description="Analyzes data, creates charts, runs calculations",
    model=OpenAIChat(id="gpt-4o"),
    tools=[PythonTools()],
)

writer_agent = Agent(
    name="Technical Writer",
    description="Writes clear, structured reports from research and analysis",
    model=OpenAIChat(id="gpt-4o"),
    tools=[FileTools()],
)

team = Team(
    name="Research Report Team",
    mode="coordinate",
    members=[research_agent, analyst_agent, writer_agent],
    storage=PostgresDb(table_name="team_sessions", db_url="..."),
    instructions=[
        "1. Researcher gathers data on the topic",
        "2. Analyst processes and structures the data",
        "3. Writer produces the final report",
    ],
)
```

**Dimension**: D6 Teams & Orchestration (M6.1 Team design)
**Score value**: +30 points on D6

---

### Best Practice #9: Workflow for Multi-Step Deterministic Processes

**Detection**: `Workflow()` usage for processes that need deterministic step ordering,
branching logic, or error recovery — instead of hoping an agent picks the right sequence.

**Why it matters**: Some processes have strict order requirements (validate, then process,
then notify). Agents may skip steps or reorder them. Workflows guarantee step execution
order with proper error handling at each step.

```python
from agno.workflow import Workflow

class ReportWorkflow(Workflow):
    name = "report_pipeline"
    description = "Generate a research report with validation"

    def run(self, topic: str) -> str:
        # Step 1: Research (always first)
        research = self.research_agent.run(f"Research {topic}")
        if not research.output:
            raise ValueError("Research step failed")

        # Step 2: Analyze (needs research data)
        analysis = self.analyst_agent.run(
            f"Analyze this research: {research.output}"
        )

        # Step 3: Write (needs both research + analysis)
        report = self.writer_agent.run(
            f"Write report from:\nResearch: {research.output}\nAnalysis: {analysis.output}"
        )

        return report.output
```

**Dimension**: D6 Teams & Orchestration (M6.3 Workflow usage)
**Score value**: +20 points on D6

---

### Best Practice #10: Evaluation Framework

**Detection**: Test files with agent evaluation logic, AgentEval usage, eval datasets,
accuracy/reliability metrics collection.

**Why it matters**: Evals are the only way to measure agent quality objectively. They catch
regressions when you change models, instructions, or tools. They provide confidence for
production deployments.

```python
from agno.eval import AgentEval

eval_suite = AgentEval(
    agent=agent,
    test_cases=[
        {
            "input": "What is the capital of France?",
            "expected": "Paris",
            "check": "contains",
        },
        {
            "input": "Summarize: The quick brown fox jumps over the lazy dog.",
            "expected_schema": SummaryOutput,
            "check": "schema_valid",
        },
        {
            "input": "What is 2+2?",
            "expected": "4",
            "check": "exact",
        },
    ],
    metrics=["accuracy", "latency", "token_usage", "tool_call_accuracy"],
)

results = eval_suite.run()
print(f"Accuracy: {results.accuracy:.2%}")
print(f"Avg latency: {results.avg_latency:.2f}s")
assert results.accuracy >= 0.95
```

**Dimension**: D8 Observability & Eval (M8.3 AgentEval)
**Score value**: +25 points on D8

---

### Best Practice #11: Observability with Tracing

**Detection**: `tracing=True` on agents, and/or integration with Langfuse, OpenTelemetry,
or Agno monitoring dashboard.

**Why it matters**: Without observability, agent failures are black boxes. Tracing shows
every model call, tool invocation, and decision point. Essential for debugging production
issues, optimizing token usage, and identifying bottlenecks.

```python
agent = Agent(
    model=OpenAIChat(id="gpt-4o"),
    tracing=True,       # Agno built-in tracing
    monitoring=True,     # Agno monitoring dashboard
)

# For Langfuse integration
import os
os.environ["LANGFUSE_PUBLIC_KEY"] = "..."
os.environ["LANGFUSE_SECRET_KEY"] = "..."
os.environ["LANGFUSE_HOST"] = "https://cloud.langfuse.com"

agent = Agent(
    model=OpenAIChat(id="gpt-4o"),
    tracing=True,
)
```

**Dimension**: D8 Observability & Eval (M8.1 Tracing, M8.2 Langfuse/OTel)
**Score value**: +20 points on D8

---

### Best Practice #12: Cookbook Examples

**Detection**: `cookbook/` or `examples/` directory with runnable agent scripts, each with
its own README explaining purpose, setup, and expected output.

**Why it matters**: Examples are the fastest onboarding path. New team members can run an
example in 5 minutes and understand how agents work. Examples also serve as integration tests
and documentation.

```
examples/
  research_agent/
    README.md          # What it does, how to run, expected output
    run.py             # Runnable script: python run.py "Research topic"
    requirements.txt   # Minimal dependencies
  team_workflow/
    README.md
    run.py
    requirements.txt
```

**Dimension**: D10 Code Quality & DX (M10.4 Examples)
**Score value**: +10 points on D10

---

## Model Selection Guide

Use this reference to evaluate whether agents are using appropriate models for their tasks.

| Use Case | Recommended Model | Agno Class | Cost | Quality |
|----------|------------------|------------|------|---------|
| Complex reasoning, analysis | Claude Sonnet/Opus | `Claude(id="claude-sonnet-4-6")` | $$$ | Highest |
| Fast classification, routing | GPT-4o-mini | `OpenAIResponses(id="gpt-4o-mini")` | $ | Good |
| Structured output, function calling | GPT-4o | `OpenAIChat(id="gpt-4o")` | $$ | High |
| Multimodal (vision + text) | Gemini 2.0 Flash | `Gemini(id="gemini-2.0-flash")` | $ | Good |
| Local/private deployment | Ollama + Llama | `Ollama(id="llama3.2")` | Free | Varies |
| Cost optimization at scale | DeepSeek | `DeepSeek(id="deepseek-chat")` | $ | Good |
| Memory management (cheap ops) | GPT-4o-mini | `OpenAIChat(id="gpt-4o-mini")` | $ | Sufficient |
| Embeddings | text-embedding-3-small | `OpenAIEmbedder(id="text-embedding-3-small")` | ¢ | High |

### Model Selection Anti-Patterns

- Using Claude Opus for simple classification (overkill, expensive)
- Using GPT-4o-mini for complex multi-step reasoning (insufficient)
- Same model for all agents regardless of task complexity
- No explicit model parameter (relying on defaults)

---

## Tool Selection Guide

Reference for evaluating tool usage and recommending appropriate built-in tools.

| Need | Built-in Tool | Import | Max per Agent |
|------|--------------|--------|---------------|
| Web search | WebSearchTools | `from agno.tools.websearch import WebSearchTools` | - |
| SQL queries | SqlTools | `from agno.tools.sql import SqlTools` | - |
| File read/write | FileTools | `from agno.tools.file import FileTools` | - |
| HTTP requests | HttpTools | `from agno.tools.http import HttpTools` | - |
| Python execution | PythonTools | `from agno.tools.python import PythonTools` | - |
| Email (Gmail) | GmailTools | `from agno.tools.email import GmailTools` | - |
| Slack messaging | SlackTools | `from agno.tools.slack import SlackTools` | - |
| Shell commands | ShellTools | `from agno.tools.shell import ShellTools` | - |
| Arxiv papers | ArxivTools | `from agno.tools.arxiv import ArxivTools` | - |
| Wikipedia | WikipediaTools | `from agno.tools.wikipedia import WikipediaTools` | - |
| YouTube transcripts | YouTubeTools | `from agno.tools.youtube import YouTubeTools` | - |
| CSV/data | CsvTools | `from agno.tools.csv_tools import CsvTools` | - |

### Tool Guidance Rules

1. **5-7 tools per agent maximum.** Beyond this, accuracy drops.
2. **Prefer built-in tools** over custom implementations for standard operations.
3. **Custom tools** should have clear docstrings — the model uses these to decide when to call them.
4. **Dangerous tools** (ShellTools, SqlTools with write access) need guardrails.
5. **Group related tools** on the same agent (web tools together, file tools together).

---

## Scoring Weights by Dimension

Default weights for the 10 dimensions. These may be adjusted based on project type
(e.g., RAG-heavy project weights D3 higher).

| # | Dimension | Default Weight | Notes |
|---|-----------|---------------|-------|
| D1 | Agent Design | 15% | Core — every Agno project needs good agents |
| D2 | Tool Integration | 10% | Important but scope varies |
| D3 | Knowledge & RAG | 10% | Critical for RAG projects, lower for others |
| D4 | Memory & Sessions | 10% | Critical for conversational agents |
| D5 | Storage & Data | 10% | Infrastructure foundation |
| D6 | Teams & Orchestration | 10% | N/A for single-agent projects |
| D7 | Safety & Guardrails | 10% | Non-negotiable for production |
| D8 | Observability & Eval | 10% | Essential for production quality |
| D9 | API & Deployment | 10% | Required for serving agents |
| D10 | Code Quality & DX | 5% | Supporting dimension |

### Weight Adjustment Triggers

| Project Type | Dimensions to Weight Higher | Dimensions to Weight Lower |
|-------------|---------------------------|---------------------------|
| RAG/Knowledge Agent | D3 (1.5x), D5 (1.3x) | D6 (0.5x if single agent) |
| Conversational Agent | D4 (1.5x), D1 (1.3x) | D3 (0.7x if no knowledge needed) |
| Multi-Agent Team | D6 (1.5x), D2 (1.3x) | D3 (0.7x if no knowledge) |
| API Agent Service | D9 (1.5x), D7 (1.3x) | D6 (0.5x if no team) |
| Prototype/MVP | D1 (1.5x), D2 (1.2x) | D7 (0.5x), D8 (0.5x) |
