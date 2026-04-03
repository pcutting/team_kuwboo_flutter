# Kuwboo: Real-Time Architecture

**Created:** March 3, 2026
**Version:** 1.0
**Purpose:** Developer-facing real-time architecture and technology integration guide
**Audience:** Phil Cutting (LionPro Dev) — implementation guide
**Status:** Greenfield rebuild — no legacy data, no migration constraints

**Companion Documents:**
- [TECHNICAL_DESIGN.md](./TECHNICAL_DESIGN.md) — 32-entity schema, ORM evaluation, feed architecture, state machines
- [REGULATORY_REQUIREMENTS.md](./REGULATORY_REQUIREMENTS.md) — UK + USA regulatory compliance architecture
- [../FEATURE_ARCHITECTURE.md](../FEATURE_ARCHITECTURE.md) — client-facing feature overview for Neil
- [TRUST_ENGINE.md](./TRUST_ENGINE.md) — trust scoring, visibility tiers, recommendation engine (adds BullMQ queues, extends pgvector usage)
- [SAFETY_PIPELINE.md](./SAFETY_PIPELINE.md) — behavior monitoring, ban evasion detection (extends pgvector with behavioral embeddings)
- [INFRASTRUCTURE.md](./INFRASTRUCTURE.md) — deployment, monitoring, scaling, operational runbooks

---

## How to Read This Document

TECHNICAL_DESIGN.md defines *what* the schema looks like and *why* each technology was chosen. This document defines *how* those technologies integrate at runtime — specifically:

- **How** MikroORM replaces the TypeORM entities defined in TECHNICAL_DESIGN.md (Section 1)
- **How** real-time events flow between clients, Socket.io, Redis, and PostgreSQL (Sections 2-4)
- **How** the mobile clients manage battery life while staying connected (Section 5)
- **How** pgvector embeddings power search, recommendations, and safety (Section 6)
- **How** background jobs process async work without blocking the request cycle (Section 7)
- **How** notifications reach users whether online or offline (Section 8)
- **How** AWS infrastructure supports all of the above (Section 9)

Sections are numbered 1-9. Cross-references to TECHNICAL_DESIGN.md use the format "TDD Section N" (e.g., TDD Section 2 = Section 2: Recommended Schema).

---

## Table of Contents

- [Section 1: Stack Overview and MikroORM Adaptation](#section-1-stack-overview-and-mikroorm-adaptation)
- [Section 2: Real-Time Architecture](#section-2-real-time-architecture)
- [Section 3: Event Flow Patterns](#section-3-event-flow-patterns)
- [Section 4: Presence System Design](#section-4-presence-system-design)
- [Section 5: Battery Optimization Strategy](#section-5-battery-optimization-strategy)
- [Section 6: pgvector Integration](#section-6-pgvector-integration)
- [Section 7: Background Job Processing](#section-7-background-job-processing)
- [Section 8: Notification System](#section-8-notification-system)
- [Section 9: Infrastructure (AWS)](#section-9-infrastructure-aws)

---

## Section 1: Stack Overview and MikroORM Adaptation

### Complete Stack

| Layer | Choice | Integration Role |
|-------|--------|-----------------|
| **Framework** | NestJS | HTTP controllers, WebSocket gateways, DI container, guards/pipes shared across HTTP + WS |
| **ORM** | MikroORM (Data Mapper) | Entity management, Unit of Work, query builder, migrations |
| **Database** | PostgreSQL 16 (RDS) | Primary data store, LISTEN/NOTIFY for real-time, pgvector for embeddings, PostGIS for proximity |
| **Real-time** | Socket.io 4.x | Bidirectional communication for chat, presence, feed updates, marketplace events |
| **State/Cache/PubSub** | Redis (ElastiCache) | Socket.io adapter, presence tracking, BullMQ jobs, feed caching, block list caching |
| **Push Notifications** | Firebase Cloud Messaging | Cross-platform push for iOS + Android when app is backgrounded/killed |
| **Background Jobs** | BullMQ (on Redis) | Async processing: push delivery, email, media processing, feed generation, embeddings |
| **API Style** | REST + OpenAPI 3.1 | Primary API for CRUD operations, generated Flutter client via openapi_generator |
| **Media** | S3 + CloudFront | Presigned upload URLs, CDN delivery, Lambda triggers for processing |

### Divergences from TECHNICAL_DESIGN.md

This document makes several architectural changes from what TECHNICAL_DESIGN.md specified. Each is documented here for traceability:

| TDD Specified | Changed To | Rationale | Section |
|--------------|-----------|-----------|---------|
| **TypeORM** (Data Mapper, CTI) | **MikroORM** (Data Mapper, STI) | UoW pattern, identity map, active maintenance outweigh CTI convenience | Section 1 |
| **Class Table Inheritance** (6 tables for content) | **Single Table Inheritance** (1 table with discriminator) | MikroORM does not support CTI natively; STI simplifies feed queries | Section 1 |
| **3 real-time transports** (SSE + Socket.io + raw WS) | **Socket.io 4.x only** | Single connection reduces battery impact on mobile; Socket.io handles all use cases adequately | Section 2 |
| **SNS Mobile Push** for push notifications | **Firebase Cloud Messaging** (FCM) | Direct FCM integration is simpler for iOS + Android with Flutter. SNS adds a layer between the app and FCM/APNs without meaningful benefit at Kuwboo's scale. FCM handles token lifecycle, topic subscriptions, and data messages natively. SNS is better suited for multi-channel fan-out (SMS + email + push) which is not needed here. | Section 8 |
| **EventBridge + SQS** for event bus | **BullMQ on Redis** | Redis is already required for Socket.io adapter and presence. BullMQ provides job queues, retry logic, DLQs, and scheduled/repeatable jobs on the same Redis instance — no additional AWS service to manage. EventBridge + SQS is the right pattern for microservice event routing; for a modular monolith where all modules share a process, BullMQ's in-process queues are simpler and cheaper. | Section 7 |

### Why MikroORM Instead of TypeORM

TECHNICAL_DESIGN.md (Section 0a) recommended TypeORM based on its CTI support, PostGIS types, and entity subscribers. Since that evaluation, the decision has shifted to MikroORM for these reasons:

| Factor | TypeORM | MikroORM | Winner |
|--------|---------|----------|--------|
| **Maintenance** | Sporadic releases, long-standing bugs unfixed | Active development, responsive maintainer, regular releases | MikroORM |
| **Unit of Work** | No UoW — each save() is an immediate DB call | True UoW pattern — batches changes, single flush() | MikroORM |
| **Identity Map** | None — same entity loaded twice creates two objects | Built-in — ensures entity identity consistency within a request | MikroORM |
| **NestJS integration** | @nestjs/typeorm — mature but reflects TypeORM's limitations | @mikro-orm/nestjs — first-class module with request-scoped EntityManager | MikroORM |
| **Query Builder** | Powerful but returns any for complex queries | Strongly typed QueryBuilder with proper return types | MikroORM |
| **PostGIS** | First-class geography column type | Custom type support — requires a PointType implementation | TypeORM |
| **CTI** | Native @TableInheritance() + @ChildEntity() | STI only (native), CTI via composition pattern | TypeORM |
| **Lifecycle hooks** | Entity subscribers (@EventSubscriber()) | Entity hooks (@BeforeCreate, @AfterUpdate, etc.) + subscribers | Tie |

**Net assessment:** MikroORM's UoW, identity map, and active maintenance outweigh TypeORM's CTI convenience. The content hierarchy requires a different modeling approach (see below).

### Content Inheritance: MikroORM Adaptation

TECHNICAL_DESIGN.md specifies Class Table Inheritance for the content hierarchy (Content -> Video, Product, Post, Event, WantedAd). MikroORM does not support CTI natively. Three options were evaluated:

#### Option A: Single Table Inheritance (STI) with Discriminator

```typescript
@Entity({ discriminatorColumn: 'type', discriminatorMap: {
  VIDEO: 'Video',
  PRODUCT: 'Product',
  POST: 'Post',
  EVENT: 'Event',
  WANTED_AD: 'WantedAd',
}})
export class Content {
  @PrimaryKey({ type: 'uuid', defaultRaw: 'gen_random_uuid()' })
  id: string;

  @Enum(() => ContentType)
  type: ContentType;

  // ... shared fields (creatorId, visibility, tier, status, counters, etc.)
}

@Entity({ discriminatorValue: 'VIDEO' })
export class Video extends Content {
  @Property()
  videoUrl: string;

  @Property()
  durationSeconds: number;

  @Property({ nullable: true })
  caption?: string;
  // Video-only columns — nullable in the shared table
}
```

**Trade-offs:**
- All content in one table — simpler queries, JOINs, and feed assembly
- Nullable columns for type-specific fields (e.g., videoUrl is null for Products)
- Wider table, but PostgreSQL handles sparse columns efficiently (null storage is 1 bit in the null bitmap)
- At Kuwboo's expected scale (less than 10M rows), STI performs well
- Feed queries are simpler — no multi-table JOINs needed

#### Option B: Composition (1:1 Relations)

```typescript
@Entity()
export class Content {
  @PrimaryKey({ type: 'uuid', defaultRaw: 'gen_random_uuid()' })
  id: string;

  @OneToOne(() => VideoDetails, vd => vd.content, { nullable: true })
  videoDetails?: VideoDetails;

  @OneToOne(() => ProductDetails, pd => pd.content, { nullable: true })
  productDetails?: ProductDetails;
  // ... etc.
}

@Entity()
export class VideoDetails {
  @PrimaryKey({ type: 'uuid', defaultRaw: 'gen_random_uuid()' })
  id: string;

  @OneToOne(() => Content)
  content: Content;

  @Property()
  videoUrl: string;
  // ... video-specific columns
}
```

**Trade-offs:**
- Closer to CTI in spirit — each type has its own table with typed, indexed columns
- Feed queries require LEFT JOINs across all detail tables
- More complex query assembly
- Better column typing — videoUrl is NOT NULL on video_details

#### Option C: Polymorphic Embeddables (MikroORM-specific)

MikroORM supports polymorphic embeddables where a discriminator selects the embedded type. However, embeddables do not support relations or separate table storage — they are JSON columns or inline fields. Not suitable for queryable typed columns.

#### Decision: STI with Discriminator (Option A)

**Rationale:**
1. **Feed query simplicity.** The feed is the core user experience (TDD Section 4). STI means `SELECT * FROM content WHERE type IN ('VIDEO', 'POST') AND status = 'ACTIVE'` — no JOINs. Composition would require 5 LEFT JOINs on every feed query.
2. **MikroORM's STI is well-supported.** Discriminator maps, proper typing, automatic filtering by subclass.
3. **Scale-appropriate.** At Kuwboo's projected scale (sub-10M content items), the wider table is not a bottleneck. PostgreSQL's TOAST mechanism handles large text columns efficiently, and null columns cost essentially nothing.
4. **Indexing works.** Type-specific columns can have partial indexes: `CREATE INDEX idx_product_price ON content (price_cents) WHERE type = 'PRODUCT'`. This gives the same query performance as CTI for filtered lookups.
5. **Simpler real-time events.** When a content item changes, one table to watch, one LISTEN/NOTIFY trigger, one event shape.

**Mitigation for nullable columns:** MikroORM's discriminator ensures that Video entities always have videoUrl populated (enforced at the application layer). TypeScript narrowing via the discriminator means you always work with the correct subclass type.

### How MikroORM Entities Map to TDD Section 2

The 32 entities from TECHNICAL_DESIGN.md map to MikroORM as follows:

| TDD Entity | MikroORM Strategy | Notes |
|-----------|-------------------|-------|
| Content (base) | @Entity with discriminatorColumn: 'type' | STI root |
| Video | @Entity with discriminatorValue: 'VIDEO', extends Content | |
| Product | @Entity with discriminatorValue: 'PRODUCT', extends Content | |
| Post | @Entity with discriminatorValue: 'POST', extends Content | |
| Event | @Entity with discriminatorValue: 'EVENT', extends Content | |
| WantedAd | @Entity with discriminatorValue: 'WANTED_AD', extends Content | |
| Auction | Standard @Entity, @OneToOne to Product content | |
| Bid | Standard @Entity, @ManyToOne to Auction | |
| User | Standard @Entity | |
| UserPreferences | Standard @Entity, @OneToOne to User | |
| YoyoSettings | Standard @Entity, @OneToOne to User | |
| YoyoOverride | Standard @Entity | |
| Session | Standard @Entity, @ManyToOne to User | |
| Device | Standard @Entity, @ManyToOne to User | |
| DatingProfile | Standard @Entity, @OneToOne to User | NOT in content hierarchy |
| Connection | Standard @Entity | FOLLOW, FRIEND, MATCH, YOYO |
| Block | Standard @Entity | Separate from Connection |
| Thread | Standard @Entity | With moduleKey |
| ThreadParticipant | Standard @Entity | Join table |
| Message | Standard @Entity, @ManyToOne to Thread | |
| InteractionState | Standard @Entity | Idempotent toggles (LIKE, SAVE) |
| InteractionEvent | Standard @Entity | Append-only log (VIEW, BID, SHARE, SWIPE) |
| Comment | Standard @Entity | |
| Media | Standard @Entity | |
| Category | Standard @Entity with self-referencing parent | Materialized path for hierarchy |
| Tag | Standard @Entity | |
| ContentTag | Standard @Entity | Join table |
| AudioTrack | Standard @Entity | |
| Notification | Standard @Entity | |
| Report | Standard @Entity with split FK columns | |
| AuditEntry | Standard @Entity | Append-only |
| UserConsent | Standard @Entity | GDPR/CCPA tracking |

### PostGIS with MikroORM

MikroORM requires a custom type for PostGIS geography columns:

```typescript
import { Type, Platform } from '@mikro-orm/core';

export class PointType extends Type<
  { lat: number; lng: number } | null,
  string | null
> {
  convertToDatabaseValue(
    value: { lat: number; lng: number } | null,
    platform: Platform,
  ): string | null {
    if (!value) return null;
    return `SRID=4326;POINT(${value.lng} ${value.lat})`;
  }

  convertToJSValue(
    value: string | null,
    platform: Platform,
  ): { lat: number; lng: number } | null {
    if (!value) return null;
    const match = value.match(/POINT\(([^ ]+) ([^ ]+)\)/);
    if (!match) return null;
    return { lng: parseFloat(match[1]), lat: parseFloat(match[2]) };
  }

  getColumnType(): string {
    return 'geography(Point, 4326)';
  }
}
```

Usage on entities:

```typescript
@Entity()
export class User {
  @Property({ type: PointType, nullable: true })
  lastLocation?: { lat: number; lng: number };
}
```

Proximity queries use MikroORM's QueryBuilder with raw SQL fragments:

```typescript
qb.andWhere(
  'ST_DWithin(u.last_location, ST_MakePoint(?, ?)::geography, ?)',
  [lng, lat, radiusMeters],
);
```

---

## Section 2: Real-Time Architecture

### Transport Strategy

TECHNICAL_DESIGN.md (Section 0d) originally specified three transports (SSE, Socket.io, raw WebSocket). This has been simplified to **Socket.io 4.x as the single real-time transport**, with Firebase Cloud Messaging for offline push.

**Why consolidate to Socket.io only:**

| Original Transport | Original Use Case | Why Socket.io Handles It |
|-------------------|-------------------|-------------------------|
| SSE | Notifications, bid updates | Socket.io supports server-push via emit(). SSE adds a second connection to manage. |
| Socket.io | Chat, presence | Already needed. Rooms, acknowledgements, reconnection. |
| Raw WebSocket | YoYo proximity coordinates | Socket.io's binary support handles coordinate payloads efficiently. The overhead difference vs raw WS is approximately 20 bytes per frame — negligible. |

**Benefits of single transport:**
- One connection to manage on mobile (battery impact)
- One authentication flow for real-time (JWT validation in Socket.io middleware)
- One reconnection strategy
- One adapter configuration (Redis)
- Simpler client SDK (one socket_io_client package in Flutter)

### NestJS WebSocket Gateways

```
NestJS Application
|
+-- HTTP Controllers (REST API)
|   +-- AuthController
|   +-- ContentController
|   +-- FeedController
|   +-- ... (standard CRUD)
|
+-- WebSocket Gateways (Socket.io)
|   +-- ChatGateway          -> /chat namespace
|   |   +-- Events: message:send, message:delivered, message:read,
|   |   |          typing:start, typing:stop
|   |   +-- Rooms: thread:{threadId}
|   |
|   +-- PresenceGateway       -> /presence namespace
|   |   +-- Events: presence:update, presence:query
|   |   +-- Rooms: module:{moduleKey} (per-module presence)
|   |
|   +-- FeedGateway           -> /feed namespace
|   |   +-- Events: content:new, content:updated, content:removed,
|   |   |          engagement:update
|   |   +-- Rooms: feed:{tab}, feed:{userId}:{tab}
|   |
|   +-- MarketplaceGateway    -> /marketplace namespace
|   |   +-- Events: bid:placed, bid:outbid, auction:ending,
|   |   |          auction:ended, product:sold
|   |   +-- Rooms: auction:{auctionId}, seller:{userId}
|   |
|   +-- NotificationGateway   -> /notifications namespace
|   |   +-- Events: notification:new, notification:read, badge:update
|   |   +-- Rooms: user:{userId}
|   |
|   +-- ProximityGateway      -> /proximity namespace
|       +-- Events: location:update, nearby:users, nearby:entered,
|       |          nearby:left
|       +-- Rooms: geo:{geohash} (dynamic geohash-based rooms)
|
+-- Shared Infrastructure
    +-- WsAuthGuard           -> JWT validation on connection
    +-- WsThrottlerGuard      -> Rate limiting per event type
    +-- Redis Adapter         -> Cross-instance event distribution
```

### Gateway Implementation Pattern

Every gateway follows the same structure:

```typescript
@WebSocketGateway({
  namespace: '/chat',
  cors: { origin: '*' },  // Tightened in production
})
@UseGuards(WsAuthGuard)
export class ChatGateway
  implements OnGatewayConnection, OnGatewayDisconnect
{
  @WebSocketServer()
  server: Server;

  constructor(
    private readonly chatService: ChatService,
    private readonly presenceService: PresenceService,
  ) {}

  async handleConnection(client: Socket) {
    const userId = client.data.userId;  // Set by WsAuthGuard
    // Join user's active thread rooms
    const threads = await this.chatService.getUserThreadIds(userId);
    for (const threadId of threads) {
      client.join(`thread:${threadId}`);
    }
  }

  async handleDisconnect(client: Socket) {
    // Presence handled by PresenceGateway
  }

  @SubscribeMessage('message:send')
  async handleMessage(
    @ConnectedSocket() client: Socket,
    @MessageBody() payload: SendMessageDto,
  ): Promise<WsResponse<MessageResponseDto>> {
    const userId = client.data.userId;
    const message = await this.chatService.sendMessage(userId, payload);

    // Broadcast to thread room (reaches all participants across
    // all server instances via Redis adapter)
    this.server
      .to(`thread:${payload.threadId}`)
      .emit('message:new', message);

    // Trigger push notification for offline participants (via BullMQ)
    await this.chatService.notifyOfflineParticipants(
      payload.threadId, userId, message,
    );

    return { event: 'message:sent', data: { messageId: message.id } };
  }
}
```

### Socket.io with Redis Adapter

The Redis adapter enables horizontal scaling — multiple NestJS instances share Socket.io state through Redis pub/sub:

```typescript
// main.ts — Socket.io Redis adapter setup
import { createAdapter } from '@socket.io/redis-adapter';
import { createClient } from 'redis';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  const pubClient = createClient({ url: process.env.REDIS_URL });
  const subClient = pubClient.duplicate();
  await Promise.all([pubClient.connect(), subClient.connect()]);

  const ioAdapter = new IoAdapter(app);
  app.useWebSocketAdapter(ioAdapter);

  // The adapter intercepts every server.emit() and publishes to Redis.
  // Other instances subscribe and re-emit to their local clients.
  const io = app.getHttpServer();
  io.adapter(createAdapter(pubClient, subClient));

  await app.listen(3000);
}
```

**How it works:**
1. Client A connects to Instance 1, joins room `thread:abc`
2. Client B connects to Instance 2, joins room `thread:abc`
3. Instance 1 receives a `message:send` event from Client A
4. Instance 1 calls `server.to('thread:abc').emit('message:new', ...)`
5. Redis adapter publishes this emit to Redis pub/sub channel
6. Instance 2's adapter picks up the message from Redis
7. Instance 2 emits to Client B (who is in room `thread:abc` locally)

**Result:** Clients on different server instances see the same real-time events, with no shared memory or sticky sessions required.

### PostgreSQL LISTEN/NOTIFY for DB-Driven Events

Some events originate from database changes (e.g., a cron job updating auction status, or an admin action via a different interface). PostgreSQL's LISTEN/NOTIFY bridges the gap between database mutations and Socket.io:

```sql
-- Trigger function for content status changes
CREATE OR REPLACE FUNCTION notify_content_change()
RETURNS trigger AS $$
BEGIN
  PERFORM pg_notify(
    'content_changes',
    json_build_object(
      'operation', TG_OP,
      'id', NEW.id,
      'type', NEW.type,
      'status', NEW.status,
      'creatorId', NEW.creator_id
    )::text
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER content_change_trigger
  AFTER INSERT OR UPDATE ON content
  FOR EACH ROW EXECUTE FUNCTION notify_content_change();
```

```sql
-- Trigger for auction status changes (cron-driven transitions)
CREATE OR REPLACE FUNCTION notify_auction_change()
RETURNS trigger AS $$
BEGIN
  IF OLD.status IS DISTINCT FROM NEW.status THEN
    PERFORM pg_notify(
      'auction_changes',
      json_build_object(
        'auctionId', NEW.id,
        'productId', NEW.product_id,
        'oldStatus', OLD.status,
        'newStatus', NEW.status,
        'winnerId', NEW.winner_id,
        'currentPrice', NEW.current_price_cents
      )::text
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER auction_change_trigger
  AFTER UPDATE ON auctions
  FOR EACH ROW EXECUTE FUNCTION notify_auction_change();
```

**NestJS listener service:**

```typescript
@Injectable()
export class PgNotifyService implements OnModuleInit, OnModuleDestroy {
  private client: Client;

  constructor(
    @Inject('FEED_GATEWAY')
    private readonly feedGateway: FeedGateway,
    @Inject('MARKETPLACE_GATEWAY')
    private readonly marketplaceGateway: MarketplaceGateway,
  ) {}

  async onModuleInit() {
    // Dedicated connection for LISTEN (not from the connection pool)
    this.client = new Client({
      connectionString: process.env.DATABASE_URL,
    });
    await this.client.connect();

    await this.client.query('LISTEN content_changes');
    await this.client.query('LISTEN auction_changes');

    this.client.on('notification', (msg) => {
      const payload = JSON.parse(msg.payload);
      switch (msg.channel) {
        case 'content_changes':
          this.handleContentChange(payload);
          break;
        case 'auction_changes':
          this.handleAuctionChange(payload);
          break;
      }
    });
  }

  private handleContentChange(payload: ContentChangePayload) {
    if (payload.status === 'ACTIVE' && payload.operation === 'INSERT') {
      this.feedGateway.server
        .to(`feed:${this.getTabForType(payload.type)}`)
        .emit('content:new', {
          contentId: payload.id,
          type: payload.type,
        });
    }
  }

  private handleAuctionChange(payload: AuctionChangePayload) {
    if (payload.newStatus === 'ENDED') {
      this.marketplaceGateway.server
        .to(`auction:${payload.auctionId}`)
        .emit('auction:ended', {
          auctionId: payload.auctionId,
          winnerId: payload.winnerId,
          finalPrice: payload.currentPrice,
        });
    }
  }

  async onModuleDestroy() {
    await this.client.end();
  }
}
```

**When to use LISTEN/NOTIFY vs direct Socket.io emit:**

| Scenario | Approach | Why |
|----------|----------|-----|
| User sends chat message | Direct emit from gateway | Synchronous, in the request flow |
| User places bid | Direct emit + LISTEN/NOTIFY for status | Bid is immediate; auction ENDED is cron-driven |
| Cron job ends auction | LISTEN/NOTIFY | No HTTP/WS request context |
| Admin removes content | LISTEN/NOTIFY | Admin action may be from a different interface |
| New content published | Direct emit from controller | In the HTTP request flow |
| Feed cache invalidation | Redis pub/sub (via BullMQ event) | Cross-concern, not tied to a specific table |

---

## Section 3: Event Flow Patterns

### Pattern 1: Chat Message

```
Client A             ChatGateway         PostgreSQL    Redis         BullMQ        Client B     Client C
(sender)             (NestJS)                          Adapter                     (online)     (offline)
   |                     |                    |           |              |             |            |
   |-- message:send ---->|                    |           |              |             |            |
   |                     |-- em.flush() ----->|           |              |             |            |
   |                     |    Message saved   |           |              |             |            |
   |                     |                    |           |              |             |            |
   |                     |-- emit to room ----|---------->|              |             |            |
   |                     |   thread:{id}      |           |-- pubsub -->|             |            |
   |                     |                    |           |              |             |            |
   |                     |                    |           |   message:new ------------->|            |
   |                     |                    |           |              |             |            |
   |                     |-- check presence --|---------->|              |             |            |
   |                     |   Client C offline |           |              |             |            |
   |                     |                    |           |              |             |            |
   |                     |-- queue push job --|-----------|------------->|             |            |
   |                     |                    |           |              |-- FCM push ->|            |
   |                     |                    |           |              |             |   push recv |
   |<-- message:sent ----|                    |           |              |             |            |
   |   (ack)             |                    |           |              |             |            |
```

**Sequence:**
1. Client A emits `message:send` with `{ threadId, text, mediaIds? }`
2. ChatGateway validates via WsAuthGuard (JWT) and WsThrottlerGuard
3. ChatService creates Message entity, updates Thread.lastMessage and Thread.lastActivity
4. MikroORM em.flush() persists in a single transaction
5. Gateway emits `message:new` to `thread:{threadId}` room — Redis adapter distributes cross-instance
6. ChatService checks which participants are online (Redis presence) vs offline
7. For offline participants: BullMQ job queued for FCM push notification
8. Gateway returns `message:sent` acknowledgement to Client A

### Pattern 2: Auction Bid

```
Bidder               AuctionController     PostgreSQL              Socket.io      BullMQ
(HTTP)               (REST)                                        emit           Jobs
   |                     |                    |                       |              |
   |-- POST /bid ------->|                    |                       |              |
   |                     |-- BEGIN TX ------->|                       |              |
   |                     |   1. Lock auction  |                       |              |
   |                     |   2. Validate min  |                       |              |
   |                     |   3. INSERT Bid    |                       |              |
   |                     |   4. UPDATE price  |                       |              |
   |                     |   5. Anti-snipe?   |                       |              |
   |                     |-- COMMIT --------->|                       |              |
   |                     |                    |                       |              |
   |                     |-- bid:placed ------|---------------------->|              |
   |                     |   to auction room  |                       |              |
   |                     |                    |                       |              |
   |                     |-- queue outbid ----|-----------------------|------------->|
   |                     |   notification     |                       |              |
   |                     |                    |                       |              |
   |<-- 201 Created -----|                    |                       |              |
   |   { bidId, amount } |                    |                       |              |
```

**Why bids use REST, not Socket.io:**
- Financial operations require HTTP semantics (status codes, idempotency keys, retry safety)
- REST responses include the full bid state for client confirmation
- Auction watchers get real-time updates via Socket.io room subscription
- The bid placement itself is a synchronous, transactional operation — not a fire-and-forget event

### Pattern 3: Feed Update (New Content Published)

```
Creator              ContentController     PostgreSQL    Redis        BullMQ         Feed
(HTTP)               (REST)                              Cache        Jobs           Subscribers
   |                     |                    |            |             |               |
   |-- POST /content --->|                    |            |             |               |
   |                     |-- em.flush() ----->|            |             |               |
   |                     |    Content saved   |            |             |               |
   |                     |                    |            |             |               |
   |                     |-- invalidate ------|----------->|             |               |
   |                     |   feed:{tab}:del   |            |             |               |
   |                     |                    |            |             |               |
   |                     |-- queue jobs ------|------------|------------>|               |
   |                     |   1. embedding     |            |             |               |
   |                     |   2. notify follows|            |             |               |
   |                     |   3. process media |            |             |               |
   |                     |                    |            |             |               |
   |                     |                    |-- NOTIFY ->|             |               |
   |                     |                    |  trigger   |             |               |
   |                     |                    |            |             |               |
   |                     |                    |            | content:new |               |
   |                     |                    |            |-------------|-------------->|
   |                     |                    |            |             |               |
   |<-- 201 Created -----|                    |            |             |               |
```

### Pattern 4: Presence Update

```
User                 PresenceGateway       Redis
opens app            (Socket.io)
   |                     |                    |
   |-- connect --------->|                    |
   |                     |-- HSET ----------->|  presence:{uid}
   |                     |-- SADD ----------->|  module:online:{mod}
   |                     |-- EXPIRE 90s ----->|
   |                     |                    |
   |   ... 30 seconds ...|                    |
   |                     |                    |
   |-- heartbeat ------->|                    |
   |                     |-- EXPIRE 90s ----->|  refresh TTL
   |                     |                    |
   |   ... 30 seconds ...|                    |
   |                     |                    |
   |-- heartbeat ------->|                    |
   |                     |-- EXPIRE 90s ----->|  refresh TTL
   |                     |                    |
   |-- disconnect ------>|                    |
   |                     |-- DEL ------------>|  presence:{uid}
   |                     |-- SREM ----------->|  module:online:{mod}
   |                     |-- SET ------------>|  lastseen:{uid}
```

---

## Section 4: Presence System Design

### Architecture

Presence is backed entirely by Redis — no PostgreSQL writes on heartbeats (which would be a write amplification disaster).

**Redis data structures:**

```
# Per-user presence hash
HSET presence:{userId} status "online" module "video_making" connectedAt "2026-03-03T10:00:00Z"
EXPIRE presence:{userId} 90  # TTL = 3 heartbeat cycles (30s each)

# Per-module presence set (for "who's online in marketplace" queries)
SADD module:online:buy_sell {userId}
EXPIRE module:online:buy_sell 120

# Last-seen timestamp (persisted when user goes offline)
SET lastseen:{userId} "2026-03-03T10:30:00Z"
```

### Per-Module Presence

Kuwboo has four modules (TDD Section 0). Users can be "online" in different contexts:

| Module Key | Presence Meaning | Use Case |
|------------|-----------------|----------|
| `video_making` | Watching/creating videos | Show "active" badge on video feed profiles |
| `buy_sell` | Browsing/selling in marketplace | Show "online" on seller profiles for instant chat |
| `dating` | Active in dating module | Show "recently active" on dating cards |
| `social_stumble` | Browsing social feed | General online indicator |

**When the user switches tabs in the app**, the Flutter client emits `presence:update` with the new moduleKey. The PresenceGateway updates Redis accordingly.

### Heartbeat Protocol

- **Heartbeat interval:** 30 seconds (client sends)
- **TTL:** 90 seconds (3 missed heartbeats = offline)
- **On disconnect:** Keys deleted immediately (no waiting for TTL)
- **Last-seen:** Written to Redis on disconnect, persisted to PostgreSQL periodically (batch job every 5 minutes)

### Graceful Degradation on Server Restart

If the NestJS instance crashes or restarts:
1. All Socket.io connections drop
2. Redis presence keys expire naturally after 90 seconds (3 missed heartbeats)
3. Clients auto-reconnect (Socket.io built-in exponential backoff)
4. On reconnect, PresenceGateway re-creates Redis entries
5. **Gap:** Users appear offline for up to 90 seconds during a rolling restart

**Mitigation for rolling deploys:** Use PM2's `--kill-timeout` to allow graceful shutdown. During shutdown, the gateway emits `server:restarting` to connected clients, which triggers an immediate reconnect attempt to a different instance (if multiple instances exist behind a load balancer).

### Presence Query API

```typescript
// REST endpoint for bulk presence queries (e.g., loading a chat list)
@Get('presence/bulk')
async getBulkPresence(
  @Query('userIds') userIds: string[],
): Promise<PresenceMap> {
  // Single Redis pipeline — O(N) but avoids N round-trips
  const pipeline = this.redis.pipeline();
  for (const uid of userIds) {
    pipeline.hgetall(`presence:${uid}`);
  }
  const results = await pipeline.exec();
  // Map to { [userId]: { status, module, lastSeen } }
}

// Socket.io for real-time presence of specific users (e.g., chat partner)
@SubscribeMessage('presence:subscribe')
async subscribePresence(
  @ConnectedSocket() client: Socket,
  @MessageBody() payload: { userIds: string[] },
) {
  for (const uid of payload.userIds) {
    client.join(`presence:${uid}`);
  }
}
```

---

## Section 5: Battery Optimization Strategy

### Mobile App State Model

Flutter apps on iOS and Android have three states that affect real-time behaviour:

| State | WebSocket | Events Received | Heartbeat | Presence |
|-------|-----------|----------------|-----------|----------|
| **Foreground** | Full connection | All events | 30s | Full (module-aware) |
| **Background** | Reduced connection | Critical only (chat, bid outbid, auction end) | 60s | Reduced (no module) |
| **Killed / Not Running** | No connection | None (FCM push only) | None | Offline (TTL expires) |

### WebSocket Lifecycle Tied to App State

```typescript
// Flutter client — AppLifecycleListener integration
class SocketManager {
  late final AppLifecycleListener _lifecycleListener;
  final SocketIO.Socket _socket;

  void init() {
    _lifecycleListener = AppLifecycleListener(
      onResume: _onForeground,
      onInactive: _onBackground,
      onPause: _onBackground,
      onDetach: _onKilled,
    );
  }

  void _onForeground() {
    if (!_socket.connected) {
      _socket.connect();
    }
    // Resume full event subscriptions
    _socket.emit('client:state', {'state': 'foreground'});
    // Delta sync — fetch missed events since lastSeen
    _socket.emit('sync:request', {'since': _lastEventTimestamp});
  }

  void _onBackground() {
    // Reduce to critical events only
    _socket.emit('client:state', {'state': 'background'});
    // Socket stays connected but server reduces event volume
  }

  void _onKilled() {
    _socket.emit('client:state', {'state': 'killed'});
    _socket.disconnect();
  }
}
```

### Server-Side Event Filtering by Client State

```typescript
@Injectable()
export class ClientStateService {
  private clientStates = new Map<string, 'foreground' | 'background'>();

  setClientState(socketId: string, state: 'foreground' | 'background') {
    this.clientStates.set(socketId, state);
  }

  shouldDeliverEvent(
    socketId: string,
    eventPriority: EventPriority,
  ): boolean {
    const state = this.clientStates.get(socketId) ?? 'foreground';
    if (state === 'foreground') return true;
    // Background: only deliver critical events
    return eventPriority === EventPriority.CRITICAL;
  }
}

enum EventPriority {
  CRITICAL = 'critical',  // chat messages, bid outbid, auction ended
  NORMAL = 'normal',      // feed updates, new followers, likes
  LOW = 'low',            // typing indicators, presence changes
}
```

### Push Notification Strategy for Offline Delivery

When a user is offline (no Socket.io connection), critical events are delivered via Firebase Cloud Messaging:

```
Event occurs --> Check Redis presence:{userId}
                      |
              +-------+-------+
              | Online        | Offline
              v               v
         Socket.io emit  BullMQ job --> FCM push notification
         (direct)                            |
                                             v
                                     notification table INSERT
                                     (for inbox, source of truth)
```

**Dual write:** Every notification-worthy event writes to the notification table AND either emits via Socket.io (if online) or sends FCM push (if offline). The notification table is the source of truth for the notification inbox — push notifications are ephemeral delivery mechanisms.

### Delta Sync for Efficient Data Transfer

When a user returns to the app after being in the background or killed state:

```typescript
// Server-side delta sync handler
@SubscribeMessage('sync:request')
async handleSyncRequest(
  @ConnectedSocket() client: Socket,
  @MessageBody() payload: { since: string },
) {
  const userId = client.data.userId;
  const since = new Date(payload.since);

  // Fetch unread notifications since timestamp
  const notifications =
    await this.notificationService.getUnreadSince(userId, since);

  // Fetch unread message counts per thread
  const unreadCounts =
    await this.chatService.getUnreadCountsSince(userId, since);

  // Fetch badge count
  const badgeCount =
    await this.notificationService.getBadgeCount(userId);

  client.emit('sync:response', {
    notifications,
    unreadCounts,
    badgeCount,
    syncedAt: new Date().toISOString(),
  });
}
```

### Batched Low-Priority Updates

Engagement updates (like counts, view counts) are batched to reduce event volume:

```typescript
@Injectable()
export class EngagementBatchService {
  private pendingUpdates = new Map<string, EngagementDelta>();
  private flushInterval: NodeJS.Timer;

  constructor(private readonly feedGateway: FeedGateway) {
    // Flush engagement updates every 5 seconds
    this.flushInterval = setInterval(() => this.flush(), 5000);
  }

  addUpdate(contentId: string, delta: Partial<EngagementDelta>) {
    const existing = this.pendingUpdates.get(contentId)
      ?? { likes: 0, views: 0, comments: 0 };
    if (delta.likes) existing.likes += delta.likes;
    if (delta.views) existing.views += delta.views;
    if (delta.comments) existing.comments += delta.comments;
    this.pendingUpdates.set(contentId, existing);
  }

  private flush() {
    if (this.pendingUpdates.size === 0) return;
    const batch = Array.from(this.pendingUpdates.entries());
    this.pendingUpdates.clear();
    // Single emit with batched updates
    this.feedGateway.server.emit('engagement:batch', batch);
  }
}
```

---

## Section 6: pgvector Integration

> **Extended by:** [TRUST_ENGINE.md §5.4](./TRUST_ENGINE.md#54-pgvector-integration-for-recommendations) adds dating profile bio embeddings for recommendation matching. [SAFETY_PIPELINE.md §6.4](./SAFETY_PIPELINE.md#64-behavior-similarity-pgvector) adds behavioral embeddings (64-dim) on User for ban evasion detection via cosine similarity.

### Why pgvector (In-Database, Not a Separate Vector DB)

At Kuwboo's expected scale (less than 10M content items, less than 1M users), a dedicated vector database (Pinecone, Weaviate, Qdrant) adds operational complexity without proportional benefit. pgvector keeps embeddings alongside the relational data they describe — enabling single-query joins between vector similarity search and standard SQL filters.

**Scale threshold for migration:** If vector search latency exceeds 100ms at p95 on a content table with more than 50M rows, evaluate migrating to a dedicated vector DB. Below that, PostgreSQL handles it.

### Embedding Generation Pipeline

```
Content created/updated
        |
        v
  BullMQ job: generate-embedding
        |
        v
  EmbeddingService
  1. Extract text:
     - Video: caption
     - Product: title + description
     - Post: text
     - Event: title + description
     - WantedAd: title + description
  2. Call OpenAI text-embedding-3-small (1536 dimensions)
  3. Store in content.embedding column
        |
        v
  PostgreSQL: UPDATE content
  SET embedding = $1::vector(1536)
  WHERE id = $2
```

### Schema Addition

The content table (STI) gets an embedding column:

```typescript
@Entity({ discriminatorColumn: 'type', /* ... */ })
export class Content {
  // ... existing fields from TDD Section 2

  @Property({ columnType: 'vector(1536)', nullable: true })
  embedding?: number[];
}
```

**Migration:**

```sql
CREATE EXTENSION IF NOT EXISTS vector;
ALTER TABLE content ADD COLUMN embedding vector(1536);
```

### Use Cases

| Use Case | How pgvector Helps | Query Pattern |
|----------|-------------------|---------------|
| **Marketplace search** | "Find products similar to this leather jacket" | Nearest-neighbor on Product embeddings filtered by type = 'PRODUCT' |
| **Feed recommendations** | "Show content similar to what this user likes" | Average embedding of user's liked content, nearest-neighbor on all active content |
| **Dating matching** | "Find profiles similar in interests" | Embed dating profile bio + prompts, nearest-neighbor on DatingProfile embeddings |
| **Duplicate detection** | "Is this product listing a repost?" | Cosine similarity > 0.95 on new content vs recent content by same creator |
| **Spam detection** | "Is this message spam?" | Embed message, compare to known spam embedding cluster |
| **Trending discovery** | "What content is thematically similar to trending items?" | Nearest-neighbor seeded by trending content embeddings |

### Index Strategy

```sql
-- HNSW index — better recall, faster queries, more memory
-- Use for the primary content search
CREATE INDEX idx_content_embedding_hnsw
  ON content USING hnsw (embedding vector_cosine_ops)
  WITH (m = 16, ef_construction = 200);

-- Partial index for Products only (most common search target)
CREATE INDEX idx_product_embedding_hnsw
  ON content USING hnsw (embedding vector_cosine_ops)
  WITH (m = 16, ef_construction = 200)
  WHERE type = 'PRODUCT' AND status = 'ACTIVE';
```

**Why HNSW over IVFFlat:**
- HNSW has better recall at the same speed
- No need to retrain (IVFFlat requires periodic REINDEX as data distribution changes)
- Build time is slower but query time is faster — queries matter more than inserts

### Embedding Generation Cost Control

| Model | Dimensions | Cost per 1M tokens | Notes |
|-------|-----------|-------------------|-------|
| text-embedding-3-small | 1536 | ~$0.02 | Recommended — good quality-to-cost ratio |
| text-embedding-3-large | 3072 | ~$0.13 | Overkill for Kuwboo's use cases |

**Estimated monthly cost at 100K new content items/month:**
- Average text length: ~100 tokens per content item
- 100K items x 100 tokens = 10M tokens
- Cost: ~$0.20/month — negligible

### DatingProfile Embeddings

Dating profiles are NOT in the content STI table. They get their own embedding column:

```sql
ALTER TABLE dating_profiles ADD COLUMN embedding vector(1536);

CREATE INDEX idx_dating_embedding_hnsw
  ON dating_profiles USING hnsw (embedding vector_cosine_ops)
  WITH (m = 16, ef_construction = 200)
  WHERE status = 'ACTIVE';
```

**Embedding input:** Concatenation of bio + prompt answers. Re-generated when the profile is updated.

---

## Section 7: Background Job Processing

### BullMQ on Redis

All async work runs through BullMQ queues backed by the same Redis instance used for Socket.io and presence. Each queue has its own concurrency and retry settings.

### Queue Architecture

| Queue | Purpose | Concurrency | Retry | Schedule |
|-------|---------|-------------|-------|----------|
| **push-notifications** | FCM push delivery | 10 | 3x exponential (1s, 4s, 16s) | On demand |
| **email** | SES transactional email | 5 | 3x exponential | On demand |
| **media-processing** | S3 upload status, thumbnails | 3 | 2x | On demand |
| **embeddings** | pgvector embedding generation | 5 | 3x (OpenAI rate limits) | On demand, rate limited 100/min |
| **feed-generation** | Cache warming, trending calculation | 2 | 1x | Every 5 minutes |
| **auction-lifecycle** | SCHEDULED to ACTIVE, ACTIVE to ENDED | 1 (sequential) | 3x immediate | Every 60 seconds |
| **cleanup** | Orphan media, expired sessions | 1 | 1x | Daily at 03:00 UTC |
| **audit** | AuditEntry writes | 5 | 5x (must not lose data) | On demand |

Every queue has a Dead-Letter Queue (DLQ) named `{queue}-failed`. Alert on DLQ depth > 0 for critical queues (audit, push-notifications).

### Job Processor Pattern

```typescript
@Processor('push-notifications')
export class PushNotificationProcessor {
  constructor(
    private readonly fcmService: FcmService,
    private readonly deviceService: DeviceService,
  ) {}

  @Process()
  async handlePush(job: Job<PushNotificationJobData>) {
    const { userId, title, body, data } = job.data;

    const devices = await this.deviceService.getActiveDevices(userId);
    if (devices.length === 0) return;

    // Send to all devices (user may have phone + tablet)
    const results = await Promise.allSettled(
      devices.map(device =>
        this.fcmService.send({
          token: device.fcmToken,
          notification: { title, body },
          data,
          android: { priority: 'high' },
          apns: {
            payload: {
              aps: { sound: 'default', badge: job.data.badgeCount },
            },
          },
        }),
      ),
    );

    // Handle stale tokens (FCM returns NotRegistered)
    for (let i = 0; i < results.length; i++) {
      if (results[i].status === 'rejected') {
        const error = (results[i] as PromiseRejectedResult).reason;
        if (
          error.code === 'messaging/registration-token-not-registered'
        ) {
          await this.deviceService.deactivateDevice(devices[i].id);
        }
      }
    }
  }
}
```

### DLQ Monitoring

A health check endpoint reports DLQ depth:

```typescript
@Controller('health')
export class HealthController {
  @Get('queues')
  async queueHealth(): Promise<QueueHealthReport> {
    const queues = [
      'push-notifications', 'email', 'media-processing',
      'embeddings', 'audit',
    ];
    const report: QueueHealthReport = {};

    for (const name of queues) {
      const queue = new Queue(name, { connection: this.redis });
      const failed = await queue.getFailedCount();
      const dlq = await new Queue(
        `${name}-failed`, { connection: this.redis },
      ).getWaitingCount();
      report[name] = { failed, dlq, healthy: dlq === 0 };
    }

    return report;
  }
}
```

---

## Section 8: Notification System

### Dual Delivery: Socket.io + FCM

Every notification follows the same dual-delivery pattern:

```
Notification trigger (like, comment, bid, match, message, etc.)
        |
        v
  NotificationService.send()
        |
        +-- 1. Write to notifications table (source of truth for inbox)
        |
        +-- 2. Check presence: is user online?
        |      |
        |      +-- YES: Socket.io emit to user:{userId} room
        |      |        via NotificationGateway
        |      |
        |      +-- NO:  BullMQ job --> FCM push
        |
        +-- 3. Update badge count in Redis
               INCR badge:{userId}
```

### Notification Grouping and Batching

High-frequency notifications (likes, views) are grouped to avoid overwhelming the user:

| Notification Type | Grouping | Window | Template |
|-------------------|----------|--------|----------|
| LIKE | Per content item | 5 min | "{count} people liked your {contentType}" |
| COMMENT | Per content item | 5 min | "{count} new comments on your {contentType}" |
| FOLLOW | Global per user | 1 hour | "{count} new followers" |
| VIEW | No notification | N/A | Views do not generate notifications |
| BID | Individual | N/A | Delivered immediately |
| MESSAGE | Individual | N/A | Delivered immediately |
| MATCH | Individual | N/A | Delivered immediately |
| AUCTION_ENDING | Individual | N/A | Delivered immediately |
| AUCTION_WON | Individual | N/A | Delivered immediately |
| AUCTION_OUTBID | Individual | N/A | Delivered immediately |

### Read/Unread State Management

```typescript
// Mark single notification as read
@Patch('notifications/:id/read')
async markRead(
  @Param('id') id: string,
  @CurrentUser() userId: string,
) {
  await this.notificationService.markRead(id, userId);

  // Decrement badge count
  await this.redis.decr(`badge:${userId}`);

  // Emit badge update to all user's devices via Socket.io
  const count = await this.redis.get(`badge:${userId}`);
  this.notificationGateway.server
    .to(`user:${userId}`)
    .emit('badge:update', { count });
}

// Mark all as read
@Post('notifications/read-all')
async markAllRead(@CurrentUser() userId: string) {
  await this.notificationService.markAllRead(userId);
  await this.redis.set(`badge:${userId}`, '0');

  this.notificationGateway.server
    .to(`user:${userId}`)
    .emit('badge:update', { count: 0 });
}
```

### Badge Count Sync

Badge counts are maintained in Redis for fast access and synced to FCM for app icon badges:

```typescript
// On every notification send
await this.redis.incr(`badge:${userId}`);
const badgeCount = parseInt(
  await this.redis.get(`badge:${userId}`) ?? '0',
);

// Include badge count in FCM push
fcmPayload.apns.payload.aps.badge = badgeCount;
fcmPayload.data.badgeCount = String(badgeCount);
```

**Consistency check:** A daily BullMQ job recalculates badge counts from the notification table (WHERE readAt IS NULL) and corrects any Redis drift.

---

## Section 9: Infrastructure (AWS)

### Architecture Overview

```
AWS eu-west-2 (London)

  Route 53 (DNS)
  kuwboo.com, api.kuwboo.com
       |
       v
  CloudFront (CDN)
  +-- api.kuwboo.com --> EC2
  +-- media.kuwboo.com --> S3 bucket
       |
       v
  VPC
  +-- EC2 (t3.medium -> t3.large)
  |   +-- Nginx (reverse proxy, SSL termination)
  |   |   +-- api.kuwboo.com --> :3000
  |   |   +-- WebSocket upgrade --> :3000
  |   |
  |   +-- PM2 Process Manager
  |       +-- NestJS Application
  |           +-- REST Controllers (HTTP :3000)
  |           +-- Socket.io Gateways (WS :3000)
  |           +-- BullMQ Workers (in-process)
  |           +-- PgNotify Listener
  |
  +-- RDS PostgreSQL 16
  |   +-- pgvector extension
  |   +-- PostGIS extension
  |   +-- db.t3.micro (Single-AZ, promote to Multi-AZ at scale)
  |
  +-- ElastiCache Redis 7.2
      +-- Socket.io adapter
      +-- BullMQ queues
      +-- Presence state
      +-- Feed cache, block list cache
      +-- cache.t3.micro

  S3 (media uploads, user avatars, audio tracks)
  SES (transactional email)
  Secrets Manager (JWT secrets, DB credentials, API keys)
  Firebase Cloud Messaging (external — push notifications)
```

### Cost Estimate (Launch Configuration)

| Service | Spec | Monthly Cost (est.) | Notes |
|---------|------|-------------------|-------|
| EC2 | t3.medium (2 vCPU, 4 GB) | ~$30 | NestJS + Socket.io + BullMQ workers |
| RDS PostgreSQL | db.t3.micro (2 vCPU, 1 GB) | ~$15 | pgvector + PostGIS extensions |
| ElastiCache Redis | cache.t3.micro | ~$12 | Socket.io adapter, BullMQ, presence, cache |
| S3 | First 50 GB | ~$1 | Media storage |
| CloudFront | First 1 TB transfer | ~$0 (free tier) | CDN for media |
| SES | First 62K emails | ~$0 (free tier) | Transactional email |
| Route 53 | Hosted zone + queries | ~$1 | DNS |
| Secrets Manager | 5 secrets | ~$2 | |
| **Total** | | **~$61/month** | |

### Scale-Up Triggers and Migration Path

| Trigger | Current | Scale-Up Action | Target |
|---------|---------|----------------|--------|
| CPU > 70% sustained 24h | t3.medium | Vertical scale | t3.large (2 vCPU, 8 GB) |
| Memory > 80% | 4 GB | Vertical scale | t3.large (8 GB) |
| WS connections > 10K | Single instance | Add ALB + ASG (2 instances) | Horizontal with sticky sessions for WS |
| WS connections > 50K | 2 instances | Dedicated Socket.io cluster | Separate EC2 for WS, separate for REST |
| DB latency p95 > 200ms | db.t3.micro | Vertical scale | db.t3.small then db.t3.medium |
| DB connections > 80% pool | 50 connections | Add PgBouncer or increase pool | PgBouncer on EC2 |
| Redis memory > 80% | cache.t3.micro | Vertical scale | cache.t3.small |
| Vector search > 100ms p95 | pgvector in-DB | Evaluate dedicated vector DB | Qdrant or Weaviate |
| BullMQ queue depth > 1000 | In-process workers | Separate worker process | Dedicated EC2 for workers |

### Nginx Configuration for WebSocket

```nginx
upstream nestjs {
    server 127.0.0.1:3000;
}

server {
    listen 443 ssl http2;
    server_name api.kuwboo.com;

    ssl_certificate /etc/letsencrypt/live/api.kuwboo.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.kuwboo.com/privkey.pem;

    # REST API
    location / {
        proxy_pass http://nestjs;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Socket.io — WebSocket upgrade
    location /socket.io/ {
        proxy_pass http://nestjs;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # Longer timeouts for WebSocket
        proxy_read_timeout 86400s;
        proxy_send_timeout 86400s;
    }
}
```

### Environment Variables

```bash
# Database
DATABASE_URL=postgresql://kuwboo:PASSWORD@RDS_ENDPOINT:5432/kuwboo
DATABASE_POOL_SIZE=20

# Redis
REDIS_URL=redis://ELASTICACHE_ENDPOINT:6379

# JWT
JWT_SECRET=from_secrets_manager
JWT_REFRESH_SECRET=from_secrets_manager
JWT_ACCESS_EXPIRY=15m
JWT_REFRESH_EXPIRY=7d

# Firebase (push notifications)
FIREBASE_PROJECT_ID=kuwboo-app
GOOGLE_APPLICATION_CREDENTIALS=/etc/kuwboo/firebase-service-account.json

# OpenAI (embeddings)
OPENAI_API_KEY=from_secrets_manager
OPENAI_EMBEDDING_MODEL=text-embedding-3-small

# AWS
AWS_REGION=eu-west-2
S3_BUCKET=kuwboo-media
CLOUDFRONT_DOMAIN=media.kuwboo.com

# SES
SES_FROM_EMAIL=noreply@kuwboo.com

# App
NODE_ENV=production
PORT=3000
CORS_ORIGINS=https://kuwboo.com,https://admin.kuwboo.com
```

---

## Summary: How It All Connects

```
Flutter App (iOS/Android)
    |
    +-- REST API (CRUD) ----------> NestJS Controllers --> MikroORM --> PostgreSQL
    |                                     |                                |
    +-- Socket.io (real-time) ----> NestJS Gateways ---> Redis Adapter <-- LISTEN/NOTIFY
    |                                     |
    +-- FCM Push (offline) <---- BullMQ Workers ---> Redis Queues
                                          |
                                          +-- Embedding generation --> pgvector (in PostgreSQL)
                                          +-- Media processing --> S3 + CloudFront
                                          +-- Email --> SES
                                          +-- Audit logging --> PostgreSQL (audit_entries)
```

All 32 entities from TECHNICAL_DESIGN.md are served by this architecture. The key integration points are:

1. **MikroORM** manages all 32 entities with STI for the content hierarchy
2. **Socket.io** provides real-time for chat, presence, feed, marketplace, notifications, and proximity
3. **Redis** serves as the glue — Socket.io adapter, BullMQ queues, presence state, feed cache
4. **PostgreSQL** is the source of truth — with LISTEN/NOTIFY bridging DB events to Socket.io
5. **pgvector** enables similarity search for content discovery, dating matching, and safety
6. **FCM** handles offline push delivery, with the notification table as the inbox source of truth
7. **BullMQ** processes all async work — push delivery, embeddings, media, email, auctions, cleanup
