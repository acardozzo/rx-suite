#!/usr/bin/env bash
# d03-components.sh — shadcn/ui component coverage & design tokens
source "$(dirname "$0")/../lib/common.sh"

echo "# D03 — COMPONENTS"
echo ""

# Full shadcn/ui registry catalog
SHADCN_CATALOG=(accordion alert alert-dialog aspect-ratio avatar badge breadcrumb button calendar card carousel chart checkbox collapsible command context-menu dialog drawer dropdown-menu form hover-card input input-otp label menubar navigation-menu pagination popover progress radio-group resizable scroll-area select separator sheet sidebar skeleton slider sonner switch table tabs textarea toggle toggle-group tooltip)

# Find components/ui directory
UI_DIR=$(find "$TARGET_ABS" -type d -name "ui" -path "*/components/ui" 2>/dev/null | head -1)
[ -z "$UI_DIR" ] && UI_DIR=$(find "$ROOT" -type d -name "ui" -path "*/components/ui" ! -path "*/node_modules/*" 2>/dev/null | head -1)

section "shadcn/ui Component Coverage"
if [ -n "$UI_DIR" ]; then
  INSTALLED=()
  NOT_INSTALLED=()
  for comp in "${SHADCN_CATALOG[@]}"; do
    if [ -f "$UI_DIR/$comp.tsx" ] || [ -f "$UI_DIR/$comp.ts" ]; then
      INSTALLED+=("$comp")
    else
      NOT_INSTALLED+=("$comp")
    fi
  done
  TOTAL=${#SHADCN_CATALOG[@]}
  INST=${#INSTALLED[@]}
  RATE=$((INST * 100 / TOTAL))
  echo "  Installed: $INST / $TOTAL (${RATE}% adoption)"
  echo "  Installed: ${INSTALLED[*]}"
  echo "  Not installed: ${NOT_INSTALLED[*]}"
else
  echo "  No components/ui/ directory found"
fi
echo ""

section "Custom Component Duplication Check"
echo "  Custom Modal (Dialog exists?):    $(src_count_files 'Modal|modal' )"
echo "  Custom Spinner (Skeleton exists?): $(src_count_files 'Spinner|spinner')"
echo "  Custom Tooltip (Tooltip exists?):  $(src_count_files 'CustomTooltip|custom-tooltip')"
echo "  Custom Select (Select exists?):    $(src_count_files 'CustomSelect|custom-select')"
echo ""

section "Design Tokens (tailwind.config)"
TW_CFG=$(find "$ROOT" -maxdepth 2 -name "tailwind.config.*" ! -path "*/node_modules/*" 2>/dev/null | head -1)
if [ -n "$TW_CFG" ]; then
  echo "  Config: $TW_CFG"
  CUSTOM_COLORS=$(grep -c 'colors\|color' "$TW_CFG" 2>/dev/null || echo 0)
  CUSTOM_SPACING=$(grep -c 'spacing' "$TW_CFG" 2>/dev/null || echo 0)
  CUSTOM_FONTS=$(grep -c 'fontFamily\|fontSize' "$TW_CFG" 2>/dev/null || echo 0)
  echo "  Color definitions:   $CUSTOM_COLORS lines"
  echo "  Spacing definitions: $CUSTOM_SPACING lines"
  echo "  Font definitions:    $CUSTOM_FONTS lines"
else
  echo "  No tailwind.config found"
fi
echo ""

section "CSS Variables"
CSS_VARS=$(find "$TARGET_ABS" -type f \( -name "*.css" -o -name "*.scss" \) ! -path "*/node_modules/*" ! -path "*/.next/*" -exec grep -c '\-\-' {} \; 2>/dev/null | awk '{s+=$1} END {print s+0}')
echo "  CSS custom properties: $CSS_VARS"
echo ""
