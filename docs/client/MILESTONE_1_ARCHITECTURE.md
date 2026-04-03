# Kuwboo Platform — Technical Architecture Document

**Milestone 1 Deliverable**
**Date:** March 11, 2026
**Prepared for:** Neil Douglas / Guess This Ltd (UK)
**Prepared by:** Philip Cutting / LionPro Dev
**Version:** 1.0

---

## Executive Summary

This document describes the technical architecture for the Kuwboo platform rebuild. It covers every major system: the technology stack, database design, API structure, real-time communication, media handling, authentication, trust and safety, regulatory compliance, and cloud infrastructure.

The architecture is designed for Kuwboo's specific needs — a multi-module social platform with video feeds, a marketplace, social discovery, location-based features, and future dating — all sharing a common user base and infrastructure.

### Architecture at a Glance

```
┌──────────────────────────────────────────────────────────────────────┐
│  Mobile App (Flutter — iOS + Android)                                │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────┐  ┌─────────┐ │
│  │  Video   │  │  Social  │  │   Shop   │  │  YoYo  │  │Sponsored│ │
│  └──────────┘  └──────────┘  └──────────┘  └────────┘  └─────────┘ │
└─────────────────────────┬────────────────────────────────────────────┘
                          │  REST API + Socket.io
                          ▼
┌──────────────────────────────────────────────────────────────────────┐
│  Backend (NestJS — Single Process on EC2)                            │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌───────┐ ┌──────┐ ┌───────────┐│
│  │  Auth  │ │Content │ │  Feed  │ │  Chat │ │Media │ │   Admin   ││
│  │Module  │ │Module  │ │Module  │ │Module │ │Module│ │  Module   ││
│  └────────┘ └────────┘ └────────┘ └───────┘ └──────┘ └───────────┘│
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │  Shared: Guards, Pipes, Interceptors, Database, Jobs          │ │
│  └────────────────────────────────────────────────────────────────┘ │
└───────┬──────────────┬──────────────┬──────────────┬────────────────┘
        │              │              │              │
   ┌────▼────┐   ┌─────▼─────┐  ┌────▼────┐   ┌────▼────┐
   │PostgreSQL│   │   Redis   │  │   S3    │   │Firebase │
   │  (RDS)   │   │ (on EC2)  │  │+CloudFrt│   │  (FCM)  │
   └──────────┘   └───────────┘  └─────────┘   └─────────┘
```

### Key Decisions

| Decision | Choice | Why |
|----------|--------|-----|
| Mobile framework | Flutter | Single codebase for iOS + Android |
| Backend framework | NestJS | Modular architecture, TypeScript, built-in WebSocket support |
| Database | PostgreSQL 16 | PostGIS for location, full-text search, modern JSON support |
| ORM | MikroORM | Active maintenance, Unit of Work pattern, strong typing |
| API style | REST + OpenAPI 3.1 | Best Flutter code generation, CDN-cacheable |
| Real-time | Socket.io 4.x | Single connection for chat, presence, feed updates, marketplace events |
| Background jobs | BullMQ (on Redis) | Job queues, retries, scheduled tasks — runs on existing Redis |
| Push notifications | Firebase Cloud Messaging | Cross-platform iOS + Android push |
| Media storage | S3 + CloudFront | Direct uploads via presigned URLs, CDN delivery |
| Authentication | Custom JWT + Twilio OTP | Full control, phone-first authentication |

---

## Glossary

Technical terms used throughout this document:

| Term | Definition |
|------|-----------|
| **API** | Application Programming Interface — how the app communicates with the server |
| **BullMQ** | A job queue system that processes tasks in the background (e.g., sending push notifications, processing videos) |
| **CDN** | Content Delivery Network — servers around the world that cache media files close to users for faster loading |
| **CloudFront** | Amazon's CDN service |
| **CRUD** | Create, Read, Update, Delete — the four basic database operations |
| **EC2** | Amazon's virtual server service |
| **Entity** | A data object stored in the database (e.g., User, Video, Product) |
| **FCM** | Firebase Cloud Messaging — Google's push notification service for iOS and Android |
| **Flutter** | Google's framework for building iOS and Android apps from a single codebase |
| **JWT** | JSON Web Token — a secure digital key that proves a user is logged in |
| **MikroORM** | The Object-Relational Mapper that translates between TypeScript code and database tables |
| **NestJS** | A TypeScript server framework with a modular architecture |
| **OpenAPI** | A specification that describes the API so that the Flutter app can auto-generate its network code |
| **ORM** | Object-Relational Mapper — software that maps database tables to code objects |
| **OTP** | One-Time Password — the verification code sent via SMS during login |
| **pgvector** | A PostgreSQL extension for AI-powered search and recommendations |
| **PostGIS** | A PostgreSQL extension for geographic/location queries (used by YoYo) |
| **Presigned URL** | A temporary, secure link that allows the app to upload files directly to S3 without going through the server |
| **RDS** | Amazon's managed database service |
| **Redis** | An in-memory data store used for caching, real-time features, and job queues |
| **REST** | Representational State Transfer — a standard approach for building web APIs |
| **S3** | Amazon's file storage service |
| **Socket.io** | A library for real-time, bidirectional communication between the app and server |
| **STI** | Single Table Inheritance — a database pattern where related types share one table with a type column |
| **Unit of Work** | A pattern where the ORM batches multiple database changes into a single efficient operation |

---

## 1. Technology Stack

### Backend

| Layer | Technology | Role |
|-------|-----------|------|
| **Framework** | NestJS 11 | HTTP controllers, WebSocket gateways, dependency injection, guards and pipes shared across HTTP and WebSocket |
| **ORM** | MikroORM (Data Mapper pattern) | Entity management, Unit of Work, query builder, database migrations |
| **Database** | PostgreSQL 16 (RDS) | Primary data store with PostGIS for location queries, pgvector for recommendations, and LISTEN/NOTIFY for real-time triggers |
| **Real-time** | Socket.io 4.x | Bidirectional communication for chat, presence, feed updates, and marketplace events |
| **Cache & Pub/Sub** | Redis 7.2 (on EC2, ElastiCache at scale) | Socket.io adapter, BullMQ jobs, presence tracking, feed caching, block list caching |
| **Push** | Firebase Cloud Messaging (FCM) | Cross-platform push notifications for iOS and Android |
| **Jobs** | BullMQ (on Redis) | Background processing: push delivery, email, media processing, feed generation, trust score updates |
| **API** | REST + OpenAPI 3.1 | Primary API with auto-generated Flutter client code |
| **Media** | S3 + CloudFront | Presigned uploads (direct from app to S3), CDN delivery worldwide |
| **Email** | Amazon SES | Transactional emails (verification, password reset, auction alerts) |
| **Search** | PostgreSQL full-text search | Built-in search using `tsvector` and `pg_trgm` — no separate search service needed at launch scale |

### Mobile

| Layer | Technology | Role |
|-------|-----------|------|
| **Framework** | Flutter 3.x (Dart) | Single codebase for iOS and Android |
| **API Client** | Auto-generated from OpenAPI spec | Type-safe API calls with no manual network code |
| **Real-time** | Socket.io 4.x client | Chat, presence, live updates |
| **Auth Storage** | flutter_secure_storage | Keychain (iOS) / EncryptedSharedPreferences (Android) |
| **State Management** | TBD (likely Riverpod or Bloc) | Application state and UI reactivity |

### Why These Technologies

**NestJS** was chosen because its modular architecture maps naturally to Kuwboo's module structure (Video, Social, Shop, YoYo, etc.). Each module is a self-contained NestJS module with its own controllers, services, and entities, but they can share cross-cutting concerns like authentication and database access.

**MikroORM** was chosen over alternatives because of its Unit of Work pattern (batches database changes for efficiency), identity map (ensures consistency within a request), and active maintenance with regular releases. It integrates natively with NestJS.

**PostgreSQL** was chosen over MySQL because it offers PostGIS for YoYo's location queries, pgvector for AI-powered recommendations, full-text search without a separate service, and superior JSON support for flexible data.

**Socket.io** was chosen as the single real-time transport (rather than multiple protocols) because a single persistent connection reduces battery impact on mobile devices. Socket.io handles all real-time needs: chat messages, typing indicators, online presence, feed refresh signals, auction bid updates, and proximity data.

---

## 2. Database Architecture

### 2.1 Overview

The database contains **32 entities** (data objects) organised into six domains:

| Domain | Entities | Purpose |
|--------|----------|---------|
| **User** | User, DatingProfile, UserPreferences, UserConsent, Device | User identity, profiles, settings, consent tracking |
| **Content** | Content, Video, Product, Post, Event, WantedAd, Category, Tag, Media | All user-created content with type-specific fields |
| **Interaction** | InteractionState, InteractionEvent, Comment | Likes, views, bids, shares, swipes, comments |
| **Connection** | Connection, Block | Follows, friends, matches (per module), blocks |
| **Messaging** | Thread, Message, Notification | Chat, direct messaging, notification inbox |
| **Trust & Safety** | Report, TrustSignal, DeviceFingerprint, AuditEntry, ContentModerationResult | Moderation, trust scoring, safety pipeline |

### 2.2 Content Hierarchy

Kuwboo has multiple content types (videos, products, posts, events, wanted ads) that share common properties (creator, status, like count, comments) but also have type-specific data (video duration, product price, event date).

The architecture uses **Single Table Inheritance (STI)** — all content types share one database table with a `type` column that identifies what kind of content each row is. Type-specific columns (like `videoUrl` or `priceCents`) are only populated for the relevant content type.

```
Content (shared table)
├── Video         (type = 'VIDEO')       → videoUrl, durationSeconds, caption
├── Product       (type = 'PRODUCT')     → priceCents, condition, auctionEndTime
├── Post          (type = 'POST')        → body, subType (blog, notice, etc.)
├── Event         (type = 'EVENT')       → startDate, endDate, venue, capacity
└── WantedAd      (type = 'WANTED_AD')   → wantedType (lost, found, stolen)
```

**Why STI:** Feed queries are the core user experience — the feed must efficiently load mixed content types (videos, products, posts) in a single query. STI makes this a simple query against one table rather than joining across five separate tables.

**Performance:** At Kuwboo's projected scale (under 10 million content items), PostgreSQL handles STI tables efficiently. Type-specific columns that are empty for other types cost virtually nothing in storage.

### 2.3 Module Key Architecture

The module key system from the existing platform is carried forward. Shared infrastructure (chat, notifications, follows) serves multiple features via a `moduleKey` discriminator:

| Module Key | Feature | Content Types |
|-----------|---------|---------------|
| `video_making` | Video feed | Video |
| `buy_sell` | Marketplace | Product, WantedAd |
| `social_stumble` | Social discovery | Post, Event |
| `yoyo` | Nearby users | (Uses User + Location, not Content) |

This means:
- **Chat is shared** — the same messaging system serves all modules, with `moduleKey` tracking which feature a conversation belongs to
- **Follows can be per-module** — a user can follow someone's videos without seeing their marketplace listings
- **Categories are module-specific** — Video has 27 categories, Marketplace has 54 hierarchical categories
- **The feed combines content types** — a feed can show videos, products, and posts together, or filter by module

### 2.4 Key Entity Details

#### User

| Field | Type | Purpose |
|-------|------|---------|
| id | UUID | Unique identifier |
| username | String | Display name |
| phone | String | Phone number (primary login) |
| email | String (optional) | Email address |
| avatarUrl | String | Profile photo |
| dateOfBirth | Date | Age verification |
| trustScore | 0-100 | Platform-wide identity trust |
| socialReputation | 0-100 | Social behavior score |
| sellerReputation | 0-100 | Marketplace behavior score |
| ageVerificationStatus | Enum | UNVERIFIED / SELF_DECLARED / PROVIDER_VERIFIED |
| status | Enum | ACTIVE / SUSPENDED / BANNED / DEACTIVATED |

#### Content (Base)

| Field | Type | Purpose |
|-------|------|---------|
| id | UUID | Unique identifier |
| type | Enum | VIDEO / PRODUCT / POST / EVENT / WANTED_AD |
| creatorId | UUID → User | Who created it |
| status | Enum | DRAFT / PENDING / ACTIVE / HIDDEN / FLAGGED / REMOVED |
| visibility | Enum | PUBLIC / CONNECTIONS / PRIVATE |
| tier | Enum | FREE / MEMBER / VIP / BOOSTED |
| categoryId | UUID → Category | Content category |
| likeCount | Integer | Cached counter |
| commentCount | Integer | Cached counter |
| viewCount | Integer | Cached counter |
| shareCount | Integer | Cached counter |
| moderationScore | Float | Automated content safety score |

#### Interaction System

Interactions are split into two types to handle different behaviors correctly:

| Type | Pattern | Examples |
|------|---------|---------|
| **InteractionState** | Toggle (on/off), one per user per content | Like, Save |
| **InteractionEvent** | Append-only log, multiple per user | View, Share, Bid, Swipe |

This distinction matters because a like is a toggle (you either like something or you don't), but bids are cumulative (a user can bid multiple times on an auction).

#### Block (Separate from Connections)

Blocks are stored in their own table, separate from follows and friends, because block checks happen on every single request (feed queries, search results, chat lookups). A dedicated table with proper indexes makes these checks fast.

#### Media

Every uploaded file (photo, video, audio) is tracked as a Media entity with:
- Upload status (uploading → processing → ready → failed)
- S3 storage key
- File type, size, dimensions, duration
- Thumbnail URL (auto-generated)

This enables storage quota enforcement, orphan cleanup, and GDPR-compliant deletion (enumerate all media by user).

### 2.5 State Machines

Key entities follow defined lifecycle states, preventing invalid transitions:

#### Content Lifecycle

```
DRAFT → PENDING → ACTIVE → HIDDEN
                    ↓         ↓
                 FLAGGED → REMOVED
```

> A content item starts as a draft, moves to pending when submitted, becomes active after moderation, and can be hidden by the creator or removed by moderators. Flagged content is under review.

#### Auction Lifecycle

```
DRAFT → SCHEDULED → LIVE → CLOSED → SETTLED
                      ↓
                   CANCELLED
```

> An auction moves from draft through scheduling, goes live at the start time, closes at the end time, and settles when payment is confirmed.

#### Report Lifecycle

```
NEW → UNDER_REVIEW → ACTION_TAKEN
                   → DISMISSED
```

> Reports from users enter as new, are reviewed by moderators, and result in either action (content removal, user warning/ban) or dismissal.

---

## 3. API Architecture

### 3.1 REST + OpenAPI

The API follows REST conventions with an OpenAPI 3.1 specification automatically generated from the NestJS code. This specification is used to auto-generate the Flutter app's network layer — eliminating manual API integration code and ensuring the app always matches the server's interface.

**API module structure:**

| Path Prefix | Module | Description |
|-------------|--------|-------------|
| `/auth/*` | Authentication | Login, register, refresh token, social login |
| `/users/*` | Users | Profiles, preferences, settings, search |
| `/content/*` | Content | CRUD for videos, products, posts, events |
| `/feed/*` | Feed | Personalised feed assembly with filters |
| `/connections/*` | Connections | Follow, friend, match, block |
| `/threads/*` | Messaging | Chat threads, messages, read receipts |
| `/media/*` | Media | Presigned upload URLs, processing status |
| `/notifications/*` | Notifications | Notification inbox, read/unread, preferences |
| `/categories/*` | Categories | Browse and search categories |
| `/moderation/*` | Moderation | Report submission, admin review queue |
| `/admin/*` | Admin | User management, content moderation, analytics |

### 3.2 Request/Response Patterns

All API responses follow a consistent structure:

```json
{
  "data": { ... },
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 142
  }
}
```

Error responses include a machine-readable code and human-readable message:

```json
{
  "statusCode": 400,
  "error": "VALIDATION_ERROR",
  "message": "Price must be a positive number"
}
```

### 3.3 Pagination

All list endpoints use cursor-based pagination for consistent results even when new content is being added. The cursor is an opaque token that the app sends back to request the next page.

---

## 4. Real-Time Architecture

### 4.1 Socket.io

A single Socket.io connection handles all real-time features. When a user opens the app, one persistent connection is established and used for everything:

| Feature | Socket.io Usage |
|---------|----------------|
| **Chat** | Send/receive messages, typing indicators, read receipts |
| **Presence** | Online/offline status, last seen timestamps |
| **Feed updates** | New content notifications, like/comment counters |
| **Marketplace** | Bid updates, auction ending alerts |
| **YoYo** | Nearby user coordinate exchange |
| **Notifications** | Real-time notification delivery |

**Why one connection:** Mobile devices have limited battery and network resources. A single Socket.io connection (which automatically handles reconnection, fallback transports, and heartbeats) is more battery-efficient than maintaining multiple separate connections.

### 4.2 Presence System

The presence system tracks which users are currently online:

| State | Meaning | Stored In |
|-------|---------|-----------|
| **Online** | App is open, Socket.io connected | Redis (with TTL) |
| **Away** | App is backgrounded (no Socket.io) | Redis (last seen timestamp) |
| **Offline** | App is closed | Database (last seen timestamp) |

Presence data is stored in Redis for fast lookups. When a user goes offline, their last-seen timestamp is written to the database for persistent display (e.g., "Last seen 2 hours ago").

### 4.3 Chat and Messaging

Chat uses a thread-based model:

- **Thread** — a conversation between two or more users, scoped to a module (e.g., a marketplace inquiry vs. a social chat)
- **Message** — an individual message within a thread, supporting text, images, video, and location sharing

Messages are delivered in real-time via Socket.io when the recipient is online, and via push notification (Firebase Cloud Messaging) when they are offline.

**Typing indicators** are ephemeral events sent via Socket.io — they are not stored in the database.

**Read receipts** are tracked per-user per-thread, updating the last-read message timestamp.

### 4.4 Battery Optimisation

The architecture includes specific strategies for mobile battery life:

| Strategy | Description |
|----------|-------------|
| **Connection reuse** | Single Socket.io connection for all real-time features |
| **Event batching** | Low-priority events (view counts, like counters) are batched and delivered periodically rather than instantly |
| **Exponential backoff** | If the connection drops, reconnection attempts start at 1 second and increase to a maximum of 30 seconds |
| **Background throttling** | When the app is backgrounded, real-time updates pause; push notifications take over |

---

## 5. Media Pipeline

### 5.1 Upload Flow

Media uploads bypass the backend server entirely for performance:

```
1. App requests a presigned upload URL from the API
2. API generates a secure, time-limited URL pointing to S3
3. App uploads the file directly to S3 using the presigned URL
4. S3 triggers a processing job (via Lambda or BullMQ)
5. Processing generates thumbnails, transcodes video, scans content
6. Media entity status updated: UPLOADING → PROCESSING → READY
7. App is notified via Socket.io that the media is ready
```

**Why presigned URLs:** Uploading directly to S3 means large files (photos, videos) don't consume backend server bandwidth or memory. The server only handles the lightweight API call to generate the URL.

### 5.2 Video Processing

Videos are transcoded using AWS MediaConvert:
- Input: Raw video from user's device
- Output: Optimised MP4 for streaming
- Thumbnails are extracted automatically
- Processing status is tracked in the Media entity

### 5.3 Image Processing

Photos are processed for:
- Thumbnail generation (multiple sizes for feed, profile, detail views)
- Content safety scanning (automated moderation)
- EXIF data stripping (privacy — removes location data from photos)

### 5.4 CDN Delivery

All media is served through CloudFront (Amazon's CDN), which caches files at edge locations worldwide. Users load media from the nearest edge location rather than the origin server in London.

---

## 6. Authentication and Security

### 6.1 Authentication Flow

Kuwboo uses phone-first authentication:

```
1. User enters phone number
2. Server sends OTP via Twilio SMS
3. User enters the OTP code
4. Server verifies the code and issues:
   - Access token (JWT, short-lived — used for API requests)
   - Refresh token (long-lived — used to get new access tokens)
5. App stores tokens in secure storage (Keychain / EncryptedSharedPreferences)
```

**Token refresh rotation:** When the access token expires, the app uses the refresh token to get a new pair. The old refresh token is invalidated. This means a stolen token can only be used once before it stops working.

### 6.2 Social Login

Users can also authenticate via:
- Google (OAuth 2.0)
- Apple Sign-In
- Facebook Login

Social login creates or links to an existing account based on the user's email address.

### 6.3 Security Measures

| Measure | Description |
|---------|-------------|
| **Rate limiting** | API endpoints are rate-limited to prevent brute-force attacks (e.g., OTP guessing) |
| **Input validation** | All user input is validated and sanitised before processing |
| **CORS** | Only allowed origins can make API requests |
| **Helmet** | Standard HTTP security headers (CSP, X-Frame-Options, etc.) |
| **Credential management** | All secrets stored in AWS Secrets Manager (not in code or environment files) |
| **Encryption at rest** | Database and S3 storage are encrypted |
| **Encryption in transit** | All communication uses HTTPS/WSS (TLS) |

---

## 7. Trust and Safety

### 7.1 Trust Score Engine

Every user has a **trust score** (0-100) that measures how confident the platform is that they are a real, unique person. This is not a "good user" score — it's an identity verification score.

#### How Trust is Earned

| Signal | Points | How |
|--------|--------|-----|
| Mobile phone number | +40 | Verified via carrier lookup (mobile SIM cards are harder to fake than VoIP numbers) |
| Selfie verification | +30 | Photo of user's face matched against profile photos |
| Device consistency | +15 | Same device used for 7+ days (real users don't switch devices constantly) |
| Email verified | +10 | Email address confirmed via link click |
| Account age | +5 | Account older than 30 days |

#### How Trust is Lost

| Signal | Points | Trigger |
|--------|--------|---------|
| VoIP phone number | -20 | Phone identified as a virtual number (commonly used by fraudsters) |
| Upheld report | -40 | Moderator confirms a report against the user |
| Dormancy | -10 | No activity for 30+ days |

#### What Trust Scores Control

| Score Range | Label | Platform Behaviour |
|-------------|-------|-------------------|
| **0-30** | High Risk | Limited daily actions, mandatory photo verification for dating, increased moderation priority |
| **30-60** | Medium | Standard limits, prompted to complete verification |
| **60-100** | Trusted | Full feature access, higher limits, eligible for "Verified" badge |

### 7.2 Reputation Scores

In addition to the base trust score, users have module-specific reputation scores:

| Score | Modules | Based On |
|-------|---------|---------|
| **Social Reputation** (0-100) | Video, Social, Dating | Response rate, conversation quality, block/report rate |
| **Seller Reputation** (0-100) | Marketplace | Transaction completion, buyer ratings, dispute rate |

**Why separate scores:** A marketplace scammer might have decent social interactions. Separate scores prevent gaming one module to gain trust in another.

### 7.3 Safety Pipeline

The safety system actively monitors for bad actors through multiple signals:

| Signal Source | What's Checked | Action |
|--------------|----------------|--------|
| **Phone verification** | Carrier type (mobile vs. VoIP), known fraud numbers | VoIP accounts get reduced trust |
| **Device fingerprint** | Device consistency, multiple accounts per device | Flag for review if patterns match banned users |
| **Behaviour monitoring** | Rapid account creation, suspicious messaging patterns | Automatic throttling or flagging |
| **Photo authenticity** | Liveness detection, face-to-profile matching | Required for dating module |
| **Content scanning** | Automated moderation on upload | Block or flag inappropriate content |

### 7.4 Anti-Ban-Evasion

When a user is banned, the system tracks signals to detect if they create a new account:
- Device fingerprint matching
- Phone number carrier matching
- IP and geographic clustering
- Behavioral pattern matching

New accounts that match banned user profiles are automatically flagged for review.

---

## 8. Regulatory Compliance

Kuwboo is operated by a UK company (Guess This Ltd) and will serve users in both the UK and USA. This triggers several regulatory frameworks that are built into the architecture from day one.

### 8.1 UK Regulations

| Regulation | What It Requires | How We Comply |
|-----------|------------------|---------------|
| **Online Safety Act 2023** | Proactive scanning for illegal content; age assurance; user empowerment tools | Automated content scanning on upload; age verification at registration; content filter preferences |
| **UK GDPR / DPA 2018** | Consent tracking; right to erasure; data portability; data minimisation | UserConsent entity tracks all consents; deletion workflow removes all user data; export endpoint for portability |
| **ICO Age Appropriate Design Code** | Platforms likely accessed by children must implement age-appropriate design | Age verification at registration; restricted features for under-18 users; high privacy defaults |
| **Consumer Rights Act 2015** | Distance selling rules for marketplace | Seller verification; clear pricing; dispute resolution workflow |

### 8.2 USA Regulations

| Regulation | What It Requires | How We Comply |
|-----------|------------------|---------------|
| **COPPA** | Parental consent for under-13 users; no data collection without consent | Hard age gate — under-13 users cannot register |
| **CCPA/CPRA** | California users can opt out of data sale; right to deletion | Opt-out consent type; deletion workflow |
| **State Dating App Safety Laws** | Background checks, safety notices for dating features (IL, CT, NV) | Safety notices in dating module; sex offender registry check integration (phased) |
| **BIPA** | Biometric consent required for photo verification (Illinois users) | Explicit biometric consent flow before selfie verification |
| **DMCA** | Takedown process for copyrighted content | DMCA notice and counter-notification workflow |

### 8.3 Built-In Compliance Architecture

Rather than bolting compliance on later, the following are part of the core schema:

| Entity | Purpose |
|--------|---------|
| **UserConsent** | Tracks every consent given or withdrawn (type, version, timestamp, IP address) |
| **AuditEntry** | Immutable log of significant actions (account changes, content moderation, data access) |
| **ContentModerationResult** | Records automated and human moderation decisions with confidence scores |
| **User.ageVerificationStatus** | Tracks verification level (self-declared, provider-verified) |
| **User.dateOfBirth** | Enables age-gating for dating (18+) and general age assurance |

---

## 9. Infrastructure

### 9.1 AWS Topology

All infrastructure runs in AWS London (eu-west-2) for UK data residency compliance.

| Resource | Specification | Purpose |
|----------|--------------|---------|
| **EC2** | t3.medium (2 vCPU, 4 GB RAM) | API server, Redis, Nginx |
| **RDS PostgreSQL 16** | db.t3.micro, 20 GB (auto-scales to 100 GB) | Primary database |
| **Redis** | On EC2 (localhost) | Cache, real-time adapter, job queues |
| **S3** | Standard storage | Media files |
| **CloudFront** | Global CDN | Media delivery |
| **Secrets Manager** | Managed secrets | Database credentials, JWT secrets, API keys |
| **SES** | Transactional email | Verification emails, auction alerts |

#### Network Design

The infrastructure uses a dedicated VPC (Virtual Private Cloud) with public and private subnets across three availability zones:

- **Public subnets** (3): EC2 API server (internet-facing)
- **Private subnets** (3): RDS database (no direct internet access)
- **Security groups**: API server accepts HTTP/HTTPS; database only accepts connections from the API server

### 9.2 Monthly Cost

| Service | Monthly Cost |
|---------|-------------|
| EC2 (t3.medium) | ~$30 |
| RDS PostgreSQL | ~$15-23 |
| Secrets Manager | ~$5 |
| Route 53 (DNS) | ~$2 |
| S3 + CloudFront | Usage-based (~$1-5) |
| **Total** | **~$52-65** |

This compares to ~$137/month for the legacy infrastructure — a reduction of approximately 55%.

### 9.3 Scaling Strategy

The architecture is designed to scale incrementally as the user base grows:

| Trigger | Action | Cost Impact |
|---------|--------|-------------|
| CPU > 70% sustained | Upgrade EC2 (t3.medium → t3.large) | +$30/month |
| Redis memory > 2 GB | Move to ElastiCache | +$40/month |
| Database connections > 80% | Upgrade RDS instance | +$15-30/month |
| Global users | Add CloudFront origins | Usage-based |
| 100K+ concurrent users | Add load balancer + auto-scaling group | Architecture change |

**Current target:** The t3.medium instance comfortably handles up to approximately 10,000 concurrent users. Scaling decisions are data-driven — we monitor actual usage and scale when thresholds are hit, not speculatively.

### 9.4 Monitoring

| What's Monitored | How | Alert Threshold |
|------------------|-----|-----------------|
| Server CPU and memory | CloudWatch | CPU > 70% for 15 minutes |
| API response times | Application metrics | p95 > 500ms |
| Database connections | CloudWatch | > 80% of max connections |
| Error rates | Application logging | Error rate > 1% |
| Disk usage | CloudWatch | > 80% used |
| SSL certificate expiry | Automated check | < 14 days |

### 9.5 Disaster Recovery

| Component | Backup Strategy | Recovery Time |
|-----------|----------------|---------------|
| Database | Automated daily snapshots, 7-day retention | < 1 hour |
| Media (S3) | S3 versioning enabled | Immediate |
| Application code | Git repository | < 30 minutes (redeploy) |
| Configuration | Secrets Manager (versioned) | Immediate |

---

## 10. Design System

The Kuwboo design system uses the **Urban Warmth** aesthetic — a clean, modern feel with warm tones and urban energy, as agreed during the design review process.

### Design Deliverables (Milestone 1)

| Deliverable | Status |
|-------------|--------|
| Design system (typography, colours, spacing, components) | Complete |
| Interactive prototype (56 screens across all modules) | Complete |
| Design review with client feedback incorporated | Complete |

### Screen Coverage

The interactive prototype covers all five core modules:

| Module | Screens | Coverage |
|--------|---------|---------|
| Authentication | 11 | Login, registration, OTP, onboarding |
| Video Making | 7 | Feed, creation, profile, discovery |
| Dating | 7 | Profiles, swipe, matches, settings |
| Social | 6 | Feed, friends, events, discovery |
| Shop (Buy & Sell) | 7 | Browse, listings, auction, seller profile |
| YoYo | 7 | Nearby, map, distance view, settings |
| Chat | 2 | Thread list, conversation |
| Profile | 4 | View, edit, settings, preferences |
| Sponsored | 4 | Creation, management, analytics |

---

## 11. Background Job Processing

Several operations are too slow or too complex to handle during an API request. These are processed asynchronously using BullMQ job queues:

| Queue | Purpose | Priority |
|-------|---------|----------|
| **push-notification** | Deliver push notifications via FCM | High |
| **media-processing** | Generate thumbnails, transcode video | High |
| **content-moderation** | Automated content safety scanning | High |
| **trust-score-recalc** | Recalculate user trust scores when signals change | Medium |
| **email** | Send transactional emails via SES | Medium |
| **feed-generation** | Pre-compute personalised feeds | Medium |
| **embedding-generation** | Generate pgvector embeddings for recommendations | Low |
| **phone-carrier-lookup** | Classify phone numbers via Twilio | Low |
| **cleanup** | Remove expired tokens, orphaned uploads | Low (scheduled) |

Jobs that fail are automatically retried with exponential backoff. After maximum retries, failed jobs are moved to a dead-letter queue for manual review.

---

## 12. Sign-Off

This Technical Architecture Document describes the system design for the Kuwboo platform rebuild. It covers the technology stack, database schema, API structure, real-time communication, media handling, authentication, trust and safety, regulatory compliance, and cloud infrastructure.

This document satisfies the Milestone 1 deliverable: *"Technical architecture document (database schema, API structure, infrastructure plan)"* as defined in the project contract.

By signing below, the client acknowledges review and approval of the technical architecture described in this document.

| | Client | Contractor |
|---|--------|------------|
| **Name** | Neil Douglas | Philip Cutting |
| **Entity** | Guess This Ltd | LionPro Dev |
| **Date** | _________________ | _________________ |
| **Signature** | _________________ | _________________ |

---

*LionPro Dev — Milestone 1: Design & Architecture*
*March 2026*
