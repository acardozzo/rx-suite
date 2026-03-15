#!/usr/bin/env bash
# D1: Dead Code & Unreachable — Unused exports, dead functions, unreachable code, commented-out code

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

PROJECT_ROOT="${1:-.}"
detect_stacks "$PROJECT_ROOT"
detect_tools

section_header "D1" "Dead Code & Unreachable (15%)"

# ─── M1.1: Unused Exports ───
metric_header "M1.1" "Unused Exports"

UNUSED_EXPORTS=0
if $HAS_KNIP && $STACK_TYPESCRIPT; then
  KNIP_OUT=$(cd "$PROJECT_ROOT" && npx knip --reporter json 2>/dev/null || echo "{}")
  UNUSED_EXPORTS=$(echo "$KNIP_OUT" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    print(len(data.get('exports', [])))
except: print(0)
" 2>/dev/null || echo "0")
  finding "INFO" "M1.1" "knip detected $UNUSED_EXPORTS unused exports"
else
  # Fallback: count exported functions/consts, check if imported elsewhere
  EXPORTS=$(grep -rn "^export \(function\|const\|class\|interface\|type\|enum\)" \
    --include='*.ts' --include='*.tsx' \
    --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist --exclude-dir=.next \
    "$PROJECT_ROOT" 2>/dev/null || true)
  if [[ -n "$EXPORTS" ]]; then
    while IFS= read -r line; do
      file=$(echo "$line" | cut -d: -f1)
      name=$(echo "$line" | grep -oP '(?:function|const|class|interface|type|enum)\s+\K\w+' || true)
      if [[ -n "$name" ]]; then
        importers=$(grep -rl "$name" --include='*.ts' --include='*.tsx' \
          --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
          "$PROJECT_ROOT" 2>/dev/null | grep -v "$file" | head -1 || true)
        if [[ -z "$importers" ]]; then
          ((UNUSED_EXPORTS++)) || true
          finding "TIER2" "M1.1" "Unused export: $name" "$file"
        fi
      fi
    done <<< "$(echo "$EXPORTS" | head -100)"
  fi
  finding "INFO" "M1.1" "$UNUSED_EXPORTS unused exports found (grep heuristic)"
fi

# ─── M1.2: Dead Functions ───
metric_header "M1.2" "Dead Functions"

DEAD_FUNCTIONS=0
if $HAS_VULTURE && $STACK_PYTHON; then
  VULTURE_OUT=$(cd "$PROJECT_ROOT" && vulture . --min-confidence 80 2>/dev/null | grep "unused function\|unused method" || true)
  if [[ -n "$VULTURE_OUT" ]]; then
    DEAD_FUNCTIONS=$(echo "$VULTURE_OUT" | wc -l | tr -d ' ')
    while IFS= read -r line; do
      finding "TIER2" "M1.2" "Dead Python function: $line"
    done <<< "$(echo "$VULTURE_OUT" | head -20)"
  fi
fi

# TypeScript dead functions (heuristic)
if $STACK_TYPESCRIPT; then
  TS_FUNCS=$(grep -rn "^function \|^const \w\+ = (" \
    --include='*.ts' --include='*.tsx' \
    --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist --exclude-dir=.next \
    "$PROJECT_ROOT" 2>/dev/null | head -50 || true)
  # Count is approximate — real detection needs knip/LSP
  finding "INFO" "M1.2" "$DEAD_FUNCTIONS dead functions found (vulture); TS functions need knip/LSP for accuracy"
fi

# ─── M1.3: Unreachable Code ───
metric_header "M1.3" "Unreachable Code"

UNREACHABLE=0
# Code after return/throw in same block (heuristic)
AFTER_RETURN=$(grep -rn -A1 "^\s*return\b\|^\s*throw\b" \
  --include='*.ts' --include='*.tsx' --include='*.js' --include='*.py' \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist --exclude-dir=.next \
  "$PROJECT_ROOT" 2>/dev/null | grep -E "^\s+[a-zA-Z]" | grep -v "^\s*[}\])/]" | grep -v "^\s*$" | grep -v "^\s*//" | grep -v "^\s*#" || true)
if [[ -n "$AFTER_RETURN" ]]; then
  UNREACHABLE=$(echo "$AFTER_RETURN" | wc -l | tr -d ' ')
  finding "TIER2" "M1.3" "$UNREACHABLE potential unreachable code blocks after return/throw"
else
  finding "INFO" "M1.3" "No obvious unreachable code detected"
fi

# ─── M1.4: Commented-Out Code ───
metric_header "M1.4" "Commented-Out Code"

COMMENTED_CODE=$(find_commented_code "$PROJECT_ROOT")
if [[ "$COMMENTED_CODE" -gt 0 ]]; then
  finding "TIER1" "M1.4" "$COMMENTED_CODE lines of commented-out code detected"
else
  finding "INFO" "M1.4" "No commented-out code blocks detected"
fi

echo ""
echo -e "  ${BOLD}D1 Raw Totals:${NC} unused_exports=$UNUSED_EXPORTS dead_functions=$DEAD_FUNCTIONS unreachable=$UNREACHABLE commented_code=$COMMENTED_CODE"
