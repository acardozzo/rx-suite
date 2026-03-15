#!/usr/bin/env bash
# D2: Authentication & Session — OWASP A07:2021, ASVS V2/V3
# Scans for password handling, session management, JWT security, and MFA support

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

PROJECT_ROOT="${1:-.}"
detect_stack "$PROJECT_ROOT"

section_header "D2" "Authentication & Session (15%)"

# ─── M2.1: Password Handling ───
metric_header "M2.1" "Password Handling"

# Check for proper hashing libraries
BCRYPT=$(search_source_files "$PROJECT_ROOT" "(bcrypt|argon2|scrypt|pbkdf2)" "-rl")
if [[ -n "$BCRYPT" ]]; then
  finding "INFO" "M2.1" "Adaptive hashing library detected (bcrypt/argon2/scrypt)"
else
  # Check for weak hashing
  WEAK_HASH=$(search_source_files "$PROJECT_ROOT" "(md5|sha1|sha256)\s*\(.*password" "-rni")
  if [[ -n "$WEAK_HASH" ]]; then
    while IFS= read -r line; do
      file=$(echo "$line" | cut -d: -f1)
      lineno=$(echo "$line" | cut -d: -f2)
      finding "CRITICAL" "M2.1" "Weak hash algorithm used for passwords" "$file" "$lineno"
    done <<< "$WEAK_HASH"
  fi
fi

# Plaintext password storage patterns
PLAINTEXT_PW=$(search_source_files "$PROJECT_ROOT" \
  "(password\s*[:=]\s*['\"]|\.password\s*=\s*req\.|password.*plaintext|store.*password.*plain)" \
  "-rni")
if [[ -n "$PLAINTEXT_PW" ]]; then
  while IFS= read -r line; do
    file=$(echo "$line" | cut -d: -f1)
    lineno=$(echo "$line" | cut -d: -f2)
    finding "HIGH" "M2.1" "Possible plaintext password handling" "$file" "$lineno"
  done <<< "$PLAINTEXT_PW"
fi

# Password strength validation
PW_STRENGTH=$(search_source_files "$PROJECT_ROOT" "(password.*length|password.*regex|password.*strong|zxcvbn|password-validator|PasswordValidator)" "-rli")
if [[ -n "$PW_STRENGTH" ]]; then
  finding "INFO" "M2.1" "Password strength validation detected"
else
  finding "MEDIUM" "M2.1" "No password strength validation detected"
fi

# ─── M2.2: Session Management ───
metric_header "M2.2" "Session Management"

# Cookie security flags
HTTPONLY=$(search_source_files "$PROJECT_ROOT" "httpOnly\s*:\s*true|httponly\s*=\s*True|http_only.*true" "-rli")
SECURE_FLAG=$(search_source_files "$PROJECT_ROOT" "secure\s*:\s*true|secure\s*=\s*True" "-rli")
SAMESITE=$(search_source_files "$PROJECT_ROOT" "(sameSite|samesite|same_site)\s*[:=]\s*['\"]?(Strict|Lax|strict|lax)" "-rli")

[[ -z "$HTTPONLY" ]] && finding "HIGH" "M2.2" "No httpOnly cookie flag detected"
[[ -n "$HTTPONLY" ]] && finding "INFO" "M2.2" "httpOnly cookie flag detected"
[[ -z "$SECURE_FLAG" ]] && finding "HIGH" "M2.2" "No secure cookie flag detected"
[[ -n "$SECURE_FLAG" ]] && finding "INFO" "M2.2" "Secure cookie flag detected"
[[ -z "$SAMESITE" ]] && finding "MEDIUM" "M2.2" "No sameSite cookie attribute detected"
[[ -n "$SAMESITE" ]] && finding "INFO" "M2.2" "SameSite cookie attribute detected"

# Session expiry
SESSION_EXPIRY=$(search_source_files "$PROJECT_ROOT" "(maxAge|max_age|expires|expiresIn|session.*timeout|session.*expir)" "-rli")
if [[ -z "$SESSION_EXPIRY" ]]; then
  finding "MEDIUM" "M2.2" "No session expiry configuration detected"
else
  finding "INFO" "M2.2" "Session expiry configuration detected"
fi

# Session regeneration
SESSION_REGEN=$(search_source_files "$PROJECT_ROOT" "(regenerate|regenerateId|session\.destroy|session_regenerate)" "-rli")
if [[ -n "$SESSION_REGEN" ]]; then
  finding "INFO" "M2.2" "Session regeneration detected"
fi

# ─── M2.3: JWT Security ───
metric_header "M2.3" "JWT Security"

# JWT library usage
JWT_LIB=$(search_source_files "$PROJECT_ROOT" "(jsonwebtoken|jose|jwt|PyJWT|java-jwt|golang-jwt)" "-rl")
if [[ -n "$JWT_LIB" ]]; then
  finding "INFO" "M2.3" "JWT library detected"

  # Algorithm pinning
  ALG_NONE=$(search_source_files "$PROJECT_ROOT" "(algorithms.*none|alg.*none|algorithm.*none)" "-rni")
  if [[ -n "$ALG_NONE" ]]; then
    while IFS= read -r line; do
      file=$(echo "$line" | cut -d: -f1)
      lineno=$(echo "$line" | cut -d: -f2)
      finding "CRITICAL" "M2.3" "JWT algorithm 'none' may be accepted" "$file" "$lineno"
    done <<< "$ALG_NONE"
  fi

  ALG_PIN=$(search_source_files "$PROJECT_ROOT" "(algorithms\s*:\s*\[|algorithm\s*[:=]\s*['\"]RS256|algorithm\s*[:=]\s*['\"]ES256)" "-rli")
  if [[ -z "$ALG_PIN" ]]; then
    finding "MEDIUM" "M2.3" "No JWT algorithm pinning detected"
  else
    finding "INFO" "M2.3" "JWT algorithm pinning detected"
  fi

  # JWT expiry
  JWT_EXP=$(search_source_files "$PROJECT_ROOT" "(expiresIn|exp\s*:|nbf|iat)" "-rl")
  if [[ -z "$JWT_EXP" ]]; then
    finding "HIGH" "M2.3" "No JWT expiry claim detected"
  fi

  # Hardcoded JWT secrets
  JWT_SECRET=$(search_source_files "$PROJECT_ROOT" "(jwt.*secret\s*[:=]\s*['\"][^'\"]{5,}|JWT_SECRET\s*=\s*['\"][^'\"]{5,})" "-rn")
  if [[ -n "$JWT_SECRET" ]]; then
    while IFS= read -r line; do
      file=$(echo "$line" | cut -d: -f1)
      lineno=$(echo "$line" | cut -d: -f2)
      finding "CRITICAL" "M2.3" "Hardcoded JWT secret in source code" "$file" "$lineno"
    done <<< "$JWT_SECRET"
  fi

  # Refresh token rotation
  REFRESH=$(search_source_files "$PROJECT_ROOT" "(refresh.*token|refreshToken|token.*rotation|rotate.*token)" "-rli")
  if [[ -z "$REFRESH" ]]; then
    finding "MEDIUM" "M2.3" "No refresh token rotation pattern detected"
  else
    finding "INFO" "M2.3" "Refresh token pattern detected"
  fi
else
  finding "INFO" "M2.3" "No JWT library detected — may use session-based auth"
fi

# ─── M2.4: MFA Support ───
metric_header "M2.4" "MFA Support"

MFA=$(search_source_files "$PROJECT_ROOT" "(totp|otpauth|speakeasy|pyotp|google-authenticator|webauthn|fido2|two.factor|2fa|mfa|multi.factor)" "-rli")
if [[ -n "$MFA" ]]; then
  finding "INFO" "M2.4" "MFA implementation detected"

  RECOVERY=$(search_source_files "$PROJECT_ROOT" "(recovery.*code|backup.*code|recovery.*key)" "-rli")
  if [[ -n "$RECOVERY" ]]; then
    finding "INFO" "M2.4" "Recovery codes detected"
  else
    finding "LOW" "M2.4" "No recovery code mechanism detected for MFA"
  fi
else
  finding "MEDIUM" "M2.4" "No MFA implementation detected"
fi

print_summary
