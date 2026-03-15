#!/usr/bin/env bash
# d04-auth-ratelimit.sh — Scan authentication & rate limiting DX patterns
source "$(dirname "$0")/../lib/common.sh"

echo "# D04 — AUTHENTICATION & RATE LIMITING DX"
echo ""

section "M4.1 Auth Flow Clarity"
echo "  Auth middleware files: $(src_count_files 'auth.*middleware|authenticate|requireAuth|isAuthenticated|authGuard|AuthGuard')"
echo "  OAuth/OIDC patterns: $(src_count_matches 'oauth|oidc|openid|authorization_code|client_credentials|pkce|PKCE')"
echo "  JWT usage: $(src_count_matches 'jwt|jsonwebtoken|jose|JWT|JsonWebToken|bearer')"
echo "  Token refresh: $(src_count_matches 'refresh.*token|token.*refresh|refreshToken|rotate.*token')"
echo "  Scopes/permissions: $(src_count_matches 'scope|permission|rbac|role.*guard|authorize|@Roles|@Permissions')"
echo "  Auth documentation:"
eval find '"$ROOT"' -maxdepth 4 -type f \( -iname "'*auth*doc*'" -o -iname "'*auth*readme*'" \) "$EXCLUDE_PATHS" 2>/dev/null | head -3 | sed 's/^/    /'
echo ""

section "M4.2 Rate Limit Headers"
echo "  Rate limit middleware: $(src_count_files 'rateLimit|rate-limit|rateLimiter|throttle|Throttle|ThrottlerGuard')"
echo "  X-RateLimit headers: $(src_count_matches 'X-RateLimit|x-ratelimit|RateLimit-Limit|RateLimit-Remaining|RateLimit-Reset')"
echo "  Retry-After header: $(src_count_matches 'Retry-After|retry-after|retryAfter')"
echo "  429 status code: $(src_count_matches '429|TOO_MANY_REQUESTS|TooManyRequests')"
echo "  Rate limit config:"
src_list 'rateLimit|rate.limit|throttle' 5 2>/dev/null | sed 's/^/    /'
echo ""

section "M4.3 API Key Management"
echo "  API key handling: $(src_count_matches 'apiKey|api_key|API_KEY|x-api-key|X-Api-Key')"
echo "  Key rotation: $(src_count_matches 'rotate.*key|key.*rotation|regenerate.*key')"
echo "  Key scoping: $(src_count_matches 'key.*scope|scope.*key|apiKey.*permission')"
echo "  Environment separation: $(src_count_matches 'test.*key|prod.*key|sandbox.*key|live.*key')"
echo ""

section "M4.4 Error UX for Auth Failures"
echo "  401 Unauthorized: $(src_count_matches '401|UNAUTHORIZED|Unauthorized')"
echo "  403 Forbidden: $(src_count_matches '403|FORBIDDEN|Forbidden')"
echo "  WWW-Authenticate header: $(src_count_matches 'WWW-Authenticate|www-authenticate')"
echo "  Auth error messages: $(src_count_matches 'invalid.*token|expired.*token|insufficient.*permission|access.*denied')"
echo ""
