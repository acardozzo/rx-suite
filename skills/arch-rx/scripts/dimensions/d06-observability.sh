#!/usr/bin/env bash
# D6: Observability & Operational Maturity
# M6.1 Logging | M6.2 Tracing | M6.3 Metrics | M6.4 Health
source "$(dirname "$0")/../lib/common.sh"

echo "## D6: OBSERVABILITY & OPERATIONAL MATURITY"
echo ""

# M6.1: Structured logging
section "M6.1: Structured logging"
echo "Unstructured (console.*):"
echo "  $(src_count 'console\.(log|warn|error|info)')"
echo "Structured logger:"
echo "  files: $(src_list '(pino|winston|bunyan|log4js|structlog|zerolog|zap|slog|serilog|NLog|log4j)' 999 | wc -l | tr -d ' ')"
echo "Correlation IDs:"
src_list "(correlation.?id|request.?id|trace.?id|x-request-id|x-correlation)" 5
echo "PII redaction:"
src_list "(redact|pii|sanitize.*log|mask.*field)" 5
echo ""

# M6.2: Distributed tracing
section "M6.2: Distributed tracing"
src_list "(opentelemetry|@opentelemetry|otel|tracer\.start|span\.end|tracing|Instrumentation)" 10
echo ""

# M6.3: Metrics
section "M6.3: Metrics & dashboards"
src_list "(prom-client|prometheus|@opentelemetry/metrics|micrometer|prometheus_client|metrics\.counter|metrics\.histogram|metrics\.gauge|statsd|datadog)" 10
echo "SLI/SLO definitions:"
find "$ROOT" -type f \( -name "*.yaml" -o -name "*.yml" -o -name "*.json" \) \
  -exec grep -l -iE "(sli|slo|error.?budget|burn.?rate|service.?level)" {} \; 2>/dev/null | head -5
echo ""

# M6.4: Health checks
section "M6.4: Health checks & readiness"
src_list "(/health|/ready|/live|/startup|healthcheck|readiness|liveness|terminus|lightship)" 10
echo ""
