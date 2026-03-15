#!/usr/bin/env bash
# D4: Security Headers & Transport — OWASP Secure Headers, HSTS RFC 6797
# Scans for HTTPS enforcement, CSP, CORS, and additional security headers

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

PROJECT_ROOT="${1:-.}"
detect_stack "$PROJECT_ROOT"

section_header "D4" "Security Headers & Transport (10%)"

# ─── M4.1: HTTPS Enforcement ───
metric_header "M4.1" "HTTPS Enforcement"

# HSTS header
HSTS=$(search_source_files "$PROJECT_ROOT" "(Strict-Transport-Security|hsts|helmet\.hsts)" "-rli")
HSTS_CFG=$(search_config_files "$PROJECT_ROOT" "(Strict-Transport-Security|hsts)" "-rli")
if [[ -n "$HSTS" || -n "$HSTS_CFG" ]]; then
  finding "INFO" "M4.1" "HSTS header configuration detected"

  # Check max-age
  HSTS_AGE=$(search_source_files "$PROJECT_ROOT" "max-age=([0-9]+)" "-rn")
  if [[ -n "$HSTS_AGE" ]]; then
    finding "INFO" "M4.1" "HSTS max-age configured"
  fi

  # includeSubDomains
  HSTS_SUB=$(search_source_files "$PROJECT_ROOT" "includeSubDomains" "-rli")
  [[ -n "$HSTS_SUB" ]] && finding "INFO" "M4.1" "HSTS includeSubDomains enabled"

  # preload
  HSTS_PRE=$(search_source_files "$PROJECT_ROOT" "preload" "-rli")
  [[ -n "$HSTS_PRE" ]] && finding "INFO" "M4.1" "HSTS preload directive present"
else
  finding "HIGH" "M4.1" "No HSTS configuration detected"
fi

# HTTP redirect to HTTPS
REDIRECT=$(search_source_files "$PROJECT_ROOT" "(redirect.*https|http.*redirect|force.*ssl|forceSSL|requireHTTPS)" "-rli")
REDIRECT_CFG=$(search_config_files "$PROJECT_ROOT" "(redirect.*https|force.*ssl)" "-rli")
if [[ -n "$REDIRECT" || -n "$REDIRECT_CFG" ]]; then
  finding "INFO" "M4.1" "HTTP-to-HTTPS redirect detected"
fi

# Helmet middleware (Node.js)
HELMET=$(search_source_files "$PROJECT_ROOT" "(require.*helmet|import.*helmet|app\.use.*helmet)" "-rl")
if [[ -n "$HELMET" ]]; then
  finding "INFO" "M4.1" "Helmet security middleware detected (sets multiple headers)"
fi

# ─── M4.2: Content Security Policy ───
metric_header "M4.2" "Content Security Policy"

CSP=$(search_source_files "$PROJECT_ROOT" "(Content-Security-Policy|contentSecurityPolicy|csp)" "-rn")
CSP_NEXT=$(search_config_files "$PROJECT_ROOT" "(Content-Security-Policy|contentSecurityPolicy)" "-rn")
if [[ -n "$CSP" || -n "$CSP_NEXT" ]]; then
  finding "INFO" "M4.2" "CSP configuration detected"

  # Check for unsafe directives
  UNSAFE_INLINE=$(search_source_files "$PROJECT_ROOT" "unsafe-inline" "-rn")
  if [[ -n "$UNSAFE_INLINE" ]]; then
    while IFS= read -r line; do
      file=$(echo "$line" | cut -d: -f1)
      lineno=$(echo "$line" | cut -d: -f2)
      finding "MEDIUM" "M4.2" "CSP contains 'unsafe-inline' — weakens XSS protection" "$file" "$lineno"
    done <<< "$UNSAFE_INLINE"
  fi

  UNSAFE_EVAL=$(search_source_files "$PROJECT_ROOT" "unsafe-eval" "-rn")
  if [[ -n "$UNSAFE_EVAL" ]]; then
    while IFS= read -r line; do
      file=$(echo "$line" | cut -d: -f1)
      lineno=$(echo "$line" | cut -d: -f2)
      finding "HIGH" "M4.2" "CSP contains 'unsafe-eval' — significant XSS risk" "$file" "$lineno"
    done <<< "$UNSAFE_EVAL"
  fi

  # Check for nonce usage
  CSP_NONCE=$(search_source_files "$PROJECT_ROOT" "(nonce-|cspNonce|nonce)" "-rl")
  if [[ -n "$CSP_NONCE" ]]; then
    finding "INFO" "M4.2" "CSP nonce usage detected — strong XSS protection"
  fi
else
  finding "HIGH" "M4.2" "No Content-Security-Policy configuration detected"
fi

# ─── M4.3: CORS Configuration ───
metric_header "M4.3" "CORS Configuration"

CORS=$(search_source_files "$PROJECT_ROOT" "(cors|Access-Control-Allow-Origin|CORS)" "-rn")
if [[ -n "$CORS" ]]; then
  # Check for wildcard
  CORS_WILD=$(search_source_files "$PROJECT_ROOT" "(origin\s*:\s*['\"]?\*['\"]?|Access-Control-Allow-Origin.*\*|allow_all_origins|AllowAllOrigins)" "-rn")
  if [[ -n "$CORS_WILD" ]]; then
    while IFS= read -r line; do
      file=$(echo "$line" | cut -d: -f1)
      lineno=$(echo "$line" | cut -d: -f2)
      finding "HIGH" "M4.3" "Wildcard CORS origin — allows any domain" "$file" "$lineno"
    done <<< "$CORS_WILD"
  else
    finding "INFO" "M4.3" "CORS configured with specific origins"
  fi

  # Check credentials with wildcard
  CORS_CRED=$(search_source_files "$PROJECT_ROOT" "(credentials\s*:\s*true|Access-Control-Allow-Credentials\s*:\s*true)" "-rn")
  if [[ -n "$CORS_CRED" && -n "$CORS_WILD" ]]; then
    finding "CRITICAL" "M4.3" "CORS wildcard with credentials — severe security risk"
  fi
else
  finding "INFO" "M4.3" "No explicit CORS configuration found"
fi

# ─── M4.4: Additional Headers ───
metric_header "M4.4" "Additional Security Headers"

HEADERS_FOUND=0

# X-Frame-Options
XFRAME=$(search_source_files "$PROJECT_ROOT" "(X-Frame-Options|frameguard|frame-options)" "-rli")
XFRAME_CFG=$(search_config_files "$PROJECT_ROOT" "X-Frame-Options" "-rli")
if [[ -n "$XFRAME" || -n "$XFRAME_CFG" ]]; then
  finding "INFO" "M4.4" "X-Frame-Options header detected"
  ((HEADERS_FOUND++))
else
  finding "MEDIUM" "M4.4" "X-Frame-Options header not detected"
fi

# X-Content-Type-Options
XCTO=$(search_source_files "$PROJECT_ROOT" "(X-Content-Type-Options|noSniff|nosniff)" "-rli")
XCTO_CFG=$(search_config_files "$PROJECT_ROOT" "X-Content-Type-Options" "-rli")
if [[ -n "$XCTO" || -n "$XCTO_CFG" ]]; then
  finding "INFO" "M4.4" "X-Content-Type-Options header detected"
  ((HEADERS_FOUND++))
else
  finding "MEDIUM" "M4.4" "X-Content-Type-Options header not detected"
fi

# Referrer-Policy
REFERRER=$(search_source_files "$PROJECT_ROOT" "(Referrer-Policy|referrerPolicy)" "-rli")
REFERRER_CFG=$(search_config_files "$PROJECT_ROOT" "Referrer-Policy" "-rli")
if [[ -n "$REFERRER" || -n "$REFERRER_CFG" ]]; then
  finding "INFO" "M4.4" "Referrer-Policy header detected"
  ((HEADERS_FOUND++))
else
  finding "LOW" "M4.4" "Referrer-Policy header not detected"
fi

# Permissions-Policy
PERMS=$(search_source_files "$PROJECT_ROOT" "(Permissions-Policy|Feature-Policy|permissionsPolicy)" "-rli")
PERMS_CFG=$(search_config_files "$PROJECT_ROOT" "(Permissions-Policy|Feature-Policy)" "-rli")
if [[ -n "$PERMS" || -n "$PERMS_CFG" ]]; then
  finding "INFO" "M4.4" "Permissions-Policy header detected"
  ((HEADERS_FOUND++))
else
  finding "LOW" "M4.4" "Permissions-Policy header not detected"
fi

finding "INFO" "M4.4" "$HEADERS_FOUND/4 additional security headers configured"

print_summary
