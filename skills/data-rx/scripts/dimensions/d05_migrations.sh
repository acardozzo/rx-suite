#!/usr/bin/env bash
# D5: Migrations & Schema Evolution (10%)
# Scans for migration discipline, quality, seed data, schema versioning

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

PROJECT_ROOT="${1:-.}"

section_header "D5" "Migrations & Schema Evolution (10%)"

SB_DIR=$(find_supabase_dir "$PROJECT_ROOT")

# ─── M5.1: Migration Discipline ───
metric_header "M5.1" "Migration Discipline"

if [[ -n "$SB_DIR" && -d "$SB_DIR/migrations" ]]; then
  MIGRATION_FILES=$(list_migrations "$PROJECT_ROOT")
  MIGRATION_CNT=$(echo "$MIGRATION_FILES" | grep -c . || echo "0")
  finding "INFO" "M5.1" "Migration directory found: $SB_DIR/migrations ($MIGRATION_CNT files)"
else
  finding "CRITICAL" "M5.1" "No supabase/migrations/ directory found"
  MIGRATION_CNT=0
fi

# Check for SQL files outside supabase/migrations/
STRAY_SQL=$(find "$PROJECT_ROOT" -name "*.sql" -not -path "*/supabase/migrations/*" \
  -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/supabase/seed.sql" \
  -not -path "*/.temp/*" 2>/dev/null | head -10)
if [[ -n "$STRAY_SQL" ]]; then
  STRAY_COUNT=$(echo "$STRAY_SQL" | wc -l | tr -d ' ')
  finding "MEDIUM" "M5.1" "SQL files found outside supabase/migrations/: $STRAY_COUNT"
  echo "$STRAY_SQL" | head -5
fi

# Check for supabase db diff in scripts
DB_DIFF=$(search_config_files "$PROJECT_ROOT" "supabase db diff|supabase migration new" "-rn")
if [[ -n "$DB_DIFF" ]]; then
  finding "INFO" "M5.1" "supabase CLI migration commands found in scripts/config"
fi

# ─── M5.2: Migration Quality ───
metric_header "M5.2" "Migration Quality"

if [[ "$MIGRATION_CNT" -gt 0 ]]; then
  # Check for IF NOT EXISTS / IF EXISTS guards
  IF_EXISTS=$(search_migration_files "$PROJECT_ROOT" "IF NOT EXISTS|IF EXISTS" "-ic" | awk -F: '{s+=$2}END{print s+0}')
  finding "INFO" "M5.2" "Idempotent guards (IF [NOT] EXISTS): $IF_EXISTS"

  # Check for comments explaining intent
  COMMENTS=$(search_migration_files "$PROJECT_ROOT" "^--\s+\w+" "-c" | awk -F: '{s+=$2}END{print s+0}')
  finding "INFO" "M5.2" "Comment lines in migrations: $COMMENTS"

  # Check for DROP TABLE without backup
  DROP_TABLE=$(search_migration_files "$PROJECT_ROOT" "DROP TABLE" "-in")
  if [[ -n "$DROP_TABLE" ]]; then
    finding "HIGH" "M5.2" "DROP TABLE found in migrations — verify backward compatibility"
    echo "$DROP_TABLE" | head -3
  fi

  # Check for ALTER COLUMN TYPE (potentially breaking)
  ALTER_TYPE=$(search_migration_files "$PROJECT_ROOT" "ALTER.*COLUMN.*TYPE|ALTER.*COLUMN.*SET DATA TYPE" "-in")
  if [[ -n "$ALTER_TYPE" ]]; then
    finding "MEDIUM" "M5.2" "Column type changes found — verify expand-and-contract pattern"
    echo "$ALTER_TYPE" | head -3
  fi

  # Check for DROP COLUMN
  DROP_COL=$(search_migration_files "$PROJECT_ROOT" "DROP COLUMN" "-in")
  if [[ -n "$DROP_COL" ]]; then
    finding "MEDIUM" "M5.2" "DROP COLUMN found — verify backward compatibility"
  fi
fi

# ─── M5.3: Seed Data ───
metric_header "M5.3" "Seed Data"

if [[ -n "$SB_DIR" && -f "$SB_DIR/seed.sql" ]]; then
  SEED_SIZE=$(wc -l < "$SB_DIR/seed.sql" | tr -d ' ')
  finding "INFO" "M5.3" "Seed file found: $SB_DIR/seed.sql ($SEED_SIZE lines)"

  # Check seed idempotency
  SEED_UPSERT=$(grep -ic "ON CONFLICT\|INSERT.*OR REPLACE\|IF NOT EXISTS" "$SB_DIR/seed.sql" 2>/dev/null || echo "0")
  if [[ "$SEED_UPSERT" -gt 0 ]]; then
    finding "INFO" "M5.3" "Seed has idempotent patterns (ON CONFLICT/IF NOT EXISTS): $SEED_UPSERT"
  else
    finding "LOW" "M5.3" "Seed file may not be idempotent — no ON CONFLICT clauses"
  fi
else
  finding "MEDIUM" "M5.3" "No seed.sql file found — no reproducible test data"
fi

# ─── M5.4: Schema Versioning ───
metric_header "M5.4" "Schema Versioning"

if [[ "$MIGRATION_CNT" -gt 0 ]]; then
  # Check timestamp format in migration filenames
  TIMESTAMP_NAMES=$(list_migrations "$PROJECT_ROOT" | xargs -I{} basename {} | grep -cE "^[0-9]{14}_" || echo "0")
  finding "INFO" "M5.4" "Migrations with timestamp prefix (YYYYMMDDHHMMSS): $TIMESTAMP_NAMES / $MIGRATION_CNT"

  if [[ "$TIMESTAMP_NAMES" -lt "$MIGRATION_CNT" ]]; then
    finding "LOW" "M5.4" "Some migrations don't follow timestamp naming convention"
  fi

  # Check for ordering issues (non-sequential timestamps)
  SORTED=$(list_migrations "$PROJECT_ROOT" | xargs -I{} basename {} | sort)
  ORIGINAL=$(list_migrations "$PROJECT_ROOT" | xargs -I{} basename {})
  if [[ "$SORTED" != "$ORIGINAL" ]]; then
    finding "MEDIUM" "M5.4" "Migration files may be out of order"
  else
    finding "INFO" "M5.4" "Migrations appear to be in correct chronological order"
  fi
fi

print_summary
