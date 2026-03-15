#!/usr/bin/env bash
# D8: Deployment & Runtime Architecture
# M8.1 Containerization | M8.2 CI/CD | M8.3 Release Strategy | M8.4 IaC
source "$(dirname "$0")/../lib/common.sh"

echo "## D8: DEPLOYMENT & RUNTIME ARCHITECTURE"
echo ""

# M8.1: Containerization
section "M8.1: Containerization & packaging"
DOCKERFILES=$(find "$ROOT" -name "Dockerfile*" -maxdepth 3 2>/dev/null)
echo "$DOCKERFILES" | head -5
for df in $(echo "$DOCKERFILES" | head -3); do
  [ -z "$df" ] && continue
  stages=$(grep -c "^FROM " "$df" 2>/dev/null || echo 0)
  nonroot=$(grep -c "USER " "$df" 2>/dev/null || echo 0)
  echo "  $df: $stages stages, $([ "$nonroot" -gt 0 ] && echo 'non-root YES' || echo 'non-root NO')"
done
if has_tool hadolint && [ -n "$DOCKERFILES" ]; then
  echo "Hadolint:"
  echo "$DOCKERFILES" | head -1 | xargs hadolint --no-color 2>/dev/null | head -10
fi
echo ""

# M8.2: CI/CD
section "M8.2: CI/CD pipeline"
find "$ROOT" -maxdepth 3 -type f \( \
  -name "*.yml" -path "*/.github/*" -o \
  -name "Jenkinsfile" -o \
  -name ".gitlab-ci.yml" -o \
  -name "bitbucket-pipelines.yml" -o \
  -name "cloudbuild.yaml" -o \
  -name "buildspec.yml" \
  \) 2>/dev/null | head -10
echo ""

# M8.3: Release strategy
section "M8.3: Release strategy"
echo "Feature flags:"
src_list "(launchdarkly|unleash|flipt|flagsmith|feature.?flag|feature.?toggle|split\.io|statsig|growthbook)" 5
echo "Canary/blue-green:"
find "$ROOT" -maxdepth 4 -type f \( -name "*.yaml" -o -name "*.yml" -o -name "*.tf" \) \
  -exec grep -l -iE "(canary|blue.?green|rolling.?update|progressive.?delivery|argo.?rollout|flagger)" {} \; 2>/dev/null | head -5
echo ""

# M8.4: IaC
section "M8.4: Infrastructure as Code"
find "$ROOT" -maxdepth 4 -type f \( \
  -name "*.tf" -o -name "*.tfvars" -o -name "Pulumi.yaml" -o \
  -name "cdk.*" -o -name "serverless.*" -o \
  -name "sam.yaml" -o -name "template.yaml" \
  \) 2>/dev/null | head -10
echo "K8s manifests:"
find "$ROOT" -maxdepth 4 -type f \( -name "*.yaml" -o -name "*.yml" \) \
  -exec grep -l "kind:.*Deployment\|kind:.*Service\|kind:.*Ingress" {} \; 2>/dev/null | head -10
echo ""
