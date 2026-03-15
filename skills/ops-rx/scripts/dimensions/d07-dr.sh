#!/usr/bin/env bash
# D7: Disaster Recovery discovery
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$(dirname "$(dirname "$SCRIPT_DIR")")/lib/common.sh"
PROJECT_ROOT="${1:-$PROJECT_ROOT}"

section "D7: Disaster Recovery"

# M7.1: Backup strategy
info "M7.1: Backup Strategy"
count_matches "  Backup scripts" "*backup*" "$PROJECT_ROOT" > /dev/null 2>&1 || true
count_grep "  Backup configs" "backup\|aws_backup\|velero\|restic\|borg\|barman\|pg_dump\|mysqldump\|mongodump" "" "$PROJECT_ROOT"
count_grep "  Backup in IaC" "backup.*policy\|backup.*plan\|backup.*vault\|retention.*policy\|snapshot.*policy" "" "$PROJECT_ROOT"
count_grep "  Backup encryption" "backup.*encrypt\|encrypt.*backup\|kms.*backup\|backup.*kms" "" "$PROJECT_ROOT"

# M7.2: Recovery testing
info "M7.2: Recovery Testing"
count_grep "  DR test/drill docs" "disaster.recovery.*test\|DR.*drill\|recovery.*test\|failover.*test\|restore.*test" "*.md" "$PROJECT_ROOT"
count_grep "  RTO/RPO definitions" "RTO\|RPO\|recovery.time\|recovery.point\|time.to.recover" "" "$PROJECT_ROOT"
count_grep "  Chaos engineering" "chaos\|litmus\|gremlin\|chaos.monkey\|chaos.mesh\|toxiproxy\|fault.inject" "" "$PROJECT_ROOT"

# M7.3: Multi-region readiness
info "M7.3: Multi-Region Readiness"
count_grep "  Multi-region config" "multi.region\|cross.region\|region.*failover\|secondary.*region\|replica.*region" "" "$PROJECT_ROOT"
count_grep "  Data replication" "replication\|replica\|read.replica\|sync.*region\|cross.region.*replication" "" "$PROJECT_ROOT"
count_grep "  DNS failover" "route53.*failover\|dns.*failover\|GeoDNS\|global.*accelerator\|cloudfront" "" "$PROJECT_ROOT"
count_grep "  Multi-AZ config" "multi.az\|availability.zone\|spread.*az\|topology.*zone" "" "$PROJECT_ROOT"

# M7.4: Business continuity
info "M7.4: Business Continuity"
count_grep "  BCP docs" "business.continuity\|BCP\|continuity.plan\|degraded.mode\|graceful.degradation" "*.md" "$PROJECT_ROOT"
count_grep "  Service priority/tiers" "service.*tier\|service.*priority\|critical.*service\|tier.1\|tier.2\|priority.*service" "*.md" "$PROJECT_ROOT"
count_grep "  Circuit breaker / fallback" "circuit.breaker\|fallback\|graceful.*degrad\|feature.*flag.*kill" "" "$PROJECT_ROOT"
