#!/usr/bin/env bash
# discover.sh — Orchestrator for project-rx (strongest discovery in rx family)
#
# Usage:
#   ./discover.sh [target_dir] [dimensions...]
#   ./discover.sh src              # all 10 dimensions
#   ./discover.sh src d01 d04      # only Identity + Business
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DIM_DIR="$SCRIPT_DIR/dimensions"

TARGET="${1:-.}"
shift || true
DIMS=("${@:-all}")
[ "${#DIMS[@]}" -eq 0 ] && DIMS=("all")

export ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
if [ "$TARGET" = "." ]; then
  export TARGET_ABS="$ROOT"
else
  export TARGET_ABS="$ROOT/$TARGET"
fi

[ ! -d "$TARGET_ABS" ] && { echo "Error: $TARGET_ABS not found" >&2; exit 1; }

source "$SCRIPT_DIR/lib/common.sh"

echo "=== PROJECT-RX DISCOVERY ==="
echo "Target: $TARGET_ABS"
echo "Date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo ""

# ─── Archetype Detection ────────────────────────────────────────────────────
echo "## ARCHETYPE"
ARCHETYPE=$(detect_archetype)
echo "  Detected: $ARCHETYPE"
echo ""

# ─── Stack Detection ────────────────────────────────────────────────────────
echo "## STACK"
export STACK="unknown"
if [ -f "$ROOT/package.json" ]; then
  export STACK="node"
  echo "  Runtime: Node.js/TypeScript"
  echo "  Package manager: $([ -f "$ROOT/pnpm-lock.yaml" ] && echo 'pnpm' || ([ -f "$ROOT/yarn.lock" ] && echo 'yarn' || echo 'npm'))"
  for fw in next express fastify hono nestjs nuxt remix sveltekit astro; do
    grep -q "\"$fw\"" "$ROOT/package.json" 2>/dev/null && echo "  Framework: $fw"
    grep -q "\"@$fw" "$ROOT/package.json" 2>/dev/null && echo "  Framework: $fw"
  done
elif [ -f "$ROOT/go.mod" ]; then export STACK="go"; echo "  Runtime: Go"
elif [ -f "$ROOT/pom.xml" ] || [ -f "$ROOT/build.gradle" ]; then export STACK="jvm"; echo "  Runtime: JVM"
elif [ -f "$ROOT/Cargo.toml" ]; then export STACK="rust"; echo "  Runtime: Rust"
elif [ -f "$ROOT/pyproject.toml" ] || [ -f "$ROOT/requirements.txt" ]; then export STACK="python"; echo "  Runtime: Python"
elif ls "$ROOT"/*.csproj 1>/dev/null 2>&1; then export STACK="dotnet"; echo "  Runtime: .NET"
fi
echo ""

# ─── Inventories ─────────────────────────────────────────────────────────────
echo "## DEPENDENCY INVENTORY (top 30)"
if [ -f "$ROOT/package.json" ]; then
  (grep -oE '"[^"]+":' "$ROOT/package.json" | grep -v '"name"\|"version"\|"description"\|"scripts"\|"dependencies"\|"devDependencies"\|"peerDependencies"' | tr -d '":' | head -30) 2>/dev/null
fi
echo ""

echo "## ROUTE INVENTORY (top 30)"
src_find -print0 2>/dev/null | xargs -0 grep -ohE '("|'"'"')(/(api|auth|admin|billing|webhook|health|ready|live|dashboard|settings|profile|onboarding|docs|v[0-9]+)[^"'"'"']*)("|'"'"')' 2>/dev/null | sort -u | head -30
echo ""

echo "## ENV VAR INVENTORY (top 30)"
src_find -print0 2>/dev/null | xargs -0 grep -ohE 'process\.env\.[A-Z_]+|env\("[A-Z_]+"' 2>/dev/null | sort -u | head -30
echo ""

# ─── Resolve dimensions ─────────────────────────────────────────────────────
ALL_DIMS=(d01 d02 d03 d04 d05 d06 d07 d08 d09 d10)

if [ "${DIMS[0]}" = "all" ]; then
  RUN_DIMS=("${ALL_DIMS[@]}")
else
  RUN_DIMS=()
  for d in "${DIMS[@]}"; do
    d_lower=$(echo "$d" | tr '[:upper:]' '[:lower:]')
    d_num=$(echo "$d_lower" | sed 's/^d//' | sed 's/^0//')
    d_padded=$(printf "d%02d" "$d_num")
    [ -f "$DIM_DIR/$d_padded"-*.sh ] && RUN_DIMS+=("$d_padded")
  done
fi

echo "## DIMENSIONS: ${RUN_DIMS[*]}"
echo ""

# ─── Run in parallel ─────────────────────────────────────────────────────────
TMPDIR=$(mktemp -d)
PIDS=()
for dim in "${RUN_DIMS[@]}"; do
  script=$(ls "$DIM_DIR/$dim"-*.sh 2>/dev/null | head -1)
  if [ -n "$script" ]; then
    bash "$script" > "$TMPDIR/$dim.out" 2>&1 &
    PIDS+=($!)
  fi
done

for pid in "${PIDS[@]}"; do wait "$pid" 2>/dev/null || true; done

for dim in "${RUN_DIMS[@]}"; do
  [ -f "$TMPDIR/$dim.out" ] && cat "$TMPDIR/$dim.out"
done
rm -rf "$TMPDIR"

echo "=== DISCOVERY COMPLETE ==="
echo "Archetype: $ARCHETYPE"
echo "Dimensions: ${RUN_DIMS[*]}"
