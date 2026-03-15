#!/usr/bin/env bash
# D9: Security Architecture
# M9.1 Zero Trust | M9.2 Secrets | M9.3 Supply Chain | M9.4 Authorization
source "$(dirname "$0")/../lib/common.sh"

echo "## D9: SECURITY ARCHITECTURE"
echo ""

# M9.1: Zero trust
section "M9.1: Zero trust & service-to-service auth"
src_list "(mTLS|mutual.*tls|service.*token|service.*auth|x-api-key|inter.?service|istio|linkerd|service.?mesh)" 10
echo ""

# M9.2: Secrets management
section "M9.2: Secrets management"
src_list "(vault|secrets.?manager|SecretManager|aws-sdk.*secret|infisical|doppler|chamber)" 10
echo "Hardcoded secrets:"
find "$TARGET_ABS" -type f \( -name "*.ts" -o -name "*.js" -o -name "*.go" -o -name "*.py" \) \
  ! -path "*/node_modules/*" ! -path "*/dist/*" ! -path "*.test.*" ! -path "*__test__*" ! -path "*spec.*" \
  -exec grep -l -iE "(sk-[a-zA-Z0-9]{20}|AKIA[0-9A-Z]{16}|ghp_[a-zA-Z0-9]{36}|password.*=.*['\"][^'\"]{8,})" {} \; 2>/dev/null | head -5
echo ""

# M9.3: Supply chain
section "M9.3: Supply chain security"
find "$ROOT" -maxdepth 3 -type f \( -name ".snyk" -o -name "socket.yml" -o -name ".trivyignore" -o -name "audit-ci*" -o -name ".npmrc" \) 2>/dev/null | head -5
echo "SBOM: $(has_tool syft && echo 'syft available' || echo 'NO — install: brew install syft')"
echo "Lockfile: $([ -f "$ROOT/package-lock.json" ] || [ -f "$ROOT/pnpm-lock.yaml" ] || [ -f "$ROOT/yarn.lock" ] || [ -f "$ROOT/go.sum" ] || [ -f "$ROOT/Cargo.lock" ] && echo 'YES' || echo 'NO')"
echo ""

# M9.4: Authorization
section "M9.4: Authorization architecture"
src_list "(rbac|abac|policy|permission|authorize|@Roles|@Guard|casbin|opa|cedar|cancan|pundit)" 10
echo ""
