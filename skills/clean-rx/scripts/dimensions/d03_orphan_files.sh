#!/usr/bin/env bash
# D3: Orphan Files & Assets — Unreferenced source files, orphan tests, unused assets, stale artifacts

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

PROJECT_ROOT="${1:-.}"
detect_stacks "$PROJECT_ROOT"
detect_tools

section_header "D3" "Orphan Files & Assets (10%)"

# ─── M3.1: Unreferenced Source Files ───
metric_header "M3.1" "Unreferenced Source Files"

ORPHAN_FILES=0
if $HAS_MADGE && $STACK_TYPESCRIPT; then
  ORPHANS=$(cd "$PROJECT_ROOT" && npx madge --orphans --extensions ts,tsx src/ 2>/dev/null || true)
  if [[ -n "$ORPHANS" ]]; then
    ORPHAN_FILES=$(echo "$ORPHANS" | wc -l | tr -d ' ')
    while IFS= read -r f; do
      finding "TIER2" "M3.1" "Orphan file (madge): $f"
    done <<< "$(echo "$ORPHANS" | head -20)"
  fi
else
  # Fallback: find .ts/.tsx files not imported anywhere
  if $STACK_TYPESCRIPT; then
    TS_FILES=$(find "$PROJECT_ROOT/src" -name "*.ts" -o -name "*.tsx" 2>/dev/null \
      | grep -v node_modules | grep -v ".test." | grep -v ".spec." | grep -v ".d.ts" \
      | grep -v "__tests__" || true)
    if [[ -n "$TS_FILES" ]]; then
      while IFS= read -r f; do
        basename_no_ext=$(basename "$f" | sed 's/\.\(ts\|tsx\)$//')
        [[ "$basename_no_ext" == "index" || "$basename_no_ext" == "page" || "$basename_no_ext" == "layout" || "$basename_no_ext" == "route" ]] && continue
        IMPORTED=$(grep -rl "$basename_no_ext" --include='*.ts' --include='*.tsx' \
          --exclude-dir=node_modules --exclude-dir=.git \
          "$PROJECT_ROOT/src" 2>/dev/null | grep -v "$f" | head -1 || true)
        if [[ -z "$IMPORTED" ]]; then
          ((ORPHAN_FILES++)) || true
          finding "TIER2" "M3.1" "Possibly orphan: $f"
        fi
      done <<< "$(echo "$TS_FILES" | head -100)"
    fi
  fi
fi
finding "INFO" "M3.1" "$ORPHAN_FILES unreferenced source files"

# ─── M3.2: Orphan Test Files ───
metric_header "M3.2" "Orphan Test Files"

ORPHAN_TESTS=0
TEST_FILES=$(find "$PROJECT_ROOT" -name "*.test.ts" -o -name "*.test.tsx" -o -name "*.spec.ts" -o -name "*.spec.tsx" -o -name "test_*.py" -o -name "*_test.py" 2>/dev/null \
  | grep -v node_modules | grep -v .git || true)
if [[ -n "$TEST_FILES" ]]; then
  while IFS= read -r tf; do
    # Derive source file name from test file
    src_name=$(basename "$tf" | sed 's/\.test\.\|\.spec\././;s/^test_//;s/_test\./\./')
    src_base=$(echo "$src_name" | sed 's/\.\(ts\|tsx\|py\)$//')
    # Check if source file exists somewhere
    SRC_EXISTS=$(find "$PROJECT_ROOT" -name "${src_base}.ts" -o -name "${src_base}.tsx" -o -name "${src_base}.py" 2>/dev/null \
      | grep -v node_modules | grep -v .git | grep -v ".test." | grep -v ".spec." | head -1 || true)
    if [[ -z "$SRC_EXISTS" ]]; then
      ((ORPHAN_TESTS++)) || true
      finding "TIER1" "M3.2" "Orphan test — source module not found" "$tf"
    fi
  done <<< "$(echo "$TEST_FILES" | head -50)"
fi
finding "INFO" "M3.2" "$ORPHAN_TESTS orphan test files"

# ─── M3.3: Unused Assets ───
metric_header "M3.3" "Unused Assets"

UNUSED_ASSETS=0
ASSET_DIRS=("$PROJECT_ROOT/public" "$PROJECT_ROOT/static" "$PROJECT_ROOT/assets" "$PROJECT_ROOT/src/assets")
for adir in "${ASSET_DIRS[@]}"; do
  [[ -d "$adir" ]] || continue
  ASSETS=$(find "$adir" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.gif" \
    -o -name "*.svg" -o -name "*.ico" -o -name "*.webp" -o -name "*.woff" -o -name "*.woff2" \
    -o -name "*.ttf" -o -name "*.mp4" -o -name "*.mp3" \) 2>/dev/null || true)
  if [[ -n "$ASSETS" ]]; then
    while IFS= read -r asset; do
      asset_name=$(basename "$asset")
      REFERENCED=$(grep -rl "$asset_name" \
        --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' \
        --include='*.css' --include='*.scss' --include='*.html' --include='*.md' \
        --exclude-dir=node_modules --exclude-dir=.git \
        "$PROJECT_ROOT" 2>/dev/null | head -1 || true)
      if [[ -z "$REFERENCED" ]]; then
        ((UNUSED_ASSETS++)) || true
        finding "TIER2" "M3.3" "Unused asset: $asset_name" "$asset"
      fi
    done <<< "$(echo "$ASSETS" | head -50)"
  fi
done
finding "INFO" "M3.3" "$UNUSED_ASSETS unused assets"

# ─── M3.4: Stale Generated Files ───
metric_header "M3.4" "Stale Generated Files"

STALE_GENERATED=0
# Check for common generated/build files tracked in git
TRACKED=$(cd "$PROJECT_ROOT" && git ls-files 2>/dev/null || true)
if [[ -n "$TRACKED" ]]; then
  GENERATED_PATTERNS=("dist/" "build/" ".next/" "__pycache__/" "*.pyc" ".turbo/" "coverage/" ".nyc_output/")
  for pattern in "${GENERATED_PATTERNS[@]}"; do
    MATCHES=$(echo "$TRACKED" | grep "$pattern" | head -5 || true)
    if [[ -n "$MATCHES" ]]; then
      COUNT=$(echo "$MATCHES" | wc -l | tr -d ' ')
      ((STALE_GENERATED += COUNT)) || true
      finding "TIER1" "M3.4" "$COUNT generated files tracked in git matching: $pattern"
    fi
  done
fi
finding "INFO" "M3.4" "$STALE_GENERATED stale generated files in git"

echo ""
echo -e "  ${BOLD}D3 Raw Totals:${NC} orphan_files=$ORPHAN_FILES orphan_tests=$ORPHAN_TESTS unused_assets=$UNUSED_ASSETS stale_generated=$STALE_GENERATED"
