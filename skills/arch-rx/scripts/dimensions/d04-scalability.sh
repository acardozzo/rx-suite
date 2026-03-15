#!/usr/bin/env bash
# D4: Scalability & Performance Patterns
# M4.1 Caching | M4.2 Pooling | M4.3 Parallelism | M4.4 Horizontal
source "$(dirname "$0")/../lib/common.sh"

echo "## D4: SCALABILITY & PERFORMANCE PATTERNS"
echo ""

# M4.1: Caching
section "M4.1: Caching strategy"
echo "In-process (L1):"
src_list "(lru.?cache|node-cache|Map\(\)|bigcache|ristretto|caffeine|moka|cachetools|MemoryCache|LazyCache)" 10
echo "Distributed (L2):"
src_list "(ioredis|redis|memcached|@Cacheable|Redisson|aiocache|StackExchange\.Redis)" 10
echo "TTL / invalidation:"
src_list "(ttl|expire|invalidat|cache.?bust|cache.?warm|EX [0-9]|setex)" 10
echo ""

# M4.2: Connection pooling
section "M4.2: Connection pooling"
src_list "(pool|poolSize|max_connections|connectionLimit|HikariPool|pgBouncer|pgpool|deadpool|connection_pool)" 10
echo ""

# M4.3: Parallelism
section "M4.3: Parallelism & concurrency"
case "$STACK" in
  node)
    src_count "(Promise\.(all|allSettled|race)|worker_threads|Worker\(|piscina|p-limit|p-queue)" ;;
  go)
    src_count "(go func|errgroup|sync\.WaitGroup|chan |select \{)" ;;
  python)
    src_count "(asyncio\.(gather|TaskGroup|create_task)|ProcessPoolExecutor|ThreadPoolExecutor|concurrent\.futures)" ;;
  jvm)
    src_count "(CompletableFuture|ForkJoinPool|parallel\(\)|Virtual.*Thread|ExecutorService)" ;;
  *)
    echo "  Stack '$STACK' — manual analysis required" ;;
esac
echo ""

# M4.4: Horizontal scaling
section "M4.4: Horizontal scaling readiness"
echo "In-process state (blockers):"
src_list "(global\.|singleton|in.?memory|Map\(\)|new Map|sync\.Map|file.*lock)" 10
echo "Session externalization:"
src_list "(express-session|connect-redis|session.*redis|session.*store|cookie.?session)" 5
echo ""
