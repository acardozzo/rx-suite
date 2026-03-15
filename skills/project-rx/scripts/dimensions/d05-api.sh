#!/usr/bin/env bash
# D5: API & Integration
# M5.1 API | M5.2 Docs | M5.3 Integrations | M5.4 Developer
source "$(dirname "$0")/../lib/common.sh"

echo "## D5: API & INTEGRATION"
echo ""

# M5.1: API Surface
section "M5.1: API Surface"
e=0
c=$(src_count "(app|router)\.(get|post|put|delete|patch)\(|export.*async.*function.*(GET|POST|PUT|DELETE)|HandleFunc|@(Get|Post|Put|Delete|Patch)Mapping|@app\.(get|post|route)")
echo "  route-handler files: $c"
[ "$c" -gt 0 ] && ((e++))
[ "$c" -gt 10 ] && ((e++))
[ "$c" -gt 30 ] && ((e++))
c=$(src_count "/api/v[0-9]\|/v[0-9]/\|apiVersion\|Accept-Version")
[ "$c" -gt 0 ] && echo "  api-versioning: $c files" && ((e++))
c=$(src_count "NextResponse\.json\|res\.json\|json\.NewEncoder\|JsonResponse\|Response\.ok")
[ "$c" -gt 0 ] && echo "  response-helpers: $c files" && ((e++))
echo "  SCORE: $(component_score "API" "$e" 1 2 3 5 | head -1)"
echo ""

# M5.2: API Documentation
section "M5.2: API Documentation"
e=0
has_file "openapi*" || has_file "swagger*" && echo "  openapi-spec" && ((e++))
for lib in swagger-ui-express @nestjs/swagger swagger-jsdoc redoc; do
  has_dep "$lib" && echo "  dep: $lib" && ((e++))
done
has_route "docs\|swagger\|redoc" && echo "  route: docs" && ((e++))
c=$(src_count "@ApiOperation\|@ApiProperty\|@ApiResponse\|@api_view")
[ "$c" -gt 0 ] && echo "  api-decorators: $c files" && ((e++))
echo "  SCORE: $(component_score "Docs" "$e" 1 2 3 4 | head -1)"
echo ""

# M5.3: External Integrations
section "M5.3: External Integrations"
e=0
c=$(src_count "OAuth.*provider\|oauth2\|openid\|oidc")
[ "$c" -gt 0 ] && echo "  oauth-providers: $c files" && ((e++))
c=$(src_count "fetch\(.*https\|axios\.\|got\.\|httpClient\|HttpService\|requests\.(get|post)")
[ "$c" -gt 0 ] && echo "  http-clients: $c files" && ((e++))
[ "$c" -gt 5 ] && ((e++))
for lib in axios got @slack/web-api twilio @sendgrid openai @anthropic; do
  has_dep "$lib" && echo "  dep: $lib" && ((e++))
done
echo "  SCORE: $(component_score "Integrations" "$e" 1 3 5 7 | head -1)"
echo ""

# M5.4: Developer Platform
section "M5.4: Developer Platform"
e=0
c=$(src_count "api.*key.*model\|ApiKey.*schema\|apiKey.*table\|generate.*key")
[ "$c" -gt 0 ] && echo "  api-key-model: $c files" && ((e++))
c=$(src_count "usage.*track\|api.*usage\|rate.*limit.*per.*key\|quota")
[ "$c" -gt 0 ] && echo "  usage-tracking: $c files" && ((e++))
has_dir "developer" || has_dir "dev-portal" && echo "  dev-portal" && ((e++))
c=$(src_count "rate.*limit.*key\|per.*key.*limit\|api.*tier")
[ "$c" -gt 0 ] && echo "  per-key-limits: $c files" && ((e++))
echo "  SCORE: $(component_score "Developer" "$e" 1 2 3 4 | head -1)"
echo ""
