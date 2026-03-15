#!/usr/bin/env bash
# d02-performance.sh — Scan performance patterns in Next.js + shadcn/ui
source "$(dirname "$0")/../lib/common.sh"

echo "# D02 — PERFORMANCE"
echo ""

section "next/image vs plain <img>"
echo "  next/image imports: $(src_count_matches "from ['\"]next/image['\"]")"
echo "  Plain <img> tags:   $(src_count_matches '<img[\s>]')"
echo ""

section "next/font vs @import"
echo "  next/font imports:  $(src_count_matches "from ['\"]next/font")"
IMPORT_FONTS=$(find "$TARGET_ABS" -type f \( -name "*.css" -o -name "*.scss" \) ! -path "*/node_modules/*" ! -path "*/.next/*" -exec grep -c '@import.*font\|@font-face' {} \; 2>/dev/null | awk '{s+=$1} END {print s+0}')
echo "  CSS @import fonts:  $IMPORT_FONTS"
echo ""

section "Code Splitting"
echo "  next/dynamic:       $(src_count_matches "from ['\"]next/dynamic['\"]")"
echo "  React.lazy:         $(src_count_matches 'React\.lazy\|lazy\(')"
echo "  Dynamic imports:    $(src_count_matches 'import\(.*\)')"
echo ""

section "Client vs Server Components"
USE_CLIENT=$(src_count_files "^['\"]use client['\"]")
TOTAL_TSX=$(src_find -name "*.tsx" | wc -l | tr -d ' ')
SERVER=$((TOTAL_TSX - USE_CLIENT))
echo "  'use client' files: $USE_CLIENT"
echo "  Server components:  ~$SERVER (of $TOTAL_TSX .tsx files)"
PCT=0
[ "$TOTAL_TSX" -gt 0 ] && PCT=$((USE_CLIENT * 100 / TOTAL_TSX))
echo "  Client ratio:       ${PCT}%"
echo ""

section "Heavy Dependencies"
echo "  moment.js:     $(src_count_files "from ['\"]moment['\"]|require\(['\"]moment['\"]")"
echo "  lodash (full): $(src_count_files "from ['\"]lodash['\"]|require\(['\"]lodash['\"]")"
echo "  lodash (tree): $(src_count_files "from ['\"]lodash/")"
echo ""

section "next/script"
echo "  next/script:   $(src_count_matches "from ['\"]next/script['\"]")"
echo ""

section "Memoization"
echo "  useMemo:       $(src_count_matches 'useMemo')"
echo "  useCallback:   $(src_count_matches 'useCallback')"
echo "  React.memo:    $(src_count_matches 'React\.memo\|memo\(')"
echo ""
