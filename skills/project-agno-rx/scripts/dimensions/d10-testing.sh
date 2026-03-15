#!/usr/bin/env bash
# d10-testing.sh — Testing and evaluation patterns
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PROJECT_ROOT="${1:-.}"
source "$SCRIPT_DIR/../lib/common.sh"

echo "── D10: Testing ──"

# M10.1: Test files with Agent imports
test_files=$(py_find -name 'test_*.py' -o -name '*_test.py' | wc -l | tr -d ' ')
agent_tests=$(py_find \( -name 'test_*.py' -o -name '*_test.py' \) -print0 | xargs -0 grep -lE 'from agno|import agno|Agent\s*\(' 2>/dev/null | wc -l | tr -d ' ')
if [[ "$agent_tests" -gt 0 ]]; then
  emit "M10.1" "PASS" "Agent test files=$agent_tests (total tests=$test_files)"
elif [[ "$test_files" -gt 0 ]]; then
  emit "M10.1" "WARN" "Test files=$test_files but none import agno (no agent-specific tests)"
else
  emit "M10.1" "WARN" "No test files found"
fi

# M10.2: Agno eval framework
eval_import=$(py_find -print0 | xargs -0 grep -cE 'from agno\.eval' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
eval_scripts=$(py_find -name '*eval*' | wc -l | tr -d ' ')
accuracy=$(py_find -print0 | xargs -0 grep -cE 'Accuracy|accuracy' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
reliability=$(py_find -print0 | xargs -0 grep -cE 'Reliability|reliability' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
if [[ "$eval_import" -gt 0 ]]; then
  emit "M10.2" "PASS" "Eval framework: imports=$eval_import scripts=$eval_scripts accuracy=$accuracy reliability=$reliability"
elif [[ "$eval_scripts" -gt 0 ]]; then
  emit "M10.2" "INFO" "Eval scripts=$eval_scripts but no agno.eval imports"
else
  emit "M10.2" "WARN" "No eval scripts or agno.eval usage"
fi

# M10.3: Examples / cookbook directory
has_cookbook=0; has_examples=0; has_readme=0
[[ -d "$ROOT/cookbook" ]] && has_cookbook=1
[[ -d "$ROOT/examples" ]] && has_examples=1
[[ -f "$ROOT/cookbook/README.md" || -f "$ROOT/examples/README.md" ]] && has_readme=1
example_count=$(find "$ROOT/cookbook" "$ROOT/examples" -name '*.py' 2>/dev/null | wc -l | tr -d ' ')
if [[ "$has_cookbook" -eq 1 || "$has_examples" -eq 1 ]]; then
  emit "M10.3" "PASS" "Examples: cookbook=$has_cookbook examples=$has_examples py_files=$example_count readme=$has_readme"
else
  emit "M10.3" "INFO" "No cookbook/ or examples/ directory"
fi

# M10.4: CI configuration
ci_files=$(find "$ROOT" -maxdepth 3 \( -name '*.yml' -o -name '*.yaml' \) -path '*/.github/*' 2>/dev/null | wc -l | tr -d ' ')
has_test_ci=$(find "$ROOT" -maxdepth 3 -path '*/.github/*' \( -name '*.yml' -o -name '*.yaml' \) -print0 2>/dev/null | xargs -0 grep -lE 'pytest|test|validate|format' 2>/dev/null | wc -l | tr -d ' ')
format_sh=$(find "$ROOT" -maxdepth 2 -name 'format.sh' -o -name 'lint.sh' 2>/dev/null | wc -l | tr -d ' ')
validate_sh=$(find "$ROOT" -maxdepth 2 -name 'validate.sh' -o -name 'check.sh' 2>/dev/null | wc -l | tr -d ' ')
if [[ "$has_test_ci" -gt 0 ]]; then
  emit "M10.4" "PASS" "CI: workflows=$ci_files test_ci=$has_test_ci format_sh=$format_sh validate_sh=$validate_sh"
elif [[ "$ci_files" -gt 0 ]]; then
  emit "M10.4" "WARN" "CI exists ($ci_files) but no test/validate steps found"
else
  emit "M10.4" "WARN" "No CI configuration found"
fi
