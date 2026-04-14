# Inner Circle — Feature Specification & Scope Estimate

**Created:** 2026-03-28
**Author:** Philip Cutting / LionPro Dev
**Status:** Draft — Pending Client Review
**Version:** 1.5

### Bid Summary

| Milestone | Deliverables | Fixed Price (USD) |
|-----------|-------------|-------------------|
| **M1: Design & Discovery** | UX flows, data model, regulatory research, platform spikes | **$4,500** |
| **M2: Core Inner Circle** | Circle management, real-time location, maps, chat, pings, paywall | **$17,500** |
| **M3: Child Accounts + Safety Shell** | Under-13 Safety Shell, 13-17 parental controls, age tiers, COPPA compliance | **$16,000** |
| **M4: Elder Monitoring** | Inactivity alerts, wandering detection, guardian dashboard, consent/POA, Simple Mode | **$5,500** |
| **M5: Emergency & Safety** | SOS, geofencing, widgets, alerts, unusual activity detection | **$7,500** |
| **M6: Platform Infrastructure** | Tags, feature flags, admin panel, regulatory compliance | **$15,000** |
| **TOTAL** | | **$66,000** |

### Optional Add-Ons (Separate Approval)

| Add-On | Description | Fixed Price (USD) |
|--------|------------|-------------------|
| **Apple Watch Companion** | watchOS Safety Shell — emoji, SOS, call parent, location, complications | **$8,000** |
| **Wear OS Companion** | Same features, native Kotlin for Android watches | **$8,000** |
| **iOS Live Activities** | Dynamic Island + Lock Screen for SOS, journey tracking, geofence alerts | **$3,000** |
| **Extended Widgets** | Family status, child status, lock screen widgets (iOS + Android) | **$3,500** |

*See [Section 10: Bid Summary](#10-bid-summary) for full deliverables, payment schedule, timeline, and milestone acceptance criteria.*

---

> **Scope:** Complete Inner Circle feature including circle management, real-time location sharing, child account system (under-13 Safety Shell through age 17), elder monitoring, parental controls, admin panel, tags system, emergency features, paywall integration, per-user/per-region feature flags, and regulatory compliance for UK + USA.
>
> **Contract Type:** Change Order / Additional Statement of Work — separate from the existing $60,000 Kuwboo rebuild contract.
>
> **Multi-Zone Note:** Initial launch targets UK (eu-west-2). Multi-zone data architecture is designed-for but deferred to implementation. See [Appendix A: Multi-Zone Data Architecture](#appendix-a-multi-zone-data-architecture).
>
> **Legal Note:** Formal legal review is required per jurisdiction before launching child/elder monitoring features. See [Appendix B: Legal Review Requirements](#appendix-b-legal-review-requirements-by-zone).

---

## Questions for Neil (Decision Points)

These questions require Neil's input before finalising scope. Each includes our current working assumption and the impact if the direction changes.

**1. Data Monetisation**

Will Kuwboo ever sell, share, or monetise Inner Circle location data to third parties? This is a paid feature — we assume no data sale.

> **Our Assumption:** No data sale. Inner Circle data is private to the paying subscriber and their circle. We will document this in the privacy policy as a selling point.
>
> **Impact If Changed:** If yes — requires CCPA opt-in consent for under-16s, additional consent flows for all users, potential UK GDPR "legitimate interest" re-evaluation. Adds approximately $1,200 to the bid.

**2. Elder Care Branding**

Inner Circle covers both child monitoring and elder care (e.g., elderly parents, grandparents with dementia). Should elder care be a distinct branded feature ("Guardian Mode", "Care Circle") or part of the same Inner Circle umbrella?

> **Our Assumption:** Same umbrella. Circle members are tagged with a "monitoring level" — the system doesn't distinguish child vs. elder at the feature level, only at the permission/consent level.
>
> **Impact If Changed:** If separate branding — adds UI/UX design work for distinct flows, separate onboarding, and separate marketing materials. Adds approximately $1,000 to the bid.

**3. Paywall Tier**

Which subscription tier includes Inner Circle? Is it a standalone add-on or bundled with an existing tier?

> **Our Assumption:** Standalone paid add-on within the existing tier structure. Free users cannot access Inner Circle. Premium users get it included. This could also be a separate "Circle" subscription.
>
> **Impact If Changed:** Pricing model affects conversion funnels, payment flow design, and promotional strategy. Needs Neil's commercial decision. No significant cost impact — the paywall integration is the same regardless of tier structure.

**4. Maximum Circle Size**

How many members can one circle contain?

> **Our Assumption:** 15 members per circle, 3 circles per account. This balances usability with server-side location broadcast costs.
>
> **Impact If Changed:** Larger circles increase real-time WebSocket load. 50+ members would require architectural changes adding approximately $1,200 to the bid.

**5. Non-App Members**

Should circle members who don't have Kuwboo (e.g., elderly grandparent with a feature phone) receive SMS-based location pings or check-in alerts?

> **Our Assumption:** No. All circle members must have the Kuwboo app installed. SMS fallback is a future consideration if demand warrants it.
>
> **Impact If Changed:** SMS fallback adds Twilio costs (~$0.01/message), SMS gateway integration, and a degraded UX path to design. Adds approximately $1,500 to the bid.

**6. Panic Button Destination**

When a child (or elder) triggers SOS, where does it go? Options: (a) circle members only, (b) circle members + emergency services, (c) configurable per member.

> **Our Assumption:** Option (c) — Configurable. Parent/guardian sets per-member whether SOS triggers a call to emergency services (999/112/911) or only notifies circle members. Default: circle members only. Emergency services opt-in requires explicit parent consent.
>
> **Impact If Changed:** Option (b) has legal implications — if the app promises emergency dispatch and fails (no signal, server down), liability risk increases significantly. Legal review required before committing to guaranteed emergency dispatch.

**7. Retention Display to Monitored Users**

Children and monitored elders — should they be able to SEE that their location is being tracked and the retention window? Or should it be invisible to them?

> **Our Assumption:** Visible. ICO Age Appropriate Design Code requires transparency. The child/elder sees a subtle indicator that location sharing is active and the retention window (e.g., "Your location is shared with Mum — last 24h"). They cannot disable it without parent/guardian action.
>
> **Impact If Changed:** If invisible — violates ICO AADC transparency principle. Not recommended for UK launch. Would require separate legal opinion.

**8. Sponsored Content in Child Feeds**

Can sponsored/paid content appear in the feeds of users aged 13-17?

> **Our Assumption:** No. Maximum child protection. Sponsored content is blocked entirely for accounts aged under 18. This is the safest ICO AADC position (no profiling children for marketing, no nudge techniques).
>
> **Impact If Changed:** If yes — requires age-appropriate ad review, ICO AADC "detrimental use" assessment, separate ad targeting rules, and potential ASA (Advertising Standards Authority) compliance. Adds approximately $1,800 to the bid.

**9. Geofence Limit Per Member**

How many safe zones can a parent/guardian define per monitored member?

> **Our Assumption:** 10 zones per monitored member. Covers home, school, work, grandparents, after-school clubs, friends' houses, etc.
>
> **Impact If Changed:** More zones means more server-side geofence evaluations per location update. 50+ zones per member needs a spatial index strategy adding approximately $500 to the bid.

**10. Fall Detection / Inactivity Alerts for Elders**

Should the app attempt to detect falls or extended inactivity (e.g., no movement for 2+ hours during waking hours) for elderly monitored members?

> **Our Assumption:** Deferred to a future phase. Fall detection requires accelerometer access and complex motion analysis. Inactivity alerts are simpler (no location update for N hours triggers an alert) and ARE included in the current bid.
>
> **Impact If Changed:** Fall detection adds approximately $2,500 to the bid for platform-specific motion analysis work on both iOS and Android.

**11. Admin Access for Neil**

Should Neil (or designated admins) have visibility into circle activity for platform moderation (e.g., abuse reports, compliance audits), or are circles fully private even from platform admins?

> **Our Assumption:** Admin access for abuse/compliance only. Admin panel shows aggregate metrics (circle count, member count, alert frequency) but does NOT show individual locations unless triggered by an abuse report or legal request. Privacy by default.
>
> **Impact If Changed:** If fully private — complicates abuse response. If fully visible — users won't trust the platform. The middle ground is the right call and has no cost impact.

**12. Multi-Circle Naming**

Can users name their circles (e.g., "Family", "Mum's carers", "School run")?

> **Our Assumption:** Yes. Users create named circles with custom names. System provides suggested names but doesn't restrict.
>
> **Impact If Changed:** Minimal impact either way. No cost change.

---

## 1. Executive Summary

Inner Circle is a **paid premium feature** that enables real-time location sharing, emergency alerts, and communication within trusted groups of family members and carers. It serves three primary use cases:

1. **Family safety** — Parents tracking children (under-13 Safety Shell + 13-17 full controls), safe arrival notifications, geofenced alerts
2. **Elder care** — Adult children monitoring elderly parents/grandparents, inactivity alerts, wandering detection
3. **Trusted group communication** — Persistent chat, quick pings, real-time presence for close family/friends

The feature includes a comprehensive **parental control system** for child accounts (under-13 Safety Shell through age 17), an **admin panel** for platform-level management, **per-user and per-region feature flags** for phased rollout, and a **tags system** for content/access control.

### What This Estimate Covers

| Category | Included |
|----------|----------|
| **Design** | UX flows, wireframes, screen specifications, data model design |
| **Discovery & Research** | Regulatory research, platform capability research (iOS/Android background location), third-party service evaluation (maps, push) |
| **Backend Development** | NestJS modules, MikroORM entities, WebSocket gateways, REST APIs, BullMQ jobs |
| **Frontend Development** | Flutter screens (iOS + Android + web), state management, map integration, real-time location UI |
| **Admin Panel** | Dashboard screens for circle management, parental control oversight, abuse response, analytics |
| **Testing & QA** | Unit tests, integration tests, platform-specific testing (iOS + Android location services), regulatory compliance testing |

### What This Estimate Does NOT Cover

| Exclusion | Reason |
|-----------|--------|
| Legal counsel fees | Requires separate budget — see [Appendix B](#appendix-b-legal-review-requirements-by-zone) |
| App Store / Play Store submission fees | Standard platform fees, not feature-specific |
| Third-party service costs (map tiles, Twilio, FCM) | Operational costs, not development hours |
| Multi-zone infrastructure deployment | Designed-for but deferred — see [Appendix A](#appendix-a-multi-zone-data-architecture) |
| SMS fallback for non-app members | Deferred unless Neil requests (see Q5) |
| Fall detection (accelerometer-based) | Deferred to Phase 2 (see Q10) |

---

## 2. Feature Architecture

### 2.1 Inner Circle Within Kuwboo

Inner Circle lives within the YoYo module but has its own entity model, WebSocket namespace, and permission layer.

```
Kuwboo App
├── Video Making
├── Buy & Sell
├── Social Stumble
├── Dating (deferred)
├── YoYo (proximity/location)
│   ├── Public YoYo (encounter-based, strangers)
│   └── Inner Circle (trusted, paid)          ← THIS FEATURE
│       ├── Circle Management
│       ├── Real-Time Location
│       ├── Circle Chat (persistent)
│       ├── Quick Pings
│       ├── Geofencing & Alerts
│       ├── SOS / Emergency
│       ├── Child Account Controls (13-17)
│       ├── Elder Monitoring Controls
│       └── Tags & Permission System
├── Sponsored Content
├── Chat (shared infrastructure)
└── Profile & Settings
```

### 2.2 Paywall Integration

Inner Circle is a **paid feature**. This provides two benefits:
1. **Revenue** — Premium subscription or standalone add-on
2. **Identity confirmation** — Payment method (credit card, Apple Pay, Google Pay) provides a verified identity signal, reducing fake accounts in circles

```
Free User                     Paid User
─────────                     ─────────
YoYo (public encounters)  →   YoYo (public encounters)
No Inner Circle            →   Inner Circle (full access)
No circle management       →   Create/manage up to 3 circles
No monitoring features     →   Child & elder monitoring
No geofencing              →   Up to 10 geofences per member
No SOS                     →   SOS / panic button
```

**Paywall enforcement:** Inner Circle menu items are visible to free users but tapping them presents an upgrade prompt. This serves as a discovery/conversion funnel.

### 2.3 Entity Model (New Entities)

These are the new backend entities required. All are greenfield — nothing exists in the current schema.

```
Circle
├── id: UUID (PK)
├── ownerId: UUID (FK → User)
├── name: string (user-defined, e.g., "Family")
├── type: enum (family, friends, care)
├── maxMembers: int (default 15)
├── createdAt: timestamp
├── dataZone: string (default 'eu-west-2')        ← multi-zone ready
└── isActive: boolean

CircleMember
├── id: UUID (PK)
├── circleId: UUID (FK → Circle)
├── userId: UUID (FK → User)
├── role: enum (owner, guardian, member, monitored_young_child, monitored_child, monitored_elder)
├── relationshipLabel: string (e.g., "Daughter", "Grandmother")
├── locationSharingEnabled: boolean
├── locationRetentionHours: int (60 min = 1, max 72)
├── joinedAt: timestamp
├── invitedBy: UUID (FK → User)
├── consentGrantedAt: timestamp
├── consentType: enum (self, parental, guardian, power_of_attorney)
└── dataZone: string

CircleInvite
├── id: UUID (PK)
├── circleId: UUID (FK → Circle)
├── inviterId: UUID (FK → User)
├── inviteePhone: string (or inviteeUserId if already on platform)
├── role: enum (member, monitored_young_child, monitored_child, monitored_elder)
├── status: enum (pending, accepted, declined, expired, revoked)
├── expiresAt: timestamp
├── token: string (unique, for deep link)
└── createdAt: timestamp

LocationPing
├── id: UUID (PK)
├── userId: UUID (FK → User)
├── circleId: UUID (FK → Circle)
├── latitude: decimal
├── longitude: decimal
├── accuracy: float (metres)
├── altitude: float (nullable)
├── speed: float (nullable)
├── batteryLevel: int (0-100)
├── isCharging: boolean
├── samplingMode: enum (high, normal, low, stationary)
├── recordedAt: timestamp
├── expiresAt: timestamp (calculated from retention setting)
├── dataZone: string
└── INDEX: (circleId, userId, recordedAt) for timeline queries

Geofence
├── id: UUID (PK)
├── circleId: UUID (FK → Circle)
├── createdBy: UUID (FK → User, must be guardian/owner)
├── monitoredUserId: UUID (FK → User)
├── name: string (e.g., "School", "Home")
├── latitude: decimal
├── longitude: decimal
├── radiusMetres: int
├── type: enum (safe_zone, restricted_zone)
├── alertOnEntry: boolean
├── alertOnExit: boolean
├── activeSchedule: JSONB (nullable — e.g., school hours only)
├── isActive: boolean
└── createdAt: timestamp

GeofenceAlert
├── id: UUID (PK)
├── geofenceId: UUID (FK → Geofence)
├── userId: UUID (FK → User, who triggered)
├── type: enum (entered, exited)
├── latitude: decimal
├── longitude: decimal
├── triggeredAt: timestamp
├── notifiedMembers: UUID[] (who was notified)
└── acknowledged: boolean

SOSEvent
├── id: UUID (PK)
├── userId: UUID (FK → User, who triggered)
├── circleId: UUID (FK → Circle)
├── latitude: decimal
├── longitude: decimal
├── accuracy: float
├── batteryLevel: int
├── status: enum (triggered, acknowledged, resolved, false_alarm)
├── emergencyServicesDispatched: boolean
├── triggeredAt: timestamp
├── resolvedAt: timestamp (nullable)
├── resolvedBy: UUID (FK → User, nullable)
└── notes: text (nullable)

QuickPing
├── id: UUID (PK)
├── circleId: UUID (FK → Circle)
├── senderId: UUID (FK → User)
├── message: enum (im_here, coming_home, on_my_way, running_late, all_good, call_me, custom)
├── customText: string (nullable, max 100 chars)
├── latitude: decimal (nullable — sender's location at time of ping)
├── longitude: decimal (nullable)
├── sentAt: timestamp
└── expiresAt: timestamp

EmojiStatus (Under-13 Safety Shell — child-to-parent status updates)
├── id: UUID (PK)
├── circleId: UUID (FK → Circle)
├── senderId: UUID (FK → User, the child)
├── emoji: enum (happy, sad, hungry, tired, scared, want_home)
├── latitude: decimal (nullable — auto-attached from last location)
├── longitude: decimal (nullable)
├── sentAt: timestamp
├── seenByParent: boolean (default false)
├── seenAt: timestamp (nullable)
└── expiresAt: timestamp (24h after sentAt)

Note: The 'scared' emoji triggers an elevated notification to the parent
(higher priority push, distinct alert sound) without triggering a full SOS.
It's a soft distress signal — "I'm uncomfortable but not in danger."

ParentalControl (extends CircleMember for monitored_child / monitored_young_child role)
├── id: UUID (PK)
├── circleMemberId: UUID (FK → CircleMember)
├── parentUserId: UUID (FK → User)
├── moduleAccess: JSONB
│   ├── video_making: boolean (default true)
│   ├── buy_sell: enum (blocked, view_only, full)
│   ├── dating: boolean (default false, always false for under-18)
│   ├── social_stumble: boolean (default true)
│   ├── yoyo_public: boolean (default false for 13-15, true for 16-17)
│   ├── sponsored_content: boolean (default false, always false for under-18)
│   └── inner_circle: boolean (default true — the point)
├── contactRestrictions: JSONB
│   ├── allowUnknownMessages: boolean (default false)
│   ├── requireApprovalForNewContacts: boolean (default true)
│   └── blockedUserIds: UUID[]
├── screenTimeMinutes: int (nullable — daily limit)
├── bedtimeStart: time (nullable, e.g., 21:00)
├── bedtimeEnd: time (nullable, e.g., 07:00)
├── sosPermissions: JSONB
│   ├── canTriggerSOS: boolean (default true — always allowed)
│   ├── sosNotifiesCircle: boolean (default true)
│   ├── sosDialsEmergency: boolean (default false — parent opt-in)
│   └── sosMessage: string (custom SOS text, nullable)
├── locationSharingAlwaysOn: boolean (default true — parent enforced)
├── canDisableLocationSharing: boolean (default false)
└── updatedAt: timestamp

ElderMonitoringControl (extends CircleMember for monitored_elder role)
├── id: UUID (PK)
├── circleMemberId: UUID (FK → CircleMember)
├── guardianUserId: UUID (FK → User)
├── consentDocumentUrl: string (nullable — uploaded POA or consent form)
├── inactivityAlertMinutes: int (default 120 — alert if no movement for 2h during waking hours)
├── wakingHoursStart: time (default 07:00)
├── wakingHoursEnd: time (default 22:00)
├── sosPermissions: JSONB (same structure as ParentalControl)
├── locationSharingAlwaysOn: boolean (default true)
├── canDisableLocationSharing: boolean (default false — guardian decides)
├── wanderingDetection: boolean (default false)
├── wanderingRadiusMetres: int (default 500 — alert if elder moves beyond this from home)
└── updatedAt: timestamp

UserFeatureFlag
├── id: UUID (PK)
├── userId: UUID (FK → User, nullable — null = system-wide)
├── groupId: UUID (FK → UserGroup, nullable — null = individual)
├── featureKey: string (e.g., 'inner_circle', 'elder_monitoring', 'geofencing')
├── enabled: boolean
├── regionScope: string (nullable — e.g., 'GB', 'US', 'US-CA')
├── reason: string (nullable — why it was toggled)
├── setBy: UUID (FK → User — admin or parent who set it)
├── expiresAt: timestamp (nullable — temporary overrides)
└── updatedAt: timestamp

ContentTag
├── id: UUID (PK)
├── name: string (e.g., 'safe-for-13', 'adult-only', 'sponsored')
├── category: enum (age_rating, content_type, safety, module_access, location_zone)
├── description: string
├── minAge: int (nullable — minimum age to view content with this tag)
├── isSystemTag: boolean (true = managed by admin, false = user-created)
└── createdAt: timestamp
```

### 2.4 Age Tier Model

| Age | Account Type | Restrictions | Inner Circle Role |
|-----|-------------|-------------|-------------------|
| **Under 13** | **Safety Shell** (parent-created) | Extremely restricted. The child does NOT see Kuwboo as a social app — they see a **parent-connected safety communicator**. Only features: one-tap call to parent, automatic location sharing, emoji status to parents, SOS panic button. All other modules hidden. Parent controls everything. COPPA verifiable parental consent required (paywall credit card satisfies this). | `monitored_young_child` — parent is `guardian` |
| **13-15** | Child (maximum restriction) | All controversial features restricted until 16. Parent controls everything. Cannot disable location sharing. No dating, no marketplace transactions, no sponsored content, no public YoYo. Contact approval required. Full Inner Circle features visible (chat, pings, map). | `monitored_child` — parent is `guardian` |
| **16-17** | Teen (moderate restriction) | Some autonomy granted. Parent still has oversight. Can view marketplace (no transactions without parent approval). Public YoYo allowed with parent opt-in. No dating. No sponsored content. | `monitored_child` — parent is `guardian`, but child can request permission changes |
| **18+** | Adult | Full access to all features. Can be circle `owner`, `guardian`, or `member`. | Any role |
| **Elder (any age, designated)** | Monitored adult | Full account with optional monitoring overlay. Guardian sets monitoring parameters. Elder can revoke monitoring at any time (unless Power of Attorney applies). | `monitored_elder` — family member is `guardian` |

### 2.5 Under-13 Safety Shell (Detail)

The under-13 experience is **not Kuwboo the social app**. It's a purpose-built child safety communicator that lives inside the Kuwboo app. The child sees only four things:

#### What the Under-13 Child Sees

```
┌─────────────────────────────────┐
│         Safety Shell UI          │
│                                  │
│   ┌─────────┐  ┌─────────┐     │
│   │  📞     │  │  🆘     │     │
│   │ Call     │  │  SOS    │     │
│   │ Parent   │  │         │     │
│   └─────────┘  └─────────┘     │
│                                  │
│   How are you feeling?           │
│   ┌────┐ ┌────┐ ┌────┐         │
│   │ 😊 │ │ 😢 │ │ 🍕 │         │
│   │Happy│ │Sad │ │Hungry│        │
│   └────┘ └────┘ └────┘         │
│   ┌────┐ ┌────┐ ┌────┐         │
│   │ 😴 │ │ 😰 │ │ 🏠 │         │
│   │Tired│ │Scared│ │Home │       │
│   └────┘ └────┘ └────┘         │
│                                  │
│   📍 Location shared with Mum   │
│                                  │
└─────────────────────────────────┘
```

#### Feature Breakdown

| Feature | Description | Always On? |
|---------|------------|-----------|
| **Call Parent** | One-tap button that dials the parent's phone number directly. Parent configures which number (Mum, Dad, or both as options). No other calling capability. | Yes — cannot be disabled |
| **SOS Panic** | Same SOS as older children. Hold-to-confirm, alerts all circle guardians with location. Emergency services dial is parent opt-in. | Yes — cannot be disabled |
| **Emoji Status** | Six large, simple buttons. Child taps one → parent receives a push notification with the emoji and the child's current location. | Yes — cannot be disabled |
| **Location Sharing** | Automatic, always-on. Child cannot see the map or other members' locations — only the parent can. Child sees a simple "📍 Location shared with [Parent]" indicator. | Yes — cannot be disabled |

#### Emoji Status Definitions

| Emoji | Label | Push to Parent | Alert Level |
|-------|-------|---------------|-------------|
| 😊 | Happy | "[Child] is feeling happy" + location | Normal |
| 😢 | Sad | "[Child] is feeling sad" + location | Normal |
| 🍕 | Hungry | "[Child] is hungry" + location | Normal |
| 😴 | Tired | "[Child] is tired" + location | Normal |
| 😰 | Scared | "[Child] feels unsafe" + location | **Elevated** (distinct alert sound, higher priority push, badge highlight) |
| 🏠 | Want to come home | "[Child] wants to come home" + location | **Elevated** |

The "Scared" and "Want to come home" emojis trigger elevated notifications — the parent's phone will use a distinct alert sound and the notification is marked high-priority. This gives the child a way to signal distress without the full SOS chain.

#### What the Under-13 Child Does NOT See

| Hidden | Reason |
|--------|--------|
| Video feed | Not age-appropriate without full content moderation for under-13 |
| Buy & Sell | No marketplace access |
| Social Stumble | No contact with strangers |
| Dating | Blocked (all ages under 18) |
| YoYo (public) | No proximity to strangers |
| Chat (except via emoji) | No free-text messaging — emojis only |
| Other circle members' locations | Only parent sees the map |
| Sponsored content | No ads of any kind |
| Notifications from other modules | Only Inner Circle notifications |

#### Parent's View of Under-13 Child

The parent sees the child in their circle like any other monitored member:
- Real-time location on map
- Emoji status history (chronological log)
- Battery level and last update time
- Geofence alerts
- SOS capability

**Parent can enable additional features per-function** if they choose. The Safety Shell defaults are the most restrictive, but a parent could unlock (for example):
- Circle chat (text messaging within the circle only)
- View-only access to the video feed (with age-appropriate content filtering)

Each unlockable feature has its own toggle in the parent's control panel. By default, everything except the four core Safety Shell features is OFF.

#### COPPA Compliance (Under-13)

Allowing under-13 users means **COPPA fully applies**. Key requirements:

| Requirement | How We Satisfy It |
|------------|------------------|
| **Verifiable Parental Consent (VPC)** | The paywall requires a credit card payment. A credit card transaction IS an accepted VPC method under FTC guidelines. The parent pays → the child account is created. This is the same method used by Disney+, YouTube Kids, and other major platforms. |
| **Parental access to child's data** | Parent dashboard shows all data collected about the child (location history, emoji log, battery history). |
| **Parental right to delete** | Parent can delete the child's account and all associated data at any time. |
| **Data minimisation** | Safety Shell collects ONLY: location, emoji status, battery level. No profile data, no browsing history, no social graph, no content interactions. |
| **No behavioural advertising** | Zero ads, zero tracking, zero profiling for under-13. |
| **Privacy policy for children** | Separate, plain-language privacy notice for the under-13 Safety Shell. Must be reviewed by legal counsel. |
| **COPPA Safe Harbor (optional)** | Participation in an FTC-approved Safe Harbor program (e.g., kidSAFE, PRIVO) provides additional legal protection. Cost: $5,000-$15,000/year. Recommended but not required. |

### 2.5 Retention Model

Location data retention is **set by the guardian/parent** for monitored members, and **self-set** for standard members.

| Setting | Range | Default | Who Controls |
|---------|-------|---------|-------------|
| Monitored child | 60 minutes — 72 hours | 24 hours | Parent/guardian |
| Monitored elder | 60 minutes — 72 hours | 24 hours | Guardian |
| Standard member | 60 minutes — 72 hours | 12 hours | Self |
| SOS event data | Minimum 30 days | 30 days | System (non-configurable, required for safety) |
| Geofence alert history | Minimum 7 days | 30 days | Guardian/parent |

**Automatic purge:** A scheduled BullMQ job runs every 15 minutes to delete expired `LocationPing` records based on each member's `expiresAt` timestamp.

**SOS exception:** When an SOS event is triggered, all location data for the affected member is retained for a minimum of 30 days regardless of the normal retention setting. This supports potential law enforcement requests.

---

## 3. Core Feature Scope

### 3.1 Circle Management

#### Workflows

**Circle Creation:**
1. User navigates to Inner Circle (paywall gate if not subscribed)
2. Taps "Create Circle"
3. Enters circle name, selects type (Family / Friends / Care)
4. System creates circle, user is `owner`

**Member Invitation:**
1. Owner/guardian taps "Invite Member"
2. Selects role: Member, Young Child (under 13), Monitored Child (13-17), Monitored Elder
3. Enters phone number or selects from Kuwboo contacts
4. System sends invite via push notification (if on Kuwboo) or generates a shareable deep link
5. Invitee receives invite with circle name, inviter name, and requested role
6. Invitee accepts → joins circle. Declines → invite expires.
7. For `monitored_young_child` (under 13): parent enters child's date of birth + phone number → child's device receives Safety Shell setup → parent confirms (two-device handshake). Credit card payment serves as COPPA verifiable parental consent.
8. For `monitored_child` (13-17): parent enters child's phone number → child's device receives setup prompt → parent confirms on their device (two-device handshake)
9. For `monitored_elder`: guardian sends invite → elder accepts on their device → guardian uploads consent documentation (optional, for legal protection)

**Member Removal:**
1. Owner/guardian taps member → "Remove from Circle"
2. Confirmation dialog explains data implications
3. Member is removed. Their location data is purged per retention policy.
4. Removed member receives notification (unless removal is flagged as abuse-related, in which case silent removal is an option for admin)

**Leave Circle (Self):**
1. Member taps "Leave Circle" in settings
2. Confirmation dialog
3. Member leaves. Location data purged.
4. **Critical for abuse prevention:** Leaving a circle does NOT immediately notify other members. There is a configurable delay (default: 1 hour) before the "member left" notification is sent. This protects domestic abuse victims who need to leave without immediate detection.

**Relationship Labeling:**
- Inviter suggests a label ("Daughter", "Grandmother", etc.)
- Invitee can accept or change the label on their end
- Labels are display-only — they don't affect permissions (roles do)

#### Navigation Entry Points

| Entry Point | Location | Behaviour |
|-------------|----------|-----------|
| Bottom nav (YoYo tab) | YoYo tab switcher | "Circle" sub-tab alongside "Nearby" |
| Profile → Inner Circle | Profile settings | Link to circle management |
| Notification tap | Push notification | Deep links to relevant circle screen |
| SOS widget | Device home screen (Flutter widget) | One-tap SOS → sends to all circles |
| Quick ping widget | Device home screen | One-tap "I'm here" to default circle |

### 3.2 Real-Time Location Sharing

#### Architecture

```
Child/Elder Device                    Server                          Parent Device
────────────────                    ──────                          ─────────────
GPS sensor
  → Location Service          →     Socket.io namespace             →   Real-time map update
    (foreground/background)         /inner-circle:{circleId}            + timeline update
  → Battery-adaptive sampling       LocationPing stored in DB
  → Queued if offline               Geofence evaluation (BullMQ)
                                    Alert dispatch (FCM push)
```

#### Battery-Adaptive Sampling

Location polling frequency adjusts based on device battery level and movement state. This is critical for user retention — aggressive tracking kills batteries and users uninstall.

| Battery Level | Movement State | Sampling Interval | GPS Mode |
|--------------|---------------|-------------------|----------|
| **80-100%** | Moving | 30 seconds | High accuracy |
| **80-100%** | Stationary | 5 minutes | Low power |
| **50-79%** | Moving | 1 minute | Balanced |
| **50-79%** | Stationary | 10 minutes | Low power |
| **20-49%** | Moving | 3 minutes | Balanced |
| **20-49%** | Stationary | 15 minutes | Low power |
| **5-19%** | Any | 10 minutes | Low power |
| **Under 5%** | Any | **Paused** (last known location flagged) | Off |

**Movement detection:** Use accelerometer (available on all modern devices) to detect movement vs. stationary. If no significant acceleration for 2 minutes, switch to stationary mode.

**Low battery alert:** When a monitored member's device drops below 15%, all guardians in the circle receive a push notification: "[Name]'s phone is at [X]% battery."

**Offline queuing:** When the device has no connectivity, location pings are queued locally (up to 100 pings). When connectivity resumes, the queue is flushed to the server in order. This means the timeline will "fill in" retroactively.

### 3.3 Circle Chat (Persistent)

Circle chat extends the existing shared chat infrastructure (threads + chats tables with `moduleKey`).

| Property | Value |
|----------|-------|
| Module key | `inner_circle` |
| Message expiry | None (persistent — infinity icon in UI) |
| Media support | Text, images, voice notes |
| Encryption | Standard TLS in transit. At-rest encryption via RDS. E2E encryption deferred (significant complexity). |
| Per-circle | Each circle has one group chat + direct message capability between any two members |
| Moderation | Circle owner can delete messages. Admin can access via abuse report flow. |

### 3.4 Quick Pings

Pre-built one-tap messages for common check-ins:

| Ping | Icon | Use Case |
|------|------|----------|
| "I'm here" | pin | Arrived at destination |
| "Coming home" | home | Heading back |
| "On my way" | walk | In transit |
| "Running late" | clock | Delayed |
| "All good" | check | General safety confirmation |
| "Call me" | phone | Needs to talk |
| Custom | edit | Free-text (max 100 chars) |

Pings include the sender's current location (optional) and expire after 4 hours.

### 3.5 Map Integration

The prototype uses a canvas-drawn placeholder map. Production requires a real mapping provider.

| Provider | Pros | Cons | Cost |
|----------|------|------|------|
| **Google Maps** (Flutter `google_maps_flutter`) | Best data quality, familiar UX | Expensive at scale, Google dependency | ~$7/1,000 loads after free tier |
| **Mapbox** (`mapbox_gl`) | Customisable style, competitive pricing | Slightly less data coverage | ~$5/1,000 loads after free tier |
| **Apple Maps** (iOS only) | Free on iOS, native feel | No Android/web support | Free (iOS only) |

**Recommendation:** Google Maps for Phase 1 (best cross-platform support, fastest integration). Evaluate Mapbox if costs become significant at scale.

**Map features required:**
- Real-time member pins with avatar, online status, and last update time
- Pin clustering when members are close together
- Geofence zone visualisation (circles on map)
- Timeline scrubber (drag to see historical positions)
- "Centre on me" button
- Safe zone indicators (green overlay)
- Restricted zone indicators (red overlay)

### 3.6 Emergency / SOS Features

#### SOS / Panic Button

- **Trigger:** Dedicated button in Inner Circle UI + optional home screen widget
- **Action on trigger:**
  1. Captures current GPS coordinates (highest accuracy)
  2. Creates `SOSEvent` record
  3. Sends immediate push notification to ALL circle guardians with location
  4. If `sosDialsEmergency` is enabled by parent: opens phone dialler with 999 (UK) or 911 (US) pre-filled (does NOT auto-dial — legal liability)
  5. Begins rapid location updates (every 10 seconds) for the duration of the SOS event
  6. SOS persists until a guardian marks it "resolved" or "false alarm"

- **Child SOS permissions (per Q6):**
  - SOS to circle members: **always enabled, cannot be disabled by parent** (child safety override)
  - SOS dialling emergency services: **parent opt-in** (default off)
  - The child can ALWAYS alert their circle. The parent controls whether emergency services are also contacted.
  - This balances the "kids in timeout calling CPS" concern with genuine emergency capability

- **Unusual activity detection (passive SOS):**
  - If a monitored member leaves ALL defined geofences AND has not sent a ping in 2+ hours → automatic alert to guardians
  - If a monitored member's device goes offline for 30+ minutes after being consistently online → "Device unreachable" alert
  - These are notifications, not SOS events — they don't trigger emergency services

#### Geofencing

- **Zones:** Up to 10 per monitored member (per Q9)
- **Types:** Safe zone (alert on EXIT) or restricted zone (alert on ENTRY)
- **Scheduling:** Optional time-based activation (e.g., "School zone: weekdays 8:00-15:30")
- **Alerts:** Push notification to all guardians in the circle
- **Server-side evaluation:** Geofence checks happen server-side (on each LocationPing received) using PostGIS `ST_DWithin`. This avoids iOS/Android platform geofence limits (20 on iOS, 100 on Android).

### 3.7 Inactivity Alerts (Elder Monitoring)

For `monitored_elder` members:
- Guardian sets waking hours (default 07:00 - 22:00)
- If no LocationPing received during waking hours for N minutes (configurable, default 120), alert guardian
- Alert is a push notification, not an SOS
- Guardian can snooze the alert (1h, 4h, 24h) or mark as "all clear"

### 3.8 Wandering Detection (Elder Monitoring)

For `monitored_elder` members with `wanderingDetection` enabled:
- Guardian sets a "home base" geofence (typically the elder's residence or care home)
- Guardian sets a wandering radius (default 500m)
- If elder moves beyond the wandering radius from home base, guardian receives an alert
- Different from standard geofencing: wandering detection is always active (no schedule), and the alert is more urgent (repeated notifications every 15 minutes until acknowledged)

---

## 4. Child Account System (Under 13 through 17)

### 4.1 Account Creation Flow

**All child accounts are parent-initiated. Children cannot self-register.**

1. **Parent creates their own Kuwboo account first** (standard registration, age 18+)
2. Parent subscribes to Inner Circle (paywall — credit card payment serves as COPPA verifiable parental consent for under-13)
3. Parent creates a circle or opens existing circle
4. Parent taps "Add Child" → enters child's details:
   - Child's first name
   - Child's date of birth (age verification — system calculates age tier: under-13 Safety Shell, 13-15, or 16-17)
   - Child's phone number (must be different from parent's)
5. System determines age tier and presents appropriate defaults to parent
6. **Under-13 flow:** System sends Safety Shell setup link to child's phone. Child installs Kuwboo → opens to Safety Shell UI only (no standard registration, no profile creation, no interests). Two-device handshake confirms link. Child sees only: Call Parent, SOS, Emoji Status, location indicator.
7. **13-17 flow:** System sends invite to child's phone. Child installs Kuwboo → enters OTP → completes simplified registration (name, photo, interests). Two-device handshake confirms link. Full Inner Circle features visible.
8. Parental controls are applied immediately with age-tier defaults.

**Key point:** Under-13 children do NOT see Kuwboo as a social app at all. They see the Safety Shell — a purpose-built parent communicator. Ages 13-17 get a simplified version of Kuwboo that skips module selection and any adult-oriented screens. The child's first experience is the Inner Circle — it's their home base in the app.

### 4.2 Parental Controls (Admin-Configurable Defaults)

#### Module Access Controls

| Module | Under-13 Default | 13-15 Default | 16-17 Default | Parent Can Override? |
|--------|-----------------|-------------|-------------|---------------------|
| Video Making (viewing) | **Blocked** | Allowed | Allowed | Yes — parent can enable view-only for under-13 (with age-appropriate content filter) |
| Video Making (posting) | **Blocked** | Blocked | Allowed | Yes (can block/unblock for 13+) |
| Buy & Sell (viewing) | **Blocked** | View only | View only | No override for under-13 |
| Buy & Sell (transactions) | **Blocked** | Blocked | Blocked | No (system enforced under 18) |
| Dating | **Blocked** | Blocked | Blocked | No (system enforced under 18) |
| Social Stumble | **Blocked** | Allowed | Allowed | Yes (can block) |
| YoYo (public) | **Blocked** | Blocked | Allowed | No override for under-13 |
| Sponsored Content | **Blocked** | Blocked | Blocked | No (system enforced under 18) |
| Inner Circle | **Safety Shell only** | Always on (full) | Always on (full) | Parent can enable circle chat for under-13 |
| Chat (with approved contacts) | **Blocked** (emoji only) | Allowed | Allowed | Parent can enable for under-13 |
| Chat (with unknown users) | **Blocked** | Blocked | Blocked | Yes (can unblock for 16-17) |
| Emoji Status | **Always on** | Available | Available | Cannot disable for under-13 |
| Call Parent | **Always on** | Available | Available | Cannot disable for under-13 |

#### Contact & Communication Controls

| Control | Under-13 Default | 13-15 Default | 16-17 Default |
|---------|-----------------|-------------|-------------|
| New contact requires parent approval | N/A (no contacts outside circle) | Yes | Yes (parent can disable for 16-17) |
| Unknown user messages blocked | N/A (no messaging) | Yes | Yes (parent can disable for 16-17) |
| Profile visible to non-contacts | No (no profile) | No | Yes (parent can restrict) |
| Can share location publicly | No | No | No (parent can enable for 16-17) |
| Can join public groups | No | No | Yes (parent can restrict) |

#### Time & Usage Controls

| Control | Description | Default |
|---------|------------|---------|
| Daily screen time limit | Max minutes per day | No limit (parent can set) |
| Bedtime mode | App restricted during set hours | Off (parent can set hours) |
| Break reminders | Notification after N minutes continuous use | 60 minutes |

#### Location Controls (Non-Negotiable for Child Accounts)

| Control | Value | Overridable? |
|---------|-------|-------------|
| Location sharing | Always on | No — parent cannot disable (child safety) |
| Child can disable location | No | No — system enforced |
| Location retention | Parent sets (60 min — 72 hours) | Parent only |
| Geofencing | Parent configures | Parent only |
| SOS to circle | Always enabled | No — child can always alert circle |
| SOS to emergency services | Parent opt-in | Parent only |

### 4.3 Account Transition at 18

When a child account holder turns 18:

1. **7 days before birthday:** System notifies both parent and child that the account will transition
2. **On birthday:**
   - Parental controls are automatically suspended (not deleted — parent can see the history)
   - Child receives "Welcome to full Kuwboo" onboarding
   - All modules unlock (dating, marketplace, sponsored content)
   - Location sharing becomes self-controlled (can disable)
   - Privacy defaults flip to adult defaults
   - Child must re-consent to data processing (GDPR requirement)
3. **Parent notification:** Parent is informed that monitoring has ended
4. **Data handling:** Historical location data is retained per the last active retention setting, then purged normally. Parent loses access to child's location history.

### 4.4 What "Maximum Protection" Means in Practice

Per the instruction to assume maximum protection of children, leaning on parental control:

- **Default to most restrictive** at every decision point
- **Parent unlocks, not child** — the child cannot escalate their own permissions
- **Anything controversial for 13-15 is restricted until 16** — this includes:
  - Posting public content (viewing is allowed)
  - Public YoYo encounters
  - Messaging unknown users
  - Joining public groups
- **No profiling of children for any purpose** — no algorithmic feed personalisation for under-18. Show chronological or curated-by-popularity feeds only.
- **No sponsored content for under-18** — zero ads, zero promoted posts, zero influencer content markers
- **No data sale for any user, but especially children** — see Q1

---

## 5. Elder Care & Monitoring

### 5.1 Use Cases

| Scenario | Features Used |
|----------|-------------|
| Adult child monitors elderly parent living alone | Location sharing, inactivity alerts, SOS, geofencing (home zone) |
| Family coordinates care for grandparent with early-stage dementia | Wandering detection, persistent chat for carer coordination, location timeline |
| Carer team for disabled adult | Shared circle among carers, shift handoff via pings, SOS |

### 5.2 Consent Model

Elder monitoring has a **fundamentally different consent model** from child monitoring:

| Aspect | Child (13-17) | Elder |
|--------|-------------|-------|
| **Who consents?** | Parent consents on child's behalf | Elder consents for themselves (or guardian with legal authority) |
| **Can monitored person revoke?** | No (until 18) | Yes, at any time (unless Power of Attorney restricts) |
| **Legal basis** | Parental responsibility | Consent or legitimate interest |
| **Verification** | Two-device handshake | Optional: upload POA document or signed consent |
| **Transparency** | Required (ICO AADC) | Required (UK GDPR) |

**Power of Attorney / Legal Guardian:** If the elder lacks mental capacity to consent (e.g., advanced dementia), the guardian can upload a Power of Attorney document or other legal authority. The platform does NOT verify the document — it stores it for audit purposes. The elder's account shows "Monitoring enabled by [Guardian Name] under legal authority."

**Abuse prevention for elders:** Same safeguards as child accounts — elder can always trigger SOS, and the platform provides a "Something's not right" button (visible only to the monitored person) that connects to relevant support services (Action on Elder Abuse in UK: 080 8808 8141, Eldercare Locator in US: 1-800-677-1116).

### 5.3 Elder-Specific UI Considerations

| Consideration | Implementation |
|--------------|----------------|
| Larger touch targets | Minimum 48x48dp (vs standard 44x44dp) |
| Higher contrast text | WCAG AAA compliance (7:1 ratio) |
| Simplified navigation | Optional "Simple Mode" with only Circle, Chat, SOS visible |
| Hearing accessibility | Visual alerts accompany all audio alerts |
| Reduced notification frequency | Configurable "quiet hours" for non-urgent alerts |

---

## 6. Feature Flags & Per-User / Per-Region Control

### 6.1 Architecture

The `UserFeatureFlag` entity supports enabling/disabling features at three levels:

```
System-wide flags (admin)
  └── Regional flags (per country/state)
      └── Group flags (user groups)
          └── Individual flags (per user)
              └── Parental flags (parent overrides child)
```

**Resolution order:** Most specific wins. A parent disabling `video_making` for their child overrides a system-wide `video_making: enabled`.

### 6.2 System-Level Controls (Admin Panel)

| Control | Example |
|---------|---------|
| Enable/disable Inner Circle globally | Kill switch for emergencies |
| Enable/disable per region | "Inner Circle is live in GB but not US yet" |
| Enable/disable per feature | "Geofencing is live, wandering detection is in beta" |
| Force-disable for specific user | Abuse response: "disable this user's circle access" |
| Beta group access | "Enable elder monitoring for beta testers only" |

### 6.3 Per-Region Rollout

Regions are identified by ISO codes with state-level granularity for the US:

| Scope | Code | Example |
|-------|------|---------|
| Country | `GB` | United Kingdom |
| Country | `US` | United States (all states) |
| State | `US-CA` | California (CCPA/AADC specific) |
| State | `US-IL` | Illinois (BIPA specific) |

**Rollout plan:**
1. Phase 1: `GB` only (UK launch)
2. Phase 2: `US` excluding states with additional requirements
3. Phase 3: `US-CA`, `US-IL`, and other states with specific laws, after legal review per state

### 6.4 Sponsored Content Integration

Sponsored content visibility is controlled by the same feature flag system:

| User Type | Sponsored Content | Controlled By |
|-----------|------------------|--------------|
| Adult (18+), free tier | Shown | System (default: enabled) |
| Adult (18+), premium tier | Configurable | User preference |
| Child (13-17) | **Always blocked** | System (non-overridable) |
| Monitored elder | Shown (default) | Guardian can disable |

---

## 7. Admin Panel Updates

The existing admin panel (dashboard) requires new screens for Inner Circle management.

### 7.1 New Admin Screens

| Screen | Purpose |
|--------|---------|
| **Circle Overview** | Total circles, active members, subscription revenue, geographic distribution |
| **Circle Detail** | View a specific circle's members, activity level, alerts. No individual location data unless abuse report. |
| **Parental Control Audit** | List of all parent-child links, consent dates, restriction levels. For compliance audits. |
| **Elder Monitoring Audit** | List of all guardian-elder links, consent documentation, POA uploads. For compliance audits. |
| **SOS Event Log** | All SOS events, resolution status, response times. For safety monitoring. |
| **Geofence Alert Log** | Alert frequency, common trigger types. For system health monitoring. |
| **Feature Flag Management** | Enable/disable features per user, group, or region. With audit trail. |
| **Abuse Reports (Circle)** | Circle-specific abuse reports. Admin can view circle members, chat history (with warrant), and take action (suspend member, dissolve circle). |
| **Content Tag Management** | Create/edit system tags (age ratings, safety tags). Assign to content and users. |
| **Retention Compliance** | Verify that data purge jobs are running. Show retention policy per circle. Compliance dashboard for GDPR/CCPA audits. |
| **Subscription Analytics** | Inner Circle subscription metrics: sign-ups, churn, conversion from free, revenue by region. |

### 7.2 Admin Permissions

| Action | Role Required |
|--------|-------------|
| View aggregate metrics | Any admin |
| View circle member list | Senior admin |
| View individual location data | Abuse team + legal request documentation |
| Dissolve a circle | Senior admin + reason logged |
| Suspend a user from circles | Any admin + reason logged |
| Manage feature flags | Senior admin |
| Export compliance data | Senior admin + audit trail |

---

## 8. Tags System

### 8.1 Tag Categories

| Category | Purpose | Examples |
|----------|---------|---------|
| `age_rating` | Content filtering for minors | `all-ages`, `13+`, `16+`, `18+` |
| `content_type` | Content classification | `educational`, `entertainment`, `news`, `user-generated` |
| `safety` | Trust/safety signals | `verified-parent`, `minor-account`, `supervised`, `flagged` |
| `module_access` | Feature gating | `marketplace-allowed`, `dating-blocked`, `posting-allowed` |
| `location_zone` | Geofence categorisation | `home`, `school`, `work`, `care-home`, `hospital` |

### 8.2 Tag Application

| Target | Who Tags | Automation |
|--------|---------|------------|
| User content (videos, posts) | System + admin | Auto-tagged by content moderation pipeline. Admin can override. |
| User profiles | System + admin | Auto-tagged based on age, account type, trust score. |
| Geofence zones | Guardian/parent | Manual creation with suggested zone types. |
| Module access | System + parent + admin | Auto-applied based on age tier. Parent can restrict further. Admin can override. |

### 8.3 Tag Enforcement

Tags feed into the feature flag system. When a child account requests content from the video feed, the query filters by `ContentTag.minAge <= user.age`. When a parent disables `buy_sell` for their child, a `module_access:marketplace-blocked` tag is applied and the feed/nav excludes marketplace content.

---

## 9. Workflows & User Journeys

### 9.1 First-Time Inner Circle Setup (Adult)

```
Subscribe to Inner Circle (paywall)
  → "Welcome to Inner Circle" intro screen
    → Explains: location sharing, circles, safety features
    → Privacy summary: what data is collected, retention, who sees it
  → "Create Your First Circle"
    → Name your circle
    → Select type (Family / Friends / Care)
  → "Invite Members"
    → Select from contacts or enter phone number
    → Choose role for each invitee
  → Circle created, awaiting member acceptance
  → Tutorial: map, pings, chat, SOS button
```

### 9.2 Child Account Setup (Parent-Initiated)

**Under-13 (Safety Shell):**
```
Parent opens Inner Circle → taps "Add Child"
  → Enters child's name and date of birth
    → System detects under-13 → "Safety Shell mode"
  → Enters child's phone number
  → Reviews Safety Shell defaults (Call Parent, SOS, Emoji Status, Location)
    → Can optionally enable: circle chat, video viewing (with content filter)
  → Confirms → credit card on file serves as COPPA verifiable parental consent
  → Setup link sent to child's phone
  → Child installs app → opens directly to Safety Shell UI
    → No registration form. Name inherited from parent's input.
    → Two-device handshake (confirmation code)
  → Link established
  → Parent sees child in circle with monitoring active
  → Child sees: Safety Shell with Call Parent, SOS, Emoji Status, "📍 Location shared with [Parent]"
```

**Ages 13-17:**
```
Parent opens Inner Circle → taps "Add Child"
  → Enters child's name and date of birth
    → System detects 13-15 (max restriction) or 16-17 (moderate)
  → Enters child's phone number
  → Reviews parental control defaults for age tier
    → Can adjust any parent-configurable setting
  → Confirms → invite sent to child's phone
  → Child installs app / opens app
    → Simplified registration (name, photo, interests)
    → Two-device handshake (confirmation code)
  → Link established
  → Parent sees child in circle with monitoring active
  → Child sees: Full Inner Circle with "Location sharing is active"
```

### 9.3 Elder Monitoring Setup (Guardian-Initiated)

```
Guardian opens Inner Circle → taps "Add Family Member"
  → Selects "I'm helping care for someone"
  → Enters elder's name and phone number
  → Selects relationship label
  → Reviews monitoring options:
    → Inactivity alert threshold
    → Waking hours
    → Wandering detection (optional)
    → SOS permissions
  → Optionally uploads consent / POA document
  → Sends invite to elder's phone
  → Elder accepts on their device
    → Clear explanation of what monitoring means
    → Elder confirms consent
  → Link established
  → Guardian sees elder in circle with monitoring active
```

### 9.4 SOS Flow

```
User taps SOS button (or triggers from widget)
  → "Are you sure?" confirmation (2-second hold to avoid accidental triggers)
  → System captures: location, battery, timestamp
  → Creates SOSEvent record
  → Sends IMMEDIATE push notification to all circle guardians:
    → "[Name] triggered an SOS alert at [Location]"
    → Notification opens directly to map showing their location
  → If sosDialsEmergency enabled: phone dialler opens with 999/911 pre-filled
  → Device enters rapid tracking mode (10-second intervals)
  → Circle chat shows SOS banner: "[Name] needs help — last seen at [Location] [Time]"
  → Continues until guardian resolves:
    → "Resolved" → normal tracking resumes
    → "False alarm" → logged, normal tracking resumes
```

### 9.5 Abuse Prevention Safeguards

| Safeguard | Description |
|-----------|------------|
| **Silent leave** | Any member can leave a circle. Notification to other members is delayed 1 hour. |
| **Hidden support** | "Something's not right" button accessible via triple-tap on the Inner Circle logo. Opens directly to: Domestic Abuse Helpline (UK: 0808 2000 247), National DV Hotline (US: 1-800-799-7233), or Childline (UK: 0800 1111) depending on user's age and region. |
| **Admin intervention** | Admin can silently disable monitoring for a specific member without notifying the guardian (for abuse cases). |
| **Monitoring detection** | If a user is in more than one circle as a `monitored_child` or `monitored_elder` with different guardians, the system flags for review (potential coercive control indicator). |

---

## 10. Bid Summary

> **Contract Type:** Change Order / Additional Statement of Work (separate from the existing $60,000 Kuwboo rebuild contract)
>
> **Pricing Basis:** Fixed-price milestones. All prices are firm — not hourly billing. Prices include design, research, development, and testing for each milestone.

### 10.1 Milestone Bid

| Milestone | Deliverables | Fixed Price (USD) |
|-----------|-------------|-------------------|
| **M1: Design & Discovery** | UX flow designs for all workflows. Data model finalisation. Regulatory research (UK + US). Map provider evaluation. Background location platform spike (iOS + Android). Paywall integration design. Admin panel screen specifications. Battery-adaptive sampling strategy. | **$4,500** |
| **M2: Core Inner Circle** | Circle management (create, invite, accept, remove, leave). Real-time location sharing (WebSocket, GPS, battery-adaptive sampling). Google Maps integration with member pins and timeline scrubber. Circle chat (persistent, extends existing chat infra). Quick pings. Notification service (FCM). Automatic data purge. Background location (iOS + Android). Offline queue. Paywall gate. Onboarding/intro flow. Navigation entry points and deep links. Unit, integration, and platform-specific tests. | **$17,500** |
| **M3: Child Accounts + Safety Shell** | Under-13 Safety Shell (Call Parent, SOS, Emoji Status, location indicator). 13-17 parental controls (module access gates, contact approval, screen time, bedtime). Two-device handshake (both age tiers). Age-tiered UI restrictions (3 tiers). Parental control dashboard. Emoji status entity + elevated alert logic. COPPA consent recording (credit card VPC). Account transitions (age 13 and 18). Activity reporting + emoji log. All child account testing. | **$16,000** |
| **M4: Elder Monitoring** | Elder monitoring setup flow. Inactivity alerts (configurable waking hours + threshold). Wandering detection (PostGIS, always-active home-base geofence). Guardian dashboard (elder-specific view). Consent/POA document upload (S3). Elder "Simple Mode" UI. Accessibility improvements (large targets, WCAG AAA contrast). Consent confirmation flow. All elder monitoring testing. | **$5,500** |
| **M5: Emergency & Safety** | SOS/panic button (hold-to-confirm, rapid tracking, chat banner). SOS + Quick Ping home screen widgets. Geofence entity (PostGIS, server-side evaluation). Geofence creation UI (draw on map, scheduling). Geofence alerts + notification dispatch. Unusual activity detection (passive SOS rules). Low battery alerts. Alert history screen. End-to-end SOS and geofence testing. | **$7,500** |
| **M6: Platform Infrastructure** | ContentTag entity + tag-based feed filtering. UserFeatureFlag entity + resolution logic (system → region → group → user → parent). Region detection + per-state scoping. Admin panel: circle overview, parental control audit, elder monitoring audit, SOS event log, feature flag management, abuse report flow, content tag management, retention compliance dashboard, subscription analytics. Age verification system. Consent management. ICO AADC compliance. COPPA + CCPA compliance hardening. Abuse prevention safeguards (silent leave, hidden support, admin intervention). DSAR support. Privacy defaults enforcement. Consent flows (Flutter). DPIA documentation. Privacy policy updates. Compliance testing. | **$15,000** |
| **TOTAL BID** | | **$66,000** |

### 10.2 Payment Schedule

Payments are due on milestone completion and acceptance.

| Milestone | Payment | Cumulative | Acceptance Criteria |
|-----------|---------|------------|-------------------|
| M1: Design & Discovery | $4,500 | $4,500 | Signed-off design documents and data model |
| M2: Core Inner Circle | $17,500 | $22,000 | Demo on staging — adult circle with live location |
| M3: Child Accounts + Safety Shell | $16,000 | $38,000 | Demo on staging — child registration, Safety Shell, parental controls |
| M4: Elder Monitoring | $5,500 | $43,500 | Demo on staging — elder setup, inactivity alerts, wandering detection |
| M5: Emergency & Safety | $7,500 | $51,000 | Demo on staging — SOS end-to-end, geofence alerts |
| M6: Platform Infrastructure | $15,000 | $66,000 | Admin panel functional, compliance audit pass |

### 10.3 Optional Add-Ons (Separate Bids)

These are NOT included in the $66,000 bid. Each is a separate scope item that can be approved independently.

| Add-On | Description | Fixed Price (USD) |
|--------|------------|-------------------|
| **Apple Watch Companion App** | watchOS Safety Shell (emoji from wrist, SOS, call parent, location, complications). Native Swift. WatchConnectivity bridge to Flutter. Testing. App Store submission. See Appendix D. | **$8,000** |
| **Wear OS Companion App** | Same features as Watch, native Kotlin. Wear Data Layer bridge. Testing. Play Store submission. See Appendix D. | **$8,000** |
| **iOS Live Activities** | Dynamic Island + Lock Screen live updates for active SOS events, journey tracking, and geofence alerts. APNs push-to-start integration. See Appendix F. | **$3,000** |
| **Extended Home Screen Widgets** | Family status widgets (iOS + Android), child status widget, lock screen widget. Beyond the SOS/Ping widgets included in M4. See Appendix F. | **$3,500** |
| **Tracker Tag Onboarding** | Recommendation text + convenience shortcuts to Find My / SmartThings from Inner Circle settings. See Appendix E. | **Included in M2 at no extra cost** |

### 10.4 What's NOT in This Bid

| Exclusion | Reason | Estimated Cost (Separate) |
|-----------|--------|--------------------------|
| **Legal counsel** (UK) | Requires qualified data protection solicitor — see Appendix B | £9,500 |
| **Legal counsel** (US) | Requires US privacy attorney — see Appendix B | $16,500 |
| **COPPA Safe Harbor program** | Optional FTC-approved certification | $5,000/year |
| **Multi-zone infrastructure deployment** | Designed-for in schema, but infra deployment is separate — see Appendix A | $6,500 |
| **Third-party service fees** | Google Maps API, Twilio (if SMS), FCM (free tier), S3 storage | Operational — varies by usage |
| **App Store / Play Store fees** | Standard platform fees | $99/year (Apple) + $25 one-time (Google) |

### 10.5 Timeline

| Milestone | Estimated Duration | Dependencies |
|-----------|-------------------|-------------|
| M1: Design & Discovery | 3 weeks | Neil sign-off on this document |
| M2: Core Inner Circle | 7 weeks | M1 complete |
| M4: Elder Monitoring | 2 weeks | M2 complete (ships first — quick win, validates monitoring pattern) |
| M3: Child Accounts + Safety Shell | 6 weeks | M2 complete (legal review can run during M4) |
| M5: Emergency & Safety | 3 weeks | M2 complete (can overlap with M3) |
| M6: Platform Infrastructure | 4 weeks | M3 + M4 + M5 complete |
| **Total** | **~7 months** | |

```
M1 (Design, 3 wks)
 ↓
M2 (Core Inner Circle, 7 wks)
 ↓
M4 (Elder — quick win, 2 wks)     ← ships first, validates monitoring
 ↓               ↓
M3               M5
(Child/Safety    (SOS/Geofence)   ← can overlap
 Shell, 6 wks)   (3 wks)
 ↓               ↓
 └───────┬───────┘
         ↓
M6 (Platform Infrastructure + Compliance, 4 wks)
```

**Why M4 before M3:** Elder monitoring is simpler (no COPPA, no ICO AADC), ships in 2 weeks, and validates the monitoring infrastructure (inactivity alerts, guardian dashboard, wandering detection) before tackling the regulatory-heavy child system. Legal counsel for child accounts can review during M4 development.

### 10.6 Risk Factors

These risks are absorbed in the fixed bid — they do not result in additional charges to Neil.

| Risk | Mitigation |
|------|-----------|
| iOS App Review rejection for background location | Built into M2 timeline. Rework and resubmission included. |
| Android OEM battery quirks (Samsung, Xiaomi, Huawei) | Platform-specific testing included in M2. |
| Map provider integration edge cases | Google Maps spike in M1 reduces risk. |
| Two-device handshake platform behaviour | Deep link + push notification testing included in M3. |
| Parental control edge cases | Comprehensive testing included in M3. |
| PostGIS geofence performance | Spatial indexing strategy designed in M1. |
| Elder monitoring simpler than estimated | M4 bid is firm — if delivered faster, no refund, but timeline improves. |

**Risk NOT absorbed:** If legal counsel feedback (Appendix B) requires fundamental architectural changes to the data model or consent flows after M2 is complete, a change order may be required. This is why M1 includes regulatory research — to surface these issues early.

### 10.7 Bid Basis (Internal — Remove Before Sending to Neil)

Target rate: $60/hr. AI productivity factor: 1.5x. Estimated dev hours: 1,105. Total bid: $66,000.

---

## 11. Multi-Zone Readiness (Schema Design)

Even though Phase 1 launches in UK only, the schema is designed for multi-zone from day one:

- Every entity with user data includes a `dataZone: string` column (default `'eu-west-2'`)
- The `UserFeatureFlag` entity supports `regionScope` for per-country and per-state feature gating
- LocationPing includes `dataZone` for future routing to zone-specific storage
- The repository layer accepts an optional zone parameter (currently ignored, routes to single DB)

**When multi-zone is needed:** Add a new RDS instance in `us-east-1`, deploy the same schema, and update the repository layer to route queries based on `dataZone`. The application code doesn't change — only the infrastructure and routing middleware.

See [Appendix A](#appendix-a-multi-zone-data-architecture) for the full multi-zone architecture.

---

## Appendix A: Multi-Zone Data Architecture

> **Status:** Design-ready, implementation deferred. Schema includes `dataZone` columns from day one. Infrastructure deployment is a separate scope item when US launch approaches.

### A.1 Zone Strategy

| Zone | AWS Region | Users Served | Data Types Stored |
|------|-----------|-------------|------------------|
| **UK** | eu-west-2 (London) | UK users, EU users | All user data, location, content |
| **US-East** | us-east-1 (Virginia) | US users (Eastern/Central) | User data, location, content |
| **US-West** (future) | us-west-2 (Oregon) | US users (Western) | Optional — depends on user distribution |

### A.2 Data Routing

```
User Registration
  → IP geolocation + user-declared country
  → Assign dataZone
  → All subsequent data stored in assigned zone

User Moves Between Zones
  → Admin/user triggers zone migration
  → Bulk data transfer (background job)
  → Old zone data purged after confirmation
  → Not automatic — requires explicit action
```

### A.3 Cross-Zone Scenarios

| Scenario | Handling |
|----------|---------|
| UK parent, US child | Both users' data stored in their respective zones. Circle metadata replicated to both zones. Location pings stay in the child's zone. Parent queries child's zone for location data. |
| User travels (UK user in US) | Data continues to be stored in UK zone. Location pings tagged with actual GPS region for compliance. No zone transfer for temporary travel. |
| User relocates permanently | User requests zone transfer. Admin processes. Background migration job. |

### A.4 Infrastructure Cost Estimate (When Deployed)

| Component | Monthly Cost (Additional) |
|-----------|--------------------------|
| RDS PostgreSQL (us-east-1) | ~$15 |
| EC2 or Fargate (us-east-1) | ~$30 |
| S3 (us-east-1) | ~$5 |
| Cross-region data transfer | ~$5 |
| **Total additional** | **~$55/month** |

### A.5 Implementation Scope (When Ready)

| Task | Hours |
|------|-------|
| Multi-region RDS deployment | 12 |
| Application-level data routing middleware | 24 |
| Zone-specific S3 buckets + media routing | 12 |
| Cross-zone query layer (circle metadata replication) | 16 |
| Zone migration background job | 12 |
| Audit logging for cross-zone data access | 8 |
| Testing (multi-region) | 16 |
| **Total** | **100** |

This is NOT included in the main estimate. It's a separate scope item to be estimated and approved when US launch is planned.

---

## Appendix B: Legal Review Requirements by Zone

> **Status:** Legal review is REQUIRED before launching child/elder monitoring features in each jurisdiction. This appendix documents what must be reviewed and approximate costs. These costs are NOT included in the development hour estimates.

### B.1 UK (Launch Zone)

| Review Area | What Needs Review | Estimated Cost |
|------------|------------------|----------------|
| **ICO AADC Compliance** | 15-principle audit of child account features. Must be completed before child accounts go live. | £3,000-£8,000 |
| **UK GDPR DPIA** | Data Protection Impact Assessment for Inner Circle (location tracking, child data, elder monitoring). Required by law for high-risk processing. | £2,000-£5,000 |
| **Online Safety Act** | Review of age assurance mechanism, content moderation, and children's safety duties. | Included in AADC review |
| **Domestic Abuse Act** | Review of coercive control safeguards. | £1,000-£2,000 |
| **Terms of Service** | Child account terms, parental consent language, elder monitoring consent, SOS disclaimer (liability limitation). | £2,000-£4,000 |
| **Privacy Policy** | Inner Circle-specific privacy notice, children's privacy notice, elder monitoring privacy notice. | £1,500-£3,000 |
| **ICO Registration** | Annual registration with the Information Commissioner's Office. | £40-£2,900/year (based on turnover) |
| **UK Total** | | **£9,540-£24,900** |

### B.2 United States (Second Zone)

| Review Area | What Needs Review | Estimated Cost |
|------------|------------------|----------------|
| **COPPA Compliance** | Under-13 Safety Shell collects location data — COPPA fully applies. Review: credit card VPC adequacy, data minimisation, parental access/delete rights, children's privacy notice. Consider COPPA Safe Harbor program ($5,000-$15,000/yr). | $5,000-$10,000 |
| **California AADC** | Mirror of UK ICO AADC review for California-specific requirements. | $3,000-$5,000 |
| **CCPA/CPRA** | Minor consent flows, opt-in for under-16, sensitive data handling (location). | $2,000-$4,000 |
| **BIPA (Illinois)** | Review of whether any Inner Circle feature constitutes biometric data collection. Current assessment: NO, if no facial recognition is used for circle identity verification. If selfie verification (from Trust Engine) is used within circles, BIPA applies. | $1,500-$3,000 |
| **State Dating Laws** | Review whether Inner Circle's location sharing triggers state-specific dating app regulations. (Likely no — Inner Circle is family-oriented, not dating.) | $1,000-$2,000 |
| **Terms of Service** | US-specific terms, child account provisions, SOS liability limitations. | $2,000-$4,000 |
| **Privacy Policy** | US-specific privacy notices (CCPA requires specific language and disclosures). | $2,000-$3,000 |
| **US Total** | | **$16,500-$31,000** |

### B.3 Per-State Review (US)

Some US states require additional review before launching features there:

| State | Reason | Additional Cost |
|-------|--------|----------------|
| **California** | AADC + CCPA/CPRA | Included above |
| **Illinois** | BIPA (if biometrics used) | Included above |
| **Texas** | Texas Data Privacy and Security Act (2024) | $1,500-$3,000 |
| **Virginia** | VCDPA — child-specific provisions | $1,500-$3,000 |
| **Colorado** | CPA — sensitive data (children's location) | $1,500-$3,000 |
| **Connecticut** | CTDPA — children's data protections | $1,500-$3,000 |

**Recommendation:** Launch US-wide excluding states with additional requirements, then add states one at a time after per-state legal review. The `UserFeatureFlag` system supports per-state rollout.

### B.4 Biometrics Clarification

The original analysis flagged BIPA (Biometric Information Privacy Act). To clarify:

**BIPA applies ONLY if the app collects biometric identifiers** — face geometry, fingerprints, voiceprints, retina scans. The existing Safety Pipeline document (`SAFETY_PIPELINE.md`) describes a **selfie verification system for trust scoring** that uses face recognition. THIS is what triggers BIPA.

**Inner Circle itself does not require biometrics.** Identity confirmation comes from:
1. Phone number verification (OTP)
2. Payment method verification (paywall)
3. Two-device handshake (child accounts)

If the Trust Engine's selfie verification is NEVER used within Inner Circle (e.g., to verify that a new circle member is who they claim to be), then BIPA does not apply to Inner Circle specifically. BIPA concerns are limited to the Trust Engine feature, which is a separate scope.

**Our assumption:** No biometrics in Inner Circle. Device-level biometrics (Face ID, Touch ID) are the device manufacturer's responsibility, not ours. We rely on phone + payment + handshake for identity.

---

## Appendix C: Regulatory Quick Reference

| Regulation | Jurisdiction | Key Inner Circle Impact | Status |
|-----------|-------------|------------------------|--------|
| **Online Safety Act 2023** | UK | Children's safety duty, age assurance, content moderation | Requires legal review |
| **ICO AADC (Children's Code)** | UK | 15 principles for child-directed services. Location defaults to OFF for children (conflict with Inner Circle's purpose — needs parental consent override). | Requires legal review |
| **UK GDPR / DPA 2018** | UK | DPIA required. Parental consent for under-13 processing. Lawful basis for location tracking. | Requires DPIA |
| **Domestic Abuse Act 2021** | UK | Coercive control safeguards for location tracking features | Requires legal review |
| **Mental Capacity Act 2005** | UK | Legal basis for monitoring elders who lack capacity. POA verification. | Requires legal review |
| **COPPA** | US | Under-13 Safety Shell collects location data — COPPA fully applies. VPC via paywall credit card. Data minimisation, parental rights, children's privacy notice. | Requires legal review |
| **California AADC** | US (CA) | Mirrors ICO AADC for California minors under 18. | Requires legal review |
| **CCPA / CPRA** | US (CA) | Minors under 16 opt-in. Location is "sensitive personal information." | Requires legal review |
| **BIPA** | US (IL) | Only if facial recognition used. NOT applicable to Inner Circle if no biometrics. | Low risk — see Appendix B.4 |
| **DMCA** | US | User-generated content in circle chat. Takedown flow needed. | Existing requirement (not Inner Circle specific) |

---

## Appendix D: Smart Watch Companion App

> **Status:** Not included in main estimate. Separate scope item — recommended for Phase 2+ once core Inner Circle is stable on phones.

### D.1 Why This Matters

Apple Watch SE is marketed as a **kids' first device**. Many families buy a child a Watch before a phone. For elder care, Apple Watch already has fall detection and heart rate monitoring built in. A Kuwboo Watch companion app would make Inner Circle dramatically more useful for both primary use cases.

### D.2 Platform Support

| Platform | Device | Relevance |
|----------|--------|-----------|
| **watchOS** (Apple Watch) | Apple Watch SE, Series 7+ | Primary target. Apple Watch SE is the kids' safety watch. Fall detection on Series 4+. |
| **Wear OS** (Google) | Pixel Watch, Samsung Galaxy Watch | Secondary target. Less common for children, but relevant for elders with Android phones. |

### D.3 Watch Features by Age Tier

| Feature | Under-13 (Safety Shell) | 13-17 | Adult/Elder |
|---------|------------------------|-------|-------------|
| **Emoji Status** | Tap emoji on watch face → pushes to parent. This is the killer use case — a 7-year-old can tap "hungry" on their wrist. | Available | Available |
| **SOS** | Raise-to-SOS or long-press side button → alerts circle. No confirmation dialog on Watch (too fiddly for small wrists — immediate send). | Hold-to-confirm | Hold-to-confirm |
| **Call Parent** | Tap to call from Watch (requires cellular Watch or phone nearby) | Available | Available |
| **Location Sharing** | Watch GPS provides location pings when phone is not available | Supplementary to phone | Primary for elders who don't carry phone |
| **Quick Ping** | "I'm here" complication on watch face | Full ping selection | Full ping selection |
| **Circle Chat** | Not available (no keyboard on Watch) | Voice-to-text replies only | Voice-to-text replies only |
| **Geofence Alerts** | Haptic tap when entering/leaving zone | Haptic + visual | Haptic + visual |
| **Fall Detection** | Use Apple's built-in fall detection → trigger Inner Circle SOS if detected | Same | Primary use case for elders |
| **Watch Complications** | Battery/status of parent's phone | Circle member status | Circle member status |

### D.4 Architecture

```
Watch App                          Phone App                   Server
─────────                          ─────────                   ──────
watchOS / Wear OS companion  ←→   Flutter app (WatchConnectivity /    ←→   Same backend
                                   Wear Data Layer API)

Watch can operate independently if cellular-enabled:
Watch GPS → direct to server via Watch cellular → same LocationPing API
```

**Key constraint:** Flutter does not have native Watch SDK support. Watch companion apps must be written in:
- **watchOS:** Swift (SwiftUI for UI)
- **Wear OS:** Kotlin (Compose for Wear OS)

This means the Watch app is a **separate native codebase** that communicates with the Flutter app via platform bridge APIs (WatchConnectivity on iOS, Data Layer API on Android).

### D.5 Scope Estimate (Watch Companion)

| Task | Hours (Low) | Hours (High) |
|------|-------------|-------------|
| **Design:** Watch UI/UX (both platforms) | 16 |
| **watchOS:** Swift companion app (emoji, SOS, location, pings, complications) | 60 |
| **watchOS:** WatchConnectivity bridge to Flutter | 16 |
| **Wear OS:** Kotlin companion app (emoji, SOS, location, pings, tiles) | 60 |
| **Wear OS:** Data Layer bridge to Flutter | 16 |
| **Backend:** No changes needed (same APIs) | 0 |
| **Testing:** Both platforms, paired and independent modes | 24 |
| **App Store / Play Store:** Separate Watch app listings and review | 8 |
| **Total** | **200** |

**Recommendation:** Start with **watchOS only** (~120 hours). Apple Watch SE is the primary kids' safety device. Add Wear OS in a subsequent phase based on demand.

### D.6 Questions for Neil

| # | Question | Assumption |
|---|----------|-----------|
| Q-D1 | Should the Watch companion be in scope for Phase 1, or deferred? | **Deferred to Phase 2.** Core phone experience first. |
| Q-D2 | watchOS only, or both platforms? | **watchOS first.** Apple Watch SE is the kids' market leader. Wear OS follows if demand warrants. |
| Q-D3 | Should the Watch app work independently (cellular Watch without phone)? | **Yes, if the Watch has cellular.** This is the primary value for kids who don't have a phone yet. Requires Watch to connect directly to server. |

---

## Appendix E: Tracker Tags (AirTag, SmartTag, Tile)

> **Status:** Out of scope for Kuwboo development. These are closed third-party ecosystems. This appendix documents why and what to recommend to users instead.

### E.1 Why We Can't Integrate

| Tracker | Ecosystem | Integration Possible? | Reason |
|---------|-----------|----------------------|--------|
| **Apple AirTag** | Apple Find My | **No** | Apple's Find My network is closed. Third-party apps cannot read AirTag locations. Only the Find My app (and licensed accessories via the Find My Network Accessory Program) can access this data. Apple does not license this to social apps. |
| **Samsung SmartTag** | Samsung SmartThings | **No** | SmartThings API exists but SmartTag location is restricted to Samsung's own apps. No third-party access to tag location. |
| **Tile** | Tile Network | **Limited** | Tile has a partner API, but it's enterprise-only (fleet tracking, B2B). Not available for consumer social apps. |
| **Chipolo** | Chipolo App | **No** | Closed ecosystem. |

### E.2 What We Can Do

1. **Recommend pairing:** In the Inner Circle onboarding, suggest that parents also set up AirTag/SmartTag in the child's backpack using the native app. "For extra peace of mind, pair an AirTag with your child's school bag using Apple's Find My app."

2. **Link to native apps:** Provide a settings option that opens the relevant tracker app (Find My on iOS, SmartThings on Samsung) as a convenience shortcut.

3. **Future:** If Apple ever opens the Find My network API to third parties (they've shown no sign of this), integration would become possible. Monitor Apple's developer announcements annually.

### E.3 Scope Estimate

| Task | Hours |
|------|-------|
| Onboarding recommendation text + link to native apps | 2 |
| Settings shortcut to Find My / SmartThings | 2 |
| **Total** | **4** |

Negligible — can be included in Phase 2 at no meaningful cost.

---

## Appendix F: Home Screen Widgets & Live Activities

> **Status:** SOS and Quick Ping widgets are already included in the Phase 5 estimate (16 + 8 = 24 hours). This appendix expands on additional widget types and iOS Live Activities for real-time tracking.

### F.1 Widget Types

| Widget | Platform | Description | Priority |
|--------|----------|------------|----------|
| **SOS Button** | iOS + Android | One-tap SOS from home screen. No app launch needed. | **Phase 1** (included in estimate) |
| **Quick Ping** | iOS + Android | One-tap "I'm here" to default circle. | **Phase 1** (included in estimate) |
| **Family Status** | iOS + Android | Shows circle members' last known locations and emoji statuses. Glanceable. Updates every 15 minutes (OS widget refresh limit). | **Phase 2** |
| **Child Status** | iOS + Android | Parent-focused: shows child's current location, battery, last emoji. | **Phase 2** |
| **Lock Screen Widget** | iOS 16+ | Small widget on lock screen showing child's emoji status or "all clear" indicator. | **Phase 2** |

### F.2 iOS Live Activities (Dynamic Island + Lock Screen)

Live Activities are a real-time update mechanism on iOS 16+ that shows persistent, updating information on the Lock Screen and in the Dynamic Island (iPhone 14 Pro+). This is **perfect for Inner Circle tracking**.

| Live Activity | Trigger | What It Shows | Duration |
|---------------|---------|--------------|----------|
| **Active SOS** | SOS event triggered | Red banner: "[Child] needs help — [Location] — [Time since trigger]" with live-updating map pin | Until SOS resolved |
| **Active Journey** | "Track my journey" feature (parent requests, child accepts) | Moving dot on mini-map, ETA if destination set, battery level | Until arrival or manual stop |
| **Geofence Alert** | Child enters/leaves zone | "[Child] left School at [Time]" with compact map | 15 minutes, then auto-dismiss |

**Why this matters:** A parent can glance at their iPhone's Lock Screen or Dynamic Island and see their child's real-time location during an active journey — without opening the app. This is the highest-value passive monitoring UX possible on iOS.

### F.3 Android Glance Widgets

Android's Glance framework (Jetpack Glance) provides similar always-visible widget capabilities:

| Widget | Size | Content |
|--------|------|---------|
| **Small (2x1)** | Notification bar | Child emoji + "All good" or last ping time |
| **Medium (3x2)** | Home screen | Mini-map with family pins + battery levels |
| **Large (4x3)** | Home screen | Full circle status: map, emoji log, last pings, battery |

### F.4 Scope Estimate (Additional Widgets + Live Activities)

These are ADDITIONAL to the SOS/Ping widgets already in Phase 5.

| Task | Hours |
|------|-------|
| **iOS Live Activities:** SOS, Journey Tracking, Geofence Alert | 24 |
| **iOS Lock Screen Widget:** Child status | 8 |
| **iOS Family Status Widget** | 12 |
| **Android Glance Widgets:** Small, Medium, Large | 20 |
| **Backend:** Live Activity push token management (APNs push-to-start) | 8 |
| **Testing:** Widget refresh accuracy, Live Activity reliability | 12 |
| **Total** | **84** |

**Recommendation:** iOS Live Activities for SOS events should be in Phase 1 (high safety value, ~12 hours). The rest can follow in Phase 2.

### F.5 Questions for Neil

| # | Question | Assumption |
|---|----------|-----------|
| Q-F1 | Should iOS Live Activities for SOS be in Phase 1? | **Yes, recommended.** When a child triggers SOS, the parent seeing it on their Dynamic Island immediately (without opening the app) is a significant safety improvement. ~12 hours additional. |
| Q-F2 | Full home screen widgets in Phase 1 or Phase 2? | **Phase 2.** SOS and Quick Ping widgets are sufficient for launch. Family status widgets follow. |

---

**Next Steps:**
1. Neil reviews the Questions for Neil section and provides answers
2. Legal counsel engaged for UK zone (see Appendix B)
3. M1 (Design & Discovery) begins after sign-off
4. Bid refined after Design phase completes
