#!/usr/bin/env bash
# d08-safety.sh — Safety, guardrails, and cost control patterns
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PROJECT_ROOT="${1:-.}"
source "$SCRIPT_DIR/../lib/common.sh"

echo "── D08: Safety ──"

# M8.1: Input guardrails
guard_import=$(py_find -print0 | xargs -0 grep -cE 'from agno\.guardrails' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
guard_names=$(py_find -print0 | xargs -0 grep -ohE '\w+Guardrail' 2>/dev/null | sort -u | tr '\n' ',' | sed 's/,$//')
input_guard=$(py_find -print0 | xargs -0 grep -cE 'input_guardrails\s*=' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
if [[ "$guard_import" -gt 0 ]]; then
  emit "M8.1" "PASS" "Guardrails imported=$guard_import input_guardrails=$input_guard types: $guard_names"
else
  emit "M8.1" "WARN" "No agno.guardrails imports — no input validation"
fi

# M8.2: Output validation and moderation
output_guard=$(py_find -print0 | xargs -0 grep -cE 'output_guardrails\s*=' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
moderation=$(py_find -print0 | xargs -0 grep -cE 'ModerationGuardrail|moderation' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
pii=$(py_find -print0 | xargs -0 grep -cE 'PIIDetection|pii' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
if [[ "$output_guard" -gt 0 || "$moderation" -gt 0 ]]; then
  emit "M8.2" "PASS" "Output guardrails=$output_guard moderation=$moderation pii=$pii"
else
  emit "M8.2" "WARN" "No output guardrails or moderation"
fi

# M8.3: Confirmation on dangerous tools
confirm_tools=$(py_find -print0 | xargs -0 grep -cE 'confirmation\s*=\s*True' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
approval_wf=$(py_find -print0 | xargs -0 grep -cE 'from agno\.approval|ApprovalRequired|requires_approval' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
if [[ "$confirm_tools" -gt 0 || "$approval_wf" -gt 0 ]]; then
  emit "M8.3" "PASS" "Tool confirmation=$confirm_tools approval_workflows=$approval_wf"
else
  emit "M8.3" "INFO" "No tool confirmation or approval patterns"
fi

# M8.4: Token limits, cost tracking, rate limiting
token_limit=$(py_find -print0 | xargs -0 grep -cE 'max_tokens|token_limit|max_completion_tokens' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
cost=$(py_find -print0 | xargs -0 grep -cE 'cost|budget|spending|token_usage' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
rate_limit=$(py_find -print0 | xargs -0 grep -cE 'rate_limit|throttle|RateLimiter' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
if [[ "$token_limit" -gt 0 || "$cost" -gt 0 ]]; then
  emit "M8.4" "PASS" "Limits: token_limit=$token_limit cost_tracking=$cost rate_limit=$rate_limit"
else
  emit "M8.4" "WARN" "No token limits or cost controls"
fi
