# Kuwboo: Safety Pipeline

**Created:** March 9, 2026
**Version:** 1.0
**Purpose:** Phone intelligence, behavior monitoring, anti-ban-evasion, VoIP handling, photo authenticity
**Audience:** Phil Cutting (LionPro Dev) — implementation guide
**Status:** Greenfield rebuild — extends the 32-entity schema and trust engine

**Companion Documents:**
- [TECHNICAL_DESIGN.md](./TECHNICAL_DESIGN.md) — 32-entity schema, ORM evaluation, feed architecture, state machines
- [REALTIME_ARCHITECTURE.md](./REALTIME_ARCHITECTURE.md) — MikroORM adaptation, Socket.io gateways, pgvector, BullMQ
- [REGULATORY_REQUIREMENTS.md](./REGULATORY_REQUIREMENTS.md) — UK + USA regulatory compliance (OSA, GDPR, COPPA, BIPA)
- [TRUST_ENGINE.md](./TRUST_ENGINE.md) — trust scoring, visibility tiers, recommendation engine

---

## How to Read This Document

TRUST_ENGINE.md defines *what scores exist* and *how they map to visibility*. This document defines the **input pipeline** — how raw signals are collected, analyzed, and fed into the trust engine. It covers:

- **How** phone numbers are classified (Section 2)
- **How** VoIP accounts are handled (Section 3)
- **How** behavior is monitored in real-time (Section 4)
- **How** photos are checked for authenticity (Section 5)
- **How** banned users are detected when they return (Section 6)
- **What** schema changes support the pipeline (Section 7)
- **What** BullMQ jobs power the analysis (Section 8)

Cross-references to TRUST_ENGINE.md use "TE Section N". Cross-references to TECHNICAL_DESIGN.md use "TDD Section N". Cross-references to REALTIME_ARCHITECTURE.md use "RTA Section N".

---

## Table of Contents

- [Section 1: Purpose and Pipeline Overview](#section-1-purpose-and-pipeline-overview)
- [Section 2: Phone Number Intelligence](#section-2-phone-number-intelligence)
- [Section 3: VoIP Account Handling](#section-3-voip-account-handling)
- [Section 4: Behavior Monitoring Pipeline](#section-4-behavior-monitoring-pipeline)
- [Section 5: Photo Authenticity Detection](#section-5-photo-authenticity-detection)
- [Section 6: Anti-Ban-Evasion System](#section-6-anti-ban-evasion-system)
- [Section 7: Schema Additions](#section-7-schema-additions)
- [Section 8: BullMQ Job Definitions](#section-8-bullmq-job-definitions)

---

## Section 1: Purpose and Pipeline Overview

### Why a Safety Pipeline

The trust engine (TRUST_ENGINE.md) scores users based on signals. This document defines where those signals come from and how they're collected. Without an active safety pipeline, the trust engine only works on explicit user actions (verifications, reports). The pipeline adds **passive detection** — identifying bad actors before they get reported.

### Pipeline Architecture

```
                    ┌─────────────────────────────┐
                    │       Signal Sources          │
                    ├─────────────────────────────┤
                    │ Phone Verification (Twilio)   │
                    │ Socket.io Events (behavior)   │
                    │ Media Uploads (photos)         │
                    │ Device Metadata (fingerprint)  │
                    │ Login Events (IP, location)    │
                    └──────────┬──────────────────┘
                               │
                               ▼
                    ┌─────────────────────────────┐
                    │    BullMQ Analysis Queues     │
                    ├─────────────────────────────┤
                    │ phone-carrier-lookup          │
                    │ behavior-analysis             │
                    │ photo-authenticity-scan        │
                    │ device-fingerprint-match       │
                    │ ban-evasion-check             │
                    └──────────┬──────────────────┘
                               │
                               ▼
                    ┌─────────────────────────────┐
                    │      Trust Signal Output      │
                    ├─────────────────────────────┤
                    │ TrustSignal record created    │
                    │ trust-score-recalc queued     │
                    │ (TE Section 2.5)              │
                    └──────────┬──────────────────┘
                               │
                               ▼
                    ┌─────────────────────────────┐
                    │  Consequence (if threshold)   │
                    ├─────────────────────────────┤
                    │ Warning → Throttle → Flag →   │
                    │ Suspend → Ban                  │
                    └─────────────────────────────┘
```

---

## Section 2: Phone Number Intelligence

### 2.1 Twilio Lookup API Integration

Twilio is already a project dependency (used for OTP in the legacy codebase — see CLAUDE.md AWS Resources). The Lookup API classifies phone numbers by carrier type without requiring a phone call or SMS.

**API call:**

```typescript
import twilio from 'twilio';

interface CarrierLookupResult {
  phoneNumber: string;
  carrierType: CarrierType;
  carrierName: string;
  countryCode: string;
  isMobile: boolean;
  isVoip: boolean;
}

async function lookupCarrier(phoneNumber: string): Promise<CarrierLookupResult> {
  const client = twilio(accountSid, authToken);

  const lookup = await client.lookups.v2
    .phoneNumbers(phoneNumber)
    .fetch({ fields: 'line_type_intelligence' });

  const lineType = lookup.lineTypeIntelligence;

  return {
    phoneNumber: lookup.phoneNumber,
    carrierType: mapLineType(lineType.type), // 'mobile', 'voip', 'landline', 'unknown'
    carrierName: lineType.carrier_name ?? 'unknown',
    countryCode: lookup.countryCode,
    isMobile: lineType.type === 'mobile',
    isVoip: lineType.type === 'nonFixedVoip' || lineType.type === 'voip',
  };
}

function mapLineType(type: string): CarrierType {
  switch (type) {
    case 'mobile': return CarrierType.MOBILE;
    case 'nonFixedVoip':
    case 'voip': return CarrierType.VOIP;
    case 'landline':
    case 'fixedVoip': return CarrierType.LANDLINE;
    default: return CarrierType.UNKNOWN;
  }
}
```

**Cost:** Twilio Lookup v2 with Line Type Intelligence costs ~$0.03 per lookup. At 1,000 registrations/month, that's ~$30/month. Cached — only looked up once per phone number.

### 2.2 Carrier Classification Policy

| Carrier Type | Trust Impact | Platform Behavior |
|-------------|-------------|-------------------|
| **Mobile** | +40 trust score | Full access. Mobile numbers require a physical SIM, making them expensive to acquire at scale. |
| **VoIP** | -20 trust score | Restricted access (see Section 3). VoIP numbers are cheap, disposable, and the primary vector for ban evasion. |
| **Landline** | Blocked | Registration rejected with message: "Please use a mobile phone number." Landlines can't receive SMS OTP. |
| **Unknown** | 0 trust score (neutral) | Treated as mobile with monitoring flag. Some legitimate carriers return unknown. Re-check after 7 days. |

### 2.3 Storage

Carrier lookup results are stored on the `PhoneVerification` entity (see Section 7). Results are immutable — if a user changes phone numbers, a new lookup is performed and stored as a new record.

### 2.4 Timing

The carrier lookup runs **during registration**, after the user enters their phone number and before the OTP is sent. This prevents wasting OTP costs on numbers we'd restrict anyway (landlines).

```
User enters phone number
        │
        ▼
  BullMQ job: phone-carrier-lookup
        │
        ├── Result: MOBILE → Send OTP, proceed normally
        ├── Result: VOIP → Send OTP, flag account as VoIP
        ├── Result: LANDLINE → Reject with user-friendly message
        └── Result: UNKNOWN → Send OTP, schedule re-check in 7 days
```

---

## Section 3: VoIP Account Handling (Soft Restriction)

### 3.1 Design Principle

VoIP numbers are not banned — many legitimate users have VoIP-only phones (e.g., Google Fi, Mint Mobile, some business lines). Instead, VoIP accounts operate under **soft restrictions** that create friction for bad actors while allowing genuine users to earn full access.

### 3.2 Restriction Table

| Feature | Mobile Account | VoIP Account | Rationale |
|---------|---------------|--------------|-----------|
| **Daily match limit** (dating) | 100 | 25 | Limits mass-swiping for scam targeting |
| **Daily messages to new users** | 50 | 15 | Limits spam campaigns |
| **Marketplace listing limit** | 20/day | 5/day | Limits product spam |
| **Photo verification** | Optional (recommended) | **Required** before dating access | Forces identity confirmation |
| **Initial trust score** | 50 (phone +40, email +10) | 0 (VoIP -20, email +10 = pending) | Starts lower, must earn trust |
| **Trust decay rate** | -2/week when dormant | -4/week when dormant | Higher risk of account abandonment |
| **Bid limit** (auctions) | No limit | 3 active bids | Limits auction manipulation |

### 3.3 Upgrade Path

VoIP users can achieve **full mobile-equivalent access** through either:

**Option A: Switch phone number**
- Register a mobile number → re-verify → VoIP penalty removed, mobile bonus applied
- Trust score change: remove -20 VoIP penalty, add +40 mobile bonus = net +60

**Option B: Earn trust through behavior** (30-day pathway)
- Requirements (all must be met):
  - 30+ days of consistent activity (no dormancy)
  - Selfie verification completed (+30 trust)
  - Zero upheld reports
  - Response rate > 50%
  - At least 5 genuine conversations (>3 messages each)
- Result: VoIP restriction flag removed, limits restored to mobile-equivalent
- Trust score: VoIP penalty remains on record but is offset by positive signals

### 3.4 User Communication

VoIP-restricted users see a transparent explanation:

```
"Your account uses a virtual phone number, which limits some features to protect
our community. You can:

• Switch to a mobile number for instant full access
• Complete identity verification and build your reputation over 30 days

Your current limits: [list active restrictions]"
```

No mention of "VoIP" or "trust score" — the messaging focuses on what the user can do to improve, not the technical classification.

---

## Section 4: Behavior Monitoring Pipeline

### 4.1 Monitored Signals

All behavior monitoring hooks into existing Socket.io events (RTA Section 2-3) and REST API endpoints. No additional client-side tracking is needed — the pipeline analyzes data the backend already receives.

| Signal | Source | Detection Method |
|--------|--------|-----------------|
| **Swipe velocity** | Socket.io `dating:swipe` event | Rate calculation: swipes per minute over rolling 5-min window |
| **Message repetition** | Chat message events (RTA Section 3) | Levenshtein distance between messages sent to different users |
| **Link frequency** | Chat message text analysis | Regex extraction of URLs from messages |
| **Copy-paste detection** | Message timing + content similarity | Messages sent within 2 seconds of each other with >80% similarity |
| **Account switching rate** | Auth token refresh events | Multiple token refreshes across different Device records in short window |
| **Device switching rate** | Device metadata on API requests | New Device records created per rolling 7-day window |
| **Report velocity** | Report creation events (TDD Section 5) | Reports filed per hour (detects coordinated reporting abuse) |

### 4.2 Detection Thresholds

| Behavior | Yellow Flag | Red Flag | Action |
|----------|-------------|----------|--------|
| **Swipe rate** | >30/min for 5 min | >50/min for 5 min | Yellow: throttle to 10/min. Red: block swiping for 1 hour |
| **100% right swipes** | >50 consecutive right swipes | >100 consecutive | Yellow: soft warning. Red: temporary match restriction |
| **Message repetition** | Same message to 3+ users | Same message to 5+ users | Yellow: rate limit messaging. Red: flag for review |
| **Link in first message** | 1 link to new contact | 3+ links to new contacts in 1 hour | Yellow: log. Red: auto-hide messages pending review |
| **Copy-paste messages** | 3 similar messages in 5 min | 10 similar messages in 1 hour | Yellow: "slow down" prompt. Red: messaging throttle |
| **Device switching** | 3 new devices in 7 days | 5+ new devices in 7 days | Yellow: require re-authentication. Red: flag for review |
| **Report filed velocity** | 3 reports in 1 hour | 10 reports in 1 hour | Yellow: deprioritize reports from this user. Red: investigate for coordinated abuse |

### 4.3 Real-Time Processing Architecture

```
Socket.io Event / API Request
        │
        ▼
  Gateway/Controller Interceptor
  (lightweight check — no DB, no queue)
        │
        ├── Rate limit check (Redis INCR with TTL)
        │   └── If exceeded → immediate throttle response
        │
        └── Queue behavior event for analysis
            └── BullMQ: behavior-analysis queue
                    │
                    ▼
              BehaviorAnalysisProcessor
                    │
                    ├── Load recent behavior window from Redis
                    ├── Apply detection rules
                    ├── If threshold crossed:
                    │   ├── Create TrustSignal (TE Section 8.3)
                    │   ├── Apply immediate consequence
                    │   └── Queue trust-score-recalc
                    │
                    └── Update behavior window in Redis
```

**Redis data structure for behavior windows:**

```
// Swipe tracking (sorted set: timestamp → swipe direction)
behavior:{userId}:swipes → ZSET { timestamp: "left"|"right" }
TTL: 1 hour

// Message hashes (sorted set: timestamp → message hash)
behavior:{userId}:msg_hashes → ZSET { timestamp: hash }
TTL: 24 hours

// Device fingerprints (set)
behavior:{userId}:devices → SET { fingerprintHash }
TTL: 7 days
```

### 4.4 Consequence Ladder

Consequences escalate based on repeated violations. The escalation state is tracked per user in Redis:

```
behavior:{userId}:escalation → { level: 0-4, lastEscalatedAt: timestamp }
TTL: 30 days (resets after 30 days of clean behavior)
```

| Level | Name | Trigger | Effect | Duration |
|-------|------|---------|--------|----------|
| **0** | Clean | Default | No restrictions | — |
| **1** | Warning | First threshold crossed | In-app notification explaining the specific behavior detected | Permanent record, no active restriction |
| **2** | Throttle | Second violation within 7 days | Feature-specific rate limits (50% reduction) | 24 hours, then returns to level 1 |
| **3** | Flag for Review | Third violation OR single red flag | Account queued for human moderation review, reduced visibility (Tier D) | Until review completed |
| **4** | Temporary Suspension | Moderation review confirms violation | Account suspended for 7 days, user notified via email | 7 days |

Level 4 → next violation after reinstatement → permanent ban.

### 4.5 Socket.io Integration

Behavior monitoring hooks into existing Socket.io gateways (RTA Section 2) via NestJS interceptors:

```typescript
@Injectable()
export class BehaviorTrackingInterceptor implements NestInterceptor {
  constructor(
    @InjectQueue('behavior-analysis')
    private readonly behaviorQueue: Queue,
    private readonly redis: Redis,
  ) {}

  async intercept(context: ExecutionContext, next: CallHandler): Promise<Observable<any>> {
    const client = context.switchToWs().getClient();
    const userId = client.data.userId;
    const event = context.switchToWs().getData();
    const eventName = context.getHandler().name;

    // Lightweight rate check (no queue, no DB)
    const key = `ratelimit:${userId}:${eventName}`;
    const count = await this.redis.incr(key);
    if (count === 1) await this.redis.expire(key, 60);

    if (count > RATE_LIMITS[eventName]) {
      throw new WsException('Rate limited. Please slow down.');
    }

    // Queue for deeper analysis (async, non-blocking)
    await this.behaviorQueue.add('analyze', {
      userId,
      eventName,
      timestamp: Date.now(),
      metadata: event,
    });

    return next.handle();
  }
}
```

---

## Section 5: Photo Authenticity Detection

### 5.1 Purpose

Profile photos are the primary trust signal in dating. Fake photos (stock images, AI-generated, stolen from other users) undermine trust across the platform. This section defines detection mechanisms.

### 5.2 Stock Photo Detection

**Method:** Perceptual hashing (pHash) against known stock image databases.

| Component | Implementation |
|-----------|---------------|
| **Hash algorithm** | pHash (perceptual hash) — robust to resizing, minor cropping, compression |
| **Reference database** | Pre-computed hashes of top stock photo databases (Shutterstock, Getty, Unsplash) |
| **Storage** | Separate Redis set per 1M hash buckets for O(1) lookup |
| **Threshold** | Hamming distance < 10 = likely stock photo |
| **False positive handling** | Flag for human review, do not auto-reject |

**Implementation note:** Building a comprehensive stock photo hash database is a significant upfront effort. **Phase 1** uses reverse image search via a third-party API (e.g., TinEye API at $0.01/search). **Phase 2** builds an internal hash database from crawled sources.

### 5.3 AI-Generated Image Detection

AI-generated profile photos are increasingly common on dating platforms.

| Detection Signal | Method | Confidence |
|-----------------|--------|------------|
| **EXIF metadata** | Real photos have camera metadata; AI images often have none or have Photoshop/DALL-E signatures | Medium — savvy users strip EXIF |
| **GAN artifacts** | Frequency domain analysis for checkerboard patterns typical of GANs | Medium — improves with model updates |
| **Consistency checks** | Earring asymmetry, background text gibberish, finger count anomalies | Low — getting less reliable as AI improves |
| **AWS Rekognition Image Properties** | Analyzes image characteristics that distinguish photos from generated content | Medium |

**Recommended approach:** Use a third-party API specialized in AI image detection (e.g., Hive Moderation, Sensity). These services continuously update their models as generation techniques evolve.

**Cost:** ~$0.005 per image. At 10,000 profile photos/month = ~$50/month.

**Integration:**

```typescript
async function checkPhotoAuthenticity(
  imageUrl: string,
): Promise<PhotoAuthenticityResult> {
  const [exifResult, aiDetectionResult, stockCheckResult] = await Promise.allSettled([
    checkExifMetadata(imageUrl),
    checkAiGenerated(imageUrl),    // Third-party API
    checkStockPhoto(imageUrl),     // pHash or TinEye
  ]);

  return {
    hasExif: exifResult.status === 'fulfilled' ? exifResult.value.hasCamera : null,
    aiGeneratedProbability: aiDetectionResult.status === 'fulfilled'
      ? aiDetectionResult.value.probability
      : null,
    isStockPhoto: stockCheckResult.status === 'fulfilled'
      ? stockCheckResult.value.isStock
      : null,
    overallVerdict: calculateVerdict(exifResult, aiDetectionResult, stockCheckResult),
  };
}

type PhotoVerdict = 'authentic' | 'suspicious' | 'likely_fake';
```

### 5.4 Duplicate Profile Photo Detection

Detect when the same photo appears across multiple accounts — a strong signal of ban evasion or catfishing.

**Method:**
1. On photo upload, compute pHash
2. Store hash in `Media.perceptualHash` column
3. Query for similar hashes across other users' profile photos:

```sql
SELECT m.id, m.user_id, m.perceptual_hash
FROM media m
JOIN dating_profiles dp ON dp.id = m.dating_profile_id
WHERE m.user_id != $1
  AND hamming_distance(m.perceptual_hash, $2) < 8
LIMIT 5;
```

**Hamming distance function (PostgreSQL):**

```sql
CREATE FUNCTION hamming_distance(a bit(256), b bit(256))
RETURNS integer AS $$
  SELECT length(replace((a # b)::text, '0', ''))
$$ LANGUAGE sql IMMUTABLE STRICT;
```

**Threshold:**
- Distance < 5: Almost certainly the same photo → auto-flag for ban evasion check
- Distance 5-10: Likely similar → queue for human review
- Distance > 10: Different photos

### 5.5 Integration with Content Moderation

Photo authenticity results extend the existing `ContentModerationResult` entity (REGULATORY_REQUIREMENTS.md §4):

```typescript
// Extend flaggedCategories enum
enum ModerationCategory {
  // Existing (from REGULATORY_REQUIREMENTS.md):
  CSAM = 'csam',
  TERRORISM = 'terrorism',
  HATE_SPEECH = 'hate_speech',
  VIOLENCE = 'violence',
  NUDITY = 'nudity',
  SELF_HARM = 'self_harm',
  ILLEGAL_GOODS = 'illegal_goods',

  // New (photo authenticity):
  STOCK_PHOTO = 'stock_photo',
  AI_GENERATED = 'ai_generated',
  DUPLICATE_PHOTO = 'duplicate_photo',
}
```

---

## Section 6: Anti-Ban-Evasion System

### 6.1 The Problem

Banned users return. They create new accounts with different email addresses, sometimes different phone numbers, and attempt to rebuild. The goal is to detect these returning users **before they can harm others**, while minimizing false positives (legitimate users who coincidentally share some characteristics).

### 6.2 Enhanced Device Fingerprinting

The existing `Device` entity (TDD Section 2) stores FCM tokens and platform info. Ban evasion detection requires deeper fingerprinting.

**Fingerprint signals (collected via mobile app):**

| Signal | Collection Method | Stability | Evasion Difficulty |
|--------|-------------------|-----------|-------------------|
| **Screen resolution** | `MediaQuery.of(context).size` (Flutter) | Very stable | Very hard (requires different device) |
| **Timezone** | `DateTime.now().timeZoneOffset` | Stable | Easy (can be changed) |
| **Device model** | `DeviceInfoPlugin` | Very stable | Very hard |
| **OS version** | `DeviceInfoPlugin` | Changes with updates | Hard |
| **Language/locale** | `Platform.localeName` | Stable | Easy |
| **GPU renderer** | OpenGL renderer string | Very stable | Very hard |
| **Total storage** | `PathProviderPlugin` | Very stable | Very hard |
| **Installed app hash** | Hash of installed apps list (Android only) | Moderately stable | Medium |

**Composite fingerprint:**

```typescript
function generateFingerprint(signals: DeviceSignals): string {
  // Hash stable signals to create a fingerprint
  const stableInput = [
    signals.screenWidth,
    signals.screenHeight,
    signals.deviceModel,
    signals.gpuRenderer,
    signals.totalStorage,
  ].join('|');

  return createHash('sha256').update(stableInput).digest('hex');
}
```

The fingerprint is **not** a unique device ID (privacy concern, also impractical). It's a similarity signal — if two accounts share the same fingerprint AND other evasion signals, the probability of ban evasion is high.

### 6.3 IP Clustering

Group accounts by IP address ranges. When a banned account and a new account share an IP cluster, it raises a flag.

**Implementation:**

```typescript
// On login/registration, record IP
@Entity({ tableName: 'login_events' })
export class LoginEvent {
  @PrimaryKey({ type: 'uuid', defaultRaw: 'gen_random_uuid()' })
  id!: string;

  @ManyToOne(() => User)
  user!: User;

  @Property()
  ipAddress!: string;

  @Property()
  ipClassC!: string;  // First 3 octets: "192.168.1"

  @Property({ type: 'DateTimeType' })
  createdAt: Date = new Date();
}
```

**Clustering query:**

```sql
-- Find accounts sharing IP ranges with banned users
SELECT le.user_id, le.ip_class_c, COUNT(*) as shared_logins
FROM login_events le
WHERE le.ip_class_c IN (
  SELECT DISTINCT le2.ip_class_c
  FROM login_events le2
  JOIN users u ON u.id = le2.user_id
  WHERE u.status = 'BANNED'
    AND le2.created_at > NOW() - INTERVAL '90 days'
)
AND le.user_id NOT IN (SELECT id FROM users WHERE status = 'BANNED')
GROUP BY le.user_id, le.ip_class_c
HAVING COUNT(*) > 3;
```

**Limitations:** Shared IPs (university, workplace, public WiFi) produce false positives. IP clustering is a **corroborating signal**, not sufficient alone. It must combine with fingerprint or behavior similarity.

### 6.4 Behavior Similarity (pgvector)

Extend the pgvector integration (RTA Section 6) to embed behavioral patterns:

```
Behavioral embedding = [
  avg_swipe_rate,
  right_swipe_ratio,
  avg_message_length,
  avg_response_time_seconds,
  link_frequency,
  time_of_day_distribution[24],  // 24-hour activity histogram
  ... (normalized to 0-1 range)
]
```

This produces a fixed-dimension vector representing how a user behaves. Banned users who return tend to exhibit the same behavioral patterns even with a different identity.

```sql
-- Find accounts with behavior similar to banned users
SELECT u.id, 1 - (u.behavior_embedding <=> $1) AS similarity
FROM users u
WHERE u.status = 'ACTIVE'
  AND u.behavior_embedding IS NOT NULL
  AND 1 - (u.behavior_embedding <=> $1) > 0.85  -- High similarity threshold
ORDER BY similarity DESC
LIMIT 10;
```

**Threshold:** Cosine similarity > 0.85 = strong behavioral match. Combined with fingerprint match or IP cluster, this is high confidence for ban evasion.

### 6.5 Photo Reuse Detection

Cross-reference new profile photos against photos from banned accounts:

```sql
-- Check if new profile photo matches any banned account's photos
SELECT bf.original_user_id, m.perceptual_hash
FROM media m
JOIN banned_fingerprints bf ON bf.original_user_id = m.user_id
WHERE m.media_type = 'PROFILE_PHOTO'
  AND hamming_distance(m.perceptual_hash, $1) < 8;
```

This uses the same perceptual hashing from Section 5.4.

### 6.6 Combined Evasion Score

No single signal is sufficient. The system combines signals into an evasion probability:

| Signal | Weight | Match Criteria |
|--------|--------|---------------|
| **Fingerprint match** | 35 | Same composite fingerprint hash as banned account |
| **IP cluster** | 15 | Shared Class C with banned account (3+ overlapping logins) |
| **Behavior similarity** | 25 | pgvector cosine similarity > 0.85 with banned account |
| **Photo reuse** | 25 | pHash distance < 8 from banned account's photos |

```typescript
function calculateEvasionScore(signals: EvasionSignals): number {
  let score = 0;
  if (signals.fingerprintMatch) score += 35;
  if (signals.ipClusterMatch) score += 15;
  if (signals.behaviorSimilarity > 0.85) score += 25;
  if (signals.photoReuseDetected) score += 25;
  return score; // 0-100
}
```

### 6.7 Actions by Evasion Score

| Score | Action | Human Review Required |
|-------|--------|----------------------|
| **0-30** | No action | No |
| **30-50** | Auto-flag, reduce visibility to Tier D | Yes — within 48 hours |
| **50-75** | Shadow restriction (user doesn't know), priority moderation queue | Yes — within 24 hours |
| **75-100** | Immediate temporary suspension pending review | Yes — within 12 hours |

**Shadow restriction:** The account appears to function normally from the user's perspective, but:
- Their messages are only visible to themselves
- Their profile appears in 0% of other users' feeds
- Their marketplace listings are not shown in search results

This prevents the user from causing harm while the review is completed, and prevents them from immediately knowing they've been detected (which would trigger another evasion attempt).

> 📋 **Regulatory note:** Shadow restrictions must be disclosed within 72 hours per OSA transparency requirements (REGULATORY_REQUIREMENTS.md §2.1). The review timeline ensures this obligation is met.

---

## Section 7: Schema Additions

All entity definitions follow MikroORM patterns established in RTA Section 1.

### 7.1 PhoneVerification Entity (New)

Stores carrier lookup results. Separate from `Device` because one user might verify multiple phone numbers over their account lifetime.

```typescript
@Entity({ tableName: 'phone_verifications' })
export class PhoneVerification {
  @PrimaryKey({ type: 'uuid', defaultRaw: 'gen_random_uuid()' })
  id!: string;

  @ManyToOne(() => User)
  user!: User;

  @Index()
  @Property()
  userId!: string;

  @Property({ length: 20 })
  phoneNumber!: string;  // E.164 format

  @Enum(() => CarrierType)
  carrierType!: CarrierType;

  @Property({ length: 100, nullable: true })
  carrierName?: string;

  @Property({ length: 2 })
  countryCode!: string;

  @Property()
  isVoip!: boolean;

  @Property()
  isVerified!: boolean;  // OTP confirmed

  @Property({ type: 'DateTimeType', nullable: true })
  verifiedAt?: Date;

  @Property({ type: 'json', nullable: true })
  lookupRawResponse?: Record<string, unknown>;  // Full Twilio response for debugging

  @Property({ type: 'DateTimeType' })
  createdAt: Date = new Date();
}

enum CarrierType {
  MOBILE = 'mobile',
  VOIP = 'voip',
  LANDLINE = 'landline',
  UNKNOWN = 'unknown',
}
```

### 7.2 Device Entity Extensions

Add to existing `Device` entity (TDD Section 2):

```typescript
// Fingerprint for ban evasion detection
@Property({ length: 64, nullable: true })
fingerprintHash?: string;  // SHA-256 of stable device signals

@Enum(() => CarrierType)
@Property({ nullable: true })
carrierType?: CarrierType;  // From phone verification

@Property({ nullable: true })
isVoip?: boolean;

@Property({ type: 'DateTimeType' })
firstSeenAt: Date = new Date();

@Property({ type: 'smallint', default: 0 })
riskScore: number = 0;  // 0-100, updated by ban evasion check
```

### 7.3 BannedFingerprint Entity (New)

When an account is banned, its fingerprint is archived for future comparison.

```typescript
@Entity({ tableName: 'banned_fingerprints' })
export class BannedFingerprint {
  @PrimaryKey({ type: 'uuid', defaultRaw: 'gen_random_uuid()' })
  id!: string;

  @Property({ length: 64 })
  @Index()
  fingerprintHash!: string;

  @Property({ type: 'DateTimeType' })
  bannedAt!: Date;

  @Property({ length: 255 })
  reason!: string;

  @Property({ type: 'uuid' })
  originalUserId!: string;  // Reference only — account may be deleted

  @Property({ type: 'json', nullable: true })
  metadata?: Record<string, unknown>;  // IP ranges, behavioral embedding snapshot

  @Property({ type: 'DateTimeType' })
  createdAt: Date = new Date();
}
```

### 7.4 LoginEvent Entity (New)

Tracks login events for IP clustering analysis.

```typescript
@Entity({ tableName: 'login_events' })
export class LoginEvent {
  @PrimaryKey({ type: 'uuid', defaultRaw: 'gen_random_uuid()' })
  id!: string;

  @ManyToOne(() => User)
  user!: User;

  @Index()
  @Property()
  userId!: string;

  @Property({ length: 45 })
  ipAddress!: string;  // IPv4 or IPv6

  @Property({ length: 45 })
  @Index()
  ipClassC!: string;  // First 3 octets for clustering

  @Property({ length: 64, nullable: true })
  deviceFingerprintHash?: string;

  @Property({ type: 'DateTimeType' })
  createdAt: Date = new Date();
}
```

### 7.5 User Entity Extensions

Add to existing `User` entity:

```typescript
// Behavioral embedding for ban evasion detection (pgvector)
@Property({ columnType: 'vector(64)', nullable: true })
behaviorEmbedding?: number[];  // Lower dimension than content embeddings — behavioral signals are simpler

// VoIP restriction tracking
@Property({ default: false })
isVoipRestricted: boolean = false;

@Property({ type: 'DateTimeType', nullable: true })
voipRestrictionsLiftedAt?: Date;
```

### 7.6 Media Entity Extensions

Add to existing `Media` entity:

```typescript
// Perceptual hash for duplicate/stock photo detection
@Property({ columnType: 'bit(256)', nullable: true })
perceptualHash?: string;
```

### 7.7 Migration

```sql
-- Phone verifications table
CREATE TABLE phone_verifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  phone_number VARCHAR(20) NOT NULL,
  carrier_type VARCHAR(10) NOT NULL,
  carrier_name VARCHAR(100),
  country_code VARCHAR(2) NOT NULL,
  is_voip BOOLEAN NOT NULL DEFAULT FALSE,
  is_verified BOOLEAN NOT NULL DEFAULT FALSE,
  verified_at TIMESTAMPTZ,
  lookup_raw_response JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_phone_verifications_user ON phone_verifications (user_id);
CREATE INDEX idx_phone_verifications_phone ON phone_verifications (phone_number);

-- Device extensions
ALTER TABLE devices ADD COLUMN fingerprint_hash VARCHAR(64);
ALTER TABLE devices ADD COLUMN carrier_type VARCHAR(10);
ALTER TABLE devices ADD COLUMN is_voip BOOLEAN;
ALTER TABLE devices ADD COLUMN first_seen_at TIMESTAMPTZ NOT NULL DEFAULT NOW();
ALTER TABLE devices ADD COLUMN risk_score SMALLINT NOT NULL DEFAULT 0;
CREATE INDEX idx_devices_fingerprint ON devices (fingerprint_hash);

-- Banned fingerprints table
CREATE TABLE banned_fingerprints (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fingerprint_hash VARCHAR(64) NOT NULL,
  banned_at TIMESTAMPTZ NOT NULL,
  reason VARCHAR(255) NOT NULL,
  original_user_id UUID NOT NULL,
  metadata JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_banned_fingerprints_hash ON banned_fingerprints (fingerprint_hash);

-- Login events table
CREATE TABLE login_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  ip_address VARCHAR(45) NOT NULL,
  ip_class_c VARCHAR(45) NOT NULL,
  device_fingerprint_hash VARCHAR(64),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_login_events_user ON login_events (user_id);
CREATE INDEX idx_login_events_ip_class ON login_events (ip_class_c);
-- Partition by month for efficient cleanup of old data
-- (create partitions as part of monthly maintenance cron)

-- User extensions for safety pipeline
ALTER TABLE users ADD COLUMN behavior_embedding vector(64);
ALTER TABLE users ADD COLUMN is_voip_restricted BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE users ADD COLUMN voip_restrictions_lifted_at TIMESTAMPTZ;

-- Media extensions for photo authenticity
ALTER TABLE media ADD COLUMN perceptual_hash BIT(256);
CREATE INDEX idx_media_perceptual_hash ON media (perceptual_hash) WHERE perceptual_hash IS NOT NULL;

-- Hamming distance function
CREATE OR REPLACE FUNCTION hamming_distance(a bit(256), b bit(256))
RETURNS integer AS $$
  SELECT length(replace((a # b)::text, '0', ''))
$$ LANGUAGE sql IMMUTABLE STRICT;
```

---

## Section 8: BullMQ Job Definitions

These jobs extend the queue architecture defined in RTA Section 7.

### 8.1 Queue Registration

| Queue | Purpose | Concurrency | Retry | Schedule |
|-------|---------|-------------|-------|----------|
| **safety-pipeline** | Phone lookup, photo authenticity, device fingerprint | 5 | 3x exponential | On demand |
| **behavior-analysis** | Real-time behavior monitoring | 10 | 1x (fire-and-forget analysis) | On demand |
| **ban-evasion** | Evasion detection checks | 3 | 3x exponential | On demand + daily 04:00 UTC |

### 8.2 Job Definitions

#### `phone-carrier-lookup`

**Queue:** `safety-pipeline`
**Trigger:** User registration (after phone number entered, before OTP sent)
**Input:** `{ userId: string, phoneNumber: string }`
**Process:**
1. Call Twilio Lookup v2 with line type intelligence
2. Create `PhoneVerification` record
3. If VoIP: set `User.isVoipRestricted = true`, create `TrustSignal` with delta -20
4. If mobile: create `TrustSignal` with delta +40
5. If landline: reject registration (return error before OTP)
6. Queue `trust-score-recalc`

#### `behavior-analysis`

**Queue:** `behavior-analysis`
**Trigger:** Socket.io events, API requests (via interceptor)
**Input:** `{ userId: string, eventName: string, timestamp: number, metadata: Record<string, unknown> }`
**Process:**
1. Load behavior window from Redis (`behavior:{userId}:*`)
2. Check each detection rule (Section 4.2)
3. If threshold crossed:
   a. Load current escalation level from Redis
   b. Escalate if appropriate (Section 4.4)
   c. Create `TrustSignal` if trust impact warranted
   d. Apply immediate consequence (throttle, flag, suspend)
   e. Queue `trust-score-recalc` if trust signal created
4. Update behavior window in Redis

#### `photo-authenticity-scan`

**Queue:** `safety-pipeline`
**Trigger:** Profile photo upload
**Input:** `{ userId: string, mediaId: string, imageUrl: string }`
**Process:**
1. Compute perceptual hash, store in `Media.perceptualHash`
2. Check stock photo database (pHash comparison or TinEye API)
3. Check AI-generated probability (third-party API)
4. Check duplicate across other users (hamming distance query)
5. Create `ContentModerationResult` with appropriate flags
6. If suspicious: queue `ban-evasion-check` with photo match context
7. If duplicate with banned account: queue immediate review

#### `device-fingerprint-match`

**Queue:** `safety-pipeline`
**Trigger:** New device registration, device metadata update
**Input:** `{ userId: string, deviceId: string, fingerprintHash: string }`
**Process:**
1. Store fingerprint on `Device.fingerprintHash`
2. Check against `BannedFingerprint` table
3. If match found: queue `ban-evasion-check` with fingerprint context
4. Update `Device.riskScore` based on match confidence

#### `ban-evasion-check`

**Queue:** `ban-evasion`
**Trigger:** Fingerprint match, photo duplicate, suspicious behavior pattern, daily batch
**Input:** `{ userId: string, triggerType: string, context: Record<string, unknown> }`
**Process:**
1. Collect all evasion signals for user:
   - Fingerprint match against banned accounts
   - IP cluster overlap with banned accounts
   - Behavioral embedding similarity (pgvector)
   - Photo reuse detection
2. Calculate combined evasion score (Section 6.6)
3. Apply action based on score (Section 6.7)
4. If action taken: create `TrustSignal`, queue `trust-score-recalc`
5. Log result for moderation dashboard

#### `behavior-embedding-update`

**Queue:** `ban-evasion`
**Trigger:** Scheduled, weekly for active users
**Input:** `{ userId: string }`
**Process:**
1. Load behavioral metrics for last 30 days
2. Normalize into fixed-dimension vector (64 dimensions)
3. Store in `User.behaviorEmbedding`
4. No immediate action — used reactively by `ban-evasion-check`

---

## Appendix: Detection Scenario Walkthroughs

### Scenario A: VoIP Spam Account

```
Day 0: User registers with Google Voice number
  → phone-carrier-lookup: VoIP detected
  → TrustSignal: delta -20 (PHONE_VERIFIED_VOIP)
  → User.isVoipRestricted = true
  → Trust score: -10 (VoIP -20, email +10)
  → Visibility tier: D (restricted)

Day 0, Hour 2: User sends identical message to 5 different users
  → behavior-analysis: message repetition RED FLAG
  → Escalation: Level 0 → Level 3 (skip warning for red flag)
  → Account flagged for moderation review
  → Visibility: effectively zero (shadow restricted)

Day 0, Hour 4: Moderator reviews, confirms spam
  → Account suspended
  → BannedFingerprint record created
  → Device fingerprint archived
```

### Scenario B: Returning Banned User

```
Day 0: New account created with different email, new VoIP number
  → phone-carrier-lookup: VoIP detected (flag raised)
  → device-fingerprint-match: fingerprint matches banned account!
  → ban-evasion-check triggered:
    - Fingerprint match: +35
    - IP cluster match: +15 (same home IP)
    - No behavioral data yet: +0
    - No photo uploaded yet: +0
    - Evasion score: 50
  → Action: Shadow restriction, priority moderation queue

Day 0, Hour 1: User uploads profile photo
  → photo-authenticity-scan: pHash matches banned account photo!
  → ban-evasion-check re-triggered:
    - Fingerprint: +35
    - IP cluster: +15
    - Photo reuse: +25
    - Evasion score: 75
  → Action: Immediate temporary suspension pending review

Day 0, Hour 2: Moderator reviews, confirms ban evasion
  → Permanent ban
  → New fingerprint/photo hashes added to banned database
```

### Scenario C: Legitimate Google Fi User

```
Day 0: User registers with Google Fi number (classified as VoIP)
  → phone-carrier-lookup: VoIP detected
  → User.isVoipRestricted = true
  → Restrictions applied (25 daily match limit, etc.)

Day 0: User completes selfie verification (+30 trust)
Day 7: Device consistency bonus (+15 trust)
  → Trust score: 35 (VoIP -20, selfie +30, email +10, device +15)
  → Visibility tier: C

Day 30: Consistent good behavior, response rate 70%, zero reports
  → VoIP upgrade path met (Section 3.3, Option B)
  → User.isVoipRestricted = false
  → Limits restored to mobile-equivalent
  → Trust score: 55 (behavioral signals compensate)
  → Visibility tier: B
```
