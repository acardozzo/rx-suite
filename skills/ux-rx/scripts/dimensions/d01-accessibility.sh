#!/usr/bin/env bash
# d01-accessibility.sh — Scan accessibility patterns in Next.js + shadcn/ui
source "$(dirname "$0")/../lib/common.sh"

echo "# D01 — ACCESSIBILITY"
echo ""

section "ARIA Attributes"
echo "  role=:         $(src_count_matches 'role="')"
echo "  aria-label:    $(src_count_matches 'aria-label')"
echo "  aria-describedby: $(src_count_matches 'aria-describedby')"
echo "  aria-live:     $(src_count_matches 'aria-live')"
echo "  aria-hidden:   $(src_count_matches 'aria-hidden')"
echo ""

section "Heading Hierarchy"
for level in 1 2 3 4 5 6; do
  count=$(src_count_matches "<[Hh]${level}[\s>]|<h${level} ")
  echo "  h$level: $count"
done
MULTI_H1=$(src_find -exec grep -l '<[Hh]1[\s>]\|<h1 ' {} \; 2>/dev/null | wc -l | tr -d ' ')
echo "  Files with h1: $MULTI_H1 (ideally 1 per page)"
echo ""

section "Image Alt Text"
WITH_ALT=$(src_count_matches '<(Image|img)\s[^>]*alt=')
WITHOUT_ALT=$(src_count_matches '<(Image|img)\s(?![^>]*alt=)')
echo "  Images with alt: $WITH_ALT"
echo "  Images possibly missing alt: $WITHOUT_ALT"
echo ""

section "Form Label Associations"
echo "  <label> tags:  $(src_count_matches '<label[\s>]|<Label[\s>]')"
echo "  htmlFor:       $(src_count_matches 'htmlFor=')"
echo "  aria-labelledby: $(src_count_matches 'aria-labelledby')"
echo ""

section "Focus Management"
echo "  tabIndex:      $(src_count_matches 'tabIndex')"
echo "  autoFocus:     $(src_count_matches 'autoFocus')"
echo "  focus-visible: $(src_count_matches 'focus-visible')"
echo "  focus-within:  $(src_count_matches 'focus-within')"
echo ""

section "Skip Links"
SKIP=$(src_count_files 'skip.*nav|skip.*main|skip.*content')
echo "  Skip link patterns: $SKIP files"
echo ""

section "sr-only (Screen Reader)"
echo "  sr-only usage: $(src_count_matches 'sr-only')"
echo ""
