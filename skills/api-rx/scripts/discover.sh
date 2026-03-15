#!/usr/bin/env bash
# discover.sh — Orchestrator for api-rx API surface discovery
#
# Stack-agnostic: works with any backend framework.
#
# Usage:
#   ./discover.sh [target_dir] [dimensions...]
#
# Examples:
#   ./discover.sh src/api            # Run all 8 dimensions against src/api/
#   ./discover.sh apps/backend all   # Same as above
#   ./discover.sh src d01 d04        # Run only REST Design + Auth
#   ./discover.sh . d1 d5            # Short form accepted

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
echo "=== API-RX DISCOVERY ==="
echo "Target: $TARGET_ABS"
echo "Date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo ""

# ─── API Surface Inventory ──────────────────────────────────────────────────
echo "## API SURFACE INVENTORY"

EXCLUDE='! -path "*/node_modules/*" ! -path "*/.git/*" ! -path "*/dist/*" ! -path "*/build/*" ! -path "*/vendor/*" ! -path "*/__pycache__/*"'

ROUTE_COUNT=$(eval find '"$TARGET_ABS"' -type f \\\( -name "'*route*'" -o -name "'*router*'" -o -name "'*controller*'" -o -name "'*handler*'" -o -name "'*endpoint*'" \\\) "$EXCLUDE" 2>/dev/null | wc -l | tr -d ' ')
echo "Route/controller files: $ROUTE_COUNT"

MIDDLEWARE_COUNT=$(eval find '"$TARGET_ABS"' -type f \\\( -name "'*middleware*'" -o -name "'*interceptor*'" -o -name "'*guard*'" \\\) "$EXCLUDE" 2>/dev/null | wc -l | tr -d ' ')
echo "Middleware files: $MIDDLEWARE_COUNT"

OPENAPI_COUNT=$(eval find '"$ROOT"' -maxdepth 4 -type f \\\( -name "'openapi.*'" -o -name "'swagger.*'" -o -name "'api-spec.*'" \\\) "$EXCLUDE" 2>/dev/null | wc -l | tr -d ' ')
echo "OpenAPI/Swagger specs: $OPENAPI_COUNT"

SCHEMA_COUNT=$(eval find '"$TARGET_ABS"' -type f \\\( -name "'*schema*'" -o -name "'*validator*'" -o -name "'*dto*'" \\\) "$EXCLUDE" 2>/dev/null | wc -l | tr -d ' ')
echo "Schema/validation files: $SCHEMA_COUNT"

WEBHOOK_COUNT=$(eval find '"$TARGET_ABS"' -type f -name "'*webhook*'" "$EXCLUDE" 2>/dev/null | wc -l | tr -d ' ')
echo "Webhook files: $WEBHOOK_COUNT"

DOC_COUNT=$(eval find '"$ROOT"' -maxdepth 3 -type f \\\( -name "'*api-doc*'" -o -name "'*swagger-ui*'" -o -name "'*redoc*'" \\\) "$EXCLUDE" 2>/dev/null | wc -l | tr -d ' ')
echo "API doc configs: $DOC_COUNT"
echo ""

# ─── Framework Detection ────────────────────────────────────────────────────
echo "## FRAMEWORK DETECTION"
detect_framework() {
  if [ -f "$ROOT/package.json" ]; then
    for fw in express fastify nestjs hapi koa restify; do
      if grep -q "\"$fw\"" "$ROOT/package.json" 2>/dev/null; then
        echo "  Detected: $fw (Node.js)"
      fi
    done
    if grep -q "\"next\"" "$ROOT/package.json" 2>/dev/null; then
      echo "  Detected: Next.js API routes"
    fi
  fi
  [ -f "$ROOT/requirements.txt" ] || [ -f "$ROOT/pyproject.toml" ] && {
    for fw in django flask fastapi; do
      grep -qi "$fw" "$ROOT/requirements.txt" "$ROOT/pyproject.toml" 2>/dev/null && echo "  Detected: $fw (Python)"
    done
  }
  [ -f "$ROOT/Gemfile" ] && grep -q "rails" "$ROOT/Gemfile" 2>/dev/null && echo "  Detected: Rails (Ruby)"
  [ -f "$ROOT/go.mod" ] && echo "  Detected: Go module"
  [ -f "$ROOT/Cargo.toml" ] && echo "  Detected: Rust (Cargo)"
  [ -f "$ROOT/pom.xml" ] || [ -f "$ROOT/build.gradle" ] && echo "  Detected: Java/Kotlin (Maven/Gradle)"
  echo "  (Stack-agnostic analysis — no framework dependency)"
}
detect_framework
echo ""

# ─── Resolve dimensions to run ──────────────────────────────────────────────
ALL_DIMS=(d01 d02 d03 d04 d05 d06 d07 d08)

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
echo "Feed this output to scoring agents with grading-framework.md."
