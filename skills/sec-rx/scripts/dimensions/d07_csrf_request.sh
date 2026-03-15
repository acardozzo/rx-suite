#!/usr/bin/env bash
# D7: CSRF & Request Security — OWASP A05:2021, SameSite Cookies
# Scans for CSRF protection, origin validation, rate limiting, file upload security

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

PROJECT_ROOT="${1:-.}"
detect_stack "$PROJECT_ROOT"

section_header "D7" "CSRF & Request Security (10%)"

# ─── M7.1: CSRF Token Validation ───
metric_header "M7.1" "CSRF Token Validation"

# CSRF middleware/library
CSRF_LIB=$(search_source_files "$PROJECT_ROOT" \
  "(csrf|csurf|csrfToken|_csrf|csrf_token|anti.forgery|AntiForgery|@csrf_protect|CsrfViewMiddleware|gorilla/csrf)" \
  "-rl")
if [[ -n "$CSRF_LIB" ]]; then
  finding "INFO" "M7.1" "CSRF protection library/middleware detected"
else
  # Check if SPA with API — may use custom headers instead
  SPA=$(search_source_files "$PROJECT_ROOT" "(react|vue|angular|svelte)" "-rli" | head -1)
  if [[ -n "$SPA" ]]; then
    # SPA frameworks often rely on SameSite cookies + custom headers
    CUSTOM_HEADER=$(search_source_files "$PROJECT_ROOT" "(X-Requested-With|X-CSRF|x-csrf|csrf-token)" "-rli")
    if [[ -n "$CUSTOM_HEADER" ]]; then
      finding "INFO" "M7.1" "Custom CSRF header pattern detected (SPA approach)"
    else
      finding "MEDIUM" "M7.1" "SPA detected but no CSRF protection pattern found"
    fi
  else
    finding "HIGH" "M7.1" "No CSRF protection detected"
  fi
fi

# SameSite cookie as CSRF mitigation
SAMESITE=$(search_source_files "$PROJECT_ROOT" "(sameSite|samesite|same_site)\s*[:=]\s*['\"]?(Strict|strict)" "-rli")
if [[ -n "$SAMESITE" ]]; then
  finding "INFO" "M7.1" "SameSite=Strict cookies detected — strong CSRF mitigation"
fi

# ─── M7.2: Origin Validation ───
metric_header "M7.2" "Origin Validation"

# Origin/Referer header checking
ORIGIN_CHECK=$(search_source_files "$PROJECT_ROOT" \
  "(req\.headers?\[?['\"]origin|req\.headers?\[?['\"]referer|checkOrigin|validateOrigin|allowedOrigins)" \
  "-rl")
if [[ -n "$ORIGIN_CHECK" ]]; then
  finding "INFO" "M7.2" "Origin/Referer validation detected"
else
  finding "MEDIUM" "M7.2" "No explicit origin validation detected"
fi

# Sec-Fetch-* headers
SEC_FETCH=$(search_source_files "$PROJECT_ROOT" "(Sec-Fetch-Site|Sec-Fetch-Mode|Sec-Fetch-Dest|sec-fetch)" "-rli")
if [[ -n "$SEC_FETCH" ]]; then
  finding "INFO" "M7.2" "Fetch metadata headers (Sec-Fetch-*) checking detected"
fi

# ─── M7.3: Request Rate Limiting ───
metric_header "M7.3" "Request Rate Limiting"

# Rate limiting libraries
RATE_LIMIT=$(search_source_files "$PROJECT_ROOT" \
  "(rate.limit|rateLimit|express-rate-limit|bottleneck|throttle|slowDown|redis.*limit|bucket|leaky.bucket|token.bucket|django-ratelimit|rack-attack|go-rate)" \
  "-rl")
if [[ -n "$RATE_LIMIT" ]]; then
  finding "INFO" "M7.3" "Rate limiting detected"

  # Check if applied to auth endpoints
  AUTH_RATE=$(search_source_files "$PROJECT_ROOT" "(login.*rate|rate.*login|auth.*limit|limit.*auth|bruteForce)" "-rli")
  if [[ -n "$AUTH_RATE" ]]; then
    finding "INFO" "M7.3" "Rate limiting on authentication endpoints detected"
  else
    finding "LOW" "M7.3" "Rate limiting exists but not confirmed on auth endpoints"
  fi
else
  finding "HIGH" "M7.3" "No rate limiting detected"
fi

# Account lockout
LOCKOUT=$(search_source_files "$PROJECT_ROOT" "(lockout|lock.*account|failed.*attempts|max.*attempts|account.*lock|brute.force)" "-rli")
if [[ -n "$LOCKOUT" ]]; then
  finding "INFO" "M7.3" "Account lockout/brute-force protection detected"
else
  finding "MEDIUM" "M7.3" "No account lockout mechanism detected"
fi

# ─── M7.4: File Upload Security ───
metric_header "M7.4" "File Upload Security"

# File upload handling
UPLOAD=$(search_source_files "$PROJECT_ROOT" \
  "(multer|formidable|busboy|multipart|upload|FileUpload|file_upload|multipart.form|UploadedFile|@UseInterceptors.*FileInterceptor)" \
  "-rl")
if [[ -n "$UPLOAD" ]]; then
  finding "INFO" "M7.4" "File upload handling detected"

  # MIME type validation
  MIME_CHECK=$(search_source_files "$PROJECT_ROOT" "(mimetype|mime.type|content.type|fileFilter|allowedTypes|accepted.*types|magic.number)" "-rli")
  if [[ -n "$MIME_CHECK" ]]; then
    finding "INFO" "M7.4" "MIME type validation detected"
  else
    finding "HIGH" "M7.4" "File uploads without MIME type validation"
  fi

  # File size limits
  SIZE_LIMIT=$(search_source_files "$PROJECT_ROOT" "(maxSize|max.size|fileSize|maxFileSize|file.size.*limit|limits.*fileSize|MAX_FILE_SIZE)" "-rli")
  if [[ -n "$SIZE_LIMIT" ]]; then
    finding "INFO" "M7.4" "File size limits detected"
  else
    finding "MEDIUM" "M7.4" "No file size limits detected"
  fi

  # Filename sanitization
  FILENAME_SANITIZE=$(search_source_files "$PROJECT_ROOT" "(sanitize.*filename|filename.*sanitize|originalname.*replace|path\.basename|secure_filename)" "-rli")
  if [[ -n "$FILENAME_SANITIZE" ]]; then
    finding "INFO" "M7.4" "Filename sanitization detected"
  else
    finding "MEDIUM" "M7.4" "No filename sanitization detected"
  fi

  # Virus scanning
  VIRUS_SCAN=$(search_source_files "$PROJECT_ROOT" "(clamav|clam|virus.*scan|malware|antivirus)" "-rli")
  if [[ -n "$VIRUS_SCAN" ]]; then
    finding "INFO" "M7.4" "Virus scanning for uploads detected"
  fi

  # Isolated storage (S3, etc.)
  ISOLATED_STORAGE=$(search_source_files "$PROJECT_ROOT" "(S3|s3.*upload|cloudinary|gcs|azure.*blob|storage.*bucket|presigned)" "-rli")
  if [[ -n "$ISOLATED_STORAGE" ]]; then
    finding "INFO" "M7.4" "Cloud/isolated storage for uploads detected"
  fi
else
  finding "INFO" "M7.4" "No file upload handling detected"
fi

print_summary
