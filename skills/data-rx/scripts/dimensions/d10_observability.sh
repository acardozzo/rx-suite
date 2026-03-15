#!/usr/bin/env bash
# D10: Observability & Maintenance (8%)
# Scans for query monitoring, bloat, connection management, backup config

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

PROJECT_ROOT="${1:-.}"

section_header "D10" "Observability & Maintenance (8%)"

SB_DIR=$(find_supabase_dir "$PROJECT_ROOT")

# ─── M10.1: Query Monitoring ───
metric_header "M10.1" "Query Monitoring"

# Check for pg_stat_statements references
PG_STAT=$(search_migration_files "$PROJECT_ROOT" "pg_stat_statements" "-in")
if [[ -n "$PG_STAT" ]]; then
  finding "INFO" "M10.1" "pg_stat_statements referenced in migrations"
else
  finding "LOW" "M10.1" "No pg_stat_statements setup in migrations"
fi

# Check for pg_stat_statements extension
PG_EXT=$(search_migration_files "$PROJECT_ROOT" "CREATE EXTENSION.*pg_stat_statements" "-in")
if [[ -n "$PG_EXT" ]]; then
  finding "INFO" "M10.1" "pg_stat_statements extension enabled"
fi

# Check for EXPLAIN usage in code/scripts
EXPLAIN=$(search_source_files "$PROJECT_ROOT" "EXPLAIN\s+ANALYZE|\.explain\(" "-rn")
if [[ -n "$EXPLAIN" ]]; then
  finding "INFO" "M10.1" "EXPLAIN ANALYZE usage detected — query plan awareness"
fi

# Check for monitoring/alerting in config
MONITORING=$(search_config_files "$PROJECT_ROOT" "monitoring|alerting|datadog|newrelic|sentry" "-rl")
if [[ -n "$MONITORING" ]]; then
  finding "INFO" "M10.1" "Monitoring/alerting configuration detected"
fi

# ─── M10.2: Database Size & Bloat ───
metric_header "M10.2" "Database Size & Bloat"

# Check for VACUUM references
VACUUM=$(search_migration_files "$PROJECT_ROOT" "VACUUM|autovacuum|vacuum_settings" "-in")
if [[ -n "$VACUUM" ]]; then
  finding "INFO" "M10.2" "VACUUM configuration found in migrations"
else
  finding "LOW" "M10.2" "No explicit VACUUM configuration — relying on autovacuum defaults"
fi

# Check for table partitioning
PARTITION=$(search_migration_files "$PROJECT_ROOT" "PARTITION BY|PARTITION OF|CREATE.*PARTITION" "-in")
if [[ -n "$PARTITION" ]]; then
  finding "INFO" "M10.2" "Table partitioning detected"
fi

# Check for unused index detection scripts
UNUSED_IDX=$(search_source_files "$PROJECT_ROOT" "pg_stat_user_indexes.*idx_scan.*=.*0|unused.*index" "-rn")
if [[ -n "$UNUSED_IDX" ]]; then
  finding "INFO" "M10.2" "Unused index detection patterns found"
fi

# ─── M10.3: Connection Management ───
metric_header "M10.3" "Connection Management"

# Check config.toml for pooler settings
if [[ -n "$SB_DIR" && -f "$SB_DIR/config.toml" ]]; then
  POOLER=$(grep -i "pool\|connection\|pgbouncer" "$SB_DIR/config.toml" 2>/dev/null || true)
  if [[ -n "$POOLER" ]]; then
    finding "INFO" "M10.3" "Connection pooler configuration in config.toml"
    echo "$POOLER" | head -5
  else
    finding "LOW" "M10.3" "No explicit pooler configuration in config.toml"
  fi
fi

# Check for connection mode in code
CONN_MODE=$(search_source_files "$PROJECT_ROOT" "pooler|transaction.*mode|session.*mode|db_pool" "-rn")
if [[ -n "$CONN_MODE" ]]; then
  finding "INFO" "M10.3" "Connection mode references found in code"
fi

# Check for connection string patterns
CONN_STRING=$(search_config_files "$PROJECT_ROOT" "DATABASE_URL|DIRECT_URL|SUPABASE_DB_URL" "-rn" | grep -v "node_modules" || true)
if [[ -n "$CONN_STRING" ]]; then
  finding "INFO" "M10.3" "Database connection string configuration detected"

  # Check for pooler URL vs direct URL
  POOLER_URL=$(echo "$CONN_STRING" | grep -i "pooler\|6543" || true)
  DIRECT_URL=$(echo "$CONN_STRING" | grep -i "direct\|5432" || true)
  [[ -n "$POOLER_URL" ]] && finding "INFO" "M10.3" "Pooler connection URL detected (port 6543)"
  [[ -n "$DIRECT_URL" ]] && finding "INFO" "M10.3" "Direct connection URL detected (port 5432)"
fi

# ─── M10.4: Backup & Recovery ───
metric_header "M10.4" "Backup & Recovery"

# Check for PITR references
PITR=$(search_config_files "$PROJECT_ROOT" "pitr|point.in.time|wal_level|archive" "-rn")
if [[ -n "$PITR" ]]; then
  finding "INFO" "M10.4" "Point-in-time recovery configuration detected"
fi

# Check for backup scripts/config
BACKUP=$(search_config_files "$PROJECT_ROOT" "backup|pg_dump|pg_restore|recovery" "-rl")
if [[ -n "$BACKUP" ]]; then
  finding "INFO" "M10.4" "Backup/recovery configuration detected"
else
  finding "LOW" "M10.4" "No explicit backup configuration — relying on Supabase managed backups"
fi

# Check for disaster recovery docs
DR_DOCS=$(find "$PROJECT_ROOT" -maxdepth 3 -name "*disaster*" -o -name "*recovery*" -o -name "*backup*" \
  -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null | head -5)
if [[ -n "$DR_DOCS" ]]; then
  finding "INFO" "M10.4" "Disaster recovery/backup documentation found"
fi

# Check Supabase plan awareness (Pro for PITR)
PLAN_REF=$(search_config_files "$PROJECT_ROOT" "pro.*plan|supabase.*plan|pitr" "-rn")
if [[ -n "$PLAN_REF" ]]; then
  finding "INFO" "M10.4" "Supabase plan references detected"
fi

print_summary
