#!/usr/bin/env bash
# D6: Capacity & Scaling discovery
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$(dirname "$(dirname "$SCRIPT_DIR")")/lib/common.sh"
PROJECT_ROOT="${1:-$PROJECT_ROOT}"

section "D6: Capacity & Scaling"

# M6.1: Load testing
info "M6.1: Load Testing"
# k6
count_matches "  k6 test scripts" "*.k6.*" "$PROJECT_ROOT" > /dev/null 2>&1 || true
count_grep "  k6 imports" "import.*k6\|from.*k6\|k6 run" "" "$PROJECT_ROOT"
# Artillery
count_matches "  Artillery configs" "*artillery*" "$PROJECT_ROOT" > /dev/null 2>&1 || true
count_grep "  Artillery references" "artillery" "" "$PROJECT_ROOT"
# Locust
count_matches "  Locust files" "*locust*" "$PROJECT_ROOT" > /dev/null 2>&1 || true
count_grep "  Locust references" "from locust\|import locust\|HttpUser\|TaskSet" "" "$PROJECT_ROOT"
# Gatling
count_grep "  Gatling references" "gatling\|Simulation\|gatling.conf" "" "$PROJECT_ROOT"
# JMeter
count_matches "  JMeter files" "*.jmx" "$PROJECT_ROOT" > /dev/null 2>&1 || true
# vegeta
count_grep "  Vegeta references" "vegeta\|echo.*GET.*vegeta" "" "$PROJECT_ROOT"
# Generic
count_grep "  Load test in CI" "load.test\|performance.test\|stress.test\|benchmark" "*.yaml" "$PROJECT_ROOT/.github/workflows" 2>/dev/null || true

# M6.2: Auto-scaling
info "M6.2: Auto-Scaling Configured"
# Kubernetes HPA
count_grep "  HPA (HorizontalPodAutoscaler)" "HorizontalPodAutoscaler\|hpa\|autoscaling/v2" "*.yaml" "$PROJECT_ROOT"
# AWS ASG
count_grep "  AWS ASG / Auto Scaling" "aws_autoscaling_group\|AutoScalingGroup\|launch_template\|scaling_policy" "" "$PROJECT_ROOT"
# KEDA
count_grep "  KEDA (event-driven scaling)" "keda\|ScaledObject\|ScaledJob\|TriggerAuthentication" "*.yaml" "$PROJECT_ROOT"
# Generic scaling
count_grep "  Scaling policies" "minReplicas\|maxReplicas\|min_capacity\|max_capacity\|scale_in\|scale_out\|cooldown\|cool_down" "" "$PROJECT_ROOT"

# M6.3: Resource monitoring
info "M6.3: Resource Monitoring"
count_grep "  Prometheus/metrics" "prometheus\|metrics\|/metrics\|ServiceMonitor\|PodMonitor" "" "$PROJECT_ROOT"
count_grep "  Grafana dashboards" "grafana\|dashboard.*json\|datasource" "" "$PROJECT_ROOT"
count_grep "  Resource limits in k8s" "resources:\|limits:\|requests:\|cpu:\|memory:" "*.yaml" "$PROJECT_ROOT"
count_matches "  Grafana dashboard files" "*dashboard*.json" "$PROJECT_ROOT" > /dev/null 2>&1 || true

# M6.4: Capacity planning
info "M6.4: Capacity Planning"
count_grep "  Capacity planning docs" "capacity.plan\|growth.projection\|headroom\|capacity.review" "*.md" "$PROJECT_ROOT"
count_grep "  Resource quotas" "ResourceQuota\|LimitRange\|resource_quota" "*.yaml" "$PROJECT_ROOT"
