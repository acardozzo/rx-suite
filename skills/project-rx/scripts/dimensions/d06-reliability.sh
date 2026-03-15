#!/usr/bin/env bash
# D6: Reliability & Operations
# M6.1 Health | M6.2 Monitoring | M6.3 Errors | M6.4 Logging
source "$(dirname "$0")/../lib/common.sh"

echo "## D6: RELIABILITY & OPERATIONS"
echo ""

# M6.1: Health Checks
section "M6.1: Health Checks"
e=0
has_route "health" && echo "  route: /health" && ((e++))
has_route "ready\|readiness" && echo "  route: /ready" && ((e++))
has_route "live\|liveness" && echo "  route: /live" && ((e++))
c=$(src_count "health.*check\|dependency.*health\|db.*ping\|redis.*ping")
[ "$c" -gt 0 ] && echo "  dep-health-checks: $c files" && ((e++))
echo "  SCORE: $(component_score "Health" "$e" 1 2 3 4 | head -1)"
echo ""

# M6.2: Monitoring
section "M6.2: Monitoring & Metrics"
e=0
for lib in prom-client prometheus @opentelemetry dd-trace newrelic @sentry/node @grafana; do
  has_dep "$lib" && echo "  dep: $lib" && ((e++))
done
c=$(src_count "counter\.\|histogram\.\|gauge\.\|metric.*collect\|recordMetric")
[ "$c" -gt 0 ] && echo "  metric-collection: $c files" && ((e++))
has_env "DATADOG\|DD_\|NEWRELIC\|OTEL_\|PROMETHEUS" && echo "  monitoring-env" && ((e++))
has_file "grafana*" || has_dir "dashboards" && echo "  dashboard-configs" && ((e++))
echo "  SCORE: $(component_score "Monitoring" "$e" 1 2 4 6 | head -1)"
echo ""

# M6.3: Error Tracking
section "M6.3: Error Tracking"
e=0
for lib in @sentry/nextjs @sentry/node @sentry/react bugsnag @bugsnag rollbar; do
  has_dep "$lib" && echo "  dep: $lib" && ((e++))
done
c=$(src_count "ErrorBoundary\|error\.tsx\|error\.js\|componentDidCatch")
[ "$c" -gt 0 ] && echo "  error-boundaries: $c files" && ((e++))
c=$(src_count "captureException\|captureMessage\|Sentry\.init\|reportError")
[ "$c" -gt 0 ] && echo "  error-reporting: $c files" && ((e++))
has_file "sentry.*.config*" && echo "  sentry-config" && ((e++))
c=$(src_count "sourcemap\|source.map\|sentryWebpackPlugin\|withSentryConfig")
[ "$c" -gt 0 ] && echo "  sourcemaps: $c files" && ((e++))
echo "  SCORE: $(component_score "Errors" "$e" 1 2 4 6 | head -1)"
echo ""

# M6.4: Logging
section "M6.4: Structured Logging"
e=0
for lib in pino winston bunyan @axiomhq/pino @logtail/pino loglevel; do
  has_dep "$lib" && echo "  dep: $lib" && ((e++))
done
c=$(src_count "logger\.\|log\.(info|warn|error|debug)\|structuredLog\|createLogger")
[ "$c" -gt 0 ] && echo "  logger-usage: $c files" && ((e++))
c=$(src_count "correlation.*id\|requestId\|traceId\|x-request-id")
[ "$c" -gt 0 ] && echo "  correlation-ids: $c files" && ((e++))
c=$(src_count "log.*level\|LOG_LEVEL\|logLevel\|setLevel")
[ "$c" -gt 0 ] && echo "  log-level-config: $c files" && ((e++))
echo "  SCORE: $(component_score "Logging" "$e" 1 2 3 5 | head -1)"
echo ""
