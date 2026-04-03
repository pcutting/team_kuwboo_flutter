# Kuwboo: Regulatory Requirements Architecture

**Created:** February 17, 2026
**Version:** 1.0
**Purpose:** Regulatory compliance architecture for UK and USA jurisdictions
**Audience:** Phil Cutting (LionPro Dev) — implementation guide
**Companion Document:** [TECHNICAL_DESIGN.md](./TECHNICAL_DESIGN.md) — schema and architecture

---

## How to Read This Document

This document identifies regulatory obligations for a UK-based platform (Guess This Ltd) that serves users in the UK and USA. For each regulation:

1. **What it requires** — the legal obligation
2. **Where the TDD already covers it** — cross-reference to existing schema/architecture
3. **What's missing** — gaps that need schema additions or new entities
4. **Entity definitions** — TypeORM entities needed to close the gaps

Section 4 contains all new entity definitions. Section 5 maps every requirement to a TDD section. Section 6 provides implementation phasing.

---

## Table of Contents

- [Section 1: Executive Summary](#section-1-executive-summary)
- [Section 2: UK Regulatory Requirements](#section-2-uk-regulatory-requirements)
- [Section 3: USA Regulatory Requirements](#section-3-usa-regulatory-requirements)
- [Section 4: Schema Additions](#section-4-schema-additions)
- [Section 5: Cross-Reference to TDD](#section-5-cross-reference-to-tdd)
- [Section 6: Implementation Priority](#section-6-implementation-priority)

---

## Section 1: Executive Summary

Kuwboo is a multi-module platform (video, marketplace, dating, social discovery) operated by a UK entity (Guess This Ltd) with users in the UK and USA. This combination triggers the following regulatory frameworks:

| Jurisdiction | Regulation | Why It Applies |
|--------------|-----------|----------------|
| UK | Online Safety Act 2023 | User-to-user service with UK users |
| UK | ICO Age Appropriate Design Code | Likely to be accessed by children (social + marketplace) |
| UK | UK GDPR / DPA 2018 | Processing personal data of UK residents |
| UK | Consumer Rights Act 2015 | Marketplace module (distance selling) |
| USA | COPPA | Under-13 users possible on a social platform |
| USA | CCPA/CPRA | California users (likely given US availability) |
| USA | State Dating App Safety Laws | Dating module (IL, CT, NV, others) |
| USA | BIPA | Biometric data from photo verification (Illinois users) |
| USA | DMCA | User-generated content with audio/video |
| USA | BSA/AML | Marketplace with financial transactions |

### What the TDD Already Covers

The TDD (Section 6) addresses GDPR fundamentals: right to access, erasure, portability, consent tracking, and retention policies. The `UserConsent` entity (now defined in TDD Section 2) covers basic consent types.

### What's Missing

11 gaps across 6 critical and 5 high/medium priority areas:

| # | Gap | Severity | Regulation |
|---|-----|----------|------------|
| 1 | No age assurance architecture | Critical | Online Safety Act, COPPA, ICO AADC |
| 2 | No proactive illegal content scanning | Critical | Online Safety Act |
| 3 | No DMCA takedown/counter-notification flow | Critical | DMCA |
| 4 | No `UserConsent` entity definition | Critical | UK GDPR, CCPA *(now fixed in TDD)* |
| 5 | No DPIA architecture for high-risk processing | Critical | UK GDPR |
| 6 | `DatingProfile.age` is a static integer | Critical | ICO AADC *(now fixed in TDD)* |
| 7 | No CCPA-specific consent types (opt-out of sale) | High | CCPA/CPRA |
| 8 | No biometric consent for photo verification | High | BIPA |
| 9 | No sex offender registry check architecture | High | State dating laws |
| 10 | No content filter preferences (user empowerment) | Medium | Online Safety Act |
| 11 | No seller verification for marketplace | Medium | Consumer Rights, AML/KYC |

---

## Section 2: UK Regulatory Requirements

### 2.1 Online Safety Act 2023 (Ofcom Enforcement)

The Online Safety Act (OSA) classifies Kuwboo as a **Category 1 User-to-User service** (or at minimum Category 2) due to video, marketplace, and dating functionality. Enforcement is by Ofcom.

#### 2.1.1 Illegal Content Duty — Proactive Scanning

**Requirement:** Platforms must take proactive steps to prevent users from encountering illegal content, including CSAM, terrorist content, fraud, and illegal sale of goods.

**TDD coverage:** The moderation system (TDD Section 5, Report state machine) handles user-reported content reactively. No proactive scanning exists.

**Gap:** Kuwboo needs automated content scanning on upload, before content reaches the feed.

**Architecture:**

```
Media Upload → S3 → Lambda trigger
                       ├── AWS Rekognition (image moderation)
                       ├── Amazon Transcribe + comprehend (video audio analysis)
                       └── Hash matching (PhotoDNA / NCMEC hash list for CSAM)
                              │
                              ▼
                     ContentModerationResult
                       ├── PASS → Content.status = ACTIVE
                       ├── FLAG → Content.status = FLAGGED + Report created
                       └── BLOCK → Content.status = REMOVED + AuditEntry + user notification
```

**Schema addition:** `ContentModerationResult` (see Section 4).

**Column additions to existing entities:**
- `Content.moderationScore: number | null` — automated confidence score
- `Content.moderationMethod: enum | null` — AUTOMATED / HUMAN / HYBRID

#### 2.1.2 Children's Safety Duty — Age Assurance

**Requirement:** Platforms likely to be accessed by children must implement age assurance measures proportionate to the risk. This includes age verification or age estimation at registration.

**TDD coverage:** None. The User entity has no `dateOfBirth` field (now noted as needed in TDD Section 2 via the DatingProfile.age fix). No age gate exists.

**Gap:** Platform-wide age assurance at registration.

**Architecture options (ranked by strength):**

| Method | Strength | Trade-off |
|--------|----------|-----------|
| Self-declaration (DOB entry) | Weak (minimum viable) | Easily lied about; Ofcom considers this insufficient alone |
| Open banking age check | Medium | UK-only; requires integration partner (e.g., Yoti, Veriff) |
| Document verification (ID scan) | Strong | Friction at registration; GDPR data minimisation concerns |
| Facial age estimation | Strong | Requires biometric consent (BIPA if US); Yoti integration |

**Recommendation:** Self-declaration at registration (dateOfBirth on User) as baseline, with age estimation integration (Yoti) for under-18 detection on high-risk modules (dating, marketplace). Dating module should enforce 18+ hard gate.

**Schema additions:**
- `User.dateOfBirth: Date` (referenced in TDD DatingProfile fix)
- `User.ageVerificationStatus: enum` — UNVERIFIED / SELF_DECLARED / PROVIDER_VERIFIED
- `User.ageVerificationProvider: string | null` — e.g., 'yoti', 'veriff'
- `User.ageVerifiedAt: Date | null`

#### 2.1.3 User Empowerment — Content Filter Preferences

**Requirement:** Category 1 services must give users tools to control what content they see, including filtering by content type and user blocking.

**TDD coverage:** Blocking is covered (TDD Section 2, Block entity). Content filtering preferences are not.

**Gap:** `UserPreferences.contentFilters` — a JSONB column allowing users to filter feed content by category, content type, or sensitivity level.

**Schema addition:**
- `UserPreferences.contentFilters: JSONB` (see Section 4)

#### 2.1.4 Transparency Reporting

**Requirement:** Annual transparency reports to Ofcom covering: content removed, reports received, automated moderation actions, appeals, user complaints.

**TDD coverage:** `AuditEntry` (TDD Section 2) captures entity-level events. `Report` entity captures user reports.

**Gap:** No dedicated aggregation mechanism, but existing `AuditEntry` + `Report` tables provide the raw data. Transparency reporting becomes a read-only analytics query against these tables — no schema change needed.

**Implementation:** Scheduled query job (quarterly) that aggregates:
- `AuditEntry WHERE action LIKE 'content.%' AND createdAt BETWEEN ...`
- `Report WHERE createdAt BETWEEN ... GROUP BY status, reason`

---

### 2.2 ICO Age Appropriate Design Code

The ICO's Age Appropriate Design Code (also called the Children's Code) applies to platforms likely to be accessed by children. With Kuwboo's video and social features, it applies.

#### 2.2.1 Platform-Wide Age Verification at Registration

**Requirement:** Establish the age of users with reasonable certainty. Apply different default settings for under-18s.

**TDD coverage:** None (see Section 2.1.2 above — shared architecture).

**Gap:** Same as OSA children's safety duty. `User.dateOfBirth` is the critical missing field.

#### 2.2.2 Default Privacy for Under-18s

**Requirement:** Default to the most privacy-protective settings for users identified or estimated as under 18.

**Implementation rules:**
- Under-18 accounts: `Content.visibility` defaults to `CONNECTIONS` (not `PUBLIC`)
- Under-18 accounts: `UserPreferences.locationSharing` defaults to `false`
- Under-18 accounts: YoYo module disabled entirely
- Under-18 accounts: Dating module blocked (hard gate)
- Under-18 accounts: Direct messaging limited to connections only

**Schema addition:**
- `User.isMinor: boolean` — computed from `dateOfBirth`, cached for query performance
- Application-level guard: `MinorGuard` that enforces module access restrictions

#### 2.2.3 dateOfBirth vs Static Age

**Requirement:** Age must be accurate at all times. A static `age: number` field becomes wrong on every birthday.

**TDD coverage:** Now addressed — TDD Section 2 `DatingProfile.age` has been replaced with a derived-age comment referencing `User.dateOfBirth`.

---

### 2.3 UK GDPR / DPA 2018

The TDD Section 6 covers GDPR fundamentals. This section addresses gaps beyond what Section 6 provides.

#### 2.3.1 Data Residency for S3/CloudFront

**Requirement:** Personal data of UK/EEA residents should be stored within adequate jurisdictions. Post-Brexit, the UK has its own adequacy framework.

**TDD coverage:** RDS is in `eu-west-2` (London). S3 bucket region is not specified. CloudFront edge locations are global by design.

**Gap:** S3 bucket for user media must be in `eu-west-2`. CloudFront distribution is acceptable (caching, not storage) but origin must be UK/EEA-region S3. Document this as an infrastructure constraint.

**No schema change needed** — infrastructure configuration only.

#### 2.3.2 DPIA Architecture for High-Risk Processing

**Requirement:** A Data Protection Impact Assessment (DPIA) is mandatory before any processing that is "likely to result in a high risk" to individuals. For Kuwboo, this includes:

| Processing Activity | Why High-Risk | DPIA Required |
|---------------------|---------------|---------------|
| Dating module (swipe matching) | Sensitive data (sexual orientation inferred from preferences) | Yes |
| YoYo proximity (real-time location) | Systematic monitoring of publicly accessible area | Yes |
| Automated content moderation | Automated decision-making with legal/significant effects | Yes |
| Marketplace (user financial data) | Financial data processing | Yes |

**TDD coverage:** None.

**Gap:** DPIAs are documents, not schema — but the platform must log which processing activities exist and their DPIA status for accountability (GDPR Article 30).

**Schema addition:** `DataProcessingRecord` (see Section 4). This is a lightweight Article 30 compliance table.

#### 2.3.3 UserConsent Entity

**Status:** Now defined in TDD Section 2 (New Models). The entity covers `TERMS`, `PRIVACY`, `MARKETING`, `LOCATION`, `COOKIES`, and `DATA_SALE_OPT_OUT` consent types.

**Additional consent types needed for this document's requirements:**
- `BIOMETRIC` — for BIPA compliance (photo verification)
- `AGE_VERIFICATION` — for ICO AADC compliance

These are added to the `ConsentType` enum in Section 4.

#### 2.3.4 Data Breach Notification Flow

**Requirement:** Notify the ICO within 72 hours of becoming aware of a personal data breach. Notify affected individuals if the breach is likely to result in high risk.

**TDD coverage:** None.

**Gap:** Operational process, not schema. But `AuditEntry` should capture breach-related events with action type `'security.breach_detected'`, `'security.breach_notified_ico'`, `'security.breach_notified_users'`.

**No new entity needed** — use existing `AuditEntry` with standardised action strings.

---

### 2.4 Consumer Rights / Distance Selling

The marketplace module triggers UK Consumer Rights Act 2015 and Consumer Contracts Regulations 2013.

#### 2.4.1 Cooling-Off Periods

**Requirement:** For distance sales (online purchases), consumers have a 14-day right to cancel from receipt of goods.

**TDD coverage:** Product and Auction entities exist (TDD Section 2) but no order/transaction lifecycle for direct purchases (non-auction).

**Gap:** An `Order` entity with status tracking that includes a `COOLING_OFF` period state. This is deferred to marketplace implementation phase.

#### 2.4.2 Dispute Resolution

**Requirement:** Platforms facilitating commerce should provide or signpost dispute resolution.

**TDD coverage:** Report entity can report users/content but has no commerce-specific dispute flow.

**Gap:** `Dispute` entity linking buyer, seller, order, with status machine. Deferred to marketplace implementation phase.

#### 2.4.3 Seller Verification

**Requirement:** High-volume or high-value sellers may need identity verification to prevent fraud and comply with consumer protection.

**Schema addition:** `SellerVerification` (see Section 4).

---

## Section 3: USA Regulatory Requirements

### 3.1 COPPA (Children's Online Privacy Protection Act)

COPPA applies to operators of commercial websites/apps directed at children under 13, or that have actual knowledge of collecting data from children under 13.

#### 3.1.1 Platform-Wide Age Gate

**Requirement:** If users under 13 may use the platform, COPPA requires verifiable parental consent before collecting personal information.

**TDD coverage:** None.

**Architecture:** Same age assurance infrastructure as OSA (Section 2.1.2). Two options:

1. **Block under-13 entirely** (recommended for Kuwboo) — reject registration if `dateOfBirth` indicates under 13. Simpler compliance, no parental consent flow needed.
2. **Allow with parental consent** — requires a verified parent account linked to the child account, with parental controls. Significant engineering effort.

**Recommendation:** Block under-13 at registration. This is the industry standard for dating/marketplace platforms (Tinder, Depop, etc.) and eliminates COPPA compliance obligations entirely.

**Implementation:**
- Registration flow: require `dateOfBirth`, reject if age < 13
- `User.dateOfBirth` must be non-null after registration
- Age check at registration time (not retroactive)

#### 3.1.2 Parental Consent Flow (If Under-13 Allowed)

If the decision changes to allow under-13 users:

```typescript
// ParentalConsent entity (deferred — only needed if under-13 allowed)
@Entity('parental_consents')
export class ParentalConsent {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  childUserId: string;

  @Column()
  parentEmail: string;

  @Column({ type: 'enum', enum: ParentalConsentStatus })
  status: ParentalConsentStatus;  // PENDING / VERIFIED / REVOKED

  @Column({ nullable: true })
  verifiedAt: Date | null;

  @Column({ nullable: true })
  verificationMethod: string | null;  // 'credit_card', 'id_scan', 'email'

  @CreateDateColumn()
  createdAt: Date;
}
```

**Deferred** — not needed if under-13 is blocked.

---

### 3.2 CCPA/CPRA (California Consumer Privacy Act / California Privacy Rights Act)

CCPA/CPRA applies if Kuwboo has California users and meets revenue/data thresholds (50K+ California consumers' data, or $25M+ revenue). Even below thresholds, implementing CCPA compliance is best practice for a US-facing platform.

#### 3.2.1 Right to Opt-Out of Sale

**Requirement:** Users must be able to opt out of the "sale" of their personal information. Under CPRA, "sharing" for cross-context behavioural advertising is also covered.

**TDD coverage:** `UserConsent` entity (now defined in TDD Section 2) includes `DATA_SALE_OPT_OUT` consent type.

**Gap:** The opt-out must be accessible via a "Do Not Sell or Share My Personal Information" link, enforceable across all data processing pipelines.

**Implementation:**
- `UserConsent` record with `consentType = DATA_SALE_OPT_OUT` and `revokedAt IS NOT NULL` indicates active opt-out
- EventBridge event filtering must respect this flag before routing analytics events to any third-party
- API endpoint: `POST /users/me/privacy/opt-out-sale`

#### 3.2.2 Sensitive Personal Information

**Requirement:** CPRA classifies certain data as "sensitive personal information" requiring explicit consent:

| Data Type | Kuwboo Feature | Sensitive Under CPRA |
|-----------|---------------|---------------------|
| Precise geolocation | YoYo proximity, content location | Yes |
| Racial/ethnic origin | Dating profile preferences | Yes |
| Sexual orientation | Dating preference genders | Yes (inferred) |
| Biometric data | Photo verification | Yes |
| Private communications | Chat messages | Yes |

**Gap:** Users must be able to limit the use of sensitive personal information. This extends the consent model beyond basic TERMS/PRIVACY.

**Schema addition:** Extended `ConsentType` enum to include `SENSITIVE_DATA_PROCESSING` (see Section 4).

#### 3.2.3 Consent Types Beyond GDPR

The `UserConsent` entity in the TDD covers GDPR consent types. CCPA/CPRA requires additional types:

| Consent Type | GDPR | CCPA/CPRA | Notes |
|-------------|------|-----------|-------|
| TERMS | Yes | — | Standard |
| PRIVACY | Yes | — | Standard |
| MARKETING | Yes | — | Standard |
| LOCATION | Yes | — | Standard |
| COOKIES | Yes | — | Standard |
| DATA_SALE_OPT_OUT | — | Yes | "Do Not Sell" |
| SENSITIVE_DATA_PROCESSING | — | Yes | Limits use of sensitive PI |
| BIOMETRIC | — | Yes (BIPA) | Photo verification consent |
| AGE_VERIFICATION | Yes (AADC) | — | Age assurance consent |

All types are included in the extended `ConsentType` enum in Section 4.

---

### 3.3 State Dating App Safety Laws

Multiple US states have enacted dating app safety laws. Illinois, Connecticut, and Nevada have the most comprehensive requirements.

#### 3.3.1 Photo Verification

**Requirement:** Dating apps must offer photo verification to confirm users match their profile photos.

**TDD coverage:** `DatingProfile` entity has `photos` relation to `Media` (TDD Section 2). No verification mechanism exists.

**Gap:** Photo verification status on `DatingProfile`.

**Schema addition:**
- `DatingProfile.photoVerificationStatus: enum` — UNVERIFIED / PENDING / VERIFIED / FAILED
- `DatingProfile.photoVerifiedAt: Date | null`

#### 3.3.2 Sex Offender Registry Check

**Requirement:** Some state laws require dating platforms to check users against sex offender registries (or disclose that they do not).

**Architecture options:**

| Approach | Feasibility | Notes |
|----------|-------------|-------|
| National Sex Offender Public Website API | Medium | Free public API, but limited to name/location matching |
| Third-party background check (Checkr, GoodHire) | High | Per-check cost ($5-30), user consent required |
| Disclosure-only | Low friction | "We do not conduct background checks" — meets minimum legal requirement in most states |

**Recommendation:** Disclosure at registration (minimum viable). Evaluate third-party integration in Phase 3 based on user base size and legal counsel.

**Schema addition (if background checks implemented):**
- `BackgroundCheck` entity (deferred — see Section 4 for structure)

#### 3.3.3 Safety Resource Integration

**Requirement:** Dating platforms must provide safety resources and emergency contact information.

**Implementation:** UI-level requirement (in-app safety centre). No schema changes needed.

---

### 3.4 BIPA (Illinois Biometric Information Privacy Act)

BIPA applies if Kuwboo collects biometric data (face geometry from photo verification) from Illinois residents. BIPA has a private right of action with statutory damages of $1,000-$5,000 per violation.

#### 3.4.1 BiometricConsent Entity

**Requirement:** Before collecting biometric data, obtain informed written consent specifying:
- What data is collected
- Purpose of collection
- How long it will be retained
- How it will be destroyed

**TDD coverage:** Photo verification is mentioned in dating profile context but has no biometric consent mechanism.

**Schema addition:** `BiometricConsent` (see Section 4).

#### 3.4.2 Retention and Destruction Policy

**Requirement:** Biometric data must be destroyed within 3 years of last interaction or when the purpose is fulfilled, whichever comes first.

**Implementation:**
- `BiometricConsent.retentionExpiresAt` — calculated at consent grant time
- Scheduled job: delete biometric data where `retentionExpiresAt < NOW()`
- `AuditEntry` with action `'biometric.data_destroyed'` for compliance trail

---

### 3.5 DMCA (Digital Millennium Copyright Act)

DMCA safe harbour protection requires Kuwboo to implement a notice-and-takedown system for copyrighted content.

#### 3.5.1 CopyrightClaim Entity

**Requirement:** DMCA requires:
1. Designated agent for receiving takedown notices (registered with US Copyright Office)
2. Takedown procedure on receipt of valid notice
3. Counter-notification procedure for content creators
4. Repeat infringer policy

**TDD coverage:** Content moderation and reporting exist (TDD Section 5, Report state machine) but are generic — no copyright-specific flow.

**Schema addition:** `CopyrightClaim` (see Section 4).

#### 3.5.2 Takedown / Counter-Notification Flow

```
Copyright holder sends DMCA notice
          │
          ▼
   CopyrightClaim created (status: RECEIVED)
          │
          ▼
   Content.status → REMOVED (within 24 hours)
   User notified of takedown
          │
          ▼
   User may file counter-notification
          │
   ┌──────┴──────┐
   │             │
   No counter    Counter filed
   │             │
   ▼             ▼
   UPHELD     COUNTER_RECEIVED
               │
               ▼
          10-14 business day wait
               │
          ┌────┴────┐
          │         │
     No lawsuit   Lawsuit filed
          │         │
          ▼         ▼
     Content       ESCALATED
     restored      (legal review)
     COUNTER_UPHELD
```

#### 3.5.3 Repeat Infringer Tracking

**Requirement:** DMCA safe harbour requires a policy for terminating repeat infringers.

**Schema addition:**
- `User.copyrightStrikes: number` — incremented on upheld claims, decremented on successful counter-notifications
- Policy: 3 strikes → account review, 5 strikes → account termination

#### 3.5.4 AudioTrack Licensing Fields

**Requirement:** Music used in videos must have licensing status tracked for DMCA compliance.

**TDD coverage:** `AudioTrack` entity (TDD Section 2) has basic fields but no licensing information.

**Schema additions to AudioTrack:**
- `licenseType: enum` — ORIGINAL / LICENSED / PUBLIC_DOMAIN / UNKNOWN
- `copyrightHolder: string | null`
- `isLicensed: boolean` — derived from licenseType, but explicit for query simplicity

---

### 3.6 AML/KYC for Marketplace

If Kuwboo's marketplace facilitates transactions above certain thresholds, Anti-Money Laundering (AML) and Know Your Customer (KYC) requirements may apply. This depends on whether Kuwboo acts as a payment processor or uses a third-party (Stripe, PayPal).

#### 3.6.1 Seller Verification for High-Value Transactions

**Requirement:** Payment processors (Stripe Connect, PayPal) typically handle KYC for sellers. Kuwboo's obligation is to collect and pass through seller identity for payment processor onboarding.

**Schema addition:** `SellerVerification` (see Section 4).

---

## Section 4: Schema Additions

### New Entity Definitions

All entities below use TypeORM Data Mapper pattern, consistent with TDD Section 2 conventions.

```typescript
// ── ContentModerationResult (OSA proactive scanning) ──
@Entity('content_moderation_results')
export class ContentModerationResult {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  contentId: string;

  @Column({ type: 'enum', enum: ModerationMethod })
  method: ModerationMethod;

  @Column({ type: 'enum', enum: ModerationOutcome })
  outcome: ModerationOutcome;

  @Column({ type: 'decimal', precision: 5, scale: 4, nullable: true })
  confidenceScore: number | null;  // 0.0000 - 1.0000

  @Column({ type: 'simple-array', nullable: true })
  flaggedCategories: string[] | null;  // e.g., ['nudity', 'violence', 'csam']

  @Column({ type: 'jsonb', nullable: true })
  providerResponse: Record<string, unknown> | null;  // Raw response from Rekognition/PhotoDNA

  @Column({ nullable: true })
  reviewedBy: string | null;  // Moderator userId if human-reviewed

  @CreateDateColumn()
  createdAt: Date;

  @ManyToOne(() => Content)
  @JoinColumn({ name: 'content_id' })
  content: Relation<Content>;
}

enum ModerationMethod {
  AUTOMATED = 'AUTOMATED',
  HUMAN = 'HUMAN',
  HYBRID = 'HYBRID',
}

enum ModerationOutcome {
  PASS = 'PASS',
  FLAG = 'FLAG',
  BLOCK = 'BLOCK',
}


// ── BiometricConsent (BIPA compliance) ─────────────────
@Entity('biometric_consents')
export class BiometricConsent {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;

  @Column({ type: 'enum', enum: BiometricDataType })
  dataType: BiometricDataType;

  @Column({ type: 'text' })
  purposeDescription: string;  // Plain-language description of why data is collected

  @Column()
  grantedAt: Date;

  @Column({ nullable: true })
  revokedAt: Date | null;

  @Column()
  retentionExpiresAt: Date;  // Max 3 years from grant per BIPA

  @Column({ nullable: true })
  destroyedAt: Date | null;  // When biometric data was actually destroyed

  @Column({ nullable: true })
  ipAddress: string | null;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: Relation<User>;
}

enum BiometricDataType {
  FACE_GEOMETRY = 'FACE_GEOMETRY',
  FINGERPRINT = 'FINGERPRINT',
  VOICEPRINT = 'VOICEPRINT',
}


// ── CopyrightClaim (DMCA takedown/counter-notification) ─
@Entity('copyright_claims')
@Index(['contentId', 'status'])
@Index(['respondentUserId', 'createdAt'])
export class CopyrightClaim {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  contentId: string;

  @Column()
  respondentUserId: string;  // The content creator (accused infringer)

  // Claimant info (may not be a Kuwboo user)
  @Column()
  claimantName: string;

  @Column()
  claimantEmail: string;

  @Column({ type: 'text' })
  claimantAddress: string;

  @Column({ type: 'text' })
  originalWorkDescription: string;

  @Column({ nullable: true })
  originalWorkUrl: string | null;

  @Column({ type: 'enum', enum: CopyrightClaimStatus, default: CopyrightClaimStatus.RECEIVED })
  status: CopyrightClaimStatus;

  // Counter-notification fields
  @Column({ type: 'text', nullable: true })
  counterNotificationText: string | null;

  @Column({ nullable: true })
  counterNotificationAt: Date | null;

  @Column({ nullable: true })
  counterDeadlineAt: Date | null;  // 10-14 business days after counter-notification

  // Resolution
  @Column({ nullable: true })
  resolvedAt: Date | null;

  @Column({ nullable: true })
  resolvedBy: string | null;  // Admin userId

  // Legal compliance
  @Column({ default: false })
  goodFaithBelief: boolean;  // Claimant affirmed good faith

  @Column({ default: false })
  perjuryAcknowledged: boolean;  // Claimant affirmed under penalty of perjury

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @ManyToOne(() => Content)
  @JoinColumn({ name: 'content_id' })
  content: Relation<Content>;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'respondent_user_id' })
  respondentUser: Relation<User>;
}

enum CopyrightClaimStatus {
  RECEIVED = 'RECEIVED',
  CONTENT_REMOVED = 'CONTENT_REMOVED',
  COUNTER_RECEIVED = 'COUNTER_RECEIVED',
  COUNTER_WAITING = 'COUNTER_WAITING',  // 10-14 day wait period
  UPHELD = 'UPHELD',                    // No counter or counter rejected
  COUNTER_UPHELD = 'COUNTER_UPHELD',    // Content restored
  ESCALATED = 'ESCALATED',              // Lawsuit filed, legal review
  WITHDRAWN = 'WITHDRAWN',              // Claimant withdrew
}


// ── SellerVerification (Consumer Rights, AML/KYC) ─────
@Entity('seller_verifications')
export class SellerVerification {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  userId: string;

  @Column({ type: 'enum', enum: SellerVerificationStatus, default: SellerVerificationStatus.UNVERIFIED })
  status: SellerVerificationStatus;

  @Column({ nullable: true })
  businessName: string | null;

  @Column({ nullable: true })
  businessRegistrationNumber: string | null;  // UK Companies House number or US EIN

  @Column({ nullable: true })
  verifiedAt: Date | null;

  @Column({ nullable: true })
  verificationProvider: string | null;  // e.g., 'stripe_connect', 'manual'

  @Column({ type: 'jsonb', nullable: true })
  providerData: Record<string, unknown> | null;  // Stripe Connect account details, etc.

  @Column({ default: 0 })
  totalSalesCount: number;

  @Column({ type: 'bigint', default: 0 })
  totalSalesAmountCents: number;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @OneToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: Relation<User>;
}

enum SellerVerificationStatus {
  UNVERIFIED = 'UNVERIFIED',
  PENDING = 'PENDING',
  VERIFIED = 'VERIFIED',
  SUSPENDED = 'SUSPENDED',
  REJECTED = 'REJECTED',
}


// ── DataProcessingRecord (GDPR Article 30) ────────────
@Entity('data_processing_records')
export class DataProcessingRecord {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  activityName: string;  // e.g., 'Dating match processing', 'YoYo proximity tracking'

  @Column({ type: 'text' })
  purpose: string;

  @Column({ type: 'enum', enum: LawfulBasis })
  lawfulBasis: LawfulBasis;

  @Column({ type: 'simple-array' })
  dataCategories: string[];  // e.g., ['location', 'preferences', 'photos']

  @Column({ type: 'simple-array' })
  dataSubjects: string[];  // e.g., ['registered_users', 'dating_users']

  @Column({ nullable: true })
  retentionPeriod: string | null;  // e.g., '2 years', '7 years (financial)'

  @Column({ default: false })
  dpiaRequired: boolean;

  @Column({ default: false })
  dpiaCompleted: boolean;

  @Column({ nullable: true })
  dpiaCompletedAt: Date | null;

  @Column({ type: 'simple-array', nullable: true })
  thirdPartyRecipients: string[] | null;  // e.g., ['Stripe', 'AWS Rekognition', 'Yoti']

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

enum LawfulBasis {
  CONSENT = 'CONSENT',
  CONTRACT = 'CONTRACT',
  LEGAL_OBLIGATION = 'LEGAL_OBLIGATION',
  VITAL_INTERESTS = 'VITAL_INTERESTS',
  PUBLIC_TASK = 'PUBLIC_TASK',
  LEGITIMATE_INTERESTS = 'LEGITIMATE_INTERESTS',
}
```

### Column Additions to Existing TDD Entities

These columns should be added to entities already defined in TDD Section 2:

#### User Entity (additions)

```typescript
// Add to User entity (TDD Section 2)
@Column({ type: 'date' })
dateOfBirth: string;  // Required at registration; drives age derivation

@Column({ type: 'enum', enum: AgeVerificationStatus, default: AgeVerificationStatus.SELF_DECLARED })
ageVerificationStatus: AgeVerificationStatus;

@Column({ nullable: true })
ageVerificationProvider: string | null;

@Column({ nullable: true })
ageVerifiedAt: Date | null;

@Column({ default: false })
isMinor: boolean;  // Computed from dateOfBirth, cached for query guards

@Column({ default: 0 })
copyrightStrikes: number;  // DMCA repeat infringer tracking

enum AgeVerificationStatus {
  UNVERIFIED = 'UNVERIFIED',
  SELF_DECLARED = 'SELF_DECLARED',
  PROVIDER_VERIFIED = 'PROVIDER_VERIFIED',
}
```

#### AudioTrack Entity (additions)

```typescript
// Add to AudioTrack entity (TDD Section 2, New Models)
@Column({ type: 'enum', enum: AudioLicenseType, default: AudioLicenseType.UNKNOWN })
licenseType: AudioLicenseType;

@Column({ nullable: true })
copyrightHolder: string | null;

@Column({ default: false })
isLicensed: boolean;  // Explicit flag: true if licenseType is ORIGINAL or LICENSED

enum AudioLicenseType {
  ORIGINAL = 'ORIGINAL',         // User's own creation
  LICENSED = 'LICENSED',         // Platform has license
  PUBLIC_DOMAIN = 'PUBLIC_DOMAIN',
  UNKNOWN = 'UNKNOWN',          // Legacy/unverified — flag for review
}
```

#### UserPreferences Entity (additions)

```typescript
// Add to UserPreferences entity (TDD Section 2)
@Column({ type: 'jsonb', default: '{}' })
contentFilters: {
  hiddenCategories?: string[];        // Category IDs to hide from feed
  hiddenContentTypes?: string[];      // e.g., ['PRODUCT', 'EVENT']
  sensitivityLevel?: 'standard' | 'reduced' | 'strict';
  hideExplicitContent?: boolean;
};
```

#### DatingProfile Entity (additions)

```typescript
// Add to DatingProfile entity (TDD Section 2)
@Column({ type: 'enum', enum: PhotoVerificationStatus, default: PhotoVerificationStatus.UNVERIFIED })
photoVerificationStatus: PhotoVerificationStatus;

@Column({ nullable: true })
photoVerifiedAt: Date | null;

enum PhotoVerificationStatus {
  UNVERIFIED = 'UNVERIFIED',
  PENDING = 'PENDING',
  VERIFIED = 'VERIFIED',
  FAILED = 'FAILED',
}
```

#### Post Entity (additions for MISSING_PERSON subtype)

```typescript
// Add to Post entity (TDD Section 2, CTI Child Entities)
// These columns are only populated when subType = MISSING_PERSON
@Column({ default: false })
verifiedByAuthority: boolean;  // Confirmed by police/official body

@Column({ nullable: true })
resolvedAt: Date | null;  // When the person was found / case closed
```

#### Content Entity (additions for moderation)

```typescript
// Add to Content base entity (TDD Section 2)
@Column({ type: 'decimal', precision: 5, scale: 4, nullable: true })
moderationScore: number | null;  // Automated confidence score

@Column({ type: 'enum', enum: ModerationMethod, nullable: true })
moderationMethod: ModerationMethod | null;
```

### Extended ConsentType Enum

Update the `ConsentType` enum in the `UserConsent` entity (TDD Section 2) to include regulatory consent types:

```typescript
enum ConsentType {
  // GDPR (existing)
  TERMS = 'TERMS',
  PRIVACY = 'PRIVACY',
  MARKETING = 'MARKETING',
  LOCATION = 'LOCATION',
  COOKIES = 'COOKIES',
  // CCPA/CPRA
  DATA_SALE_OPT_OUT = 'DATA_SALE_OPT_OUT',
  SENSITIVE_DATA_PROCESSING = 'SENSITIVE_DATA_PROCESSING',
  // BIPA
  BIOMETRIC = 'BIOMETRIC',
  // ICO AADC
  AGE_VERIFICATION = 'AGE_VERIFICATION',
}
```

---

## Section 5: Cross-Reference to TDD

| # | Regulatory Requirement | TDD Section | TDD Entity | Gap Status |
|---|----------------------|-------------|------------|------------|
| 1 | OSA illegal content scanning | Section 5 (Report state machine) | Content, Report | **Gap**: no proactive scanning — needs `ContentModerationResult` |
| 2 | OSA children's safety | — | — | **Gap**: no `User.dateOfBirth`, no age assurance |
| 3 | OSA user empowerment | Section 2 (Block entity) | Block | **Partial**: blocking exists, content filters missing |
| 4 | OSA transparency reporting | Section 2 (AuditEntry) | AuditEntry, Report | **Covered**: aggregation queries on existing tables |
| 5 | AADC age verification | — | — | **Gap**: no `dateOfBirth`, no verification status |
| 6 | AADC default privacy for minors | Section 2 (UserPreferences) | UserPreferences | **Partial**: preferences exist, no minor-specific defaults |
| 7 | AADC accurate age | Section 2 (DatingProfile) | DatingProfile | **Fixed**: TDD bug #3 addressed (static age removed) |
| 8 | UK GDPR data residency | Section 0c (AWS Services) | — | **Gap**: S3 region not specified (infrastructure) |
| 9 | UK GDPR DPIA | — | — | **Gap**: needs `DataProcessingRecord` |
| 10 | UK GDPR UserConsent | Section 2 (New Models), Section 6 | UserConsent | **Fixed**: TDD bug #2 addressed (entity now defined) |
| 11 | UK GDPR breach notification | Section 2 (AuditEntry) | AuditEntry | **Covered**: use standardised action strings |
| 12 | Consumer Rights cooling-off | Section 2 (Product, Auction) | Product | **Gap**: no Order entity (deferred) |
| 13 | Consumer Rights seller verification | — | — | **Gap**: needs `SellerVerification` |
| 14 | COPPA age gate | — | User | **Gap**: needs `dateOfBirth` + registration check |
| 15 | CCPA opt-out | Section 2 (UserConsent) | UserConsent | **Covered**: `DATA_SALE_OPT_OUT` consent type |
| 16 | CCPA sensitive data | Section 2 (UserConsent) | UserConsent | **Gap**: needs `SENSITIVE_DATA_PROCESSING` consent type |
| 17 | State dating photo verification | Section 2 (DatingProfile) | DatingProfile | **Gap**: needs `photoVerificationStatus` |
| 18 | State dating safety resources | — | — | **Covered**: UI-level, no schema needed |
| 19 | BIPA biometric consent | — | — | **Gap**: needs `BiometricConsent` |
| 20 | DMCA takedown flow | Section 5 (Report state machine) | Report | **Gap**: needs `CopyrightClaim` entity |
| 21 | DMCA repeat infringer | Section 2 (User) | User | **Gap**: needs `copyrightStrikes` on User |
| 22 | DMCA audio licensing | Section 2 (AudioTrack) | AudioTrack | **Gap**: needs `licenseType`, `copyrightHolder`, `isLicensed` |
| 23 | AML/KYC seller verification | — | — | **Gap**: needs `SellerVerification` |

---

## Section 6: Implementation Priority

### Phase 1 — Pre-Launch (Legally Required)

These must be in place before Kuwboo accepts users. Without them, the platform operates in breach of law or forfeits safe harbour protections.

| Item | Regulation | Effort | Dependency |
|------|-----------|--------|------------|
| `User.dateOfBirth` + age gate at registration | COPPA, OSA, AADC | Low | None |
| Block under-13 at registration | COPPA | Low | `dateOfBirth` |
| Block under-18 from dating module | OSA, AADC | Low | `dateOfBirth` |
| `UserConsent` entity + consent collection at registration | UK GDPR | Medium | TDD entity (done) |
| DMCA designated agent registration | DMCA | Low (legal) | None |
| `CopyrightClaim` entity + takedown endpoint | DMCA | Medium | None |
| `User.copyrightStrikes` + repeat infringer policy | DMCA | Low | `CopyrightClaim` |
| Content moderation scanning (AWS Rekognition) | OSA | High | Media upload pipeline |
| Privacy policy + terms of service | UK GDPR, CCPA | Low (legal) | None |
| "Do Not Sell" link + `DATA_SALE_OPT_OUT` | CCPA | Low | `UserConsent` |

### Phase 2 — Within 6 Months of Launch

| Item | Regulation | Effort | Dependency |
|------|-----------|--------|------------|
| CCPA sensitive data consent | CPRA | Low | `UserConsent` |
| `BiometricConsent` entity + BIPA flow for photo verification | BIPA | Medium | Dating photo verification feature |
| `ContentModerationResult` entity + automated scanning pipeline | OSA | High | S3 Lambda trigger pipeline |
| `UserPreferences.contentFilters` + feed filtering | OSA | Medium | Feed algorithm |
| `AudioTrack` licensing fields | DMCA | Low | None |
| `DataProcessingRecord` entity + DPIA documentation | UK GDPR | Low | None |
| `Post.verifiedByAuthority` + `resolvedAt` for MISSING_PERSON | OSA | Low | None |
| OSA transparency report (first annual) | OSA | Medium | `AuditEntry`, `Report` data |

### Phase 3 — As Needed (Based on Growth)

| Item | Regulation | Trigger |
|------|-----------|---------|
| `SellerVerification` entity + seller onboarding | Consumer Rights, AML | Marketplace launch with transactions |
| Age estimation integration (Yoti/Veriff) | OSA, AADC | Ofcom guidance update or user volume |
| Sex offender registry background checks | State dating laws | US dating user base > 10K |
| `Order` entity + cooling-off period flow | Consumer Rights | Marketplace direct purchase (non-auction) |
| `Dispute` entity + resolution flow | Consumer Rights | Marketplace transaction volume |
| Parental consent flow | COPPA | Decision to allow under-13 users |

---

## Appendix: Regulatory Reference Links

| Regulation | Reference |
|-----------|-----------|
| Online Safety Act 2023 | legislation.gov.uk — Online Safety Act 2023 |
| ICO Age Appropriate Design Code | ico.org.uk — Age appropriate design code |
| UK GDPR | legislation.gov.uk — Data Protection Act 2018 |
| Consumer Rights Act 2015 | legislation.gov.uk — Consumer Rights Act 2015 |
| COPPA | ftc.gov — COPPA Rule |
| CCPA/CPRA | oag.ca.gov — California Consumer Privacy Act |
| BIPA | ilga.gov — Biometric Information Privacy Act |
| DMCA | copyright.gov — DMCA |

---
