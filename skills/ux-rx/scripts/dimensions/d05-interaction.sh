#!/usr/bin/env bash
# d05-interaction.sh — Scan interaction & feedback patterns
source "$(dirname "$0")/../lib/common.sh"

echo "# D05 — INTERACTION & FEEDBACK"
echo ""

section "Loading States"
echo "  Skeleton usage:     $(src_count_matches 'Skeleton|skeleton')"
echo "  Loader/Spinner:     $(src_count_matches 'Loader|Spinner|Loading|isLoading|isPending')"
echo "  loading text:       $(src_count_matches 'Loading\.\.\.|Carregando')"
echo ""

section "Transitions & Animations"
echo "  transition- classes: $(src_count_matches '\btransition-')"
echo "  animate- classes:    $(src_count_matches '\banimate-')"
echo "  motion- (framer):    $(src_count_matches '\bmotion[\.\(]|from.*framer-motion')"
echo "  duration- classes:   $(src_count_matches '\bduration-')"
echo ""

section "Reduced Motion"
REDUCED=$(src_count_files 'prefers-reduced-motion|motion-reduce|motion-safe')
echo "  prefers-reduced-motion handling: $REDUCED files"
echo ""

section "Optimistic Updates"
OPTIMISTIC=$(src_count_files 'optimistic|onMutate.*variables|setQueryData')
echo "  Optimistic update patterns: $OPTIMISTIC files"
echo ""

section "Hover / Active / Focus States"
echo "  hover: classes:  $(src_count_matches '\bhover:')"
echo "  active: classes: $(src_count_matches '\bactive:')"
echo "  focus: classes:  $(src_count_matches '\bfocus:')"
echo "  group-hover:     $(src_count_matches '\bgroup-hover')"
echo ""

section "Toast / Notification"
echo "  sonner/toast:    $(src_count_matches 'toast\(|sonner|useToast')"
echo "  alert patterns:  $(src_count_matches '<Alert[\s>]|alert\(')"
echo ""
