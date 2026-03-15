#!/usr/bin/env bash
# d06-workflow.sh — Workflow orchestration patterns
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PROJECT_ROOT="${1:-.}"
source "$SCRIPT_DIR/../lib/common.sh"

echo "── D06: Workflow ──"

# M6.1: Workflow() and Step/Parallel/Loop/Condition/Router imports
wf_count=$(py_find -print0 | xargs -0 grep -cE '\bWorkflow\s*\(' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
wf_imports=$(py_find -print0 | xargs -0 grep -ohE 'from agno\.workflow.*import\s+(.*)' 2>/dev/null | sort -u)
step=$(py_find -print0 | xargs -0 grep -cE '\b(Step|Steps)\s*\(' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
parallel=$(py_find -print0 | xargs -0 grep -cE '\bParallel\s*\(' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
loop=$(py_find -print0 | xargs -0 grep -cE '\bLoop\s*\(' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
condition=$(py_find -print0 | xargs -0 grep -cE '\bCondition\s*\(' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
router=$(py_find -print0 | xargs -0 grep -cE '\bRouter\s*\(' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
if [[ "$wf_count" -gt 0 ]]; then
  emit "M6.1" "PASS" "Workflows=$wf_count Step=$step Parallel=$parallel Loop=$loop Condition=$condition Router=$router"
else
  emit "M6.1" "INFO" "No Workflow() usage found"
fi

# M6.2: Error handling in workflows
on_error=$(py_find -print0 | xargs -0 grep -cE 'on_error\s*=' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
retry=$(py_find -print0 | xargs -0 grep -cE 'retry|max_retries|retry_count' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
if [[ "$on_error" -gt 0 || "$retry" -gt 0 ]]; then
  emit "M6.2" "PASS" "Error handling: on_error=$on_error retry=$retry"
else
  [[ "$wf_count" -gt 0 ]] && emit "M6.2" "WARN" "Workflows without error handlers" \
                           || emit "M6.2" "INFO" "No workflow error handling"
fi

# M6.3: Human-in-the-loop patterns
user_input=$(py_find -print0 | xargs -0 grep -cE 'user_input\s*=' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
pause=$(py_find -print0 | xargs -0 grep -cE 'pause|resume|approval' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
if [[ "$user_input" -gt 0 || "$pause" -gt 0 ]]; then
  emit "M6.3" "PASS" "Human-in-loop: user_input=$user_input pause/approval=$pause"
else
  emit "M6.3" "INFO" "No human-in-the-loop patterns"
fi

# M6.4: State passing and session management
session_id=$(py_find -print0 | xargs -0 grep -cE 'session_id\s*=' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
state_pass=$(py_find -print0 | xargs -0 grep -cE 'state\s*=|run_state|workflow_state' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
if [[ "$session_id" -gt 0 || "$state_pass" -gt 0 ]]; then
  emit "M6.4" "PASS" "State mgmt: session_id=$session_id state=$state_pass"
else
  [[ "$wf_count" -gt 0 ]] && emit "M6.4" "WARN" "Workflows without session/state management" \
                           || emit "M6.4" "INFO" "No workflow state management"
fi
