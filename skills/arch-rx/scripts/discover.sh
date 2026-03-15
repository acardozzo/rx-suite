#!/usr/bin/env bash
# discover.sh — Orchestrator for arch-rx architecture discovery
#
# Usage:
#   ./discover.sh [target_dir] [dimensions...]
#
# Examples:
#   ./discover.sh src              # Run all 11 dimensions against src/
#   ./discover.sh src all          # Same as above
#   ./discover.sh src d02 d03      # Run only Async + Resilience
#   ./discover.sh apps/api d09     # Run only Security against apps/api/

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DIM_DIR="$SCRIPT_DIR/dimensions"

# Parse args
TARGET="${1:-src}"
shift || true
DIMS=("${@:-all}")
[ "${#DIMS[@]}" -eq 0 ] && DIMS=("all")

# Resolve paths
export ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
export TARGET_ABS="$ROOT/$TARGET"

if [ ! -d "$TARGET_ABS" ]; then
  echo "Error: Directory $TARGET_ABS does not exist" >&2
  exit 1
fi

# ─── Header ─────────────────────────────────────────────────────────────────
echo "=== ARCH-RX DISCOVERY ==="
echo "Target: $TARGET_ABS"
echo "Date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo ""

# ─── Tool detection ─────────────────────────────────────────────────────────
echo "## TOOL AVAILABILITY"
for tool in madge depcruise hadolint syft; do
  if command -v "$tool" >/dev/null 2>&1; then
    echo "  $tool: YES"
  else
    echo "  $tool: NO"
  fi
done
echo ""

# ─── Stack detection ────────────────────────────────────────────────────────
echo "## STACK DETECTION"
echo ""
export STACK="unknown"
if [ -f "$ROOT/package.json" ]; then
  export STACK="node"
  echo "Runtime: Node.js/TypeScript"
  echo "Package manager: $([ -f "$ROOT/pnpm-lock.yaml" ] && echo 'pnpm' || ([ -f "$ROOT/yarn.lock" ] && echo 'yarn' || echo 'npm'))"
  for fw in next express fastify hono nestjs nuxt; do
    grep -q "\"$fw\"" "$ROOT/package.json" 2>/dev/null && echo "Framework: $fw"
  done
elif [ -f "$ROOT/go.mod" ]; then
  export STACK="go"; echo "Runtime: Go"; head -1 "$ROOT/go.mod"
elif [ -f "$ROOT/pom.xml" ] || [ -f "$ROOT/build.gradle" ] || [ -f "$ROOT/build.gradle.kts" ]; then
  export STACK="jvm"; echo "Runtime: JVM (Java/Kotlin)"
elif [ -f "$ROOT/Cargo.toml" ]; then
  export STACK="rust"; echo "Runtime: Rust"
elif [ -f "$ROOT/pyproject.toml" ] || [ -f "$ROOT/requirements.txt" ]; then
  export STACK="python"; echo "Runtime: Python"
elif ls "$ROOT"/*.csproj 1>/dev/null 2>&1; then
  export STACK="dotnet"; echo "Runtime: .NET"
fi
echo ""

# ─── Resolve dimensions to run ──────────────────────────────────────────────
ALL_DIMS=(d01 d02 d03 d04 d05 d06 d07 d08 d09 d10 d11)

if [ "${DIMS[0]}" = "all" ]; then
  RUN_DIMS=("${ALL_DIMS[@]}")
else
  RUN_DIMS=()
  for d in "${DIMS[@]}"; do
    # Normalize: accept "d01", "d1", "1", "D01"
    d_lower=$(echo "$d" | tr '[:upper:]' '[:lower:]')
    d_num=$(echo "$d_lower" | sed 's/^d//' | sed 's/^0//')
    d_padded=$(printf "d%02d" "$d_num")
    if [ -f "$DIM_DIR/$d_padded-"*.sh ]; then
      RUN_DIMS+=("$d_padded")
    else
      echo "Warning: Unknown dimension '$d' (resolved to '$d_padded'), skipping" >&2
    fi
  done
fi

echo "## DIMENSIONS: ${RUN_DIMS[*]}"
echo ""

# ─── Run dimension scripts ──────────────────────────────────────────────────
TMPDIR=$(mktemp -d)
PIDS=()

for dim in "${RUN_DIMS[@]}"; do
  script=$(ls "$DIM_DIR/$dim"-*.sh 2>/dev/null | head -1)
  if [ -n "$script" ]; then
    bash "$script" > "$TMPDIR/$dim.out" 2>&1 &
    PIDS+=($!)
  fi
done

# Wait for all
for pid in "${PIDS[@]}"; do
  wait "$pid" 2>/dev/null || true
done

# Output in order
for dim in "${RUN_DIMS[@]}"; do
  [ -f "$TMPDIR/$dim.out" ] && cat "$TMPDIR/$dim.out"
done

rm -rf "$TMPDIR"

# ─── Deep analysis (optional tools, only on 'all') ──────────────────────────
if [ "${DIMS[0]}" = "all" ] || [ "${#DIMS[@]}" -eq 0 ]; then
  echo "## DEEP ANALYSIS (optional tools)"
  echo ""

  if command -v depcruise >/dev/null 2>&1 && [ "$STACK" = "node" ]; then
    echo "### dependency-cruiser: layer violations"
    depcruise "$TARGET_ABS" --output-type err 2>/dev/null | head -20
    echo ""
  fi

  if command -v madge >/dev/null 2>&1 && [ "$STACK" = "node" ]; then
    echo "### madge: circular dependencies"
    CIRCULARS=$(madge --circular "$TARGET_ABS" 2>/dev/null | grep -c "→" || echo 0)
    echo "Circular dependency chains: $CIRCULARS"
    madge --circular "$TARGET_ABS" 2>/dev/null | head -15
    echo ""
  fi
fi

# ─── Summary ────────────────────────────────────────────────────────────────
echo "=== DISCOVERY COMPLETE ==="
echo "Dimensions analyzed: ${RUN_DIMS[*]}"
echo ""
echo "Feed this output to scoring agents with grading-framework.md and stack-adapters.md."
