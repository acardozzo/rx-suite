#!/usr/bin/env bash
# D5: Data Architecture & Flow
# M5.1 Storage Fit | M5.2 Data Flow | M5.3 Schema Evolution | M5.4 Distributed Tx
source "$(dirname "$0")/../lib/common.sh"

echo "## D5: DATA ARCHITECTURE & FLOW"
echo ""

# M5.1: Storage fit
section "M5.1: Data stores detected"
for store in postgres mysql mongodb dynamodb redis elasticsearch opensearch neo4j influxdb timescale sqlite supabase prisma typeorm sequelize drizzle qdrant pinecone weaviate; do
  count=$(src_list "$store" 999 | wc -l | tr -d ' ')
  [ "$count" -gt 0 ] && echo "  $store: $count files"
done
echo ""

# M5.2: Data flow / ownership
section "M5.2: Data flow & ownership"
if has_tool madge && [ "$STACK" = "node" ]; then
  echo "Cross-layer data imports (madge):"
  madge "$TARGET_ABS" --json 2>/dev/null | python3 -c "
import json,sys
try:
  g=json.load(sys.stdin)
  violations=[]
  for src,deps in g.items():
    for dep in deps:
      if '/db' in dep or '/model' in dep or '/schema' in dep or '/entity' in dep:
        if '/db' not in src and '/model' not in src and '/repository' not in src:
          violations.append(f'  {src} -> {dep}')
  print(f'Direct DB/model access from non-data layers: {len(violations)}')
  for v in violations[:15]: print(v)
except: print('  (analysis failed)')
" 2>/dev/null || echo "  (unavailable)"
else
  echo "  madge not available — manual ownership analysis required"
fi
echo ""

# M5.3: Schema evolution
section "M5.3: Schema evolution & migration"
echo "Migration files:"
find "$ROOT" -type f \( -name "*.sql" -o -name "*migration*" \) -path "*/migration*" 2>/dev/null | wc -l | xargs echo "  Count:"
find "$ROOT" -type d \( -name "migrations" -o -name "migrate" -o -name "migration" -o -name "supabase" \) 2>/dev/null | head -5
echo "Migration tool:"
grep -rl "flyway\|liquibase\|knex.*migrate\|prisma.*migrate\|alembic\|django.*migrate\|golang-migrate\|goose\|refinery" \
  "$ROOT/package.json" "$ROOT/go.mod" "$ROOT/requirements.txt" "$ROOT/pom.xml" 2>/dev/null | head -3
echo ""

# M5.4: Distributed transaction patterns
section "M5.4: Distributed transaction patterns"
src_list "(saga|compensat|outbox|transactional.?outbox|two.?phase|2pc|eventual.?consist|choreograph)" 10
echo ""
