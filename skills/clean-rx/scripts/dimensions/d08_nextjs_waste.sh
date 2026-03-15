#!/usr/bin/env bash
# D8: Next.js / Frontend Waste — Unused pages, dead components, dead CSS, unused API routes
# Score as N/A (100) if project doesn't use Next.js

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

PROJECT_ROOT="${1:-.}"
detect_stacks "$PROJECT_ROOT"

if ! $STACK_NEXTJS; then
  echo -e "  ${YELLOW}D8: Next.js not detected — scoring as N/A (100)${NC}"
  exit 0
fi

section_header "D8" "Next.js / Frontend Waste (8%)"

# Detect app directory
APP_DIR=""
[[ -d "$PROJECT_ROOT/app" ]] && APP_DIR="$PROJECT_ROOT/app"
[[ -d "$PROJECT_ROOT/src/app" ]] && APP_DIR="$PROJECT_ROOT/src/app"

PAGES_DIR=""
[[ -d "$PROJECT_ROOT/pages" ]] && PAGES_DIR="$PROJECT_ROOT/pages"
[[ -d "$PROJECT_ROOT/src/pages" ]] && PAGES_DIR="$PROJECT_ROOT/src/pages"

# ─── M8.1: Unused Pages/Routes ───
metric_header "M8.1" "Unused Pages/Routes"

UNUSED_ROUTES=0
if [[ -n "$APP_DIR" ]]; then
  # Find all page.tsx files and derive their routes
  PAGE_FILES=$(find "$APP_DIR" -name "page.tsx" -o -name "page.ts" -o -name "page.jsx" 2>/dev/null || true)
  if [[ -n "$PAGE_FILES" ]]; then
    while IFS= read -r pf; do
      # Derive route from file path
      route=$(echo "$pf" | sed "s|$APP_DIR||;s|/page\.\(tsx\|ts\|jsx\)$||;s|^$|/|")
      # Skip root and dynamic routes (harder to verify)
      [[ "$route" == "/" || "$route" == *"["* ]] && continue
      # Check if any Link or router.push points to this route
      LINKED=$(grep -rl "href=['\"]${route}['\"\?]\|push(['\"]${route}['\"])\|replace(['\"]${route}['\"])" \
        --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' \
        --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist --exclude-dir=.next \
        "$PROJECT_ROOT" 2>/dev/null | head -1 || true)
      if [[ -z "$LINKED" ]]; then
        ((UNUSED_ROUTES++)) || true
        finding "TIER2" "M8.1" "Route '$route' has no Link/push references" "$pf"
      fi
    done <<< "$PAGE_FILES"
  fi
fi
finding "INFO" "M8.1" "$UNUSED_ROUTES unreferenced routes"

# ─── M8.2: Unused Components ───
metric_header "M8.2" "Unused Components"

UNUSED_COMPONENTS=0
COMP_DIRS=("$PROJECT_ROOT/src/components" "$PROJECT_ROOT/components" "$PROJECT_ROOT/src/app/components")
for cdir in "${COMP_DIRS[@]}"; do
  [[ -d "$cdir" ]] || continue
  COMP_FILES=$(find "$cdir" -name "*.tsx" -o -name "*.jsx" 2>/dev/null | grep -v ".test." | grep -v ".spec." || true)
  if [[ -n "$COMP_FILES" ]]; then
    while IFS= read -r cf; do
      comp_name=$(basename "$cf" | sed 's/\.\(tsx\|jsx\)$//')
      [[ "$comp_name" == "index" ]] && continue
      # Check if component name is imported/used elsewhere
      USED=$(grep -rl "$comp_name" \
        --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' \
        --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist --exclude-dir=.next \
        "$PROJECT_ROOT" 2>/dev/null | grep -v "$cf" | head -1 || true)
      if [[ -z "$USED" ]]; then
        ((UNUSED_COMPONENTS++)) || true
        finding "TIER2" "M8.2" "Unused component: $comp_name" "$cf"
      fi
    done <<< "$(echo "$COMP_FILES" | head -80)"
  fi
done
finding "INFO" "M8.2" "$UNUSED_COMPONENTS unused components"

# ─── M8.3: Dead CSS / Tailwind Classes ───
metric_header "M8.3" "Dead CSS / Tailwind Classes"

DEAD_CSS=0
# Check for CSS module files and verify usage
CSS_MODULES=$(find "$PROJECT_ROOT/src" "$PROJECT_ROOT/app" -name "*.module.css" -o -name "*.module.scss" 2>/dev/null | grep -v node_modules || true)
if [[ -n "$CSS_MODULES" ]]; then
  while IFS= read -r css_file; do
    css_basename=$(basename "$css_file" | sed 's/\.module\.\(css\|scss\)$//')
    # Check if the CSS module is imported
    IMPORTED=$(grep -rl "$css_basename\.module" \
      --include='*.ts' --include='*.tsx' \
      --exclude-dir=node_modules --exclude-dir=.git \
      "$PROJECT_ROOT" 2>/dev/null | head -1 || true)
    if [[ -z "$IMPORTED" ]]; then
      ((DEAD_CSS++)) || true
      finding "TIER1" "M8.3" "Unused CSS module" "$css_file"
    fi
  done <<< "$CSS_MODULES"
fi

# Check Tailwind content configuration
if [[ -f "$PROJECT_ROOT/tailwind.config.js" || -f "$PROJECT_ROOT/tailwind.config.ts" ]]; then
  finding "INFO" "M8.3" "Tailwind detected — purge/content config handles dead class removal at build time"
fi

finding "INFO" "M8.3" "$DEAD_CSS dead CSS entries"

# ─── M8.4: Unused API Routes ───
metric_header "M8.4" "Unused API Routes"

UNUSED_API=0
API_DIR=""
[[ -n "$APP_DIR" && -d "$APP_DIR/api" ]] && API_DIR="$APP_DIR/api"
[[ -n "$PAGES_DIR" && -d "$PAGES_DIR/api" ]] && API_DIR="$PAGES_DIR/api"

if [[ -n "$API_DIR" ]]; then
  API_FILES=$(find "$API_DIR" -name "route.ts" -o -name "route.tsx" -o -name "*.ts" 2>/dev/null | grep -v ".test." || true)
  if [[ -n "$API_FILES" ]]; then
    while IFS= read -r af; do
      # Derive API route path
      api_route=$(echo "$af" | sed "s|.*api/||;s|/route\.\(ts\|tsx\)$||;s|\.ts$||")
      # Check if called from client code
      CALLED=$(grep -rl "/api/${api_route}\|api/${api_route}" \
        --include='*.ts' --include='*.tsx' --include='*.js' \
        --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist --exclude-dir=.next \
        "$PROJECT_ROOT" 2>/dev/null | grep -v "$af" | head -1 || true)
      if [[ -z "$CALLED" ]]; then
        ((UNUSED_API++)) || true
        finding "TIER2" "M8.4" "Unused API route: /api/$api_route" "$af"
      fi
    done <<< "$API_FILES"
  fi
fi
finding "INFO" "M8.4" "$UNUSED_API unused API routes"

echo ""
echo -e "  ${BOLD}D8 Raw Totals:${NC} unused_routes=$UNUSED_ROUTES unused_components=$UNUSED_COMPONENTS dead_css=$DEAD_CSS unused_api=$UNUSED_API"
