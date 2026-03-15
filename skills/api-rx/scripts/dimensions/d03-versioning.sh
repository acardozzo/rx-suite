#!/usr/bin/env bash
# d03-versioning.sh — Scan versioning & evolution patterns
source "$(dirname "$0")/../lib/common.sh"

echo "# D03 — VERSIONING & EVOLUTION"
echo ""

section "M3.1 Versioning Strategy"
echo "  URL version prefixes (/v1/, /v2/, etc.):"
for v in v1 v2 v3 v4; do
  count=$(src_count_matches "['\"/]${v}[/'\"]" 2>/dev/null)
  [ "$count" -gt 0 ] && echo "    /$v/: $count occurrences"
done
echo "  Header-based versioning: $(src_count_matches 'api-version|Accept-Version|X-API-Version|API-Version')"
echo "  Version parameter: $(src_count_matches 'version=|apiVersion|api_version')"
echo "  Versioned route groups: $(route_count_files '/v[0-9]/')"
echo ""

section "M3.2 Deprecation Policy"
echo "  Sunset header usage: $(src_count_matches 'Sunset|sunset')"
echo "  @deprecated annotations: $(src_count_matches '@deprecated|@Deprecated|deprecated.*true|isDeprecated')"
echo "  Deprecation warnings in response: $(src_count_matches 'X-Deprecated|deprecation.*warning|Deprecation')"
echo "  Migration guide files:"
src_list 'migration' 5 2>/dev/null | sed 's/^/    /'
eval find '"$ROOT"' -maxdepth 3 -type f \( -iname "'*migration*'" -o -iname "'*upgrade*'" \) "$EXCLUDE_PATHS" 2>/dev/null | head -5 | sed 's/^/    /'
echo ""

section "M3.3 Backward Compatibility"
echo "  Breaking change detection (CI): $(src_count_files 'breaking.*change|BREAKING|backward.*compat|api-diff|openapi-diff')"
echo "  Compatibility tests: $(src_count_files 'compat.*test|backward.*test|regression.*api')"
echo "  Additive-only policy docs:"
eval find '"$ROOT"' -maxdepth 3 -type f -iname "'*api-policy*'" "$EXCLUDE_PATHS" 2>/dev/null | head -3 | sed 's/^/    /'
echo ""

section "M3.4 Changelog & Migration"
echo "  CHANGELOG files:"
eval find '"$ROOT"' -maxdepth 3 -type f \( -iname "'changelog*'" -o -iname "'changes*'" \) "$EXCLUDE_PATHS" 2>/dev/null | head -3 | sed 's/^/    /'
echo "  Release notes: $(eval find '"$ROOT"' -maxdepth 3 -type f -iname "'*release*note*'" "$EXCLUDE_PATHS" 2>/dev/null | wc -l | tr -d ' ')"
echo "  API changelog generation: $(src_count_files 'generateChangelog|changelog.*gen|api.*changelog')"
echo ""
