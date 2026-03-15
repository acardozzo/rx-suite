#!/usr/bin/env bash
# rx-deps.sh — Dependency checker for rx-suite
#
# Usage:
#   ./rx-deps.sh              # Check all dependencies
#   ./rx-deps.sh arch-rx      # Check deps for specific skill
#   ./rx-deps.sh --install    # Check + install missing (interactive)
#
# Outputs a table of required/recommended tools with status and install commands.

set -euo pipefail

MODE="${1:-all}"
INSTALL=false
[ "$MODE" = "--install" ] && INSTALL=true && MODE="all"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

check() {
  local name="$1" cmd="$2" type="$3" purpose="$4" skills="$5" install_cmd="$6" required="${7:-no}"

  if command -v "$cmd" >/dev/null 2>&1; then
    local ver
    ver=$("$cmd" --version 2>/dev/null | head -1 || echo "installed")
    printf "  ${GREEN}✅${NC} %-20s %-12s %-40s %s\n" "$name" "$type" "$purpose" "$ver"
  else
    if [ "$required" = "yes" ]; then
      printf "  ${RED}❌${NC} %-20s %-12s %-40s ${RED}REQUIRED${NC}\n" "$name" "$type" "$purpose"
    else
      printf "  ${YELLOW}⚠️${NC}  %-20s %-12s %-40s ${YELLOW}$install_cmd${NC}\n" "$name" "$type" "$purpose"
    fi

    if [ "$INSTALL" = true ] && [ "$required" != "yes" ]; then
      echo -n "    Install $name? [y/N] "
      read -r ans
      if [ "$ans" = "y" ] || [ "$ans" = "Y" ]; then
        echo "    Running: $install_cmd"
        eval "$install_cmd" 2>&1 | tail -3
        echo ""
      fi
    fi
  fi
}

check_feature() {
  local name="$1" check_cmd="$2" purpose="$3" enable_hint="$4"

  if eval "$check_cmd" 2>/dev/null; then
    printf "  ${GREEN}✅${NC} %-20s %-12s %s\n" "$name" "feature" "$purpose"
  else
    printf "  ${YELLOW}⚠️${NC}  %-20s %-12s %-40s ${YELLOW}$enable_hint${NC}\n" "$name" "feature" "$purpose"
  fi
}

echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                   rx-suite Dependency Check                      ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

# ─── CORE (always needed) ───────────────────────────────────────────────
echo "─── Core (required) ───"
check "bash"     "bash"    "core"  "Script execution"         "all"   "" "yes"
check "git"      "git"     "core"  "Version control, worktrees" "all" "" "yes"
check "python3"  "python3" "core"  "JSON analysis, data processing" "all" "" "yes"
echo ""

# ─── NODE.JS TOOLS ──────────────────────────────────────────────────────
if [ "$MODE" = "all" ] || [[ "$MODE" =~ ^(arch|ux|clean|api|test|code) ]]; then
  echo "─── Node.js Tools (recommended) ───"
  check "madge"      "madge"      "npm"  "Import graph, circular deps"       "arch-rx, clean-rx"  "npm i -g madge"
  check "depcheck"   "depcheck"   "npm"  "Unused npm dependencies"           "clean-rx"           "npm i -g depcheck"
  check "knip"       "knip"       "npm"  "Dead exports, files, deps"         "clean-rx"           "npm i -g knip"
  check "lighthouse" "lhci"       "npm"  "Core Web Vitals, a11y audit"       "ux-rx, test-rx"     "npm i -g @lhci/cli"
  check "pa11y"      "pa11y"      "npm"  "WCAG accessibility testing"        "ux-rx, test-rx"     "npm i -g pa11y"
  echo ""
fi

# ─── PYTHON TOOLS ────────────────────────────────────────────────────────
if [ "$MODE" = "all" ] || [[ "$MODE" =~ ^(clean|code|project-agno) ]]; then
  echo "─── Python Tools (recommended) ───"
  check "vulture"        "vulture"        "pip"  "Dead Python code detection"     "clean-rx"  "pip install vulture"
  check "ruff"           "ruff"           "pip"  "Python linting, unused imports" "clean-rx"  "pip install ruff"
  check "pip-autoremove" "pip-autoremove" "pip"  "Unused Python packages"         "clean-rx"  "pip install pip-autoremove"
  echo ""
fi

# ─── SYSTEM TOOLS ────────────────────────────────────────────────────────
if [ "$MODE" = "all" ] || [[ "$MODE" =~ ^(arch|sec) ]]; then
  echo "─── System Tools (recommended) ───"
  check "hadolint"  "hadolint"  "brew"  "Dockerfile quality linting"       "arch-rx"   "brew install hadolint"
  check "syft"      "syft"      "brew"  "SBOM for supply chain audit"      "arch-rx"   "brew install syft"
  check "semgrep"   "semgrep"   "brew"  "Static analysis (OWASP patterns)" "sec-rx"    "brew install semgrep"
  echo ""
fi

# ─── SUPABASE ────────────────────────────────────────────────────────────
if [ "$MODE" = "all" ] || [[ "$MODE" =~ ^(data) ]]; then
  echo "─── Supabase Tools ───"
  check "supabase"  "supabase"  "npm"  "DB introspection, migrations"      "data-rx"  "npm i -g supabase"
  echo ""
fi

# ─── LSP ─────────────────────────────────────────────────────────────────
echo "─── LSP (enhances accuracy) ───"
check "pyright"  "pyright"  "lsp"  "Python type checking, unused symbols"  "code-rx, clean-rx, project-agno-rx"  "pip install pyright"
check "vtsls"    "vtsls"    "lsp"  "TypeScript dead code, type errors"     "code-rx, clean-rx"                   "npm i -g @vtsls/language-server"
echo ""

# ─── CLAUDE CODE FEATURES ────────────────────────────────────────────────
echo "─── Claude Code Features ───"
check_feature "LSP enabled"         "[ \"\$ENABLE_LSP_TOOL\" = '1' ] || grep -q 'ENABLE_LSP_TOOL=1' ~/.zshrc 2>/dev/null"  "Type-aware code analysis"  "Add ENABLE_LSP_TOOL=1 to ~/.zshrc"
check_feature "typescript-lsp"      "grep -q 'typescript-lsp' ~/.claude/settings.json 2>/dev/null"                          "TS language server plugin" "Enable in Claude Code settings"
check_feature "pyright-lsp"         "grep -q 'pyright-lsp' ~/.claude/settings.json 2>/dev/null"                             "Python language server"    "Enable in Claude Code settings"
echo ""

# ─── CLAUDE CODE MCPs ───────────────────────────────────────────────────
echo "─── MCPs (optional, enhance specific skills) ───"
check_feature "Playwright MCP"      "grep -rq 'playwright' ~/.claude/settings.json 2>/dev/null"    "Browser testing for ux-rx E2E"         "Install Playwright MCP"
check_feature "Supabase MCP"        "grep -rq 'supabase' ~/.claude/settings.json 2>/dev/null"      "Direct DB introspection for data-rx"    "Install Supabase MCP"
check_feature "Firecrawl MCP"       "grep -rq 'firecrawl' ~/.claude/settings.json 2>/dev/null"     "Web scraping for api-rx docs check"     "Install Firecrawl MCP"
echo ""

# ─── SUMMARY ─────────────────────────────────────────────────────────────
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║  ${GREEN}✅${NC} = installed    ${YELLOW}⚠️${NC}  = missing (recommended)    ${RED}❌${NC} = required  ║"
echo "╚══════════════════════════════════════════════════════════════════╝"

if [ "$INSTALL" != true ]; then
  echo ""
  echo "Run with --install to interactively install missing tools:"
  echo "  bash scripts/rx-deps.sh --install"
  echo ""
  echo "Or install all recommended at once:"
  echo "  npm i -g madge depcheck knip @lhci/cli pa11y @vtsls/language-server supabase"
  echo "  pip install vulture ruff pyright pip-autoremove"
  echo "  brew install hadolint syft semgrep"
fi
