#!/usr/bin/env bash
# d04-adr.sh — D4: Architecture Decision Records
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

ROOT="$1"

header "D4: Architecture Decision Records (15%)"

# ── M4.1: ADR Practice ────────────────────────────────────────────────────
subheader "M4.1: ADR Practice"

adr_dir=""
for candidate in docs/adr docs/decisions docs/ADR doc/adr doc/decisions adr decisions; do
  if [[ -d "$ROOT/$candidate" ]]; then
    adr_dir="$ROOT/$candidate"
    found "ADR directory: $candidate"
    break
  fi
done

adr_count=0
if [[ -n "$adr_dir" ]]; then
  adr_count=$(find "$adr_dir" -maxdepth 2 -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
  info "ADR files found: $adr_count"

  # Check for numbering pattern
  numbered=$(find "$adr_dir" -maxdepth 2 -name "[0-9]*" -type f 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$numbered" -gt 0 ]]; then
    found "Numbered ADRs: $numbered"
  else
    warn "ADRs not numbered"
  fi

  # Check for template
  if [[ -f "$adr_dir/template.md" ]] || [[ -f "$adr_dir/TEMPLATE.md" ]] || [[ -f "$adr_dir/000-template.md" ]]; then
    found "ADR template exists"
  fi
else
  missing "No ADR directory found (docs/adr/, docs/decisions/)"
fi

# ── M4.2: ADR Completeness ────────────────────────────────────────────────
subheader "M4.2: ADR Completeness"

if [[ -n "$adr_dir" ]] && [[ "$adr_count" -gt 0 ]]; then
  complete=0
  partial=0

  while IFS= read -r adr_file; do
    has_context=false
    has_decision=false
    has_consequences=false
    has_status=false

    if has_section "$adr_file" "context"; then has_context=true; fi
    if has_section "$adr_file" "decision"; then has_decision=true; fi
    if has_section "$adr_file" "consequence\|impact"; then has_consequences=true; fi
    if has_section "$adr_file" "status\|accepted\|rejected\|superseded"; then has_status=true; fi

    if $has_context && $has_decision && $has_consequences; then
      complete=$((complete + 1))
    elif $has_decision; then
      partial=$((partial + 1))
    fi
  done < <(find "$adr_dir" -maxdepth 2 -name "*.md" -not -name "template*" -not -name "TEMPLATE*" -not -name "README*" -type f 2>/dev/null)

  info "Complete ADRs (context+decision+consequences): $complete"
  info "Partial ADRs (decision only): $partial"
  if [[ "$adr_count" -gt 0 ]]; then
    pct=$(percentage "$complete" "$adr_count")
    info "Completeness: ${pct}%"
  fi
else
  missing "No ADRs to evaluate completeness"
fi

# ── M4.3: ADR Currency ────────────────────────────────────────────────────
subheader "M4.3: ADR Currency"

if [[ -n "$adr_dir" ]] && [[ "$adr_count" -gt 0 ]]; then
  # Find most recently modified ADR
  newest=$(find "$adr_dir" -maxdepth 2 -name "*.md" -not -name "template*" -not -name "README*" -type f -exec stat -f "%m %N" {} \; 2>/dev/null | sort -rn | head -1)
  if [[ -n "$newest" ]]; then
    newest_ts=$(echo "$newest" | awk '{print $1}')
    newest_file=$(echo "$newest" | awk '{print $2}')
    now=$(date +%s)
    age_days=$(( (now - newest_ts) / 86400 ))
    info "Most recent ADR: $(basename "$newest_file") ($age_days days ago)"

    if [[ "$age_days" -lt 90 ]]; then
      found "ADR updated within last 3 months"
    elif [[ "$age_days" -lt 180 ]]; then
      warn "Most recent ADR is 3-6 months old"
    elif [[ "$age_days" -lt 365 ]]; then
      warn "Most recent ADR is 6-12 months old"
    else
      warn "Most recent ADR is over 1 year old"
    fi
  fi
else
  missing "No ADRs to check currency"
fi

# ── M4.4: ADR Discoverability ─────────────────────────────────────────────
subheader "M4.4: ADR Discoverability"

if [[ -n "$adr_dir" ]]; then
  # Check for index
  if [[ -f "$adr_dir/README.md" ]] || [[ -f "$adr_dir/INDEX.md" ]] || [[ -f "$adr_dir/index.md" ]]; then
    found "ADR index file exists"
  else
    missing "No ADR index (README.md in ADR dir)"
  fi

  # Check if linked from main README
  for readme in README.md readme.md; do
    if [[ -f "$ROOT/$readme" ]]; then
      if grep -qi "adr\|decision.record\|architecture.decision" "$ROOT/$readme" 2>/dev/null; then
        found "ADR referenced in project README"
      else
        missing "ADR not linked from project README"
      fi
      break
    fi
  done
else
  missing "No ADR directory to evaluate discoverability"
fi

echo ""
