#!/usr/bin/env bash
# d08-documentation.sh — Scan documentation & developer experience patterns
source "$(dirname "$0")/../lib/common.sh"

echo "# D08 — DOCUMENTATION & DEVELOPER EXPERIENCE"
echo ""

section "M8.1 Interactive Documentation"
echo "  Swagger UI setup: $(src_count_matches 'swagger-ui|SwaggerUI|swaggerUi|swagger_ui|@nestjs/swagger')"
echo "  Redoc setup: $(src_count_matches 'redoc|Redoc|ReDoc')"
echo "  API doc config files:"
eval find '"$ROOT"' -maxdepth 4 -type f \( -iname "'*swagger*config*'" -o -iname "'*redoc*'" -o -iname "'*swagger-ui*'" \) "$EXCLUDE_PATHS" 2>/dev/null | head -5 | sed 's/^/    /'
echo "  Try-it / playground: $(src_count_matches 'tryItOut|try.it|playground|apiExplorer')"
echo "  Doc hosting config: $(src_count_files 'docsSite|apiDocs|docsUrl|api.*portal')"
echo ""

section "M8.2 Code Examples"
echo "  Curl examples: $(src_count_matches 'curl|CURL|curl -X')"
echo "  Multi-language examples:"
eval find '"$ROOT"' -maxdepth 5 -type d \( -iname "'examples'" -o -iname "'samples'" -o -iname "'snippets'" \) "$EXCLUDE_PATHS" 2>/dev/null | head -3 | sed 's/^/    /'
echo "  SDK quickstart files: $(eval find '"$ROOT"' -maxdepth 4 -type f \( -iname "'*quickstart*'" -o -iname "'*getting-started*'" \) "$EXCLUDE_PATHS" 2>/dev/null | wc -l | tr -d ' ')"
echo "  Postman collection: $(eval find '"$ROOT"' -maxdepth 4 -type f -iname "'*postman*'" "$EXCLUDE_PATHS" 2>/dev/null | wc -l | tr -d ' ')"
echo "  Insomnia workspace: $(eval find '"$ROOT"' -maxdepth 4 -type f -iname "'*insomnia*'" "$EXCLUDE_PATHS" 2>/dev/null | wc -l | tr -d ' ')"
echo ""

section "M8.3 Getting Started Guide"
echo "  Getting started docs:"
eval find '"$ROOT"' -maxdepth 4 -type f \( -iname "'*getting*started*'" -o -iname "'*quickstart*'" -o -iname "'*quick-start*'" \) "$EXCLUDE_PATHS" 2>/dev/null | head -3 | sed 's/^/    /'
echo "  README with API usage: $(eval find '"$ROOT"' -maxdepth 2 -type f -iname "'readme*'" "$EXCLUDE_PATHS" 2>/dev/null | wc -l | tr -d ' ')"
echo "  Sandbox/test environment: $(src_count_matches 'sandbox|SANDBOX|test.*environment|staging.*api')"
echo "  Demo/seed scripts: $(eval find '"$ROOT"' -maxdepth 4 -type f \( -iname "'*seed*'" -o -iname "'*demo*'" \) "$EXCLUDE_PATHS" 2>/dev/null | wc -l | tr -d ' ')"
echo ""

section "M8.4 Error Catalog"
echo "  Error catalog/dictionary files:"
eval find '"$ROOT"' -maxdepth 4 -type f \( -iname "'*error*catalog*'" -o -iname "'*error*codes*'" -o -iname "'*error*dictionary*'" -o -iname "'*error*reference*'" \) "$EXCLUDE_PATHS" 2>/dev/null | head -3 | sed 's/^/    /'
echo "  Error code definitions: $(src_count_files 'ErrorCode|ERROR_CODES|errorCodes|error_codes')"
echo "  Error documentation: $(src_count_matches '@description.*error|error.*description|error.*documentation|error.*help')"
echo "  Fix suggestions in errors: $(src_count_matches 'suggestion|fix.*hint|how.*to.*fix|resolution|remediation')"
echo ""
