#!/usr/bin/env bash
# D7: Security & Compliance
# M7.1 Validation | M7.2 Headers | M7.3 Secrets | M7.4 Audit
source "$(dirname "$0")/../lib/common.sh"

echo "## D7: SECURITY & COMPLIANCE"
echo ""

# M7.1: Input Validation
section "M7.1: Input Validation & Sanitization"
e=0
c=$(src_count "z\.object\|z\.string\|Joi\.\|yup\.\|@IsString\|@IsNotEmpty\|class-validator")
[ "$c" -gt 0 ] && echo "  validation-schemas: $c files" && ((e++))
[ "$c" -gt 5 ] && ((e++))
c=$(src_count "DOMPurify\|sanitize\|xss\|escape.*html\|bleach")
[ "$c" -gt 0 ] && echo "  sanitization: $c files" && ((e++))
for lib in helmet csurf express-validator; do
  has_dep "$lib" && echo "  dep: $lib" && ((e++))
done
c=$(src_count "sql.*inject\|parameterized\|prepared.*statement\|\\\$[0-9]")
[ "$c" -gt 0 ] && echo "  param-queries: $c files" && ((e++))
echo "  SCORE: $(component_score "Validation" "$e" 1 2 4 6 | head -1)"
echo ""

# M7.2: Security Headers
section "M7.2: Security Headers & Transport"
e=0
for lib in helmet next-secure-headers; do
  has_dep "$lib" && echo "  dep: $lib" && ((e++))
done
c=$(src_count "Content-Security-Policy\|contentSecurityPolicy\|csp")
[ "$c" -gt 0 ] && echo "  CSP: $c files" && ((e++))
c=$(src_count "cors\|Access-Control-Allow\|@CrossOrigin\|allowedOrigins")
[ "$c" -gt 0 ] && echo "  CORS: $c files" && ((e++))
c=$(src_count "Strict-Transport-Security\|hsts\|X-Frame-Options\|X-Content-Type")
[ "$c" -gt 0 ] && echo "  security-headers: $c files" && ((e++))
echo "  SCORE: $(component_score "Headers" "$e" 1 2 3 4 | head -1)"
echo ""

# M7.3: Secret Management
section "M7.3: Secret Management"
e=0
has_file ".env.example" && echo "  .env.example exists" && ((e++))
has_file ".env.local.example" && echo "  .env.local.example" && ((e++))
c=$(src_count "vault\|infisical\|doppler\|1password.*cli\|aws.*secrets.*manager")
[ "$c" -gt 0 ] && echo "  vault-integration: $c files" && ((e++))
has_file ".gitignore" && grep -q "\.env" "$ROOT/.gitignore" 2>/dev/null && echo "  .env in gitignore" && ((e++))
# Check for hardcoded secrets (negative signal)
c=$(src_count "sk_live_\|sk_test_\|ghp_\|AKIA[0-9A-Z]")
[ "$c" -gt 0 ] && echo "  WARNING: possible hardcoded secrets in $c files"
echo "  SCORE: $(component_score "Secrets" "$e" 1 2 3 4 | head -1)"
echo ""

# M7.4: Audit Trail
section "M7.4: Audit Trail"
e=0
c=$(src_count "audit.*log\|audit.*trail\|AuditLog\|audit_log\|audit.*event")
[ "$c" -gt 0 ] && echo "  audit-log: $c files" && ((e++))
c=$(src_count "audit.*middleware\|log.*action\|trackActivity\|activityLog")
[ "$c" -gt 0 ] && echo "  audit-middleware: $c files" && ((e++))
c=$(src_count "who.*did.*what\|performed_by\|actor_id\|changed_by\|user.*action")
[ "$c" -gt 0 ] && echo "  actor-tracking: $c files" && ((e++))
has_file "audit*" && echo "  audit-table/model" && ((e++))
echo "  SCORE: $(component_score "Audit" "$e" 1 2 3 4 | head -1)"
echo ""
