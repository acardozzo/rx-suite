#!/usr/bin/env bash
# D2: Relationships & Foreign Keys (10%)
# Scans for FK constraints, cascade rules, junction tables, self-referential patterns

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

PROJECT_ROOT="${1:-.}"

section_header "D2" "Relationships & Foreign Keys (10%)"

# ─── M2.1: Foreign Key Coverage ───
metric_header "M2.1" "Foreign Key Coverage"

FK_COUNT=$(search_migration_files "$PROJECT_ROOT" "REFERENCES|FOREIGN KEY" "-ic" | awk -F: '{s+=$2}END{print s+0}')
finding "INFO" "M2.1" "Foreign key constraints found: $FK_COUNT"

# Find columns named *_id that might lack FK constraints
ID_COLS=$(search_migration_files "$PROJECT_ROOT" "[a-z]+_id\s+(uuid|bigint|integer)" "-io" | sort -u)
if [[ -n "$ID_COLS" ]]; then
  ID_COL_COUNT=$(echo "$ID_COLS" | wc -l | tr -d ' ')
  finding "INFO" "M2.1" "Columns ending in _id: $ID_COL_COUNT — verify all have FK constraints"
fi

# Check for implicit relationships (columns named _id without REFERENCES on same line)
IMPLICIT_FK=$(search_migration_files "$PROJECT_ROOT" "[a-z]+_id\s+(uuid|bigint|integer)" "-in" | grep -iv "REFERENCES" || true)
if [[ -n "$IMPLICIT_FK" ]]; then
  finding "MEDIUM" "M2.1" "Possible implicit FKs (no REFERENCES on same line) — may be on separate ALTER TABLE"
  echo "$IMPLICIT_FK" | head -5
fi

# ─── M2.2: Cascade Rules ───
metric_header "M2.2" "Cascade Rules"

CASCADE_COUNT=$(search_migration_files "$PROJECT_ROOT" "ON DELETE CASCADE" "-ic" | awk -F: '{s+=$2}END{print s+0}')
SET_NULL_COUNT=$(search_migration_files "$PROJECT_ROOT" "ON DELETE SET NULL" "-ic" | awk -F: '{s+=$2}END{print s+0}')
RESTRICT_COUNT=$(search_migration_files "$PROJECT_ROOT" "ON DELETE RESTRICT" "-ic" | awk -F: '{s+=$2}END{print s+0}')
NO_ACTION_COUNT=$(search_migration_files "$PROJECT_ROOT" "ON DELETE NO ACTION" "-ic" | awk -F: '{s+=$2}END{print s+0}')

finding "INFO" "M2.2" "ON DELETE CASCADE: $CASCADE_COUNT, SET NULL: $SET_NULL_COUNT, RESTRICT: $RESTRICT_COUNT, NO ACTION: $NO_ACTION_COUNT"

# FKs without explicit ON DELETE
FK_NO_DELETE=$(search_migration_files "$PROJECT_ROOT" "REFERENCES" "-in" | grep -iv "ON DELETE" || true)
if [[ -n "$FK_NO_DELETE" ]]; then
  NO_DELETE_CNT=$(echo "$FK_NO_DELETE" | wc -l | tr -d ' ')
  finding "LOW" "M2.2" "FKs without explicit ON DELETE: $NO_DELETE_CNT (defaults to NO ACTION)"
fi

# Check for ON UPDATE rules
ON_UPDATE=$(search_migration_files "$PROJECT_ROOT" "ON UPDATE" "-ic" | awk -F: '{s+=$2}END{print s+0}')
finding "INFO" "M2.2" "ON UPDATE rules found: $ON_UPDATE"

# ─── M2.3: Junction Tables for M:N ───
metric_header "M2.3" "Junction Tables for M:N"

# Look for tables with 2+ FK columns and few other columns (junction pattern)
TABLES=$(list_tables "$PROJECT_ROOT")
if [[ -n "$TABLES" ]]; then
  while IFS= read -r table; do
    # Strip schema prefix for cleaner output
    tbl_name=$(echo "$table" | sed 's/.*\.//')
    FK_IN_TABLE=$(search_migration_files "$PROJECT_ROOT" "CREATE TABLE.*$tbl_name" "-l" | head -1)
    if [[ -n "$FK_IN_TABLE" ]]; then
      REF_COUNT=$(grep -c "REFERENCES" "$FK_IN_TABLE" 2>/dev/null || echo "0")
      if [[ "$REF_COUNT" -ge 2 ]]; then
        finding "INFO" "M2.3" "Possible junction table: $tbl_name ($REF_COUNT FK references)"
      fi
    fi
  done <<< "$TABLES"
fi

# Check for array columns used for M:N (anti-pattern)
ARRAY_RELATIONS=$(search_migration_files "$PROJECT_ROOT" "uuid\[\]|integer\[\]|bigint\[\]" "-in")
if [[ -n "$ARRAY_RELATIONS" ]]; then
  finding "MEDIUM" "M2.3" "Array columns for IDs found — consider junction tables for M:N"
  echo "$ARRAY_RELATIONS" | head -3
fi

# ─── M2.4: Self-Referential & Polymorphic Patterns ───
metric_header "M2.4" "Self-Referential & Polymorphic Patterns"

# Self-referential FKs (parent_id, manager_id, reply_to_id)
SELF_REF=$(search_migration_files "$PROJECT_ROOT" "parent_id|manager_id|reply_to_id|replied_to|parent_comment" "-in")
if [[ -n "$SELF_REF" ]]; then
  finding "INFO" "M2.4" "Self-referential columns detected"
  echo "$SELF_REF" | head -5
  # Check if they have FK constraints
  SELF_REF_FK=$(echo "$SELF_REF" | grep -i "REFERENCES" || true)
  if [[ -z "$SELF_REF_FK" ]]; then
    finding "MEDIUM" "M2.4" "Self-referential columns may lack FK constraints"
  fi
fi

# Polymorphic patterns (type + id columns)
POLY=$(search_migration_files "$PROJECT_ROOT" "[a-z]+_type\s+text|[a-z]+_type\s+varchar|polymorphic" "-in")
if [[ -n "$POLY" ]]; then
  finding "LOW" "M2.4" "Polymorphic pattern detected — verify referential integrity"
  echo "$POLY" | head -3
fi

# ltree usage for hierarchies
LTREE=$(search_migration_files "$PROJECT_ROOT" "ltree" "-in")
if [[ -n "$LTREE" ]]; then
  finding "INFO" "M2.4" "ltree extension used for hierarchies"
fi

print_summary
