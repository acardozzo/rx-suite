#!/usr/bin/env bash
# d02-tools.sh — Tool usage patterns
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PROJECT_ROOT="${1:-.}"
source "$SCRIPT_DIR/../lib/common.sh"

echo "── D02: Tools ──"

# M2.1: Built-in tool imports
builtin_tools=$(py_find -print0 | xargs -0 grep -ohE 'from agno\.tools\.\w+' 2>/dev/null | sort -u)
n_builtin=$(echo "$builtin_tools" | grep -c 'agno\.tools\.' 2>/dev/null || echo 0)
tool_names=$(echo "$builtin_tools" | sed 's/from agno\.tools\.//' | tr '\n' ',' | sed 's/,$//')
if [[ "$n_builtin" -gt 0 ]]; then
  emit "M2.1" "PASS" "Built-in tools ($n_builtin): $tool_names"
else
  emit "M2.1" "INFO" "No built-in agno.tools imports"
fi

# M2.2: Tool configuration (cache, confirmation, show_result)
cache=$(py_find -print0 | xargs -0 grep -cE 'cache\s*=\s*True' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
confirm=$(py_find -print0 | xargs -0 grep -cE 'confirmation\s*=\s*True' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
show_res=$(py_find -print0 | xargs -0 grep -cE 'show_result\s*=' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
if [[ "$cache" -gt 0 || "$confirm" -gt 0 || "$show_res" -gt 0 ]]; then
  emit "M2.2" "PASS" "Tool config: cache=$cache confirmation=$confirm show_result=$show_res"
else
  emit "M2.2" "INFO" "No tool cache/confirmation/show_result config"
fi

# M2.3: @tool decorator, docstrings, type hints
decorators=$(py_find -print0 | xargs -0 grep -cE '^\s*@tool\b' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
# Check tool functions have docstrings (function after @tool with """ on next few lines)
tool_files=$(py_find -print0 | xargs -0 grep -lE '^\s*@tool\b' 2>/dev/null || true)
docstring_count=0
if [[ -n "$tool_files" ]]; then
  docstring_count=$(echo "$tool_files" | xargs awk '/@tool/{t=1;next} t && /def /{d=1;next} d && /"""|'\'''\'''\''/{c++;d=0;t=0} /^$/{d=0;t=0} END{print c+0}' 2>/dev/null || echo 0)
fi
hints=$(py_find -print0 | xargs -0 grep -cE 'def \w+\([^)]*:\s*(str|int|float|bool|list|dict|Optional)' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
if [[ "$decorators" -gt 0 ]]; then
  emit "M2.3" "PASS" "@tool decorators: $decorators | docstrings~$docstring_count | typed_params=$hints"
else
  emit "M2.3" "INFO" "No @tool decorator usage"
fi

# M2.4: Toolkit subclasses and tool_factories
toolkits=$(py_find -print0 | xargs -0 grep -cE 'class\s+\w+\(.*Toolkit' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
factories=$(py_find -print0 | xargs -0 grep -cE 'tool_factories\s*=' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
tools_list=$(py_find -print0 | xargs -0 grep -cE 'tools\s*=\s*\[' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
if [[ "$toolkits" -gt 0 || "$factories" -gt 0 ]]; then
  emit "M2.4" "PASS" "Toolkit subclasses=$toolkits tool_factories=$factories tools=[...]=$tools_list"
else
  emit "M2.4" "INFO" "No Toolkit subclasses or tool_factories (tools=[$tools_list])"
fi
