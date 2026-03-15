#!/usr/bin/env bash
# D6: Supabase Auth Integration (10%)
# Scans for auth setup, user metadata, auth hooks, session management

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

PROJECT_ROOT="${1:-.}"

section_header "D6" "Supabase Auth Integration (10%)"

SB_DIR=$(find_supabase_dir "$PROJECT_ROOT")

# ─── M6.1: Auth Setup ───
metric_header "M6.1" "Auth Setup & Configuration"

# Check config.toml for auth settings
if [[ -n "$SB_DIR" && -f "$SB_DIR/config.toml" ]]; then
  finding "INFO" "M6.1" "Supabase config.toml found"

  # Check for auth provider config
  AUTH_PROVIDERS=$(grep -E "\[auth\.(external_)?[a-z]+\]" "$SB_DIR/config.toml" 2>/dev/null || true)
  if [[ -n "$AUTH_PROVIDERS" ]]; then
    PROVIDER_COUNT=$(echo "$AUTH_PROVIDERS" | wc -l | tr -d ' ')
    finding "INFO" "M6.1" "Auth providers configured: $PROVIDER_COUNT"
    echo "$AUTH_PROVIDERS" | head -5
  fi

  # Check email templates
  EMAIL_TEMPLATE=$(grep -i "template" "$SB_DIR/config.toml" 2>/dev/null | grep -i "email" || true)
  if [[ -n "$EMAIL_TEMPLATE" ]]; then
    finding "INFO" "M6.1" "Custom email templates referenced in config"
  fi
else
  finding "MEDIUM" "M6.1" "No supabase/config.toml found — default auth configuration"
fi

# Check for Supabase Auth usage in code
AUTH_USAGE=$(search_source_files "$PROJECT_ROOT" "supabase\.auth\.|signInWith|signUp|signOut|onAuthStateChange" "-rl")
if [[ -n "$AUTH_USAGE" ]]; then
  AUTH_FILES=$(echo "$AUTH_USAGE" | wc -l | tr -d ' ')
  finding "INFO" "M6.1" "Supabase Auth usage found in $AUTH_FILES files"
else
  # Check for custom auth
  CUSTOM_AUTH=$(search_source_files "$PROJECT_ROOT" "bcrypt|jsonwebtoken|jwt\.sign|passport\.|next-auth|lucia|clerk" "-rl")
  if [[ -n "$CUSTOM_AUTH" ]]; then
    finding "HIGH" "M6.1" "Custom auth library detected instead of Supabase Auth"
    echo "$CUSTOM_AUTH" | head -3
  else
    finding "MEDIUM" "M6.1" "No auth implementation detected"
  fi
fi

# ─── M6.2: User Metadata & Profiles ───
metric_header "M6.2" "User Metadata & Profiles Table"

# Check for profiles table
PROFILES_TABLE=$(search_migration_files "$PROJECT_ROOT" "CREATE TABLE.*profiles" "-in")
if [[ -n "$PROFILES_TABLE" ]]; then
  finding "INFO" "M6.2" "Profiles table found in migrations"

  # Check FK to auth.users
  PROFILES_FK=$(search_migration_files "$PROJECT_ROOT" "profiles.*REFERENCES.*auth\.users|FOREIGN KEY.*auth\.users" "-in")
  if [[ -n "$PROFILES_FK" ]]; then
    finding "INFO" "M6.2" "Profiles table has FK to auth.users"
  else
    finding "MEDIUM" "M6.2" "Profiles table may lack FK to auth.users"
  fi

  # Check RLS on profiles
  PROFILES_RLS=$(search_migration_files "$PROJECT_ROOT" "ENABLE ROW LEVEL SECURITY.*profiles|profiles.*ENABLE ROW LEVEL SECURITY" "-in")
  if [[ -n "$PROFILES_RLS" ]]; then
    finding "INFO" "M6.2" "RLS enabled on profiles table"
  else
    finding "HIGH" "M6.2" "RLS not detected on profiles table"
  fi
else
  finding "MEDIUM" "M6.2" "No profiles table found — user data may be in auth.users metadata only"
fi

# ─── M6.3: Auth Hooks & Triggers ───
metric_header "M6.3" "Auth Hooks & Triggers"

# Check for handle_new_user function
HANDLE_NEW_USER=$(search_migration_files "$PROJECT_ROOT" "handle_new_user|on_auth_user_created" "-in")
if [[ -n "$HANDLE_NEW_USER" ]]; then
  finding "INFO" "M6.3" "handle_new_user / on_auth_user_created function found"
else
  finding "MEDIUM" "M6.3" "No handle_new_user trigger function found"
fi

# Check for trigger on auth.users
AUTH_TRIGGER=$(search_migration_files "$PROJECT_ROOT" "CREATE TRIGGER.*auth\.users|AFTER INSERT ON auth\.users" "-in")
if [[ -n "$AUTH_TRIGGER" ]]; then
  finding "INFO" "M6.3" "Trigger on auth.users INSERT detected"
else
  finding "MEDIUM" "M6.3" "No trigger on auth.users — profile creation may rely on client code"
fi

# Check if trigger is in migrations (not manual)
if [[ -n "$AUTH_TRIGGER" ]]; then
  finding "INFO" "M6.3" "Auth trigger is defined in migration files"
fi

# ─── M6.4: Session Management ───
metric_header "M6.4" "Session Management"

# Check for onAuthStateChange
AUTH_STATE=$(search_source_files "$PROJECT_ROOT" "onAuthStateChange" "-rl")
if [[ -n "$AUTH_STATE" ]]; then
  AUTH_STATE_COUNT=$(echo "$AUTH_STATE" | wc -l | tr -d ' ')
  finding "INFO" "M6.4" "onAuthStateChange listeners: $AUTH_STATE_COUNT files"
else
  finding "MEDIUM" "M6.4" "No onAuthStateChange handler detected — auth state may not be tracked"
fi

# Check for getSession / getUser
GET_SESSION=$(search_source_files "$PROJECT_ROOT" "getSession|getUser|auth\.refreshSession" "-rl")
if [[ -n "$GET_SESSION" ]]; then
  finding "INFO" "M6.4" "Session/user retrieval patterns detected"
fi

# Check for MFA
MFA=$(search_source_files "$PROJECT_ROOT" "mfa|enrollFactor|challengeAndVerify|totp" "-rl")
if [[ -n "$MFA" ]]; then
  finding "INFO" "M6.4" "MFA implementation detected"
fi

# Check JWT config in config.toml
if [[ -n "$SB_DIR" && -f "$SB_DIR/config.toml" ]]; then
  JWT_CONFIG=$(grep -i "jwt\|expiry\|token" "$SB_DIR/config.toml" 2>/dev/null || true)
  if [[ -n "$JWT_CONFIG" ]]; then
    finding "INFO" "M6.4" "JWT/token configuration in config.toml"
  fi
fi

print_summary
