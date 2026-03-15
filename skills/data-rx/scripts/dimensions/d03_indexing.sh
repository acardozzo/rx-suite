#!/usr/bin/env bash
# D3: Indexing & Query Performance (12%)
# Scans for index coverage, composite indexes, index types, query patterns

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

PROJECT_ROOT="${1:-.}"

section_header "D3" "Indexing & Query Performance (12%)"

# ─── M3.1: Index Coverage ───
metric_header "M3.1" "Index Coverage"

INDEX_COUNT=$(search_migration_files "$PROJECT_ROOT" "CREATE\s+(UNIQUE\s+)?INDEX" "-ic" | awk -F: '{s+=$2}END{print s+0}')
finding "INFO" "M3.1" "Total indexes created: $INDEX_COUNT"

# Check if FK columns have indexes
FK_COLS=$(search_migration_files "$PROJECT_ROOT" "REFERENCES" "-in" | sed -E 's/.*\b([a-z_]+_id)\b.*/\1/' | sort -u)
if [[ -n "$FK_COLS" ]]; then
  MISSING_IDX=0
  while IFS= read -r col; do
    HAS_IDX=$(search_migration_files "$PROJECT_ROOT" "CREATE.*INDEX.*$col" "-il")
    if [[ -z "$HAS_IDX" ]]; then
      finding "MEDIUM" "M3.1" "FK column '$col' may lack an index"
      ((MISSING_IDX++)) || true
    fi
  done <<< "$FK_COLS"
  if [[ "$MISSING_IDX" -eq 0 ]]; then
    finding "INFO" "M3.1" "All detected FK columns appear to have indexes"
  fi
fi

# Unique indexes
UNIQUE_IDX=$(search_migration_files "$PROJECT_ROOT" "CREATE UNIQUE INDEX" "-ic" | awk -F: '{s+=$2}END{print s+0}')
finding "INFO" "M3.1" "Unique indexes: $UNIQUE_IDX"

# ─── M3.2: Composite Indexes ───
metric_header "M3.2" "Composite Indexes"

# Composite indexes (multiple columns in parentheses)
COMPOSITE=$(search_migration_files "$PROJECT_ROOT" "CREATE.*INDEX.*\(.*,.*\)" "-in")
if [[ -n "$COMPOSITE" ]]; then
  COMP_COUNT=$(echo "$COMPOSITE" | wc -l | tr -d ' ')
  finding "INFO" "M3.2" "Composite indexes found: $COMP_COUNT"
  echo "$COMPOSITE" | head -5
else
  finding "LOW" "M3.2" "No composite indexes found — consider for multi-column query patterns"
fi

# ─── M3.3: Index Types ───
metric_header "M3.3" "Index Types"

# GIN indexes (for JSONB, arrays, full-text)
GIN_COUNT=$(search_migration_files "$PROJECT_ROOT" "USING\s+gin" "-ic" | awk -F: '{s+=$2}END{print s+0}')
finding "INFO" "M3.3" "GIN indexes: $GIN_COUNT"

# GiST indexes (for geo, range types)
GIST_COUNT=$(search_migration_files "$PROJECT_ROOT" "USING\s+gist" "-ic" | awk -F: '{s+=$2}END{print s+0}')
finding "INFO" "M3.3" "GiST indexes: $GIST_COUNT"

# pg_trgm for text search
TRGM=$(search_migration_files "$PROJECT_ROOT" "pg_trgm|gin_trgm_ops" "-in")
if [[ -n "$TRGM" ]]; then
  finding "INFO" "M3.3" "pg_trgm trigram search indexes detected"
fi

# Check if JSONB columns have GIN indexes
JSONB_COLS=$(search_migration_files "$PROJECT_ROOT" "\bjsonb\b" "-il")
if [[ -n "$JSONB_COLS" && "$GIN_COUNT" -eq 0 ]]; then
  finding "MEDIUM" "M3.3" "JSONB columns found but no GIN indexes — add GIN for JSONB queries"
fi

# Partial indexes
PARTIAL=$(search_migration_files "$PROJECT_ROOT" "CREATE.*INDEX.*WHERE" "-ic" | awk -F: '{s+=$2}END{print s+0}')
finding "INFO" "M3.3" "Partial indexes: $PARTIAL"

# ─── M3.4: Query Patterns ───
metric_header "M3.4" "Query Patterns"

# SELECT * / no .select() (defaults to all columns)
SELECT_STAR=$(search_source_files "$PROJECT_ROOT" "\.from\(['\"].*['\"]\)\.select\(\s*\)" "-rn")
SELECT_ALL=$(search_source_files "$PROJECT_ROOT" "\.from\(['\"].*['\"]\)\.select\(['\"]?\*['\"]?\)" "-rn")
NO_SELECT=$(search_source_files "$PROJECT_ROOT" "\.from\(['\"].*['\"]\)\.(eq|filter|order|limit|range)" "-rn" | grep -v "\.select(" || true)

if [[ -n "$SELECT_STAR" || -n "$SELECT_ALL" ]]; then
  finding "MEDIUM" "M3.4" "SELECT * or empty .select() found — specify columns"
  echo "${SELECT_STAR}${SELECT_ALL}" | head -5
fi
if [[ -n "$NO_SELECT" ]]; then
  finding "LOW" "M3.4" "Queries without .select() found — defaults to all columns"
  echo "$NO_SELECT" | head -3
fi

# Specific column selection
SPECIFIC_SELECT=$(search_source_files "$PROJECT_ROOT" "\.select\(['\"][a-z_]+(\s*,\s*[a-z_]+)*['\"]" "-rn")
if [[ -n "$SPECIFIC_SELECT" ]]; then
  SPEC_COUNT=$(echo "$SPECIFIC_SELECT" | wc -l | tr -d ' ')
  finding "INFO" "M3.4" "Specific column .select() calls: $SPEC_COUNT"
fi

# N+1 patterns (select inside loops)
N_PLUS_1=$(search_source_files "$PROJECT_ROOT" "(for|while|forEach|\.map)\s*\(.*\n?.*supabase|\.from\(.*\).*\.select\(.*\).*\.eq\(" "-rn")
if [[ -n "$N_PLUS_1" ]]; then
  finding "HIGH" "M3.4" "Possible N+1 query pattern — Supabase calls inside loops"
  echo "$N_PLUS_1" | head -5
fi

# Pagination
PAGINATION=$(search_source_files "$PROJECT_ROOT" "\.range\(|\.limit\(" "-rl")
if [[ -n "$PAGINATION" ]]; then
  finding "INFO" "M3.4" "Pagination detected (.range() or .limit())"
else
  finding "LOW" "M3.4" "No pagination detected — consider .range() for large datasets"
fi

print_summary
