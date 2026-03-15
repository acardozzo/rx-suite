#!/usr/bin/env bash
# D4: UI & Visual Testing — component tests, visual regression, a11y, cross-browser
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

PROJECT_ROOT="${1:-$(pwd)}"

# --------------------------------------------------------------------------
# M4.1 — Component tests
# --------------------------------------------------------------------------

# Storybook stories
STORYBOOK_FILES=$(find "$PROJECT_ROOT" -type f \( -name "*.stories.ts" -o -name "*.stories.tsx" -o -name "*.stories.js" -o -name "*.stories.jsx" -o -name "*.stories.mdx" \) "${EXCLUDE_DIRS[@]}" 2>/dev/null | wc -l | tr -d ' ')
HAS_STORYBOOK_CONFIG=$(find "$PROJECT_ROOT" -maxdepth 3 -type d -name ".storybook" "${EXCLUDE_DIRS[@]}" 2>/dev/null | wc -l | tr -d ' ')

# Testing Library render calls in tests
RENDER_IN_TESTS=$(grep -rl "render(\|screen\.\|fireEvent\|userEvent\|@testing-library" "$PROJECT_ROOT" --include="*.test.*" --include="*.spec.*" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

# Component files (to calculate ratio)
COMPONENT_FILES=$(find "$PROJECT_ROOT" -type f \( -name "*.tsx" -o -name "*.jsx" -o -name "*.vue" -o -name "*.svelte" \) "${EXCLUDE_DIRS[@]}" 2>/dev/null | grep -v "test\|spec\|stories\|__test" | wc -l | tr -d ' ')

# Storybook interaction tests
INTERACTION_TESTS=$(grep -rl "play:\|userEvent\.\|within(" "$PROJECT_ROOT" --include="*.stories.*" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

# --------------------------------------------------------------------------
# M4.2 — Visual regression
# --------------------------------------------------------------------------

# Chromatic
HAS_CHROMATIC=$(count_pattern "chromatic\|@chromatic-com" "package.json" "$PROJECT_ROOT")
CHROMATIC_CONFIG=$(find "$PROJECT_ROOT" -maxdepth 3 -name "chromatic.*" "${EXCLUDE_DIRS[@]}" 2>/dev/null | wc -l | tr -d ' ')

# Percy
HAS_PERCY=$(count_pattern "@percy\|percy" "package.json" "$PROJECT_ROOT")
PERCY_CONFIG=$(find "$PROJECT_ROOT" -maxdepth 3 -name ".percy.*" "${EXCLUDE_DIRS[@]}" 2>/dev/null | wc -l | tr -d ' ')

# Playwright visual comparison
PLAYWRIGHT_VISUAL=$(grep -rl "toHaveScreenshot\|toMatchSnapshot\|expect(page).toHaveScreenshot\|screenshot" "$PROJECT_ROOT" --include="*.spec.*" --include="*.test.*" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

# BackstopJS
HAS_BACKSTOP=$(count_pattern "backstopjs\|backstop" "package.json" "$PROJECT_ROOT")
BACKSTOP_CONFIG=$(find "$PROJECT_ROOT" -maxdepth 3 -name "backstop.*" "${EXCLUDE_DIRS[@]}" 2>/dev/null | wc -l | tr -d ' ')

VISUAL_REGRESSION_CONFIGURED="false"
if [[ $HAS_CHROMATIC -gt 0 ]] || [[ $HAS_PERCY -gt 0 ]] || [[ $PLAYWRIGHT_VISUAL -gt 0 ]] || [[ $HAS_BACKSTOP -gt 0 ]]; then
  VISUAL_REGRESSION_CONFIGURED="true"
fi

# --------------------------------------------------------------------------
# M4.3 — Accessibility testing
# --------------------------------------------------------------------------

# axe-core / jest-axe
AXE_IN_TESTS=$(grep -rl "axe\|toHaveNoViolations\|jest-axe\|@axe-core\|checkA11y\|a11y" "$PROJECT_ROOT" --include="*.test.*" --include="*.spec.*" --include="*.stories.*" "${EXCLUDE_DIRS[@]/#/--exclude-dir=}" 2>/dev/null | wc -l | tr -d ' ' || echo "0")
HAS_AXE_DEP=$(count_pattern "axe-core\|jest-axe\|@axe-core/react\|vitest-axe" "package.json" "$PROJECT_ROOT")

# pa11y
HAS_PA11Y=$(count_pattern "pa11y" "package.json" "$PROJECT_ROOT")

# Storybook a11y addon
HAS_STORYBOOK_A11Y=$(count_pattern "@storybook/addon-a11y" "package.json" "$PROJECT_ROOT")

# --------------------------------------------------------------------------
# M4.4 — Cross-browser testing
# --------------------------------------------------------------------------

# Playwright multi-browser config
PLAYWRIGHT_PROJECTS=$(grep -c "chromium\|firefox\|webkit" "$PROJECT_ROOT"/playwright.config.* 2>/dev/null | head -1 || echo "0")
if [[ -z "$PLAYWRIGHT_PROJECTS" ]]; then PLAYWRIGHT_PROJECTS=0; fi

# BrowserStack / Sauce Labs
HAS_BROWSERSTACK=$(count_pattern "browserstack\|BROWSERSTACK" "*" "$PROJECT_ROOT")
HAS_SAUCELABS=$(count_pattern "saucelabs\|SAUCE_" "*" "$PROJECT_ROOT")

# Cypress multi-browser
CYPRESS_BROWSERS=$(grep -c "chrome\|firefox\|edge\|electron" "$PROJECT_ROOT"/cypress.config.* 2>/dev/null | head -1 || echo "0")
if [[ -z "$CYPRESS_BROWSERS" ]]; then CYPRESS_BROWSERS=0; fi

# --------------------------------------------------------------------------
# Output JSON
# --------------------------------------------------------------------------

cat << EOF
{
  "component_tests": {
    "storybook_files": $STORYBOOK_FILES,
    "storybook_config": $HAS_STORYBOOK_CONFIG,
    "render_in_tests": $RENDER_IN_TESTS,
    "component_files": $COMPONENT_FILES,
    "interaction_tests": $INTERACTION_TESTS
  },
  "visual_regression": {
    "configured": $VISUAL_REGRESSION_CONFIGURED,
    "chromatic": $HAS_CHROMATIC,
    "chromatic_config": $CHROMATIC_CONFIG,
    "percy": $HAS_PERCY,
    "percy_config": $PERCY_CONFIG,
    "playwright_visual": $PLAYWRIGHT_VISUAL,
    "backstop": $HAS_BACKSTOP,
    "backstop_config": $BACKSTOP_CONFIG
  },
  "accessibility": {
    "axe_in_tests": $AXE_IN_TESTS,
    "axe_dependency": $HAS_AXE_DEP,
    "pa11y": $HAS_PA11Y,
    "storybook_a11y_addon": $HAS_STORYBOOK_A11Y
  },
  "cross_browser": {
    "playwright_browser_count": $PLAYWRIGHT_PROJECTS,
    "browserstack": $HAS_BROWSERSTACK,
    "saucelabs": $HAS_SAUCELABS,
    "cypress_browsers": $CYPRESS_BROWSERS
  }
}
EOF
