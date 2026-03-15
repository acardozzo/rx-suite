#!/usr/bin/env bash
# D4: Stale Configuration — Unused env vars, stale configs, dead scripts, dead CI steps

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

PROJECT_ROOT="${1:-.}"
detect_stacks "$PROJECT_ROOT"
detect_tools

section_header "D4" "Stale Configuration (10%)"

# ─── M4.1: Unused Environment Variables ───
metric_header "M4.1" "Unused Environment Variables"

UNUSED_ENV=0
ENV_FILES=("$PROJECT_ROOT/.env" "$PROJECT_ROOT/.env.example" "$PROJECT_ROOT/.env.local" "$PROJECT_ROOT/.env.development")
for envfile in "${ENV_FILES[@]}"; do
  [[ -f "$envfile" ]] || continue
  while IFS= read -r line; do
    [[ -z "$line" || "$line" == \#* ]] && continue
    VAR_NAME=$(echo "$line" | cut -d= -f1 | tr -d ' ')
    [[ -z "$VAR_NAME" ]] && continue
    # Check if used in source code
    USED=$(grep -rl "$VAR_NAME" \
      --include='*.ts' --include='*.tsx' --include='*.js' --include='*.py' \
      --include='*.yml' --include='*.yaml' \
      --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
      "$PROJECT_ROOT" 2>/dev/null | grep -v ".env" | head -1 || true)
    if [[ -z "$USED" ]]; then
      ((UNUSED_ENV++)) || true
      finding "TIER2" "M4.1" "Unused env var: $VAR_NAME" "$envfile"
    fi
  done < "$envfile"
  break  # Only check first found env file
done
finding "INFO" "M4.1" "$UNUSED_ENV unused environment variables"

# ─── M4.2: Stale Config Files ───
metric_header "M4.2" "Stale Config Files"

STALE_CONFIGS=0
# Check for config files whose tools are not installed
declare -A CONFIG_TOOL_MAP
CONFIG_TOOL_MAP[".babelrc"]="@babel/core"
CONFIG_TOOL_MAP["babel.config.js"]="@babel/core"
CONFIG_TOOL_MAP[".prettierrc"]="prettier"
CONFIG_TOOL_MAP["prettier.config.js"]="prettier"
CONFIG_TOOL_MAP[".stylelintrc"]="stylelint"
CONFIG_TOOL_MAP["jest.config.js"]="jest"
CONFIG_TOOL_MAP["jest.config.ts"]="jest"
CONFIG_TOOL_MAP[".mocharc.yml"]="mocha"
CONFIG_TOOL_MAP["webpack.config.js"]="webpack"
CONFIG_TOOL_MAP[".huskyrc"]="husky"
CONFIG_TOOL_MAP["commitlint.config.js"]="@commitlint/cli"

for config in "${!CONFIG_TOOL_MAP[@]}"; do
  if [[ -f "$PROJECT_ROOT/$config" ]]; then
    tool="${CONFIG_TOOL_MAP[$config]}"
    if $STACK_TYPESCRIPT && [[ -f "$PROJECT_ROOT/package.json" ]]; then
      HAS_DEP=$(grep -q "\"$tool\"" "$PROJECT_ROOT/package.json" 2>/dev/null && echo "yes" || echo "no")
      if [[ "$HAS_DEP" == "no" ]]; then
        ((STALE_CONFIGS++)) || true
        finding "TIER1" "M4.2" "Config file '$config' exists but '$tool' not in package.json"
      fi
    fi
  fi
done
finding "INFO" "M4.2" "$STALE_CONFIGS stale config files"

# ─── M4.3: Unused Scripts ───
metric_header "M4.3" "Unused Scripts in package.json"

UNUSED_SCRIPTS=0
if $STACK_TYPESCRIPT && [[ -f "$PROJECT_ROOT/package.json" ]]; then
  SCRIPTS=$(python3 -c "
import json
with open('$PROJECT_ROOT/package.json') as f:
    p = json.load(f)
    for s in p.get('scripts', {}).keys():
        print(s)
" 2>/dev/null || true)
  # Well-known scripts that are always "used"
  KNOWN_SCRIPTS="dev|build|start|test|lint|format|preview|deploy|postinstall|preinstall|prepare"
  if [[ -n "$SCRIPTS" ]]; then
    while IFS= read -r script; do
      echo "$script" | grep -qE "^($KNOWN_SCRIPTS)$" && continue
      # Check if referenced in CI, README, or other scripts
      REFERENCED=$(grep -rl "$script" \
        --include='*.yml' --include='*.yaml' --include='*.md' --include='*.json' \
        --include='Makefile' --include='Dockerfile*' \
        --exclude-dir=node_modules --exclude-dir=.git \
        "$PROJECT_ROOT" 2>/dev/null | head -1 || true)
      if [[ -z "$REFERENCED" ]]; then
        ((UNUSED_SCRIPTS++)) || true
        finding "TIER2" "M4.3" "Script '$script' not referenced in CI/docs"
      fi
    done <<< "$SCRIPTS"
  fi
fi
finding "INFO" "M4.3" "$UNUSED_SCRIPTS unused scripts"

# ─── M4.4: Dead CI/CD Steps ───
metric_header "M4.4" "Dead CI/CD Steps"

DEAD_CI=0
CI_FILES=$(find "$PROJECT_ROOT" -maxdepth 3 \( -path "*/.github/workflows/*.yml" -o -path "*/.github/workflows/*.yaml" \
  -o -name ".gitlab-ci.yml" -o -name "Jenkinsfile" -o -name "bitbucket-pipelines.yml" \) \
  -not -path "*/node_modules/*" 2>/dev/null || true)
if [[ -n "$CI_FILES" ]]; then
  while IFS= read -r ci_file; do
    [[ -z "$ci_file" ]] && continue
    # Check for script references to non-existent files
    SCRIPT_REFS=$(grep -oP "(?:run:|script:)\s*\K.*" "$ci_file" 2>/dev/null || true)
    if [[ -n "$SCRIPT_REFS" ]]; then
      while IFS= read -r ref; do
        # Extract file paths from commands
        FILE_REF=$(echo "$ref" | grep -oP '\./[^\s]+|scripts/[^\s]+' || true)
        if [[ -n "$FILE_REF" && ! -f "$PROJECT_ROOT/$FILE_REF" ]]; then
          ((DEAD_CI++)) || true
          finding "TIER2" "M4.4" "CI references non-existent: $FILE_REF" "$ci_file"
        fi
      done <<< "$SCRIPT_REFS"
    fi
  done <<< "$CI_FILES"
fi
finding "INFO" "M4.4" "$DEAD_CI dead CI/CD steps"

echo ""
echo -e "  ${BOLD}D4 Raw Totals:${NC} unused_env=$UNUSED_ENV stale_configs=$STALE_CONFIGS unused_scripts=$UNUSED_SCRIPTS dead_ci=$DEAD_CI"
