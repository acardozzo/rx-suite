#!/usr/bin/env bash
# d01-agent-design.sh — Agent definition patterns
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PROJECT_ROOT="${1:-.}"
source "$SCRIPT_DIR/../lib/common.sh"

echo "── D01: Agent Design ──"

# M1.1: Agent() definitions with key parameters
agent_files=$(py_list 'Agent\s*(' | head -50)
n_agents=$(count_agents)
has_name=$(echo "$agent_files" | xargs grep -l 'name=' 2>/dev/null | wc -l | tr -d ' ')
has_desc=$(echo "$agent_files" | xargs grep -l 'description=' 2>/dev/null | wc -l | tr -d ' ')
has_instr=$(echo "$agent_files" | xargs grep -l 'instructions=' 2>/dev/null | wc -l | tr -d ' ')
has_model=$(echo "$agent_files" | xargs grep -l 'model=' 2>/dev/null | wc -l | tr -d ' ')
has_md=$(echo "$agent_files" | xargs grep -l 'markdown=' 2>/dev/null | wc -l | tr -d ' ')

if [[ "$n_agents" -gt 0 && "$has_name" -gt 0 && "$has_instr" -gt 0 && "$has_model" -gt 0 ]]; then
  emit "M1.1" "PASS" "Agents: $n_agents | name=$has_name desc=$has_desc instructions=$has_instr model=$has_model markdown=$has_md"
elif [[ "$n_agents" -gt 0 ]]; then
  emit "M1.1" "WARN" "Agents: $n_agents but missing key params (name/instructions/model)"
else
  emit "M1.1" "SKIP" "No Agent() definitions found"
fi

# M1.2: Structured output with output_schema
schema_count=$(py_find -print0 | xargs -0 grep -cE 'output_schema=' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
pydantic=$(py_find -print0 | xargs -0 grep -cE 'from pydantic import|BaseModel' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
if [[ "$schema_count" -gt 0 ]]; then
  emit "M1.2" "PASS" "output_schema used $schema_count times, Pydantic refs=$pydantic"
else
  emit "M1.2" "INFO" "No output_schema usage (structured output not configured)"
fi

# M1.3: Memory/history config on agents
hist_ctx=$(py_find -print0 | xargs -0 grep -cE 'add_history_to_context=' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
hist_runs=$(py_find -print0 | xargs -0 grep -cE 'num_history_runs=' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
agent_db=$(py_find -print0 | xargs -0 grep -cE 'Agent\s*\([^)]*db=' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
if [[ "$hist_ctx" -gt 0 || "$agent_db" -gt 0 ]]; then
  emit "M1.3" "PASS" "History config: add_history=$hist_ctx num_history_runs=$hist_runs db=$agent_db"
else
  emit "M1.3" "INFO" "No history/persistence config on agents"
fi

# M1.4: Anti-pattern — Agent() inside loops
loop_agents=$(py_find -print0 | xargs -0 grep -cE '^\s+(for|while)\b' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
# More precise: files with both loop and Agent() on adjacent lines
bad=$(py_find -print0 | xargs -0 awk '/^\s*(for|while)\b/{loop=NR} loop && NR-loop<5 && /Agent\s*\(/{print FILENAME; loop=0}' 2>/dev/null | sort -u | wc -l | tr -d ' ')
if [[ "$bad" -gt 0 ]]; then
  emit "M1.4" "WARN" "Agent() inside loops detected in $bad files (potential anti-pattern)"
else
  emit "M1.4" "PASS" "No Agent() inside loop anti-pattern"
fi
