#!/usr/bin/env bash
# D9: Python Waste — Unused imports, dead functions/classes, unused vars, empty __init__.py
# Score as N/A (100) if project doesn't use Python

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

PROJECT_ROOT="${1:-.}"
detect_stacks "$PROJECT_ROOT"
detect_tools

if ! $STACK_PYTHON; then
  echo -e "  ${YELLOW}D9: Python not detected — scoring as N/A (100)${NC}"
  exit 0
fi

section_header "D9" "Python Waste (8%)"

# ─── M9.1: Unused Python Imports ───
metric_header "M9.1" "Unused Python Imports"

UNUSED_PY_IMPORTS=0
if $HAS_RUFF; then
  RUFF_OUT=$(cd "$PROJECT_ROOT" && ruff check --select F401 --output-format text . 2>/dev/null || true)
  if [[ -n "$RUFF_OUT" ]]; then
    UNUSED_PY_IMPORTS=$(echo "$RUFF_OUT" | wc -l | tr -d ' ')
    while IFS= read -r line; do
      finding "TIER1" "M9.1" "Unused import (ruff F401, auto-fixable): $line"
    done <<< "$(echo "$RUFF_OUT" | head -15)"
  fi
else
  # Fallback: basic grep for common patterns
  UNUSED_PY_IMPORTS=$(grep -rn "^import \|^from .* import " \
    --include='*.py' --exclude-dir=.venv --exclude-dir=venv --exclude-dir=.git --exclude-dir=__pycache__ \
    "$PROJECT_ROOT" 2>/dev/null | wc -l | tr -d ' ')
  finding "INFO" "M9.1" "Found $UNUSED_PY_IMPORTS import lines (install ruff for accurate unused detection)"
  UNUSED_PY_IMPORTS=0  # Cannot confirm unused without ruff
fi
finding "INFO" "M9.1" "$UNUSED_PY_IMPORTS unused Python imports"

# ─── M9.2: Dead Python Functions/Classes ───
metric_header "M9.2" "Dead Python Functions/Classes"

DEAD_PY_FUNCS=0
if $HAS_VULTURE; then
  VULTURE_OUT=$(cd "$PROJECT_ROOT" && vulture . --min-confidence 80 2>/dev/null || true)
  if [[ -n "$VULTURE_OUT" ]]; then
    DEAD_ITEMS=$(echo "$VULTURE_OUT" | grep -c "unused function\|unused class\|unused method" || echo "0")
    DEAD_PY_FUNCS=$DEAD_ITEMS
    while IFS= read -r line; do
      finding "TIER2" "M9.2" "$line"
    done <<< "$(echo "$VULTURE_OUT" | grep "unused function\|unused class\|unused method" | head -15)"
  fi
else
  # Fallback: find function/class defs and check for callers
  PY_DEFS=$(grep -rn "^def \|^class " \
    --include='*.py' --exclude-dir=.venv --exclude-dir=venv --exclude-dir=.git --exclude-dir=__pycache__ \
    "$PROJECT_ROOT" 2>/dev/null || true)
  if [[ -n "$PY_DEFS" ]]; then
    while IFS= read -r line; do
      file=$(echo "$line" | cut -d: -f1)
      name=$(echo "$line" | grep -oP '(?:def|class)\s+\K\w+' || true)
      [[ -z "$name" || "$name" == "__"* || "$name" == "test_"* ]] && continue
      CALLERS=$(grep -rl "$name" --include='*.py' \
        --exclude-dir=.venv --exclude-dir=venv --exclude-dir=.git --exclude-dir=__pycache__ \
        "$PROJECT_ROOT" 2>/dev/null | grep -v "$file" | head -1 || true)
      if [[ -z "$CALLERS" ]]; then
        ((DEAD_PY_FUNCS++)) || true
      fi
    done <<< "$(echo "$PY_DEFS" | head -80)"
    finding "INFO" "M9.2" "Install vulture for more accurate dead code detection"
  fi
fi
finding "INFO" "M9.2" "$DEAD_PY_FUNCS dead Python functions/classes"

# ─── M9.3: Unused Python Variables ───
metric_header "M9.3" "Unused Python Variables"

UNUSED_PY_VARS=0
if $HAS_RUFF; then
  RUFF_F841=$(cd "$PROJECT_ROOT" && ruff check --select F841 --output-format text . 2>/dev/null || true)
  if [[ -n "$RUFF_F841" ]]; then
    UNUSED_PY_VARS=$(echo "$RUFF_F841" | wc -l | tr -d ' ')
    while IFS= read -r line; do
      finding "TIER1" "M9.3" "Unused variable (ruff F841, auto-fixable): $line"
    done <<< "$(echo "$RUFF_F841" | head -10)"
  fi
fi
finding "INFO" "M9.3" "$UNUSED_PY_VARS unused Python variables"

# ─── M9.4: Empty __init__.py ───
metric_header "M9.4" "Empty __init__.py Files"

EMPTY_INIT=0
INIT_FILES=$(find "$PROJECT_ROOT" -name "__init__.py" \
  -not -path "*/.venv/*" -not -path "*/venv/*" -not -path "*/.git/*" \
  -not -path "*/node_modules/*" -not -path "*/__pycache__/*" 2>/dev/null || true)
if [[ -n "$INIT_FILES" ]]; then
  while IFS= read -r init_file; do
    [[ -z "$init_file" ]] && continue
    # Check if file is empty or only whitespace/comments
    CONTENT=$(grep -cve '^\s*#\|^\s*$' "$init_file" 2>/dev/null || echo "0")
    if [[ "$CONTENT" == "0" ]]; then
      ((EMPTY_INIT++)) || true
      finding "TIER1" "M9.4" "Empty __init__.py (removable in Python 3.3+)" "$init_file"
    fi
  done <<< "$INIT_FILES"
fi
finding "INFO" "M9.4" "$EMPTY_INIT empty __init__.py files"

echo ""
echo -e "  ${BOLD}D9 Raw Totals:${NC} unused_imports=$UNUSED_PY_IMPORTS dead_funcs=$DEAD_PY_FUNCS unused_vars=$UNUSED_PY_VARS empty_init=$EMPTY_INIT"
