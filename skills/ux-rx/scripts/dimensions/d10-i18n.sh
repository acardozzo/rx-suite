#!/usr/bin/env bash
# d10-i18n.sh — Scan internationalization & localization patterns
source "$(dirname "$0")/../lib/common.sh"

echo "# D10 — INTERNATIONALIZATION"
echo ""

section "i18n Library Detection"
echo "  next-intl:     $(src_count_files "from ['\"]next-intl")"
echo "  next-i18next:  $(src_count_files "from ['\"]next-i18next")"
echo "  react-intl:    $(src_count_files "from ['\"]react-intl")"
echo "  i18next:       $(src_count_files "from ['\"]i18next")"
echo "  react-i18next: $(src_count_files "from ['\"]react-i18next")"
PKG=$(find "$ROOT" -maxdepth 2 -name "package.json" ! -path "*/node_modules/*" 2>/dev/null | head -1)
if [ -n "$PKG" ]; then
  I18N_DEP=$(grep -oE '"(next-intl|next-i18next|react-intl|i18next|react-i18next)"' "$PKG" 2>/dev/null | head -3)
  [ -n "$I18N_DEP" ] && echo "  package.json deps: $I18N_DEP"
fi
echo ""

section "Translation Function Usage"
echo "  t() calls:         $(src_count_matches '\bt\(['\''"]')"
echo "  useTranslation:    $(src_count_matches 'useTranslation')"
echo "  useTranslations:   $(src_count_matches 'useTranslations')"
echo "  formatMessage:     $(src_count_matches 'formatMessage')"
echo ""

section "Locale Files"
for dir in messages locales translations i18n lang; do
  FOUND=$(find "$ROOT" -type d -name "$dir" ! -path "*/node_modules/*" 2>/dev/null | head -1)
  if [ -n "$FOUND" ]; then
    COUNT=$(find "$FOUND" -type f 2>/dev/null | wc -l | tr -d ' ')
    echo "  $dir/ directory: $COUNT files"
    find "$FOUND" -type f 2>/dev/null | head -5 | sed 's/^/    /'
  fi
done
echo ""

section "Intl API Usage"
echo "  Intl.NumberFormat:  $(src_count_matches 'Intl\.NumberFormat')"
echo "  Intl.DateTimeFormat: $(src_count_matches 'Intl\.DateTimeFormat')"
echo "  Intl.RelativeTimeFormat: $(src_count_matches 'Intl\.RelativeTimeFormat')"
echo ""

section "RTL & Logical Properties"
echo "  dir=rtl:       $(src_count_matches 'dir=.rtl')"
echo "  Logical CSS (ms-/me-/ps-/pe-): $(src_count_matches '\b(ms|me|ps|pe)-')"
echo ""

section "Hardcoded Strings (Sample)"
HARDCODED=$(src_find -name "*.tsx" -exec grep -l '>[A-Z][a-z].*</' {} \; 2>/dev/null | wc -l | tr -d ' ')
echo "  .tsx files with visible hardcoded text: ~$HARDCODED"
echo ""
