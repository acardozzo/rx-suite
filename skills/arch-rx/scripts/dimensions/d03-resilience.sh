#!/usr/bin/env bash
# D3: Resilience & Fault Tolerance
# M3.1 Circuit Breaker | M3.2 Retry/Backoff | M3.3 Bulkhead | M3.4 Degradation
source "$(dirname "$0")/../lib/common.sh"

echo "## D3: RESILIENCE & FAULT TOLERANCE"
echo ""

# M3.1: Circuit breakers
section "M3.1: Circuit breaker coverage"
src_list "(circuit.?breaker|opossum|cockatiel|gobreaker|hystrix|resilience4j|pybreaker|polly|CircuitBreaker|failsafe)" 10
echo ""

# M3.2: Retry/backoff
section "M3.2: Retry & backoff strategy"
src_list "(retry|backoff|p-retry|exponential|tenacity|@Retryable|RetryTemplate|cockatiel|tokio-retry)" 10
echo "Jitter:"
src_list "(jitter|random.*delay|Math\.random.*retry)" 5
echo ""

# M3.3: Bulkhead & isolation
section "M3.3: Bulkhead & isolation patterns"
src_list "(bulkhead|p-limit|p-queue|bottleneck|Semaphore|semaphore|errgroup|thread.?pool|worker.?pool|isolation|resource.?limit)" 10
echo "Timeouts:"
src_list "(timeout|AbortController|AbortSignal|context\.WithTimeout|deadline|TimeoutException)" 10
echo ""

# M3.4: Graceful degradation
section "M3.4: Graceful degradation & fallbacks"
src_list "(fallback|stale.?data|stale.?while|cache.?fallback|degraded|graceful.?degrad|feature.?flag|feature.?toggle|LaunchDarkly|unleash|flipt|flagsmith)" 10
echo ""
