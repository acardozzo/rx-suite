#!/usr/bin/env bash
# D1: Schema Design & Normalization (12%)
# Scans migrations for table naming, column types, normalization, primary keys

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

PROJECT_ROOT="${1:-.}"

section_header "D1" "Schema Design & Normalization (12%)"

# ─── M1.1: Table Naming Conventions ───
metric_header "M1.1" "Table Naming Conventions"

TABLES=$(list_tables "$PROJECT_ROOT")
if [[ -n "$TABLES" ]]; then
  TOTAL_TABLES=$(echo "$TABLES" | wc -l | tr -d ' ')
  finding "INFO" "M1.1" "Found $TOTAL_TABLES tables in migrations"

  # Check snake_case
  NON_SNAKE=$(echo "$TABLES" | grep -v -E '^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)?$' || true)
  if [[ -n "$NON_SNAKE" ]]; then
    while IFS= read -r tbl; do
      finding "MEDIUM" "M1.1" "Table not snake_case: $tbl"
    done <<< "$NON_SNAKE"
  else
    finding "INFO" "M1.1" "All tables use snake_case naming"
  fi

  # Check singular vs plural
  SINGULAR=$(echo "$TABLES" | grep -v -E 's$|data$|info$|status$|metadata$' | head -5 || true)
  if [[ -n "$SINGULAR" ]]; then
    finding "LOW" "M1.1" "Possibly singular table names (check convention): $(echo "$SINGULAR" | tr '\n' ', ')"
  fi
else
  finding "HIGH" "M1.1" "No CREATE TABLE statements found in migrations"
fi

# ─── M1.2: Column Types & Constraints ───
metric_header "M1.2" "Column Types & Constraints"

# Check for varchar(255) anti-pattern (should use text)
VARCHAR_255=$(search_migration_files "$PROJECT_ROOT" "varchar\s*\(\s*255\s*\)" "-in")
if [[ -n "$VARCHAR_255" ]]; then
  finding "LOW" "M1.2" "varchar(255) found — prefer text type in PostgreSQL"
  echo "$VARCHAR_255" | head -3
fi

# Check for timestamp vs timestamptz
TIMESTAMP_NO_TZ=$(search_migration_files "$PROJECT_ROOT" "\btimestamp\b" "-in" | grep -iv "timestamptz\|timestamp with time zone" || true)
if [[ -n "$TIMESTAMP_NO_TZ" ]]; then
  finding "MEDIUM" "M1.2" "timestamp without timezone found — use timestamptz instead"
  echo "$TIMESTAMP_NO_TZ" | head -3
fi

# Check for NOT NULL constraints
NOT_NULL_COUNT=$(search_migration_files "$PROJECT_ROOT" "NOT NULL" "-c" | awk -F: '{s+=$2}END{print s+0}')
finding "INFO" "M1.2" "NOT NULL constraints found: $NOT_NULL_COUNT"

# Check for CHECK constraints
CHECK_COUNT=$(search_migration_files "$PROJECT_ROOT" "CHECK\s*\(" "-c" | awk -F: '{s+=$2}END{print s+0}')
finding "INFO" "M1.2" "CHECK constraints found: $CHECK_COUNT"

# Check for DEFAULT values
DEFAULT_COUNT=$(search_migration_files "$PROJECT_ROOT" "DEFAULT\b" "-ic" | awk -F: '{s+=$2}END{print s+0}')
finding "INFO" "M1.2" "DEFAULT values found: $DEFAULT_COUNT"

# Check for gen_random_uuid()
UUID_DEFAULT=$(search_migration_files "$PROJECT_ROOT" "gen_random_uuid\(\)" "-c" | awk -F: '{s+=$2}END{print s+0}')
finding "INFO" "M1.2" "gen_random_uuid() defaults: $UUID_DEFAULT"

# ─── M1.3: Normalization Level ───
metric_header "M1.3" "Normalization Level"

# Check for array columns (potential denormalization)
ARRAY_COLS=$(search_migration_files "$PROJECT_ROOT" "\[\]|ARRAY\[" "-in")
if [[ -n "$ARRAY_COLS" ]]; then
  finding "LOW" "M1.3" "Array columns found — verify intentional denormalization"
  echo "$ARRAY_COLS" | head -3
fi

# Check for JSONB columns
JSONB_COLS=$(search_migration_files "$PROJECT_ROOT" "\bjsonb?\b" "-in")
if [[ -n "$JSONB_COLS" ]]; then
  JSONB_COUNT=$(echo "$JSONB_COLS" | wc -l | tr -d ' ')
  finding "INFO" "M1.3" "JSONB columns found: $JSONB_COUNT — verify intentional use"
fi

# Check for repeated column groups (address1, address2 pattern)
REPEATED=$(search_migration_files "$PROJECT_ROOT" "[a-z]+[_]?[1-3]\b" "-in" | grep -iv "auth\|m2m\|v[0-9]" || true)
if [[ -n "$REPEATED" ]]; then
  finding "MEDIUM" "M1.3" "Possible repeated column groups (normalization issue)"
  echo "$REPEATED" | head -3
fi

# ─── M1.4: Primary Keys & Identity ───
metric_header "M1.4" "Primary Keys & Identity"

# Check UUID vs serial PKs
UUID_PKS=$(search_migration_files "$PROJECT_ROOT" "uuid.*PRIMARY KEY|PRIMARY KEY.*uuid|id uuid.*DEFAULT gen_random_uuid" "-ic" | awk -F: '{s+=$2}END{print s+0}')
SERIAL_PKS=$(search_migration_files "$PROJECT_ROOT" "serial\s+PRIMARY KEY|bigserial\s+PRIMARY KEY|GENERATED.*AS IDENTITY" "-ic" | awk -F: '{s+=$2}END{print s+0}')
finding "INFO" "M1.4" "UUID PKs: $UUID_PKS, Serial/Identity PKs: $SERIAL_PKS"

# Check for tables without explicit PK
NO_PK=$(search_migration_files "$PROJECT_ROOT" "CREATE TABLE" "-c" | awk -F: '{s+=$2}END{print s+0}')
PK_COUNT=$(search_migration_files "$PROJECT_ROOT" "PRIMARY KEY" "-c" | awk -F: '{s+=$2}END{print s+0}')
if [[ "$PK_COUNT" -lt "$NO_PK" ]]; then
  finding "HIGH" "M1.4" "Possible tables without PRIMARY KEY — $NO_PK tables, $PK_COUNT PKs detected"
fi

print_summary
