#!/usr/bin/env bash
# D2: Async & Event Architecture
# M2.1 Async Coverage | M2.2 Event Decoupling | M2.3 Queue Infra | M2.4 CQRS
source "$(dirname "$0")/../lib/common.sh"

echo "## D2: ASYNC & EVENT ARCHITECTURE"
echo ""

# M2.1: Long operation candidates
section "M2.1: Long operation candidates (potential >5s)"
echo "External API calls:"
src_count "(fetch\(|axios\.|got\(|request\(|http\.(get|post)|\.send\()"
echo "Heavy processing (PDF, image, AI inference):"
src_list "(pdf|sharp|jimp|imagemagick|ffmpeg|puppeteer|playwright|openai\..*create|anthropic\..*create|completion)" 10
echo ""

# M2.2: Event decoupling
section "M2.2: Event-driven side effects"
src_list "(EventEmitter|\.emit\(|\.on\(.*event|eventBus|EventBus|@EventHandler|event_handler|ApplicationEvent|@OnEvent)" 15
echo "Dead letter queues:"
src_list "(dead.?letter|dlq|failed.?queue|error.?queue)" 5
echo "Idempotency:"
src_list "(idempoten|dedup|exactly.?once|idempotency.?key)" 5
echo ""

# M2.3: Queue infrastructure
section "M2.3: Queue & message infrastructure"
src_list "(bullmq|bull|agenda|celery|sidekiq|resque|asynq|machinery|sqs|pubsub|kafka|rabbitmq|amqp|nats|redis.*queue|BullModule|@Process|@Processor|MassTransit|NServiceBus|Hangfire)" 20
echo "Backpressure:"
src_list "(backpressure|back.?pressure|concurrency.*limit|maxConcurrency|rate.*queue)" 5
echo ""

# M2.4: CQRS
section "M2.4: CQRS / read-write separation"
src_list "(CommandHandler|QueryHandler|ReadModel|WriteModel|cqrs|materialized.*view|read.?replica)" 10
echo ""
