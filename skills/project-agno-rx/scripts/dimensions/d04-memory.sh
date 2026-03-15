#!/usr/bin/env bash
# d04-memory.sh — Memory management patterns
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PROJECT_ROOT="${1:-.}"
source "$SCRIPT_DIR/../lib/common.sh"

echo "── D04: Memory ──"

# M4.1: MemoryManager import and instantiation
mm_import=$(py_find -print0 | xargs -0 grep -cE 'from agno\.memory.*import.*MemoryManager' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
mm_inst=$(py_find -print0 | xargs -0 grep -cE 'MemoryManager\s*\(' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
mm_db=$(py_find -print0 | xargs -0 grep -cE 'MemoryManager\s*\([^)]*db=' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
if [[ "$mm_import" -gt 0 ]]; then
  emit "M4.1" "PASS" "MemoryManager imported=$mm_import instantiated=$mm_inst with_db=$mm_db"
else
  emit "M4.1" "INFO" "No MemoryManager usage"
fi

# M4.2: Agentic memory flags
agentic_mem=$(py_find -print0 | xargs -0 grep -cE 'enable_agentic_memory\s*=\s*True' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
update_mem=$(py_find -print0 | xargs -0 grep -cE 'update_memory_on_run\s*=\s*True' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
add_mem_ctx=$(py_find -print0 | xargs -0 grep -cE 'add_memories_to_context\s*=\s*True' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
if [[ "$agentic_mem" -gt 0 || "$update_mem" -gt 0 ]]; then
  emit "M4.2" "PASS" "Agentic memory: enable=$agentic_mem update_on_run=$update_mem add_to_ctx=$add_mem_ctx"
else
  emit "M4.2" "INFO" "No agentic memory flags set"
fi

# M4.3: Memory optimization
summarize=$(py_find -print0 | xargs -0 grep -cE 'summarize|create_session_summary|summary_model' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
mem_limit=$(py_find -print0 | xargs -0 grep -cE 'memory_limit|max_memories' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
if [[ "$summarize" -gt 0 || "$mem_limit" -gt 0 ]]; then
  emit "M4.3" "PASS" "Memory optimization: summarization=$summarize limits=$mem_limit"
else
  emit "M4.3" "INFO" "No memory optimization config"
fi

# M4.4: Learning machine
learn_import=$(py_find -print0 | xargs -0 grep -cE 'from agno\.learn' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
learn_usage=$(py_find -print0 | xargs -0 grep -cE 'LearningMachine|learning_machine' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
if [[ "$learn_import" -gt 0 ]]; then
  emit "M4.4" "PASS" "Learning machine: imports=$learn_import usage=$learn_usage"
else
  emit "M4.4" "INFO" "No agno.learn usage"
fi
