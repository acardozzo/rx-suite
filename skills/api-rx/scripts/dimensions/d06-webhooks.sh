#!/usr/bin/env bash
# d06-webhooks.sh — Scan webhook & event API patterns
source "$(dirname "$0")/../lib/common.sh"

echo "# D06 — WEBHOOK & EVENT API"
echo ""

section "M6.1 Delivery Guarantees"
echo "  Webhook handler files: $(src_count_files 'webhook|Webhook|web_hook|WebHook')"
echo "  Idempotency key patterns: $(src_count_matches 'idempotency.*key|idempotencyKey|Idempotency-Key|idempotent|dedup')"
echo "  Event delivery tracking: $(src_count_matches 'delivery.*status|deliveryStatus|webhook.*log|event.*log|delivery.*attempt')"
echo "  At-least-once references: $(src_count_matches 'at.least.once|atLeastOnce|guaranteed.*delivery')"
echo "  Redelivery/replay endpoint: $(src_count_matches 'redeliver|replay|resend.*event|retry.*webhook')"
echo ""

section "M6.2 Signature Verification"
echo "  HMAC signing: $(src_count_matches 'hmac|HMAC|createHmac|hmac-sha256|webhook.*secret|signing.*secret')"
echo "  Timestamp validation: $(src_count_matches 'timestamp.*valid|webhook.*timestamp|replay.*attack|tolerance.*time')"
echo "  Signature header: $(src_count_matches 'X-Signature|x-hub-signature|X-Webhook-Signature|webhook.*signature')"
echo "  Verification helpers: $(src_count_files 'verifySignature|verify_signature|validateWebhook|verify.*webhook')"
echo ""

section "M6.3 Retry Policy"
echo "  Exponential backoff: $(src_count_matches 'exponential.*backoff|backoff.*exponential|retryDelay.*Math|retry.*interval')"
echo "  Dead letter queue: $(src_count_matches 'dead.*letter|deadLetter|dlq|DLQ|failed.*event.*queue')"
echo "  Retry count/attempts: $(src_count_matches 'retry.*count|retryCount|attempt.*count|max.*retries|maxRetries')"
echo "  Manual retry endpoint: $(src_count_matches 'retry.*endpoint|manual.*retry|POST.*retry')"
echo ""

section "M6.4 Event Schema & Versioning"
echo "  Event type definitions: $(src_count_matches 'eventType|event_type|EventType|type.*event|WebhookEvent')"
echo "  Event versioning: $(src_count_matches 'event.*version|eventVersion|schema.*version|api_version.*event')"
echo "  Event catalog/registry: $(src_count_files 'eventCatalog|event-catalog|EventRegistry|event.*types')"
echo "  Event type filtering: $(src_count_matches 'subscribe.*event|filter.*event|event.*subscription|enabled_events')"
echo ""
