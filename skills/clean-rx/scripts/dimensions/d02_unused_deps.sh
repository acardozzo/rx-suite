#!/usr/bin/env bash
# D2: Unused Dependencies — Phantom deps, dev/prod misplacement, duplicates, deprecated

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

PROJECT_ROOT="${1:-.}"
detect_stacks "$PROJECT_ROOT"
detect_tools

section_header "D2" "Unused Dependencies (12%)"

# ─── M2.1: Phantom Dependencies ───
metric_header "M2.1" "Phantom Dependencies (listed but never imported)"

PHANTOM_DEPS=0

if $HAS_DEPCHECK && $STACK_TYPESCRIPT; then
  DEPCHECK_OUT=$(cd "$PROJECT_ROOT" && npx depcheck --json 2>/dev/null || echo "{}")
  UNUSED_LIST=$(echo "$DEPCHECK_OUT" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    for dep in data.get('dependencies', []):
        print(dep)
except: pass
" 2>/dev/null || true)
  if [[ -n "$UNUSED_LIST" ]]; then
    PHANTOM_DEPS=$(echo "$UNUSED_LIST" | wc -l | tr -d ' ')
    while IFS= read -r dep; do
      finding "TIER1" "M2.1" "Unused dependency: $dep (depcheck verified)"
    done <<< "$UNUSED_LIST"
  fi
elif $STACK_TYPESCRIPT && [[ -f "$PROJECT_ROOT/package.json" ]]; then
  # Fallback: parse deps from package.json, grep in source
  DEPS=$(python3 -c "
import json
with open('$PROJECT_ROOT/package.json') as f:
    p = json.load(f)
    for d in list(p.get('dependencies', {}).keys()):
        print(d)
" 2>/dev/null || true)
  if [[ -n "$DEPS" ]]; then
    while IFS= read -r dep; do
      # Skip common implicit deps
      case "$dep" in @types/*|typescript|eslint*|prettier*|next|react|react-dom) continue ;; esac
      USED=$(grep -rl "from ['\"]$dep\|require(['\"]$dep\|import ['\"]$dep" \
        --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' \
        --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
        "$PROJECT_ROOT" 2>/dev/null | head -1 || true)
      if [[ -z "$USED" ]]; then
        ((PHANTOM_DEPS++)) || true
        finding "TIER2" "M2.1" "Possibly unused: $dep (grep heuristic)"
      fi
    done <<< "$DEPS"
  fi
fi

# Python phantom deps
if $STACK_PYTHON; then
  if [[ -f "$PROJECT_ROOT/requirements.txt" ]]; then
    while IFS= read -r line; do
      dep=$(echo "$line" | sed 's/[><=!].*//' | sed 's/\[.*//' | tr -d ' ' | tr '[:upper:]' '[:lower:]')
      [[ -z "$dep" || "$dep" == \#* ]] && continue
      # Normalize: replace - with _ for Python import
      import_name=$(echo "$dep" | tr '-' '_')
      USED=$(grep -rl "import $import_name\|from $import_name" \
        --include='*.py' --exclude-dir=.venv --exclude-dir=venv --exclude-dir=.git \
        "$PROJECT_ROOT" 2>/dev/null | head -1 || true)
      if [[ -z "$USED" ]]; then
        ((PHANTOM_DEPS++)) || true
        finding "TIER2" "M2.1" "Possibly unused Python dep: $dep"
      fi
    done < "$PROJECT_ROOT/requirements.txt"
  fi
fi

finding "INFO" "M2.1" "$PHANTOM_DEPS phantom dependencies detected"

# ─── M2.2: Dev/Prod Misplacement ───
metric_header "M2.2" "Dev/Prod Misplacement"

MISPLACED=0
if $STACK_TYPESCRIPT && [[ -f "$PROJECT_ROOT/package.json" ]]; then
  DEV_DEPS=$(python3 -c "
import json
with open('$PROJECT_ROOT/package.json') as f:
    p = json.load(f)
    for d in list(p.get('devDependencies', {}).keys()):
        print(d)
" 2>/dev/null || true)
  if [[ -n "$DEV_DEPS" ]]; then
    while IFS= read -r dep; do
      case "$dep" in @types/*|typescript|eslint*|prettier*|jest*|vitest*|playwright*) continue ;; esac
      IN_SRC=$(grep -rl "from ['\"]$dep\|require(['\"]$dep" \
        --include='*.ts' --include='*.tsx' \
        --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
        --exclude-dir='*.test.*' --exclude-dir='*.spec.*' --exclude-dir='__tests__' \
        "$PROJECT_ROOT/src" 2>/dev/null | head -1 || true)
      if [[ -n "$IN_SRC" ]]; then
        ((MISPLACED++)) || true
        finding "TIER2" "M2.2" "devDependency '$dep' imported in production code" "$IN_SRC"
      fi
    done <<< "$DEV_DEPS"
  fi
fi
finding "INFO" "M2.2" "$MISPLACED misplaced dependencies"

# ─── M2.3: Duplicate Dependencies ───
metric_header "M2.3" "Duplicate Dependencies"

DUPLICATES=0
if $STACK_TYPESCRIPT && [[ -f "$PROJECT_ROOT/package.json" ]]; then
  ALL_DEPS=$(python3 -c "
import json
with open('$PROJECT_ROOT/package.json') as f:
    p = json.load(f)
    all_d = list(p.get('dependencies', {}).keys()) + list(p.get('devDependencies', {}).keys())
    for d in all_d:
        print(d)
" 2>/dev/null || true)
  # Known duplicate pairs
  PAIRS=("moment:dayjs:luxon:date-fns" "lodash:underscore:ramda" "axios:got:node-fetch:ky" "express:fastify:koa:hapi" "mocha:jest:vitest:ava" "chalk:kleur:colorette:picocolors")
  for pair in "${PAIRS[@]}"; do
    IFS=':' read -ra LIBS <<< "$pair"
    FOUND=()
    for lib in "${LIBS[@]}"; do
      echo "$ALL_DEPS" | grep -q "^${lib}$" && FOUND+=("$lib") || true
    done
    if [[ ${#FOUND[@]} -gt 1 ]]; then
      ((DUPLICATES++)) || true
      finding "TIER2" "M2.3" "Duplicate libraries: ${FOUND[*]} (same purpose)"
    fi
  done
fi
finding "INFO" "M2.3" "$DUPLICATES duplicate dependency pairs"

# ─── M2.4: Deprecated/Outdated ───
metric_header "M2.4" "Deprecated/Outdated Packages"

DEPRECATED=0
if $STACK_TYPESCRIPT && has_tool npm; then
  DEP_WARN=$(cd "$PROJECT_ROOT" && npm outdated --json 2>/dev/null | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    count = 0
    for pkg, info in data.items():
        current = info.get('current', '0').split('.')[0]
        latest = info.get('latest', '0').split('.')[0]
        if current != latest:
            count += 1
            print(f'{pkg}: {info.get(\"current\",\"?\")} -> {info.get(\"latest\",\"?\")}')
    sys.exit(0)
except: pass
" 2>/dev/null || true)
  if [[ -n "$DEP_WARN" ]]; then
    DEPRECATED=$(echo "$DEP_WARN" | wc -l | tr -d ' ')
    finding "TIER3" "M2.4" "$DEPRECATED packages are a major version behind"
  fi
fi
finding "INFO" "M2.4" "$DEPRECATED deprecated/outdated packages"

echo ""
echo -e "  ${BOLD}D2 Raw Totals:${NC} phantom=$PHANTOM_DEPS misplaced=$MISPLACED duplicates=$DUPLICATES deprecated=$DEPRECATED"
