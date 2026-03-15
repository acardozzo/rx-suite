#!/usr/bin/env bash
# D9: User Experience Infrastructure
# M9.1 Errors | M9.2 Loading | M9.3 Responsive | M9.4 Onboarding
source "$(dirname "$0")/../lib/common.sh"

echo "## D9: USER EXPERIENCE INFRASTRUCTURE"
echo ""

# M9.1: Error UX
section "M9.1: Error States"
e=0
c=$(find "$TARGET_ABS" -type f -name "error.tsx" -o -name "error.jsx" -o -name "error.js" 2>/dev/null | wc -l | tr -d ' ')
[ "$c" -gt 0 ] && echo "  error.tsx: $c files" && ((e++))
c=$(find "$TARGET_ABS" -type f -name "not-found.tsx" -o -name "not-found.jsx" -o -name "404.*" 2>/dev/null | wc -l | tr -d ' ')
[ "$c" -gt 0 ] && echo "  not-found: $c files" && ((e++))
c=$(src_count "500\|InternalServerError\|ServerError\|global-error")
[ "$c" -gt 0 ] && echo "  500-page: $c files" && ((e++))
c=$(src_count "EmptyState\|empty.*state\|no-data\|NoResults")
[ "$c" -gt 0 ] && echo "  empty-states: $c files" && ((e++))
echo "  SCORE: $(component_score "ErrorUX" "$e" 1 2 3 4 | head -1)"
echo ""

# M9.2: Loading States
section "M9.2: Loading & Feedback"
e=0
c=$(find "$TARGET_ABS" -type f -name "loading.tsx" -o -name "loading.jsx" 2>/dev/null | wc -l | tr -d ' ')
[ "$c" -gt 0 ] && echo "  loading.tsx: $c files" && ((e++))
c=$(src_count "Skeleton\|skeleton")
[ "$c" -gt 0 ] && echo "  skeletons: $c files" && ((e++))
c=$(src_count "Sonner\|toast\|useToast\|react-hot-toast\|notification")
[ "$c" -gt 0 ] && echo "  toasts: $c files" && ((e++))
c=$(src_count "Progress\|progress.*bar\|NProgress\|nprogress\|Spinner")
[ "$c" -gt 0 ] && echo "  progress/spinners: $c files" && ((e++))
for lib in sonner react-hot-toast react-toastify; do
  has_dep "$lib" && echo "  dep: $lib" && ((e++))
done
echo "  SCORE: $(component_score "Loading" "$e" 1 2 4 6 | head -1)"
echo ""

# M9.3: Responsive & Accessibility
section "M9.3: Responsive & A11y"
e=0
c=$(src_count "sm:\|md:\|lg:\|xl:\|@media.*min-width\|breakpoint\|useMediaQuery")
[ "$c" -gt 0 ] && echo "  responsive: $c files" && ((e++))
c=$(src_count "aria-\|role=\|sr-only\|screenReader\|alt=")
[ "$c" -gt 0 ] && echo "  a11y-attrs: $c files" && ((e++))
c=$(src_count "focus-visible\|focus-within\|:focus\|tabIndex\|onKeyDown")
[ "$c" -gt 0 ] && echo "  focus-mgmt: $c files" && ((e++))
has_dep "@radix-ui" || has_dep "@headlessui" && echo "  a11y-primitives" && ((e++))
echo "  SCORE: $(component_score "Responsive" "$e" 1 2 3 4 | head -1)"
echo ""

# M9.4: Onboarding
section "M9.4: Onboarding"
e=0
has_route "onboarding\|welcome\|setup\|getting-started" && echo "  route: onboarding" && ((e++))
c=$(src_count "Onboarding\|onboarding\|WelcomeWizard\|SetupWizard\|Stepper")
[ "$c" -gt 0 ] && echo "  onboarding-components: $c files" && ((e++))
for lib in react-joyride intro.js driver.js @shepherd; do
  has_dep "$lib" && echo "  dep: $lib" && ((e++))
done
c=$(src_count "first.*run\|isNew.*User\|hasCompleted.*Setup\|onboarded")
[ "$c" -gt 0 ] && echo "  first-run-detection: $c files" && ((e++))
echo "  SCORE: $(component_score "Onboarding" "$e" 1 2 3 4 | head -1)"
echo ""
