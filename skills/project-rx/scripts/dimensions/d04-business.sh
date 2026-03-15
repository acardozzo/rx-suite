#!/usr/bin/env bash
# D4: Business Logic & Domain
# M4.1 Domain | M4.2 Rules | M4.3 Tenancy | M4.4 Billing
source "$(dirname "$0")/../lib/common.sh"

echo "## D4: BUSINESS LOGIC & DOMAIN"
echo ""

# M4.1: Domain Models
section "M4.1: Domain Models"
e=0
has_dir "models" || has_dir "entities" || has_dir "domain" && echo "  domain-dir" && ((e++))
has_file "schema.prisma" && echo "  prisma-schema" && ((e++))
c=$(src_count "model\s+\w+\s*\{|@Entity|class.*Entity|interface.*Model|type.*=.*\{")
[ "$c" -gt 0 ] && echo "  model-defs: $c files" && ((e++))
c=$(src_count "enum\s+\w+|StatusEnum|TypeEnum|value.*object")
[ "$c" -gt 0 ] && echo "  enums/VOs: $c files" && ((e++))
echo "  SCORE: $(component_score "Domain" "$e" 1 2 3 4 | head -1)"
echo ""

# M4.2: Business Rules
section "M4.2: Business Rules & Validation"
e=0
for lib in zod joi yup class-validator superstruct valibot; do
  has_dep "$lib" && echo "  dep: $lib" && ((e++))
done
for lib in xstate zustand-machine robot3 aasm; do
  has_dep "$lib" && echo "  state-machine: $lib" && ((e++))
done
c=$(src_count "z\.object\|Joi\.object\|yup\.object\|@IsString\|@IsNotEmpty")
[ "$c" -gt 0 ] && echo "  validation-schemas: $c files" && ((e++))
c=$(src_count "workflow\|state.*machine\|transition\|business.*rule")
[ "$c" -gt 0 ] && echo "  workflows: $c files" && ((e++))
echo "  SCORE: $(component_score "Rules" "$e" 1 2 4 6 | head -1)"
echo ""

# M4.3: Multi-Tenancy
section "M4.3: Multi-Tenancy"
e=0
c=$(src_count "tenant_id\|tenantId\|organization_id\|orgId")
[ "$c" -gt 0 ] && echo "  tenant-id-refs: $c files" && ((e++))
c=$(src_count "org.*model\|Organization.*schema\|Team.*schema\|Workspace")
[ "$c" -gt 0 ] && echo "  org-model: $c files" && ((e++))
c=$(src_count "tenant.*middleware\|org.*context\|currentOrg\|withTenant")
[ "$c" -gt 0 ] && echo "  tenant-middleware: $c files" && ((e++))
c=$(src_count "RLS\|row.*level.*security\|enable_rls\|POLICY")
[ "$c" -gt 0 ] && echo "  RLS-policies: $c files" && ((e++))
has_route "org\|team\|workspace" && echo "  route: org/team" && ((e++))
echo "  SCORE: $(component_score "Tenancy" "$e" 1 2 3 5 | head -1)"
echo ""

# M4.4: Billing
section "M4.4: Billing & Payments"
e=0
for lib in stripe @stripe/stripe-js paddle @lemonsqueezy/wedges lemon-squeezy; do
  has_dep "$lib" && echo "  dep: $lib" && ((e++))
done
has_route "billing\|pricing\|subscription\|checkout" && echo "  route: billing" && ((e++))
c=$(src_count "subscription.*model\|Plan.*schema\|price_id\|priceId")
[ "$c" -gt 0 ] && echo "  subscription-model: $c files" && ((e++))
c=$(src_count "invoice\|receipt\|charge\|payment.*intent")
[ "$c" -gt 0 ] && echo "  payment-logic: $c files" && ((e++))
c=$(src_count "stripe.*webhook\|checkout.*session.*completed\|payment.*succeeded")
[ "$c" -gt 0 ] && echo "  payment-webhooks: $c files" && ((e++))
has_env "STRIPE\|PADDLE\|LEMON" && echo "  billing-env" && ((e++))
echo "  SCORE: $(component_score "Billing" "$e" 1 2 4 6 | head -1)"
echo ""
