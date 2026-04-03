# Kuwboo: Trust Score Engine

**Created:** March 9, 2026
**Version:** 1.0
**Purpose:** Trust scoring, profile quality, visibility tiers, and recommendation engine
**Audience:** Phil Cutting (LionPro Dev) — implementation guide
**Status:** Greenfield rebuild — extends the 32-entity schema

**Companion Documents:**
- [TECHNICAL_DESIGN.md](./TECHNICAL_DESIGN.md) — 32-entity schema, ORM evaluation, feed architecture, state machines
- [REALTIME_ARCHITECTURE.md](./REALTIME_ARCHITECTURE.md) — MikroORM adaptation, Socket.io gateways, pgvector, BullMQ
- [REGULATORY_REQUIREMENTS.md](./REGULATORY_REQUIREMENTS.md) — UK + USA regulatory compliance (OSA, GDPR, COPPA, BIPA)
- [SAFETY_PIPELINE.md](./SAFETY_PIPELINE.md) — phone intelligence, behavior monitoring, anti-ban-evasion, photo authenticity

---

## How to Read This Document

This document defines the **trust and reputation layer** that sits between the raw user data (defined in TECHNICAL_DESIGN.md) and the feed/recommendation system (TDD Section 4). It answers:

- **How** users earn trust (Section 2)
- **How** dating profiles are scored for quality (Section 3)
- **How** trust and quality map to visibility tiers (Section 4)
- **How** the recommendation engine combines trust, quality, and compatibility (Section 5)
- **How** new users get a fair start (Section 6)
- **What** users see about their own scores (Section 7)
- **What** schema changes are needed (Section 8)
- **What** BullMQ jobs power the recalculation pipeline (Section 9)

Cross-references to TECHNICAL_DESIGN.md use "TDD Section N". Cross-references to REALTIME_ARCHITECTURE.md use "RTA Section N".

---

## Table of Contents

- [Section 1: Purpose and Design Decision](#section-1-purpose-and-design-decision)
- [Section 2: Trust Score Engine](#section-2-trust-score-engine)
- [Section 3: Profile Quality Score](#section-3-profile-quality-score)
- [Section 4: Visibility Tier System](#section-4-visibility-tier-system)
- [Section 5: Recommendation Engine](#section-5-recommendation-engine)
- [Section 6: New User Boost](#section-6-new-user-boost)
- [Section 7: User Transparency Dashboard](#section-7-user-transparency-dashboard)
- [Section 8: Schema Additions](#section-8-schema-additions)
- [Section 9: BullMQ Job Definitions](#section-9-bullmq-job-definitions)

---

## Section 1: Purpose and Design Decision

### Why a Trust Layer

Kuwboo has four distinct modules (video, marketplace, dating, social discovery) sharing one user base. A user's behavior in marketplace doesn't necessarily predict their behavior in dating. A trust system needs to be **platform-wide** for identity signals (is this a real person?) but **module-specific** for behavioral reputation (is this person a good seller? a respectful dater?).

### Architecture Decision: Base Score + Reputation Facets

```
User.trustScore          → 0-100 base (phone type, email verified, device consistency, selfie, account age, reports)
User.socialReputation    → 0-100 (engagement quality, response rate, connection health)
User.sellerReputation    → 0-100 (transaction completion, buyer ratings, dispute rate, listing quality)
```

**Why three scores instead of one:**
- A marketplace scammer can have low `sellerReputation` while having decent `socialReputation` from genuine social interactions
- Dating visibility uses `trustScore + socialReputation` (identity trust + social behavior)
- Marketplace search ranking uses `trustScore + sellerReputation` (identity trust + seller track record)
- Video feed ranking uses `trustScore + socialReputation` (identity trust + content engagement quality)

**Why not per-module trust scores:**
- The base `trustScore` captures identity verification signals that are universal (phone type, device consistency, selfie). Duplicating these across modules creates sync problems
- Reputation facets capture module-specific behavior. Two facets cover all four modules without creating a proliferation of scores that are hard to explain to users

---

## Section 2: Trust Score Engine

### 2.1 Base Trust Score (0-100)

The base trust score measures **how confident we are that this is a real, unique human** — not whether they're a "good" user. It's computed from identity verification signals only.

#### Signal Weights

| Signal | Weight | Condition | Rationale |
|--------|--------|-----------|-----------|
| **Phone type: mobile** | +40 | Carrier type = `mobile` | Mobile numbers require real SIM cards; hardest to fake at scale |
| **Selfie verification** | +30 | Photo verification passed | Face-to-photo match confirms physical identity |
| **Device consistency** | +15 | Same device for 7+ days | Real users have stable devices; fraudsters cycle rapidly |
| **Email verified** | +10 | Email confirmed via link click | Weak signal (email is cheap) but still friction |
| **Account age** | +5 | Account age 30+ days | Time investment; harder to rebuild reputation after ban |
| **VoIP phone penalty** | -20 | Carrier type = `voip` | VoIP numbers are cheap, disposable, and the primary tool for ban evasion |
| **Report penalty** | -40 | Upheld report (moderation reviewed, confirmed) | Direct evidence of bad behavior |
| **Dormancy penalty** | -10 | No activity for 30+ days | Accounts that go dormant may have been compromised or abandoned |

**Maximum achievable: 100** (mobile +40, selfie +30, device consistency +15, email +10, account age +5)
**Minimum floor: 0** (scores cannot go negative; clamped to 0-100 range)

#### Score Calculation

```typescript
function calculateTrustScore(signals: TrustSignal[]): number {
  let score = 0;

  for (const signal of signals) {
    score += signal.delta;
  }

  // Clamp to 0-100
  return Math.max(0, Math.min(100, score));
}
```

The score is the sum of all active `TrustSignal` records for a user. Signals are append-only — a report penalty adds a new signal with `delta: -40`, it doesn't modify the phone verification signal.

#### Score Ranges

| Range | Label | Platform Behavior |
|-------|-------|-------------------|
| **0-30** | High Risk | Limited daily actions, mandatory photo verification for dating, increased moderation queue priority, no marketplace transactions over £50 |
| **30-60** | Medium | Standard limits, nudge to complete verification, standard moderation priority |
| **60-100** | Trusted | Full feature access, higher daily limits, lower moderation priority, eligible for "Verified" badge display |

### 2.2 Social Reputation (0-100)

Measures how the user behaves in social contexts (dating, video, social stumble).

| Signal | Weight | Measurement |
|--------|--------|-------------|
| **Response rate** | 30 | % of received messages replied to within 24h (minimum 10 received) |
| **Conversation depth** | 25 | Average messages per conversation thread (deeper = better) |
| **Report rate (incoming)** | -25 | % of interactions that result in reports against this user |
| **Block rate (incoming)** | -20 | % of match/follows that lead to being blocked |
| **Content engagement quality** | 20 | Ratio of likes/comments received to content posted (creates value, not noise) |

**Computation:** Weighted average, normalized to 0-100. Requires minimum interaction thresholds before each signal contributes (avoids penalizing users with small sample sizes).

```typescript
function calculateSocialReputation(metrics: SocialMetrics): number {
  const signals: { value: number; weight: number; minSample: number; actual: number }[] = [
    { value: metrics.responseRate, weight: 30, minSample: 10, actual: metrics.messagesReceived },
    { value: metrics.avgConversationDepth / 20 * 100, weight: 25, minSample: 5, actual: metrics.conversationCount },
    { value: 100 - (metrics.reportRate * 100), weight: 25, minSample: 20, actual: metrics.interactionCount },
    { value: 100 - (metrics.blockRate * 100), weight: 20, minSample: 20, actual: metrics.matchCount },
    { value: Math.min(metrics.engagementRatio * 20, 100), weight: 20, minSample: 5, actual: metrics.contentPosted },
  ];

  let totalWeight = 0;
  let weightedSum = 0;

  for (const s of signals) {
    if (s.actual >= s.minSample) {
      weightedSum += s.value * s.weight;
      totalWeight += s.weight;
    }
  }

  // Default to 50 (neutral) if insufficient data
  if (totalWeight === 0) return 50;

  return Math.max(0, Math.min(100, weightedSum / totalWeight));
}
```

### 2.3 Seller Reputation (0-100)

Measures marketplace reliability.

| Signal | Weight | Measurement |
|--------|--------|-------------|
| **Transaction completion** | 30 | % of accepted offers that result in completed transactions |
| **Buyer ratings** | 25 | Average rating from buyers (1-5 stars, normalized to 0-100) |
| **Dispute rate** | -25 | % of transactions that enter dispute resolution |
| **Listing quality** | 10 | % of listings with 3+ photos, complete description, accurate category |
| **Response time** | 10 | Average time to respond to buyer inquiries |

**Computation:** Same weighted-average pattern as social reputation, with module-appropriate thresholds.

### 2.4 Decay Mechanics

Trust and reputation scores decay when an account becomes inactive, because historical good behavior doesn't guarantee future behavior — especially if an account has been compromised or sold.

| Score | Dormancy Threshold | Decay Rate | Minimum Floor |
|-------|--------------------|------------|---------------|
| **trustScore** | 30 days no login | -2 points per week | 20 (verified signals don't expire, only behavioral trust decays) |
| **socialReputation** | 14 days no social activity | -3 points per week | 30 |
| **sellerReputation** | 30 days no marketplace activity | -2 points per week | 30 |

**VoIP accounts decay faster:** VoIP-registered accounts have a 2x decay multiplier (e.g., trustScore decays at -4/week instead of -2/week) because VoIP numbers have a higher probability of being disposable.

**Decay stops immediately** when the user resumes activity. Scores recover through normal positive signal accumulation, not instant restoration.

### 2.5 Recalculation Triggers

Trust scores are **not** recalculated on every request. They update when something meaningful changes:

| Trigger | Job | Priority |
|---------|-----|----------|
| User completes phone verification | `trust-score-recalc` | High |
| User completes selfie verification | `trust-score-recalc` | High |
| User completes email verification | `trust-score-recalc` | Medium |
| Moderation upholds a report against user | `trust-score-recalc` | High |
| Device change detected | `trust-score-recalc` | Medium |
| Daily decay check (scheduled) | `trust-score-decay` | Low |
| Transaction completed (marketplace) | `seller-reputation-update` | Medium |
| Conversation metrics updated (batch) | `social-reputation-update` | Low |

All triggers dispatch BullMQ jobs (see Section 9).

---

## Section 3: Profile Quality Score (Dating-Specific)

### 3.1 Purpose

The profile quality score measures **how much effort a user has put into their dating profile** and how attractive it is to potential matches. This is distinct from trust (which measures identity confidence) and social reputation (which measures behavior quality).

A user with a high trust score but a low-quality profile (no bio, blurry photos) should rank lower in dating recommendations than a user with an equally high trust score and a well-crafted profile.

### 3.2 Signals and Weights

| Signal | Weight | Scoring Method |
|--------|--------|----------------|
| **Photo count** | 15 | 0 photos = 0, 1 = 30, 2 = 60, 3 = 80, 4+ = 100 |
| **Photo quality** | 20 | AI scoring: resolution, lighting, face visible, not blurry (0-100 per photo, averaged) |
| **Face detection** | 15 | At least 1 photo with a clearly detected face = 100, none = 0 |
| **Bio completeness** | 15 | Character count: 0 = 0, 1-50 = 30, 51-150 = 70, 151+ = 100 |
| **Prompts answered** | 10 | 0 = 0, 1 = 40, 2 = 70, 3+ = 100 |
| **Match-to-conversation ratio** | 15 | % of matches where user sent first message (minimum 5 matches) |
| **Response rate** | 10 | % of received messages replied to within 24h (minimum 10 received) |

### 3.3 Formula

```typescript
function calculateProfileQualityScore(metrics: ProfileQualityMetrics): number {
  const signals = [
    { value: photoCountScore(metrics.photoCount), weight: 15 },
    { value: metrics.avgPhotoQuality, weight: 20 },
    { value: metrics.hasFaceDetection ? 100 : 0, weight: 15 },
    { value: bioCompletenessScore(metrics.bioLength), weight: 15 },
    { value: promptScore(metrics.promptsAnswered), weight: 10 },
    { value: metrics.matchToConversationRatio * 100, weight: 15, minSample: 5, actual: metrics.totalMatches },
    { value: metrics.responseRate * 100, weight: 10, minSample: 10, actual: metrics.messagesReceived },
  ];

  let totalWeight = 0;
  let weightedSum = 0;

  for (const s of signals) {
    // Skip behavioral signals without enough data
    if ('minSample' in s && s.actual < s.minSample) continue;
    weightedSum += s.value * s.weight;
    totalWeight += s.weight;
  }

  return Math.max(0, Math.min(100, weightedSum / totalWeight));
}
```

### 3.4 Photo Quality Assessment

Photo quality is assessed via AWS Rekognition (already in the stack for OSA compliance — see REGULATORY_REQUIREMENTS.md §2.1.1):

| Check | Rekognition API | Scoring |
|-------|-----------------|---------|
| Face detected | `DetectFaces` | Boolean: face present with confidence > 90% |
| Image quality | `DetectFaces` → Quality attribute | Brightness + Sharpness (0-100) |
| Sunglasses/obscured | `DetectFaces` → Attributes | Penalty if face is obscured in all photos |
| Multiple people | `DetectFaces` → FaceDetails count | Primary photo should have exactly 1 face |

> 📋 **Regulatory note:** Photo analysis data (face geometry) triggers BIPA obligations for Illinois users. The photo quality check uses Rekognition's moderation/quality endpoints — NOT facial recognition for identity matching. Face *detection* (is a face present?) has different regulatory treatment than face *recognition* (whose face is this?). See REGULATORY_REQUIREMENTS.md §3.4 (BIPA) for consent requirements.

### 3.5 Storage

Profile quality score is stored on `DatingProfile` (see Section 8 for entity definition):

```typescript
@Property({ type: 'smallint', default: 0 })
profileQualityScore: number;  // 0-100

@Property({ type: 'DateTimeType', nullable: true })
profileQualityUpdatedAt?: Date;
```

---

## Section 4: Visibility Tier System

### 4.1 Purpose

Visibility tiers control **how often** a user's content or dating profile appears in other users' feeds. Higher-tier users get more exposure. The tier system is the mechanism through which trust and quality scores translate to concrete user experience impact.

### 4.2 Tier Definitions

| Tier | Trust Score | Profile Quality (dating) | Feed Exposure | Description |
|------|-------------|--------------------------|---------------|-------------|
| **A** | 70-100 | 70-100 | Full — appears in all relevant feeds | Verified, high-quality, active users |
| **B** | 50-69 | 50-69 | Standard — appears in most feeds | Normal users with decent engagement |
| **C** | 30-49 | 30-49 | Reduced — appears less frequently | New or low-engagement users building history |
| **D** | 0-29 | 0-29 | Limited — severely restricted visibility | High-risk accounts, pending review |

### 4.3 Tier Calculation

For **dating** (where profile quality matters):

```typescript
function calculateVisibilityTier(
  trustScore: number,
  socialReputation: number,
  profileQualityScore: number,
): VisibilityTier {
  // Combined score: trust + social behavior + profile effort
  const combined = trustScore * 0.4 + socialReputation * 0.3 + profileQualityScore * 0.3;

  if (combined >= 70) return VisibilityTier.A;
  if (combined >= 50) return VisibilityTier.B;
  if (combined >= 30) return VisibilityTier.C;
  return VisibilityTier.D;
}
```

For **non-dating modules** (video, social, marketplace):

```typescript
function calculateContentVisibilityTier(
  trustScore: number,
  moduleReputation: number, // socialReputation or sellerReputation
): VisibilityTier {
  const combined = trustScore * 0.5 + moduleReputation * 0.5;

  if (combined >= 70) return VisibilityTier.A;
  if (combined >= 50) return VisibilityTier.B;
  if (combined >= 30) return VisibilityTier.C;
  return VisibilityTier.D;
}
```

### 4.4 Feed Exposure Mapping

The tier system determines which users **see** which other users in their feeds:

| Viewer's Tier | Sees Content From |
|---------------|-------------------|
| **A** | A, B |
| **B** | A, B, C |
| **C** | A, B, C |
| **D** | A, B, C (but D users are rarely shown to others) |

**Key principle:** Higher-tier users see fewer low-quality accounts. Lower-tier users still see high-quality content (it motivates them to improve). Tier D users can see content but are rarely shown to others — this creates natural incentive to verify and engage.

**Implementation in FeedRepository:**

This extends the existing `FeedRepository.findForUser()` query (TDD Section 4):

```typescript
// In FeedRepository.findForUser(), add tier filtering:
if (viewerTier === VisibilityTier.A) {
  qb.andWhere('creator.visibilityTier IN (:...tiers)', {
    tiers: [VisibilityTier.A, VisibilityTier.B],
  });
} else {
  qb.andWhere('creator.visibilityTier IN (:...tiers)', {
    tiers: [VisibilityTier.A, VisibilityTier.B, VisibilityTier.C],
  });
}
```

### 4.5 Tier Transition Rules

Tiers are not updated in real-time — they recalculate on a schedule and on significant events:

| Trigger | Recalculation |
|---------|---------------|
| Trust score change > 5 points | Immediate via BullMQ job |
| Profile quality score update | Immediate via BullMQ job |
| Daily batch | All users, 03:00 UTC |

**Hysteresis:** To prevent users from bouncing between tiers on small fluctuations, a user must exceed the tier boundary by **3 points** to move up, but drops immediately when falling below. Example: a user at Tier B (combined 50) must reach 53 to move to Tier A threshold range, but drops from A to B the moment they fall below 70.

---

## Section 5: Recommendation Engine

### 5.1 Combined Visibility Score

The recommendation engine combines trust, profile quality, and compatibility into a single ranking score for feed ordering:

```
visibility_score = trust_score * 0.4 + profile_quality_score * 0.3 + compatibility_score * 0.3
```

This score determines **ordering within a feed** — which content appears first. The visibility tier (Section 4) determines **whether content appears at all**. Both work together.

### 5.2 Integration with Existing Feed Architecture

The existing feed query (TDD Section 4, `FeedRepository.findForUser()`) uses cursor-based pagination with basic ordering by `createdAt`. The recommendation engine extends this with a composite score:

```typescript
// Extended ordering in FeedRepository.findForUser()
qb.addSelect(
  `(creator.trust_score * 0.4 + :profileWeight * dp.profile_quality_score + :compatWeight * :compatScore)`,
  'visibility_score',
)
.setParameters({
  profileWeight: tab === 'dating' ? 0.3 : 0,
  compatWeight: tab === 'dating' ? 0.3 : 0,
  compatScore: compatibilityScore, // Pre-computed or 0 for non-dating
})
.orderBy('visibility_score', 'DESC')
.addOrderBy('content.createdAt', 'DESC'); // Tiebreaker
```

For non-dating feeds, the formula simplifies to trust-weighted chronological ordering:

```
feed_score = trust_score * 0.3 + recency_score * 0.5 + engagement_score * 0.2
```

Where `recency_score` decays exponentially from 100 (just posted) to 0 (7+ days old) and `engagement_score` is normalized like/comment count.

### 5.3 Compatibility Signals (Dating-Specific)

| Signal | Weight | Source |
|--------|--------|--------|
| **Location proximity** | 25 | PostGIS `ST_DWithin` on User.lastLocation vs preference `distanceKm` |
| **Age preference overlap** | 20 | Bidirectional: both users must be within each other's age range |
| **Shared interests** | 15 | Tag overlap on DatingProfile preferences (JSONB) |
| **Swipe history compatibility** | 15 | Users who liked similar profiles tend to be compatible |
| **pgvector bio similarity** | 15 | Cosine similarity on dating profile embeddings (RTA Section 6) |
| **Activity pattern match** | 10 | Users active at similar times are more likely to have real conversations |

```typescript
function calculateCompatibility(viewer: DatingProfile, candidate: DatingProfile): number {
  let score = 0;
  let totalWeight = 0;

  // Location proximity (25)
  const distance = calculateDistance(viewer.user.lastLocation, candidate.user.lastLocation);
  const maxDistance = Math.min(viewer.preferenceDistanceKm, candidate.preferenceDistanceKm);
  if (distance <= maxDistance) {
    score += (1 - distance / maxDistance) * 25;
    totalWeight += 25;
  }

  // Age preference overlap (20) — bidirectional check
  const viewerAge = calculateAge(viewer.user.dateOfBirth);
  const candidateAge = calculateAge(candidate.user.dateOfBirth);
  if (
    candidateAge >= viewer.preferenceAgeMin && candidateAge <= viewer.preferenceAgeMax &&
    viewerAge >= candidate.preferenceAgeMin && viewerAge <= candidate.preferenceAgeMax
  ) {
    score += 20;
    totalWeight += 20;
  }

  // Shared interests (15)
  const overlap = intersect(viewer.interests, candidate.interests);
  score += Math.min(overlap.length / 3, 1) * 15;
  totalWeight += 15;

  // pgvector bio similarity (15)
  // Computed separately via SQL: 1 - (viewer.embedding <=> candidate.embedding)
  // Passed in as a pre-computed value

  // ... remaining signals

  return totalWeight > 0 ? (score / totalWeight) * 100 : 50;
}
```

### 5.4 pgvector Integration for Recommendations

Extends RTA Section 6 (pgvector Integration). Dating profile embeddings are generated from:

```
Embedding input = bio + " " + prompts.map(p => p.answer).join(" ")
```

The embedding is stored on a dedicated column on `DatingProfile` (not on `Content`, since dating profiles are not in the content hierarchy — see TDD Section 2):

```typescript
@Property({ columnType: 'vector(1536)', nullable: true })
bioEmbedding?: number[];
```

**Recommendation query pattern:**

```sql
SELECT dp.*, u.trust_score,
       1 - (dp.bio_embedding <=> $1) AS bio_similarity
FROM dating_profiles dp
JOIN users u ON u.id = dp.user_id
WHERE dp.status = 'ACTIVE'
  AND dp.visibility_tier IN ('A', 'B')
  AND u.id != $2
  AND ST_DWithin(u.last_location, $3::geography, $4 * 1000)
ORDER BY (
  u.trust_score * 0.004 +
  dp.profile_quality_score * 0.003 +
  (1 - (dp.bio_embedding <=> $1)) * 0.003
) DESC
LIMIT 20;
```

---

## Section 6: New User Boost

### 6.1 Problem

New users have no trust score history, no engagement metrics, and an empty profile. Without intervention, they'd land in Tier C/D and get minimal visibility — creating a cold-start problem where they can't build a reputation because nobody sees them.

### 6.2 Boost Mechanics

| Parameter | Value | Rationale |
|-----------|-------|-----------|
| **Duration** | 72 hours from first profile completion | Long enough to collect meaningful data, short enough to not be gameable |
| **Visibility override** | Tier B (regardless of actual tier) | Gets new users seen without putting them alongside fully verified users |
| **Activation condition** | Profile is 50%+ complete (has photo, bio, and at least 1 preference set) | Prevents empty profiles from getting boosted |
| **Daily impression cap** | 2x normal Tier B exposure | More chances to be seen, but not overwhelming the feed |
| **Ends early if** | User receives 2+ upheld reports OR fails photo verification | Bad actors don't get a full 72-hour runway |

### 6.3 Data Collection During Boost

The boost window is when the system collects initial signals for permanent scoring:

| Signal | Collected During Boost | Used For |
|--------|----------------------|----------|
| Swipe patterns | Yes | Social reputation baseline |
| Message response rate | Yes | Social reputation baseline |
| Photo verification completion | Yes | Trust score |
| Device consistency | Yes | Trust score |
| Block/report rate from others | Yes | Social reputation + trust score |

### 6.4 Transition to Normal Scoring

When the boost expires:

1. Calculate initial `trustScore` from signals collected during boost
2. Calculate initial `socialReputation` from behavioral data collected during boost
3. Calculate `profileQualityScore` from profile state at boost expiry
4. Compute visibility tier normally (Section 4)
5. Remove the `newUserBoostExpiresAt` override
6. Queue a `visibility-tier-transition` BullMQ job

If the user ends up in a lower tier than B after the boost, the transition is immediate — no taper. The boost is a data-collection window, not an earned privilege.

### 6.5 Schema

```typescript
// On DatingProfile entity:
@Property({ type: 'DateTimeType', nullable: true })
newUserBoostExpiresAt?: Date;  // null = no active boost
```

---

## Section 7: User Transparency Dashboard

### 7.1 Design Principle

Users should understand **what they can do to improve** without understanding the algorithm. Exposing raw scores creates gaming incentives. Hiding everything creates distrust. The middle ground is showing qualitative indicators with actionable improvement paths.

### 7.2 What Users See

| Indicator | Displayed As | Source |
|-----------|-------------|--------|
| **Trust level** | Badge: "Verified" / "Good Standing" / "Building Trust" | trustScore: 60+ / 30-59 / 0-29 |
| **Profile completeness** | Progress bar: "85% complete" | profileQualityScore signals (photo count, bio, prompts) |
| **Response rate** | "You reply to 78% of messages" | Direct metric from socialReputation computation |
| **Photo quality** | "Your photos look great!" / "Try adding a clearer photo" | Photo quality sub-score from profileQualityScore |
| **Verification status** | Checkmarks: Phone ✓ Email ✓ Selfie ✗ | Individual verification status booleans |

### 7.3 What Users Do NOT See

- Raw numeric trust score (0-100)
- Visibility tier assignment (A/B/C/D)
- Algorithm weights or formulas
- Comparison to other users
- Seller/social reputation scores as numbers
- Decay rates or dormancy penalties

### 7.4 Improvement Suggestions

The dashboard shows contextual prompts based on what would improve the user's scores the most:

| Current State | Suggestion | Impact |
|---------------|-----------|--------|
| No selfie verification | "Verify your identity to build trust" | +30 trust score |
| VoIP phone number | "Switch to a mobile number for full access" | +60 trust score delta (+40 mobile, remove -20 VoIP) |
| 1 photo on dating profile | "Add more photos — profiles with 3+ photos get 2x more matches" | +50 profile quality improvement |
| Empty bio | "Write a short bio — even 2-3 sentences helps" | +15 profile quality improvement |
| Low response rate | "Try replying to more messages — it helps your visibility" | Social reputation improvement |

### 7.5 API Endpoint

```typescript
// GET /users/me/trust-dashboard
interface TrustDashboardResponse {
  trustLevel: 'verified' | 'good_standing' | 'building_trust';
  profileCompleteness: number;  // 0-100 percentage
  responseRate: number | null;  // null if insufficient data
  photoQualityIndicator: 'great' | 'good' | 'needs_improvement' | null;
  verifications: {
    phone: boolean;
    email: boolean;
    selfie: boolean;
  };
  suggestions: Array<{
    type: string;
    message: string;
    priority: 'high' | 'medium' | 'low';
  }>;
}
```

---

## Section 8: Schema Additions

All entity definitions follow MikroORM patterns established in RTA Section 1 (Data Mapper, decorators, Unit of Work).

### 8.1 User Entity Extensions

Add to existing `User` entity (TDD Section 2):

```typescript
// Trust and reputation scores
@Property({ type: 'smallint', default: 0 })
trustScore: number;  // 0-100

@Property({ type: 'smallint', default: 50 })
socialReputation: number;  // 0-100, default 50 (neutral)

@Property({ type: 'smallint', default: 50 })
sellerReputation: number;  // 0-100, default 50 (neutral)

@Property({ type: 'DateTimeType', nullable: true })
trustUpdatedAt?: Date;

@Enum(() => VisibilityTier)
visibilityTier: VisibilityTier = VisibilityTier.C;  // Default for new users
```

```typescript
enum VisibilityTier {
  A = 'A',
  B = 'B',
  C = 'C',
  D = 'D',
}
```

### 8.2 DatingProfile Entity Extensions

Add to existing `DatingProfile` entity (TDD Section 2):

```typescript
@Property({ type: 'smallint', default: 0 })
profileQualityScore: number;  // 0-100

@Property({ type: 'DateTimeType', nullable: true })
profileQualityUpdatedAt?: Date;

@Property({ type: 'DateTimeType', nullable: true })
newUserBoostExpiresAt?: Date;  // null = no active boost

@Property({ columnType: 'vector(1536)', nullable: true })
bioEmbedding?: number[];  // pgvector embedding of bio + prompts
```

### 8.3 TrustSignal Entity (New)

Append-only audit log of every trust score change. This provides transparency, debuggability, and the ability to recalculate scores from scratch.

```typescript
@Entity({ tableName: 'trust_signals' })
export class TrustSignal {
  @PrimaryKey({ type: 'uuid', defaultRaw: 'gen_random_uuid()' })
  id!: string;

  @ManyToOne(() => User)
  user!: User;

  @Index()
  @Property()
  userId!: string;

  @Enum(() => TrustSignalType)
  signalType!: TrustSignalType;

  @Property({ type: 'smallint' })
  delta!: number;  // Can be positive or negative

  @Property({ length: 255, nullable: true })
  source?: string;  // e.g., "twilio-lookup", "rekognition", "moderation-report-123"

  @Property({ type: 'json', nullable: true })
  metadata?: Record<string, unknown>;  // Additional context (carrier name, report id, etc.)

  @Property({ type: 'DateTimeType' })
  createdAt: Date = new Date();
}

enum TrustSignalType {
  PHONE_VERIFIED_MOBILE = 'phone_verified_mobile',
  PHONE_VERIFIED_VOIP = 'phone_verified_voip',
  EMAIL_VERIFIED = 'email_verified',
  SELFIE_VERIFIED = 'selfie_verified',
  DEVICE_CONSISTENCY = 'device_consistency',
  ACCOUNT_AGE_BONUS = 'account_age_bonus',
  REPORT_UPHELD = 'report_upheld',
  DORMANCY_DECAY = 'dormancy_decay',
  VOIP_DECAY = 'voip_decay',
  MANUAL_ADJUSTMENT = 'manual_adjustment',  // Admin override
}
```

**Index:**

```sql
CREATE INDEX idx_trust_signals_user_created
  ON trust_signals (user_id, created_at DESC);
```

### 8.4 ProfileQualityMetric Entity (New)

Tracks individual quality measurements over time. Enables trend analysis and debugging.

```typescript
@Entity({ tableName: 'profile_quality_metrics' })
export class ProfileQualityMetric {
  @PrimaryKey({ type: 'uuid', defaultRaw: 'gen_random_uuid()' })
  id!: string;

  @ManyToOne(() => User)
  user!: User;

  @Index()
  @Property()
  userId!: string;

  @Enum(() => ProfileMetricType)
  metricType!: ProfileMetricType;

  @Property({ type: 'smallint' })
  value!: number;  // 0-100

  @Property({ type: 'json', nullable: true })
  metadata?: Record<string, unknown>;  // e.g., { photoCount: 4, avgQuality: 82 }

  @Property({ type: 'DateTimeType' })
  measuredAt: Date = new Date();
}

enum ProfileMetricType {
  PHOTO_COUNT = 'photo_count',
  PHOTO_QUALITY = 'photo_quality',
  FACE_DETECTION = 'face_detection',
  BIO_COMPLETENESS = 'bio_completeness',
  PROMPTS_ANSWERED = 'prompts_answered',
  MATCH_TO_CONVERSATION = 'match_to_conversation',
  RESPONSE_RATE = 'response_rate',
}
```

### 8.5 Migration

```sql
-- Trust score columns on users
ALTER TABLE users ADD COLUMN trust_score SMALLINT NOT NULL DEFAULT 0;
ALTER TABLE users ADD COLUMN social_reputation SMALLINT NOT NULL DEFAULT 50;
ALTER TABLE users ADD COLUMN seller_reputation SMALLINT NOT NULL DEFAULT 50;
ALTER TABLE users ADD COLUMN trust_updated_at TIMESTAMPTZ;
ALTER TABLE users ADD COLUMN visibility_tier VARCHAR(1) NOT NULL DEFAULT 'C';
CREATE INDEX idx_users_visibility_tier ON users (visibility_tier);
CREATE INDEX idx_users_trust_score ON users (trust_score);

-- Profile quality columns on dating_profiles
ALTER TABLE dating_profiles ADD COLUMN profile_quality_score SMALLINT NOT NULL DEFAULT 0;
ALTER TABLE dating_profiles ADD COLUMN profile_quality_updated_at TIMESTAMPTZ;
ALTER TABLE dating_profiles ADD COLUMN new_user_boost_expires_at TIMESTAMPTZ;
ALTER TABLE dating_profiles ADD COLUMN bio_embedding vector(1536);

CREATE INDEX idx_dating_profiles_quality ON dating_profiles (profile_quality_score);
CREATE INDEX idx_dating_profiles_bio_embedding_hnsw
  ON dating_profiles USING hnsw (bio_embedding vector_cosine_ops)
  WITH (m = 16, ef_construction = 200);

-- Trust signals table
CREATE TABLE trust_signals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  signal_type VARCHAR(50) NOT NULL,
  delta SMALLINT NOT NULL,
  source VARCHAR(255),
  metadata JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_trust_signals_user_created ON trust_signals (user_id, created_at DESC);

-- Profile quality metrics table
CREATE TABLE profile_quality_metrics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  metric_type VARCHAR(30) NOT NULL,
  value SMALLINT NOT NULL,
  metadata JSONB,
  measured_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_profile_quality_metrics_user ON profile_quality_metrics (user_id, measured_at DESC);
```

---

## Section 9: BullMQ Job Definitions

These jobs extend the queue architecture defined in RTA Section 7. All follow the same `@Processor` / `@Process` pattern.

### 9.1 Queue Registration

| Queue | Purpose | Concurrency | Retry | Schedule |
|-------|---------|-------------|-------|----------|
| **trust-scoring** | Trust score recalculation | 5 | 3x exponential | On demand + daily 03:00 UTC |
| **profile-quality** | Dating profile quality scoring | 3 | 2x | On demand |
| **visibility-tiers** | Tier transitions and notifications | 3 | 2x | On demand + daily 03:00 UTC |

### 9.2 Job Definitions

#### `trust-score-recalc`

**Queue:** `trust-scoring`
**Trigger:** Phone/email/selfie verification, upheld report, device change
**Input:** `{ userId: string, trigger: TrustSignalType }`
**Process:**
1. Load all `TrustSignal` records for user
2. Sum deltas to compute new trust score (clamped 0-100)
3. Update `User.trustScore` and `User.trustUpdatedAt`
4. If score change > 5 points, queue `visibility-tier-transition`

#### `trust-score-decay`

**Queue:** `trust-scoring`
**Trigger:** Scheduled, daily at 03:00 UTC
**Input:** `{}` (batch job)
**Process:**
1. Find users with no login in 30+ days and `trustScore > 20`
2. Apply decay (-2/week, or -4/week for VoIP accounts)
3. Insert `TrustSignal` with type `DORMANCY_DECAY` for each affected user
4. Update `User.trustScore`

#### `profile-quality-update`

**Queue:** `profile-quality`
**Trigger:** Photo upload/delete, bio edit, prompt edit, daily batch
**Input:** `{ userId: string }`
**Process:**
1. Load `DatingProfile` with photos and user metrics
2. Run photo quality assessment (AWS Rekognition if new photos)
3. Calculate profile quality score (Section 3 formula)
4. Store individual metrics as `ProfileQualityMetric` records
5. Update `DatingProfile.profileQualityScore`
6. If score change > 5 points, queue `visibility-tier-transition`

#### `visibility-tier-transition`

**Queue:** `visibility-tiers`
**Trigger:** Trust score or profile quality change > 5 points, daily batch
**Input:** `{ userId: string }`
**Process:**
1. Load current tier from `User.visibilityTier`
2. Calculate new tier using formula (Section 4)
3. Apply hysteresis (3-point buffer for upward transitions)
4. If tier changed:
   a. Update `User.visibilityTier`
   b. Emit Socket.io event to user (if online): `trust:tier-changed`
   c. If tier dropped to D, queue moderation review notification

#### `new-user-boost-expiry`

**Queue:** `visibility-tiers`
**Trigger:** Scheduled, every 15 minutes
**Input:** `{}` (batch job)
**Process:**
1. Find `DatingProfile` records where `newUserBoostExpiresAt < NOW()` and `newUserBoostExpiresAt IS NOT NULL`
2. For each: calculate permanent scores, set visibility tier, clear `newUserBoostExpiresAt`
3. Queue `visibility-tier-transition` for each

#### `dating-profile-embedding`

**Queue:** `profile-quality` (shares queue with profile quality)
**Trigger:** Bio or prompts update on DatingProfile
**Input:** `{ userId: string }`
**Process:**
1. Load DatingProfile bio and prompts
2. Concatenate: `bio + " " + prompts.map(p => p.answer).join(" ")`
3. Call OpenAI `text-embedding-3-small` (1536 dimensions) — same model as content embeddings (RTA Section 6)
4. Store in `DatingProfile.bioEmbedding`

---

## Appendix: Score Simulation Examples

### Example 1: New User Journey

| Day | Action | Trust Score | Social Rep | Profile Quality | Tier |
|-----|--------|-------------|------------|-----------------|------|
| 0 | Registers with mobile phone | 40 | 50 (default) | 0 | B (boost) |
| 0 | Verifies email | 50 | 50 | 0 | B (boost) |
| 0 | Adds 3 photos + bio | 50 | 50 | 65 | B (boost) |
| 3 | Boost expires | 50 | 48 | 65 | B |
| 7 | Completes selfie verification | 80 | 52 | 65 | A |
| 14 | Active conversations, good response rate | 80 | 68 | 72 | A |

### Example 2: VoIP Scammer

| Day | Action | Trust Score | Social Rep | Tier |
|-----|--------|-------------|------------|------|
| 0 | Registers with VoIP phone | 20 (-20 penalty) | 50 | C |
| 0 | No selfie verification | 20 | 50 | C |
| 1 | Spam messages detected | 20 | 30 | D |
| 2 | Report upheld | 0 | 20 | D |
| 3 | Account suspended | — | — | — |

### Example 3: Good Marketplace Seller

| Day | Action | Trust Score | Seller Rep | Tier |
|-----|--------|-------------|------------|------|
| 0 | Mobile phone verified, email verified | 50 | 50 | B |
| 7 | Device consistent for 7 days | 65 | 50 | B |
| 14 | Selfie verified | 95 | 50 | A |
| 30 | 10 completed transactions, 4.8★ avg | 100 | 78 | A |
| 60 | 1 dispute out of 25 transactions | 100 | 72 | A |
