# Kuwboo Project Risk Register

**Created:** January 27, 2026
**Last Updated:** January 27, 2026
**Owner:** LionPro Dev (Philip Cutting)

---

## Executive Summary

This document consolidates all identified risks from the discovery phase assessments. Risks are categorized by type and prioritized by severity and likelihood to guide mitigation efforts.

### Risk Overview

| Category | Critical | High | Medium | Low | Total |
|----------|----------|------|--------|-----|-------|
| Security | 3 | 4 | 3 | 1 | 11 |
| Technical | 0 | 4 | 5 | 3 | 12 |
| Operational | 1 | 2 | 3 | 1 | 7 |
| Business | 0 | 2 | 2 | 1 | 5 |
| **Total** | **4** | **12** | **13** | **6** | **35** |

---

## Risk Matrix

| Likelihood / Severity | Critical | High | Medium | Low |
|----------------------|----------|------|--------|-----|
| **Almost Certain** | - | SEC-003 | - | - |
| **Likely** | SEC-001, SEC-002 | TEC-001, OPS-001 | TEC-005 | - |
| **Possible** | SEC-004 | TEC-002, TEC-003, BUS-001 | SEC-005, TEC-006 | TEC-009 |
| **Unlikely** | - | OPS-002, BUS-002 | OPS-003, SEC-006 | SEC-007 |
| **Rare** | - | - | TEC-007, OPS-004, BUS-003 | TEC-010 |

---

## Security Risks

### SEC-001: SQL Injection Vulnerability in Lambda (CRITICAL)

| Property | Value |
|----------|-------|
| **ID** | SEC-001 |
| **Category** | Security |
| **Severity** | Critical |
| **Likelihood** | Likely |
| **Source** | AWS_INFRASTRUCTURE_AUDIT.md, BACKEND_ASSESSMENT.md |
| **Status** | Open |

**Description:**
The `kuwboo-media-convert-on-job-complete-dev` Lambda function uses string interpolation in SQL queries instead of parameterized queries, allowing SQL injection attacks.

**Location:**
`docs/lambda/job-complete/index.js:14`

```javascript
// VULNERABLE CODE
const sqlQuery = `UPDATE feeds SET status='active' WHERE job_id='${jobId}'`;
```

**Impact:**
- Database corruption or data theft
- Unauthorized data modification
- Potential full database compromise

**Mitigation:**
1. Replace string interpolation with parameterized queries
2. Implement input validation
3. Use ORM or query builder

**Owner:** Backend Developer
**Target Date:** February 7, 2026
**Effort:** 2 hours

---

### SEC-002: Hardcoded Test Credentials (CRITICAL)

| Property | Value |
|----------|-------|
| **ID** | SEC-002 |
| **Category** | Security |
| **Severity** | Critical |
| **Likelihood** | Likely |
| **Source** | BACKEND_ASSESSMENT.md |
| **Status** | Open |

**Description:**
Test phone number `7566662735` always accepts OTP `4444`, allowing anyone to bypass authentication.

**Location:**
`src/controllers/account-controller.js:26-28`

**Impact:**
- Complete authentication bypass
- Unauthorized access to any account
- Account takeover potential

**Mitigation:**
1. Remove hardcoded test credentials entirely, OR
2. Gate behind `NODE_ENV=development` check with strong safeguards
3. Add audit logging for this number's usage

**Owner:** Backend Developer
**Target Date:** February 7, 2026
**Effort:** 30 minutes

---

### SEC-003: NSAllowsArbitraryLoads Enabled (HIGH)

| Property | Value |
|----------|-------|
| **ID** | SEC-003 |
| **Category** | Security |
| **Severity** | High |
| **Likelihood** | Almost Certain (if MITM attempted) |
| **Source** | iOS_CODEBASE_AUDIT.md |
| **Status** | Open |

**Description:**
iOS app allows unencrypted HTTP connections via `NSAllowsArbitraryLoads` in Info.plist, exposing user data to man-in-the-middle attacks.

**Location:**
`Kuwboo/Info.plist:101-105`

**Impact:**
- User credentials exposed on insecure networks
- Session hijacking
- Data interception

**Mitigation:**
1. Remove `NSAllowsArbitraryLoads: true`
2. Add specific exception domains only where required
3. Implement SSL pinning

**Owner:** iOS Developer
**Target Date:** March 15, 2026
**Effort:** 4 hours

---

### SEC-004: Outdated JWT Library with CVEs (CRITICAL)

| Property | Value |
|----------|-------|
| **ID** | SEC-004 |
| **Category** | Security |
| **Severity** | Critical |
| **Likelihood** | Possible |
| **Source** | BACKEND_ASSESSMENT.md |
| **Status** | Open |

**Description:**
Backend uses jsonwebtoken 8.5.1 with known vulnerabilities CVE-2022-23529 (arbitrary code execution) and CVE-2022-23539 (algorithm confusion).

**Impact:**
- Authentication bypass
- Remote code execution
- Token forgery

**Mitigation:**
1. Update jsonwebtoken to 9.x
2. Review JWT implementation for algorithm pinning
3. Add token validation tests

**Owner:** Backend Developer
**Target Date:** February 14, 2026
**Effort:** 4 hours

---

### SEC-005: Credentials Not Rotated (HIGH)

| Property | Value |
|----------|-------|
| **ID** | SEC-005 |
| **Category** | Security |
| **Severity** | High |
| **Likelihood** | Possible |
| **Source** | AWS_INFRASTRUCTURE_AUDIT.md |
| **Status** | Open |

**Description:**
All credentials (database, AWS, JWT secrets, Twilio, SMTP) are still using values known to previous developer (Codiant).

**Credentials at Risk:**
- `DB_PASSWORD`
- `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`
- `JWT_SECRET` / `JWT_REFRESH_SECRET`
- `TWILIO_ACCOUNT_SID` / `TWILIO_AUTH_TOKEN`
- `SMTP_USERNAME` / `SMTP_PASSWORD`

**Impact:**
- Unauthorized data access
- Service abuse
- Data breach

**Mitigation:**
1. Rotate all credentials systematically
2. Update `.env` on EC2
3. Update Lambda environment variables
4. Restart services

**Owner:** DevOps / Backend Developer
**Target Date:** February 28, 2026
**Effort:** 4 hours

---

### SEC-006: No SSL Pinning (MEDIUM)

| Property | Value |
|----------|-------|
| **ID** | SEC-006 |
| **Category** | Security |
| **Severity** | Medium |
| **Likelihood** | Unlikely |
| **Source** | iOS_CODEBASE_AUDIT.md |
| **Status** | Open |

**Description:**
iOS app has no certificate or public key pinning, making API communications vulnerable to MITM attacks even over HTTPS.

**Impact:**
- API traffic interception with rogue certificate
- Session hijacking on compromised networks

**Mitigation:**
1. Implement TrustKit or manual URLSession delegate validation
2. Pin public key for API endpoints

**Owner:** iOS Developer
**Target Date:** April 30, 2026
**Effort:** 8 hours

---

### SEC-007: Debug Print Statements in Production (LOW)

| Property | Value |
|----------|-------|
| **ID** | SEC-007 |
| **Category** | Security |
| **Severity** | Low |
| **Likelihood** | Unlikely |
| **Source** | iOS_CODEBASE_AUDIT.md |
| **Status** | Open |

**Description:**
Debug `print()` statements throughout iOS codebase leak information to device console.

**Locations:**
- `Authorization/Authorization.swift:199`
- `Root/LoggedIn/BuyAndSell/ProductDetail/ProductDetailVC.swift`: multiple instances
- Various other files

**Impact:**
- Information leakage to anyone with device access
- Potential sensitive data exposure in logs

**Mitigation:**
1. Wrap prints with `#if DEBUG`
2. Use OSLog framework with appropriate log levels

**Owner:** iOS Developer
**Target Date:** May 31, 2026
**Effort:** 2 hours

---

### SEC-008: No Rate Limiting (HIGH)

| Property | Value |
|----------|-------|
| **ID** | SEC-008 |
| **Category** | Security |
| **Severity** | High |
| **Likelihood** | Possible |
| **Source** | BACKEND_ASSESSMENT.md |
| **Status** | Open |

**Description:**
No rate limiting middleware on API endpoints, exposing system to brute force attacks on OTP, DoS via expensive queries, and scraping.

**Impact:**
- Account takeover via OTP brute force
- Service degradation or outage
- Data scraping

**Mitigation:**
1. Add `express-rate-limit` middleware
2. Configure rate limits per endpoint type
3. Add monitoring for rate limit violations

**Owner:** Backend Developer
**Target Date:** March 15, 2026
**Effort:** 4 hours

---

### SEC-009: Permissive CORS Configuration (MEDIUM)

| Property | Value |
|----------|-------|
| **ID** | SEC-009 |
| **Category** | Security |
| **Severity** | Medium |
| **Likelihood** | Possible |
| **Source** | BACKEND_ASSESSMENT.md |
| **Status** | Open |

**Description:**
Backend uses `app.use(cors())` which allows all origins.

**Impact:**
- Cross-site request forgery potential
- Unauthorized API access from malicious websites

**Mitigation:**
```javascript
app.use(cors({
  origin: ['https://kuwboo.com', 'https://admin.kuwboo.com']
}));
```

**Owner:** Backend Developer
**Target Date:** March 15, 2026
**Effort:** 1 hour

---

### SEC-010: Outdated Axios with SSRF Vulnerability (HIGH)

| Property | Value |
|----------|-------|
| **ID** | SEC-010 |
| **Category** | Security |
| **Severity** | High |
| **Likelihood** | Possible |
| **Source** | BACKEND_ASSESSMENT.md |
| **Status** | Open |

**Description:**
Backend uses axios 0.24.0 with SSRF vulnerability CVE-2023-45857.

**Impact:**
- Server-side request forgery
- Internal network scanning
- Data exfiltration

**Mitigation:**
1. Update axios to 1.6.x

**Owner:** Backend Developer
**Target Date:** February 14, 2026
**Effort:** 2 hours

---

### SEC-011: Deprecated `request` Package (MEDIUM)

| Property | Value |
|----------|-------|
| **ID** | SEC-011 |
| **Category** | Security |
| **Severity** | Medium |
| **Likelihood** | Possible |
| **Source** | BACKEND_ASSESSMENT.md |
| **Status** | Open |

**Description:**
Backend uses deprecated `request` package (unmaintained since 2020) which may have unpatched vulnerabilities.

**Impact:**
- No security patches available
- Potential undiscovered vulnerabilities

**Mitigation:**
1. Replace with axios or node-fetch
2. Review all usages for security implications

**Owner:** Backend Developer
**Target Date:** March 31, 2026
**Effort:** 4 hours

---

## Technical Risks

### TEC-001: GoogleSignIn SDK Severely Outdated (HIGH)

| Property | Value |
|----------|-------|
| **ID** | TEC-001 |
| **Category** | Technical |
| **Severity** | High |
| **Likelihood** | Likely |
| **Source** | iOS_CODEBASE_AUDIT.md |
| **Status** | Open |

**Description:**
iOS app uses GoogleSignIn 5.0.2 (deprecated) while current version is 7.1.0. Breaking API changes required.

**Impact:**
- Google authentication may stop working
- App Store rejection for deprecated SDK
- Security vulnerabilities in old SDK

**Mitigation:**
```swift
// OLD (5.x)
GIDSignIn.sharedInstance()?.signIn(with: config, presenting: viewController)

// NEW (7.x)
let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController)
```

**Owner:** iOS Developer
**Target Date:** February 28, 2026
**Effort:** 8 hours

---

### TEC-002: Inconsistent Deployment Targets (HIGH)

| Property | Value |
|----------|-------|
| **ID** | TEC-002 |
| **Category** | Technical |
| **Severity** | High |
| **Likelihood** | Possible |
| **Source** | iOS_CODEBASE_AUDIT.md |
| **Status** | Open |

**Description:**
iOS project has inconsistent deployment targets across targets (ranging from iOS 12.0 to 14.0).

| Target | Current | Should Be |
|--------|---------|-----------|
| Kuwboo (main) | 14.0 | 15.0 |
| KuwbooTests | 12.0 | 15.0 |
| KuwbooUITests | 12.0 | 15.0 |
| KuwbooAPI | 12.1 | 15.0 |
| KuwbooNotificationContent | 13.2 | 15.0 |
| KuwbooNotificationService | 12.0 | 15.0 |

**Impact:**
- Build warnings and potential failures
- API availability issues
- Inconsistent behavior

**Mitigation:**
1. Align all targets to iOS 15.0 minimum
2. Update Podfile deployment target
3. Test thoroughly after changes

**Owner:** iOS Developer
**Target Date:** February 15, 2026
**Effort:** 2 hours

---

### TEC-003: Zero Test Coverage (HIGH)

| Property | Value |
|----------|-------|
| **ID** | TEC-003 |
| **Category** | Technical |
| **Severity** | High |
| **Likelihood** | Possible (regression bugs) |
| **Source** | iOS_CODEBASE_AUDIT.md, BACKEND_ASSESSMENT.md |
| **Status** | Open |

**Description:**
Both iOS app and backend have effectively 0% test coverage. Only boilerplate test templates exist.

**Impact:**
- No regression detection
- Fear of refactoring
- Higher bug rates
- Difficult maintenance

**Mitigation:**
1. Add Jest + Supertest for backend API testing
2. Add XCTest for iOS ViewModels
3. Target 20% coverage for critical paths within 6 months

**Owner:** Development Team
**Target Date:** July 31, 2026
**Effort:** 80+ hours

---

### TEC-004: Sequelize 5.x End of Life (HIGH)

| Property | Value |
|----------|-------|
| **ID** | TEC-004 |
| **Category** | Technical |
| **Severity** | High |
| **Likelihood** | Possible |
| **Source** | BACKEND_ASSESSMENT.md |
| **Status** | Open |

**Description:**
Backend uses Sequelize 5.22.0 which is end-of-life and no longer receives security patches.

**Impact:**
- No security updates
- Compatibility issues with newer Node.js
- Missing performance improvements

**Mitigation:**
1. Upgrade to Sequelize 6.x
2. Review breaking changes in migration guide
3. Test all database operations

**Owner:** Backend Developer
**Target Date:** March 31, 2026
**Effort:** 8 hours

---

### TEC-005: Massive Classes Technical Debt (MEDIUM)

| Property | Value |
|----------|-------|
| **ID** | TEC-005 |
| **Category** | Technical |
| **Severity** | Medium |
| **Likelihood** | Likely |
| **Source** | iOS_CODEBASE_AUDIT.md |
| **Status** | Open |

**Description:**
Multiple iOS files exceed 1,000 lines, violating single responsibility principle:

| File | Lines |
|------|-------|
| EditPostVC.swift | 1,909 |
| ProductDetailVC.swift | 1,789 |
| ChatVC.swift | 1,750 |
| CreatePostVC.swift | 1,648 |
| HomeVC.swift | 1,006 |

**Impact:**
- Difficult to maintain
- Higher bug rates
- Slow development velocity
- Hard to test

**Mitigation:**
1. Extract subcomponents and helpers
2. Apply MVVM pattern more strictly
3. Break into smaller, focused classes

**Owner:** iOS Developer
**Target Date:** June 30, 2026
**Effort:** 48+ hours

---

### TEC-006: Deprecated UIGraphicsBeginImageContext API (MEDIUM)

| Property | Value |
|----------|-------|
| **ID** | TEC-006 |
| **Category** | Technical |
| **Severity** | Medium |
| **Likelihood** | Possible (iOS 17+) |
| **Source** | iOS_CODEBASE_AUDIT.md |
| **Status** | Open |

**Description:**
10 occurrences of deprecated `UIGraphicsBeginImageContext` API found.

**Impact:**
- Deprecated warnings in Xcode
- Potential removal in future iOS versions
- Memory inefficiencies

**Mitigation:**
```swift
// Modern replacement
let renderer = UIGraphicsImageRenderer(size: size)
let newImage = renderer.image { context in
    image.draw(in: rect)
}
```

**Owner:** iOS Developer
**Target Date:** April 30, 2026
**Effort:** 4 hours

---

### TEC-007: Socket.io In-Memory Session Storage (MEDIUM)

| Property | Value |
|----------|-------|
| **ID** | TEC-007 |
| **Category** | Technical |
| **Severity** | Medium |
| **Likelihood** | Rare (unless scaling) |
| **Source** | BACKEND_ASSESSMENT.md |
| **Status** | Open |

**Description:**
Socket.io client list stored in array in memory, preventing horizontal scaling.

**Impact:**
- Cannot run multiple server instances
- Memory growth over time
- Lost connections on server restart

**Mitigation:**
1. Enable Redis adapter (code exists but commented out)
2. Configure Redis connection
3. Test multi-instance deployment

**Owner:** Backend Developer
**Target Date:** May 31, 2026
**Effort:** 4 hours

---

### TEC-008: Force Unwraps in Critical Paths (MEDIUM)

| Property | Value |
|----------|-------|
| **ID** | TEC-008 |
| **Category** | Technical |
| **Severity** | Medium |
| **Likelihood** | Possible |
| **Source** | iOS_CODEBASE_AUDIT.md |
| **Status** | Open |

**Description:**
Force unwraps (`!`) used on URL construction and other operations that could fail.

**Locations:**
- `Constant.swift:24`
- `AppDelegate.swift:362`
- `InstagramLogin.swift:97,140`
- Various other files

**Impact:**
- App crashes if URL construction fails
- Poor error handling
- Bad user experience

**Mitigation:**
1. Use optional binding or guard statements
2. Provide fallback behavior
3. Log errors appropriately

**Owner:** iOS Developer
**Target Date:** April 30, 2026
**Effort:** 4 hours

---

### TEC-009: Mixed Async Patterns in Backend (LOW)

| Property | Value |
|----------|-------|
| **ID** | TEC-009 |
| **Category** | Technical |
| **Severity** | Low |
| **Likelihood** | Possible |
| **Source** | BACKEND_ASSESSMENT.md |
| **Status** | Open |

**Description:**
Backend mixes callbacks and Promise/async-await patterns inconsistently, making code harder to maintain and debug.

**Impact:**
- Error handling inconsistencies
- Potential race conditions
- Maintainability issues

**Mitigation:**
1. Standardize on async/await
2. Refactor callbacks to promises
3. Add ESLint rules for async patterns

**Owner:** Backend Developer
**Target Date:** June 30, 2026
**Effort:** 8 hours

---

### TEC-010: Large Payload Limit (DoS Risk) (LOW)

| Property | Value |
|----------|-------|
| **ID** | TEC-010 |
| **Category** | Technical |
| **Severity** | Low |
| **Likelihood** | Rare |
| **Source** | BACKEND_ASSESSMENT.md |
| **Status** | Open |

**Description:**
Body parser configured with 2000MB limit, enabling denial-of-service attacks.

```javascript
app.use(bodyParser.json({ limit: '2000mb' }));
```

**Impact:**
- Memory exhaustion attacks
- Server unresponsiveness
- Resource abuse

**Mitigation:**
1. Reduce limit to 10MB for most endpoints
2. Use separate limits for file uploads
3. Add request validation

**Owner:** Backend Developer
**Target Date:** March 31, 2026
**Effort:** 1 hour

---

### TEC-011: Hardcoded SwiftLint Path (LOW)

| Property | Value |
|----------|-------|
| **ID** | TEC-011 |
| **Category** | Technical |
| **Severity** | Low |
| **Likelihood** | Unlikely |
| **Source** | iOS_CODEBASE_AUDIT.md |
| **Status** | Open |

**Description:**
SwiftLint configuration contains hardcoded path `/Users/codiant/...` which should be removed.

**Impact:**
- Build issues on different machines
- Linting may not work correctly

**Mitigation:**
1. Remove hardcoded path
2. Use relative paths or environment variables

**Owner:** iOS Developer
**Target Date:** February 15, 2026
**Effort:** 30 minutes

---

### TEC-012: Privacy Manifests Unverified (MEDIUM)

| Property | Value |
|----------|-------|
| **ID** | TEC-012 |
| **Category** | Technical |
| **Severity** | Medium |
| **Likelihood** | Possible |
| **Source** | iOS_CODEBASE_AUDIT.md |
| **Status** | Open |

**Description:**
iOS 17 requires privacy manifests for certain APIs. 145 pod dependencies need verification for privacy manifest compliance.

**Impact:**
- App Store rejection
- Compliance issues

**Mitigation:**
1. Audit all pods for privacy manifest inclusion
2. Add manifests where missing
3. Document required API reasons

**Owner:** iOS Developer
**Target Date:** February 28, 2026
**Effort:** 4 hours

---

## Operational Risks

### OPS-001: No CI/CD Pipeline (HIGH)

| Property | Value |
|----------|-------|
| **ID** | OPS-001 |
| **Category** | Operational |
| **Severity** | High |
| **Likelihood** | Likely |
| **Source** | AWS_INFRASTRUCTURE_AUDIT.md |
| **Status** | Open |

**Description:**
No automated deployment pipelines exist. All deployments are manual, prone to errors and inconsistencies.

**Impact:**
- Deployment errors
- Configuration drift
- Slow release cycles
- No deployment audit trail

**Mitigation:**
1. Set up GitHub Actions for backend
2. Configure fastlane for iOS/Android
3. Implement staging → production workflow

**Owner:** DevOps
**Target Date:** April 30, 2026
**Effort:** 16 hours

---

### OPS-002: No Automated Backups (HIGH)

| Property | Value |
|----------|-------|
| **ID** | OPS-002 |
| **Category** | Operational |
| **Severity** | High |
| **Likelihood** | Unlikely (until needed) |
| **Source** | AWS_INFRASTRUCTURE_AUDIT.md |
| **Status** | Open |

**Description:**
AWS Backup not configured. Only RDS automated backup (1 day retention) exists.

**Impact:**
- Data loss risk
- No point-in-time recovery
- Compliance issues

**Mitigation:**
1. Configure AWS Backup for Aurora and S3
2. Extend RDS backup retention to 7+ days
3. Test restore procedures

**Owner:** DevOps
**Target Date:** March 31, 2026
**Effort:** 4 hours

---

### OPS-003: No CloudWatch Alarms (MEDIUM)

| Property | Value |
|----------|-------|
| **ID** | OPS-003 |
| **Category** | Operational |
| **Severity** | Medium |
| **Likelihood** | Unlikely (silent failures) |
| **Source** | AWS_INFRASTRUCTURE_AUDIT.md |
| **Status** | Open |

**Description:**
No CloudWatch alarms configured for critical metrics (CPU, memory, errors, API latency).

**Impact:**
- Undetected outages
- Slow incident response
- Poor reliability visibility

**Mitigation:**
1. Create alarms for EC2 CPU/memory
2. Create alarms for RDS connections/CPU
3. Create alarms for Lambda errors
4. Configure SNS notifications

**Owner:** DevOps
**Target Date:** March 31, 2026
**Effort:** 4 hours

---

### OPS-004: SSM Agent Not Installed (MEDIUM)

| Property | Value |
|----------|-------|
| **ID** | OPS-004 |
| **Category** | Operational |
| **Severity** | Medium |
| **Likelihood** | Rare |
| **Source** | AWS_INFRASTRUCTURE_AUDIT.md |
| **Status** | Open |

**Description:**
SSM Agent not running on EC2 instance despite IAM policy attached. Limits secure access options.

**Impact:**
- Must use SSH with IP whitelisting
- Less secure access pattern
- No session logging

**Mitigation:**
1. SSH to instance and install SSM agent
2. Verify agent registration
3. Test Session Manager access

**Owner:** DevOps
**Target Date:** March 15, 2026
**Effort:** 1 hour

---

### OPS-005: Single-AZ Database (CRITICAL)

| Property | Value |
|----------|-------|
| **ID** | OPS-005 |
| **Category** | Operational |
| **Severity** | Critical |
| **Likelihood** | Possible |
| **Source** | AWS_INFRASTRUCTURE_AUDIT.md |
| **Status** | Acknowledged |

**Description:**
Aurora MySQL cluster runs in single-AZ configuration with no Multi-AZ failover.

**Impact:**
- Single point of failure
- Extended downtime during AZ outage
- Data at risk during hardware failure

**Mitigation:**
1. Evaluate need for Multi-AZ (staging vs production)
2. If production, enable Multi-AZ
3. Consider cost vs availability tradeoff

**Owner:** DevOps
**Target Date:** Before Production Launch
**Effort:** 2 hours + cost increase

**Note:** Acceptable for staging/TestFlight. Required for production.

---

### OPS-006: Admin Panel Source Code Missing (MEDIUM)

| Property | Value |
|----------|-------|
| **ID** | OPS-006 |
| **Category** | Operational |
| **Severity** | Medium |
| **Likelihood** | Likely (if changes needed) |
| **Source** | AWS_INFRASTRUCTURE_AUDIT.md |
| **Status** | Open |

**Description:**
Admin panel React source code not available. Only compiled/minified build exists in S3.

**Impact:**
- Cannot modify admin panel
- Must rebuild from scratch if changes needed
- No version control

**Mitigation:**
1. Request source from Codiant, OR
2. Plan for admin panel rebuild
3. Document current functionality for rebuild reference

**Owner:** Project Manager
**Target Date:** TBD
**Effort:** High (if rebuild)

---

### OPS-007: No Git History for Backend (LOW)

| Property | Value |
|----------|-------|
| **ID** | OPS-007 |
| **Category** | Operational |
| **Severity** | Low |
| **Likelihood** | Unlikely |
| **Source** | AWS_INFRASTRUCTURE_AUDIT.md |
| **Status** | Acknowledged |

**Description:**
Backend code was recovered from EC2 server without git history. No version control history available.

**Impact:**
- Cannot track change history
- No blame information
- No revert capability

**Mitigation:**
1. Request git repository access from Codiant (nice-to-have)
2. Initialize new git repo with current state
3. Document known good state

**Owner:** Development Team
**Target Date:** Completed (new repo initialized)
**Effort:** N/A

---

## Business Risks

### BUS-001: App Store Age Rating Deadline (HIGH)

| Property | Value |
|----------|-------|
| **ID** | BUS-001 |
| **Category** | Business |
| **Severity** | High |
| **Likelihood** | Possible |
| **Source** | iOS_CODEBASE_AUDIT.md |
| **Status** | URGENT - Action Required |

**Description:**
Apple requires updated age rating questionnaire in App Store Connect by January 31, 2026.

**Impact:**
- App submission blocked
- App removed from store
- Lost users and revenue

**Mitigation:**
1. Log into App Store Connect
2. Navigate to App Store > App Information
3. Complete age rating questionnaire

**Owner:** Product Owner / Developer
**Target Date:** January 31, 2026
**Effort:** 30 minutes

---

### BUS-002: iOS 26 SDK Requirement (HIGH)

| Property | Value |
|----------|-------|
| **ID** | BUS-002 |
| **Category** | Business |
| **Severity** | High |
| **Likelihood** | Unlikely (time buffer) |
| **Source** | iOS_CODEBASE_AUDIT.md |
| **Status** | Open |

**Description:**
Apple will require iOS 26 SDK (Xcode 26) for app updates starting April 2026.

**Impact:**
- Cannot submit updates without new SDK
- Potential compatibility issues

**Mitigation:**
1. Install Xcode 26 beta when available (March 2026)
2. Test app with iOS 26 beta
3. Update any deprecated APIs
4. Verify pod compatibility

**Owner:** iOS Developer
**Target Date:** April 15, 2026
**Effort:** 8-16 hours

---

### BUS-003: Social Auth Integrations May Break (MEDIUM)

| Property | Value |
|----------|-------|
| **ID** | BUS-003 |
| **Category** | Business |
| **Severity** | Medium |
| **Likelihood** | Rare |
| **Source** | BACKEND_ASSESSMENT.md |
| **Status** | Open |

**Description:**
Backend uses deprecated passport packages for Instagram and Twitter authentication that may stop working.

| Package | Status |
|---------|--------|
| passport-instagram-token | Instagram Basic API deprecated |
| passport-twitter-token | Twitter/X API changes |

**Impact:**
- Users unable to authenticate via Instagram/Twitter
- Lost user acquisition channel

**Mitigation:**
1. Evaluate actual usage of these auth methods
2. If used, update to Meta Business API / Twitter OAuth2
3. If unused, remove dead code

**Owner:** Backend Developer
**Target Date:** May 31, 2026
**Effort:** 8-16 hours

---

### BUS-004: Database Over-Provisioned (MEDIUM)

| Property | Value |
|----------|-------|
| **ID** | BUS-004 |
| **Category** | Business |
| **Severity** | Medium |
| **Likelihood** | Certain (ongoing cost) |
| **Source** | AWS_INFRASTRUCTURE_AUDIT.md |
| **Status** | Open |

**Description:**
Aurora MySQL ($72/month) is over-provisioned for staging/TestFlight workload. RDS MySQL db.t3.micro ($15/month) would suffice.

**Impact:**
- $57/month unnecessary cost
- $684/year wasted

**Mitigation:**
1. Create RDS MySQL db.t3.micro instance
2. Migrate data via mysqldump
3. Update application configuration
4. Delete Aurora cluster

**Owner:** DevOps
**Target Date:** March 31, 2026
**Effort:** 4 hours

---

### BUS-005: No Production Domain (LOW)

| Property | Value |
|----------|-------|
| **ID** | BUS-005 |
| **Category** | Business |
| **Severity** | Low |
| **Likelihood** | Unlikely (until launch) |
| **Source** | AWS_INFRASTRUCTURE_AUDIT.md |
| **Status** | Acknowledged |

**Description:**
No production domain configured. App uses `kuwboo.codiantdev.com` (Codiant's subdomain).

| Domain | Status |
|--------|--------|
| kuwboo.com | Not registered |
| www.kuwboo.com | Not configured |
| admin.kuwboo.com | Not configured |

**Impact:**
- Dependency on Codiant's domain
- Unprofessional appearance
- Brand risk

**Mitigation:**
1. Register kuwboo.com domain
2. Configure DNS in Route53
3. Obtain SSL certificates
4. Update app configuration

**Owner:** Product Owner
**Target Date:** Before Production Launch
**Effort:** 4 hours

---

## Risk Tracking

### Status Definitions

| Status | Definition |
|--------|------------|
| **Open** | Risk identified, not yet mitigated |
| **In Progress** | Mitigation underway |
| **Mitigated** | Controls in place, residual risk acceptable |
| **Closed** | Risk eliminated |
| **Acknowledged** | Risk accepted without mitigation |

### Priority Definitions

| Priority | Criteria |
|----------|----------|
| **Critical** | Must fix immediately, blocks production |
| **High** | Fix within 30 days |
| **Medium** | Fix within 90 days |
| **Low** | Fix when convenient |

---

## Appendix: Risk Sources

| Document | Risks Identified |
|----------|------------------|
| AWS_INFRASTRUCTURE_AUDIT.md | OPS-001 to OPS-007, BUS-004, BUS-005, SEC-001, SEC-005 |
| BACKEND_ASSESSMENT.md | SEC-002, SEC-004, SEC-008 to SEC-011, TEC-003, TEC-004, TEC-007, TEC-009, TEC-010, BUS-003 |
| iOS_CODEBASE_AUDIT.md | SEC-003, SEC-006, SEC-007, TEC-001 to TEC-003, TEC-005, TEC-006, TEC-008, TEC-011, TEC-012, BUS-001, BUS-002 |
| MOBILE_CODEBASE_ASSESSMENT.md | Feature parity risks (covered elsewhere) |
| FEATURE_COMPARISON.md | Feature parity risks (covered elsewhere) |

---

**Document Version:** 1.0
**Next Review:** February 28, 2026
