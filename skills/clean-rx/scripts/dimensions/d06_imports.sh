#!/usr/bin/env bash
# D6: Import Hygiene — Circular imports, unused imports, wildcard imports, deep relative paths

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

PROJECT_ROOT="${1:-.}"
detect_stacks "$PROJECT_ROOT"
detect_tools

section_header "D6" "Import Hygiene (10%)"

# ─── M6.1: Circular Imports ───
metric_header "M6.1" "Circular Imports"

CIRCULAR=0
if $HAS_MADGE && $STACK_TYPESCRIPT; then
  CIRC_OUT=$(cd "$PROJECT_ROOT" && npx madge --circular --extensions ts,tsx src/ 2>/dev/null || true)
  if [[ -n "$CIRC_OUT" && "$CIRC_OUT" != *"No circular"* ]]; then
    CIRCULAR=$(echo "$CIRC_OUT" | grep -c ">" || echo "0")
    while IFS= read -r chain; do
      [[ -n "$chain" ]] && finding "TIER2" "M6.1" "Circular: $chain"
    done <<< "$(echo "$CIRC_OUT" | head -10)"
  fi
  finding "INFO" "M6.1" "$CIRCULAR circular import chains (madge)"
else
  finding "INFO" "M6.1" "madge not available — install for circular import detection"
fi

# ─── M6.2: Unused Imports ───
metric_header "M6.2" "Unused Imports"

UNUSED_IMPORTS=0

# Python: ruff F401
if $HAS_RUFF && $STACK_PYTHON; then
  RUFF_F401=$(cd "$PROJECT_ROOT" && ruff check --select F401 --output-format json . 2>/dev/null | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    print(len(data))
except: print(0)
" 2>/dev/null || echo "0")
  UNUSED_IMPORTS=$((UNUSED_IMPORTS + RUFF_F401))
  [[ "$RUFF_F401" -gt 0 ]] && finding "TIER1" "M6.2" "$RUFF_F401 unused Python imports (ruff F401, auto-fixable)"
fi

# TypeScript: grep heuristic (knip is better)
if $STACK_TYPESCRIPT; then
  if $HAS_KNIP; then
    KNIP_IMPORTS=$(cd "$PROJECT_ROOT" && npx knip --reporter json 2>/dev/null | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    print(len(data.get('unlisted', [])))
except: print(0)
" 2>/dev/null || echo "0")
    UNUSED_IMPORTS=$((UNUSED_IMPORTS + KNIP_IMPORTS))
    [[ "$KNIP_IMPORTS" -gt 0 ]] && finding "TIER1" "M6.2" "$KNIP_IMPORTS unused TS imports (knip)"
  else
    finding "INFO" "M6.2" "Install knip for accurate TS unused import detection"
  fi
fi

finding "INFO" "M6.2" "$UNUSED_IMPORTS total unused imports"

# ─── M6.3: Wildcard Imports ───
metric_header "M6.3" "Wildcard Imports"

WILDCARD=0
# Python: from x import *
PY_WILD=$(grep -rn "from .* import \*" \
  --include='*.py' --exclude-dir=.venv --exclude-dir=venv --exclude-dir=.git --exclude-dir=__pycache__ \
  "$PROJECT_ROOT" 2>/dev/null || true)
if [[ -n "$PY_WILD" ]]; then
  PY_WILD_COUNT=$(echo "$PY_WILD" | wc -l | tr -d ' ')
  WILDCARD=$((WILDCARD + PY_WILD_COUNT))
  while IFS= read -r line; do
    file=$(echo "$line" | cut -d: -f1)
    lineno=$(echo "$line" | cut -d: -f2)
    finding "TIER1" "M6.3" "Wildcard import" "$file" "$lineno"
  done <<< "$(echo "$PY_WILD" | head -10)"
fi

# JS/TS: import * (note: import * as X is often intentional for namespaces)
TS_WILD=$(grep -rn "import \* from\|import \* as.*from" \
  --include='*.ts' --include='*.tsx' --include='*.js' \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist --exclude-dir=.next \
  "$PROJECT_ROOT" 2>/dev/null || true)
if [[ -n "$TS_WILD" ]]; then
  TS_WILD_COUNT=$(echo "$TS_WILD" | wc -l | tr -d ' ')
  WILDCARD=$((WILDCARD + TS_WILD_COUNT))
fi

finding "INFO" "M6.3" "$WILDCARD wildcard imports"

# ─── M6.4: Deep Relative Imports ───
metric_header "M6.4" "Deep Relative Imports (> 3 levels)"

DEEP_IMPORTS=$(grep -rn "from ['\"]\.\.\/\.\.\/\.\.\/\.\.\/" \
  --include='*.ts' --include='*.tsx' --include='*.js' \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist --exclude-dir=.next \
  "$PROJECT_ROOT" 2>/dev/null || true)
DEEP_COUNT=0
if [[ -n "$DEEP_IMPORTS" ]]; then
  DEEP_COUNT=$(echo "$DEEP_IMPORTS" | wc -l | tr -d ' ')
  while IFS= read -r line; do
    file=$(echo "$line" | cut -d: -f1)
    lineno=$(echo "$line" | cut -d: -f2)
    finding "TIER1" "M6.4" "Deep relative import (use path alias)" "$file" "$lineno"
  done <<< "$(echo "$DEEP_IMPORTS" | head -10)"
fi
finding "INFO" "M6.4" "$DEEP_COUNT deep relative imports"

echo ""
echo -e "  ${BOLD}D6 Raw Totals:${NC} circular=$CIRCULAR unused_imports=$UNUSED_IMPORTS wildcard=$WILDCARD deep_relative=$DEEP_COUNT"
