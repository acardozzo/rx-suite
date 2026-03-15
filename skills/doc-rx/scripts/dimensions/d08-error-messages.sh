#!/usr/bin/env bash
# d08-error-messages.sh — D8: Error Messages & User-Facing Text
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

ROOT="$1"

header "D8: Error Messages & User-Facing Text (10%)"

# Determine source directories
src_dirs=()
for d in src lib app packages components utils helpers services; do
  if [[ -d "$ROOT/$d" ]]; then
    src_dirs+=("$ROOT/$d")
  fi
done
if [[ ${#src_dirs[@]} -eq 0 ]]; then
  src_dirs=("$ROOT")
fi

# ── M8.1: Error Message Quality ───────────────────────────────────────────
subheader "M8.1: Error Message Quality"

# Count error patterns
generic_errors=0
actionable_errors=0
raw_stack_traces=0

for sd in "${src_dirs[@]}"; do
  # Generic/unhelpful errors
  generic_errors=$((generic_errors + $(grep -rcE '(Something went wrong|An error occurred|Error|Unknown error|Unexpected error|Internal error)["'"'"'`]' "$sd" --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" 2>/dev/null | tail -1 | awk -F: '{sum+=$NF} END {print sum+0}')))

  # Actionable errors (contain hints like "please", "try", "check", "make sure", "ensure")
  actionable_errors=$((actionable_errors + $(grep -rcEi '(please|try |check |make sure|ensure |verify |must |should )' "$sd" --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" 2>/dev/null | grep -i 'error\|throw\|reject\|fail' | tail -1 | awk -F: '{sum+=$NF} END {print sum+0}')))

  # Stack trace exposure patterns
  raw_stack_traces=$((raw_stack_traces + $(grep -rcE '(\.stack|stackTrace|stack_trace|console\.error\(err\)|res\.(send|json)\(err\))' "$sd" --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" 2>/dev/null | tail -1 | awk -F: '{sum+=$NF} END {print sum+0}')))
done

info "Generic error messages: $generic_errors"
info "Actionable error patterns: $actionable_errors"
if [[ "$raw_stack_traces" -gt 0 ]]; then
  warn "Potential stack trace exposure: $raw_stack_traces instances"
else
  found "No obvious stack trace exposure patterns"
fi

# Check for error boundary / error handling components
error_components=$(find "$ROOT" -maxdepth 5 \( -name "*error*boundary*" -o -name "*error*handler*" -o -name "*error*page*" -o -name "error.tsx" -o -name "error.jsx" \) -type f 2>/dev/null | head -5)
if [[ -n "$error_components" ]]; then
  found "Error handling components found"
  while IFS= read -r ec; do
    info "  ${ec#$ROOT/}"
  done <<< "$error_components"
fi

# ── M8.2: CLI/Terminal UX ─────────────────────────────────────────────────
subheader "M8.2: CLI/Terminal UX"

# Check for CLI entry points
cli_files=$(find "$ROOT" -maxdepth 4 \( -name "cli.*" -o -name "command.*" -o -name "cmd.*" \) \( -name "*.ts" -o -name "*.js" -o -name "*.py" -o -name "*.go" \) -type f 2>/dev/null | head -5)

has_cli=false
if [[ -n "$cli_files" ]]; then
  has_cli=true
  found "CLI entry points found"

  # Check for help text
  help_text=0
  for cf in $cli_files; do
    if grep -qE '(--help|\.help\(|description:|usage:|\.option\(|\.command\()' "$cf" 2>/dev/null; then
      help_text=$((help_text + 1))
    fi
  done
  info "CLI files with help text: $help_text"
fi

# Check for CLI frameworks
if [[ -f "$ROOT/package.json" ]]; then
  if grep -qE 'commander|yargs|inquirer|ora|chalk|cli-table|meow|oclif|clipanion' "$ROOT/package.json" 2>/dev/null; then
    found "CLI framework/UX library in dependencies"
    has_cli=true
  fi
fi

# Check bin entry
if [[ -f "$ROOT/package.json" ]]; then
  if grep -q '"bin"' "$ROOT/package.json" 2>/dev/null; then
    found "bin entry in package.json"
    has_cli=true
  fi
fi

if [[ "$has_cli" == "false" ]]; then
  info "No CLI detected (may not be applicable)"
fi

# ── M8.3: Log Message Quality ─────────────────────────────────────────────
subheader "M8.3: Log Message Quality"

# Check for structured logging
structured_logging=false

if [[ -f "$ROOT/package.json" ]]; then
  if grep -qE 'pino|winston|bunyan|log4js|roarr|signale' "$ROOT/package.json" 2>/dev/null; then
    found "Structured logging library in dependencies"
    structured_logging=true
  fi
fi

# Count console.log usage
console_logs=0
for sd in "${src_dirs[@]}"; do
  console_logs=$((console_logs + $(grep -rc 'console\.\(log\|warn\|error\|info\|debug\)' "$sd" --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" 2>/dev/null | tail -1 | awk -F: '{sum+=$NF} END {print sum+0}')))
done
info "console.* calls in source: $console_logs"

# Check for logger module
logger_file=$(find "$ROOT" -maxdepth 5 \( -name "logger.*" -o -name "logging.*" -o -name "log.*" \) \( -name "*.ts" -o -name "*.js" \) -not -path "*/node_modules/*" -type f 2>/dev/null | head -3)
if [[ -n "$logger_file" ]]; then
  found "Custom logger module found"
  while IFS= read -r lf; do
    info "  ${lf#$ROOT/}"
  done <<< "$logger_file"
fi

# Check for request ID / correlation ID patterns
for sd in "${src_dirs[@]}"; do
  if grep -rq 'requestId\|request_id\|correlationId\|correlation_id\|traceId\|trace_id\|x-request-id' "$sd" --include="*.ts" --include="*.js" 2>/dev/null; then
    found "Request/correlation ID pattern detected"
    break
  fi
done

# ── M8.4: User-Facing Copy ────────────────────────────────────────────────
subheader "M8.4: User-Facing Copy"

# Check for i18n setup
i18n_found=false
if [[ -f "$ROOT/package.json" ]]; then
  if grep -qE 'i18next|react-intl|next-intl|vue-i18n|formatjs|lingui|@internationalized' "$ROOT/package.json" 2>/dev/null; then
    found "i18n library in dependencies"
    i18n_found=true
  fi
fi

# Check for locale/translation files
locale_dirs=$(find "$ROOT" -maxdepth 4 \( -name "locales" -o -name "locale" -o -name "translations" -o -name "i18n" -o -name "messages" \) -type d 2>/dev/null | head -3)
if [[ -n "$locale_dirs" ]]; then
  found "Locale/translation directory found"
  while IFS= read -r ld; do
    locale_files=$(find "$ld" -type f 2>/dev/null | wc -l | tr -d ' ')
    info "  ${ld#$ROOT/} ($locale_files files)"
  done <<< "$locale_dirs"
  i18n_found=true
fi

if [[ "$i18n_found" == "false" ]]; then
  info "No i18n setup detected (may not be needed)"
fi

# Check for hardcoded strings in components
hardcoded_strings=0
for sd in "${src_dirs[@]}"; do
  # Look for JSX text content (rough heuristic)
  hardcoded_strings=$((hardcoded_strings + $(grep -rcE '>[A-Z][a-z]+ [a-z]+' "$sd" --include="*.tsx" --include="*.jsx" 2>/dev/null | tail -1 | awk -F: '{sum+=$NF} END {print sum+0}')))
done
if [[ "$hardcoded_strings" -gt 0 ]]; then
  info "Approximate hardcoded strings in JSX: $hardcoded_strings"
fi

echo ""
