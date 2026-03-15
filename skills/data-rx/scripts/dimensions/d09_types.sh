#!/usr/bin/env bash
# D9: Type Safety & Client Integration (10%)
# Scans for generated types, client typing, validation schemas, API layer separation

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

PROJECT_ROOT="${1:-.}"

section_header "D9" "Type Safety & Client Integration (10%)"

# ─── M9.1: Generated Types ───
metric_header "M9.1" "Generated Types Freshness"

TYPES_STATUS=$(check_types_freshness "$PROJECT_ROOT")
case "$TYPES_STATUS" in
  MISSING)
    finding "HIGH" "M9.1" "No generated types file found (database.types.ts / types.ts)"
    ;;
  NO_MIGRATIONS)
    finding "INFO" "M9.1" "No migrations to compare — types freshness unknown"
    ;;
  FRESH:*)
    TYPES_FILE="${TYPES_STATUS#FRESH:}"
    finding "INFO" "M9.1" "Generated types are FRESH: $TYPES_FILE"
    ;;
  STALE:*)
    TYPES_FILE="${TYPES_STATUS#STALE:}"
    finding "HIGH" "M9.1" "Generated types are STALE: $TYPES_FILE — regenerate with supabase gen types typescript"
    ;;
esac

# Check for type generation in CI/scripts
TYPE_GEN_CI=$(search_config_files "$PROJECT_ROOT" "supabase gen types|gen types typescript" "-rn")
if [[ -n "$TYPE_GEN_CI" ]]; then
  finding "INFO" "M9.1" "Type generation found in CI/scripts"
else
  finding "LOW" "M9.1" "No automated type generation step detected (CI or pre-commit)"
fi

# Check for Database type export
DB_TYPE_EXPORT=$(search_source_files "$PROJECT_ROOT" "export.*type.*Database|export.*interface.*Database" "-rn")
if [[ -n "$DB_TYPE_EXPORT" ]]; then
  finding "INFO" "M9.1" "Database type export found"
fi

# ─── M9.2: Client Typing ───
metric_header "M9.2" "Typed Supabase Client"

# Check for createClient<Database>
TYPED_CLIENT=$(search_source_files "$PROJECT_ROOT" "createClient<Database|createServerClient<Database|createBrowserClient<Database" "-rn")
if [[ -n "$TYPED_CLIENT" ]]; then
  TYPED_COUNT=$(echo "$TYPED_CLIENT" | wc -l | tr -d ' ')
  finding "INFO" "M9.2" "Typed Supabase client (with Database generic): $TYPED_COUNT instances"
else
  # Check for untyped createClient
  UNTYPED=$(search_source_files "$PROJECT_ROOT" "createClient\(|createServerClient\(|createBrowserClient\(" "-rn" | grep -v "<Database" || true)
  if [[ -n "$UNTYPED" ]]; then
    finding "MEDIUM" "M9.2" "Supabase client created WITHOUT Database type parameter"
    echo "$UNTYPED" | head -3
  fi
fi

# Check for `any` in Supabase-related code
ANY_USAGE=$(search_source_files "$PROJECT_ROOT" "as any.*supabase|supabase.*as any|: any.*from\(|data:\s*any" "-rn")
if [[ -n "$ANY_USAGE" ]]; then
  ANY_COUNT=$(echo "$ANY_USAGE" | wc -l | tr -d ' ')
  finding "MEDIUM" "M9.2" "'any' type usage near Supabase queries: $ANY_COUNT instances"
else
  finding "INFO" "M9.2" "No 'any' type casts detected near Supabase queries"
fi

# ─── M9.3: Validation Schemas ───
metric_header "M9.3" "Validation Schemas"

# Check for Zod/Valibot schemas
ZOD_USAGE=$(search_source_files "$PROJECT_ROOT" "z\.\w+\(\)|z\.object\(|z\.string\(|z\.number\(" "-rl")
VALIBOT_USAGE=$(search_source_files "$PROJECT_ROOT" "v\.\w+\(\)|object\(\{|string\(\)|number\(\)" "-rl" | grep -iv "node_modules" || true)

if [[ -n "$ZOD_USAGE" ]]; then
  ZOD_COUNT=$(echo "$ZOD_USAGE" | wc -l | tr -d ' ')
  finding "INFO" "M9.3" "Zod validation schemas detected in $ZOD_COUNT files"
elif [[ -n "$VALIBOT_USAGE" ]]; then
  finding "INFO" "M9.3" "Valibot validation detected"
else
  finding "MEDIUM" "M9.3" "No Zod/Valibot validation schemas detected"
fi

# Check for form validation integration
FORM_VAL=$(search_source_files "$PROJECT_ROOT" "zodResolver|valibotResolver|useForm.*schema|resolver.*schema" "-rl")
if [[ -n "$FORM_VAL" ]]; then
  finding "INFO" "M9.3" "Form validation with schema resolver detected"
fi

# Check for server-side validation on mutations
SERVER_VAL=$(search_source_files "$PROJECT_ROOT" "\.parse\(|\.safeParse\(|validate\(" "-rl" | head -10)
if [[ -n "$SERVER_VAL" ]]; then
  finding "INFO" "M9.3" "Schema parsing/validation detected"
fi

# ─── M9.4: API Layer Separation ───
metric_header "M9.4" "Server vs Client Supabase Separation"

SERVER_CLIENT=$(search_source_files "$PROJECT_ROOT" "createServerClient" "-rl")
BROWSER_CLIENT=$(search_source_files "$PROJECT_ROOT" "createBrowserClient" "-rl")
GENERIC_CLIENT=$(search_source_files "$PROJECT_ROOT" "createClient\b" "-rl" | grep -v "createServerClient\|createBrowserClient" || true)

SERVER_COUNT=$(echo "$SERVER_CLIENT" | grep -c . || echo "0")
BROWSER_COUNT=$(echo "$BROWSER_CLIENT" | grep -c . || echo "0")
GENERIC_COUNT=$(echo "$GENERIC_CLIENT" | grep -c . || echo "0")

finding "INFO" "M9.4" "createServerClient: $SERVER_COUNT files, createBrowserClient: $BROWSER_COUNT files, createClient: $GENERIC_COUNT files"

if [[ "$SERVER_COUNT" -gt 0 && "$BROWSER_COUNT" -gt 0 ]]; then
  finding "INFO" "M9.4" "Proper server/client separation detected"
elif [[ "$GENERIC_COUNT" -gt 0 && "$SERVER_COUNT" -eq 0 && "$BROWSER_COUNT" -eq 0 ]]; then
  finding "MEDIUM" "M9.4" "Only generic createClient used — no server/browser separation via @supabase/ssr"
fi

# Check for Supabase calls directly in UI components
COMPONENT_CALLS=$(search_source_files "$PROJECT_ROOT" "\.from\(.*\.select\(|\.from\(.*\.insert\(|\.from\(.*\.update\(|\.from\(.*\.delete\(" "-rl" | grep -E "\.(tsx|jsx)$" || true)
if [[ -n "$COMPONENT_CALLS" ]]; then
  COMP_COUNT=$(echo "$COMPONENT_CALLS" | wc -l | tr -d ' ')
  finding "LOW" "M9.4" "Direct Supabase calls in $COMP_COUNT component files — consider abstracting via hooks/actions"
fi

print_summary
