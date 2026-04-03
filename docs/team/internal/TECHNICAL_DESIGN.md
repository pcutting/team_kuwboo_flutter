# Kuwboo: Technical Design Document

**Created:** February 17, 2026
**Version:** 1.0
**Purpose:** Developer-facing technical companion to FEATURE_ARCHITECTURE.md
**Audience:** Phil Cutting (LionPro Dev) — implementation guide

**Companion Documents:**
- [../FEATURE_ARCHITECTURE.md](../FEATURE_ARCHITECTURE.md) — client-facing feature overview for Neil
- [REGULATORY_REQUIREMENTS.md](./REGULATORY_REQUIREMENTS.md) — UK + USA regulatory compliance architecture (OSA, GDPR, COPPA, CCPA, BIPA, DMCA)

---

## How to Read This Document

This is the engineering document that FEATURE_ARCHITECTURE.md intentionally leaves out. It covers:

- **Why** each technology was chosen (with honest trade-offs)
- **What's wrong** with the current schema (with severity and evidence)
- **How** the revised schema solves those problems (with TypeORM entity syntax)
- **Where** every client-facing promise maps to a database column
- **What's missing** that neither document addresses yet
- **Where regulatory obligations apply** — inline callouts (📋) link to [REGULATORY_REQUIREMENTS.md](./REGULATORY_REQUIREMENTS.md) for the full legal context

Sections are numbered 0-6. Section 0 is the stack evaluation (ORM, API layer, AWS services). Sections 1-6 are the schema and architecture work. Regulatory callouts appear throughout — look for the 📋 marker.

---

## Table of Contents

- [Section 0a: ORM Evaluation](#section-0a-orm-evaluation)
- [Section 0b: API Layer Evaluation](#section-0b-api-layer-evaluation)
- [Section 0c: AWS Services Assessment](#section-0c-aws-services-assessment)
- [Section 0d: Complete Stack Summary](#section-0d-complete-stack-summary)
- [Section 1: Architecture Critique](#section-1-architecture-critique)
- [Section 2: Recommended Schema](#section-2-recommended-schema)
- [Section 3: Document-to-Schema Reconciliation](#section-3-document-to-schema-reconciliation)
- [Section 4: Feed Architecture](#section-4-feed-architecture)
- [Section 5: State Machines](#section-5-state-machines)
- [Section 6: Missing Infrastructure](#section-6-missing-infrastructure)

---

## Section 0a: ORM Evaluation

### The Question

Is Prisma the right ORM for a platform that needs Class Table Inheritance, complex JSONB queries, PostGIS geography, audit logging via subscribers, financial transaction integrity for auctions, and eventual analytics event streams?

### Current Investment in Prisma

Scaffolding-level. A 599-line schema, 5 route files (~430 lines of business logic), one Fastify plugin. Estimated 2-3 days of work to reproduce. Switching cost is low now and exponentially expensive later.

Current dependencies (`kuwboo-rebuild/backend/package.json`):
- `@prisma/client: ^5.10.2`
- `prisma: ^5.10.2` (devDependency)

### Evaluation Against Kuwboo's Requirements

| Requirement | Prisma | TypeORM | Drizzle |
|-------------|--------|---------|---------|
| **Class Table Inheritance (CTI)** | Not supported natively. Must model as manual 1:1 optional relations. No `@TableInheritance()` concept. | First-class. `@TableInheritance()` + `@ChildEntity()` decorators. This is the strongest reason to switch. | Not supported. Manual 1:1 like Prisma. |
| **Complex WHERE on typed columns** | Works if columns are first-class. Fails when data is in `metadata Json` — requires `$queryRaw` for JSONB path queries. Prisma Client can't express `WHERE (metadata->>'priceCents')::int < 5000`. | QueryBuilder handles arbitrary WHERE, JOIN, subqueries. Can mix typed columns and raw fragments. | SQL-shaped TypeScript — expressive, handles complex queries well. |
| **PostGIS geography** | `Unsupported("geography(Point, 4326)")` — can't be queried via Prisma Client. Every proximity query is raw SQL. See `schema.prisma` line 43 — `lastLocation` is already `Unsupported`. | `@Column({ type: 'geography', spatialFeatureType: 'Point', srid: 4326 })` — first-class spatial type with query support. | Supported via custom types + raw SQL helpers. Less ergonomic than TypeORM. |
| **Entity subscribers / audit logging** | Middleware (limited). Can intercept queries but no entity lifecycle hooks. No `@AfterInsert`, `@AfterUpdate`. | Entity subscribers — `@EventSubscriber()` with `afterInsert`, `afterUpdate`, `afterRemove`. Automatic audit trail without per-query boilerplate. | None built-in. Must implement manually. |
| **Composable query builder** | Limited. Chained `where` is AND-only. No OR composition without `$queryRaw`. | QueryBuilder — `.where()`, `.andWhere()`, `.orWhere()`, `.leftJoin()`, `.subQuery()`. Fully composable. | SQL-shaped builder. Good composability, different paradigm. |
| **Transaction support** | `$transaction([...])` — sequential. `$transaction(async (tx) => {...})` — interactive. Works but verbose. | `EntityManager.transaction()` — idiomatic. `QueryRunner` for manual control. | `db.transaction()` — clean, modern API. |
| **Migration flexibility** | Opaque. Can't add expression indexes, partial indexes, triggers, or views in Prisma schema. Requires separate SQL migration files that Prisma doesn't track. | Generates SQL files you can edit. Expression indexes, triggers, views all addable. Full control. | Generates editable SQL files. Good flexibility. |
| **Repository pattern** | No repository concept. All queries through global `prisma.model.method()`. Business logic scatters into route handlers (visible in `routes.ts`). | Custom repositories — encapsulate business queries (e.g., `ContentRepository.findForFeed()`, `BlockRepository.isBlocked()`). | No built-in repository. Functional query style. |
| **View entities** | Not supported. | `@ViewEntity()` — define database views as queryable entities. Useful for pre-computed feed queries like trending content. | Not built-in, but can query views via raw SQL. |
| **Type safety** | Strongest. Generated client with full type inference from schema. This is Prisma's best feature. | Weaker. QueryBuilder returns `any` for complex queries. Decorator-based types work for simple cases. Better with strict mode + `Relation<>` types. | Strong. SQL-shaped TypeScript infers types from schema. Comparable to Prisma for simple queries. |
| **Maturity / ecosystem** | Very mature. Large community. Good docs. | Mature but has had maintenance gaps. Active again. Largest TypeScript ORM by adoption. | Young (2023+). Growing fast. Less battle-tested at scale. |

### Evidence from the Current Codebase

**PostGIS is already fighting Prisma.** Line 43 of `schema.prisma`:

```prisma
lastLocation Unsupported("geography(Point, 4326)")? @map("last_location")
```

Every proximity query for YoYo will require `$queryRaw` — no type safety, no composability, no relation loading. YoYo is a core feature, not a nice-to-have.

**Metadata JSON is already causing problems.** The content routes (`routes.ts` line 28-44) define rich Zod schemas for product metadata (price, condition, category, images, auction config) — but all of it gets stuffed into a single `metadata Json` column. Querying "products under £50 in Electronics" requires:

```sql
-- What you'd need (impossible in Prisma Client):
WHERE type = 'PRODUCT'
  AND (metadata->>'priceCents')::int < 5000
  AND (metadata->>'categoryId') = 'electronics'
```

With TypeORM CTI, these become typed columns on a `Product` child entity — queryable, indexable, type-safe.

**The old codebase shows why typed columns matter.** `BuySellProduct.js` has 5 Sequelize scopes with raw SQL literals (`highestBid`, `yourLatestBid`, `highestBidList`, `highestAndYourLatestBid`, `winnerDetails`) — all querying typed columns on a real table. The rebuild's Prisma schema collapsed these into JSON, losing queryability.

### Recommendation: TypeORM with Data Mapper Pattern

**Reasons:**

1. **CTI is the deciding factor.** The entire schema redesign (Section 2) hinges on Class Table Inheritance. Prisma can't express it. TypeORM has it built in. This alone justifies the switch.

2. **PostGIS as a first-class type.** YoYo proximity queries need `ST_DWithin`, `ST_Distance`, `ST_MakePoint`. Fighting `Unsupported()` on every query is engineering friction that compounds over the project's lifetime.

3. **Entity subscribers for audit logging.** Follower tracking, financial transactions (auctions), marketing analytics, GDPR compliance — all need audit trails. TypeORM's subscriber system delivers this with zero per-query boilerplate.

4. **Custom repositories.** A `FeedRepository` that always applies block filtering. A `ContentRepository` with the ranking algorithm baked in. A `AuctionRepository` with bid validation and financial integrity checks. This is where business logic lives cleanly in NestJS's DI container.

5. **Phil has TypeORM experience.** Reduced risk, faster ramp-up, fewer surprises during development.

### What Prisma Does Better (Honest Trade-offs)

| Prisma Advantage | Impact | Mitigation |
|-----------------|--------|------------|
| Type inference on simple queries is genuinely better | TypeORM's QueryBuilder loses types on complex queries | Strict TypeORM config + well-typed repository return types + `SelectQueryBuilder<T>` generics |
| Prisma Studio is a nice local DB browser | Loses a convenient dev tool | pgAdmin, DBeaver, or any PostgreSQL GUI |
| Migration workflow is simpler for the common case | More migration management overhead | TypeORM migrations are SQL files — more work but more power. Expression indexes and triggers are addable. |
| Community momentum — more StackOverflow answers | Slightly harder to find solutions | TypeORM has been around longer. NestJS docs use TypeORM as the primary example. |

### Discipline Required with TypeORM

These are non-negotiable conventions for the Kuwboo project:

1. **Data Mapper pattern exclusively.** Never Active Record. Active Record leads to fat entities with business logic embedded in model classes, making them untestable and tightly coupled. Data Mapper keeps entities as plain data objects and puts query logic in repositories.

2. **Strict TypeScript mode.** TypeORM's decorators can be loose without it. Enable `strict: true`, `strictPropertyInitialization: true` in `tsconfig.json`.

3. **Explicit return types on all repository methods.** Don't rely on TypeORM's inferred types for complex queries. Define interfaces for query results.

4. **No `getRepository()` calls in controllers.** All data access goes through NestJS-injected custom repositories. Controllers call services, services call repositories.

### What About Drizzle?

Drizzle is the modern alternative with better type safety than TypeORM. But it lacks CTI, subscribers, and repositories — the three things this project needs most. If Kuwboo were a simpler CRUD app with fewer content types, Drizzle would be the pick. For this complexity profile, TypeORM is the better tool.

---

## Section 0b: API Layer Evaluation

### The Question

Is GraphQL the right API layer for a platform with polymorphic content feeds, real-time subscriptions (chat, auctions, proximity), a Flutter mobile client, video uploads, and 4 modules sharing cross-cutting entities?

### GraphQL — Honest Critique for Kuwboo's Case

| Dimension | Verdict | Detail |
|-----------|---------|--------|
| **Polymorphic feeds** | Genuine strength | `union FeedItem = Video \| Product \| Post \| Event` with inline fragments. The client declares exactly which fields per subtype. This is GraphQL's best use case — better than REST discriminated unions. |
| **Real-time subscriptions** | Functional but heavyweight | Subscriptions work for auction bids (low-frequency, typed payloads). But for chat, GraphQL adds unnecessary resolver chain overhead vs a raw WebSocket. For YoYo proximity (high-frequency coordinate exchange), it adds serialisation cost for what is essentially a coordinate broadcast. You'll end up with a separate WebSocket layer anyway. |
| **Flutter codegen** | Immature vs REST | Three Dart codegen options (`graphql_codegen`, `Artemis`, `Ferry`) — all functional but smaller communities, fewer edge case solutions, less battle-testing than `openapi_generator` for Dart, which generates Freezed models + Retrofit clients from an OpenAPI spec. REST codegen for Flutter is measurably more mature. |
| **N+1 problem** | Real, solvable, ongoing tax | Feed of 20 items with nested creator data = 41+ queries without DataLoader. NestJS has DataLoader integration, but it's boilerplate you write and maintain for every nested relationship. With REST, you control exactly which JOINs happen per endpoint. |
| **HTTP caching** | Significant disadvantage | REST: each URL maps to a cacheable response. CloudFront works out of the box. GraphQL: all queries are POST to a single endpoint — URL-based CDN caching doesn't work. Automatic Persisted Queries (APQ) are a workaround but require client-side support and infrastructure. For a mobile app hitting CloudFront, REST caching is essentially free. |
| **File uploads** | GraphQL is the wrong tool | Apollo's own docs recommend REST for file uploads. Multipart GraphQL bypasses CSRF protections. Industry pattern: presigned S3 URLs (REST) for upload, then pass S3 key to a mutation. You're running hybrid REST+GraphQL regardless. |
| **Over/under-fetching** | Marginal benefit here | This matters most when multiple client teams consume the API. Kuwboo has one Flutter client — you can design BFF (Backend for Frontend) REST endpoints that return exactly what each screen needs. GraphQL flexibility solves a problem you can engineer around. |
| **Schema evolution** | Genuine strength | Additive fields, `@deprecated` directives, no URL versioning. Smoother than REST versioning over the app's lifecycle. But this is a future benefit, not an immediate one. |
| **Complexity attacks** | Real attack surface REST doesn't have | Without depth limiting and cost analysis, deeply nested queries can DoS the server. Mitigations exist (query depth limiting, complexity scoring, persisted queries) but are additional infrastructure to configure and maintain. |
| **AppSync (managed GraphQL)** | Not viable for Kuwboo | 30-second timeout, 1MB response limit, limited federation, vendor lock-in. Self-host with Mercurius or Apollo if GraphQL is chosen. |

### 2026 Alternatives Evaluated

| Alternative | Fit for Kuwboo | Why / Why Not |
|-------------|----------------|---------------|
| **REST + OpenAPI 3.1** | **Strong (recommended)** | Best Flutter codegen story (`openapi_generator` → Freezed + Retrofit). Trivial CDN caching via CloudFront. Every developer knows it. No complexity attack surface. NestJS `@nestjs/swagger` generates specs from decorators automatically. |
| **tRPC** | Not viable | Type safety requires TypeScript on both ends. Flutter is Dart. The Dart client package exists but requires a TypeScript extractor tool — defeats the zero-codegen value proposition. |
| **gRPC** | Technically strong, operationally complex | ~7x faster than REST (protobuf + HTTP/2). Native streaming. Dart client is Google-maintained. But: no browser support without Envoy proxy, binary protocol is harder to debug, smaller NestJS ecosystem. Consider for internal service-to-service if Kuwboo ever splits to microservices. |
| **JSON:API** | Underrated middle ground | Solves under-fetching with `?include=creator,bids.bidder`, over-fetching with `?fields[product]=id,title,price`. Standard HTTP caching works. But: Flutter codegen support is minimal, response format is verbose. |
| **Hybrid REST + GraphQL** | Viable, adds cognitive overhead | REST for CRUD + uploads, GraphQL for complex feed queries. You end up here anyway if you choose GraphQL (file uploads must be REST). Works well for larger teams (5+), adds friction for a 1-3 person team. |
| **REST + SSE** | Strong contender for real-time | SSE for server-push (notifications, bid updates). Works through proxies, firewalls, load balancers without config. Automatic reconnection. Standard HTTP so CloudFront works. Only gap: chat needs bidirectional (WebSocket). |
| **WebTransport** | Watch, don't build on | HTTP/3 + QUIC. Multiple independent streams. Being standardised (IETF). But Dart/Flutter support is not mature. Not ready for production. |

### Recommendation: REST + OpenAPI 3.1 with Layered Real-Time

**Primary API:** REST + OpenAPI 3.1 spec generated from NestJS decorators.

**Real-time layer (3 transports for 3 use cases):**

| Use Case | Transport | Why This Transport |
|----------|-----------|-------------------|
| Notifications, auction bid updates, feed refresh signals | **SSE (Server-Sent Events)** | Unidirectional server-push. Works through standard HTTP infrastructure. Auto-reconnect built into the browser/client spec. NestJS has `@Sse()` decorator. |
| Chat messages, typing indicators, online presence | **Socket.io** | Bidirectional. Room-based for conversations. Automatic reconnection with backoff. NestJS has `@nestjs/platform-socket.io` with gateway decorators. |
| YoYo proximity coordinate exchange | **WebSocket (raw)** | High-frequency bidirectional. Lower overhead than Socket.io for coordinate broadcasts that don't need rooms or acknowledgements. Binary frames for compact lat/lng payloads. |

### Why Not GraphQL

1. **Flutter codegen maturity.** REST codegen for Dart is measurably more mature. This affects daily development velocity for the entire project lifecycle.
2. **Caching.** CloudFront CDN caching with REST is free. GraphQL requires APQ infrastructure.
3. **File uploads.** You need REST endpoints anyway for presigned S3 URLs. Hybrid adds complexity for a small team.
4. **Complexity attacks.** An attack surface that REST simply doesn't have. More infrastructure to configure and monitor.
5. **N+1 maintenance tax.** DataLoader boilerplate for every nested relationship, ongoing.

### Where GraphQL Would Have Been the Right Call

- If Kuwboo had 3+ client platforms (web, iOS native, Android native) with separate teams needing different data shapes
- If the API served third-party consumers who need flexible queries
- If the polymorphic feed was the only consideration (it's GraphQL's genuine strength)
- If the team had 5+ backend developers where the self-documenting schema reduces coordination cost

### What Phil Loses by Choosing REST

Polymorphic feed queries are less elegant — discriminated union JSON with a `type` field vs GraphQL fragments. Schema evolution requires a versioning strategy (URL-based or header-based) instead of additive-only. These are manageable trade-offs with proven solutions that the industry has been using for 15+ years.

---

## Section 0c: AWS Services Assessment

### Principle

Use AWS-managed services when the managed version eliminates meaningful operational complexity. Self-build when the managed version is overpriced, too opaque, or doesn't fit the use case.

| Service | Recommendation | Reasoning |
|---------|---------------|-----------|
| **SNS Mobile Push** | **Use managed** | Handles APNs/FCM token management, retry logic, platform differences, token rotation, silent push failures, badge count sync. Building custom push infrastructure is deceptively complex. Cost: ~£0.40/million publishes — essentially free at startup scale. |
| **EventBridge** | **Use managed** | Cross-module event routing. When a bid is placed (marketplace), the notification module, chat module, and analytics all care. EventBridge's content-based filtering maps naturally to the `moduleKey` architecture. Better than SNS for events with meaningful payloads that need routing rules. Pair with SQS for guaranteed processing. |
| **Cognito** | **Do NOT use — custom auth** | Opaque errors, limited customisation (Lambda triggers at every lifecycle point), MFA constraints, $2,500/million for M2M auth. Kuwboo already has custom JWT + Twilio OTP. NestJS: `@nestjs/passport` + `passport-jwt` + `@nestjs/jwt`. Social login via passport strategies (`passport-google-oauth20`, `passport-apple`). Full control over token structure and refresh rotation. |
| **S3 + CloudFront** | **Use managed** | Presigned URLs for direct client-to-S3 upload (bypasses the server entirely). CloudFront for global edge caching of media. Gotchas: multipart upload for files >100MB, lifecycle policies for incomplete uploads, Transfer Acceleration for users outside eu-west-2. Trigger Lambda on upload for thumbnail generation + video transcoding via MediaConvert. **Regulatory constraint:** S3 bucket must be in `eu-west-2` for UK GDPR data residency — see [REGULATORY_REQUIREMENTS.md §2.3.1](./REGULATORY_REQUIREMENTS.md#231-data-residency-for-s3cloudfront). The upload Lambda trigger is also the integration point for OSA proactive content scanning — see [REGULATORY_REQUIREMENTS.md §2.1.1](./REGULATORY_REQUIREMENTS.md#211-illegal-content-duty--proactive-scanning). |
| **ElastiCache / Redis** | **Self-managed Redis initially** | Redis on EC2 for session store, feed caching, rate limiting, presence tracking (YoYo online status). ElastiCache minimum is ~£40/mo vs ~£12-25/mo self-managed. Move to ElastiCache when concurrent connections or memory exceeds EC2's capacity. **Note:** Redis 8.0 changed to AGPLv3. AWS ElastiCache only supports Redis ≤7.2, transitioning to Valkey (Linux Foundation fork). Use Redis 7.2 or evaluate Valkey. |
| **SES** | **Use managed for transactional email** | £0.08/1,000 emails vs SendGrid's £16/mo for 50K. 10-20x cheaper for transactional email (password resets, verification codes, bid notifications, auction ending alerts). Add SendGrid only if marketing email with engagement analytics is needed later. |
| **RDS PostgreSQL** | **Use managed (confirmed)** | Already decided. eu-west-2. PostGIS extension for YoYo proximity queries via `CREATE EXTENSION postgis`. Managed backups, failover, patching. |

### Services NOT to Use

| Service | Why Not |
|---------|---------|
| **AppSync** | 30s timeout, 1MB response limit, limited flexibility. Kuwboo needs custom resolvers, not managed GraphQL. |
| **Cognito** | See above. Custom JWT gives full control at lower complexity for this use case. |
| **DynamoDB** | Relational data model with JOINs (content → creator → blocks → preferences). DynamoDB's single-table design adds complexity without benefit here. PostgreSQL handles the query patterns better. |
| **Amplify** | Opinionated framework that constrains architecture. Kuwboo needs NestJS's modularity, not Amplify's conventions. |

---

## Section 0d: Complete Stack Summary

| Layer | Choice | Key Reasoning |
|-------|--------|---------------|
| **Framework** | NestJS | Modular architecture maps to Kuwboo's 4 modules. First-class TypeORM integration via `@nestjs/typeorm`. Decorator-based routing matches the OpenAPI generation strategy. |
| **ORM** | TypeORM (Data Mapper) | CTI for content hierarchy. PostGIS first-class. Entity subscribers for audit. Custom repositories via NestJS DI. |
| **Database** | PostgreSQL 16 (RDS) | PostGIS, JSONB for flexible metadata, `tsvector` for full-text search, expression indexes, `pg_trgm` for fuzzy matching. |
| **Primary API** | REST + OpenAPI 3.1 | Best Flutter codegen (`openapi_generator` → Freezed + Retrofit). CDN caching via CloudFront. `@nestjs/swagger` generates spec from decorators. |
| **Real-time: Notifications/Bids** | SSE (Server-Sent Events) | Unidirectional server-push. Works through standard HTTP infra. Auto-reconnect. NestJS `@Sse()` decorator. |
| **Real-time: Chat/Presence** | Socket.io | Bidirectional. Room-based for conversations. NestJS `@nestjs/platform-socket.io` with `@WebSocketGateway()`. |
| **Real-time: Proximity** | WebSocket (raw) | High-frequency coordinate exchange. Lower overhead than Socket.io for this specific use case. Binary frames for lat/lng. |
| **Push Notifications** | SNS Mobile Push | Managed APNs/FCM. Token lifecycle handled. |
| **Event Bus** | EventBridge + SQS | Content-based routing by moduleKey. Guaranteed delivery via SQS dead-letter queues. |
| **Auth** | Custom JWT + Passport.js | Full control over token structure. Twilio OTP. Social login via passport strategies. Refresh token rotation. |
| **Media Storage** | S3 + CloudFront | Presigned upload URLs. CDN delivery. Lambda triggers for processing. |
| **Video Transcoding** | MediaConvert | AWS-managed. HLS output for adaptive bitrate. Thumbnail extraction. |
| **Cache/Sessions** | Redis 7.2 (self-managed → ElastiCache) | Session store, feed cache, rate limiting, presence, pub/sub for Socket.io scaling. |
| **Email** | SES | Transactional email at £0.08/1K. |
| **Search** | PostgreSQL `tsvector` + `pg_trgm` | Built-in full-text search. No ElasticSearch needed at launch scale. Migrate if search becomes a bottleneck. |
| **Flutter Codegen** | `openapi_generator` | Freezed models + Retrofit clients from OpenAPI spec. Mature Dart ecosystem. |

### NestJS Module Structure

```
src/
├── modules/
│   ├── auth/           # JWT, OTP, social login, guards
│   ├── users/          # Profiles, preferences, settings
│   ├── content/        # Base content CRUD, CTI entities
│   │   ├── video/      # Video-specific logic
│   │   ├── product/    # Product + auction logic
│   │   ├── post/       # Post subtypes (blog, notice, etc.)
│   │   └── event/      # Event-specific logic
│   ├── feed/           # Feed assembly, ranking, caching
│   ├── connections/    # Follow, friend, match, block
│   ├── messaging/      # Chat, threads, Socket.io gateway
│   ├── dating/         # Profiles, swipe, matching
│   ├── yoyo/           # Proximity, WebSocket gateway
│   ├── media/          # S3 presigned URLs, processing status
│   ├── notifications/  # SNS push, in-app notifications, SSE
│   ├── moderation/     # Reports, review queue, actions
│   └── admin/          # Admin panel endpoints
├── shared/
│   ├── entities/       # Base entities, audit subscriber
│   ├── guards/         # Auth, roles, rate limiting
│   ├── interceptors/   # Logging, transform, cache
│   ├── pipes/          # Validation, sanitisation
│   └── database/       # TypeORM config, migrations
└── main.ts
```

---

## Section 1: Architecture Critique

### What's Wrong with the Current Schema

The Prisma schema (`kuwboo-rebuild/backend/prisma/schema.prisma`, 599 lines) was a reasonable first attempt at unifying 130 tables into a coherent model. But the deep review found **14 issues** — 6 critical, 4 high, 4 medium — that would cause significant problems in production.

### Critical Issues

#### Issue 1: `metadata Json` on Content Is Unqueryable

**Severity:** Critical
**Lines:** schema.prisma L239
**Evidence:** The `Content` model stores all type-specific data in a single `metadata Json` column. Product price, video duration, dating profile age, post text, event dates — everything goes into one untyped JSON blob.

**What breaks:**
- "Products under £50" → requires `$queryRaw` with JSONB path casting
- "Auctions ending in 24 hours" → `metadata->>'endTime'` can't use an index
- "Dating profiles aged 25-35 within 10km" → requires raw SQL combining JSON extraction with PostGIS `ST_DWithin`
- Feed ranking by content-type-specific signals (price, duration, age) → all raw SQL

**Evidence from old codebase:** `BuySellProduct.js` has 5 Sequelize scopes with complex WHERE clauses on typed columns (`price`, `bidStatus`, `startTime`, `endTime`, `minimumBidAmount`). The rebuild's schema collapsed these into JSON.

**Fix:** TypeORM Class Table Inheritance. Each content type gets its own table with typed, indexed columns. The base `Content` entity holds shared fields.

**Fixed by ORM switch?** Yes — CTI eliminates this entirely.

---

#### Issue 2: Interaction Unique Constraint Breaks VIEW, BID, SHARE

**Severity:** Critical
**Lines:** schema.prisma L311
**Evidence:** `@@unique([userId, contentId, type])` on the `Interaction` model means a user can only have ONE interaction of each type per content item.

**What breaks:**
- **VIEWs:** A user can only view content once. Re-views aren't tracked. View count analytics become meaningless — you can count unique viewers but not engagement depth.
- **BIDs:** A user can only place ONE bid on an auction. The entire auction system is broken. The old system (`bids` table in `BuySellProduct.js`) correctly allows multiple bids per user.
- **SHAREs:** A user can share content to exactly one platform, once. No tracking of "shared to WhatsApp AND Instagram."
- **SWIPE_LEFT/SWIPE_RIGHT:** Can never re-evaluate a dating profile (no "undo swipe" feature).

**Fix:** Split interactions into two models:

| Model | Constraint | Purpose | Types |
|-------|-----------|---------|-------|
| `InteractionState` | `@@unique([userId, contentId, type])` | Idempotent toggles | LIKE, SAVE |
| `InteractionEvent` | `@@index([userId, contentId, type, createdAt])` — no unique | Append-only log | VIEW, SHARE, BID, SWIPE_RIGHT, SWIPE_LEFT, SUPER_LIKE, SPARK |

**Fixed by ORM switch?** No — this is a schema design issue that requires splitting the model regardless of ORM.

---

#### Issue 3: No Media Model

**Severity:** Critical
**Evidence:** Videos, images, and thumbnails are tracked as raw URL strings inside `metadata Json` or `avatarUrl`. There is no first-class entity for uploaded media.

**What this prevents:**
- Upload status tracking (uploading → processing → ready → failed)
- Orphan cleanup (abandoned uploads consuming S3 storage)
- Storage quota enforcement per user
- Media reuse across content types (same image in a post and a product listing)
- Thumbnail generation status
- Video transcoding status (MediaConvert callback updates)
- GDPR deletion (can't enumerate a user's media without scanning every content item's JSON)

**Fix:** Create a `Media` entity with `id`, `userId`, `type` (IMAGE/VIDEO/AUDIO), `url`, `thumbnailUrl`, `status` (UPLOADING/PROCESSING/READY/FAILED), `mimeType`, `sizeBytes`, `width`, `height`, `durationSeconds`, `s3Key`, `createdAt`.

**Fixed by ORM switch?** No — this is a missing model.

---

#### Issue 4: No Category/Tag Model

**Severity:** Critical
**Evidence:** The old app had 27 video categories, 54 marketplace categories (hierarchical), and 30 blog categories — all with separate tables (`video_categories`, `buy_sell_categories`, `blog_categories`). The new schema has `categoryId` referenced in the Zod validation (`routes.ts` L36) but no `Category` model in Prisma. `categoryId` is a string pointing to nothing.

**What breaks:**
- Category browsing in the Shop tab (54 categories with parent-child hierarchy)
- Video feed filtering by category (27 categories)
- Category-specific feed ranking
- Admin category management
- Neil's existing category data has no destination

**Fix:** Create `Category` entity with `id`, `name`, `slug`, `parentId` (self-referencing for hierarchy), `scope` enum (VIDEO/PRODUCT/POST), `iconUrl`, `sortOrder`, `isActive`. Create `Tag` + `ContentTag` for free-form tagging (many-to-many).

**Fixed by ORM switch?** No — missing model.

---

#### Issue 5: Report Model Has Polymorphic FK Bug

**Severity:** Critical
**Lines:** schema.prisma L481-499
**Evidence:** The `Report` model has `targetId String` which is simultaneously a foreign key to BOTH `users` AND `content`:

```prisma
reportedUser User?    @relation("Reported", fields: [targetId], references: [id])
content      Content? @relation(fields: [targetId], references: [id])
```

A single `targetId` column has two FK constraints pointing to different tables. This will fail at migration time (conflicting constraints) or at runtime (FK validation against the wrong table).

Additionally, `ReportTarget` enum includes `MESSAGE` and `COMMENT` but there are no FK relations for those — `targetId` would be an orphaned string with no referential integrity.

**Fix:** Use separate nullable FK columns:

```
reportedUserId    String?  → User
reportedContentId String?  → Content
reportedMessageId String?  → Message
reportedCommentId String?  → Comment
```

With a check constraint ensuring exactly one is non-null.

**Fixed by ORM switch?** Partially — TypeORM handles polymorphic relations more cleanly with separate columns, but the schema design still needs correcting.

---

#### Issue 6: BLOCK in Connection Table

**Severity:** Critical
**Lines:** schema.prisma L379
**Evidence:** `BLOCK` is a `ConnectionContext` enum value alongside `FOLLOW`, `FRIEND`, `MATCH`, and `YOYO`. Blocks are stored in the same table as social connections.

**Why this is wrong:**
- **Blocks are cross-cutting access control**, not social connections. Every feed query, every comment display, every chat lookup, every search result must check "is this user blocked?" Scanning a table that also contains millions of follows/friends/matches to find blocks is a hot-path performance problem.
- **Block checks need both directions.** If A blocks B, then B's content is hidden from A AND A's content is hidden from B. The `Connection` model is directional (`fromUserId`, `toUserId`), so checking requires `WHERE (fromUserId = A AND toUserId = B AND context = 'BLOCK') OR (fromUserId = B AND toUserId = A AND context = 'BLOCK')`.
- **Block lookups are on every request.** Feed, search, profiles, comments, chat — every user-facing query needs to exclude blocked users. This needs to be a fast, indexed, dedicated table.

**Fix:** Separate `Block` entity with `blockerId`, `blockedId`, `createdAt`. Both columns individually indexed. Cacheable in Redis as a Set per user. Remove `BLOCK` from `ConnectionContext`.

**Fixed by ORM switch?** No — domain model issue.

---

### High Issues

#### Issue 7: DATING_PROFILE as Content

**Severity:** High
**Lines:** schema.prisma L274
**Evidence:** `DATING_PROFILE` is a `ContentType` enum value. Dating profiles are stored in the `Content` table alongside videos, products, and posts.

**Why this is wrong:**
- Dating profiles are **long-lived singletons** (one per user, updated over months), not ephemeral content (created, consumed, archived).
- Content has `likeCount`, `shareCount`, `viewCount`, `commentCount` — none of which apply to dating profiles. Dating has swipes, not likes. Matches, not comments.
- Content has `status: PENDING → ACTIVE → HIDDEN → FLAGGED → REMOVED`. Dating profiles have a different lifecycle: `INCOMPLETE → ACTIVE → PAUSED → HIDDEN`.
- Content appears in feeds. Dating profiles appear in a dedicated swipe interface with proximity + preference filtering — fundamentally different from feed assembly.
- `deletedAt` on Content means soft-delete. But you can't "delete" a dating profile the way you delete a post — it should be deactivatable.

**Fix:** `DatingProfile` as a separate entity with a 1:1 relation on `User`. Columns for indexed preferences (ageMin, ageMax, distanceKm, genderPreferences), prompts (JSONB), photo gallery (relation to Media), and its own status enum.

**Fixed by ORM switch?** Yes — CTI means DatingProfile naturally becomes its own entity outside the content hierarchy.

---

#### Issue 8: No Notification Model

**Severity:** High
**Evidence:** The schema has no model for in-app notifications. Push notifications via SNS are fire-and-forget — there's no way to:
- Show a notification inbox in the app
- Track read/unread state
- Group notifications ("3 people liked your video")
- Re-deliver missed notifications when a user was offline
- Let users clear or manage their notifications

**Evidence from old codebase:** `Notification.js` shows the old app had a full notification model with `type`, `moduleName`, `title`, `message`, `receiverRead` (read/unread), `isRead`, `notificationData`, `status`, and FK relations to 10+ entity types.

**Fix:** Create `Notification` entity with `id`, `userId`, `type` (enum), `title`, `body`, `data` (JSONB for deep-link payload), `readAt`, `groupKey` (for collapsing similar notifications), `createdAt`.

**Fixed by ORM switch?** No — missing model.

---

#### Issue 9: No Visibility Tier in Schema

**Severity:** High
**Evidence:** FEATURE_ARCHITECTURE.md (lines 229-239) promises four visibility tiers: Free, Member, VIP, Boosted. The schema has only `Visibility` enum with `PUBLIC`, `CONNECTIONS`, `PRIVATE` — which is access control (who can see it), not feed ranking (how prominently it appears).

These are two different concepts:
- **Access control** (Visibility): PUBLIC / CONNECTIONS / PRIVATE — determines whether a user *can* see content
- **Feed ranking tier** (VisibilityTier): FREE / MEMBER / VIP / BOOSTED — determines how *prominently* content surfaces in feeds for users who can see it

**Fix:** Add `tier` column to Content with enum `FREE | MEMBER | VIP | BOOSTED`. Add `boostExpiresAt DateTime?` for time-limited promotions. The feed algorithm uses `tier` as a ranking signal weight.

**Fixed by ORM switch?** No — missing column.

---

#### Issue 10: No Per-Module Follow Support

**Severity:** High
**Evidence:** FEATURE_ARCHITECTURE.md describes "per-module follow relationships" as part of cross-cutting user profiles. The old database had `user_follower_by_modules` with a `module` column. The new `Connection` model has no module scope — a follow is global.

**What breaks:** A user following someone's video content is forced to also see their marketplace listings and social posts. The old app explicitly supported "I follow your videos but not your shop."

**Fix:** Add `moduleScope` column to Connection (nullable — null means "follow everything"). Enum: `VIDEO | SHOP | SOCIAL | DATING | null`.

**Fixed by ORM switch?** No — missing column.

---

### Medium Issues

#### Issue 11: No Content Sub-Type for Absorbed Modules

**Severity:** Medium
**Evidence:** FEATURE_ARCHITECTURE.md (lines 212-224) describes Blog, Notice Board, VIP Pages, Find Discount, Lost & Found, and Missing Person being absorbed into the core experiences. The `ContentType` enum has `POST` but no way to distinguish a regular post from a blog post, a notice, or a missing person alert.

**Fix:** With CTI, the `Post` child entity gets a `subType` enum: `STANDARD | BLOG | NOTICE | MISSING_PERSON`. The `WantedAd` child entity handles Lost & Found with `wantedType: LOST | FOUND | STOLEN`. Find Discount becomes a `isDeal: boolean` flag on `Product`.

**Fixed by ORM switch?** Yes — CTI child entities naturally discriminate subtypes via typed columns.

---

#### Issue 12: No Audio/Music Model

**Severity:** Medium
**Evidence:** The old system had 7 tables for TikTok-style audio: `albums`, `artists`, `audio_artists`, `audio_tracks`, `audio_track_claims`, `audio_track_favorites`, `favorite_tags`. The new schema has nothing for audio.

**Impact:** Video creation with music overlay (a core TikTok-like feature) has no backend support. Music search, attribution, copyright claims, trending sounds — all missing.

**Fix:** Create `AudioTrack` entity with `id`, `title`, `artistName`, `url`, `durationSeconds`, `usageCount`, `isOriginal`, `sourceVideoId` (for "original sound" from user videos). Create `AudioTrackFavorite` for user sound libraries. Copyright claims can be deferred to a later phase.

**Fixed by ORM switch?** No — missing model.

---

#### Issue 13: Thread Missing moduleKey

**Severity:** Medium
**Lines:** schema.prisma L393-413
**Evidence:** The old `threads` table had `moduleKey` enum (`video_making`, `buy_sell`, `dating`, `social_stumble`) — critical for knowing whether a conversation is a marketplace inquiry, a dating match chat, or a social DM. The new `Thread` model has no `moduleKey`.

**Impact:** Can't filter chats by context ("show me my marketplace conversations"). Can't apply module-specific chat rules (marketplace: auto-close after sale; dating: only allow after match).

**Fix:** Add `moduleKey` enum to Thread. Also add `contextId` (nullable string) for linking to the entity that initiated the conversation (product ID, match ID, etc.).

**Fixed by ORM switch?** No — missing column.

---

#### Issue 14: Engagement Counters Have No Transaction Safety

**Severity:** Medium
**Lines:** schema.prisma L243-247, routes.ts L314-320
**Evidence:** Like/unlike operations increment/decrement counters in a separate query from the interaction creation:

```typescript
// routes.ts L298-320 — two separate operations, no transaction
await fastify.prisma.interaction.upsert({...}); // Step 1: create interaction
await fastify.prisma.content.update({           // Step 2: increment counter
  data: { likeCount: { increment: 1 } },
});
```

If Step 1 succeeds but Step 2 fails (network issue, process crash), the interaction exists but the counter is wrong. Over time, counters drift from actual interaction counts.

**Fix:** Wrap in a transaction. Or better: use TypeORM entity subscribers to automatically update counters when interactions are created/deleted — the counter update becomes a side effect of the interaction, not a separate manual operation.

**Fixed by ORM switch?** Partially — TypeORM subscribers can automate counter updates, but the transaction pattern is still needed for financial operations (auction bids).

---

### Score

**ORM switch resolves or partially resolves 5 of 14 issues.** The remaining 9 require schema design work regardless of ORM choice.

---

## Section 2: Recommended Schema

### Entity Relationship Overview

```
User ──┬── 1:1 ── DatingProfile
       ├── 1:1 ── UserPreferences
       ├── 1:1 ── YoyoSettings
       ├── 1:N ── Session
       ├── 1:N ── Device
       ├── 1:N ── Content (creator)
       │            ├── Video (CTI child)
       │            ├── Product (CTI child)
       │            │     └── 1:1 ── Auction
       │            │                  └── 1:N ── Bid
       │            ├── Post (CTI child)
       │            ├── Event (CTI child)
       │            └── WantedAd (CTI child)
       ├── 1:N ── InteractionState
       ├── 1:N ── InteractionEvent
       ├── 1:N ── Comment
       ├── 1:N ── Media (uploader)
       ├── 1:N ── Notification (recipient)
       ├── 1:N ── Block (blocker)
       ├── 1:N ── Connection (fromUser)
       ├── 1:N ── Report (reporter)
       └── N:M ── Thread (via ThreadParticipant)

Content ── 1:N ── Comment
         ── 1:N ── InteractionState
         ── 1:N ── InteractionEvent
         ── 1:N ── Report
         ── N:M ── Tag (via ContentTag)
         ── N:1 ── Category

Category ── self-referencing (parentId) for hierarchy
```

> 📋 **Regulatory entities** extend this diagram. See [REGULATORY_REQUIREMENTS.md §4](./REGULATORY_REQUIREMENTS.md#section-4-schema-additions) for: `ContentModerationResult` (1:N on Content), `BiometricConsent` (1:N on User), `CopyrightClaim` (N:1 Content + N:1 User), `SellerVerification` (1:1 on User), `DataProcessingRecord` (standalone). Column additions to User, AudioTrack, UserPreferences, DatingProfile, Post, and Content are also specified there.

### TypeORM Entity Definitions

#### Base Content Entity (Class Table Inheritance Root)

> 📋 **Regulatory:** Content requires `moderationScore` and `moderationMethod` columns for OSA proactive scanning compliance. See [REGULATORY_REQUIREMENTS.md §2.1.1](./REGULATORY_REQUIREMENTS.md#211-illegal-content-duty--proactive-scanning) and [§4 (Content additions)](./REGULATORY_REQUIREMENTS.md#content-entity-additions-for-moderation).

```typescript
@Entity('content')
@TableInheritance({ column: { type: 'varchar', name: 'type' } })
export class Content {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  creatorId: string;

  @ManyToOne(() => User, user => user.content)
  @JoinColumn({ name: 'creator_id' })
  creator: Relation<User>;

  @Column({ type: 'enum', enum: Visibility, default: Visibility.PUBLIC })
  visibility: Visibility;

  @Column({ type: 'enum', enum: ContentTier, default: ContentTier.FREE })
  tier: ContentTier;

  @Column({ type: 'geography', spatialFeatureType: 'Point', srid: 4326, nullable: true })
  location: string | null;

  @Column({ nullable: true })
  locationName: string | null;

  // Denormalised engagement counters
  @Column({ default: 0 })
  likeCount: number;

  @Column({ default: 0 })
  saveCount: number;

  @Column({ default: 0 })
  shareCount: number;

  @Column({ default: 0 })
  viewCount: number;

  @Column({ default: 0 })
  commentCount: number;

  @Column({ type: 'enum', enum: ContentStatus, default: ContentStatus.ACTIVE })
  status: ContentStatus;

  @Column({ nullable: true })
  moderatedAt: Date | null;

  @Column({ nullable: true })
  moderatedBy: string | null;

  @Column({ nullable: true })
  boostExpiresAt: Date | null;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @DeleteDateColumn()
  deletedAt: Date | null;

  // Relations
  @OneToMany(() => InteractionState, i => i.content)
  interactionStates: Relation<InteractionState[]>;

  @OneToMany(() => InteractionEvent, i => i.content)
  interactionEvents: Relation<InteractionEvent[]>;

  @OneToMany(() => Comment, c => c.content)
  comments: Relation<Comment[]>;

  @OneToMany(() => Report, r => r.content)
  reports: Relation<Report[]>;

  @OneToMany(() => ContentTag, ct => ct.content)
  contentTags: Relation<ContentTag[]>;

  @ManyToOne(() => Category, { nullable: true })
  @JoinColumn({ name: 'category_id' })
  category: Relation<Category> | null;
}
```

#### CTI Child Entities

```typescript
@ChildEntity('VIDEO')
export class Video extends Content {
  @Column()
  videoUrl: string;

  @Column()
  thumbnailUrl: string;

  @Column()
  durationSeconds: number;

  @Column({ nullable: true })
  caption: string | null;

  @Column({ nullable: true })
  musicId: string | null;

  @ManyToOne(() => AudioTrack, { nullable: true })
  @JoinColumn({ name: 'music_id' })
  music: Relation<AudioTrack> | null;
}

@ChildEntity('PRODUCT')
export class Product extends Content {
  @Column()
  title: string;

  @Column({ type: 'text', nullable: true })
  description: string | null;

  @Column()
  priceCents: number;

  @Column({ default: 'GBP' })
  currency: string;

  @Column({ type: 'enum', enum: ProductCondition })
  condition: ProductCondition;

  @Column({ default: false })
  isDeal: boolean;

  @Column({ nullable: true })
  originalPriceCents: number | null;

  @Column({ type: 'simple-array', nullable: true })
  shippingOptions: string[] | null;

  @OneToOne(() => Auction, auction => auction.product, { nullable: true })
  auction: Relation<Auction> | null;

  @OneToMany(() => Media, m => m.product)
  images: Relation<Media[]>;
}

// Regulatory: MISSING_PERSON subtype requires verifiedByAuthority and resolvedAt columns.
// See REGULATORY_REQUIREMENTS.md §4 (Post entity additions).
@ChildEntity('POST')
export class Post extends Content {
  @Column({ type: 'enum', enum: PostSubType, default: PostSubType.STANDARD })
  subType: PostSubType;

  @Column({ type: 'text' })
  text: string;

  @Column({ default: false })
  isPinned: boolean;

  @Column({ nullable: true })
  readingTime: string | null;

  @OneToMany(() => Media, m => m.post)
  images: Relation<Media[]>;
}

@ChildEntity('EVENT')
export class Event extends Content {
  @Column()
  title: string;

  @Column({ type: 'text', nullable: true })
  description: string | null;

  @Column({ nullable: true })
  venue: string | null;

  @Column()
  startsAt: Date;

  @Column()
  endsAt: Date;

  @Column({ nullable: true })
  capacity: number | null;

  @Column({ default: 0 })
  attendeeCount: number;
}

@ChildEntity('WANTED_AD')
export class WantedAd extends Content {
  @Column()
  title: string;

  @Column({ type: 'text', nullable: true })
  description: string | null;

  @Column({ type: 'enum', enum: WantedType })
  wantedType: WantedType;

  @Column({ nullable: true })
  lastSeenDate: Date | null;

  @Column({ nullable: true })
  contactInfo: string | null;

  @OneToMany(() => Media, m => m.wantedAd)
  images: Relation<Media[]>;
}
```

#### Enums

```typescript
enum Visibility {
  PUBLIC = 'PUBLIC',
  CONNECTIONS = 'CONNECTIONS',
  PRIVATE = 'PRIVATE',
}

enum ContentTier {
  FREE = 'FREE',
  MEMBER = 'MEMBER',
  VIP = 'VIP',
  BOOSTED = 'BOOSTED',
}

enum ContentStatus {
  PENDING = 'PENDING',
  ACTIVE = 'ACTIVE',
  HIDDEN = 'HIDDEN',
  FLAGGED = 'FLAGGED',
  REMOVED = 'REMOVED',
}

enum ProductCondition {
  NEW = 'NEW',
  LIKE_NEW = 'LIKE_NEW',
  GOOD = 'GOOD',
  FAIR = 'FAIR',
  FOR_PARTS = 'FOR_PARTS',
}

enum PostSubType {
  STANDARD = 'STANDARD',
  BLOG = 'BLOG',
  NOTICE = 'NOTICE',
  MISSING_PERSON = 'MISSING_PERSON',
}

enum WantedType {
  LOST = 'LOST',
  FOUND = 'FOUND',
  STOLEN = 'STOLEN',
}
```

#### Interactions (Split Model)

```typescript
// Idempotent toggles — one per (user, content, type)
@Entity('interaction_states')
@Unique(['userId', 'contentId', 'type'])
export class InteractionState {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;

  @Column()
  contentId: string;

  @Column({ type: 'enum', enum: InteractionStateType })
  type: InteractionStateType;

  @CreateDateColumn()
  createdAt: Date;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: Relation<User>;

  @ManyToOne(() => Content)
  @JoinColumn({ name: 'content_id' })
  content: Relation<Content>;
}

enum InteractionStateType {
  LIKE = 'LIKE',
  SAVE = 'SAVE',
}

// Append-only event log — no unique constraint
@Entity('interaction_events')
@Index(['userId', 'contentId', 'type', 'createdAt'])
export class InteractionEvent {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;

  @Column()
  contentId: string;

  @Column({ type: 'enum', enum: InteractionEventType })
  type: InteractionEventType;

  @Column({ type: 'jsonb', nullable: true })
  metadata: Record<string, unknown> | null;  // e.g., { bidAmountCents: 5000 }

  @CreateDateColumn()
  createdAt: Date;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: Relation<User>;

  @ManyToOne(() => Content)
  @JoinColumn({ name: 'content_id' })
  content: Relation<Content>;
}

enum InteractionEventType {
  VIEW = 'VIEW',
  SHARE = 'SHARE',
  BID = 'BID',
  SWIPE_RIGHT = 'SWIPE_RIGHT',
  SWIPE_LEFT = 'SWIPE_LEFT',
  SUPER_LIKE = 'SUPER_LIKE',
  SPARK = 'SPARK',
}
```

#### New Models

```typescript
// ── Media ─────────────────────────────────────────────
@Entity('media')
export class Media {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;

  @Column({ type: 'enum', enum: MediaType })
  type: MediaType;

  @Column()
  url: string;

  @Column({ nullable: true })
  thumbnailUrl: string | null;

  @Column({ type: 'enum', enum: MediaStatus, default: MediaStatus.UPLOADING })
  status: MediaStatus;

  @Column()
  mimeType: string;

  @Column({ type: 'bigint' })
  sizeBytes: number;

  @Column({ nullable: true })
  width: number | null;

  @Column({ nullable: true })
  height: number | null;

  @Column({ nullable: true })
  durationSeconds: number | null;

  @Column()
  s3Key: string;

  @CreateDateColumn()
  createdAt: Date;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: Relation<User>;
}

enum MediaType { IMAGE = 'IMAGE', VIDEO = 'VIDEO', AUDIO = 'AUDIO' }
enum MediaStatus { UPLOADING = 'UPLOADING', PROCESSING = 'PROCESSING', READY = 'READY', FAILED = 'FAILED' }

// ── Category ──────────────────────────────────────────
@Entity('categories')
@Tree('materialized-path')
export class Category {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  name: string;

  @Column({ unique: true })
  slug: string;

  @Column({ type: 'enum', enum: CategoryScope })
  scope: CategoryScope;

  @Column({ nullable: true })
  iconUrl: string | null;

  @Column({ default: 0 })
  sortOrder: number;

  @Column({ default: true })
  isActive: boolean;

  @TreeParent()
  parent: Relation<Category> | null;

  @TreeChildren()
  children: Relation<Category[]>;

  @CreateDateColumn()
  createdAt: Date;
}

enum CategoryScope { VIDEO = 'VIDEO', PRODUCT = 'PRODUCT', POST = 'POST' }

// ── Tag + ContentTag (many-to-many) ───────────────────
@Entity('tags')
export class Tag {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  name: string;

  @Column({ default: 0 })
  usageCount: number;

  @CreateDateColumn()
  createdAt: Date;
}

@Entity('content_tags')
@Unique(['contentId', 'tagId'])
export class ContentTag {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  contentId: string;

  @Column()
  tagId: string;

  @ManyToOne(() => Content, c => c.contentTags)
  @JoinColumn({ name: 'content_id' })
  content: Relation<Content>;

  @ManyToOne(() => Tag)
  @JoinColumn({ name: 'tag_id' })
  tag: Relation<Tag>;
}

// ── Notification ──────────────────────────────────────
@Entity('notifications')
export class Notification {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;

  @Column({ type: 'enum', enum: NotificationType })
  type: NotificationType;

  @Column()
  title: string;

  @Column({ type: 'text' })
  body: string;

  @Column({ type: 'jsonb', nullable: true })
  data: Record<string, unknown> | null;  // Deep-link payload

  @Column({ nullable: true })
  readAt: Date | null;

  @Column({ nullable: true })
  groupKey: string | null;  // For collapsing: "like:content:uuid" → "5 people liked your post"

  @CreateDateColumn()
  createdAt: Date;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: Relation<User>;
}

enum NotificationType {
  LIKE = 'LIKE',
  COMMENT = 'COMMENT',
  FOLLOW = 'FOLLOW',
  MATCH = 'MATCH',
  MESSAGE = 'MESSAGE',
  BID = 'BID',
  AUCTION_ENDING = 'AUCTION_ENDING',
  AUCTION_WON = 'AUCTION_WON',
  AUCTION_OUTBID = 'AUCTION_OUTBID',
  MENTION = 'MENTION',
  YOYO_NEARBY = 'YOYO_NEARBY',
  SYSTEM = 'SYSTEM',
}

// ── Block (separated from Connection) ─────────────────
@Entity('blocks')
@Unique(['blockerId', 'blockedId'])
export class Block {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  blockerId: string;

  @Column()
  @Index()
  blockedId: string;

  @CreateDateColumn()
  createdAt: Date;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'blocker_id' })
  blocker: Relation<User>;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'blocked_id' })
  blocked: Relation<User>;
}

// ── DatingProfile (1:1 on User, NOT in Content hierarchy) ──
// Regulatory: Dating module triggers US state safety laws (photo verification,
// registry checks) and BIPA (biometric consent for photo verification).
// Requires photoVerificationStatus column. 18+ hard gate via User.dateOfBirth.
// See REGULATORY_REQUIREMENTS.md §3.3 (State Dating Laws), §3.4 (BIPA),
// §2.1.2 (OSA children's safety), §4 (DatingProfile additions).
@Entity('dating_profiles')
export class DatingProfile {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  userId: string;

  @Column({ nullable: true })
  headline: string | null;

  @Column({ type: 'text' })
  bio: string;

  // DERIVED — do not store a static age integer. Compute from User.dateOfBirth:
  //   SELECT EXTRACT(YEAR FROM AGE(u.date_of_birth))::int AS age
  //   FROM dating_profiles dp JOIN users u ON u.id = dp.user_id
  // In TypeORM, expose as a virtual property or use @AfterLoad() to compute.
  // The User entity must have: @Column({ type: 'date' }) dateOfBirth: string;

  @Column({ default: 18 })
  @Index()
  preferenceAgeMin: number;

  @Column({ default: 99 })
  @Index()
  preferenceAgeMax: number;

  @Column({ default: 50 })
  preferenceDistanceKm: number;

  @Column({ type: 'simple-array' })
  preferenceGenders: string[];

  @Column({ type: 'jsonb', nullable: true })
  prompts: { question: string; answer: string }[] | null;

  @Column({ type: 'enum', enum: DatingProfileStatus, default: DatingProfileStatus.INCOMPLETE })
  status: DatingProfileStatus;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @OneToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: Relation<User>;

  @OneToMany(() => Media, m => m.datingProfile)
  photos: Relation<Media[]>;
}

enum DatingProfileStatus {
  INCOMPLETE = 'INCOMPLETE',
  ACTIVE = 'ACTIVE',
  PAUSED = 'PAUSED',
  HIDDEN = 'HIDDEN',
}

// ── AudioTrack ────────────────────────────────────────
// Regulatory: DMCA compliance requires licenseType, copyrightHolder, isLicensed
// columns for copyright tracking. See REGULATORY_REQUIREMENTS.md §3.5.4
// (AudioTrack Licensing) and §4 (AudioTrack additions).
@Entity('audio_tracks')
export class AudioTrack {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  title: string;

  @Column({ nullable: true })
  artistName: string | null;

  @Column()
  url: string;

  @Column()
  durationSeconds: number;

  @Column({ default: 0 })
  usageCount: number;

  @Column({ default: false })
  isOriginal: boolean;

  @Column({ nullable: true })
  sourceVideoId: string | null;  // For "original sound" from user videos

  @CreateDateColumn()
  createdAt: Date;
}

// ── AuditEntry (append-only, immutable) ───────────────
// Regulatory: AuditEntry serves as the data source for OSA transparency
// reporting (§2.1.4) and UK GDPR breach notification trail (§2.3.4).
// Use standardised action strings: 'security.breach_detected',
// 'security.breach_notified_ico', 'biometric.data_destroyed', etc.
// See REGULATORY_REQUIREMENTS.md §2.1.4 and §2.3.4.
@Entity('audit_entries')
@Index(['entityType', 'entityId'])
@Index(['actorId', 'createdAt'])
export class AuditEntry {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ nullable: true })
  actorId: string | null;  // null for system actions

  @Column()
  action: string;  // 'content.created', 'bid.placed', 'user.blocked', etc.

  @Column()
  entityType: string;

  @Column()
  entityId: string;

  @Column({ type: 'jsonb', nullable: true })
  changes: Record<string, unknown> | null;

  @CreateDateColumn()
  createdAt: Date;
}

// ── UserConsent (GDPR/CCPA consent tracking) ──────────
// Referenced in Section 6 (GDPR Compliance). Full regulatory context
// in docs/internal/REGULATORY_REQUIREMENTS.md Section 2.3 and Section 3.2.
@Entity('user_consents')
@Unique(['userId', 'consentType', 'version'])
export class UserConsent {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;

  @Column({ type: 'enum', enum: ConsentType })
  consentType: ConsentType;

  @Column()
  version: string;  // e.g., 'privacy-policy-v2', 'terms-v3'

  @Column()
  grantedAt: Date;

  @Column({ nullable: true })
  revokedAt: Date | null;

  @Column({ type: 'enum', enum: ConsentSource, default: ConsentSource.REGISTRATION })
  source: ConsentSource;  // Where consent was collected

  @Column({ nullable: true })
  ipAddress: string | null;  // Record for audit trail

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: Relation<User>;
}

enum ConsentType {
  TERMS = 'TERMS',
  PRIVACY = 'PRIVACY',
  MARKETING = 'MARKETING',
  LOCATION = 'LOCATION',
  COOKIES = 'COOKIES',
  DATA_SALE_OPT_OUT = 'DATA_SALE_OPT_OUT',  // CCPA/CPRA
}

enum ConsentSource {
  REGISTRATION = 'REGISTRATION',
  SETTINGS = 'SETTINGS',
  PROMPT = 'PROMPT',
  LEGAL_UPDATE = 'LEGAL_UPDATE',
}
```

#### Updated Connection (without BLOCK, with moduleScope)

```typescript
@Entity('connections')
@Unique(['fromUserId', 'toUserId', 'context'])
export class Connection {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  fromUserId: string;

  @Column()
  toUserId: string;

  @Column({ type: 'enum', enum: ConnectionContext })
  context: ConnectionContext;

  @Column({ type: 'enum', enum: ConnectionStatus, default: ConnectionStatus.PENDING })
  status: ConnectionStatus;

  @Column({ type: 'enum', enum: ModuleScope, nullable: true })
  moduleScope: ModuleScope | null;  // null = follow everything

  @Column({ nullable: true })
  matchedAt: Date | null;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'from_user_id' })
  fromUser: Relation<User>;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'to_user_id' })
  toUser: Relation<User>;
}

enum ConnectionContext {
  FOLLOW = 'FOLLOW',
  FRIEND = 'FRIEND',
  MATCH = 'MATCH',
  YOYO = 'YOYO',
  // BLOCK removed — now a separate entity
}

enum ConnectionStatus {
  PENDING = 'PENDING',
  ACTIVE = 'ACTIVE',
  REJECTED = 'REJECTED',
}

enum ModuleScope {
  VIDEO = 'VIDEO',
  SHOP = 'SHOP',
  SOCIAL = 'SOCIAL',
  DATING = 'DATING',
}
```

#### Updated Thread (with moduleKey)

```typescript
@Entity('threads')
export class Thread {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'enum', enum: ThreadType, default: ThreadType.DIRECT })
  type: ThreadType;

  @Column({ type: 'enum', enum: ModuleScope, nullable: true })
  moduleKey: ModuleScope | null;

  @Column({ nullable: true })
  contextId: string | null;  // Product ID, match ID, etc.

  @Column({ nullable: true })
  name: string | null;

  @Column({ nullable: true })
  imageUrl: string | null;

  @Column({ nullable: true })
  lastMessage: string | null;

  @Column({ default: () => 'CURRENT_TIMESTAMP' })
  lastActivity: Date;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @OneToMany(() => ThreadParticipant, tp => tp.thread)
  participants: Relation<ThreadParticipant[]>;

  @OneToMany(() => Message, m => m.thread)
  messages: Relation<Message[]>;
}
```

#### Updated Report (split FK columns)

```typescript
@Entity('reports')
export class Report {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  reporterId: string;

  @Column({ type: 'enum', enum: ReportTarget })
  targetType: ReportTarget;

  // Split FK columns — exactly one should be non-null
  @Column({ nullable: true })
  reportedUserId: string | null;

  @Column({ nullable: true })
  reportedContentId: string | null;

  @Column({ nullable: true })
  reportedMessageId: string | null;

  @Column({ nullable: true })
  reportedCommentId: string | null;

  @Column({ type: 'enum', enum: ReportCategory })
  category: ReportCategory;

  @Column({ type: 'text', nullable: true })
  description: string | null;

  @Column({ type: 'jsonb', nullable: true })
  evidence: Record<string, unknown> | null;

  @Column({ type: 'enum', enum: ReportStatus, default: ReportStatus.PENDING })
  status: ReportStatus;

  @Column({ type: 'text', nullable: true })
  resolution: string | null;

  @Column({ nullable: true })
  resolvedBy: string | null;

  @Column({ nullable: true })
  resolvedAt: Date | null;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'reporter_id' })
  reporter: Relation<User>;

  @ManyToOne(() => User, { nullable: true })
  @JoinColumn({ name: 'reported_user_id' })
  reportedUser: Relation<User> | null;

  @ManyToOne(() => Content, { nullable: true })
  @JoinColumn({ name: 'reported_content_id' })
  reportedContent: Relation<Content> | null;

  @ManyToOne(() => Message, { nullable: true })
  @JoinColumn({ name: 'reported_message_id' })
  reportedMessage: Relation<Message> | null;

  @ManyToOne(() => Comment, { nullable: true })
  @JoinColumn({ name: 'reported_comment_id' })
  reportedComment: Relation<Comment> | null;
}
```

### Table Count

| Area | Tables |
|------|--------|
| Users & Auth | 5 (users, sessions, verifications, devices, user_preferences) |
| Content (CTI) | 6 (content, videos, products, posts, events, wanted_ads) |
| Dating | 1 (dating_profiles) |
| Interactions | 2 (interaction_states, interaction_events) |
| Social | 3 (comments, connections, blocks) |
| Messaging | 3 (threads, thread_participants, messages) |
| Media & Audio | 2 (media, audio_tracks) |
| Discovery | 2 (yoyo_settings, yoyo_overrides) |
| Organisation | 3 (categories, tags, content_tags) |
| Moderation | 2 (reports, audit_entries) |
| Notifications | 1 (notifications) |
| Shop | 2 (auctions, bids) |
| **Total** | **32** |

Up from the Prisma schema's ~17 models, down from the old system's 130 tables. The increase from 17 is because the Prisma schema was missing critical models (Media, Category, Tag, Notification, Block, AudioTrack, AuditEntry) and CTI splits the monolithic Content into typed child tables. The decrease from 130 is because duplication is eliminated (11 report tables → 1, 6 separate comment systems → 1, etc.).

---

## Section 3: Document-to-Schema Reconciliation

Every promise in FEATURE_ARCHITECTURE.md mapped to the entity and column that delivers it.

### Part 2: Four Core Experiences

| Promise (FEATURE_ARCHITECTURE.md) | Entity | Column(s) | Notes |
|-----------------------------------|--------|-----------|-------|
| Video tab — TikTok-style feed | `Video` (CTI child) | `videoUrl`, `thumbnailUrl`, `durationSeconds`, `caption` | CTI discriminator `type = 'VIDEO'` |
| Video — recording up to 60s | `Video` | `durationSeconds` (validated ≤180 at API) | Client-side recording, server stores result |
| Video — audio library | `AudioTrack` | `title`, `artistName`, `url`, `durationSeconds` | `Video.musicId` FK to `AudioTrack` |
| Video — 27 categories | `Category` | `scope = 'VIDEO'` | Seed data from old `video_categories` table |
| Dating tab — profile-based matching | `DatingProfile` | `bio`, `age`, `preferenceAgeMin/Max/DistanceKm/Genders`, `prompts` | 1:1 on User, NOT in content hierarchy |
| Dating — swipe mechanics | `InteractionEvent` | `type: SWIPE_RIGHT / SWIPE_LEFT / SUPER_LIKE / SPARK` | Append-only (no unique constraint allows re-swipe) |
| Dating — matching | `Connection` | `context: MATCH`, `status: ACTIVE`, `matchedAt` | Created when both users swipe right |
| Social tab — posts | `Post` (CTI child) | `text`, `subType: STANDARD` | Images via `Media` relation |
| Social — events | `Event` (CTI child) | `title`, `venue`, `startsAt`, `endsAt`, `capacity`, `attendeeCount` | |
| Social — friend system | `Connection` | `context: FRIEND`, `status: PENDING → ACTIVE` | |
| Shop tab — product listings | `Product` (CTI child) | `title`, `description`, `priceCents`, `condition`, `currency` | Images via `Media` relation |
| Shop — auctions | `Auction` | `startPrice`, `currentPrice`, `minIncrement`, `startsAt`, `endsAt`, `status` | 1:1 on Product |
| Shop — bidding | `Bid` | `userId`, `auctionId`, `amountCents` | Multiple bids per user allowed |
| Shop — 54 categories (hierarchical) | `Category` | `scope: PRODUCT`, `parentId` (self-ref) | `@Tree('materialized-path')` for hierarchy |

### Cross-Cutting Capabilities

| Promise | Entity | Column(s) | Notes |
|---------|--------|-----------|-------|
| YoYo proximity | `User` | `lastLocation` (PostGIS geography) | `ST_DWithin` for proximity queries |
| YoYo settings | `YoyoSettings` | `enabled`, `myPrecision`, `whoSeesExact`, `activeHours*` | Per-user privacy control |
| YoYo overrides | `YoyoOverride` | `targetUserId`, `precision` | Per-person precision override |
| Sponsored links / Boosted | `Content` | `tier: BOOSTED`, `boostExpiresAt` | Feed algorithm weights by tier |
| Messaging — unified inbox | `Thread` + `ThreadParticipant` + `Message` | `moduleKey` on Thread for context | Single inbox, filterable by module |
| Unified reporting | `Report` | `targetType`, split FK columns | One report flow, one review queue |
| Per-module follows | `Connection` | `moduleScope: VIDEO / SHOP / SOCIAL / DATING / null` | null = follow everything |

### Absorbed Extended Modules

| Old Module | Becomes | Entity | Discriminator |
|-----------|---------|--------|---------------|
| Blog | Long-form post | `Post` | `subType: BLOG`, `readingTime` set |
| Notice Board | Announcement post | `Post` | `subType: NOTICE`, `isPinned: true` |
| VIP Pages | Enhanced creator profiles | `User` (VIP status) + `Content.tier: VIP` | VIP is a tier, not a module |
| Find Discount | Deal tag on products | `Product` | `isDeal: true`, `originalPriceCents` set |
| Lost & Found | Community listing | `WantedAd` | `wantedType: LOST / FOUND / STOLEN` |
| Missing Person | Safety post | `Post` | `subType: MISSING_PERSON` |

### Content Visibility Tiers

| Tier | Schema Mapping | Feed Algorithm Effect |
|------|---------------|----------------------|
| Free | `Content.tier = FREE` (default) | Standard chronological + engagement ranking |
| Member | `Content.tier = MEMBER` | +10% boost weight in ranking score |
| VIP | `Content.tier = VIP` | +25% boost weight, priority in non-follower feeds |
| Boosted | `Content.tier = BOOSTED`, `boostExpiresAt` set | Appears in sponsored placements, analytics tracked via `InteractionEvent` |

### Remaining Gaps

| Feature Mentioned | Status | Notes |
|-------------------|--------|-------|
| Video editing (trim, filters, effects, text overlay) | Client-side only | No backend entity needed — editing happens before upload |
| Photo albums | Not modelled | Could be a collection of `Media` items with a name. Defer to Phase 2 if needed. |
| User hobbies / interests | Not modelled | Old app had `user_hobbies`, `user_interests`. Could be JSONB on User or separate entity. Low priority. |
| User tagging in posts | Partially modelled | `Post.text` can contain @mentions parsed client-side. No dedicated `PostMention` join table. Add if mention notifications are needed. |
| Draft videos | Not modelled | `Content.status = DRAFT` could work, or a separate `Draft` entity for work-in-progress that hasn't been published. |
| Privacy controls (who can see/message) | Partially modelled | `Visibility` enum handles view access. Message permissions need `UserPreferences` extension (e.g., `allowMessagesFrom: EVERYONE / CONNECTIONS / NOBODY`). |
| Search by hashtag/user/audio | Covered by entities | `Tag` for hashtags, `User.username` for user search, `AudioTrack.title` for audio search. Full-text search via `tsvector` (Section 6). |

---

## Section 4: Feed Architecture

### How Mixed Feeds Get Assembled

The feed is the core user experience. Every tab (Video, Social, Shop, Home) shows a mixed, ranked feed of content items from different CTI subtypes.

### Feed Query Flow

```
Client Request
  GET /feed?tab=social&cursor=abc&limit=20&lat=51.5&lng=-0.1
      │
      ▼
  FeedController.getFeed()
      │
      ▼
  FeedService.assembleFeed(userId, tab, cursor, limit, location)
      │
      ├── 1. BlockRepository.getBlockedIds(userId)         → Set<string>
      │      (cached in Redis, TTL 5 min)
      │
      ├── 2. UserPreferencesRepository.getWeights(userId)  → { video, social, shop, dating }
      │
      ├── 3. FeedRepository.findForUser(userId, {          → Content[]
      │        tab,
      │        cursor,
      │        limit,
      │        blockedIds,
      │        weights,
      │        location,
      │      })
      │
      └── 4. Return paginated response with nextCursor
```

### FeedRepository — The Core Query

```typescript
@Injectable()
export class FeedRepository {
  constructor(
    @InjectRepository(Content)
    private readonly contentRepo: Repository<Content>,
  ) {}

  async findForUser(
    userId: string,
    opts: FeedQueryOptions,
  ): Promise<Content[]> {
    const { tab, cursor, limit, blockedIds, weights, location } = opts;

    const qb = this.contentRepo
      .createQueryBuilder('content')
      .leftJoinAndSelect('content.creator', 'creator')
      .leftJoinAndSelect('content.category', 'category')
      .where('content.status = :status', { status: ContentStatus.ACTIVE })
      .andWhere('content.visibility = :visibility', { visibility: Visibility.PUBLIC })
      .andWhere('content.creatorId != :userId', { userId });

    // Block filtering — composable, not manual per-query
    if (blockedIds.length > 0) {
      qb.andWhere('content.creatorId NOT IN (:...blockedIds)', { blockedIds });
    }

    // Tab → content type filtering
    const typeMap: Record<string, string[]> = {
      video: ['VIDEO'],
      dating: [],  // Dating uses DatingProfile, not Content
      social: ['POST', 'EVENT'],
      shop: ['PRODUCT', 'WANTED_AD'],
      home: ['VIDEO', 'PRODUCT', 'POST', 'EVENT'],
    };
    const types = typeMap[tab];
    if (types.length > 0) {
      qb.andWhere('content.type IN (:...types)', { types });
    }

    // Cursor-based pagination
    if (cursor) {
      qb.andWhere('content.createdAt < (SELECT created_at FROM content WHERE id = :cursor)', { cursor });
    }

    // Ranking: multi-signal score
    qb.addSelect(`(
      -- Recency decay (exponential, half-life 24h)
      EXP(-0.693 * EXTRACT(EPOCH FROM (NOW() - content.created_at)) / 86400)
      -- Engagement signal
      + (content.like_count * 0.3 + content.comment_count * 0.5 + content.share_count * 0.8) * 0.001
      -- Tier boost
      + CASE content.tier
          WHEN 'VIP' THEN 0.25
          WHEN 'MEMBER' THEN 0.10
          WHEN 'BOOSTED' THEN 0.40
          ELSE 0
        END
    )`, 'rank_score');

    qb.orderBy('rank_score', 'DESC')
      .take(limit);

    return qb.getMany();
  }
}
```

### Ranking Signals

| Signal | Weight | Source | Notes |
|--------|--------|--------|-------|
| Recency | Primary | `content.createdAt` | Exponential decay, half-life 24 hours. Recent content ranks higher. |
| Engagement | Secondary | `likeCount`, `commentCount`, `shareCount` | Weighted: shares > comments > likes. Normalised to 0-1 range. |
| Creator relevance | Tertiary | `Connection` table | Content from followed creators gets a boost. Requires subquery or JOIN. |
| Content type weight | Quaternary | `UserPreferences` | Users who watch more videos see more videos. Weights from 0-1 per type. |
| Proximity | Conditional | PostGIS `ST_DWithin` | Only for location-aware content (Shop, Events, WantedAds). Uses `content.location`. |
| Tier boost | Additive | `Content.tier` | FREE=0, MEMBER=+0.10, VIP=+0.25, BOOSTED=+0.40 |

### Caching Strategy

| Cache | Key Pattern | TTL | Invalidation |
|-------|-------------|-----|--------------|
| Block list | `blocks:{userId}` | 5 min | On block/unblock event |
| User preferences | `prefs:{userId}` | 15 min | On preference update |
| Feed page | `feed:{userId}:{tab}:{cursor}` | 60 sec | On new content creation (invalidate tab) |
| Trending content | `trending:{tab}` | 5 min | Recalculated by background job |
| Creator profile | `creator:{userId}` | 10 min | On profile update |

### ViewEntity for Trending

TypeORM's `@ViewEntity()` can pre-compute trending feeds:

```typescript
@ViewEntity({
  expression: `
    SELECT
      content.id,
      content.type,
      content.creator_id,
      content.created_at,
      (content.like_count * 0.3 + content.comment_count * 0.5 + content.share_count * 0.8)
        * EXP(-0.693 * EXTRACT(EPOCH FROM (NOW() - content.created_at)) / 86400)
        AS trending_score
    FROM content
    WHERE content.status = 'ACTIVE'
      AND content.created_at > NOW() - INTERVAL '7 days'
    ORDER BY trending_score DESC
    LIMIT 1000
  `,
})
export class TrendingContent {
  @ViewColumn()
  id: string;

  @ViewColumn()
  type: string;

  @ViewColumn()
  creatorId: string;

  @ViewColumn()
  createdAt: Date;

  @ViewColumn()
  trendingScore: number;
}
```

---

## Section 5: State Machines

### Content Lifecycle

> 📋 **Regulatory:** The Online Safety Act requires a proactive scanning step *before* content reaches ACTIVE state. The PENDING → ACTIVE transition should include automated moderation (AWS Rekognition, hash matching) with results stored in `ContentModerationResult`. Content that fails scanning should transition to FLAGGED or REMOVED automatically. See [REGULATORY_REQUIREMENTS.md §2.1.1](./REGULATORY_REQUIREMENTS.md#211-illegal-content-duty--proactive-scanning).
>
> DMCA takedowns create an additional transition: ACTIVE → REMOVED via `CopyrightClaim` (external to the Report flow). See [REGULATORY_REQUIREMENTS.md §3.5.2](./REGULATORY_REQUIREMENTS.md#352-takedown--counter-notification-flow).

```
                    ┌──────────┐
            ┌───────│  PENDING │ (awaiting moderation, if moderation enabled)
            │       └────┬─────┘
            │            │ approve
            │            ▼
  create ──►│       ┌──────────┐
            └───────│  ACTIVE  │◄──────── restore (by moderator)
                    └────┬─────┘
                         │
              ┌──────────┼──────────┐
              │          │          │
         hide │     flag │   remove │
         (creator)  (report)  (moderator)
              │          │          │
              ▼          ▼          ▼
         ┌────────┐ ┌────────┐ ┌─────────┐
         │ HIDDEN │ │FLAGGED │ │ REMOVED │
         └────┬───┘ └────┬───┘ └─────────┘
              │          │
         unhide    ┌─────┴─────┐
         (creator) │           │
              │    dismiss    remove
              │    (moderator) (moderator)
              ▼         │          │
         ┌────────┐     ▼          ▼
         │ ACTIVE │ ┌────────┐ ┌─────────┐
         └────────┘ │ ACTIVE │ │ REMOVED │
                    └────────┘ └─────────┘
```

**Transitions:**
- `PENDING → ACTIVE`: Moderator approves, or auto-approve if moderation disabled
- `ACTIVE → HIDDEN`: Creator hides their own content
- `HIDDEN → ACTIVE`: Creator unhides
- `ACTIVE → FLAGGED`: Report threshold reached (e.g., 3 reports)
- `FLAGGED → ACTIVE`: Moderator dismisses reports
- `FLAGGED → REMOVED`: Moderator confirms violation
- `ACTIVE → REMOVED`: Moderator removes directly (severe violations)
- `REMOVED → ACTIVE`: Moderator restores (appeals process)

---

### Auction Lifecycle

> 📋 **Regulatory:** Auctions and marketplace transactions trigger UK Consumer Rights Act cooling-off periods (14-day right to cancel) and potential AML/KYC obligations for high-value sellers. Seller identity verification via `SellerVerification` entity may be required. See [REGULATORY_REQUIREMENTS.md §2.4](./REGULATORY_REQUIREMENTS.md#24-consumer-rights--distance-selling) and [§3.6](./REGULATORY_REQUIREMENTS.md#36-amlkyc-for-marketplace).

```
  create ──► ┌───────────┐
             │ SCHEDULED │ (future start time)
             └─────┬─────┘
                   │ startsAt reached (cron job)
                   ▼
             ┌───────────┐
             │  ACTIVE   │◄─── bid placed (updates currentPrice)
             └─────┬─────┘
                   │
          ┌────────┼────────┐
          │        │        │
     endsAt     cancel    bid
     reached   (creator) (bidder)
     (cron)       │        │
          │        │        │
          ▼        ▼        │
     ┌─────────┐ ┌──────────┐    │
     │  ENDED  │ │CANCELLED │    │
     └────┬────┘ └──────────┘    │
          │                      │
     winnerId set                │
     (highest bidder)            │
          │                      │
          ▼                      │
     Notification:               │
     AUCTION_WON (winner)        │
     AUCTION_ENDED (seller)      │
     AUCTION_OUTBID (losers) ◄───┘
```

**Business rules:**
- Minimum bid = `currentPrice + minIncrement`
- Bid validation in a transaction: read `currentPrice`, validate, insert bid, update `currentPrice`, all atomically
- Anti-sniping: if bid placed within last 2 minutes of `endsAt`, extend `endsAt` by 2 minutes (configurable)
- Cron job runs every minute to transition `SCHEDULED → ACTIVE` and `ACTIVE → ENDED`

---

### Connection Lifecycle

```
  ── FOLLOW ──
  create ──► ACTIVE (immediate, no approval needed)

  ── FRIEND ──
  request ──► ┌─────────┐
              │ PENDING │
              └────┬────┘
                   │
            ┌──────┼──────┐
            │      │      │
          accept  reject  (timeout)
            │      │      │
            ▼      ▼      ▼
       ┌────────┐ ┌──────────┐ ┌──────────┐
       │ ACTIVE │ │ REJECTED │ │ expired  │
       └────────┘ └──────────┘ └──────────┘

  ── MATCH (Dating) ──
  Regulatory: Dating module requires 18+ age gate (OSA §2.1.2, COPPA §3.1),
  photo verification (State Laws §3.3), biometric consent if face geometry
  used (BIPA §3.4). See REGULATORY_REQUIREMENTS.md.

  User A swipes right ──► InteractionEvent (SWIPE_RIGHT)
                          │
                          Check: has User B already swiped right on A?
                          │
                    ┌─────┴──────┐
                    │ No         │ Yes
                    ▼            ▼
               (wait)       Connection created:
                            context=MATCH, status=ACTIVE
                            │
                            Thread created:
                            moduleKey=DATING, contextId=matchId
```

---

### Report Lifecycle

> 📋 **Regulatory:** Report volumes, outcomes, and response times must be aggregated for the OSA annual transparency report to Ofcom. The Report + AuditEntry tables provide the raw data. See [REGULATORY_REQUIREMENTS.md §2.1.4](./REGULATORY_REQUIREMENTS.md#214-transparency-reporting). Note that DMCA copyright claims have their own lifecycle via `CopyrightClaim`, separate from this general report flow — see [§3.5](./REGULATORY_REQUIREMENTS.md#35-dmca-digital-millennium-copyright-act).

```
  submit ──► ┌─────────┐
             │ PENDING │
             └────┬────┘
                  │ moderator picks up
                  ▼
             ┌───────────┐
             │ IN_REVIEW │
             └─────┬─────┘
                   │
          ┌────────┼────────┐
          │        │        │
       dismiss   action   escalate
          │        │        │
          ▼        ▼        ▼
     ┌───────────┐ ┌──────────┐ ┌───────────┐
     │ DISMISSED │ │ RESOLVED │ │ ESCALATED │
     └───────────┘ └──────────┘ └───────────┘
                        │
                   Side effects:
                   - Content → REMOVED
                   - User → SUSPENDED/BANNED
                   - AuditEntry created
```

---

## Section 6: Missing Infrastructure

> 📋 **Regulatory:** This section covers GDPR fundamentals. For the full regulatory landscape (Online Safety Act, COPPA, CCPA, BIPA, DMCA, consumer protection, AML/KYC) and all required schema additions, see [REGULATORY_REQUIREMENTS.md](./REGULATORY_REQUIREMENTS.md). The cross-reference table in [§5](./REGULATORY_REQUIREMENTS.md#section-5-cross-reference-to-tdd) maps every regulatory requirement back to TDD sections, and the implementation phasing in [§6](./REGULATORY_REQUIREMENTS.md#section-6-implementation-priority) prioritises pre-launch vs post-launch obligations.

### GDPR Compliance

| Requirement | Implementation |
|-------------|---------------|
| Right to access | `GET /users/me/data-export` — generates JSON of all user data (profile, content, interactions, messages, connections). Async job, delivers via secure download link or email. |
| Right to erasure | `DELETE /users/me` — soft-deletes user, anonymises PII (display name → "Deleted User", avatar → null, bio → null). Content can be kept (anonymised) or deleted per user preference. Media files queued for S3 deletion. |
| Data portability | Same as right to access — JSON export. |
| Consent tracking | `UserConsent` entity (defined in Section 2, New Models): `userId`, `consentType` (TERMS/PRIVACY/MARKETING/LOCATION/COOKIES/DATA_SALE_OPT_OUT), `grantedAt`, `revokedAt`, `version`, `source`, `ipAddress`. See `REGULATORY_REQUIREMENTS.md` for extended consent types (CCPA, BIPA). |
| Retention policy | Soft-deleted users: full erasure after 30 days. Audit entries: retained 7 years (financial compliance). Interaction events: retained 2 years, then aggregated. |

### Rate Limiting

| Endpoint Group | Limit | Window | Implementation |
|---------------|-------|--------|----------------|
| Auth (OTP send) | 5 requests | 15 min | Per phone number. Prevents OTP abuse. |
| Auth (OTP verify) | 10 attempts | 15 min | Per phone number. Lock after 10 failures. |
| Content creation | 30 posts | 1 hour | Per user. Prevents spam flooding. |
| Feed requests | 120 requests | 1 min | Per user. Generous for scrolling. |
| Search | 30 requests | 1 min | Per user. Prevents scraping. |
| File upload | 50 uploads | 1 hour | Per user. Storage abuse prevention. |
| Bid placement | 60 bids | 1 min | Per user per auction. Prevents bid spamming. |
| Report submission | 10 reports | 1 hour | Per user. Prevents report abuse. |
| Global fallback | 1000 requests | 1 min | Per IP. DDoS mitigation. |

Implementation: `@nestjs/throttler` with Redis backing store for distributed rate limiting.

### Admin Roles

| Role | Permissions |
|------|------------|
| `SUPER_ADMIN` | Everything. User management, system config, financial data. |
| `MODERATOR` | Report review, content removal, user suspension. No financial access. |
| `SUPPORT` | Read-only user data, respond to support tickets. No moderation actions. |
| `ANALYST` | Read-only analytics, engagement data, trend reports. No user PII. |

Implementation: `@nestjs/casl` for attribute-based access control (ABAC) or a simple role-based guard.

### Full-Text Search

PostgreSQL-native search using `tsvector` and `pg_trgm`.

**Note:** Because `content` uses Class Table Inheritance, columns like `title`, `description`, and `caption` live on child tables (`products`, `videos`, `posts`, etc.), not on the `content` base table. A generated tsvector column on `content` cannot reference child columns. Two approaches:

**Option A — Per-child-table tsvector (simpler, recommended at launch):**

```sql
-- Products: search on title + description
ALTER TABLE products ADD COLUMN search_vector tsvector
  GENERATED ALWAYS AS (
    setweight(to_tsvector('english', COALESCE(title, '')), 'A') ||
    setweight(to_tsvector('english', COALESCE(description, '')), 'B')
  ) STORED;
CREATE INDEX idx_products_search ON products USING GIN (search_vector);

-- Videos: search on caption
ALTER TABLE videos ADD COLUMN search_vector tsvector
  GENERATED ALWAYS AS (
    to_tsvector('english', COALESCE(caption, ''))
  ) STORED;
CREATE INDEX idx_videos_search ON videos USING GIN (search_vector);

-- Posts: search on text
ALTER TABLE posts ADD COLUMN search_vector tsvector
  GENERATED ALWAYS AS (
    to_tsvector('english', COALESCE(text, ''))
  ) STORED;
CREATE INDEX idx_posts_search ON posts USING GIN (search_vector);

-- Events: search on title + description
ALTER TABLE events ADD COLUMN search_vector tsvector
  GENERATED ALWAYS AS (
    setweight(to_tsvector('english', COALESCE(title, '')), 'A') ||
    setweight(to_tsvector('english', COALESCE(description, '')), 'B')
  ) STORED;
CREATE INDEX idx_events_search ON events USING GIN (search_vector);

-- Wanted ads: search on title + description
ALTER TABLE wanted_ads ADD COLUMN search_vector tsvector
  GENERATED ALWAYS AS (
    setweight(to_tsvector('english', COALESCE(title, '')), 'A') ||
    setweight(to_tsvector('english', COALESCE(description, '')), 'B')
  ) STORED;
CREATE INDEX idx_wanted_ads_search ON wanted_ads USING GIN (search_vector);
```

**Option B — Materialised search view (better for unified cross-type search):**

```sql
CREATE MATERIALIZED VIEW content_search AS
  SELECT c.id, c.status, c.type,
    setweight(to_tsvector('english', COALESCE(p.title, e.title, w.title, '')), 'A') ||
    setweight(to_tsvector('english', COALESCE(p.description, e.description, w.description, v.caption, po.text, '')), 'B')
    AS search_vector
  FROM content c
  LEFT JOIN products p ON p.id = c.id
  LEFT JOIN videos v ON v.id = c.id
  LEFT JOIN posts po ON po.id = c.id
  LEFT JOIN events e ON e.id = c.id
  LEFT JOIN wanted_ads w ON w.id = c.id;

CREATE INDEX idx_content_search ON content_search USING GIN (search_vector);

-- Refresh periodically or via trigger
REFRESH MATERIALIZED VIEW CONCURRENTLY content_search;
```

**User/username search (independent of CTI — works directly):**

```sql
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX idx_users_username_trgm ON users USING GIN (username gin_trgm_ops);
CREATE INDEX idx_users_display_name_trgm ON users USING GIN (display_name gin_trgm_ops);
```

Search query (using Option A, per-table):

```sql
-- Example: search products
SELECT c.id, ts_rank(p.search_vector, query) AS rank
FROM content c
JOIN products p ON p.id = c.id,
  plainto_tsquery('english', 'vintage car') AS query
WHERE p.search_vector @@ query
  AND c.status = 'ACTIVE'
ORDER BY rank DESC
LIMIT 20;
```

This handles search at startup scale. Migrate to ElasticSearch/OpenSearch if:
- Search latency exceeds 200ms p95
- Faceted search (filter by price range + category + condition simultaneously) becomes a core feature
- Multi-language support is needed (PostgreSQL full-text has limited language support)

### Transaction Safety for Counters

All counter updates must be wrapped in transactions or handled via entity subscribers:

```typescript
@EventSubscriber()
export class InteractionStateSubscriber implements EntitySubscriberInterface<InteractionState> {
  listenTo() { return InteractionState; }

  async afterInsert(event: InsertEvent<InteractionState>): Promise<void> {
    const { entity, manager } = event;
    const column = entity.type === 'LIKE' ? 'likeCount' : 'saveCount';

    await manager.increment(Content, { id: entity.contentId }, column, 1);
  }

  async afterRemove(event: RemoveEvent<InteractionState>): Promise<void> {
    const { entity, manager } = event;
    if (!entity) return;
    const column = entity.type === 'LIKE' ? 'likeCount' : 'saveCount';

    await manager.decrement(Content, { id: entity.contentId }, column, 1);
  }
}
```

For auctions (financial integrity), use explicit transactions:

```typescript
async placeBid(userId: string, auctionId: string, amountCents: number): Promise<Bid> {
  return this.dataSource.transaction(async (manager) => {
    // Lock the auction row to prevent concurrent bid race conditions
    const auction = await manager.findOne(Auction, {
      where: { id: auctionId },
      lock: { mode: 'pessimistic_write' },
    });

    if (!auction || auction.status !== AuctionStatus.ACTIVE) {
      throw new BadRequestException('Auction is not active');
    }

    if (amountCents < auction.currentPrice + auction.minIncrement) {
      throw new BadRequestException(
        `Minimum bid is ${auction.currentPrice + auction.minIncrement} cents`,
      );
    }

    // Create bid
    const bid = manager.create(Bid, { auctionId, userId, amountCents });
    await manager.save(bid);

    // Update auction current price
    auction.currentPrice = amountCents;
    await manager.save(auction);

    // Anti-sniping: extend if bid within last 2 minutes
    const twoMinutesFromNow = new Date(Date.now() + 2 * 60 * 1000);
    if (auction.endsAt < twoMinutesFromNow) {
      auction.endsAt = twoMinutesFromNow;
      await manager.save(auction);
    }

    return bid;
  });
}
```

### Analytics Event Model

For tracking user behaviour without impacting the main database:

```typescript
// EventBridge event structure
interface AnalyticsEvent {
  source: 'kuwboo-api';
  detailType: string;  // 'content.viewed', 'bid.placed', 'match.created'
  detail: {
    userId: string;
    moduleKey: ModuleScope;
    entityType: string;
    entityId: string;
    metadata: Record<string, unknown>;
    timestamp: string;
    sessionId: string;
  };
}
```

Route analytics events to:
- **SQS → Lambda → S3** for raw event storage (Parquet format)
- **Athena** for ad-hoc queries on the S3 data lake
- **QuickSight** for dashboards (if needed later)

At launch, `InteractionEvent` (append-only) serves as the analytics source. Move to EventBridge + S3 when event volume or query patterns outgrow PostgreSQL.

---

## Appendix A: Migration from Prisma to TypeORM

### Steps

1. Install TypeORM + NestJS integration:
   ```
   @nestjs/typeorm typeorm pg reflect-metadata
   ```

2. Remove Prisma:
   ```
   Remove: @prisma/client, prisma (devDep), prisma/ directory
   Remove: Fastify Prisma plugin
   ```

3. Create TypeORM entities matching Section 2 definitions

4. Configure TypeORM in NestJS app module:
   ```typescript
   TypeOrmModule.forRoot({
     type: 'postgres',
     host: process.env.DB_HOST,
     port: 5432,
     database: 'kuwboo',
     entities: [__dirname + '/**/*.entity{.ts,.js}'],
     synchronize: false,  // NEVER true in production
     migrations: [__dirname + '/migrations/*{.ts,.js}'],
     subscribers: [__dirname + '/**/*.subscriber{.ts,.js}'],
     logging: process.env.NODE_ENV === 'development',
   })
   ```

5. Generate initial migration from entities

6. Rewrite route handlers as NestJS controllers + services + repositories

### Estimated Effort

The current codebase has ~430 lines of business logic across 5 route files. Rewriting this in NestJS with proper separation of concerns (controller → service → repository) will expand the code but improve maintainability. Estimate: 3-5 days for the migration + entity creation. The Fastify → NestJS migration is the larger effort (framework change), not the Prisma → TypeORM change.

---

## Appendix B: Database Indexes

### Performance-Critical Indexes

```sql
-- Feed queries (most common query pattern)
CREATE INDEX idx_content_feed ON content (status, type, created_at DESC)
  WHERE status = 'ACTIVE';

-- Block lookups (every request)
CREATE INDEX idx_blocks_blocker ON blocks (blocker_id);
CREATE INDEX idx_blocks_blocked ON blocks (blocked_id);

-- Proximity queries (YoYo, location-based shop)
CREATE INDEX idx_content_location ON content USING GIST (location)
  WHERE location IS NOT NULL;
CREATE INDEX idx_users_location ON users USING GIST (last_location)
  WHERE last_location IS NOT NULL;

-- Auction queries (active auctions ending soon)
CREATE INDEX idx_auctions_active ON auctions (status, ends_at)
  WHERE status = 'ACTIVE';

-- Notification inbox
CREATE INDEX idx_notifications_user ON notifications (user_id, created_at DESC);
CREATE INDEX idx_notifications_unread ON notifications (user_id, read_at)
  WHERE read_at IS NULL;

-- Thread listing (conversation inbox)
CREATE INDEX idx_threads_activity ON threads (last_activity DESC);
CREATE INDEX idx_thread_participants_user ON thread_participants (user_id);

-- Connection lookups
CREATE INDEX idx_connections_from ON connections (from_user_id, context, status);
CREATE INDEX idx_connections_to ON connections (to_user_id, context, status);

-- Dating profile filtering
-- Note: age is derived from users.date_of_birth, not stored on dating_profiles.
-- Index on preference columns for range filtering; age filtering uses a JOIN to users.
CREATE INDEX idx_dating_profiles_active ON dating_profiles (status, preference_age_min, preference_age_max)
  WHERE status = 'ACTIVE';

-- Category tree
CREATE INDEX idx_categories_scope ON categories (scope, is_active, sort_order)
  WHERE is_active = true;

-- Content tags
CREATE INDEX idx_content_tags_content ON content_tags (content_id);
CREATE INDEX idx_content_tags_tag ON content_tags (tag_id);
```

---

*Document by LionPro Dev — February 17, 2026*
