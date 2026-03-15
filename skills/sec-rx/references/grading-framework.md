# sec-rx Grading Framework

All sub-metrics are scored on a 0-5 scale. This document defines the threshold criteria for each score level across all 32 sub-metrics.

---

## Score Scale

| Score | Label | Meaning |
|-------|-------|---------|
| 0 | Critical | Actively exploitable vulnerability present |
| 1 | Poor | Known weakness, no mitigation in place |
| 2 | Below Average | Partial mitigation, significant gaps remain |
| 3 | Adequate | Basic protections in place, some hardening needed |
| 4 | Good | Strong protections, minor improvements possible |
| 5 | Excellent | Best-practice implementation, defense in depth |

---

## D1: Injection Prevention (15%)

### M1.1 — SQL Injection

| Score | Criteria |
|-------|----------|
| 0 | Raw string concatenation in SQL queries with user input found |
| 1 | Some queries use concatenation, no parameterization pattern established |
| 2 | ORM used but raw queries exist without parameterization |
| 3 | All queries parameterized or via ORM; no input validation layer |
| 4 | Parameterized queries + input validation + query builder patterns |
| 5 | Parameterized queries + input validation + SQL linting rule in CI + no raw query escape hatches |

### M1.2 — XSS Prevention

| Score | Criteria |
|-------|----------|
| 0 | `innerHTML` or `dangerouslySetInnerHTML` used with unsanitized user input |
| 1 | Some output encoding, but inconsistent; no CSP header |
| 2 | Framework auto-escaping relied upon, but bypass patterns exist (e.g., `dangerouslySetInnerHTML`) |
| 3 | Auto-escaping + CSP header present but permissive (`unsafe-inline`) |
| 4 | Strict CSP + DOMPurify/sanitize-html for any raw HTML rendering |
| 5 | Strict CSP with nonces + sanitization library + no `unsafe-inline`/`unsafe-eval` + automated XSS tests |

### M1.3 — Command Injection

| Score | Criteria |
|-------|----------|
| 0 | `exec()`/`system()`/`spawn()` called with unsanitized user input |
| 1 | Shell commands used with partial sanitization |
| 2 | Shell commands exist but input is validated (incomplete allowlist) |
| 3 | No shell exec with user input; or strict allowlisting of commands |
| 4 | No shell exec + eslint rule blocking `child_process` with user input |
| 5 | No shell exec + lint rule + alternative APIs used (e.g., direct bindings) + CI enforcement |

### M1.4 — NoSQL Injection

| Score | Criteria |
|-------|----------|
| 0 | MongoDB `$where` or operator injection possible with user input |
| 1 | Query operators accepted from user input without filtering |
| 2 | Some input type checking, but `$gt`/`$ne` operators not blocked |
| 3 | Input type validation on all query parameters; schema validation |
| 4 | Schema validation + query operator stripping + ODM with strict schemas |
| 5 | All above + automated NoSQL injection tests + mongo-sanitize or equivalent |

---

## D2: Authentication & Session (15%)

### M2.1 — Password Handling

| Score | Criteria |
|-------|----------|
| 0 | Plaintext password storage found |
| 1 | Weak hashing (MD5/SHA1) without salt |
| 2 | SHA-256 with salt but not adaptive hashing |
| 3 | bcrypt/argon2/scrypt used; no password strength requirements |
| 4 | Adaptive hashing + strength requirements + breach-check (HaveIBeenPwned API) |
| 5 | All above + password rotation policy + credential stuffing protection |

### M2.2 — Session Management

| Score | Criteria |
|-------|----------|
| 0 | Session tokens in URL, no expiry, no secure flags |
| 1 | Cookie-based but missing httpOnly or secure flags |
| 2 | httpOnly + secure flags set; no sameSite; no session expiry |
| 3 | httpOnly + secure + sameSite=Lax + session expiry configured |
| 4 | All above + session regeneration on authentication + absolute timeout |
| 5 | All above + concurrent session limits + session revocation capability + idle timeout |

### M2.3 — JWT Security

| Score | Criteria |
|-------|----------|
| 0 | JWT with `alg: none` accepted or secret hardcoded in source |
| 1 | JWT used but no expiry claim, weak secret |
| 2 | Expiry set but no algorithm pinning; no refresh rotation |
| 3 | Algorithm pinned (RS256/ES256) + expiry + strong secret/key |
| 4 | All above + refresh token rotation + token blacklisting on logout |
| 5 | All above + short-lived access tokens (<15 min) + JTI claim + audience validation |

### M2.4 — MFA Support

| Score | Criteria |
|-------|----------|
| 0 | No MFA support; single-factor auth only |
| 1 | MFA planned but not implemented |
| 2 | TOTP MFA available but optional, no recovery flow |
| 3 | TOTP MFA with recovery codes, optional enrollment |
| 4 | TOTP + WebAuthn support, enforced for admin roles |
| 5 | Multiple MFA methods + enforced for all users + adaptive MFA (risk-based) |

---

## D3: Authorization & Access Control (15%)

### M3.1 — IDOR Prevention

| Score | Criteria |
|-------|----------|
| 0 | Direct object references with no ownership check (e.g., `/api/users/123/data` accessible to any authenticated user) |
| 1 | Some endpoints have ownership checks, most do not |
| 2 | Ownership checks on sensitive endpoints only |
| 3 | All data-access endpoints verify resource ownership |
| 4 | All above + UUID/non-sequential IDs + authorization middleware pattern |
| 5 | All above + automated IDOR tests + centralized authorization service |

### M3.2 — Function-Level Access

| Score | Criteria |
|-------|----------|
| 0 | Admin functions accessible without role check |
| 1 | Some admin routes protected, inconsistent enforcement |
| 2 | Admin routes have role checks but no middleware pattern (inline checks) |
| 3 | Consistent middleware/decorator pattern for role-based access |
| 4 | All above + principle of least privilege + granular permissions (not just admin/user) |
| 5 | All above + permission matrix documented + automated access control tests |

### M3.3 — Data-Level Access

| Score | Criteria |
|-------|----------|
| 0 | No tenant isolation; cross-tenant data access possible |
| 1 | Tenant filtering exists but can be bypassed |
| 2 | Tenant filtering in application layer, not DB layer |
| 3 | Row-level security (RLS) or query-scoped tenant filtering on all queries |
| 4 | RLS + default-deny policies + audit logging on cross-tenant attempts |
| 5 | All above + RLS tests + automated tenant isolation verification |

### M3.4 — Privilege Escalation Prevention

| Score | Criteria |
|-------|----------|
| 0 | Users can assign themselves higher roles via API |
| 1 | Role assignment API exists without authorization check |
| 2 | Role assignment requires admin but no hierarchy enforcement |
| 3 | Role hierarchy enforced; cannot assign role >= own level |
| 4 | All above + role changes audited + approval workflow for elevation |
| 5 | All above + automated privilege escalation tests + time-bound elevated access |

---

## D4: Security Headers & Transport (10%)

### M4.1 — HTTPS Enforcement

| Score | Criteria |
|-------|----------|
| 0 | No HTTPS; application serves over HTTP |
| 1 | HTTPS available but HTTP not redirected |
| 2 | HTTP redirects to HTTPS but no HSTS |
| 3 | HSTS header present with reasonable max-age (>= 6 months) |
| 4 | HSTS with includeSubDomains + preload-ready |
| 5 | HSTS preloaded + TLS 1.2+ only + strong cipher suites |

### M4.2 — Content Security Policy

| Score | Criteria |
|-------|----------|
| 0 | No CSP header |
| 1 | CSP present but report-only with permissive policy |
| 2 | CSP enforced but includes `unsafe-inline` and `unsafe-eval` |
| 3 | CSP enforced, no `unsafe-eval`, limited `unsafe-inline` usage |
| 4 | CSP with nonces or hashes, no `unsafe-inline` |
| 5 | Strict CSP + report-uri configured + no unsafe directives + frame-ancestors set |

### M4.3 — CORS Configuration

| Score | Criteria |
|-------|----------|
| 0 | `Access-Control-Allow-Origin: *` with credentials |
| 1 | Wildcard CORS without credentials |
| 2 | Origin allowlist exists but overly broad (e.g., `*.example.com`) |
| 3 | Specific origin allowlist, proper preflight handling |
| 4 | All above + credentials restricted to specific origins + methods restricted |
| 5 | All above + CORS config reviewed/tested + no `Access-Control-Allow-Origin` reflection |

### M4.4 — Additional Headers

| Score | Criteria |
|-------|----------|
| 0 | No security headers set |
| 1 | Only 1 of 4 key headers present |
| 2 | 2 of 4 key headers present (X-Frame-Options, X-Content-Type-Options, Referrer-Policy, Permissions-Policy) |
| 3 | 3 of 4 key headers present |
| 4 | All 4 headers present with reasonable values |
| 5 | All 4 headers + Cache-Control for sensitive responses + Feature-Policy/Permissions-Policy restrictive |

---

## D5: Data Protection & Privacy (10%)

### M5.1 — Encryption at Rest

| Score | Criteria |
|-------|----------|
| 0 | Passwords or API keys stored in plaintext in DB |
| 1 | Some sensitive data encrypted, keys stored alongside data |
| 2 | Encryption used but with weak algorithms or hardcoded keys |
| 3 | AES-256 or equivalent with external key management |
| 4 | All above + column-level encryption for PII + key rotation policy |
| 5 | All above + envelope encryption + HSM/KMS integration + encrypted backups |

### M5.2 — PII Handling

| Score | Criteria |
|-------|----------|
| 0 | PII collected without consent, no inventory of PII fields |
| 1 | PII collected, basic awareness but no formal handling |
| 2 | PII fields identified, but no minimization or consent tracking |
| 3 | PII minimized + consent tracked + data subject access request (DSAR) capability |
| 4 | All above + PII pseudonymization + purpose limitation enforced |
| 5 | All above + automated PII detection + data mapping + privacy impact assessments |

### M5.3 — Logging Sanitization

| Score | Criteria |
|-------|----------|
| 0 | Passwords, tokens, or API keys logged in plaintext |
| 1 | Some log redaction but inconsistent |
| 2 | Structured logging but no automated PII filtering |
| 3 | Log redaction middleware for known sensitive fields |
| 4 | All above + automated log scanning for leaked secrets + log levels enforced |
| 5 | All above + log redaction tests + no request body logging in production + audit log separation |

### M5.4 — Data Retention

| Score | Criteria |
|-------|----------|
| 0 | No data retention policy; data kept indefinitely |
| 1 | Retention policy documented but not enforced |
| 2 | Manual cleanup processes exist |
| 3 | Automated retention jobs + configurable periods |
| 4 | All above + right-to-deletion API + cascade deletion |
| 5 | All above + retention compliance tests + data lifecycle auditing |

---

## D6: Dependency & Supply Chain (10%)

### M6.1 — Vulnerability Scanning

| Score | Criteria |
|-------|----------|
| 0 | No dependency vulnerability scanning |
| 1 | Manual `npm audit` / `pip audit` run occasionally |
| 2 | Scanning in CI but not blocking on findings |
| 3 | Scanning in CI, blocking on critical/high severity |
| 4 | All above + Dependabot/Renovate auto-PRs + Snyk or similar |
| 5 | All above + license compliance scanning + container image scanning |

### M6.2 — Critical CVE Response

| Score | Criteria |
|-------|----------|
| 0 | No process for CVE response; known critical CVEs unpatched |
| 1 | Ad-hoc CVE response, no SLA |
| 2 | Awareness of CVEs but response > 30 days for critical |
| 3 | Critical CVEs patched within 14 days; documented process |
| 4 | Critical CVEs patched within 72 hours; monitoring alerts |
| 5 | All above + zero-day response plan + dependency pinning with automated updates |

### M6.3 — Lockfile Integrity

| Score | Criteria |
|-------|----------|
| 0 | No lockfile committed |
| 1 | Lockfile committed but not enforced (`npm install` instead of `npm ci`) |
| 2 | Lockfile enforced in CI; versions not fully pinned |
| 3 | Lockfile enforced + `--frozen-lockfile` in CI |
| 4 | All above + lockfile changes reviewed in PRs + exact version pinning |
| 5 | All above + lockfile integrity hash verification + supply chain attestation |

### M6.4 — SBOM & Provenance

| Score | Criteria |
|-------|----------|
| 0 | No SBOM generated |
| 1 | Manual dependency list maintained |
| 2 | SBOM generated but not in CI pipeline |
| 3 | SBOM auto-generated in CI (CycloneDX/SPDX format) |
| 4 | All above + signed artifacts + build provenance |
| 5 | All above + SLSA Level 3+ compliance + published SBOM |

---

## D7: CSRF & Request Security (10%)

### M7.1 — CSRF Token Validation

| Score | Criteria |
|-------|----------|
| 0 | No CSRF protection on state-changing endpoints |
| 1 | CSRF protection on some forms, not all state-changing APIs |
| 2 | CSRF tokens used but not validated server-side consistently |
| 3 | Synchronizer token or double-submit cookie on all state-changing requests |
| 4 | All above + SameSite=Strict cookies + custom request headers |
| 5 | All above + CSRF protection tests + token rotation per request |

### M7.2 — Origin Validation

| Score | Criteria |
|-------|----------|
| 0 | No Origin/Referer header checking |
| 1 | Origin checked on some endpoints |
| 2 | Origin middleware exists but bypassable |
| 3 | Origin/Referer validated on all state-changing requests |
| 4 | All above + strict null origin rejection + configurable allowlist |
| 5 | All above + origin validation tests + fetch metadata headers (Sec-Fetch-*) |

### M7.3 — Request Rate Limiting

| Score | Criteria |
|-------|----------|
| 0 | No rate limiting; unlimited login attempts possible |
| 1 | Basic rate limiting on a few endpoints |
| 2 | Rate limiting on auth endpoints but not API-wide |
| 3 | API-wide rate limiting + stricter limits on auth endpoints |
| 4 | All above + progressive delays + account lockout + IP-based + user-based limits |
| 5 | All above + distributed rate limiting + rate limit headers + automated abuse detection |

### M7.4 — File Upload Security

| Score | Criteria |
|-------|----------|
| 0 | File uploads accepted without any validation |
| 1 | Client-side validation only (extension check) |
| 2 | Server-side extension check but no MIME validation or size limit |
| 3 | MIME type validation + size limits + filename sanitization |
| 4 | All above + virus scanning + isolated storage (S3/separate domain) |
| 5 | All above + content analysis + upload rate limiting + signed URLs for access |

---

## D8: Security Testing & Monitoring (15%)

### M8.1 — SAST Integration

| Score | Criteria |
|-------|----------|
| 0 | No static security analysis |
| 1 | Linting exists but no security-focused rules |
| 2 | eslint-plugin-security or equivalent installed but not enforced |
| 3 | Security linting enforced in CI (semgrep/CodeQL/eslint-security) |
| 4 | All above + custom rules for project-specific patterns + pre-commit hooks |
| 5 | All above + multiple SAST tools + security rule coverage tracking + blocking on findings |

### M8.2 — DAST / Pen Testing

| Score | Criteria |
|-------|----------|
| 0 | No dynamic security testing or penetration testing |
| 1 | Ad-hoc manual testing only |
| 2 | OWASP ZAP or similar run occasionally |
| 3 | DAST in CI pipeline (at least on staging deployments) |
| 4 | All above + annual professional penetration test + findings tracked |
| 5 | All above + continuous DAST + bug bounty program + remediation SLAs |

### M8.3 — Security Monitoring

| Score | Criteria |
|-------|----------|
| 0 | No security event logging or monitoring |
| 1 | Basic application logging, no security-specific monitoring |
| 2 | Failed login attempts logged but not alerted on |
| 3 | Security events logged + alerting on anomalies (failed logins, privilege changes) |
| 4 | All above + SIEM integration + audit trail for sensitive operations |
| 5 | All above + real-time threat detection + automated response + SOC integration |

### M8.4 — Incident Response Readiness

| Score | Criteria |
|-------|----------|
| 0 | No incident response plan or security contact |
| 1 | Informal awareness but no documented process |
| 2 | SECURITY.md exists with contact info |
| 3 | SECURITY.md + documented incident response procedure |
| 4 | All above + responsible disclosure policy + post-incident review process |
| 5 | All above + tabletop exercises + automated containment playbooks + SLA-based response |

---

## Final Score Calculation

```
Final Score = (D1 * 0.15) + (D2 * 0.15) + (D3 * 0.15) + (D4 * 0.10) +
              (D5 * 0.10) + (D6 * 0.10) + (D7 * 0.10) + (D8 * 0.15)
```

Each dimension score is the average of its 4 sub-metric scores, normalized to 0-5.

### Overall Rating

| Score Range | Rating | Action Required |
|-------------|--------|----------------|
| 0.0 - 1.0 | Critical | Immediate remediation required; do not deploy |
| 1.1 - 2.0 | Poor | Major security gaps; high-priority remediation |
| 2.1 - 3.0 | Below Average | Significant improvements needed before production |
| 3.1 - 3.5 | Adequate | Meets minimum bar; plan improvements |
| 3.6 - 4.0 | Good | Solid security posture; minor hardening opportunities |
| 4.1 - 4.5 | Very Good | Strong security; focus on advanced protections |
| 4.6 - 5.0 | Excellent | Best-in-class; maintain and iterate |
