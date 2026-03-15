#!/usr/bin/env bash
# D11: AI/ML Integration Patterns
# M11.1 Model Serving | M11.2 RAG/Embedding | M11.3 Prompt Mgmt | M11.4 MLOps
source "$(dirname "$0")/../lib/common.sh"

echo "## D11: AI/ML INTEGRATION PATTERNS"
echo ""

# M11.1: Model serving
section "M11.1: Model serving & inference architecture"
echo "LLM providers:"
src_list "(openai|anthropic|claude|gpt-|gemini|ollama|langchain|litellm|ai-sdk|@ai-sdk|huggingface|cohere|mistral)" 15
echo "Provider abstraction:"
src_list "(litellm|ai.?gateway|model.?router|provider.?factory|llm.?client|ai.?client|createModel)" 5
echo "Streaming inference:"
src_list "(stream.*true|\.stream\(|StreamingTextResponse|ReadableStream|streamText|createStreamable)" 5
echo ""

# M11.2: RAG & embeddings
section "M11.2: RAG & embedding pipeline"
src_list "(vector|embedding|pinecone|chromadb|weaviate|qdrant|pgvector|faiss|milvus|similarity.?search|cosine|chunk)" 10
echo ""

# M11.3: Prompt management
section "M11.3: Prompt engineering & LLM management"
echo "Prompt files/templates:"
find "$TARGET_ABS" -type d \( -name "prompts" -o -name "prompt*" -o -name "templates" \) 2>/dev/null | head -5
find "$TARGET_ABS" -type f \( -name "*prompt*" -o -name "*system*message*" \) ! -path "*/node_modules/*" 2>/dev/null | head -5
echo "Guardrails:"
src_list "(guardrail|content.?filter|moderat|safety.?check|input.?valid.*prompt|output.?valid.*response)" 5
echo "Structured output:"
src_list "(response_format|structured.?output|json_schema|tool_choice|function_call|generateObject)" 5
echo ""

# M11.4: MLOps lifecycle
section "M11.4: MLOps lifecycle & feedback"
src_list "(langfuse|langsmith|promptfoo|braintrust|ragas|evaluate|eval.*pipeline|token.*usage|token.*count|feedback.*loop|human.*feedback|thumbs)" 10
echo "Cost tracking:"
src_list "(token.*cost|cost.*track|usage.*track|billing.*ai|model.*cost)" 5
echo ""
