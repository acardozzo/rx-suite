#!/usr/bin/env bash
# d03-code-docs.sh — D3: Code Documentation
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

ROOT="$1"

header "D3: Code Documentation (10%)"

# Determine source directories
src_dirs=()
for d in src lib app packages components utils helpers services; do
  if [[ -d "$ROOT/$d" ]]; then
    src_dirs+=("$ROOT/$d")
  fi
done

if [[ ${#src_dirs[@]} -eq 0 ]]; then
  src_dirs=("$ROOT")
fi

# ── M3.1: Public API Documentation ────────────────────────────────────────
subheader "M3.1: Public API Documentation (JSDoc/TSDoc on exports)"

total_exports=0
documented_exports=0

for sd in "${src_dirs[@]}"; do
  # Count exported functions/classes/const
  exports=$(grep -rl 'export ' "$sd" --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" 2>/dev/null | head -50)
  if [[ -n "$exports" ]]; then
    while IFS= read -r f; do
      file_exports=$(grep -c 'export ' "$f" 2>/dev/null || echo "0")
      total_exports=$((total_exports + file_exports))
      # Check for JSDoc preceding exports
      file_docs=$(grep -cB1 'export ' "$f" 2>/dev/null | grep -c '\*/' 2>/dev/null || echo "0")
      # Also count /** blocks
      jsdoc_blocks=$(grep -c '/\*\*' "$f" 2>/dev/null || echo "0")
      documented_exports=$((documented_exports + jsdoc_blocks))
    done <<< "$exports"
  fi
done

if [[ "$total_exports" -gt 0 ]]; then
  pct=$(percentage "$documented_exports" "$total_exports")
  info "Export statements sampled: $total_exports"
  info "JSDoc/TSDoc blocks found: $documented_exports"
  info "Approximate doc coverage: ${pct}%"
else
  warn "No export statements found to analyze"
fi

# ── M3.2: Complex Logic Comments ──────────────────────────────────────────
subheader "M3.2: Complex Logic Comments"

# Look for explanatory comments (not trivial)
explanatory_comments=0
for sd in "${src_dirs[@]}"; do
  # Comments that explain WHY (longer comments, TODO, HACK, NOTE, FIXME, EXPLAIN)
  explanatory_comments=$((explanatory_comments + $(grep -rcE '// (TODO|HACK|NOTE|FIXME|EXPLAIN|IMPORTANT|WARNING|REASON|because|workaround|tricky|complex)' "$sd" --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" 2>/dev/null | tail -1 | awk -F: '{sum+=$NF} END {print sum+0}')))
done
info "Explanatory comments (TODO/NOTE/HACK/etc): $explanatory_comments"

# Check for regex or bitwise without comments
complex_no_comment=0
for sd in "${src_dirs[@]}"; do
  # Regex patterns without preceding comment
  complex_no_comment=$((complex_no_comment + $(grep -rcE '(new RegExp|/[^/]{15,}/[gim]*|<<|>>|>>>|\^=|\|=|&=)' "$sd" --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" 2>/dev/null | tail -1 | awk -F: '{sum+=$NF} END {print sum+0}')))
done
if [[ "$complex_no_comment" -gt 0 ]]; then
  warn "Complex patterns (regex/bitwise) found: $complex_no_comment (check if commented)"
fi

# ── M3.3: Type Documentation ──────────────────────────────────────────────
subheader "M3.3: Type Documentation"

total_types=0
documented_types=0
for sd in "${src_dirs[@]}"; do
  # Count interface/type declarations
  types=$(grep -rcE '(^|\s)(interface|type)\s+[A-Z]' "$sd" --include="*.ts" --include="*.tsx" 2>/dev/null | tail -1 | awk -F: '{sum+=$NF} END {print sum+0}')
  total_types=$((total_types + types))
done

# Check how many have JSDoc above them
for sd in "${src_dirs[@]}"; do
  # Rough: count files that have both /** and interface/type
  files_with_types=$(grep -rlE '(interface|type)\s+[A-Z]' "$sd" --include="*.ts" --include="*.tsx" 2>/dev/null | head -30)
  if [[ -n "$files_with_types" ]]; then
    while IFS= read -r f; do
      has_doc=$(grep -c '/\*\*' "$f" 2>/dev/null || echo "0")
      has_type=$(grep -cE '(interface|type)\s+[A-Z]' "$f" 2>/dev/null || echo "0")
      if [[ "$has_doc" -gt 0 ]] && [[ "$has_type" -gt 0 ]]; then
        documented_types=$((documented_types + has_doc))
      fi
    done <<< "$files_with_types"
  fi
done

info "Type/interface declarations found: $total_types"
if [[ "$total_types" -gt 0 ]]; then
  pct=$(percentage "$documented_types" "$total_types")
  info "Approximate documented types: ${pct}%"
fi

# ── M3.4: Example Usage ───────────────────────────────────────────────────
subheader "M3.4: Example Usage in Doc Comments"

example_count=0
for sd in "${src_dirs[@]}"; do
  example_count=$((example_count + $(grep -rcE '@example|@usage|@sample|```' "$sd" --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" 2>/dev/null | tail -1 | awk -F: '{sum+=$NF} END {print sum+0}')))
done

if [[ "$example_count" -gt 0 ]]; then
  found "@example / code examples in doc comments: $example_count"
else
  missing "No @example tags found in source files"
fi

# Check for examples directory
if [[ -d "$ROOT/examples" ]] || [[ -d "$ROOT/example" ]]; then
  found "examples/ directory exists"
  example_files=$(find "$ROOT/examples" "$ROOT/example" -type f 2>/dev/null | wc -l | tr -d ' ')
  info "Example files: $example_files"
fi

echo ""
