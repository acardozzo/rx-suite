#!/usr/bin/env bash
# D10: Growth & Analytics
# M10.1 Analytics | M10.2 Flags | M10.3 Export | M10.4 Admin
source "$(dirname "$0")/../lib/common.sh"

echo "## D10: GROWTH & ANALYTICS"
echo ""

# M10.1: Analytics
section "M10.1: Product Analytics"
e=0
for lib in posthog-js @posthog/react mixpanel-browser amplitude-js @google-analytics @vercel/analytics plausible-tracker; do
  has_dep "$lib" && echo "  dep: $lib" && ((e++))
done
c=$(src_count "track\(|capture\(|analytics\.\|posthog\.\|mixpanel\.\|gtag\(")
[ "$c" -gt 0 ] && echo "  event-tracking: $c files" && ((e++))
has_env "POSTHOG\|MIXPANEL\|AMPLITUDE\|GA_\|ANALYTICS\|PLAUSIBLE" && echo "  analytics-env" && ((e++))
c=$(src_count "identify\(\|setUser\|setUserId\|alias\(")
[ "$c" -gt 0 ] && echo "  user-identification: $c files" && ((e++))
echo "  SCORE: $(component_score "Analytics" "$e" 1 2 4 6 | head -1)"
echo ""

# M10.2: Feature Flags
section "M10.2: Feature Flags"
e=0
for lib in launchdarkly @growthbook/growthbook-react @unleash flagsmith statsig-react @vercel/flags; do
  has_dep "$lib" && echo "  dep: $lib" && ((e++))
done
c=$(src_count "featureFlag\|useFeature\|isFeatureEnabled\|getFeatureFlag\|useFlag")
[ "$c" -gt 0 ] && echo "  flag-usage: $c files" && ((e++))
has_env "LAUNCHDARKLY\|GROWTHBOOK\|UNLEASH\|FLAGSMITH\|STATSIG" && echo "  flags-env" && ((e++))
c=$(src_count "flag.*config\|feature.*toggle\|experiment\|variant")
[ "$c" -gt 0 ] && echo "  flag-config: $c files" && ((e++))
echo "  SCORE: $(component_score "Flags" "$e" 1 2 3 4 | head -1)"
echo ""

# M10.3: Data Export & Import
section "M10.3: Data Export & Import"
e=0
c=$(src_count "csv.*export\|exportCsv\|toCSV\|createCsv\|json2csv\|papaparse")
[ "$c" -gt 0 ] && echo "  csv-export: $c files" && ((e++))
has_route "export\|download" && echo "  route: export" && ((e++))
c=$(src_count "gdpr.*export\|data.*portability\|data.*export\|downloadMyData")
[ "$c" -gt 0 ] && echo "  gdpr-export: $c files" && ((e++))
c=$(src_count "import.*csv\|upload.*csv\|bulk.*import\|parseCSV")
[ "$c" -gt 0 ] && echo "  import: $c files" && ((e++))
for lib in papaparse csv-parse xlsx exceljs; do
  has_dep "$lib" && echo "  dep: $lib" && ((e++))
done
echo "  SCORE: $(component_score "Export" "$e" 1 2 3 5 | head -1)"
echo ""

# M10.4: Admin Panel
section "M10.4: Admin Panel"
e=0
has_route "admin" && echo "  route: /admin" && ((e++))
c=$(find "$TARGET_ABS" -type f -path "*/admin/*" 2>/dev/null | wc -l | tr -d ' ')
[ "$c" -gt 0 ] && echo "  admin-files: $c" && ((e++))
c=$(src_count "AdminLayout\|admin.*layout\|admin.*guard\|isAdmin\|requireAdmin")
[ "$c" -gt 0 ] && echo "  admin-layout/guard: $c files" && ((e++))
c=$(src_count "AdminDashboard\|admin.*dashboard\|admin.*stats\|AdminOverview")
[ "$c" -gt 0 ] && echo "  admin-dashboard: $c files" && ((e++))
for lib in react-admin adminjs @adminjs tremor; do
  has_dep "$lib" && echo "  dep: $lib" && ((e++))
done
echo "  SCORE: $(component_score "Admin" "$e" 1 2 3 5 | head -1)"
echo ""
