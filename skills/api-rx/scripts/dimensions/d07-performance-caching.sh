#!/usr/bin/env bash
# d07-performance-caching.sh — Scan performance & caching DX patterns
source "$(dirname "$0")/../lib/common.sh"

echo "# D07 — PERFORMANCE & CACHING DX"
echo ""

section "M7.1 Cache Headers"
echo "  Cache-Control headers: $(src_count_matches 'Cache-Control|cache-control|cacheControl')"
echo "  ETag headers: $(src_count_matches 'ETag|etag|Etag')"
echo "  Last-Modified headers: $(src_count_matches 'Last-Modified|last-modified|lastModified')"
echo "  Vary header: $(src_count_matches 'Vary|vary.*header')"
echo "  Cache middleware: $(src_count_files 'cacheMiddleware|CacheInterceptor|cache.*middleware|@CacheKey|@CacheTTL')"
echo "  no-cache/no-store usage: $(src_count_matches 'no-cache|no-store|must-revalidate')"
echo ""

section "M7.2 Conditional Requests"
echo "  If-None-Match handling: $(src_count_matches 'If-None-Match|if-none-match|ifNoneMatch')"
echo "  If-Modified-Since handling: $(src_count_matches 'If-Modified-Since|if-modified-since|ifModifiedSince')"
echo "  If-Match (optimistic concurrency): $(src_count_matches 'If-Match|if-match|ifMatch|optimistic.*lock')"
echo "  304 Not Modified responses: $(src_count_matches '304|NOT_MODIFIED|NotModified')"
echo ""

section "M7.3 Bulk Operations"
echo "  Batch endpoints: $(src_count_matches 'batch|bulk|/batch|/bulk|BatchRequest|BulkOperation')"
echo "  Multi-resource operations: $(src_count_matches 'createMany|updateMany|deleteMany|insertMany|bulkCreate|bulkUpdate')"
echo "  Partial success handling: $(src_count_matches 'partial.*success|results\[|per.*item.*status|errors\[.*index')"
echo "  Streaming responses: $(src_count_matches 'stream|Stream|pipe\(res|readable.*stream|ndjson|text/event-stream')"
echo ""

section "M7.4 Response Time & Payload Optimization"
echo "  Compression middleware: $(src_count_matches 'compression|gzip|brotli|deflate|Content-Encoding')"
echo "  Field selection support: $(src_count_matches 'fields=|select\(|\.select\b|sparseFields|\$select')"
echo "  Relation expansion/include: $(src_count_matches 'include=|expand=|populate\(|\.include\(|relations=|embed=')"
echo "  Response size limits: $(src_count_matches 'maxSize|max.*payload|payload.*limit|body.*limit')"
echo "  Lazy loading relations: $(src_count_matches 'lazy.*load|LazyLoading|onDemand|expand.*false')"
echo ""
