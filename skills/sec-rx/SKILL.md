---
name: sec-rx
description: "Code-level security posture evaluation. Scans for OWASP Top 10 vulnerabilities, authentication flaws, injection vectors, authorization gaps, and data protection issues. Complements arch-rx D9 (architectural security) by inspecting actual source code patterns, dependencies, and security configurations. Produces a scored report across 8 dimensions with 32 sub-metrics mapped to OWASP ASVS and CWE references."
triggers:
  - "run sec-rx"
  - "security audit"
  - "OWASP check"
  - "vulnerability scan"
  - "security review"
---

## Prerequisites

Recommended: `semgrep` (`brew install semgrep`)

Check all dependencies: `bash scripts/rx-deps.sh` or `bash scripts/rx-deps.sh --install`


# sec-rx — Code-Level Security Posture Evaluation

Evaluates source code for security vulnerabilities, misconfigurations, and missing protections. Maps findings to OWASP Top 10 2021, ASVS 4.0, and CWE entries.

## Dimensions (8) and Sub-Metrics (32)

### D1: Injection Prevention (15%)
**Source:** OWASP A03:2021, CWE-79/89/78

| ID | Sub-Metric | What to look for |
|----|-----------|-----------------|
| M1.1 | SQL Injection | Parameterized queries, no string concatenation in SQL, ORM usage |
| M1.2 | XSS Prevention | Output encoding, Content Security Policy, input sanitization, no `innerHTML`/`dangerouslySetInnerHTML` with user data |
| M1.3 | Command Injection | No `exec`/`spawn` with unsanitized user input, command allowlisting |
| M1.4 | NoSQL Injection | Query operator injection prevention, schema validation, input type checking |

### D2: Authentication & Session (15%)
**Source:** OWASP A07:2021, ASVS V2/V3

| ID | Sub-Metric | What to look for |
|----|-----------|-----------------|
| M2.1 | Password Handling | bcrypt/argon2/scrypt usage, no plaintext storage, strength requirements enforced |
| M2.2 | Session Management | Secure cookie flags (httpOnly, sameSite, secure), session expiry, regeneration on auth |
| M2.3 | JWT Security | Algorithm pinning (no `none`), expiry claims, refresh token rotation, secret strength |
| M2.4 | MFA Support | TOTP/WebAuthn implementation, recovery codes, enrollment flow |

### D3: Authorization & Access Control (15%)
**Source:** OWASP A01:2021, ASVS V4

| ID | Sub-Metric | What to look for |
|----|-----------|-----------------|
| M3.1 | IDOR Prevention | Object-level authorization checks on every data-access endpoint |
| M3.2 | Function-Level Access | Role/permission checks on admin and privileged functions |
| M3.3 | Data-Level Access | Row-level security, tenant isolation, query scoping |
| M3.4 | Privilege Escalation Prevention | Role hierarchy enforcement, no self-role-assignment |

### D4: Security Headers & Transport (10%)
**Source:** OWASP Secure Headers Project, HSTS RFC 6797

| ID | Sub-Metric | What to look for |
|----|-----------|-----------------|
| M4.1 | HTTPS Enforcement | HSTS header, HTTP-to-HTTPS redirect, TLS 1.2+ |
| M4.2 | Content Security Policy | CSP header present, restrictive directives, no `unsafe-inline`/`unsafe-eval` |
| M4.3 | CORS Configuration | Not wildcard `*`, specific allowed origins, credentials handling |
| M4.4 | Additional Headers | X-Frame-Options, X-Content-Type-Options, Referrer-Policy, Permissions-Policy |

### D5: Data Protection & Privacy (10%)
**Source:** OWASP A02:2021, GDPR Technical Measures

| ID | Sub-Metric | What to look for |
|----|-----------|-----------------|
| M5.1 | Encryption at Rest | Sensitive fields encrypted in DB, key management, no plaintext secrets |
| M5.2 | PII Handling | PII identified and minimized, consent tracking, erasure capability |
| M5.3 | Logging Sanitization | No PII, secrets, tokens, or passwords in log output |
| M5.4 | Data Retention | Automated cleanup jobs, configurable retention periods, right-to-deletion support |

### D6: Dependency & Supply Chain (10%)
**Source:** OWASP A06:2021, SLSA Framework

| ID | Sub-Metric | What to look for |
|----|-----------|-----------------|
| M6.1 | Vulnerability Scanning | Automated scanning in CI (npm audit, Snyk, Dependabot), not just periodic |
| M6.2 | Critical CVE Response | SLA for patching critical vulnerabilities, documented process |
| M6.3 | Lockfile Integrity | Lockfile committed and enforced, pinned versions, reviewed changes |
| M6.4 | SBOM & Provenance | Software bill of materials generated, signed artifacts, audit trail |

### D7: CSRF & Request Security (10%)
**Source:** OWASP A05:2021, SameSite Cookies

| ID | Sub-Metric | What to look for |
|----|-----------|-----------------|
| M7.1 | CSRF Token Validation | Double-submit cookies or synchronizer token pattern on state-changing requests |
| M7.2 | Origin Validation | Referrer/Origin header checking middleware |
| M7.3 | Request Rate Limiting | Brute-force protection, account lockout, API rate limits |
| M7.4 | File Upload Security | MIME type validation, size limits, virus scanning, isolated storage |

### D8: Security Testing & Monitoring (15%)
**Source:** OWASP Testing Guide, SAST/DAST Best Practices

| ID | Sub-Metric | What to look for |
|----|-----------|-----------------|
| M8.1 | SAST Integration | Static analysis in CI (semgrep, eslint-plugin-security, CodeQL) |
| M8.2 | DAST / Pen Testing | OWASP ZAP, periodic penetration tests, documented findings |
| M8.3 | Security Monitoring | Failed login tracking, anomaly detection, audit trail for sensitive ops |
| M8.4 | Incident Response Readiness | SECURITY.md / security contact, disclosure policy, response plan |

## Execution

```bash
# Run full scan
bash ~/.claude/skills/sec-rx/scripts/discover.sh /path/to/project

# Run single dimension
bash ~/.claude/skills/sec-rx/scripts/dimensions/d01_injection.sh /path/to/project
```

## Scoring

Each sub-metric scores 0-5. Dimension score = weighted average of its sub-metrics. Final score = weighted sum of dimension scores using the percentages above. See `references/grading-framework.md` for full threshold tables.

## Output

Results are written to `sec-rx-report.md` in the project root. See `references/output-templates.md` for format specification.

## Auto-Plan Integration

After generating the scorecard and saving the report to `docs/audits/`:
1. Save a copy of the report to `docs/rx-plans/{this-skill-name}/{date}-report.md`
2. For each dimension scoring below 97, invoke the `rx-plan` skill to create or update the improvement plan at `docs/rx-plans/{this-skill-name}/{dimension}/v{N}-{date}-plan.md`
3. Update `docs/rx-plans/{this-skill-name}/summary.md` with current scores
4. Update `docs/rx-plans/dashboard.md` with overall progress

This happens automatically — the user does not need to run `/rx-plan` separately.
