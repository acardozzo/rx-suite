#!/usr/bin/env bash
# D4: Row-Level Security (12%) — THE KEY DIMENSION
# Scans for RLS enabled, policy completeness, policy quality, service role separation

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

PROJECT_ROOT="${1:-.}"

section_header "D4" "Row-Level Security (12%)"

# ─── M4.1: RLS Enabled ───
metric_header "M4.1" "RLS Enabled on All User-Facing Tables"

ALL_TABLES=$(list_tables "$PROJECT_ROOT")
RLS_TABLES=$(list_rls_enabled "$PROJECT_ROOT")
FORCE_RLS=$(list_rls_force "$PROJECT_ROOT")

TOTAL_TABLES=$(echo "$ALL_TABLES" | grep -c . || echo "0")
RLS_COUNT=$(echo "$RLS_TABLES" | grep -c . || echo "0")
FORCE_COUNT=$(echo "$FORCE_RLS" | grep -c . || echo "0")

finding "INFO" "M4.1" "Tables: $TOTAL_TABLES total, $RLS_COUNT with RLS enabled, $FORCE_COUNT with FORCE RLS"

# Find tables WITHOUT RLS
if [[ -n "$ALL_TABLES" ]]; then
  while IFS= read -r table; do
    tbl_clean=$(echo "$table" | sed 's/.*\.//' | tr -d '[:space:]')
    [[ -z "$tbl_clean" ]] && continue
    if ! echo "$RLS_TABLES" | grep -q "$tbl_clean" 2>/dev/null; then
      finding "CRITICAL" "M4.1" "Table WITHOUT RLS: $table"
    fi
  done <<< "$ALL_TABLES"
fi

# Check FORCE ROW LEVEL SECURITY
if [[ "$FORCE_COUNT" -lt "$RLS_COUNT" ]]; then
  finding "MEDIUM" "M4.1" "Not all RLS-enabled tables have FORCE ROW LEVEL SECURITY"
fi

# ─── M4.2: Policy Completeness ───
metric_header "M4.2" "Policy Completeness (CRUD per table)"

POLICIES=$(list_rls_policies "$PROJECT_ROOT")
POLICY_COUNT=$(echo "$POLICIES" | grep -c . || echo "0")
finding "INFO" "M4.2" "Total policies: $POLICY_COUNT"

# Count policies per operation
SELECT_POLICIES=$(echo "$POLICIES" | grep -ic "FOR SELECT" || echo "0")
INSERT_POLICIES=$(echo "$POLICIES" | grep -ic "FOR INSERT" || echo "0")
UPDATE_POLICIES=$(echo "$POLICIES" | grep -ic "FOR UPDATE" || echo "0")
DELETE_POLICIES=$(echo "$POLICIES" | grep -ic "FOR DELETE" || echo "0")
ALL_POLICIES=$(echo "$POLICIES" | grep -ic "FOR ALL" || echo "0")

finding "INFO" "M4.2" "SELECT: $SELECT_POLICIES, INSERT: $INSERT_POLICIES, UPDATE: $UPDATE_POLICIES, DELETE: $DELETE_POLICIES, ALL: $ALL_POLICIES"

# Check WITH CHECK on INSERT/UPDATE
WITH_CHECK=$(echo "$POLICIES" | grep -ic "WITH CHECK" || echo "0")
finding "INFO" "M4.2" "Policies with WITH CHECK clause: $WITH_CHECK"

if [[ "$INSERT_POLICIES" -gt 0 || "$UPDATE_POLICIES" -gt 0 ]]; then
  if [[ "$WITH_CHECK" -eq 0 ]]; then
    finding "MEDIUM" "M4.2" "INSERT/UPDATE policies found but no WITH CHECK clause — verify data is validated"
  fi
fi

# ─── M4.3: Policy Quality ───
metric_header "M4.3" "Policy Quality"

# Check for auth.uid() usage
AUTH_UID_COUNT=$(echo "$POLICIES" | grep -ic "auth\.uid()" || echo "0")
finding "INFO" "M4.3" "Policies using auth.uid(): $AUTH_UID_COUNT / $POLICY_COUNT"

# Check for auth.jwt() usage
AUTH_JWT_COUNT=$(echo "$POLICIES" | grep -ic "auth\.jwt()" || echo "0")
if [[ "$AUTH_JWT_COUNT" -gt 0 ]]; then
  finding "INFO" "M4.3" "Policies using auth.jwt(): $AUTH_JWT_COUNT"
fi

# CRITICAL: Check for USING(true) anti-pattern
USING_TRUE=$(search_migration_files "$PROJECT_ROOT" "USING\s*\(\s*true\s*\)" "-in")
if [[ -n "$USING_TRUE" ]]; then
  USING_TRUE_COUNT=$(echo "$USING_TRUE" | wc -l | tr -d ' ')
  finding "CRITICAL" "M4.3" "USING(true) found in $USING_TRUE_COUNT policies — wide-open RLS!"
  echo "$USING_TRUE" | head -5
else
  finding "INFO" "M4.3" "No USING(true) anti-pattern detected"
fi

# Check for WITH CHECK(true)
WITH_CHECK_TRUE=$(search_migration_files "$PROJECT_ROOT" "WITH CHECK\s*\(\s*true\s*\)" "-in")
if [[ -n "$WITH_CHECK_TRUE" ]]; then
  finding "HIGH" "M4.3" "WITH CHECK(true) found — anyone can insert/update"
  echo "$WITH_CHECK_TRUE" | head -3
fi

# Check for overly permissive role checks
ANON_OPEN=$(search_migration_files "$PROJECT_ROOT" "TO\s+anon" "-in" | grep -i "USING\s*(\s*true\s*)" || true)
if [[ -n "$ANON_OPEN" ]]; then
  finding "CRITICAL" "M4.3" "Anon role has USING(true) policies — public access to data!"
fi

# ─── M4.4: Service Role Separation ───
metric_header "M4.4" "Service Role Separation"

# Check for service_role key in client-side code
SERVICE_KEY_CLIENT=$(search_source_files "$PROJECT_ROOT" "NEXT_PUBLIC.*SERVICE_ROLE|service_role.*createClient|createBrowserClient.*service_role" "-rn")
if [[ -n "$SERVICE_KEY_CLIENT" ]]; then
  finding "CRITICAL" "M4.4" "service_role key possibly exposed in client-side code!"
  echo "$SERVICE_KEY_CLIENT" | head -5
else
  finding "INFO" "M4.4" "No service_role key found in client-side code"
fi

# Check for createServerClient usage (good pattern)
SERVER_CLIENT=$(search_source_files "$PROJECT_ROOT" "createServerClient" "-rl")
if [[ -n "$SERVER_CLIENT" ]]; then
  finding "INFO" "M4.4" "createServerClient detected — proper server-side client"
fi

# Check for createBrowserClient usage (good pattern)
BROWSER_CLIENT=$(search_source_files "$PROJECT_ROOT" "createBrowserClient" "-rl")
if [[ -n "$BROWSER_CLIENT" ]]; then
  finding "INFO" "M4.4" "createBrowserClient detected — proper client-side client"
fi

# Check for service_role in env files
SERVICE_ENV=$(search_config_files "$PROJECT_ROOT" "SERVICE_ROLE" "-rn" | grep -iv "NEXT_PUBLIC\|VITE_\|REACT_APP_" || true)
if [[ -n "$SERVICE_ENV" ]]; then
  finding "INFO" "M4.4" "Service role key in server-only env vars"
fi

# Public env with service role = critical
SERVICE_PUBLIC=$(search_config_files "$PROJECT_ROOT" "NEXT_PUBLIC.*SERVICE_ROLE|VITE_.*SERVICE_ROLE|REACT_APP_.*SERVICE_ROLE" "-rn")
if [[ -n "$SERVICE_PUBLIC" ]]; then
  finding "CRITICAL" "M4.4" "Service role key in PUBLIC env variable!"
  echo "$SERVICE_PUBLIC" | head -3
fi

print_summary
