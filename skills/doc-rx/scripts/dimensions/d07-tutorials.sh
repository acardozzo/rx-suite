#!/usr/bin/env bash
# d07-tutorials.sh — D7: Tutorials & Guides
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

ROOT="$1"

header "D7: Tutorials & Guides (10%)"

# ── M7.1: Tutorial Exists ─────────────────────────────────────────────────
subheader "M7.1: Tutorial Exists"

tutorial_found=false
for candidate in docs/tutorial* docs/getting-started* docs/quickstart* tutorial* TUTORIAL* guide/getting-started*; do
  matches=$(find "$ROOT" -maxdepth 3 -path "$ROOT/$candidate" -type f 2>/dev/null | head -3)
  if [[ -n "$matches" ]]; then
    while IFS= read -r m; do
      found "Tutorial: ${m#$ROOT/}"
      tutorial_found=true
    done <<< "$matches"
    break
  fi
done

# Check for tutorial directories
for d in tutorials tutorial docs/tutorials docs/guides guides; do
  if [[ -d "$ROOT/$d" ]]; then
    count=$(find "$ROOT/$d" -type f -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    found "Tutorial directory: $d/ ($count files)"
    tutorial_found=true
    break
  fi
done

if [[ "$tutorial_found" == "false" ]]; then
  missing "No tutorials found"
fi

# ── M7.2: How-To Guides ───────────────────────────────────────────────────
subheader "M7.2: How-To Guides"

howto_found=false
for candidate in docs/how-to* docs/howto* docs/recipes* docs/cookbook*; do
  matches=$(find "$ROOT" -maxdepth 3 -path "$ROOT/$candidate" 2>/dev/null | head -3)
  if [[ -n "$matches" ]]; then
    while IFS= read -r m; do
      found "How-to: ${m#$ROOT/}"
      howto_found=true
    done <<< "$matches"
    break
  fi
done

# Check for FAQ
for candidate in FAQ.md faq.md docs/FAQ.md docs/faq.md; do
  if [[ -f "$ROOT/$candidate" ]]; then
    found "FAQ file: $candidate"
    howto_found=true
    break
  fi
done

# Check for troubleshooting
for candidate in TROUBLESHOOTING.md docs/troubleshooting* docs/debug*; do
  match=$(find "$ROOT" -maxdepth 3 -path "$ROOT/$candidate" -type f 2>/dev/null | head -1)
  if [[ -n "$match" ]]; then
    found "Troubleshooting guide: ${match#$ROOT/}"
    howto_found=true
    break
  fi
done

if [[ "$howto_found" == "false" ]]; then
  missing "No how-to guides, FAQ, or troubleshooting docs"
fi

# ── M7.3: Explanation Docs ────────────────────────────────────────────────
subheader "M7.3: Explanation Docs"

explanation_found=false

# Check for design docs, architecture explanations, concepts
for candidate in docs/design* docs/concepts* docs/architecture* docs/explanation* docs/rationale* docs/why*; do
  matches=$(find "$ROOT" -maxdepth 3 -path "$ROOT/$candidate" 2>/dev/null | head -3)
  if [[ -n "$matches" ]]; then
    while IFS= read -r m; do
      found "Explanation doc: ${m#$ROOT/}"
      explanation_found=true
    done <<< "$matches"
    break
  fi
done

# Check for RFCs
if [[ -d "$ROOT/docs/rfcs" ]] || [[ -d "$ROOT/rfcs" ]] || [[ -d "$ROOT/docs/rfc" ]]; then
  found "RFC directory found"
  explanation_found=true
fi

if [[ "$explanation_found" == "false" ]]; then
  missing "No explanation/conceptual documentation"
fi

# ── M7.4: Reference Docs ──────────────────────────────────────────────────
subheader "M7.4: Reference Docs"

reference_found=false

# Check for auto-generated docs
for candidate in docs/api-reference* docs/reference* docs/generated* api-docs site/docs; do
  match=$(find "$ROOT" -maxdepth 3 -path "$ROOT/$candidate" 2>/dev/null | head -1)
  if [[ -n "$match" ]]; then
    found "Reference docs: ${match#$ROOT/}"
    reference_found=true
    break
  fi
done

# Check for doc generation tools
if [[ -f "$ROOT/package.json" ]]; then
  if grep -qE 'typedoc|jsdoc|documentation\.js|docusaurus|vitepress|nextra|mintlify|starlight' "$ROOT/package.json" 2>/dev/null; then
    found "Documentation generation tool configured"
    reference_found=true
  fi
fi

# Check for typedoc/jsdoc config
for config in typedoc.json typedoc.js .typedoc.json jsdoc.json jsdoc.conf.json .jsdoc.json; do
  if [[ -f "$ROOT/$config" ]]; then
    found "Doc generator config: $config"
    reference_found=true
    break
  fi
done

# Check for docs site config
for config in docusaurus.config.js docusaurus.config.ts docs/.vitepress mintlify.json starlight.config.mjs; do
  match=$(find "$ROOT" -maxdepth 2 -name "$(basename "$config")" -type f 2>/dev/null | head -1)
  if [[ -n "$match" ]]; then
    found "Documentation site: $(basename "$config")"
    reference_found=true
    break
  fi
done

if [[ "$reference_found" == "false" ]]; then
  missing "No reference documentation or doc generation setup"
fi

echo ""
