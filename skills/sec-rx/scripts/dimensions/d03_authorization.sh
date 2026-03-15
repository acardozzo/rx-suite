#!/usr/bin/env bash
# D3: Authorization & Access Control — OWASP A01:2021, ASVS V4
# Scans for IDOR, function-level access, data-level access, privilege escalation

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

PROJECT_ROOT="${1:-.}"
detect_stack "$PROJECT_ROOT"

section_header "D3" "Authorization & Access Control (15%)"

# ─── M3.1: IDOR Prevention ───
metric_header "M3.1" "IDOR Prevention"

# Routes with ID params but no auth check nearby
ID_PARAMS=$(search_source_files "$PROJECT_ROOT" \
  "(params\.(id|userId|user_id|orderId)|req\.params\.\w*[Ii]d|path.*/:id|<int:.*id>|\{id\})" \
  "-rn")
if [[ -n "$ID_PARAMS" ]]; then
  COUNT=$(echo "$ID_PARAMS" | wc -l | tr -d ' ')
  finding "MEDIUM" "M3.1" "$COUNT endpoints with ID parameters — verify ownership checks exist"

  # Check for ownership verification patterns
  OWNERSHIP=$(search_source_files "$PROJECT_ROOT" \
    "(userId\s*===?\s*|user_id\s*==\s*|owner|belongs_to|authorize|canAccess|checkOwnership|\.where.*user)" \
    "-rl")
  if [[ -n "$OWNERSHIP" ]]; then
    finding "INFO" "M3.1" "Ownership verification patterns detected"
  else
    finding "HIGH" "M3.1" "No ownership verification patterns detected — potential IDOR vulnerability"
  fi
fi

# UUID usage (better than sequential IDs)
UUID_USAGE=$(search_source_files "$PROJECT_ROOT" "(uuid|uuidv4|crypto\.randomUUID|nanoid)" "-rl")
if [[ -n "$UUID_USAGE" ]]; then
  finding "INFO" "M3.1" "UUID/non-sequential ID generation detected"
fi

# ─── M3.2: Function-Level Access ───
metric_header "M3.2" "Function-Level Access"

# Auth middleware patterns
AUTH_MW=$(search_source_files "$PROJECT_ROOT" \
  "(requireAuth|isAuthenticated|authMiddleware|@login_required|@require_role|@Authorize|@PreAuthorize|@RolesAllowed|authenticate|protect.*route|guard)" \
  "-rl")
if [[ -n "$AUTH_MW" ]]; then
  MW_COUNT=$(echo "$AUTH_MW" | wc -l | tr -d ' ')
  finding "INFO" "M3.2" "Auth middleware/decorators found in $MW_COUNT files"
else
  finding "HIGH" "M3.2" "No authentication middleware pattern detected"
fi

# Admin routes without role checks
ADMIN_ROUTES=$(search_source_files "$PROJECT_ROOT" "(\/admin|\/dashboard|\/manage|\/settings|isAdmin|role.*admin)" "-rn")
if [[ -n "$ADMIN_ROUTES" ]]; then
  finding "INFO" "M3.2" "Admin routes detected — verify role-based access control"
fi

# Role-based access
RBAC=$(search_source_files "$PROJECT_ROOT" \
  "(role|permission|hasRole|checkRole|canAccess|authorize|RBAC|ability|casl|casbin|@Roles|roles_required)" \
  "-rl")
if [[ -n "$RBAC" ]]; then
  finding "INFO" "M3.2" "RBAC pattern detected"
else
  finding "MEDIUM" "M3.2" "No role-based access control pattern detected"
fi

# ─── M3.3: Data-Level Access ───
metric_header "M3.3" "Data-Level Access"

# Row-level security (Supabase RLS, Postgres policies)
RLS=$(search_source_files "$PROJECT_ROOT" "(row.level.security|RLS|CREATE POLICY|ALTER.*ENABLE.*ROW|\.rls\()" "-rli")
RLS_SQL=$(search_config_files "$PROJECT_ROOT" "(row.level.security|CREATE POLICY|ENABLE ROW)" "-rli")
if [[ -n "$RLS" || -n "$RLS_SQL" ]]; then
  finding "INFO" "M3.3" "Row-level security policies detected"
else
  finding "MEDIUM" "M3.3" "No row-level security detected"
fi

# Tenant isolation
TENANT=$(search_source_files "$PROJECT_ROOT" \
  "(tenant|tenantId|tenant_id|organization_id|orgId|workspace_id|multi.tenant)" \
  "-rl")
if [[ -n "$TENANT" ]]; then
  finding "INFO" "M3.3" "Tenant/organization isolation patterns detected"

  # Check if queries always scope by tenant
  TENANT_SCOPE=$(search_source_files "$PROJECT_ROOT" "(where.*tenant|filter.*tenant|scope.*tenant)" "-rl")
  if [[ -z "$TENANT_SCOPE" ]]; then
    finding "HIGH" "M3.3" "Tenant fields exist but no query scoping pattern detected"
  fi
fi

# ─── M3.4: Privilege Escalation Prevention ───
metric_header "M3.4" "Privilege Escalation Prevention"

# Self-role-assignment patterns
ROLE_ASSIGN=$(search_source_files "$PROJECT_ROOT" \
  "(\.role\s*=|set.*role|update.*role|assignRole|changeRole|req\.body\.role|params\.role)" \
  "-rn")
if [[ -n "$ROLE_ASSIGN" ]]; then
  while IFS= read -r line; do
    file=$(echo "$line" | cut -d: -f1)
    lineno=$(echo "$line" | cut -d: -f2)
    finding "HIGH" "M3.4" "Role assignment in code — verify authorization check" "$file" "$lineno"
  done <<< "$ROLE_ASSIGN"
fi

# Role hierarchy enforcement
ROLE_HIERARCHY=$(search_source_files "$PROJECT_ROOT" "(role.*hierarchy|permission.*level|role.*level|isSuper|isSuperAdmin)" "-rli")
if [[ -n "$ROLE_HIERARCHY" ]]; then
  finding "INFO" "M3.4" "Role hierarchy pattern detected"
fi

# Audit logging for privilege changes
PRIV_AUDIT=$(search_source_files "$PROJECT_ROOT" "(audit.*role|log.*role.*change|audit.*permission|log.*privilege)" "-rli")
if [[ -n "$PRIV_AUDIT" ]]; then
  finding "INFO" "M3.4" "Privilege change audit logging detected"
else
  finding "LOW" "M3.4" "No audit logging for privilege changes detected"
fi

print_summary
