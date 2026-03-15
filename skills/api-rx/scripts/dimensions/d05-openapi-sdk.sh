#!/usr/bin/env bash
# d05-openapi-sdk.sh — Scan OpenAPI spec & SDK readiness patterns
source "$(dirname "$0")/../lib/common.sh"

echo "# D05 — OPENAPI & SDK READINESS"
echo ""

section "M5.1 OpenAPI Spec Completeness"
echo "  OpenAPI/Swagger spec files:"
eval find '"$ROOT"' -maxdepth 5 -type f \( -name "'openapi.*'" -o -name "'swagger.*'" -o -name "'api-spec.*'" -o -name "'api.yaml'" -o -name "'api.json'" \) "$EXCLUDE_PATHS" 2>/dev/null | head -5 | sed 's/^/    /'
SPEC_COUNT=$(eval find '"$ROOT"' -maxdepth 5 -type f \( -name "'openapi.*'" -o -name "'swagger.*'" \) "$EXCLUDE_PATHS" 2>/dev/null | wc -l | tr -d ' ')
echo "  Spec count: $SPEC_COUNT"
echo "  OpenAPI version references: $(src_count_matches 'openapi.*3\.[0-9]|swagger.*2\.[0-9]|openapi:|swagger:')"
echo "  Schema definitions (components/schemas): $(src_count_matches 'components.*schemas|\$ref.*#/|definitions:')"
echo "  Example objects in spec: $(src_count_matches 'example:|examples:|x-example')"
echo "  Tags for organization: $(src_count_matches 'tags:|x-tag')"
echo ""

section "M5.2 Code Generation Compatibility"
echo "  operationId definitions: $(src_count_matches 'operationId|operation_id')"
echo "  SDK generation config:"
eval find '"$ROOT"' -maxdepth 3 -type f \( -iname "'*openapi-generator*'" -o -iname "'*swagger-codegen*'" -o -iname "'*orval*'" -o -iname "'*.openapirc*'" \) "$EXCLUDE_PATHS" 2>/dev/null | head -3 | sed 's/^/    /'
echo "  Type generation (ts/js): $(src_count_files 'generateTypes|generate-types|openapi-typescript|swagger-typescript')"
echo ""

section "M5.3 Request/Response Examples"
echo "  Example blocks in code: $(src_count_matches '@example|@Example|example.*request|example.*response|sampleRequest|sampleResponse')"
echo "  Postman/Insomnia collections:"
eval find '"$ROOT"' -maxdepth 4 -type f \( -iname "'*postman*'" -o -iname "'*insomnia*'" -o -name "'*.postman_collection.json'" \) "$EXCLUDE_PATHS" 2>/dev/null | head -3 | sed 's/^/    /'
echo "  Example/fixture files: $(eval find '"$ROOT"' -maxdepth 4 -type d \( -iname "'examples'" -o -iname "'fixtures'" -o -iname "'samples'" \) "$EXCLUDE_PATHS" 2>/dev/null | wc -l | tr -d ' ')"
echo ""

section "M5.4 Schema Validation"
echo "  Zod schemas: $(src_count_matches 'z\.\(object\|string\|number\|array\|enum\)|zod|ZodSchema')"
echo "  Joi schemas: $(src_count_matches 'Joi\.\(object\|string\|number\|array\)|joi\.object|@hapi/joi')"
echo "  Yup schemas: $(src_count_matches 'yup\.\(object\|string\|number\)|Yup\.object')"
echo "  class-validator: $(src_count_matches '@IsString|@IsNumber|@IsEmail|@IsNotEmpty|@ValidateNested|class-validator')"
echo "  AJV/JSON Schema: $(src_count_matches 'ajv|Ajv|jsonSchema|JSON\.Schema|\$schema')"
echo "  Manual if-check validation: $(src_count_matches 'if.*!req\.(body|params|query)|if.*typeof.*req\.')"
echo ""
