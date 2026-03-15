#!/usr/bin/env bash
# d01-readme.sh — D1: README & Project Overview
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

ROOT="$1"

header "D1: README & Project Overview (15%)"

# ── M1.1: Quick Start ──────────────────────────────────────────────────────
subheader "M1.1: Quick Start"

readme_file=""
for candidate in README.md readme.md README.rst README.txt README; do
  if [[ -f "$ROOT/$candidate" ]]; then
    readme_file="$ROOT/$candidate"
    found "README found: $candidate"
    break
  fi
done

if [[ -z "$readme_file" ]]; then
  missing "No README file found"
else
  # Check for quick start / getting started / installation sections
  if has_section "$readme_file" "quick.start\|getting.started\|installation\|setup"; then
    found "Quick start / Getting started section exists"
  else
    missing "No quick start / getting started section"
  fi

  # Count commands in code blocks (``` sections)
  code_blocks=$(grep -c '```' "$readme_file" 2>/dev/null || echo "0")
  info "Code blocks in README: $code_blocks"

  # Check for one-liner setup
  if grep -qi "docker.compose\|make dev\|npm start\|yarn dev\|pnpm dev\|cargo run" "$readme_file" 2>/dev/null; then
    found "One-liner setup command detected"
  else
    warn "No single setup command (docker-compose/make dev/npm start) found"
  fi
fi

# ── M1.2: Architecture Overview ────────────────────────────────────────────
subheader "M1.2: Architecture Overview"

if [[ -n "$readme_file" ]]; then
  if has_section "$readme_file" "architect\|structure\|overview\|design\|modules\|components"; then
    found "Architecture/structure section in README"
  else
    missing "No architecture section in README"
  fi
fi

# Check for diagrams
diagram_found=false
for ext in png jpg svg mmd puml drawio; do
  diagrams=$(find "$ROOT" -maxdepth 4 -name "*architect*.$ext" -o -name "*diagram*.$ext" -o -name "*overview*.$ext" 2>/dev/null | head -5)
  if [[ -n "$diagrams" ]]; then
    found "Diagram files found (*.$ext)"
    diagram_found=true
    break
  fi
done

# Check for Mermaid in markdown
if [[ -n "$readme_file" ]] && grep -q '```mermaid' "$readme_file" 2>/dev/null; then
  found "Mermaid diagram in README"
  diagram_found=true
fi

if [[ "$diagram_found" == "false" ]]; then
  missing "No architecture diagrams found"
fi

# ── M1.3: Prerequisites Listed ─────────────────────────────────────────────
subheader "M1.3: Prerequisites Listed"

if [[ -n "$readme_file" ]]; then
  if has_section "$readme_file" "prerequisit\|requirement\|depend\|you.will.need\|you.need"; then
    found "Prerequisites section found"
  else
    missing "No prerequisites section"
  fi

  # Check for version mentions
  if grep -qE '(node|npm|python|java|go|rust|ruby)\s*[>=<]+\s*[0-9]' "$readme_file" 2>/dev/null; then
    found "Version requirements specified"
  elif grep -qiE '(node|npm|python|java|go|rust|ruby)\s+[0-9]+\.' "$readme_file" 2>/dev/null; then
    found "Version numbers mentioned (not pinned)"
  else
    warn "No specific version requirements found"
  fi
fi

# Check for .env.example
if [[ -f "$ROOT/.env.example" ]] || [[ -f "$ROOT/.env.sample" ]]; then
  found ".env.example / .env.sample exists"
else
  warn "No .env.example file"
fi

# Check for .tool-versions / .nvmrc / .node-version / .python-version
for vfile in .tool-versions .nvmrc .node-version .python-version .ruby-version rust-toolchain.toml; do
  if [[ -f "$ROOT/$vfile" ]]; then
    found "Version file: $vfile"
  fi
done

# ── M1.4: Badges & Status ──────────────────────────────────────────────────
subheader "M1.4: Badges & Status"

if [[ -n "$readme_file" ]]; then
  badge_count=$(grep -cE '\[!\[.*\]\(.*\)\]\(.*\)|\!\[.*badge.*\]|shields\.io|img\.shields|codecov|coveralls|github\.com/.*workflows.*badge' "$readme_file" 2>/dev/null || echo "0")
  if [[ "$badge_count" -gt 0 ]]; then
    found "Badges found: $badge_count"
  else
    missing "No badges in README"
  fi

  # Check for specific badge types
  if grep -qi "build\|ci\|pipeline\|workflow" "$readme_file" 2>/dev/null && grep -qi "badge\|shield\|status" "$readme_file" 2>/dev/null; then
    found "Build/CI status badge likely present"
  fi

  if grep -qi "coverage\|codecov\|coveralls" "$readme_file" 2>/dev/null; then
    found "Coverage badge likely present"
  fi

  if grep -qi "license" "$readme_file" 2>/dev/null; then
    found "License mentioned"
  fi
fi

# Check for LICENSE file
if [[ -f "$ROOT/LICENSE" ]] || [[ -f "$ROOT/LICENSE.md" ]] || [[ -f "$ROOT/LICENCE" ]]; then
  found "LICENSE file exists"
else
  missing "No LICENSE file"
fi

echo ""
