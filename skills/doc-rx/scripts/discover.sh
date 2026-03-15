#!/usr/bin/env bash
# discover.sh — Main discovery orchestrator for doc-rx
# Runs all dimension scripts and collects signals.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

ROOT="${1:-$(detect_root .)}"
ROOT="$(cd "$ROOT" && pwd)"

echo -e "${BOLD}${BLUE}"
echo "  ╔══════════════════════════════════════════════╗"
echo "  ║          doc-rx Discovery Scanner            ║"
echo "  ╚══════════════════════════════════════════════╝"
echo -e "${NC}"
echo -e "  Project root: ${CYAN}${ROOT}${NC}"
echo -e "  Date: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# ── Run each dimension scanner ──────────────────────────────────────────────
for dim in "$SCRIPT_DIR/dimensions"/d*.sh; do
  if [[ -x "$dim" ]]; then
    bash "$dim" "$ROOT"
  else
    warn "Skipping non-executable: $dim"
  fi
done

# ── Final summary ───────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${BLUE}═══ Discovery Complete ═══${NC}"
echo -e "${DIM}Feed these signals to the doc-rx grading framework for scoring.${NC}"
echo ""
