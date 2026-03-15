#!/usr/bin/env bash
# D10: Git & Repository Hygiene — Large files, secrets, .gitignore gaps, stale branches

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

PROJECT_ROOT="${1:-.}"
detect_stacks "$PROJECT_ROOT"

section_header "D10" "Git & Repository Hygiene (9%)"

cd "$PROJECT_ROOT"

# ─── M10.1: Large Files in Git ───
metric_header "M10.1" "Large Files (> 1MB) in Git"

LARGE_FILES=0
LARGE_LIST=$(find_large_files "$PROJECT_ROOT")
if [[ -n "$LARGE_LIST" ]]; then
  LARGE_FILES=$(echo "$LARGE_LIST" | wc -l | tr -d ' ')
  while IFS= read -r lf; do
    finding "TIER2" "M10.1" "Large file in git: $lf"
  done <<< "$LARGE_LIST"
else
  finding "INFO" "M10.1" "No files > 1MB tracked in git"
fi
finding "INFO" "M10.1" "$LARGE_FILES large files in repository"

# ─── M10.2: Secrets in Tracked Files ───
metric_header "M10.2" "Secrets in Tracked Files"

SECRETS_FOUND=0
# Common secret patterns in tracked files (exclude .env files which are expected)
SECRET_PATTERNS=(
  "AKIA[0-9A-Z]{16}"                          # AWS Access Key
  "sk-[a-zA-Z0-9]{32,}"                       # OpenAI/Stripe secret key
  "ghp_[a-zA-Z0-9]{36}"                       # GitHub PAT
  "glpat-[a-zA-Z0-9_-]{20,}"                  # GitLab PAT
  "xox[baprs]-[a-zA-Z0-9-]+"                  # Slack token
  "password\s*[:=]\s*['\"][^'\"]{8,}"          # Hardcoded passwords
  "secret\s*[:=]\s*['\"][^'\"]{8,}"            # Hardcoded secrets
  "api[_-]?key\s*[:=]\s*['\"][a-zA-Z0-9]{16,}" # API keys
)

TRACKED_FILES=$(git ls-files 2>/dev/null | grep -v "\.env\|\.lock\|node_modules\|\.git" || true)
for pattern in "${SECRET_PATTERNS[@]}"; do
  MATCHES=$(echo "$TRACKED_FILES" | xargs grep -rn -E "$pattern" 2>/dev/null \
    | grep -v "\.env\|test\|mock\|fixture\|example\|sample\|template" \
    | head -5 || true)
  if [[ -n "$MATCHES" ]]; then
    MATCH_COUNT=$(echo "$MATCHES" | wc -l | tr -d ' ')
    SECRETS_FOUND=$((SECRETS_FOUND + MATCH_COUNT))
    while IFS= read -r line; do
      file=$(echo "$line" | cut -d: -f1)
      lineno=$(echo "$line" | cut -d: -f2)
      finding "TIER3" "M10.2" "Possible secret pattern detected" "$file" "$lineno"
    done <<< "$MATCHES"
  fi
done
finding "INFO" "M10.2" "$SECRETS_FOUND potential secrets in tracked files"

# ─── M10.3: .gitignore Gaps ───
metric_header "M10.3" ".gitignore Gaps"

GITIGNORE_GAPS=0
GITIGNORE="$PROJECT_ROOT/.gitignore"

# Expected entries by stack
EXPECTED_ALL=(".env" ".env.local" ".DS_Store" "*.log")
EXPECTED_NODE=("node_modules" "dist" ".next" "coverage" ".turbo")
EXPECTED_PYTHON=("__pycache__" "*.pyc" ".venv" "venv" ".mypy_cache" ".ruff_cache")
EXPECTED_SUPABASE=(".temp" ".branches")

check_gitignore() {
  local entry="$1"
  if [[ -f "$GITIGNORE" ]]; then
    grep -q "$entry" "$GITIGNORE" 2>/dev/null && return 0
  fi
  return 1
}

for entry in "${EXPECTED_ALL[@]}"; do
  if ! check_gitignore "$entry"; then
    ((GITIGNORE_GAPS++)) || true
    finding "TIER1" "M10.3" "Missing .gitignore entry: $entry"
  fi
done

if $STACK_TYPESCRIPT; then
  for entry in "${EXPECTED_NODE[@]}"; do
    if ! check_gitignore "$entry"; then
      ((GITIGNORE_GAPS++)) || true
      finding "TIER1" "M10.3" "Missing .gitignore entry (Node): $entry"
    fi
  done
fi

if $STACK_PYTHON; then
  for entry in "${EXPECTED_PYTHON[@]}"; do
    if ! check_gitignore "$entry"; then
      ((GITIGNORE_GAPS++)) || true
      finding "TIER1" "M10.3" "Missing .gitignore entry (Python): $entry"
    fi
  done
fi

if $STACK_SUPABASE; then
  for entry in "${EXPECTED_SUPABASE[@]}"; do
    if ! check_gitignore "$entry"; then
      ((GITIGNORE_GAPS++)) || true
      finding "TIER1" "M10.3" "Missing .gitignore entry (Supabase): $entry"
    fi
  done
fi
finding "INFO" "M10.3" "$GITIGNORE_GAPS .gitignore gaps"

# ─── M10.4: Stale Branches ───
metric_header "M10.4" "Stale Branches"

STALE_BRANCHES=0
# Merged branches (excluding main, master, develop)
MERGED=$(git branch --merged 2>/dev/null | grep -v "^\*\|main\|master\|develop\|release" | wc -l | tr -d ' ')
STALE_BRANCHES=$((STALE_BRANCHES + MERGED))
[[ "$MERGED" -gt 0 ]] && finding "TIER1" "M10.4" "$MERGED merged branches can be deleted"

# Remote branches not updated in 30+ days
OLD_BRANCHES=$(git for-each-ref --sort=-committerdate --format='%(refname:short) %(committerdate:relative)' refs/heads/ 2>/dev/null \
  | grep -E "(months?|years?) ago" | grep -v "main\|master\|develop" | wc -l | tr -d ' ')
STALE_BRANCHES=$((STALE_BRANCHES + OLD_BRANCHES))
[[ "$OLD_BRANCHES" -gt 0 ]] && finding "TIER2" "M10.4" "$OLD_BRANCHES branches with no recent commits"

finding "INFO" "M10.4" "$STALE_BRANCHES stale branches total"

echo ""
echo -e "  ${BOLD}D10 Raw Totals:${NC} large_files=$LARGE_FILES secrets=$SECRETS_FOUND gitignore_gaps=$GITIGNORE_GAPS stale_branches=$STALE_BRANCHES"
