#!/usr/bin/env bash
# discover.sh — Agno project discovery orchestrator
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PROJECT_ROOT="${1:-.}"
source "$SCRIPT_DIR/lib/common.sh"

echo "═══════════════════════════════════════════"
echo "  Agno Project Discovery"
echo "═══════════════════════════════════════════"
echo "  Root: $PROJECT_ROOT"
echo ""

# ── Verify this is an Agno project ──
if ! has_agno_dep; then
  echo "ERROR: No agno dependency found in pyproject.toml or requirements*.txt"
  echo "This does not appear to be an Agno project."
  exit 1
fi

# ── Project summary ──
ver=$(agno_version)
agents=$(count_agents)
teams=$(count_teams)
tools=$(count_tools)
workflows=$(py_find -print0 | xargs -0 grep -cE '\bWorkflow\s*\(' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
py_total=$(py_find | wc -l | tr -d ' ')

echo "  Agno version : $ver"
echo "  Python files  : $py_total"
echo "  Agents        : $agents"
echo "  Teams         : $teams"
echo "  Workflows     : $workflows"
echo "  Tools (custom): $tools"
echo ""
echo "═══════════════════════════════════════════"
echo "  Running 10 dimension scans..."
echo "═══════════════════════════════════════════"
echo ""

# ── Dispatch dimension scripts in parallel ──
DIMS_DIR="$SCRIPT_DIR/dimensions"
pids=()
tmpdir=$(mktemp -d)

for i in 01 02 03 04 05 06 07 08 09 10; do
  script="$DIMS_DIR/d${i}-"*.sh
  # shellcheck disable=SC2086
  if [[ -x $script ]]; then
    bash $script "$PROJECT_ROOT" > "$tmpdir/d${i}.out" 2>&1 &
    pids+=($!)
  fi
done

# ── Collect results ──
for pid in "${pids[@]}"; do
  wait "$pid" || true
done

for i in 01 02 03 04 05 06 07 08 09 10; do
  if [[ -f "$tmpdir/d${i}.out" ]]; then
    cat "$tmpdir/d${i}.out"
    echo ""
  fi
done

rm -rf "$tmpdir"
echo "═══════════════════════════════════════════"
echo "  Discovery complete."
echo "═══════════════════════════════════════════"
