#!/usr/bin/env bash
# discover.sh — Orchestrator for ux-rx UX discovery
#
# Stack: Next.js App Router + shadcn/ui + Tailwind CSS (fixed)
#
# Usage:
#   ./discover.sh [target_dir] [dimensions...]
#
# Examples:
#   ./discover.sh app              # Run all 11 dimensions against app/
#   ./discover.sh src all          # Same as above
#   ./discover.sh src d02 d03      # Run only Performance + Components
#   ./discover.sh . d1 d5          # Short form accepted

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DIM_DIR="$SCRIPT_DIR/dimensions"

# Parse args
TARGET="${1:-.}"
shift || true
DIMS=("${@:-all}")
[ "${#DIMS[@]}" -eq 0 ] && DIMS=("all")

# Resolve paths
export ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
if [[ "$TARGET" = /* ]]; then
  export TARGET_ABS="$TARGET"
else
  export TARGET_ABS="$ROOT/$TARGET"
fi

if [ ! -d "$TARGET_ABS" ]; then
  echo "Error: Directory $TARGET_ABS does not exist" >&2
  exit 1
fi

# ─── Header ─────────────────────────────────────────────────────────────────
echo "=== UX-RX DISCOVERY ==="
echo "Target: $TARGET_ABS"
echo "Date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo ""

# ─── Verify Next.js project ─────────────────────────────────────────────────
echo "## PROJECT VERIFICATION"
NEXT_CONFIG=$(find "$ROOT" -maxdepth 2 -name "next.config*" ! -path "*/node_modules/*" 2>/dev/null | head -1)
if [ -z "$NEXT_CONFIG" ]; then
  echo "Warning: No next.config found — this may not be a Next.js project" >&2
else
  echo "Next.js config: $NEXT_CONFIG"
fi

PKG_MGR="npm"
[ -f "$ROOT/pnpm-lock.yaml" ] && PKG_MGR="pnpm"
[ -f "$ROOT/yarn.lock" ] && PKG_MGR="yarn"
[ -f "$ROOT/bun.lockb" ] && PKG_MGR="bun"
echo "Package manager: $PKG_MGR"
echo ""

# ─── shadcn/ui inventory ────────────────────────────────────────────────────
echo "## SHADCN/UI INVENTORY"
UI_DIR=$(find "$TARGET_ABS" -type d -name "ui" -path "*/components/ui" 2>/dev/null | head -1)
if [ -z "$UI_DIR" ]; then
  UI_DIR=$(find "$ROOT" -type d -name "ui" -path "*/components/ui" ! -path "*/node_modules/*" 2>/dev/null | head -1)
fi

if [ -n "$UI_DIR" ]; then
  INSTALLED=$(ls "$UI_DIR"/*.tsx "$UI_DIR"/*.ts 2>/dev/null | xargs -I{} basename {} .tsx | sort)
  COUNT=$(echo "$INSTALLED" | grep -c . || echo 0)
  echo "Installed components ($COUNT):"
  echo "$INSTALLED" | sed 's/^/  - /'
else
  echo "No components/ui/ directory found"
fi
echo ""

# ─── Tailwind config ────────────────────────────────────────────────────────
echo "## TAILWIND CONFIG"
TW_CONFIG=$(find "$ROOT" -maxdepth 2 \( -name "tailwind.config.*" -o -name "postcss.config.*" \) ! -path "*/node_modules/*" 2>/dev/null | head -3)
if [ -n "$TW_CONFIG" ]; then
  echo "$TW_CONFIG" | sed 's/^/  /'
else
  echo "  No tailwind.config found (may use CSS-based config with v4)"
fi
echo ""

# ─── Resolve dimensions to run ──────────────────────────────────────────────
ALL_DIMS=(d01 d02 d03 d04 d05 d06 d07 d08 d09 d10 d11)

if [ "${DIMS[0]}" = "all" ]; then
  RUN_DIMS=("${ALL_DIMS[@]}")
else
  RUN_DIMS=()
  for d in "${DIMS[@]}"; do
    d_lower=$(echo "$d" | tr '[:upper:]' '[:lower:]')
    d_num=$(echo "$d_lower" | sed 's/^d//' | sed 's/^0//')
    d_padded=$(printf "d%02d" "$d_num")
    if ls "$DIM_DIR/$d_padded"-*.sh >/dev/null 2>&1; then
      RUN_DIMS+=("$d_padded")
    else
      echo "Warning: Unknown dimension '$d' (resolved to '$d_padded'), skipping" >&2
    fi
  done
fi

echo "## DIMENSIONS: ${RUN_DIMS[*]}"
echo ""

# ─── Run dimension scripts in parallel ──────────────────────────────────────
TMPDIR=$(mktemp -d)
PIDS=()

for dim in "${RUN_DIMS[@]}"; do
  script=$(ls "$DIM_DIR/$dim"-*.sh 2>/dev/null | head -1)
  if [ -n "$script" ]; then
    bash "$script" > "$TMPDIR/$dim.out" 2>&1 &
    PIDS+=($!)
  fi
done

for pid in "${PIDS[@]}"; do
  wait "$pid" 2>/dev/null || true
done

for dim in "${RUN_DIMS[@]}"; do
  [ -f "$TMPDIR/$dim.out" ] && cat "$TMPDIR/$dim.out"
done

rm -rf "$TMPDIR"

# ─── Summary ────────────────────────────────────────────────────────────────
echo "=== DISCOVERY COMPLETE ==="
echo "Dimensions analyzed: ${RUN_DIMS[*]}"
echo ""
echo "Feed this output to scoring agents with grading-framework.md and stack-adapters.md."
