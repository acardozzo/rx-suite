#!/usr/bin/env bash
# d07-models.sh — Model provider and configuration patterns
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PROJECT_ROOT="${1:-.}"
source "$SCRIPT_DIR/../lib/common.sh"

echo "── D07: Models ──"

# M7.1: Model class usage variety
model_imports=$(py_find -print0 | xargs -0 grep -ohE 'from agno\.models\.\w+\s+import\s+\w+' 2>/dev/null | sort -u)
model_classes=$(echo "$model_imports" | grep -oE 'import \w+' | sed 's/import //' | sort -u | tr '\n' ',' | sed 's/,$//')
n_providers=$(echo "$model_imports" | grep -oE 'agno\.models\.\w+' | sort -u | wc -l | tr -d ' ')
model_param=$(py_find -print0 | xargs -0 grep -cE 'model\s*=\s*["\x27]' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
if [[ "$n_providers" -gt 0 ]]; then
  emit "M7.1" "PASS" "Providers=$n_providers Classes: $model_classes model_param=$model_param"
else
  emit "M7.1" "WARN" "No agno.models imports found"
fi

# M7.2: String format vs class usage, raw API call anti-pattern
string_fmt=$(py_find -print0 | xargs -0 grep -cE 'model\s*=\s*"(openai|anthropic|google|groq):[^"]+' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
raw_openai=$(py_find -print0 | xargs -0 grep -cE 'openai\.chat\.completions\.create|client\.chat\.completions' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
raw_anthropic=$(py_find -print0 | xargs -0 grep -cE 'anthropic\.messages\.create|client\.messages\.create' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
if [[ "$raw_openai" -gt 0 || "$raw_anthropic" -gt 0 ]]; then
  emit "M7.2" "WARN" "Raw API calls detected (openai=$raw_openai anthropic=$raw_anthropic) — use agno.models instead"
else
  emit "M7.2" "PASS" "No raw API calls — string_format=$string_fmt class_usage=$n_providers"
fi

# M7.3: Multi-model / fallback patterns
model_defs=$(py_find -print0 | xargs -0 grep -cE '(OpenAI|Claude|Gemini|Groq|Ollama)\w*\s*\(' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
fallback=$(py_find -print0 | xargs -0 grep -cE 'fallback|backup_model|secondary_model' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
if [[ "$model_defs" -gt 1 && "$fallback" -gt 0 ]]; then
  emit "M7.3" "PASS" "Multi-model: $model_defs instances, fallback=$fallback"
elif [[ "$model_defs" -gt 1 ]]; then
  emit "M7.3" "INFO" "Multiple models ($model_defs) but no fallback logic"
else
  emit "M7.3" "INFO" "Single model usage"
fi

# M7.4: Streaming and response format
stream=$(py_find -print0 | xargs -0 grep -cE 'stream\s*=\s*True' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
resp_fmt=$(py_find -print0 | xargs -0 grep -cE 'response_format\s*=' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
stream_handler=$(py_find -print0 | xargs -0 grep -cE 'on_stream|stream_handler|astream' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
if [[ "$stream" -gt 0 ]]; then
  emit "M7.4" "PASS" "Streaming: stream=$stream handlers=$stream_handler response_format=$resp_fmt"
else
  emit "M7.4" "INFO" "No streaming config (stream=0 response_format=$resp_fmt)"
fi
