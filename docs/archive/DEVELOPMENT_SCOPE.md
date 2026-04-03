> **DEPRECATED** — Superseded by team/internal/ architecture docs (references outdated Fastify/Prisma stack). Retained for historical context.

# Kuwboo Rebuild: Full Development Scope

**Created:** February 15, 2026
**Last Updated:** February 15, 2026
**Version:** 1.0
**Purpose:** Comprehensive development plan covering Flutter app, new backend, data migration, App Store launch, and growth phases

**Related Documents:**
- [INITIAL_DESIGN_SCOPE.md](INITIAL_DESIGN_SCOPE.md) -- Designer commission scope (~48 screens, $6-9K)
- [FEATURE_ANALYSIS_MVP.md](FEATURE_ANALYSIS_MVP.md) -- Neil's 6 priorities mapped to codebase state
- [MOBILE_STRATEGY_ANALYSIS.md](MOBILE_STRATEGY_ANALYSIS.md) -- Flutter rebuild rationale ($76K 2-year TCO vs $128K native)
- [BACKEND_ASSESSMENT.md](BACKEND_ASSESSMENT.md) -- Existing backend analysis (530 JS files, Express/Sequelize)
- [AWS_INFRASTRUCTURE_AUDIT.md](AWS_INFRASTRUCTURE_AUDIT.md) -- Current infrastructure ($137/month)
- [RISK_REGISTER.md](RISK_REGISTER.md) -- 35 identified risks (4 critical, 12 high)

---

## Part 1: Executive Summary

### What This Document Covers

This is the master plan for rebuilding Kuwboo from the ground up: a new Flutter mobile app, a new TypeScript backend, migrating Neil's existing data, launching on the App Store, and growing the platform after launch.

### Key Numbers

| Metric | Value |
|--------|-------|
| **Total Investment** | $91,000 -- $127,000 across all phases |
| **Timeline to App Store** | 27-38 weeks (foundation through launch) |
| **Monthly Infrastructure** | ~$80-100/month (down from ~$137 today) |
| **Ongoing After Launch** | $2,000-$4,000/month (maintenance + growth features) |
| **Tech Stack** | Flutter 3.x + Fastify 4.26 + Prisma 5.10 + PostgreSQL 16 |
| **Platforms** | iOS + Android from a single codebase |

### What Neil Gets at Each Phase Gate

| Phase | Neil Receives |
|-------|---------------|
| **Phase 1 complete** | Professional screen designs in Figma, automated deployment pipeline, infrastructure costs cut by ~40%, database migration plan validated |
| **Phase 2 complete** | Working Flutter app with Video + Shop + Social (replacing current iOS app), new backend API running, all existing user data migrated |
| **Phase 3 complete** | Dating, Yoyo proximity discovery, and Sponsored Links added to the app |
| **Phase 4 complete** | App live on App Store and Google Play, monitoring in place |
| **Phase 5 ongoing** | Analytics dashboard, content moderation tools, admin panel, monetisation features |

---

## Part 2: What We Start With

### Already Scaffolded

We are not starting from zero. Significant groundwork is in place across three areas:

#### Flutter App (`kuwboo-rebuild/mobile/`)

| Component | Status | Key Packages |
|-----------|--------|--------------|
| Project structure | Complete | Flutter 3.x, Dart SDK >=3.2 |
| State management | Complete | Riverpod 2.4.10 |
| Navigation | Complete | GoRouter 13.2, 12 routes defined |
| API client | Complete | Dio 5.4.1 with token refresh |
| Auth flow | Complete | Login, OTP, onboarding screens built |
| Theme system | Complete | Light + dark mode, Poppins font, tab accent colours |
| Maps & location | Configured | google_maps_flutter 2.5.3, Geolocator 11.0 |
| Camera & media | Configured | camera 0.10.5, video_player 2.8.3 |
| Firebase push | Configured | firebase_messaging 15.2.0 |
| SSO providers | Configured | google_sign_in 6.2.1, sign_in_with_apple 6.1.0 |

**What's placeholder only:** Video feed, Dating, Social feed, Shop, Yoyo map, Inbox, Profile, Settings (routes exist, screens show "Coming Soon").

#### Backend API (`kuwboo-rebuild/backend/`)

| Component | Status | Key Packages |
|-----------|--------|--------------|
| Framework | Scaffolded | Fastify 4.26.2 + TypeScript 5.3 |
| ORM & database | Scaffolded | Prisma 5.10.2 + PostgreSQL |
| Auth | Scaffolded | @fastify/jwt 8.0.1, bcrypt 5.1 |
| Real-time | Configured | Socket.io 4.7.4 |
| Rate limiting | Configured | @fastify/rate-limit 9.1.0 |
| Media uploads | Configured | @fastify/multipart 8.1, AWS SDK v3 |
| Validation | Configured | Zod 3.22 |
| Testing | Configured | Vitest 1.3 |
| API docs | Configured | @fastify/swagger 8.14 |

#### Prisma Schema (Unified Content Model)

The database schema is already designed in Prisma, mapping the existing 130+ MySQL tables to a unified PostgreSQL model:

| Model | Purpose | Replaces |
|-------|---------|----------|
| User | Unified user with location (PostGIS) | users, user_settings, user_images (6+ tables) |
| Content | Unified content with JSONB metadata | feeds, buy_sell_products, social_stumbles (15+ tables) |
| Interaction | Likes, saves, bids, swipes | feed_likes, bids, user_match_profiles (10+ tables) |
| Connection | Follows, friends, matches, blocks, yoyo | user_followers, user_blocks, dating_unmatch (8+ tables) |
| Thread/Message | Chat with thread participants | threads, chats, chat_medias (5+ tables) |
| Auction/Bid | Marketplace bidding | bids, buy_sell_products (auction fields) |
| YoyoSettings | Proximity discovery preferences | New (no equivalent) |
| Report/AuditLog | Moderation and safety | report_users, report_contents (4+ tables) |

**Total:** ~15 Prisma models replacing 130+ MySQL tables.

#### Design Explorations

We have 26 design variants in a Flutter viewer (`new_douglas/design/viewer/`) covering aesthetic directions (Neo-Brutalist, Soft Luxury, Calm Tech, etc.). These are our internal explorations to gather user opinions -- separate from the professional designer's scope.

#### Existing Data

| Asset | Size | Location |
|-------|------|----------|
| MySQL database dump | 30 MB | EC2 server (`/home/ubuntu/kuwboo_db_stag.sql`) |
| Media files | ~187 MB | S3 bucket (`kuwboo-dev`) |
| Video uploads | Unknown | S3 bucket (`kuwboo-dev-new`) |
| Backend code (legacy) | 530 JS files | `backend/kuwboo-api/` (local copy) |

---

## Part 3: Growth Phases

### Phase Overview

| Phase | Name | Duration | Cost Range | Running Total |
|-------|------|----------|-----------|---------------|
| 1 | Foundation | 4-6 weeks | $12,000-$18,000 | $12K-$18K |
| 2 | Feature Parity | 12-16 weeks | $50,000-$68,000 | $62K-$86K |
| 3 | New Features | 8-12 weeks | $16,000-$24,000 | $78K-$110K |
| 4 | Launch | 3-4 weeks | $3,000-$5,000 | $81K-$115K |
| 5 | Growth | Ongoing | $2,000-$4,000/month | +monthly |
| -- | Contingency (15%) | -- | $12,000-$17,000 | **$91K-$127K** |

---

### Phase 1: Foundation (4-6 weeks, $12,000-$18,000)

**Goal:** Lay the groundwork so development can proceed without blockers.

#### Deliverables

| Deliverable | Cost | Duration |
|-------------|------|----------|
| Design commission (Tier 1-2, ~48 screens in Figma) | $6,000-$9,000 | 3 weeks (designer) |
| CI/CD pipeline (GitHub Actions for backend, Fastlane/Codemagic for Flutter) | $1,500-$2,500 | 1 week |
| Infrastructure optimisation (Aurora $72/mo to RDS PostgreSQL $15/mo) | $500-$1,000 | 2 days |
| Database migration plan (schema mapping, pgloader scripts, validation strategy) | $1,500-$2,000 | 1 week |
| Security quick wins (rotate credentials, fix Lambda SQL injection, add rate limiting) | $1,000-$1,500 | 3 days |
| Automated backups (RDS snapshots, S3 lifecycle rules) | $500-$1,000 | 1 day |
| CloudWatch alarms (CPU, memory, errors, latency) | $500-$500 | 1 day |

#### Dependencies

- Neil approves design budget ($6-9K)
- Neil provides brand assets (logo, colour preferences) to designer
- AWS account access (already available)

#### Exit Criteria

- [ ] Figma file with ~48 screens delivered and approved by Neil
- [ ] `git push` to `main` triggers automated backend deployment to EC2
- [ ] Infrastructure costs reduced to ~$80-100/month
- [ ] Database migration scripts tested against dump file
- [ ] All critical security risks (SEC-001, SEC-002, SEC-004) resolved
- [ ] CloudWatch alerts firing on anomalies

---

### Phase 2: Feature Parity (12-16 weeks, $50,000-$68,000)

**Goal:** Build a Flutter app that replaces everything the current iOS app does, backed by a new API.

#### Deliverables -- Flutter App

| Module | Screens | Effort | Cost |
|--------|---------|--------|------|
| Video Making (feed, recorder, editor, sounds, search) | ~12 | 4 weeks | $8,000 |
| Buy & Sell (listings, categories, product detail, bidding) | ~12 | 3 weeks | $6,000 |
| Social/Stumble (feed, posts, events, friends) | ~10 | 2 weeks | $4,000 |
| Chat/Messaging (inbox, conversation, media, Socket.io) | ~5 | 2 weeks | $4,000 |
| Shared screens (profile, settings, notifications, CMS) | ~14 | 2 weeks | $4,000 |
| Push notifications (Firebase) | -- | 0.5 weeks | $1,000 |
| Testing and polish | -- | 2 weeks | $4,000 |
| **Flutter subtotal** | **~53** | **15.5 weeks** | **$31,000** |

#### Deliverables -- Backend API

| Component | Endpoints | Effort | Cost |
|-----------|-----------|--------|------|
| Auth (phone OTP, email, Google SSO, Apple SSO, JWT refresh) | ~10 | 1.5 weeks | $3,000 |
| Users (profile CRUD, preferences, followers, blocks) | ~8 | 1 week | $2,000 |
| Content (unified CRUD, feed algorithms, search) | ~8 | 2 weeks | $4,000 |
| Marketplace (products, auctions, bidding, categories) | ~6 | 1.5 weeks | $3,000 |
| Messaging (threads, messages, Socket.io real-time) | ~6 | 1.5 weeks | $3,000 |
| Media pipeline (S3 upload, MediaConvert integration) | ~4 | 1 week | $2,000 |
| Admin API (user management, content moderation) | ~5 | 1 week | $2,000 |
| **Backend subtotal** | **~47** | **10 weeks** | **$19,000** |

#### Deliverables -- Data Migration

| Task | Effort | Cost |
|------|--------|------|
| MySQL to PostgreSQL migration (pgloader + custom scripts) | 1 week | $2,000 |
| Data validation and integrity checks | 3 days | $1,000 |
| **Migration subtotal** | **1.5 weeks** | **$3,000** |

**Note:** Flutter and backend work run in parallel. Total elapsed time is 12-16 weeks, not the sum of individual efforts.

#### Dependencies

- Phase 1 complete (designs in hand, CI/CD working, migration plan validated)
- Neil available for weekly progress reviews (30-minute check-ins)

#### Exit Criteria

- [ ] Flutter app on TestFlight/internal testing with Video + Shop + Social fully functional
- [ ] New backend API serving all mobile requests
- [ ] All existing users and content migrated to PostgreSQL
- [ ] Socket.io real-time messaging working
- [ ] Push notifications delivering on both iOS and Android
- [ ] No critical bugs in core user flows

---

### Phase 3: New Features (8-12 weeks, $16,000-$24,000)

**Goal:** Add the features Neil wants that don't exist in the current app.

#### Deliverables

| Feature | Backend | Flutter | Design | Total Cost |
|---------|---------|---------|--------|------------|
| Dating (profiles, swipe matching, preferences) | 1.5 weeks / $3,000 | 2 weeks / $4,000 | Part of future commission | $7,000 |
| Yoyo proximity discovery (profiles, nearby feed, connections) | 1 week / $2,000 | 2 weeks / $4,000 | Part of future commission | $6,000 |
| Sponsored Links (ad creation, targeting, impressions, analytics) | 1 week / $2,000 | 1 week / $2,000 | Part of future commission | $4,000 |
| Second design commission (Dating + Yoyo + Ads, ~16 screens) | -- | -- | $3,000-$4,500 | $3,000-$4,500 |
| Integration testing across all modules | -- | 1 week / $2,000 | -- | $2,000 |

**Yoyo leverages existing infrastructure:** PostGIS geography columns already in Prisma schema, Google Maps SDK in Flutter app, Geolocator configured. The Haversine distance formula from the legacy backend is replaced by PostgreSQL's native PostGIS `ST_DWithin` for proximity queries.

#### Dependencies

- Phase 2 complete (core app working end-to-end)
- Second design commission approved by Neil ($3-4.5K)

#### Exit Criteria

- [ ] Dating swipe interface working with mutual matching
- [ ] Yoyo showing nearby users on map and list views
- [ ] Sponsored Links displaying in video feed with impression tracking
- [ ] All 6 of Neil's priority features (Video, Shop, Social, Dating, Yoyo, Sponsored Links) functional

---

### Phase 4: Launch (3-4 weeks, $3,000-$5,000)

**Goal:** Get the app approved and live on both stores.

#### Deliverables

| Task | Effort | Cost |
|------|--------|------|
| TestFlight beta (invite 10-20 testers, collect feedback, fix issues) | 1 week | $1,000 |
| App Store assets (screenshots, preview video, description, keywords) | 2 days | $500 |
| App Store submission (age rating, privacy questionnaire, review guidelines) | 1 day | $200 |
| Google Play submission (content rating, data safety, store listing) | 1 day | $200 |
| Production infrastructure (domain registration, SSL, monitoring) | 2 days | $500 |
| Launch monitoring (crash tracking, error rates, performance baselines) | 1 week | $500-$1,000 |
| Post-launch bug fixes (first 2 weeks) | 2 weeks | $1,000-$1,500 |

#### Dependencies

- Phase 3 complete (all features working)
- Neil has Apple Developer account ($99/year) and Google Play developer account ($25 one-time)
- Production domain registered (kuwboo.com or preferred alternative)

#### Exit Criteria

- [ ] App live on App Store and Google Play
- [ ] No crash rate above 1%
- [ ] API response time under 500ms at p95
- [ ] Monitoring alerts configured and tested
- [ ] Rollback procedure documented and tested

---

### Phase 5: Growth (Ongoing, $2,000-$4,000/month)

**Goal:** Iterate based on real user data and scale the platform.

#### Monthly Deliverables

| Category | Examples | Monthly Cost |
|----------|----------|-------------|
| Analytics & insights | User retention tracking, funnel analysis, A/B testing | $500-$1,000 |
| Content moderation | Review queues, automated flagging, report handling | $500-$1,000 |
| Admin panel | Web dashboard for Neil to manage users, content, ads | $500-$1,000 |
| Feature iterations | Based on user feedback and analytics data | $500-$1,000 |

#### Potential Growth Features (prioritised by Neil when ready)

- Video duets/reactions
- In-app payments (Stripe) for marketplace
- Shipping integration for Buy & Sell
- Live streaming
- Creator monetisation programme
- Event-based Yoyo (activate at conferences/parties)
- Push notification campaigns
- Referral programme

---

## Part 4: Backend Architecture

### Technology Stack

| Layer | Technology | Version | Why |
|-------|------------|---------|-----|
| **Framework** | Fastify | 4.26 | 2x faster than Express, TypeScript-first, schema validation built-in |
| **Language** | TypeScript | 5.3 | Type safety, better tooling, fewer bugs |
| **ORM** | Prisma | 5.10 | Type-safe queries, migrations, schema visualisation |
| **Database** | PostgreSQL | 16 | PostGIS for Yoyo, JSONB for flexible metadata, industry standard |
| **Real-time** | Socket.io | 4.7 | Already proven in current app, handles chat + notifications |
| **Validation** | Zod | 3.22 | Runtime validation matching TypeScript types |
| **Auth** | @fastify/jwt | 8.0 | JWT access + refresh tokens, industry standard |
| **Media** | AWS S3 + MediaConvert | v3 SDK | Reuse existing video pipeline, presigned uploads |
| **Rate limiting** | @fastify/rate-limit | 9.1 | Protection against brute force and abuse |
| **Caching** | Redis (ioredis) | 5.3 | Session store, Socket.io adapter, feed caching |
| **Testing** | Vitest | 1.3 | Fast, TypeScript-native, Jest-compatible |
| **Logging** | Pino | 8.19 | Structured JSON logs, low overhead |

### API Surface

| Domain | Endpoints | Key Operations |
|--------|-----------|----------------|
| Auth | ~10 | Phone OTP, email login, Google/Apple SSO, JWT refresh, logout, device registration |
| Users | ~8 | Profile CRUD, preferences, avatar upload, followers/following, block/unblock |
| Content | ~8 | Create/read/update/delete, feed discovery (personalised, trending, following), search, hashtags |
| Marketplace | ~6 | Product CRUD, auction management, bidding, categories, location-based search |
| Yoyo | ~5 | Settings, activate/deactivate, nearby users (PostGIS query), connect, connections list |
| Messaging | ~6 | Threads, send/receive messages, read receipts, media messages, Socket.io events |
| Admin | ~5 | User management, content moderation, reports queue, analytics, ad management |
| **Total** | **~48** | |

### Real-Time Events (Socket.io)

| Event | Direction | Purpose |
|-------|-----------|---------|
| `message:new` | Server to client | New chat message |
| `message:read` | Bidirectional | Read receipts |
| `typing:start/stop` | Bidirectional | Typing indicators |
| `notification:new` | Server to client | Push notification fallback |
| `yoyo:nearby` | Server to client | Nearby user appeared/left |
| `match:new` | Server to client | New dating match |
| `bid:new` | Server to client | New bid on auction |

### Media Pipeline

```
Mobile App                   AWS                          Database
    |                         |                              |
    |-- presigned URL req --> S3 presigned URL generator     |
    |-- direct upload ------> S3 (kuwboo-dev-new)           |
    |                         |-- S3 event --> Lambda        |
    |                         |               |              |
    |                         |         MediaConvert         |
    |                         |               |              |
    |                         |   SNS --> Lambda --> UPDATE feeds.status
    |                         |                              |
    |<-- CDN URL ----------- CloudFront (kuwboo-dev)        |
```

**Reuse:** The existing Lambda functions, MediaConvert preset, S3 buckets, and CloudFront distributions continue to work. The new backend generates presigned upload URLs instead of handling file uploads directly.

---

## Part 5: Database Migration Strategy

### Approach: MySQL to PostgreSQL via pgloader + Custom Scripts

| Step | Tool | Purpose |
|------|------|---------|
| 1. Schema mapping | Manual + Prisma | Map 130+ MySQL tables to ~15 Prisma models |
| 2. Initial migration | pgloader | Bulk transfer data from MySQL to PostgreSQL |
| 3. Data transformation | TypeScript scripts | Reshape data to match unified content model |
| 4. Validation | Automated tests | Verify row counts, referential integrity, data accuracy |
| 5. Media URL mapping | Script | Map S3 keys from old paths to new content model |

### Schema Mapping Overview

| MySQL Domain (tables) | PostgreSQL Model | Transformation |
|----------------------|------------------|----------------|
| users, user_settings, user_images, user_devices (6+ tables) | User, UserPreferences, Device | Merge settings into user, extract devices |
| feeds, feed_comments, feed_likes, feed_shares (5+ tables) | Content (type: VIDEO), Comment, Interaction | Flatten to unified content with JSONB metadata |
| buy_sell_products, bids, buy_sell_categories (5+ tables) | Content (type: PRODUCT), Auction, Bid | Products become Content with shop metadata |
| social_stumbles, social_stumble_comments (5+ tables) | Content (type: POST), Comment, Interaction | Posts become Content with social metadata |
| threads, chats, chat_medias (3+ tables) | Thread, ThreadParticipant, Message | Restructure with explicit participants |
| user_followers, user_blocks, user_match_profiles (5+ tables) | Connection (various contexts) | Merge into unified connection model |
| categories (video, buy_sell, blog, etc.) | Content.metadata JSONB | Categories stored as metadata, not separate tables |

### Data Validation Approach

| Check | Method |
|-------|--------|
| Row count parity | Compare source and target counts per domain |
| Referential integrity | Verify all foreign keys resolve |
| Content completeness | Spot-check 100 random records per content type |
| Media availability | Verify S3 URLs still resolve after migration |
| Auth continuity | Verify existing users can log in with migrated credentials |

### Rollback Strategy

- MySQL database dump preserved as backup before migration
- PostgreSQL migration runs against a fresh database (non-destructive)
- Old Express/Sequelize backend remains running until new backend is verified
- DNS switch (not code deploy) controls which backend serves traffic
- Rollback = point DNS back to old backend (< 5 minute recovery)

---

## Part 6: Infrastructure Plan

### Current State vs Target

| Resource | Current | Target | Monthly Savings |
|----------|---------|--------|-----------------|
| Database | Aurora MySQL db.t3.medium ($72/mo) | RDS PostgreSQL db.t3.micro ($15/mo) | $57 |
| EC2 | t3.medium ($31/mo compute + $30/mo other) | t3.medium (same, or t3.small if sufficient) | $0-$15 |
| S3 | 3 buckets (~$1.40/mo) | Same (reuse existing) | $0 |
| CloudFront | 2 distributions (~$0) | Same (reuse existing) | $0 |
| Lambda | 2 functions (~$0) | Same (reuse existing) | $0 |
| Monitoring | None | CloudWatch alarms + SNS | +$2-5 |
| **Total** | **~$137/mo** | **~$80-100/mo** | **$37-57** |

### Infrastructure Details

| Component | Configuration |
|-----------|---------------|
| **Region** | eu-west-2 (London) -- same as current |
| **EC2** | t3.medium, Ubuntu, PM2 process manager |
| **Database** | RDS PostgreSQL 16, db.t3.micro, 7-day backup retention |
| **CI/CD** | GitHub Actions (backend deploy on push to main) |
| **Flutter CI** | Codemagic or Fastlane (build + TestFlight/Play upload) |
| **SSL** | Let's Encrypt (auto-renewal via certbot) |
| **Domain** | kuwboo.com (or Neil's preferred domain) |
| **Monitoring** | CloudWatch alarms for CPU >70%, memory >80%, 5xx errors >1%, API latency >500ms |

### Domain Strategy

| Domain | Points To | Purpose |
|--------|-----------|---------|
| `api.kuwboo.com` | EC2 (Nginx reverse proxy) | Backend API |
| `kuwboo.com` | S3/CloudFront or simple landing page | Marketing site (future) |
| `admin.kuwboo.com` | S3/CloudFront | Admin panel (future) |

**Prerequisite:** Neil registers `kuwboo.com` (or preferred domain) before Phase 4 launch.

---

## Part 7: Cost Summary

### By Category

| Category | Low Estimate | High Estimate | Notes |
|----------|-------------|---------------|-------|
| **Design (initial)** | $6,000 | $9,000 | ~48 screens, mid-level designer |
| **Design (future)** | $3,000 | $4,500 | ~16 screens (Dating, Yoyo, Ads) |
| **Flutter development** | $31,000 | $39,000 | All modules + testing |
| **Backend development** | $19,000 | $27,000 | API + real-time + admin |
| **Data migration** | $3,000 | $5,000 | MySQL to PostgreSQL + validation |
| **Infrastructure / DevOps** | $3,000 | $5,000 | CI/CD, monitoring, optimisation |
| **App Store launch** | $1,000 | $2,000 | Submissions, assets, monitoring |
| **Post-launch fixes** | $1,000 | $1,500 | First 2 weeks |
| **Subtotal** | $67,000 | $93,000 | |
| **Contingency (15%)** | $10,000 | $14,000 | Scope changes, unknowns |
| **Total** | **$77,000** | **$107,000** | |

### By Phase (Cash Flow View)

| Phase | Duration | Spend | Running Total |
|-------|----------|-------|---------------|
| Phase 1: Foundation | Weeks 1-6 | $12,000-$18,000 | $12K-$18K |
| Phase 2: Feature Parity | Weeks 7-22 | $50,000-$68,000 | $62K-$86K |
| Phase 3: New Features | Weeks 23-34 | $16,000-$24,000 | $78K-$110K |
| Phase 4: Launch | Weeks 35-38 | $3,000-$5,000 | $81K-$115K |
| Contingency (15%) | -- | $12,000-$17,000 | **$91K-$127K** |
| Phase 5: Growth | Ongoing | $2,000-$4,000/month | +monthly |

### What's NOT Included

- Apple Developer account ($99/year) -- Neil's responsibility
- Google Play developer account ($25 one-time) -- Neil's responsibility
- Domain registration (~$12-15/year) -- Neil's responsibility
- Ongoing AWS infrastructure (~$80-100/month) -- Neil's responsibility
- Third-party API costs (Twilio SMS, Google Maps) -- usage-based, currently minimal

---

## Part 8: Risk Items

### Top Risks Relevant to the Rebuild

| ID | Risk | Severity | Phase Addressed | Mitigation |
|----|------|----------|-----------------|------------|
| SEC-001 | SQL injection in Lambda function | Critical | Phase 1 | Parameterise queries |
| SEC-002 | Hardcoded test OTP bypasses auth | Critical | Phase 1 | Gate behind environment check |
| SEC-004 | JWT library CVEs (code execution, algorithm confusion) | Critical | Phase 1 | New backend uses @fastify/jwt (no legacy CVEs) |
| SEC-005 | All credentials known to previous developer (Codiant) | High | Phase 1 | Rotate all credentials |
| OPS-001 | No CI/CD pipeline (manual deploys) | High | Phase 1 | GitHub Actions + Codemagic |
| OPS-002 | No automated backups | High | Phase 1 | RDS snapshots + S3 lifecycle |
| OPS-005 | Single-AZ database (single point of failure) | Critical | Phase 4 | Evaluate Multi-AZ for production launch |
| NEW-001 | Data migration integrity -- records lost or corrupted during MySQL to PostgreSQL transfer | High | Phase 2 | Automated validation scripts, row count checks, rollback plan |
| NEW-002 | App Store rejection -- content policy, privacy requirements, or technical issues | Medium | Phase 4 | Pre-submission checklist, TestFlight beta testing, privacy manifests |
| NEW-003 | Scope creep -- Neil requests features not in this plan during development | Medium | All phases | This document is the scope baseline; changes evaluated as change requests with cost/time impact |

### Risk Reduction Through Rebuild

The rebuild eliminates several existing risks entirely:

| Risk | Status After Rebuild |
|------|---------------------|
| SEC-003 (iOS NSAllowsArbitraryLoads) | Eliminated -- Flutter app uses secure defaults |
| TEC-001 (Outdated GoogleSignIn SDK) | Eliminated -- Flutter uses google_sign_in 6.2.1 |
| TEC-003 (Zero test coverage) | Mitigated -- Vitest for backend, flutter_test for mobile |
| TEC-004 (Sequelize 5.x EOL) | Eliminated -- Prisma 5.10 replaces Sequelize |
| TEC-005 (Massive 1,900-line view controllers) | Eliminated -- Flutter widget architecture enforces smaller files |
| BUS-003 (Deprecated social auth packages) | Eliminated -- Modern Flutter + Fastify auth packages |

---

## Part 9: Pre-Launch Checklist

### Technical Readiness

- [ ] All 6 priority features functional (Video, Shop, Social, Dating, Yoyo, Sponsored Links)
- [ ] API response time under 500ms at p95
- [ ] No crash rate above 1% on TestFlight
- [ ] Push notifications delivering on iOS and Android
- [ ] Real-time chat working (Socket.io)
- [ ] Media uploads and video processing working
- [ ] All existing user data migrated and validated

### Security

- [ ] All credentials rotated (database, AWS, JWT, Twilio, SMTP)
- [ ] Rate limiting active on all public endpoints
- [ ] JWT refresh token rotation implemented
- [ ] CORS restricted to known origins
- [ ] Input validation on all API endpoints (Zod schemas)
- [ ] Content moderation pipeline active (report flow working)

### App Store Requirements

- [ ] App Store screenshots (6.7" and 6.1" iPhone)
- [ ] App preview video (optional but recommended)
- [ ] App description and keywords
- [ ] Age rating questionnaire completed
- [ ] Privacy policy URL (hosted on kuwboo.com)
- [ ] Privacy nutrition labels accurate
- [ ] iOS privacy manifests included for all required APIs

### Google Play Requirements

- [ ] Store listing (title, description, graphics)
- [ ] Content rating questionnaire completed
- [ ] Data safety section completed
- [ ] Target audience and content declarations
- [ ] 20 testers for closed testing track (14-day requirement)

### Infrastructure

- [ ] Production domain configured (kuwboo.com)
- [ ] SSL certificates provisioned and auto-renewing
- [ ] CloudWatch alarms configured and tested
- [ ] Database backups verified (can restore)
- [ ] Rollback procedure documented and tested
- [ ] Monitoring dashboard accessible to Neil

### Legal

- [ ] Terms of Service written and hosted
- [ ] Privacy Policy written and hosted (GDPR-compliant for UK users)
- [ ] Cookie policy (if web admin panel)
- [ ] Data deletion mechanism working (GDPR right to erasure)
- [ ] Age verification for Dating module (18+ requirement)

---

## Part 10: Summary for Neil

**What are we building?** A completely new Kuwboo app from scratch, using Flutter (one codebase for both iPhone and Android) with a modern backend server. This replaces your current iOS app and the outdated backend that Codiant built. Everything your users can do today (videos, marketplace, social) will work in the new app, plus three new features: Dating, Yoyo nearby discovery, and Sponsored Links.

**How much will it cost?** The full rebuild from design through to App Store launch is estimated at $91,000 to $127,000, spread across four phases over roughly 8-9 months. After launch, ongoing maintenance and new features run $2,000 to $4,000 per month. The first phase (design + infrastructure, $12-18K) gets the professional screen designs done and cuts your monthly server costs by about 40%.

**What's the timeline?** Phase 1 (foundation and design) takes 4-6 weeks. Phase 2 (building the core app) takes 12-16 weeks. Phase 3 (adding Dating, Yoyo, and Sponsored Links) takes 8-12 weeks. Phase 4 (App Store launch) takes 3-4 weeks. Total: roughly 27-38 weeks from starting to having the app live on the App Store.

**Why rebuild instead of fix?** Your current iOS app has 124,000 lines of Swift code with zero tests, outdated libraries, and security vulnerabilities. The Android app is 65% incomplete. Maintaining two separate native apps costs roughly $3,000/month. The Flutter rebuild gives you one codebase for both platforms, modern architecture, and a 2-year total cost of $76,000 compared to $128,000 for patching the native apps. That's $52,000 saved over two years while getting a better product.

**What do you need to do?** Approve the design budget ($6-9K) so we can commission the designer. Provide any brand preferences (logo, colours, fonts). Be available for a 30-minute weekly check-in during development. Register the kuwboo.com domain before launch. Keep your Apple Developer ($99/year) and Google Play ($25 one-time) accounts active.
