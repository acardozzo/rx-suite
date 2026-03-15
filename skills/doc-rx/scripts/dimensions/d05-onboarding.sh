#!/usr/bin/env bash
# d05-onboarding.sh — D5: Onboarding & Contributing
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

ROOT="$1"

header "D5: Onboarding & Contributing (15%)"

# ── M5.1: CONTRIBUTING.md ─────────────────────────────────────────────────
subheader "M5.1: CONTRIBUTING.md"

contrib_file=""
for candidate in CONTRIBUTING.md contributing.md CONTRIBUTING.rst docs/CONTRIBUTING.md docs/contributing.md; do
  if [[ -f "$ROOT/$candidate" ]]; then
    contrib_file="$ROOT/$candidate"
    found "Contributing guide: $candidate"
    break
  fi
done

if [[ -n "$contrib_file" ]]; then
  # Check for key sections
  if has_section "$contrib_file" "pull.request\|PR\|merge.request"; then
    found "PR process documented"
  else
    warn "No PR process section"
  fi

  if has_section "$contrib_file" "code.style\|style.guide\|lint\|format"; then
    found "Code style documented"
  else
    warn "No code style section"
  fi

  if has_section "$contrib_file" "review\|reviewer"; then
    found "Review expectations documented"
  else
    warn "No review expectations"
  fi

  if has_section "$contrib_file" "commit\|conventional"; then
    found "Commit conventions documented"
  else
    warn "No commit conventions"
  fi

  if has_section "$contrib_file" "test"; then
    found "Testing requirements documented"
  else
    warn "No testing requirements"
  fi
else
  # Check README for contributing section
  for readme in README.md readme.md; do
    if [[ -f "$ROOT/$readme" ]] && has_section "$ROOT/$readme" "contribut"; then
      warn "Contributing info in README only (no standalone file)"
      break
    fi
  done
  if [[ -z "$contrib_file" ]]; then
    missing "No CONTRIBUTING.md or contributing section"
  fi
fi

# ── M5.2: Development Setup Automation ────────────────────────────────────
subheader "M5.2: Development Setup Automation"

# Dev containers
if [[ -d "$ROOT/.devcontainer" ]]; then
  found "Dev container configuration (.devcontainer/)"
elif [[ -f "$ROOT/.devcontainer.json" ]]; then
  found "Dev container configuration (.devcontainer.json)"
else
  missing "No dev container setup"
fi

# Docker compose
for dc in docker-compose.yml docker-compose.yaml compose.yml compose.yaml; do
  if [[ -f "$ROOT/$dc" ]]; then
    found "Docker Compose: $dc"
    # Check for dev profile
    if grep -q "dev\|development" "$ROOT/$dc" 2>/dev/null; then
      found "Development profile/service in compose"
    fi
    break
  fi
done

# Makefile
if [[ -f "$ROOT/Makefile" ]]; then
  found "Makefile exists"
  if grep -q "dev\|setup\|install\|start" "$ROOT/Makefile" 2>/dev/null; then
    found "Makefile has dev/setup targets"
  fi
elif [[ -f "$ROOT/makefile" ]] || [[ -f "$ROOT/GNUmakefile" ]]; then
  found "Makefile variant exists"
fi

# Taskfile
if [[ -f "$ROOT/Taskfile.yml" ]] || [[ -f "$ROOT/Taskfile.yaml" ]]; then
  found "Taskfile exists"
fi

# Setup scripts
setup_scripts=$(find "$ROOT" -maxdepth 2 \( -name "setup.*" -o -name "bootstrap.*" -o -name "init.*" -o -name "dev.*" \) -type f 2>/dev/null | head -5)
if [[ -n "$setup_scripts" ]]; then
  while IFS= read -r s; do
    found "Setup script: $(basename "$s")"
  done <<< "$setup_scripts"
fi

# Package.json scripts
if [[ -f "$ROOT/package.json" ]]; then
  if grep -q '"dev"' "$ROOT/package.json" 2>/dev/null; then
    found "npm/yarn dev script defined"
  fi
  if grep -q '"setup"\|"bootstrap"\|"prepare"' "$ROOT/package.json" 2>/dev/null; then
    found "npm/yarn setup/bootstrap script defined"
  fi
fi

# ── M5.3: First-Contribution Guide ────────────────────────────────────────
subheader "M5.3: First-Contribution Guide"

# Check for good-first-issue template or labels reference
if [[ -d "$ROOT/.github" ]]; then
  if find "$ROOT/.github" -name "*.md" -exec grep -l "good.first.issue\|first.contribution\|beginner\|newcomer" {} \; 2>/dev/null | head -1 | grep -q .; then
    found "First-contribution references in .github templates"
  fi

  # Issue templates
  issue_templates=$(find "$ROOT/.github" -name "*.md" -o -name "*.yml" -o -name "*.yaml" 2>/dev/null | grep -i "issue" | head -5)
  if [[ -n "$issue_templates" ]]; then
    found "Issue templates found"
  fi
fi

if [[ -n "$contrib_file" ]] && has_section "$contrib_file" "first\|beginner\|newcomer\|good.first"; then
  found "First-contribution guidance in CONTRIBUTING.md"
else
  missing "No first-contribution guide"
fi

# ── M5.4: Code Review Guidelines ──────────────────────────────────────────
subheader "M5.4: Code Review Guidelines"

# CODEOWNERS
if [[ -f "$ROOT/CODEOWNERS" ]] || [[ -f "$ROOT/.github/CODEOWNERS" ]] || [[ -f "$ROOT/docs/CODEOWNERS" ]]; then
  found "CODEOWNERS file exists"
else
  missing "No CODEOWNERS file"
fi

# PR templates
pr_template=$(find "$ROOT" -maxdepth 3 \( -name "pull_request_template*" -o -name "PULL_REQUEST_TEMPLATE*" \) -type f 2>/dev/null | head -1)
if [[ -n "$pr_template" ]]; then
  found "PR template: ${pr_template#$ROOT/}"
else
  missing "No PR template"
fi

# Review docs
review_doc=false
for candidate in docs/review* docs/code-review* REVIEW.md; do
  if find "$ROOT" -maxdepth 3 -path "$ROOT/$candidate" -type f 2>/dev/null | head -1 | grep -q .; then
    found "Review guidelines document found"
    review_doc=true
    break
  fi
done

if [[ "$review_doc" == "false" ]] && [[ -n "$contrib_file" ]]; then
  if has_section "$contrib_file" "review"; then
    found "Review section in CONTRIBUTING.md"
    review_doc=true
  fi
fi

if [[ "$review_doc" == "false" ]]; then
  missing "No code review guidelines"
fi

echo ""
