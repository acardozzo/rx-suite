#!/usr/bin/env bash
# d02-api-docs.sh — D2: API Documentation
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

ROOT="$1"

header "D2: API Documentation (15%)"

# ── M2.1: OpenAPI/Swagger Spec ─────────────────────────────────────────────
subheader "M2.1: OpenAPI/Swagger Spec"

openapi_files=$(find "$ROOT" -maxdepth 5 \( \
  -name "openapi.yaml" -o -name "openapi.yml" -o -name "openapi.json" \
  -o -name "swagger.yaml" -o -name "swagger.yml" -o -name "swagger.json" \
  -o -name "api-spec.*" -o -name "api.yaml" -o -name "api.yml" \
  \) -type f 2>/dev/null)

if [[ -n "$openapi_files" ]]; then
  while IFS= read -r f; do
    found "OpenAPI/Swagger spec: $(basename "$f") at ${f#$ROOT/}"
    # Check if it references all paths
    if grep -qc '"paths"\|paths:' "$f" 2>/dev/null; then
      path_count=$(grep -cE '^\s{2,4}["/]' "$f" 2>/dev/null || echo "0")
      info "Approximate path entries: $path_count"
    fi
  done <<< "$openapi_files"
else
  missing "No OpenAPI/Swagger spec found"
fi

# Check for Swagger UI / Redoc setup
if grep -rq "swagger-ui\|redoc\|@apidevtools\|swagger-jsdoc" "$ROOT/package.json" 2>/dev/null; then
  found "Swagger UI / Redoc dependency in package.json"
fi

# ── M2.2: Endpoint Documentation ──────────────────────────────────────────
subheader "M2.2: Endpoint Documentation"

# Check for API docs directory
api_docs_dir=""
for candidate in docs/api doc/api api-docs API.md docs/endpoints; do
  if [[ -d "$ROOT/$candidate" ]] || [[ -f "$ROOT/$candidate" ]]; then
    api_docs_dir="$ROOT/$candidate"
    found "API docs location: $candidate"
    break
  fi
done

# Check for inline route documentation (JSDoc on routes)
route_files=$(find "$ROOT" -maxdepth 5 \( -name "*.ts" -o -name "*.js" \) -path "*/route*" -o -path "*/api/*" -type f 2>/dev/null | head -20)
if [[ -n "$route_files" ]]; then
  documented=0
  total=0
  while IFS= read -r rf; do
    total=$((total + 1))
    if grep -q '@swagger\|@openapi\|@api\|/\*\*' "$rf" 2>/dev/null; then
      documented=$((documented + 1))
    fi
  done <<< "$route_files"
  info "Route files sampled: $total, with doc comments: $documented"
fi

# Check for Postman/Insomnia collections
postman=$(find "$ROOT" -maxdepth 3 \( -name "*postman*" -o -name "*insomnia*" \) -type f 2>/dev/null | head -3)
if [[ -n "$postman" ]]; then
  found "Postman/Insomnia collection found"
fi

# ── M2.3: Authentication Guide ────────────────────────────────────────────
subheader "M2.3: Authentication Guide"

auth_doc=false
for candidate in docs/auth* docs/authentication* AUTHENTICATION.md docs/security*; do
  match=$(find "$ROOT" -maxdepth 3 -path "$ROOT/$candidate" -type f 2>/dev/null | head -1)
  if [[ -n "$match" ]]; then
    found "Auth documentation: ${match#$ROOT/}"
    auth_doc=true
    break
  fi
done

# Check README for auth section
for readme in README.md readme.md; do
  if [[ -f "$ROOT/$readme" ]]; then
    if has_section "$ROOT/$readme" "authenticat\|authoriz\|auth\|login\|token\|api.key"; then
      found "Auth section in README"
      auth_doc=true
    fi
  fi
done

if [[ "$auth_doc" == "false" ]]; then
  missing "No authentication documentation found"
fi

# ── M2.4: Error Code Catalog ──────────────────────────────────────────────
subheader "M2.4: Error Code Catalog"

error_doc=false
for candidate in docs/errors* docs/error-codes* ERROR_CODES.md docs/troubleshoot*; do
  match=$(find "$ROOT" -maxdepth 3 -path "$ROOT/$candidate" -type f 2>/dev/null | head -1)
  if [[ -n "$match" ]]; then
    found "Error documentation: ${match#$ROOT/}"
    error_doc=true
    break
  fi
done

# Check for error constants/enums
error_constants=$(find "$ROOT/src" "$ROOT/lib" "$ROOT/app" -maxdepth 4 \
  \( -name "*error*" -o -name "*errors*" \) \
  \( -name "*.ts" -o -name "*.js" -o -name "*.py" -o -name "*.go" \) \
  -type f 2>/dev/null | head -5)
if [[ -n "$error_constants" ]]; then
  info "Error definition files found in source"
  while IFS= read -r ef; do
    info "  ${ef#$ROOT/}"
  done <<< "$error_constants"
fi

if [[ "$error_doc" == "false" ]]; then
  missing "No error code catalog found"
fi

echo ""
