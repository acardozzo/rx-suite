#!/usr/bin/env bash
# D10: Multi-Tenancy & Isolation
# M10.1 Isolation | M10.2 Context | M10.3 Noisy Neighbor | M10.4 Lifecycle
source "$(dirname "$0")/../lib/common.sh"

echo "## D10: MULTI-TENANCY & ISOLATION"
echo ""

# M10.1: Tenant isolation
section "M10.1: Tenant isolation strategy"
echo "Tenant identifiers:"
echo "  $(src_count '(tenant.?id|org.?id|organization.?id|workspace.?id|team.?id|account.?id)')"
echo "DB-level isolation (RLS/schema):"
src_list "(row.?level.?security|RLS|enable_rls|\.eq\(.*tenant|WHERE.*tenant_id|current_setting\('app\.tenant|schema.*tenant|CREATE SCHEMA)" 10
echo ""

# M10.2: Tenant context propagation
section "M10.2: Tenant context propagation"
src_list "(AsyncLocalStorage|cls-hooked|context\.Context.*tenant|contextvars|tenant.*middleware|@TenantId|tenant.*interceptor)" 10
echo ""

# M10.3: Noisy neighbor
section "M10.3: Noisy neighbor protection"
src_list "(rate.?limit.*tenant|tenant.*rate.?limit|per.?tenant.*limit|quota|resource.?limit.*tenant|fair.?schedul)" 10
echo ""

# M10.4: Tenant lifecycle
section "M10.4: Tenant lifecycle management"
src_list "(provision|onboard|tenant.*creat|tenant.*delet|offboard|data.*export|gdpr|data.*portab|tenant.*migrat|usage.*meter)" 10
echo ""
