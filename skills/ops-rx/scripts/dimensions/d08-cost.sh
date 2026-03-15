#!/usr/bin/env bash
# D8: Cost & Efficiency discovery
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$(dirname "$(dirname "$SCRIPT_DIR")")/lib/common.sh"
PROJECT_ROOT="${1:-$PROJECT_ROOT}"

section "D8: Cost & Efficiency"

# M8.1: Resource tagging
info "M8.1: Resource Tagging"
count_grep "  Tags in Terraform" 'tags\s*=' "*.tf" "$PROJECT_ROOT"
count_grep "  Tags in CloudFormation" "Tags:\|tags:" "*.yaml" "$PROJECT_ROOT"
count_grep "  Tag enforcement" "tag.*policy\|required.*tags\|aws_organizations_policy.*TAG\|tag.*compliance" "" "$PROJECT_ROOT"
count_grep "  Cost allocation tags" "cost.center\|cost_center\|costCenter\|cost.allocation\|billing.*tag" "" "$PROJECT_ROOT"
count_grep "  Default tags" "default_tags\|defaultTags\|provider.*tags" "*.tf" "$PROJECT_ROOT"

# M8.2: Right-sizing
info "M8.2: Right-Sizing"
count_grep "  Spot/preemptible usage" "spot\|preemptible\|spot_instance\|spot.*fleet\|SpotFleet\|spot_price" "" "$PROJECT_ROOT"
count_grep "  Reserved instances" "reserved\|savings.plan\|reserved_instance\|RI\|commitment" "" "$PROJECT_ROOT"
count_grep "  Instance type definitions" "instance_type\|instanceType\|machine_type\|node_type\|vm_size" "" "$PROJECT_ROOT"
count_grep "  Compute Optimizer / right-sizing" "right.siz\|compute.optimizer\|trusted.advisor\|cost.explorer" "" "$PROJECT_ROOT"

# M8.3: Budget alerts
info "M8.3: Budget Alerts"
count_grep "  AWS Budget config" "aws_budgets\|Budget.*Action\|budget.*alert\|cost.*alert\|billing.*alert" "" "$PROJECT_ROOT"
count_grep "  Cost anomaly detection" "cost.*anomaly\|anomaly.*detection\|CostAnomalyMonitor\|aws_ce_anomaly" "" "$PROJECT_ROOT"
count_grep "  FinOps references" "finops\|FinOps\|cloud.*cost\|cloud.*spend\|cloud.*economics" "" "$PROJECT_ROOT"
count_grep "  Infracost" "infracost\|INFRACOST\|infracost.*ci" "" "$PROJECT_ROOT"

# M8.4: Waste elimination
info "M8.4: Waste Elimination"
count_grep "  Cleanup scripts" "cleanup\|clean.up\|prune\|garbage.collect\|expire\|lifecycle.*rule" "" "$PROJECT_ROOT"
count_grep "  S3/storage lifecycle" "lifecycle.*rule\|lifecycle_rule\|expiration\|transition.*GLACIER\|noncurrent.*version" "" "$PROJECT_ROOT"
count_grep "  Unused resource detection" "unused\|idle\|orphan\|stale.*resource\|abandoned" "" "$PROJECT_ROOT"
count_grep "  TTL / auto-delete" "ttl\|TTL\|auto.delete\|auto_delete\|expiry\|time.to.live" "" "$PROJECT_ROOT"
count_grep "  Dev environment cleanup" "auto.*shutdown\|schedule.*stop\|stop.*instance.*night\|dev.*cleanup" "" "$PROJECT_ROOT"
