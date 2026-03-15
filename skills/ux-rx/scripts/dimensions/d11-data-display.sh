#!/usr/bin/env bash
# d11-data-display.sh — Scan data display & table patterns
source "$(dirname "$0")/../lib/common.sh"

echo "# D11 — DATA DISPLAY"
echo ""

section "Table Components"
echo "  shadcn <Table>:      $(src_count_matches '<Table[\s>]')"
echo "  <TableHeader>:       $(src_count_matches '<TableHeader')"
echo "  <TableBody>:         $(src_count_matches '<TableBody')"
echo "  <TableRow>:          $(src_count_matches '<TableRow')"
echo "  <TableCell>:         $(src_count_matches '<TableCell')"
echo "  Raw <table>:         $(src_count_matches '<table[\s>]')"
echo ""

section "TanStack Table"
echo "  @tanstack/react-table: $(src_count_files "from ['\"]@tanstack/react-table")"
echo "  useReactTable:         $(src_count_matches 'useReactTable')"
echo "  getCoreRowModel:       $(src_count_matches 'getCoreRowModel')"
echo "  ColumnDef:             $(src_count_matches 'ColumnDef')"
echo ""

section "Pagination"
echo "  shadcn Pagination:   $(src_count_matches '<Pagination')"
echo "  Page size select:    $(src_count_matches 'pageSize\|perPage\|per_page\|limit.*select')"
echo "  Cursor pagination:   $(src_count_matches 'cursor\|nextCursor\|hasNextPage')"
echo ""

section "Search & Filtering"
echo "  Search inputs:       $(src_count_files 'search.*input\|SearchInput\|type=.search\|onSearch')"
echo "  Filter patterns:     $(src_count_files 'filter\|Filter.*select\|FilterBar')"
echo "  Debounce:            $(src_count_matches 'debounce\|useDebounce')"
echo ""

section "Sorting"
echo "  Sort indicators:     $(src_count_matches 'sort\|Sort.*icon\|ArrowUpDown\|SortAsc\|SortDesc')"
echo "  getSortedRowModel:   $(src_count_matches 'getSortedRowModel')"
echo ""

section "Charts & Visualization"
echo "  recharts:            $(src_count_files "from ['\"]recharts")"
echo "  shadcn Chart:        $(src_count_files "from.*chart\|<Chart")"
echo "  d3:                  $(src_count_files "from ['\"]d3")"
echo "  chart.js:            $(src_count_files "from ['\"]chart")"
echo ""

section "Virtual Scrolling"
echo "  react-window:        $(src_count_files "from ['\"]react-window")"
echo "  react-virtuoso:      $(src_count_files "from ['\"]react-virtuoso")"
echo "  tanstack-virtual:    $(src_count_files "from ['\"]@tanstack/react-virtual")"
echo ""
