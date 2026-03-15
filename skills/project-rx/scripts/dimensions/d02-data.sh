#!/usr/bin/env bash
# D2: Data & Storage
# M2.1 DB | M2.2 Files | M2.3 Cache | M2.4 Search
source "$(dirname "$0")/../lib/common.sh"

echo "## D2: DATA & STORAGE"
echo ""

# M2.1: Database
section "M2.1: Database"
e=0
for lib in prisma drizzle typeorm sequelize mongoose pg mysql2 @supabase/supabase-js knex mikro-orm; do
  has_dep "$lib" && echo "  dep: $lib" && ((e++))
done
has_dir "migrations" || has_dir "migrate" && echo "  migrations-dir" && ((e++))
has_file "schema.prisma" && echo "  prisma-schema" && ((e++))
has_file "drizzle.config*" && echo "  drizzle-config" && ((e++))
has_file "seed*" && echo "  seed-script" && ((e++))
c=$(src_count "createTable\|CREATE TABLE\|addColumn\|migration")
[ "$c" -gt 0 ] && echo "  migration-files: $c" && ((e++))
echo "  SCORE: $(component_score "DB" "$e" 1 3 5 7 | head -1)"
echo ""

# M2.2: File Storage
section "M2.2: File Storage"
e=0
for lib in multer formidable busboy @aws-sdk/client-s3 @google-cloud/storage sharp @uploadthing/react; do
  has_dep "$lib" && echo "  dep: $lib" && ((e++))
done
has_route "upload\|file\|attachment" && echo "  route: upload" && ((e++))
c=$(src_count "S3Client\|PutObjectCommand\|upload.*file\|getSignedUrl\|createPresignedPost")
[ "$c" -gt 0 ] && echo "  s3-usage: $c files" && ((e++))
has_env "AWS_S3\|S3_BUCKET\|STORAGE_BUCKET\|CLOUDFLARE_R2" && echo "  storage-env" && ((e++))
echo "  SCORE: $(component_score "Files" "$e" 1 2 4 6 | head -1)"
echo ""

# M2.3: Cache
section "M2.3: Cache"
e=0
for lib in redis ioredis node-cache @upstash/redis lru-cache keyv; do
  has_dep "$lib" && echo "  dep: $lib" && ((e++))
done
c=$(src_count "cache.*middleware\|cacheControl\|stale-while-revalidate\|revalidate")
[ "$c" -gt 0 ] && echo "  cache-middleware: $c files" && ((e++))
c=$(src_count "cache.*invalidat\|cache.*purge\|cache.*clear\|cache\.del")
[ "$c" -gt 0 ] && echo "  cache-invalidation: $c files" && ((e++))
has_env "REDIS_URL\|REDIS_HOST\|UPSTASH" && echo "  redis-env" && ((e++))
echo "  SCORE: $(component_score "Cache" "$e" 1 2 3 5 | head -1)"
echo ""

# M2.4: Search
section "M2.4: Search"
e=0
for lib in @elastic/elasticsearch @opensearch algoliasearch meilisearch typesense; do
  has_dep "$lib" && echo "  dep: $lib" && ((e++))
done
c=$(src_count "full.*text.*search\|textsearch\|@@fulltext\|to_tsvector\|MATCH.*AGAINST")
[ "$c" -gt 0 ] && echo "  fts-queries: $c files" && ((e++))
has_route "search" && echo "  route: search" && ((e++))
has_env "ALGOLIA\|MEILISEARCH\|ELASTIC\|TYPESENSE" && echo "  search-env" && ((e++))
echo "  SCORE: $(component_score "Search" "$e" 1 2 3 5 | head -1)"
echo ""
