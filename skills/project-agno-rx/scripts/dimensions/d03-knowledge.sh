#!/usr/bin/env bash
# d03-knowledge.sh — Knowledge base and vector DB patterns
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PROJECT_ROOT="${1:-.}"
source "$SCRIPT_DIR/../lib/common.sh"

echo "── D03: Knowledge ──"

# M3.1: Vector DB imports
vdb_imports=$(py_find -print0 | xargs -0 grep -ohE 'from agno\.vectordb\.\w+' 2>/dev/null | sort -u)
n_vdb=$(echo "$vdb_imports" | grep -c 'vectordb\.' 2>/dev/null || echo 0)
vdb_names=$(echo "$vdb_imports" | sed 's/from agno\.vectordb\.//' | tr '\n' ',' | sed 's/,$//')
kb_count=$(py_find -print0 | xargs -0 grep -cE 'KnowledgeBase\s*\(' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
if [[ "$n_vdb" -gt 0 ]]; then
  prod=0
  echo "$vdb_names" | grep -qE 'pgvector|qdrant|pinecone|weaviate|milvus' && prod=1
  [[ "$prod" -eq 1 ]] && emit "M3.1" "PASS" "VectorDB ($vdb_names), KBs=$kb_count — production-grade" \
                       || emit "M3.1" "WARN" "VectorDB ($vdb_names), KBs=$kb_count — consider production DB"
else
  emit "M3.1" "INFO" "No agno.vectordb imports found"
fi

# M3.2: Chunking configuration
semantic=$(py_find -print0 | xargs -0 grep -cE 'semantic_chunking|SemanticChunking' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
recursive=$(py_find -print0 | xargs -0 grep -cE 'recursive.*chunk|RecursiveChunking' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
agentic=$(py_find -print0 | xargs -0 grep -cE 'agentic.*chunk|AgenticChunking' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
chunk_size=$(py_find -print0 | xargs -0 grep -oE 'chunk_size\s*=\s*[0-9]+' 2>/dev/null | head -3 | tr '\n' ' ')
if [[ "$semantic" -gt 0 || "$recursive" -gt 0 || "$agentic" -gt 0 ]]; then
  emit "M3.2" "PASS" "Chunking: semantic=$semantic recursive=$recursive agentic=$agentic $chunk_size"
else
  emit "M3.2" "INFO" "No explicit chunking config found"
fi

# M3.3: Embedder imports and dimensions
embedders=$(py_find -print0 | xargs -0 grep -ohE 'from agno\.\w+.*import.*Embedder' 2>/dev/null | sort -u | wc -l | tr -d ' ')
embedder_names=$(py_find -print0 | xargs -0 grep -ohE '\w+Embedder' 2>/dev/null | sort -u | tr '\n' ',' | sed 's/,$//')
dims=$(py_find -print0 | xargs -0 grep -oE 'dimensions\s*=\s*[0-9]+' 2>/dev/null | head -3 | tr '\n' ' ')
if [[ "$embedders" -gt 0 ]]; then
  emit "M3.3" "PASS" "Embedders: $embedder_names $dims"
else
  emit "M3.3" "INFO" "No explicit Embedder imports"
fi

# M3.4: Search/retrieval configuration
search_type=$(py_find -print0 | xargs -0 grep -cE 'search_type=' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
hybrid=$(py_find -print0 | xargs -0 grep -cE 'hybrid\s*=\s*True' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
reranker=$(py_find -print0 | xargs -0 grep -cE 'reranker=' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
threshold=$(py_find -print0 | xargs -0 grep -cE 'similarity_threshold=' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
if [[ "$search_type" -gt 0 || "$hybrid" -gt 0 || "$reranker" -gt 0 ]]; then
  emit "M3.4" "PASS" "Retrieval: search_type=$search_type hybrid=$hybrid reranker=$reranker threshold=$threshold"
else
  emit "M3.4" "INFO" "No retrieval tuning config"
fi
