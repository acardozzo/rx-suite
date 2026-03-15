#!/usr/bin/env bash
# d06-changelog.sh — D6: Changelog & Versioning
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

ROOT="$1"

header "D6: Changelog & Versioning (10%)"

# ── M6.1: Changelog Maintenance ───────────────────────────────────────────
subheader "M6.1: Changelog Maintenance"

changelog_file=""
for candidate in CHANGELOG.md changelog.md CHANGELOG.rst CHANGES.md HISTORY.md; do
  if [[ -f "$ROOT/$candidate" ]]; then
    changelog_file="$ROOT/$candidate"
    found "Changelog file: $candidate"
    break
  fi
done

if [[ -n "$changelog_file" ]]; then
  # Check format (Keep a Changelog)
  if grep -qi "all notable changes\|keep.a.changelog\|unreleased" "$changelog_file" 2>/dev/null; then
    found "Follows Keep a Changelog format"
  else
    info "Does not follow standard Keep a Changelog format"
  fi

  # Count versions/releases
  version_count=$(grep -cE '##\s+\[?[0-9]+\.[0-9]+' "$changelog_file" 2>/dev/null || echo "0")
  info "Version entries: $version_count"

  # Check recency
  line_count=$(wc -l < "$changelog_file" | tr -d ' ')
  info "Changelog lines: $line_count"
else
  missing "No CHANGELOG.md found"
fi

# Check for auto-generation tools
if [[ -f "$ROOT/package.json" ]]; then
  if grep -qE 'standard-version|conventional-changelog|semantic-release|release-it|changeset|auto-changelog' "$ROOT/package.json" 2>/dev/null; then
    found "Changelog auto-generation tool configured"
  fi
fi

if [[ -d "$ROOT/.changeset" ]]; then
  found "Changesets directory exists (.changeset/)"
fi

# ── M6.2: Conventional Commits ────────────────────────────────────────────
subheader "M6.2: Conventional Commits"

if command -v git &>/dev/null && [[ -d "$ROOT/.git" ]]; then
  # Sample last 50 commits
  total_commits=50
  conventional=0
  recent_commits=$(cd "$ROOT" && git log --oneline -n "$total_commits" --format="%s" 2>/dev/null)

  if [[ -n "$recent_commits" ]]; then
    while IFS= read -r msg; do
      if echo "$msg" | grep -qE '^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\(.+\))?(!)?:'; then
        conventional=$((conventional + 1))
      fi
    done <<< "$recent_commits"

    pct=$(percentage "$conventional" "$total_commits")
    info "Conventional commits in last $total_commits: $conventional ($pct%)"

    if [[ "$pct" -ge 80 ]]; then
      found "Strong conventional commit adoption (>= 80%)"
    elif [[ "$pct" -ge 50 ]]; then
      warn "Moderate conventional commit adoption (50-79%)"
    else
      warn "Low conventional commit adoption (< 50%)"
    fi
  fi

  # Check for commitlint / husky
  if [[ -f "$ROOT/commitlint.config.js" ]] || [[ -f "$ROOT/commitlint.config.ts" ]] || [[ -f "$ROOT/.commitlintrc.js" ]] || [[ -f "$ROOT/.commitlintrc.json" ]]; then
    found "commitlint configured"
  fi

  if [[ -d "$ROOT/.husky" ]]; then
    found "Husky git hooks configured"
    if [[ -f "$ROOT/.husky/commit-msg" ]]; then
      found "commit-msg hook exists"
    fi
  fi
else
  warn "Not a git repository, cannot analyze commits"
fi

# ── M6.3: Semantic Versioning ─────────────────────────────────────────────
subheader "M6.3: Semantic Versioning"

# Check package.json version
if [[ -f "$ROOT/package.json" ]]; then
  version=$(grep -oE '"version"\s*:\s*"[0-9]+\.[0-9]+\.[0-9]+[^"]*"' "$ROOT/package.json" 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+[^"]*')
  if [[ -n "$version" ]]; then
    found "Package version: $version (SemVer format)"
  else
    warn "No SemVer version in package.json"
  fi
fi

# Check Cargo.toml version
if [[ -f "$ROOT/Cargo.toml" ]]; then
  version=$(grep -E '^version\s*=' "$ROOT/Cargo.toml" 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
  if [[ -n "$version" ]]; then
    found "Cargo version: $version"
  fi
fi

# Check git tags
if command -v git &>/dev/null && [[ -d "$ROOT/.git" ]]; then
  tag_count=$(cd "$ROOT" && git tag -l 2>/dev/null | grep -cE '^v?[0-9]+\.[0-9]+' || echo "0")
  info "SemVer git tags: $tag_count"
fi

# ── M6.4: Release Notes ───────────────────────────────────────────────────
subheader "M6.4: Release Notes"

# Check for GitHub releases (via .github or release configs)
if [[ -f "$ROOT/.github/release.yml" ]] || [[ -f "$ROOT/.github/release.yaml" ]]; then
  found "GitHub release configuration exists"
fi

if [[ -f "$ROOT/.releaserc" ]] || [[ -f "$ROOT/.releaserc.json" ]] || [[ -f "$ROOT/.releaserc.js" ]] || [[ -f "$ROOT/release.config.js" ]]; then
  found "semantic-release configuration exists"
fi

# Check if release notes directory exists
if [[ -d "$ROOT/docs/releases" ]] || [[ -d "$ROOT/releases" ]]; then
  found "Release notes directory found"
fi

# Check for breaking change documentation
if [[ -n "$changelog_file" ]]; then
  breaking=$(grep -ci "breaking\|BREAKING" "$changelog_file" 2>/dev/null || echo "0")
  if [[ "$breaking" -gt 0 ]]; then
    found "Breaking changes documented in changelog ($breaking mentions)"
  fi

  migration=$(grep -ci "migrat\|upgrade\|upgrad" "$changelog_file" 2>/dev/null || echo "0")
  if [[ "$migration" -gt 0 ]]; then
    found "Migration/upgrade guidance in changelog"
  fi
fi

echo ""
