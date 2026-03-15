#!/usr/bin/env bash
# D7: Supabase Waste — Unused tables, orphan migrations, dead RLS, unused storage buckets
# Score as N/A (100) if project doesn't use Supabase

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

PROJECT_ROOT="${1:-.}"
detect_stacks "$PROJECT_ROOT"

if ! $STACK_SUPABASE; then
  echo -e "  ${YELLOW}D7: Supabase not detected — scoring as N/A (100)${NC}"
  exit 0
fi

section_header "D7" "Supabase Waste (8%)"

MIGRATIONS_DIR="$PROJECT_ROOT/supabase/migrations"

# ─── M7.1: Unused Tables ───
metric_header "M7.1" "Unused Tables"

UNUSED_TABLES=0
if [[ -d "$MIGRATIONS_DIR" ]]; then
  # Extract table names from CREATE TABLE statements
  TABLES=$(grep -rhi "CREATE TABLE" "$MIGRATIONS_DIR" 2>/dev/null \
    | sed 's/.*CREATE TABLE\s\+\(IF NOT EXISTS\s\+\)\?//I' \
    | sed 's/\s*(.*//;s/"//g;s/;//' \
    | tr -d ' ' | sort -u || true)

  if [[ -n "$TABLES" ]]; then
    # Check which tables are dropped in later migrations
    DROPPED=$(grep -rhi "DROP TABLE" "$MIGRATIONS_DIR" 2>/dev/null \
      | sed 's/.*DROP TABLE\s\+\(IF EXISTS\s\+\)\?//I' \
      | sed 's/\s*;.*//;s/"//g;s/ CASCADE//' \
      | tr -d ' ' | sort -u || true)

    while IFS= read -r table; do
      [[ -z "$table" ]] && continue
      # Skip if table was dropped
      echo "$DROPPED" | grep -q "^${table}$" && continue
      # Skip system/auth tables
      [[ "$table" == auth.* || "$table" == storage.* || "$table" == extensions.* ]] && continue
      # Extract just the table name (remove schema prefix)
      tname=$(echo "$table" | sed 's/.*\.//')
      # Check if referenced in client code
      USED=$(grep -rl "from(['\"]${tname}['\"])\|\.from(['\"]${tname}['\"])\|'${tname}'\|\"${tname}\"" \
        --include='*.ts' --include='*.tsx' --include='*.js' --include='*.py' \
        --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
        --exclude-dir=supabase \
        "$PROJECT_ROOT" 2>/dev/null | head -1 || true)
      if [[ -z "$USED" ]]; then
        ((UNUSED_TABLES++)) || true
        finding "TIER3" "M7.1" "Table '$table' not found in client code (may have external consumers)"
      fi
    done <<< "$TABLES"
  fi
fi
finding "INFO" "M7.1" "$UNUSED_TABLES potentially unused tables"

# ─── M7.2: Orphan Migrations ───
metric_header "M7.2" "Orphan Migrations"

ORPHAN_MIGRATIONS=0
if [[ -d "$MIGRATIONS_DIR" ]]; then
  # Find tables that are created and then dropped
  CREATED=$(grep -rhl "CREATE TABLE" "$MIGRATIONS_DIR" 2>/dev/null | sort || true)
  DROP_FILES=$(grep -rhl "DROP TABLE" "$MIGRATIONS_DIR" 2>/dev/null | sort || true)

  if [[ -n "$DROP_FILES" ]]; then
    while IFS= read -r drop_file; do
      DROPPED_TABLES=$(grep -hi "DROP TABLE" "$drop_file" 2>/dev/null \
        | sed 's/.*DROP TABLE\s\+\(IF EXISTS\s\+\)\?//I' \
        | sed 's/\s*;.*//;s/"//g' | tr -d ' ')
      if [[ -n "$DROPPED_TABLES" ]]; then
        while IFS= read -r dtable; do
          [[ -z "$dtable" ]] && continue
          # Check if this table was created in an earlier migration
          CREATE_FILE=$(grep -rl "CREATE TABLE.*${dtable}" "$MIGRATIONS_DIR" 2>/dev/null | head -1 || true)
          if [[ -n "$CREATE_FILE" ]]; then
            ((ORPHAN_MIGRATIONS++)) || true
            finding "TIER2" "M7.2" "Table '$dtable' created then dropped" "$drop_file"
          fi
        done <<< "$DROPPED_TABLES"
      fi
    done <<< "$DROP_FILES"
  fi
fi
finding "INFO" "M7.2" "$ORPHAN_MIGRATIONS orphan migration pairs"

# ─── M7.3: Dead RLS Policies ───
metric_header "M7.3" "Dead RLS Policies"

DEAD_RLS=0
if [[ -d "$MIGRATIONS_DIR" ]]; then
  # Extract RLS policy targets
  RLS_TARGETS=$(grep -rhi "CREATE POLICY\|ALTER POLICY" "$MIGRATIONS_DIR" 2>/dev/null \
    | grep -oiP "ON\s+\K[^\s(]+" | sed 's/"//g' | sort -u || true)

  if [[ -n "$RLS_TARGETS" ]]; then
    # Get list of dropped tables
    DROPPED=$(grep -rhi "DROP TABLE" "$MIGRATIONS_DIR" 2>/dev/null \
      | sed 's/.*DROP TABLE\s\+\(IF EXISTS\s\+\)\?//I' \
      | sed 's/\s*;.*//;s/"//g;s/ CASCADE//' | tr -d ' ' | sort -u || true)

    while IFS= read -r target; do
      [[ -z "$target" ]] && continue
      tname=$(echo "$target" | sed 's/.*\.//')
      if echo "$DROPPED" | grep -qi "$tname"; then
        ((DEAD_RLS++)) || true
        finding "TIER1" "M7.3" "RLS policy on dropped table: $target"
      fi
    done <<< "$RLS_TARGETS"
  fi
fi
finding "INFO" "M7.3" "$DEAD_RLS dead RLS policies"

# ─── M7.4: Unused Storage Buckets ───
metric_header "M7.4" "Unused Storage Buckets"

UNUSED_BUCKETS=0
# Find bucket creation
BUCKETS=$(grep -rhi "INSERT INTO storage.buckets\|createBucket\|storage\.createBucket" \
  "$MIGRATIONS_DIR" "$PROJECT_ROOT/supabase" 2>/dev/null \
  | grep -oP "'[^']+'" | tr -d "'" | sort -u || true)
if [[ -n "$BUCKETS" ]]; then
  while IFS= read -r bucket; do
    [[ -z "$bucket" ]] && continue
    USED=$(grep -rl "storage.from(['\"]${bucket}['\"])\|\.from(['\"]${bucket}['\"])" \
      --include='*.ts' --include='*.tsx' --include='*.js' --include='*.py' \
      --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=supabase \
      "$PROJECT_ROOT" 2>/dev/null | head -1 || true)
    if [[ -z "$USED" ]]; then
      ((UNUSED_BUCKETS++)) || true
      finding "TIER3" "M7.4" "Storage bucket '$bucket' not referenced in client code"
    fi
  done <<< "$BUCKETS"
fi
finding "INFO" "M7.4" "$UNUSED_BUCKETS unused storage buckets"

echo ""
echo -e "  ${BOLD}D7 Raw Totals:${NC} unused_tables=$UNUSED_TABLES orphan_migrations=$ORPHAN_MIGRATIONS dead_rls=$DEAD_RLS unused_buckets=$UNUSED_BUCKETS"
