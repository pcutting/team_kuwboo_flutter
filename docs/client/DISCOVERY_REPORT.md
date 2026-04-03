# Kuwboo Platform — Discovery Report

**Date:** January 27, 2026
**Prepared for:** Neil Douglas / Guess This Ltd (UK)
**Prepared by:** Philip Cutting / LionPro Dev
**Version:** 1.0

---

## Executive Summary

LionPro Dev conducted a comprehensive discovery phase of the Kuwboo platform, assessing the existing codebase, infrastructure, feature set, and operational posture. The purpose was to understand the current state of the platform, identify risks, evaluate options, and recommend a path forward.

### Key Findings

| Area | Assessment |
|------|-----------|
| **Backend API** | Functional but built on outdated dependencies with security vulnerabilities |
| **Mobile Apps** | Two separate native apps (iOS and Android) with inconsistent feature sets |
| **Infrastructure** | Running on AWS (London region) with higher costs than necessary |
| **Security** | Several vulnerabilities identified, including issues in authentication and data handling |
| **Testing** | No automated tests exist across any part of the platform |
| **Deployment** | No automated deployment pipeline; all changes are manual |

### Recommendation

Based on the discovery findings, we recommend a **full platform rebuild** using modern technologies. The combination of outdated dependencies, security vulnerabilities, lack of testing, two separate mobile codebases, and the scope of Neil's feature vision makes a rebuild more cost-effective and lower-risk than attempting to modernise the existing code. The detailed rationale is presented in Section 9.

---

## 1. Discovery Scope

The discovery phase covered the following areas, as agreed in the scope of work:

| Deliverable | Status |
|-------------|--------|
| Code and system review | Complete |
| Technical assessment report | Complete |
| Risk and issue register | Complete |
| Infrastructure audit | Complete |
| System architecture diagram | Complete |
| Cost analysis and optimisation recommendations | Complete |
| Technical feasibility assessment | Complete |
| MVP scope considerations | Complete |
| Development roadmap | Complete |

### What Was Assessed

- **Backend API:** 530 JavaScript files (Node.js / Express / Sequelize)
- **iOS App:** 1,881 Swift files (MVVM + RxSwift architecture)
- **Android App:** 1,130 Kotlin files
- **AWS Infrastructure:** EC2, Aurora MySQL, S3, Lambda, CloudFront, MediaConvert
- **Database:** Aurora MySQL with 130+ tables

---

## 2. Platform Assessment

### 2.1 Backend API

The backend is a Node.js application built with Express.js and Sequelize ORM, connecting to an Aurora MySQL database on AWS.

| Aspect | Assessment | Notes |
|--------|-----------|-------|
| **Architecture** | Fair | Clean MVC pattern with repository layer and service separation |
| **Security** | Needs Attention | Outdated authentication library with known vulnerabilities; input validation gaps |
| **Dependencies** | Outdated | Several core packages are end-of-life or have known security issues |
| **Testing** | None | No automated tests of any kind |
| **Documentation** | Minimal | Partial Swagger API docs; no inline documentation |
| **Code Quality** | Mixed | Consistent patterns but technical debt accumulated over time |

**What Works Well:**
- Repository pattern provides clean data access
- Consistent patterns across modules (Video, Buy & Sell, Social, Chat)
- Functional real-time messaging via Socket.io
- Media processing pipeline (S3 upload, video transcoding via MediaConvert)

**Areas of Concern:**
- Core authentication library has published security advisories
- No rate limiting on API endpoints (risk of brute-force attacks)
- Real-time connections stored in-memory (cannot scale horizontally)
- 2GB request body limit creates denial-of-service risk
- Several deprecated packages still in use

**API Coverage:** Approximately 100+ endpoints across authentication, feeds, chat, marketplace, social features, media handling, and administration.

### 2.2 Mobile Applications

Two separate native applications exist — one for iOS (Swift) and one for Android (Kotlin). They were developed independently, leading to feature inconsistencies.

#### iOS App

| Property | Detail |
|----------|--------|
| Language | Swift |
| Architecture | MVVM + Router + RxSwift |
| Size | 1,881 files, ~124,000 lines of code |
| Dependencies | 145 CocoaPods |

**Strengths:**
- Well-structured MVVM architecture
- Comprehensive module coverage (Video, Buy & Sell, Social, Dating, Chat)
- Push notification support

**Concerns:**
- Google Sign-In SDK severely outdated (v5 vs current v7) — may stop working
- Allows unencrypted HTTP connections (security risk)
- Several very large view controllers (1,000+ lines) indicating accumulated complexity
- Inconsistent deployment targets across build components

#### Android App

| Property | Detail |
|----------|--------|
| Language | Kotlin |
| Size | 1,130 files, ~28,000 lines of code |

**Strengths:**
- Kotlin codebase (modern language)
- Core module support

**Concerns:**
- Significantly smaller codebase suggests fewer features than iOS
- Feature parity gaps with iOS version

#### Feature Parity Analysis

| Module | iOS | Android | Gap |
|--------|-----|---------|-----|
| Video Making | Full | Full | Minimal |
| Buy & Sell | Full | Partial | Auction features incomplete on Android |
| Social / Stumble | Full | Basic | Social discovery features limited |
| Dating | Partial | Basic | Matching logic incomplete on both |
| Chat | Full | Full | Minimal |
| YoYo (Nearby) | Partial | Basic | Location features limited |
| Admin Panel | N/A | N/A | Web-only (source code not available) |

The feature parity gaps are a key factor in the mobile strategy recommendation (Section 5).

### 2.3 Cloud Infrastructure (AWS)

The platform runs on AWS in the London (eu-west-2) region under account 166927554624.

#### Active Resources

| Service | Purpose | Monthly Cost |
|---------|---------|-------------|
| EC2 (t3.medium) | API server | ~$61 |
| Aurora MySQL | Database | ~$72 |
| S3 (3 buckets) | Media storage, frontend hosting | ~$1 |
| Lambda (2 functions) | Video processing pipeline | < $1 |
| CloudFront (2 distributions) | CDN for frontend and media | < $1 |
| MediaConvert | Video transcoding | Usage-based |
| **Total** | | **~$137/month** |

#### Architecture

```
Mobile App / Web → CloudFront (CDN) → S3 (media + frontend)
                 → EC2 (API server) → Aurora MySQL (database)
                 → S3 (video upload) → Lambda → MediaConvert → S3 (processed video)
```

#### Infrastructure Concerns

| Issue | Impact |
|-------|--------|
| Database over-provisioned | Aurora MySQL costs ~$72/month; a standard RDS instance would cost ~$15/month for the same workload |
| No automated deployment | All deployments are manual, increasing error risk |
| No monitoring or alerting | No CloudWatch alarms configured; outages would go undetected |
| No automated backups beyond RDS defaults | Limited disaster recovery capability |
| Single availability zone | Single point of failure for the database |
| No CI/CD pipeline | No automated testing or deployment workflow |

#### Domain Status

No production domain is configured. The platform currently uses a subdomain provided by the previous developer. Production domains (e.g., kuwboo.com) need to be registered and configured before launch.

### 2.4 Database

The database contains 130+ tables in Aurora MySQL, organised around the module key architecture.

#### Module Key Architecture

A key architectural pattern is the **module key system**, where shared tables (like chat threads) serve multiple features. A `moduleKey` column determines which feature a record belongs to:

| Module Key | Feature |
|-----------|---------|
| `video_making` | TikTok-style video feed |
| `buy_sell` | Marketplace |
| `dating` | Dating and matching |
| `social_stumble` | Social discovery |

This pattern also extends to content types like blogs, notice boards, VIP pages, discount listings, and lost-and-found posts.

**Why this matters:** The shared infrastructure pattern means changes to core systems (chat, notifications) affect all modules. The rebuild carries this pattern forward with a cleaner implementation.

#### Category Structure

Each module maintains its own category hierarchy:

| Module | Categories |
|--------|-----------|
| Video | 27 categories |
| Buy & Sell | 54 categories (hierarchical) |
| Blog | 30 categories |
| Notice Board | Module-specific |

---

## 3. Feature Inventory

Based on the codebase review and Neil's confirmed priorities, the platform has six primary modules:

| Priority | Module | Description | Codebase Status |
|----------|--------|-------------|-----------------|
| 1 | **Video Making** | TikTok-style short video feed with creation, editing, filters, and social interactions | Most complete across both platforms |
| 2 | **Social (with Stumble)** | Social discovery feed, friend finding, activity stream, and random discovery feature | Complete on iOS, basic on Android |
| 3 | **Buy & Sell** | Marketplace with product listings, categories, auction/bidding, seller profiles | Complete on iOS, partial on Android |
| 4 | **YoYo** | Location-based nearby user discovery with distance-based list view | Partial on both platforms |
| 5 | **Sponsored Links** | Promoted content system for in-feed advertising and revenue generation | Backend structure exists, needs development |
| 6 | **Dating** | User profiles, matching, discovery (deferred post-MVP) | Incomplete on both platforms |

### Extended Content Modules

Additional content types share the same backend patterns:

- Blog posts
- Notice board announcements
- VIP / brand pages
- Discount listings
- Lost and found items
- Missing person reports

These are lower priority and will be addressed after core modules are stable.

---

## 4. Risk Assessment

The discovery phase identified **35 risks** across four categories. Below is a summary organised by priority.

### Definitions

| Severity | Meaning |
|----------|---------|
| **Critical** | Must be addressed before any production use |
| **High** | Should be addressed within 30 days of active development |
| **Medium** | Should be addressed within 90 days |
| **Low** | Address when convenient |

### Risk Summary

| Category | Critical | High | Medium | Low | Total |
|----------|----------|------|--------|-----|-------|
| Security | 3 | 4 | 3 | 1 | 11 |
| Technical | 0 | 4 | 5 | 3 | 12 |
| Operational | 1 | 2 | 3 | 1 | 7 |
| Business | 0 | 2 | 2 | 1 | 5 |
| **Total** | **4** | **12** | **13** | **6** | **35** |

### 4.1 Critical Security Risks

| ID | Risk | Description |
|----|------|-------------|
| SEC-001 | **Data handling vulnerability** | A component that processes video uploads contains a vulnerability that could allow unauthorised database modifications |
| SEC-002 | **Authentication bypass** | A testing shortcut in the authentication flow was left in place, allowing access without proper verification |
| SEC-004 | **Outdated authentication library** | The JWT (JSON Web Token) library has known security advisories that could allow token manipulation |

> **What is a JWT?** A JSON Web Token is an industry-standard method for securely transmitting authentication information between the app and the server. Think of it as a digital key that proves a user is logged in.

### 4.2 High-Priority Risks

| ID | Risk | Category |
|----|------|----------|
| SEC-003 | iOS app allows unencrypted connections | Security |
| SEC-005 | Credentials accessible to previous developer need rotation | Security |
| SEC-008 | No rate limiting on API (brute-force risk) | Security |
| SEC-010 | HTTP library has known vulnerability | Security |
| TEC-001 | Google Sign-In SDK severely outdated | Technical |
| TEC-002 | Inconsistent build configurations | Technical |
| TEC-003 | Zero automated test coverage | Technical |
| TEC-004 | Database ORM (Sequelize) is end-of-life | Technical |
| OPS-001 | No automated deployment pipeline | Operational |
| OPS-002 | No automated backup strategy | Operational |
| OPS-005 | Single-availability-zone database | Operational |
| BUS-001 | App Store requirements deadline | Business |

### 4.3 Medium and Low Risks

An additional 19 risks were identified covering:
- Deprecated APIs and packages that may stop working
- Code quality issues (large files, mixed coding patterns)
- Missing monitoring and alerting
- Domain registration requirements
- Social authentication integrations that may break
- Database cost optimisation opportunities

### 4.4 Risk Disposition

All identified risks are addressed by the rebuild strategy:
- **Security vulnerabilities** are eliminated by building on modern, maintained libraries
- **Technical debt** does not carry forward — the new codebase starts clean
- **Operational gaps** (CI/CD, monitoring, backups) are part of the infrastructure plan
- **Business risks** (App Store compliance, domain setup) are tracked in the project plan

---

## 5. Mobile Strategy Recommendation

### The Problem

Maintaining two separate native mobile applications (iOS in Swift, Android in Kotlin) means:
- Every feature must be built twice
- Every bug fix must be applied twice
- Feature parity is difficult to maintain (as evidenced by the gaps found)
- Two separate skill sets required for development
- Higher long-term maintenance cost

### The Recommendation: Flutter

We recommend rebuilding the mobile applications using **Flutter**, Google's cross-platform framework.

> **What is Flutter?** Flutter is a framework from Google that lets developers write one codebase that runs on both iOS and Android (and web). It compiles to native code, so performance is comparable to apps built specifically for each platform.

#### Why Flutter

| Factor | Native (Current) | Flutter (Proposed) |
|--------|------------------|-------------------|
| **Codebases to maintain** | 2 (Swift + Kotlin) | 1 (Dart) |
| **Feature parity** | Difficult (currently inconsistent) | Guaranteed (single codebase) |
| **Development speed** | Slower (everything built twice) | Faster (build once) |
| **Developer availability** | Need iOS + Android specialists | Flutter developers handle both |
| **Long-term maintenance** | Higher (two codebases diverge over time) | Lower (one codebase to update) |
| **Performance** | Native | Near-native (compiled to ARM) |
| **App Store compliance** | Separate submissions | Single codebase, separate submissions |

#### What Flutter Handles Well for Kuwboo

- **Video playback and camera:** Flutter's video and camera plugins are mature
- **Real-time messaging:** Socket.io client libraries available for Dart
- **Location services:** PostGIS integration via standard location APIs
- **Push notifications:** Firebase Cloud Messaging works natively
- **Secure storage:** Keychain (iOS) and EncryptedSharedPreferences (Android) via `flutter_secure_storage`

#### Trade-offs

- Flutter adds ~5-10MB to app size compared to pure native
- Some platform-specific features (e.g., iOS widgets) require additional configuration
- The development team needs Flutter/Dart experience (LionPro Dev has this)

---

## 6. MVP Strategy

### Recommended Approach: Multi-Module Launch

Based on Neil's priorities, we recommend launching with the five core modules rather than a single-feature MVP:

1. **Video Making** — the primary engagement driver
2. **Social (with Stumble)** — user discovery and retention
3. **Buy & Sell** — marketplace revenue opportunity
4. **YoYo** — location-based differentiation
5. **Sponsored Links** — revenue model

**Dating** is deferred to a post-launch phase.

### What This Gets Right

- Preserves Kuwboo's multi-module identity (it's not "just another TikTok clone")
- Each module reinforces the others (social discovery drives marketplace traffic)
- Revenue model (Sponsored Links + marketplace commissions) is present from day one
- Dating can be added with proper safety infrastructure in place

---

## 7. Development Roadmap

The rebuild is structured as six milestones, each building on the previous:

| Milestone | Focus | Target |
|-----------|-------|--------|
| **M1: Design & Architecture** | UI/UX design, technical architecture, design system | Months 1-2 |
| **M2: Backend Core & Auth** | API framework, authentication, media pipeline, push notifications | Months 2-4 |
| **M3: Video + Social** | Video feed, social discovery, Stumble, content moderation | Months 4-6 |
| **M4: Buy & Sell + Sponsored** | Marketplace, auctions, seller profiles, promoted content | Months 6-8 |
| **M5: YoYo + Notifications** | Location features, cross-module notifications, website | Months 8-10 |
| **M6: Testing & Launch** | QA, performance, App Store submission, polish | Months 10-12 |

Each milestone has defined acceptance criteria documented in the project contract.

---

## 8. Cost Analysis

### Current Monthly Costs

| Service | Monthly Cost | Notes |
|---------|-------------|-------|
| Aurora MySQL (database) | $72 | Over-provisioned for current usage |
| EC2 (API server) | $61 | Appropriately sized |
| Other (S3, networking) | $4 | Storage and data transfer |
| **Total (before tax)** | **~$137** | |

### Optimised Monthly Costs (Post-Rebuild)

| Service | Monthly Cost | Notes |
|---------|-------------|-------|
| EC2 (t3.medium) | ~$30 | API server |
| RDS PostgreSQL (db.t3.micro) | ~$15-23 | Right-sized database |
| Secrets Manager | ~$5 | Credential management |
| Route 53 | ~$2 | DNS |
| **Total** | **~$52-60** | |

**Annual savings:** Approximately **$920-$1,020** compared to current costs.

### Cost Reduction Already Achieved

During the discovery phase, we identified that the legacy database (Aurora MySQL) was significantly over-provisioned. The greenfield infrastructure uses a right-sized PostgreSQL instance, reducing database costs by approximately $50/month.

The legacy infrastructure has been hibernated (services stopped but preserved) to minimise costs while retaining the ability to restore if needed. Monthly cost for hibernated services: approximately $6-10.

---

## 9. Recommendation: Full Platform Rebuild

### Why Rebuild Rather Than Patch

The discovery phase thoroughly assessed the existing platform. While the codebase is functional and follows reasonable architectural patterns, the combination of factors below makes a rebuild the more prudent investment:

| Factor | Patch Approach | Rebuild Approach |
|--------|---------------|-----------------|
| **Security vulnerabilities** | Fix individually (weeks of work) | Eliminated by modern stack |
| **Two mobile codebases** | Continue maintaining both | Single Flutter codebase |
| **Feature parity gaps** | Fix individually per platform | Guaranteed from day one |
| **Outdated dependencies** | Upgrade each (breaking changes likely) | Start with current versions |
| **Zero test coverage** | Add tests to unfamiliar code | Test-first development |
| **No CI/CD** | Add pipeline to legacy system | Built into new workflow |
| **Database over-provisioning** | Migrate within MySQL | PostgreSQL with modern features |
| **Neil's feature vision** | Constrained by existing architecture | Architecture designed for full scope |

### The Decisive Factors

1. **Two native mobile apps → one Flutter app.** This alone justifies the rebuild. Maintaining feature parity across two separate codebases is an ongoing cost that compounds over the life of the product.

2. **Neil's feature scope exceeds what patching can deliver.** The five confirmed modules (Video, Social, Buy & Sell, YoYo, Sponsored Links) plus future Dating require an architecture designed for this scale. Bolting new features onto the existing codebase would be slower and riskier.

3. **Security requires a clean foundation.** The number of vulnerabilities, combined with the need to rotate all credentials, means the security remediation effort alone approaches the cost of building core authentication from scratch — with the added benefit of modern security patterns.

4. **No legacy data migration required.** A rebuild typically carries the risk of data migration complexity. In Kuwboo's case, the app is pre-launch with no live user data to migrate. This removes the largest rebuild risk.

### What Carries Forward

The rebuild is informed by everything learned during discovery:
- The module key architecture (proven pattern, carried forward)
- Category structures (video: 27, marketplace: 54, blog: 30)
- Feature specifications (mapped from existing codebase)
- Real-time messaging patterns
- Media processing pipeline design
- Understanding of Neil's priorities and aesthetic preferences

---

## 10. Documents Delivered

### Discovery Phase Documents

| Document | Description |
|----------|-------------|
| This report | Consolidated discovery findings and recommendations |
| Backend assessment | Detailed backend code review |
| iOS codebase audit | Detailed iOS app review |
| Mobile assessment | Cross-platform comparison |
| AWS infrastructure audit | Complete cloud resource inventory |
| Database schema documentation | Table and category structure |
| Feature comparison | iOS vs Android feature parity |
| Mobile strategy analysis | Flutter vs native evaluation |
| Risk register | 35 identified risks with severity and mitigation |
| MVP scope document | Feature prioritisation strategy |
| Architecture diagrams | System topology (Mermaid format) |
| Development roadmap | Phase-based timeline |

### Post-Discovery Documents

| Document | Description |
|----------|-------------|
| Contract | Signed rebuild contract ($60,000, 6 milestones) |
| Development scope | Full rebuild plan with phases and costs |
| Feature architecture | Client-facing feature overview |
| Design review feedback | Neil's design preferences captured |

---

## 11. Sign-Off

This Discovery Report summarises the findings from the discovery phase conducted by LionPro Dev. The findings informed the decision to proceed with a full platform rebuild, as documented in the signed contract.

By signing below, the client acknowledges receipt and review of the discovery findings.

| | Client | Contractor |
|---|--------|------------|
| **Name** | Neil Douglas | Philip Cutting |
| **Entity** | Guess This Ltd | LionPro Dev |
| **Date** | _________________ | _________________ |
| **Signature** | _________________ | _________________ |

---

*LionPro Dev — Discovery Phase Complete*
*January 27, 2026*
