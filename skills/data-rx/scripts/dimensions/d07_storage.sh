#!/usr/bin/env bash
# D7: Supabase Storage (8%)
# Scans for bucket config, storage RLS, image transforms, cleanup

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

PROJECT_ROOT="${1:-.}"

section_header "D7" "Supabase Storage (8%)"

# ─── M7.1: Bucket Configuration ───
metric_header "M7.1" "Bucket Configuration"

# Check for bucket creation in migrations
BUCKET_CREATE=$(search_migration_files "$PROJECT_ROOT" "storage\.buckets|INSERT INTO.*storage\.buckets|create_bucket" "-in")
if [[ -n "$BUCKET_CREATE" ]]; then
  BUCKET_COUNT=$(echo "$BUCKET_CREATE" | wc -l | tr -d ' ')
  finding "INFO" "M7.1" "Storage buckets in migrations: $BUCKET_COUNT"
  echo "$BUCKET_CREATE" | head -5

  # Check for file size limits
  SIZE_LIMIT=$(search_migration_files "$PROJECT_ROOT" "file_size_limit|fileSizeLimit" "-in")
  if [[ -n "$SIZE_LIMIT" ]]; then
    finding "INFO" "M7.1" "File size limits configured"
  else
    finding "LOW" "M7.1" "No file size limits detected on buckets"
  fi

  # Check for MIME type restrictions
  MIME_LIMIT=$(search_migration_files "$PROJECT_ROOT" "allowed_mime_types|allowedMimeTypes" "-in")
  if [[ -n "$MIME_LIMIT" ]]; then
    finding "INFO" "M7.1" "MIME type restrictions configured"
  else
    finding "LOW" "M7.1" "No MIME type restrictions detected on buckets"
  fi
else
  # Check client-side bucket usage
  CLIENT_STORAGE=$(search_source_files "$PROJECT_ROOT" "supabase\.storage|\.from\(['\"].*['\"]\)\.(upload|download|list|remove)" "-rl")
  if [[ -n "$CLIENT_STORAGE" ]]; then
    finding "MEDIUM" "M7.1" "Storage client usage found but no bucket creation in migrations"
  else
    finding "INFO" "M7.1" "No Supabase Storage usage detected (may be N/A)"
  fi
fi

# ─── M7.2: Storage RLS ───
metric_header "M7.2" "Storage RLS Policies"

STORAGE_RLS=$(search_migration_files "$PROJECT_ROOT" "storage\.objects|CREATE POLICY.*storage" "-in")
if [[ -n "$STORAGE_RLS" ]]; then
  STORAGE_POLICY_COUNT=$(echo "$STORAGE_RLS" | grep -ic "CREATE POLICY" || echo "0")
  finding "INFO" "M7.2" "Storage RLS policies: $STORAGE_POLICY_COUNT"

  # Check for per-user path policies
  USER_PATH=$(echo "$STORAGE_RLS" | grep -i "auth\.uid\|storage\.foldername" || true)
  if [[ -n "$USER_PATH" ]]; then
    finding "INFO" "M7.2" "Per-user storage path policies detected"
  else
    finding "MEDIUM" "M7.2" "Storage policies don't appear to use per-user paths"
  fi
else
  CLIENT_STORAGE=$(search_source_files "$PROJECT_ROOT" "supabase\.storage|\.upload\(" "-rl")
  if [[ -n "$CLIENT_STORAGE" ]]; then
    finding "HIGH" "M7.2" "Storage usage found but no RLS policies on storage.objects"
  else
    finding "INFO" "M7.2" "No storage RLS needed (storage not used)"
  fi
fi

# ─── M7.3: Image Transformations ───
metric_header "M7.3" "Image Transformations"

# Check for Supabase image transform usage
IMG_TRANSFORM=$(search_source_files "$PROJECT_ROOT" "\.getPublicUrl.*transform|transform.*width.*height|\.download.*transform" "-rn")
if [[ -n "$IMG_TRANSFORM" ]]; then
  finding "INFO" "M7.3" "Supabase image transforms detected"
else
  # Check if images are used at all
  IMG_UPLOAD=$(search_source_files "$PROJECT_ROOT" "image/|\.upload.*\.(jpg|png|webp|avif|gif)" "-rl")
  if [[ -n "$IMG_UPLOAD" ]]; then
    finding "LOW" "M7.3" "Image uploads found but no Supabase image transforms used"
  else
    finding "INFO" "M7.3" "No image handling detected (N/A)"
  fi
fi

# ─── M7.4: Cleanup & Lifecycle ───
metric_header "M7.4" "Cleanup & Lifecycle"

# Check for storage cleanup functions
CLEANUP=$(search_source_files "$PROJECT_ROOT" "storage\.remove|storage\.emptyBucket|orphan.*file|file.*cleanup|storage.*delete" "-rl")
if [[ -n "$CLEANUP" ]]; then
  finding "INFO" "M7.4" "Storage cleanup patterns detected"
else
  CLIENT_STORAGE=$(search_source_files "$PROJECT_ROOT" "supabase\.storage|\.upload\(" "-rl")
  if [[ -n "$CLIENT_STORAGE" ]]; then
    finding "LOW" "M7.4" "Storage in use but no cleanup/orphan detection patterns found"
  else
    finding "INFO" "M7.4" "No storage cleanup needed (storage not used)"
  fi
fi

# Check for storage-related Edge Functions (cron cleanup)
SB_DIR=$(find_supabase_dir "$PROJECT_ROOT")
if [[ -n "$SB_DIR" && -d "$SB_DIR/functions" ]]; then
  STORAGE_FUNC=$(grep -rl "storage" "$SB_DIR/functions/" 2>/dev/null || true)
  if [[ -n "$STORAGE_FUNC" ]]; then
    finding "INFO" "M7.4" "Edge Functions referencing storage found"
  fi
fi

print_summary
