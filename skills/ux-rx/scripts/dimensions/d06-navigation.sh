#!/usr/bin/env bash
# d06-navigation.sh — Scan navigation & routing patterns
source "$(dirname "$0")/../lib/common.sh"

echo "# D06 — NAVIGATION"
echo ""

section "App Router Structure"
APP_DIR=$(find "$TARGET_ABS" -type d -name "app" -not -path "*/node_modules/*" 2>/dev/null | head -1)
if [ -n "$APP_DIR" ]; then
  ROUTES=$(find "$APP_DIR" -name "page.tsx" -o -name "page.jsx" -o -name "page.ts" -o -name "page.js" 2>/dev/null | wc -l | tr -d ' ')
  LAYOUTS=$(find "$APP_DIR" -name "layout.tsx" -o -name "layout.jsx" 2>/dev/null | wc -l | tr -d ' ')
  TEMPLATES=$(find "$APP_DIR" -name "template.tsx" -o -name "template.jsx" 2>/dev/null | wc -l | tr -d ' ')
  DYNAMIC=$(find "$APP_DIR" -type d -name '\[*\]' 2>/dev/null | wc -l | tr -d ' ')
  GROUPS=$(find "$APP_DIR" -type d -name '\(*\)' 2>/dev/null | wc -l | tr -d ' ')
  echo "  Route pages:       $ROUTES"
  echo "  Layout files:      $LAYOUTS"
  echo "  Template files:    $TEMPLATES"
  echo "  Dynamic segments:  $DYNAMIC"
  echo "  Route groups:      $GROUPS"
else
  echo "  No app/ directory found"
fi
echo ""

section "Breadcrumb Usage"
echo "  Breadcrumb components: $(src_count_files 'Breadcrumb|breadcrumb')"
echo ""

section "Command Palette / Search"
echo "  Command (cmdk):  $(src_count_files 'Command|cmdk|CommandDialog')"
echo "  Search input:    $(src_count_files 'search.*input\|SearchInput\|type=.search')"
echo ""

section "Link Usage"
NEXT_LINK=$(src_count_matches "from ['\"]next/link['\"]")
RAW_A=$(src_count_matches '<a\s.*href=')
echo "  next/link imports: $NEXT_LINK"
echo "  Raw <a> tags:      $RAW_A"
echo ""

section "Active State Indicators"
echo "  usePathname:     $(src_count_matches 'usePathname')"
echo "  useSelectedLayoutSegment: $(src_count_matches 'useSelectedLayoutSegment')"
echo "  active/current classes:   $(src_count_matches 'isActive\|isCurrent\|active.*class\|data-active')"
echo ""

section "Not Found Pages"
if [ -n "$APP_DIR" ]; then
  NOT_FOUND=$(find "$APP_DIR" -name "not-found.tsx" -o -name "not-found.jsx" 2>/dev/null | wc -l | tr -d ' ')
  echo "  not-found.tsx files: $NOT_FOUND"
fi
echo ""
