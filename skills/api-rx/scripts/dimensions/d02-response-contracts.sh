#!/usr/bin/env bash
# d02-response-contracts.sh — Scan response consistency & contract patterns
source "$(dirname "$0")/../lib/common.sh"

echo "# D02 — RESPONSE CONSISTENCY & CONTRACTS"
echo ""

section "M2.1 Response Envelope Consistency"
echo "  Response wrapper/envelope patterns: $(src_count_matches 'data:|\"data\":|meta:|\"meta\":|pagination:|\"pagination\":')"
echo "  Shared response builder: $(src_count_files 'createResponse|sendResponse|apiResponse|formatResponse|ResponseHelper|BaseResponse|ApiResponse')"
echo "  Raw array returns: $(src_count_matches 'res\.(json|send)\(\[|return\s+\[|JSON\.stringify\(\[')"
echo "  Envelope enforcement middleware: $(src_count_files 'responseInterceptor|transformResponse|serialize|ResponseMiddleware')"
echo ""

section "M2.2 Error Response Format"
echo "  Structured error classes: $(src_count_files 'ApiError|HttpException|AppError|CustomError|ServiceError|DomainError')"
echo "  RFC 7807 Problem Details: $(src_count_matches 'problem.*detail|application/problem|ProblemDetail|problemDetails')"
echo "  Error code constants: $(src_count_files 'ErrorCode|ERROR_CODE|error_codes|ErrorType')"
echo "  Field-level validation errors: $(src_count_matches 'field.*error|errors\[|validation.*error|fieldErrors')"
echo "  i18n error keys: $(src_count_matches 'error\..*\.message|i18n.*error|errorKey|message_key')"
echo "  Global error handler: $(src_count_files 'errorHandler|exceptionFilter|error-handler|exception-handler')"
echo ""

section "M2.3 Pagination Pattern"
echo "  Cursor-based pagination: $(src_count_matches 'cursor|after.*before|startCursor|endCursor')"
echo "  Offset pagination: $(src_count_matches 'offset.*limit|page.*per_page|pageSize|page_size|skip.*take')"
echo "  Total count in response: $(src_count_matches 'totalCount|total_count|totalItems|total_items|total:|\"total\"')"
echo "  Next/prev links: $(src_count_matches 'nextPage|next_page|prevPage|prev_page|hasMore|has_more|hasNextPage')"
echo "  Pagination helper/util: $(src_count_files 'paginate|Pagination|PaginationHelper|paginateQuery')"
echo ""

section "M2.4 Sparse Fields & Filtering"
echo "  Field selection (fields param): $(src_count_matches 'fields=|select\(|\.select\b|\$select|sparseFields')"
echo "  Filter operators: $(src_count_matches 'filter\[|filters\.|whereClause|filterBy|query\.filter|\.where\(')"
echo "  Sort parameter: $(src_count_matches 'sort=|sortBy|sort_by|orderBy|order_by|\.sort\(')"
echo "  Search/keyword filter: $(src_count_matches 'search=|q=|keyword|fulltext|searchQuery')"
echo ""
