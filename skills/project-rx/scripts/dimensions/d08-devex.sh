#!/usr/bin/env bash
# D8: Developer Experience & CI/CD
# M8.1 CI/CD | M8.2 Dev | M8.3 Quality | M8.4 Docs
source "$(dirname "$0")/../lib/common.sh"

echo "## D8: DEVELOPER EXPERIENCE & CI/CD"
echo ""

# M8.1: CI/CD
section "M8.1: CI/CD Pipeline"
e=0
has_dir ".github/workflows" && echo "  github-actions" && ((e++))
has_file "Dockerfile" && echo "  Dockerfile" && ((e++))
has_file ".gitlab-ci.yml" && echo "  gitlab-ci" && ((e++))
has_file "Jenkinsfile" && echo "  Jenkinsfile" && ((e++))
has_file "vercel.json" || has_file ".vercel" && echo "  vercel-deploy" && ((e++))
has_file "fly.toml" && echo "  fly-deploy" && ((e++))
has_file "railway.json" || has_file "railway.toml" && echo "  railway-deploy" && ((e++))
has_file "render.yaml" && echo "  render-deploy" && ((e++))
c=$(find "$ROOT/.github/workflows" -name "*.yml" -o -name "*.yaml" 2>/dev/null | wc -l | tr -d ' ')
[ "$c" -gt 0 ] && echo "  workflow-files: $c"
echo "  SCORE: $(component_score "CI/CD" "$e" 1 2 3 5 | head -1)"
echo ""

# M8.2: Dev Environment
section "M8.2: Dev Environment"
e=0
has_file "docker-compose*" && echo "  docker-compose" && ((e++))
has_file ".env.example" || has_file ".env.local.example" && echo "  env-example" && ((e++))
if [ -f "$ROOT/package.json" ]; then
  for script in dev build test lint seed db:push db:migrate; do
    grep -q "\"$script\"" "$ROOT/package.json" 2>/dev/null && echo "  script: $script" && ((e++))
  done
fi
has_file ".devcontainer*" || has_dir ".devcontainer" && echo "  devcontainer" && ((e++))
has_file "Makefile" && echo "  Makefile" && ((e++))
echo "  SCORE: $(component_score "Dev" "$e" 1 3 5 7 | head -1)"
echo ""

# M8.3: Code Quality
section "M8.3: Code Quality"
e=0
has_file ".eslintrc*" || has_file "eslint.config*" && echo "  eslint" && ((e++))
has_file "biome.json" && echo "  biome" && ((e++))
has_file ".prettierrc*" || has_file "prettier.config*" && echo "  prettier" && ((e++))
c=$(src_count "\"strict\".*true\|strict.*:.*true")
[ "$c" -gt 0 ] && echo "  ts-strict: $c files" && ((e++))
has_dir ".husky" && echo "  husky" && ((e++))
has_file ".lintstagedrc*" || has_dep "lint-staged" && echo "  lint-staged" && ((e++))
has_file ".commitlintrc*" || has_dep "@commitlint" && echo "  commitlint" && ((e++))
echo "  SCORE: $(component_score "Quality" "$e" 1 3 5 7 | head -1)"
echo ""

# M8.4: Documentation
section "M8.4: Documentation"
e=0
has_file "README.md" && echo "  README.md" && ((e++))
has_dir "docs" && echo "  docs/" && ((e++))
has_dir "adr" || has_dir "decisions" && echo "  ADR dir" && ((e++))
has_file "CONTRIBUTING.md" && echo "  CONTRIBUTING.md" && ((e++))
has_file "CHANGELOG.md" && echo "  CHANGELOG.md" && ((e++))
has_file "LICENSE" && echo "  LICENSE" && ((e++))
echo "  SCORE: $(component_score "Docs" "$e" 1 2 4 6 | head -1)"
echo ""
