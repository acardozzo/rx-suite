#!/usr/bin/env bash
# d01-rest-design.sh — Scan REST maturity & resource design patterns
source "$(dirname "$0")/../lib/common.sh"

echo "# D01 — REST MATURITY & RESOURCE DESIGN"
echo ""

section "M1.1 Resource Naming"
echo "  Verb-in-URL violations (getX, createX, deleteX, updateX, fetchX):"
echo "    count: $(src_count_matches '(get|create|delete|update|fetch|remove|add|set)[A-Z][a-zA-Z]*['\''"]?\s*[,\)]|['\''"]/(get|create|delete|update|fetch|remove)[A-Z]')"
echo "  Route definitions: $(route_count_matches '(route|get|post|put|patch|delete|router)\s*\(')"
echo "  Plural noun routes: $(src_count_matches '['\''"]\/[a-z]+s(\/|['\''"]|\/:)')"
echo "  Singular noun routes: $(src_count_matches '['\''"]\/[a-z]+[^s](\/:|['\''"])\s*[,\)]')"
echo "  Hierarchical routes (nested resources): $(src_count_matches '['\''"]\/[a-z]+\/:[a-zA-Z]+\/[a-z]+')"
echo ""

section "M1.2 HTTP Method Semantics"
echo "  GET handlers:    $(route_count_matches '\.(get|GET)\s*\(')"
echo "  POST handlers:   $(route_count_matches '\.(post|POST)\s*\(')"
echo "  PUT handlers:    $(route_count_matches '\.(put|PUT)\s*\(')"
echo "  PATCH handlers:  $(route_count_matches '\.(patch|PATCH)\s*\(')"
echo "  DELETE handlers: $(route_count_matches '\.(delete|DELETE)\s*\(')"
echo "  @Get decorators:    $(src_count_matches '@Get\(|@api_view.*GET|@app\.get')"
echo "  @Post decorators:   $(src_count_matches '@Post\(|@api_view.*POST|@app\.post')"
echo "  @Put decorators:    $(src_count_matches '@Put\(|@api_view.*PUT|@app\.put')"
echo "  @Patch decorators:  $(src_count_matches '@Patch\(|@api_view.*PATCH|@app\.patch')"
echo "  @Delete decorators: $(src_count_matches '@Delete\(|@api_view.*DELETE|@app\.delete')"
echo ""

section "M1.3 Status Code Accuracy"
echo "  Distinct status codes used:"
for code in 200 201 202 204 301 302 304 400 401 403 404 405 409 422 429 500 502 503; do
  count=$(src_count_matches "(status\(${code}\)|statusCode.*${code}|${code}[,\)]|HttpStatus\.|\\.status.*${code}|res\.status\(${code}\)|response.*${code})" 2>/dev/null)
  [ "$count" -gt 0 ] && echo "    $code: $count occurrences"
done
echo "  200-for-everything risk (success: false in 200): $(src_count_matches 'success.*false|error.*true.*200|status.*200.*error')"
echo ""

section "M1.4 HATEOAS / Hypermedia"
echo "  Link generation patterns: $(src_count_matches 'links.*self|_links|href.*http|rel['\''\"]:.*['\''\"](self|next|prev|related)')"
echo "  Self links: $(src_count_matches 'self.*url|self.*href|links.*self')"
echo "  Pagination links (next/prev): $(src_count_matches 'next.*url|prev.*url|nextPage|prevPage|next_page|previous_page')"
echo "  HAL/JSON:API link patterns: $(src_count_matches '_embedded|_links|jsonapi|relationships')"
echo ""
