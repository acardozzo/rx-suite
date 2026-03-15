#!/usr/bin/env bash
# D1: Communication & Protocol Fitness
# M1.1 Sync Chain Depth | M1.2 Protocol Fit | M1.3 API Gateway | M1.4 Contract Evolution
source "$(dirname "$0")/../lib/common.sh"

echo "## D1: COMMUNICATION & PROTOCOL FITNESS"
echo ""

# M1.1: Sync chain depth
section "M1.1: Import graph / sync chain depth"
if has_tool madge && [ "$STACK" = "node" ]; then
  echo "Longest import chains (madge):"
  madge "$TARGET_ABS" --json 2>/dev/null | python3 -c "
import json,sys
try:
  g=json.load(sys.stdin)
  def depth(n,seen=set()):
    if n in seen: return 0
    seen.add(n)
    return 1+max((depth(d,seen.copy()) for d in g.get(n,[])),default=0)
  depths=[(k,depth(k)) for k in g]
  depths.sort(key=lambda x:-x[1])
  for f,d in depths[:10]: print(f'  depth={d}: {f}')
except: print('  (analysis failed)')
" 2>/dev/null || echo "  (python analysis unavailable)"
else
  echo "  madge not available — listing entry points for manual trace:"
  src_list "(app\.(get|post|put|delete|use)|router\.(get|post|put|delete)|createServer|listen\()" 10
fi
echo ""

# M1.2: Protocol inventory
section "M1.2: Protocol inventory"
echo "HTTP routes:"
src_list "(app\.(get|post|put|delete|patch|use)|router\.(get|post|put|delete)|@(Get|Post|Put|Delete|Patch|RequestMapping)|HandleFunc|http\.Handle|@app\.(get|post|route)|\.MapGet|\.MapPost)" 20
echo ""
echo "WebSocket:"
src_list "(websocket|ws\.|socket\.io|@WebSocket|gorilla/websocket|channels\.)" 10
echo ""
echo "SSE:"
src_list "(text/event-stream|EventSource|ServerSentEvent|sse-starlette)" 10
echo ""
echo "gRPC:"
find "$ROOT" -name "*.proto" -type f 2>/dev/null | head -10
echo ""
echo "GraphQL:"
find "$ROOT" -type f \( -name "*.graphql" -o -name "*.gql" \) 2>/dev/null | head -10
src_list "(typeDefs|@Query|@Mutation|buildSchema|makeExecutableSchema)" 10
echo ""

# M1.3: API Gateway
section "M1.3: API Gateway & edge patterns"
find "$ROOT" -type f \( -name "nginx.conf" -o -name "traefik.*" -o -name "envoy.*" -o -name "kong.*" -o -name "gateway.*" -o -name "apisix.*" \) 2>/dev/null | head -10
echo "Rate limiting:"
src_list "(rate.?limit|throttle|express-rate-limit|@Throttle|slowapi|governor|rate_limiter)" 5
echo ""

# M1.4: Contract evolution
section "M1.4: Contract evolution & versioning"
src_list "(/v[0-9]+/|/api/v[0-9]|version.*header|Accept-Version)" 10
echo "Contract test tools:"
find "$ROOT" -type f \( -name "pact*" -o -name ".pactrc" -o -name "dredd.*" -o -name "schemathesis*" \) 2>/dev/null | head -5
grep -rl "pact\|@pact-foundation\|dredd\|schemathesis" "$ROOT/package.json" "$ROOT/requirements.txt" "$ROOT/go.mod" 2>/dev/null | head -3
echo ""
