#!/usr/bin/env bash
# D5: Type & Lint Debt — any types, disabled lint rules, missing annotations, TODO/FIXME

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

PROJECT_ROOT="${1:-.}"
detect_stacks "$PROJECT_ROOT"
detect_tools

section_header "D5" "Type & Lint Debt (10%)"

# ─── M5.1: any Type Usage ───
metric_header "M5.1" "any Type Usage"

ANY_COUNT=$(count_any_types "$PROJECT_ROOT")
if [[ "$ANY_COUNT" -gt 0 ]]; then
  # Show top offenders
  TOP_ANY=$(grep -rn "as any\|: any\|@ts-ignore\|@ts-expect-error" \
    --include='*.ts' --include='*.tsx' \
    --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist --exclude-dir=.next \
    "$PROJECT_ROOT" 2>/dev/null | head -10 || true)
  if [[ -n "$TOP_ANY" ]]; then
    while IFS= read -r line; do
      file=$(echo "$line" | cut -d: -f1)
      lineno=$(echo "$line" | cut -d: -f2)
      finding "TIER1" "M5.1" "any/ts-ignore usage" "$file" "$lineno"
    done <<< "$TOP_ANY"
  fi
fi
finding "INFO" "M5.1" "$ANY_COUNT total any type usages"

# Python Any types
if $STACK_PYTHON; then
  PY_ANY=$(grep -rn ": Any\|-> Any\|typing.Any" \
    --include='*.py' --exclude-dir=.venv --exclude-dir=venv --exclude-dir=.git \
    "$PROJECT_ROOT" 2>/dev/null | wc -l | tr -d ' ')
  [[ "$PY_ANY" -gt 0 ]] && finding "INFO" "M5.1" "$PY_ANY Python Any type usages"
fi

# ─── M5.2: Disabled Lint Rules ───
metric_header "M5.2" "Disabled Lint Rules"

DISABLED_RULES=0
# eslint-disable
ESLINT_DISABLE=$(grep -rn "eslint-disable\|eslint-disable-next-line\|eslint-disable-line" \
  --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist --exclude-dir=.next \
  "$PROJECT_ROOT" 2>/dev/null | wc -l | tr -d ' ')
DISABLED_RULES=$((DISABLED_RULES + ESLINT_DISABLE))

# Python noqa / type: ignore / pylint: disable
PY_DISABLED=0
if $STACK_PYTHON; then
  PY_DISABLED=$(grep -rn "# noqa\|# type: ignore\|# pylint: disable\|# type:ignore" \
    --include='*.py' --exclude-dir=.venv --exclude-dir=venv --exclude-dir=.git \
    "$PROJECT_ROOT" 2>/dev/null | wc -l | tr -d ' ')
  DISABLED_RULES=$((DISABLED_RULES + PY_DISABLED))
fi

finding "INFO" "M5.2" "$DISABLED_RULES disabled lint rules (eslint-disable: $ESLINT_DISABLE, Python: $PY_DISABLED)"

# ─── M5.3: Missing Type Annotations ───
metric_header "M5.3" "Missing Type Annotations"

MISSING_TYPES=0
# TypeScript: functions without explicit return type (heuristic)
if $STACK_TYPESCRIPT; then
  # Functions with no return type annotation: "function name(" or "const name = (" without ":"
  UNTYPED_TS=$(grep -rn "^\s*export\s\+function\s\+\w\+(.*)\s*{" \
    --include='*.ts' --include='*.tsx' \
    --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist --exclude-dir=.next \
    "$PROJECT_ROOT" 2>/dev/null | grep -v "): " | wc -l | tr -d ' ')
  MISSING_TYPES=$((MISSING_TYPES + UNTYPED_TS))
fi

# Python: functions without type hints
if $STACK_PYTHON; then
  UNTYPED_PY=$(grep -rn "^\s*def \w\+(" \
    --include='*.py' --exclude-dir=.venv --exclude-dir=venv --exclude-dir=.git \
    "$PROJECT_ROOT" 2>/dev/null | grep -v " -> " | wc -l | tr -d ' ')
  MISSING_TYPES=$((MISSING_TYPES + UNTYPED_PY))
fi

finding "INFO" "M5.3" "$MISSING_TYPES functions with missing type annotations"

# ─── M5.4: TODO/FIXME/HACK Comments ───
metric_header "M5.4" "TODO/FIXME/HACK Comments"

TODO_COUNT=$(count_todo_fixme "$PROJECT_ROOT")
if [[ "$TODO_COUNT" -gt 0 ]]; then
  # Show sample
  SAMPLE=$(grep -rn "TODO\|FIXME\|HACK\|XXX" \
    --include='*.ts' --include='*.tsx' --include='*.py' --include='*.js' \
    --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist --exclude-dir=.next \
    --exclude-dir=.venv --exclude-dir=venv \
    "$PROJECT_ROOT" 2>/dev/null | head -5 || true)
  if [[ -n "$SAMPLE" ]]; then
    while IFS= read -r line; do
      file=$(echo "$line" | cut -d: -f1)
      lineno=$(echo "$line" | cut -d: -f2)
      finding "TIER3" "M5.4" "Tech debt marker" "$file" "$lineno"
    done <<< "$SAMPLE"
  fi
fi
finding "INFO" "M5.4" "$TODO_COUNT TODO/FIXME/HACK/XXX comments"

echo ""
echo -e "  ${BOLD}D5 Raw Totals:${NC} any_types=$ANY_COUNT disabled_lint=$DISABLED_RULES missing_types=$MISSING_TYPES todo_fixme=$TODO_COUNT"
