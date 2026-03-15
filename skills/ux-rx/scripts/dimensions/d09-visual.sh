#!/usr/bin/env bash
# d09-visual.sh — Scan visual consistency & design tokens
source "$(dirname "$0")/../lib/common.sh"

echo "# D09 — VISUAL CONSISTENCY"
echo ""

section "Tailwind Theme Extensions"
TW_CFG=$(find "$ROOT" -maxdepth 2 -name "tailwind.config.*" ! -path "*/node_modules/*" 2>/dev/null | head -1)
if [ -n "$TW_CFG" ]; then
  echo "  Config: $TW_CFG"
  echo "  extend.colors lines:    $(grep -c 'color' "$TW_CFG" 2>/dev/null || echo 0)"
  echo "  extend.spacing lines:   $(grep -c 'spacing' "$TW_CFG" 2>/dev/null || echo 0)"
  echo "  extend.fontSize lines:  $(grep -c 'fontSize' "$TW_CFG" 2>/dev/null || echo 0)"
  echo "  extend.borderRadius:    $(grep -c 'borderRadius' "$TW_CFG" 2>/dev/null || echo 0)"
fi
echo ""

section "CSS Variables"
CSS_FILES=$(find "$TARGET_ABS" -type f \( -name "*.css" -o -name "*.scss" \) ! -path "*/node_modules/*" ! -path "*/.next/*" 2>/dev/null)
HSL_VARS=0
TOTAL_VARS=0
if [ -n "$CSS_FILES" ]; then
  TOTAL_VARS=$(echo "$CSS_FILES" | xargs grep -c '\-\-' 2>/dev/null | awk -F: '{s+=$NF} END {print s+0}')
  HSL_VARS=$(echo "$CSS_FILES" | xargs grep -c 'hsl' 2>/dev/null | awk -F: '{s+=$NF} END {print s+0}')
fi
echo "  CSS custom properties: $TOTAL_VARS"
echo "  HSL variable values:   $HSL_VARS"
echo ""

section "Arbitrary Values (Inconsistency Signals)"
ARB_COLORS=$(src_count_matches '\[#[0-9a-fA-F]')
ARB_SIZES=$(src_count_matches '\[[0-9]+px\]|\[[0-9]+rem\]')
ARB_SPACING=$(src_count_matches '(p|m|gap|space)-\[[0-9]')
echo "  Arbitrary colors ([#hex]):    $ARB_COLORS"
echo "  Arbitrary sizes ([Npx/rem]):  $ARB_SIZES"
echo "  Arbitrary spacing:            $ARB_SPACING"
TOTAL_ARB=$((ARB_COLORS + ARB_SIZES + ARB_SPACING))
echo "  Total arbitrary values:       $TOTAL_ARB"
echo ""

section "Dark Mode"
DARK_CLASSES=$(src_count_matches '\bdark:')
echo "  dark: class usage:    $DARK_CLASSES"
TW_DARK=""
[ -n "$TW_CFG" ] && TW_DARK=$(grep -o 'darkMode.*' "$TW_CFG" 2>/dev/null | head -1)
echo "  darkMode config:      ${TW_DARK:-not found}"
echo "  theme toggle:         $(src_count_files 'useTheme\|ThemeProvider\|next-themes')"
echo ""

section "Spacing Consistency"
echo "  p-[N] arbitrary:  $(src_count_matches 'p-\[[0-9]')"
echo "  m-[N] arbitrary:  $(src_count_matches 'm-\[[0-9]')"
echo "  gap-[N] arbitrary: $(src_count_matches 'gap-\[[0-9]')"
echo ""
