#!/usr/bin/env bash
# d08-edge-states.sh — Scan edge state handling (loading, error, empty)
source "$(dirname "$0")/../lib/common.sh"

echo "# D08 — EDGE STATES"
echo ""

APP_DIR=$(find "$TARGET_ABS" -type d -name "app" -not -path "*/node_modules/*" 2>/dev/null | head -1)

section "Route-Level Loading States"
if [ -n "$APP_DIR" ]; then
  PAGES=$(find "$APP_DIR" -name "page.tsx" -o -name "page.jsx" 2>/dev/null | wc -l | tr -d ' ')
  LOADING=$(find "$APP_DIR" -name "loading.tsx" -o -name "loading.jsx" 2>/dev/null | wc -l | tr -d ' ')
  echo "  loading.tsx files: $LOADING (of $PAGES route pages)"
  find "$APP_DIR" -name "loading.tsx" -o -name "loading.jsx" 2>/dev/null | head -10 | sed 's/^/    /'
else
  echo "  No app/ directory found"
fi
echo ""

section "Route-Level Error States"
if [ -n "$APP_DIR" ]; then
  ERROR=$(find "$APP_DIR" -name "error.tsx" -o -name "error.jsx" 2>/dev/null | wc -l | tr -d ' ')
  GLOBAL_ERR=$(find "$APP_DIR" -name "global-error.tsx" -o -name "global-error.jsx" 2>/dev/null | wc -l | tr -d ' ')
  echo "  error.tsx files:        $ERROR (of $PAGES route pages)"
  echo "  global-error.tsx files: $GLOBAL_ERR"
  find "$APP_DIR" -name "error.tsx" -o -name "error.jsx" 2>/dev/null | head -10 | sed 's/^/    /'
fi
echo ""

section "Not Found States"
if [ -n "$APP_DIR" ]; then
  NOT_FOUND=$(find "$APP_DIR" -name "not-found.tsx" -o -name "not-found.jsx" 2>/dev/null | wc -l | tr -d ' ')
  echo "  not-found.tsx files: $NOT_FOUND"
fi
echo ""

section "Suspense Boundaries"
echo "  <Suspense>: $(src_count_matches '<Suspense')"
echo "  fallback=:  $(src_count_matches 'fallback=')"
echo ""

section "Error Boundaries"
echo "  ErrorBoundary components: $(src_count_files 'ErrorBoundary|error-boundary')"
echo ""

section "Empty States"
echo "  Empty state patterns: $(src_count_files 'EmptyState\|empty-state\|no.*results\|no.*data\|no.*items')"
echo "  Placeholder text:     $(src_count_matches 'No .* found\|No .* yet\|Nothing here\|Nenhum')"
echo ""

section "Retry / Refresh Patterns"
echo "  retry/refresh: $(src_count_files 'retry\|refetch\|try.*again\|reset\(\)')"
echo ""
