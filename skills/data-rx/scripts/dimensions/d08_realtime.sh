#!/usr/bin/env bash
# D8: Supabase Realtime & Edge Functions (8%)
# Scans for channels, presence, edge functions, webhooks

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

PROJECT_ROOT="${1:-.}"

section_header "D8" "Supabase Realtime & Edge Functions (8%)"

SB_DIR=$(find_supabase_dir "$PROJECT_ROOT")

# ─── M8.1: Realtime Channels ───
metric_header "M8.1" "Realtime Channels"

# Check for channel subscriptions
CHANNELS=$(search_source_files "$PROJECT_ROOT" "\.channel\(|supabase.*channel|\.on\(\s*['\"]postgres_changes" "-rn")
if [[ -n "$CHANNELS" ]]; then
  CHANNEL_COUNT=$(echo "$CHANNELS" | wc -l | tr -d ' ')
  finding "INFO" "M8.1" "Realtime channel usage found: $CHANNEL_COUNT instances"

  # Check for cleanup/unsubscribe
  UNSUBSCRIBE=$(search_source_files "$PROJECT_ROOT" "\.unsubscribe\(\)|removeChannel|channel.*remove" "-rl")
  if [[ -n "$UNSUBSCRIBE" ]]; then
    finding "INFO" "M8.1" "Channel cleanup (unsubscribe) detected"
  else
    finding "MEDIUM" "M8.1" "No channel unsubscribe/cleanup detected — possible memory leaks"
  fi

  # Check for error handling on subscription
  SUB_ERROR=$(search_source_files "$PROJECT_ROOT" "\.subscribe\(.*error\|\.subscribe\(.*err\|\.subscribe\(.*status" "-rn")
  if [[ -n "$SUB_ERROR" ]]; then
    finding "INFO" "M8.1" "Subscription error handling detected"
  else
    finding "LOW" "M8.1" "No error handling on channel subscriptions"
  fi
else
  finding "INFO" "M8.1" "No Realtime channel usage detected (may be N/A)"
fi

# ─── M8.2: Realtime Presence ───
metric_header "M8.2" "Realtime Presence"

PRESENCE=$(search_source_files "$PROJECT_ROOT" "\.track\(|presenceState|\.on\(\s*['\"]presence" "-rn")
if [[ -n "$PRESENCE" ]]; then
  finding "INFO" "M8.2" "Presence tracking detected"

  # Check for untrack
  UNTRACK=$(search_source_files "$PROJECT_ROOT" "\.untrack\(" "-rl")
  if [[ -n "$UNTRACK" ]]; then
    finding "INFO" "M8.2" "Presence untrack on disconnect detected"
  else
    finding "LOW" "M8.2" "No presence untrack detected — may leave stale presence"
  fi
else
  finding "INFO" "M8.2" "No Presence usage detected (N/A if not needed)"
fi

# ─── M8.3: Edge Functions ───
metric_header "M8.3" "Edge Functions"

if [[ -n "$SB_DIR" && -d "$SB_DIR/functions" ]]; then
  FUNC_COUNT=$(find "$SB_DIR/functions" -name "index.ts" -o -name "index.js" 2>/dev/null | wc -l | tr -d ' ')
  finding "INFO" "M8.3" "Edge Functions found: $FUNC_COUNT"

  # Check for Deno serve pattern
  DENO_SERVE=$(grep -rl "Deno\.\|serve(" "$SB_DIR/functions/" 2>/dev/null || true)
  if [[ -n "$DENO_SERVE" ]]; then
    finding "INFO" "M8.3" "Deno serve pattern detected in Edge Functions"
  fi

  # Check for hardcoded secrets
  HARDCODED=$(grep -rn "sk_live\|sk_test\|api_key.*=.*['\"][A-Za-z0-9]" "$SB_DIR/functions/" 2>/dev/null || true)
  if [[ -n "$HARDCODED" ]]; then
    finding "CRITICAL" "M8.3" "Possible hardcoded secrets in Edge Functions!"
    echo "$HARDCODED" | head -3
  fi

  # Check for Deno.env usage (good — using secrets)
  DENO_ENV=$(grep -rl "Deno\.env\.get" "$SB_DIR/functions/" 2>/dev/null || true)
  if [[ -n "$DENO_ENV" ]]; then
    finding "INFO" "M8.3" "Deno.env.get() used for secrets — good pattern"
  fi

  # Check for CORS headers
  CORS=$(grep -rl "Access-Control\|cors" "$SB_DIR/functions/" 2>/dev/null || true)
  if [[ -n "$CORS" ]]; then
    finding "INFO" "M8.3" "CORS configuration detected in Edge Functions"
  else
    finding "LOW" "M8.3" "No CORS configuration in Edge Functions"
  fi
else
  # Check if server-side logic exists that should be in Edge Functions
  SERVER_SECRETS=$(search_source_files "$PROJECT_ROOT" "STRIPE_SECRET|SENDGRID_API|TWILIO_AUTH|third.*party.*secret" "-rl")
  if [[ -n "$SERVER_SECRETS" ]]; then
    finding "MEDIUM" "M8.3" "Third-party secrets found in app code — consider Edge Functions"
  else
    finding "INFO" "M8.3" "No Edge Functions directory (may be N/A)"
  fi
fi

# ─── M8.4: Database Webhooks & Triggers ───
metric_header "M8.4" "Database Webhooks & Triggers"

# Check for pg_notify
PG_NOTIFY=$(search_migration_files "$PROJECT_ROOT" "pg_notify|PERFORM pg_notify" "-in")
if [[ -n "$PG_NOTIFY" ]]; then
  finding "INFO" "M8.4" "pg_notify usage detected in migrations"
fi

# Check for database triggers (not auth-related)
DB_TRIGGERS=$(search_migration_files "$PROJECT_ROOT" "CREATE TRIGGER" "-in" | grep -iv "auth\.users" || true)
if [[ -n "$DB_TRIGGERS" ]]; then
  TRIGGER_COUNT=$(echo "$DB_TRIGGERS" | wc -l | tr -d ' ')
  finding "INFO" "M8.4" "Database triggers found: $TRIGGER_COUNT"

  # Check if triggers are BEFORE/AFTER and what operations
  BEFORE_TRIGGERS=$(echo "$DB_TRIGGERS" | grep -ic "BEFORE" || echo "0")
  AFTER_TRIGGERS=$(echo "$DB_TRIGGERS" | grep -ic "AFTER" || echo "0")
  finding "INFO" "M8.4" "BEFORE triggers: $BEFORE_TRIGGERS, AFTER triggers: $AFTER_TRIGGERS"
else
  finding "INFO" "M8.4" "No custom database triggers (may be N/A)"
fi

# Check for trigger functions
TRIGGER_FUNCS=$(search_migration_files "$PROJECT_ROOT" "CREATE.*FUNCTION.*RETURNS TRIGGER|returns trigger" "-in")
if [[ -n "$TRIGGER_FUNCS" ]]; then
  FUNC_COUNT=$(echo "$TRIGGER_FUNCS" | wc -l | tr -d ' ')
  finding "INFO" "M8.4" "Trigger functions: $FUNC_COUNT"
fi

print_summary
