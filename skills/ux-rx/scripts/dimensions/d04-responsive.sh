#!/usr/bin/env bash
# d04-responsive.sh — Scan responsive design patterns
source "$(dirname "$0")/../lib/common.sh"

echo "# D04 — RESPONSIVE DESIGN"
echo ""

section "Breakpoint Usage Distribution"
SM=$(src_count_matches '\bsm:')
MD=$(src_count_matches '\bmd:')
LG=$(src_count_matches '\blg:')
XL=$(src_count_matches '\bxl:')
XXL=$(src_count_matches '\b2xl:')
echo "  sm:  $SM"
echo "  md:  $MD"
echo "  lg:  $LG"
echo "  xl:  $XL"
echo "  2xl: $XXL"
TOTAL_BP=$((SM + MD + LG + XL + XXL))
echo "  Total responsive prefixes: $TOTAL_BP"
echo ""

section "Mobile-First Analysis"
if [ "$TOTAL_BP" -gt 0 ]; then
  echo "  If base classes are mobile, breakpoints scale UP (good mobile-first)"
  FILES_WITH_BP=$(src_count_files '\b(sm|md|lg|xl|2xl):')
  TOTAL_SRC=$(src_find | wc -l | tr -d ' ')
  echo "  Files using breakpoints: $FILES_WITH_BP / $TOTAL_SRC"
fi
echo ""

section "Touch Target Sizes"
SMALL_INTERACTIVE=$(src_count_matches '(w-[456]|h-[456]|p-[01]).*(onClick|button|Button|<a[\s>])')
echo "  Potentially small interactive elements: $SMALL_INTERACTIVE"
echo "  icon-only buttons (size=.icon.): $(src_count_matches 'size.*icon\|size=.icon')"
echo ""

section "Fixed Pixel Values"
FIXED_PX=$(src_count_matches 'text-\[[0-9]+px\]')
FIXED_WIDTHS=$(src_count_matches 'w-\[[0-9]+px\]|h-\[[0-9]+px\]')
echo "  Fixed text sizes (text-[Npx]): $FIXED_PX"
echo "  Fixed w/h pixels:              $FIXED_WIDTHS"
echo ""

section "Container Queries"
echo "  @container usage: $(src_count_matches '@container')"
echo ""

section "Responsive Utilities"
echo "  hidden/block combos: $(src_count_matches 'hidden.*md:block\|md:hidden\|lg:hidden')"
echo "  flex direction swaps: $(src_count_matches 'flex-col.*md:flex-row\|md:flex-row\|lg:flex-row')"
echo ""
