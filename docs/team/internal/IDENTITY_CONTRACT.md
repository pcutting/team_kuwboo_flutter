# Kuwboo: Identity Contract

**Status:** Authoritative — Phase D0 of the identity execution plan.
**Supersedes:** `AUTH_CONTRACT.md` (closed via PR #84). All open questions from that doc are resolved here.
**Integrates:** [`TRUST_ENGINE.md`](./TRUST_ENGINE.md), [`REGULATORY_REQUIREMENTS.md`](./REGULATORY_REQUIREMENTS.md), [`TECHNICAL_DESIGN.md`](./TECHNICAL_DESIGN.md).
**Implementation target:** Phases D1–D3 (backend core entities, shared api_client, mobile/admin consumers).

---

## 1. Purpose & Scope

This document is the single source of truth for how a Kuwboo user is identified, authenticated, age-gated, trusted, and profiled. It unifies the previously separate concerns of sign-in (`AUTH_CONTRACT.md`), trust scoring (`TRUST_ENGINE.md`), age assurance (`REGULATORY_REQUIREMENTS.md`), and behavioural interest modelling into one executable spec. Every downstream implementation phase (D1a backend core, D1b interests, D1c prototype UX, D2a shared client, D2b/c/d integration) is built against this contract. Every API path, entity column, enum value, and rate limit in this document is considered committed — if an implementation detail disagrees with this document, this document wins or the document is amended first via PR.

---

## 2. Guiding Principles

1. **One user, many credentials.** A `user` is the durable identity; phone, email, Google, and Apple are *credentials* attached to it. JWTs carry `user_id`, never `credential_id`.
2. **Phone, email, and SSO are peers.** Email is not a "recovery" channel bolted onto phone. Any verified credential signs in as the full user.
3. **The verification badge is derived, not stored.** `users.trust_score >= 60` implies the "Verified" badge — no separate boolean.
4. **Soft gates before hard gates.** Profile completeness is a nudge, not a wall. The only hard gate in the product is **18+ on dating routes** (legal requirement). Everything else degrades gracefully.
5. **No silent cross-account merges.** Two accounts sharing an email is a support-team operation, never an API path, because auto-merge enables takeover attacks.
6. **Self-declared age is acceptable v1; provider-verified is deferred.** DOB is nullable and skippable outside dating. Yoti / ID-check integration is noted as future work and not in this phase.
7. **Append-only audit trails.** `trust_signals`, `interest_signals`, and `verifications` are event-sourced — we never mutate historical rows.
8. **Rate-limit at the identifier, not just the IP.** Per-identifier limits prevent farm attacks from distributed IPs; per-IP limits prevent enumeration from a single attacker.

---

## 3. Data Model

### 3.1 Entity overview

```
users ──┬── credentials         (N:1, UNIQUE(type, identifier))
        ├── verifications       (append-only audit of verify attempts)
        ├── trust_signals       (append-only, score = sum(delta))
        ├── user_interests      (declared, on onboarding)
        └── interest_signals    (behavioural, event-sourced, decayed)

interests (taxonomy) ── user_interests, interest_signals
```

### 3.2 `users` (extended)

Pre-existing entity per `TECHNICAL_DESIGN.md`. Columns added by this contract are marked **[new]**.

```sql
users
  id                        uuid PK
  display_name              text
  username                  citext UNIQUE
  avatar_url                text
  bio                       text
  date_of_birth             date                       -- [new] nullable; required for dating
  birthday_skipped          bool  DEFAULT false        -- [new] user chose Skip on authBirthday
  onboarding_progress       onboarding_progress_enum   -- [new] resume pointer
      DEFAULT 'welcome'
  profile_completeness_pct  int   DEFAULT 0            -- [new] 0-100, recomputed on PATCH
  tutorial_version          int   DEFAULT 0            -- [new] bump to re-show tutorial
  tutorial_completed_at     timestamptz                -- [new] null until first completion
  last_reminder_at          timestamptz                -- [new] throttles nudge FCM job
  trust_score               int   DEFAULT 0            -- derived; see TRUST_ENGINE §2.1
  social_reputation         int   DEFAULT 50           -- see TRUST_ENGINE §2.2
  seller_reputation         int   DEFAULT 50           -- see TRUST_ENGINE §2.3
  visibility_tier           char(1) DEFAULT 'C'        -- A|B|C|D, see TRUST_ENGINE §4
  age_verification_status   age_verification_enum      -- see REGULATORY §2.2 / 3.1
      DEFAULT 'self_declared'
  created_at                timestamptz DEFAULT now()
  last_login_at             timestamptz
  deleted_at                timestamptz                -- soft delete

CREATE TYPE onboarding_progress_enum AS ENUM (
  'welcome', 'method', 'phone', 'otp', 'birthday',
  'profile', 'interests', 'tutorial', 'complete'
);

CREATE TYPE age_verification_enum AS ENUM (
  'unverified', 'self_declared', 'provider_verified', 'failed'
);

CREATE INDEX idx_users_onboarding_progress ON users(onboarding_progress)
  WHERE onboarding_progress != 'complete';
CREATE INDEX idx_users_nudge_candidates ON users(last_reminder_at)
  WHERE profile_completeness_pct < 70;
CREATE INDEX idx_users_visibility_tier ON users(visibility_tier);
```

### 3.3 `credentials` **[new]**

```sql
credentials
  id             uuid PK
  user_id        uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE
  type           credential_type_enum NOT NULL
  identifier     text NOT NULL                    -- E.164 phone / lowercased email / SSO sub
  provider_data  jsonb                            -- raw SSO claims for audit; null for phone/email
  verified_at    timestamptz NOT NULL
  is_primary     bool DEFAULT false
  revoked_at     timestamptz                      -- null = active
  created_at     timestamptz DEFAULT now()
  last_used_at   timestamptz

  UNIQUE (type, identifier)                       -- prevents credential theft across users
  UNIQUE (user_id, type) WHERE is_primary AND revoked_at IS NULL

CREATE TYPE credential_type_enum AS ENUM ('phone', 'email', 'google', 'apple');

CREATE INDEX idx_credentials_user_active ON credentials(user_id) WHERE revoked_at IS NULL;
CREATE INDEX idx_credentials_lookup ON credentials(type, identifier) WHERE revoked_at IS NULL;
```

### 3.4 `verifications` **[existing, per TECHNICAL_DESIGN]**

Append-only attempt log. Stores OTPs (hashed), SSO exchange receipts, and future provider-verification receipts.

```sql
verifications
  id             uuid PK
  user_id        uuid REFERENCES users(id)        -- nullable for pre-signup OTPs
  channel        verification_channel_enum        -- 'phone_otp' | 'email_otp' | 'google' | 'apple' | 'yoti'
  identifier     text NOT NULL                    -- phone / email / provider sub
  code_hash      text                             -- bcrypt(otp); null for SSO
  expires_at     timestamptz NOT NULL
  consumed_at    timestamptz
  ip             inet
  user_agent     text
  attempts       int DEFAULT 0
  created_at     timestamptz DEFAULT now()

CREATE INDEX idx_verifications_identifier_channel_unconsumed
  ON verifications(identifier, channel) WHERE consumed_at IS NULL;
```

### 3.5 `trust_signals` **[existing in TRUST_ENGINE §8.3]**

Append-only. The user's `trust_score` is `clamp(0, 100, SUM(delta))` over active signals. See `TRUST_ENGINE.md` §2.1 for the full weight table; signals introduced specifically by this contract are listed in section 7 below.

```sql
trust_signals
  id          uuid PK
  user_id     uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE
  signal_type text NOT NULL                    -- 'phone_verified_mobile', 'email_verified', ...
  delta       int NOT NULL                     -- positive or negative
  source      text                             -- 'onboarding' | 'moderation' | 'decay' | 'admin'
  metadata    jsonb
  expires_at  timestamptz                      -- null = permanent
  created_at  timestamptz DEFAULT now()

CREATE INDEX idx_trust_signals_user_active ON trust_signals(user_id)
  WHERE expires_at IS NULL OR expires_at > now();
```

### 3.6 `interests`, `user_interests`, `interest_signals` **[new]**

```sql
interests                                       -- taxonomy, admin-managed
  id            uuid PK
  slug          text UNIQUE NOT NULL            -- immutable; used in event payloads
  label         text NOT NULL                   -- admin-editable display string
  category      text                            -- 'sport' | 'music' | 'hobby' | ...
  display_order int DEFAULT 0
  is_active     bool DEFAULT true               -- soft-delete
  created_at    timestamptz DEFAULT now()
  updated_at    timestamptz DEFAULT now()

user_interests                                  -- declared by user in onboarding
  user_id     uuid REFERENCES users(id) ON DELETE CASCADE
  interest_id uuid REFERENCES interests(id) ON DELETE CASCADE
  selected_at timestamptz DEFAULT now()
  PRIMARY KEY (user_id, interest_id)

interest_signals                                -- behavioural, event-sourced
  user_id      uuid REFERENCES users(id) ON DELETE CASCADE
  interest_id  uuid REFERENCES interests(id) ON DELETE CASCADE
  weight       float NOT NULL DEFAULT 0         -- exponentially decayed
  last_seen_at timestamptz DEFAULT now()
  event_count  int NOT NULL DEFAULT 0           -- total contributing events (for warm-up check)
  PRIMARY KEY (user_id, interest_id)

CREATE INDEX idx_user_interests_interest ON user_interests(interest_id);
CREATE INDEX idx_interest_signals_user ON interest_signals(user_id) WHERE weight > 0;
```

---

## 4. Auth Flows

All OTPs are 6 digits, 10-minute TTL, stored in `verifications` as `bcrypt(otp)`. Rate limits: **5 per identifier per 15min** + **20 per IP per 15min** (guarded in Nest, shared for `send-otp` and `resend`). Tokens: `access_token` (15min JWT) + `refresh_token` (30 days, rotating).

### 4.1 Phone OTP — new user

```
Client                          API
  │ POST /auth/phone/send-otp   │
  │─{phone: "+447..."}─────────▶│ rate-limit check
  │                             │ INSERT verifications(channel=phone_otp, identifier, code_hash, expires_at)
  │                             │ Twilio.send(otp)
  │◀────── 200 {sent: true} ────│
  │ POST /auth/phone/verify-otp │
  │─{phone, code}──────────────▶│ SELECT verifications WHERE identifier AND channel AND NOT consumed
  │                             │ bcrypt.compare(code, code_hash)
  │                             │ UPDATE verifications SET consumed_at = now()
  │                             │ LOOKUP credentials(type=phone, identifier=phone) → MISS
  │                             │ INSERT users(...), credentials(type=phone, ...verified_at=now())
  │                             │ APPEND trust_signals('phone_verified_mobile' or 'phone_verified_voip')
  │◀ 200 {access, refresh, user, isNew: true} ─│
```

### 4.2 Phone OTP — returning user

Identical to 4.1 except the credential lookup hits. No user/credential insert; `users.last_login_at` and `credentials.last_used_at` are bumped. Response `isNew: false`.

### 4.3 Email OTP — peer to phone

Exactly parallel to phone. `POST /auth/email/send-otp` → SES sends code → `POST /auth/email/verify-otp` → sign in or create. Email is normalised: lowercase, trim, Gmail dot-strip. Disposable-email domains (Kickbox-style blocklist) rejected at the `send-otp` step with `422 {code: "disposable_email"}`. Email credentials contribute `+10` to trust score (TRUST_ENGINE §2.1 "Email verified").

### 4.4 Google SSO — first time (no email match)

```
Client: signInWithGoogle() → idToken
  │ POST /auth/google           │
  │─{idToken}─────────────────▶│ verify idToken against Google public keys
  │                             │ extract {sub, email, email_verified, name, picture}
  │                             │ LOOKUP credentials(type=google, identifier=sub) → MISS
  │                             │ LOOKUP credentials(type=email, identifier=email) → MISS
  │                             │ INSERT users(...), credentials(type=google, identifier=sub,
  │                             │                                 provider_data=claims, verified_at=now())
  │                             │ IF email_verified: also INSERT credentials(type=email, identifier=email)
  │                             │ APPEND trust_signals('sso_google_verified' +5)
  │◀ 200 {access, refresh, user, isNew: true} ─│
```

### 4.5 Google SSO — email matches an existing credential

This is the anti-takeover path. If `credentials(type=email, identifier=<google email>)` already exists on **a different** user, we **do not** silently merge. We require the user to prove control of that email:

```
  │ POST /auth/google           │
  │─{idToken}─────────────────▶│ google credential MISS, email credential HIT on user X
  │◀ 409 {code: "email_owned", challenge_id: "..."}
  │ POST /auth/email/send-otp   │
  │─{email, challenge_id}─────▶│ send OTP to that email
  │ POST /auth/google/confirm   │
  │─{idToken, email_otp, challenge_id} ▶ verify OTP → attach google credential to user X
  │◀ 200 {access, refresh, user, isNew: false} ─│
```

If the user fails the OTP, no credential is attached; they may retry or abandon. We never create a second user with the same email.

### 4.6 Apple SSO — both cases

Same shape as Google. Apple requires `authorizationCode` **in addition to** `identityToken` — the current shared client omits it; D2a fixes this.

```
POST /auth/apple
  body: { identityToken, authorizationCode, nonce }
```

`authorizationCode` is exchanged server-side for a refresh token via Apple's `/auth/token` endpoint; we store the refresh token in `provider_data` for future revocation checks. The email-match → prove-ownership path is identical to Google's (see 4.5), substituting `POST /auth/apple/confirm`.

### 4.7 Token refresh

```
POST /auth/refresh
  Authorization: Bearer <expired_access_token>
  body: { refresh_token }
```

**Fix from legacy:** the access token is read from the `Authorization` header even when expired — the refresh endpoint accepts `exp`-expired JWTs specifically because that's the definition of the problem. The refresh token is verified, rotated (old one revoked, new one issued), and a fresh access token is returned. Reuse of a revoked refresh token triggers a family-wide revocation (all tokens for that user) and a `trust_signals('refresh_reuse_detected' -10)` append.

### 4.8 Attach second credential

Authenticated route. The user is already `user_id=U`; they want to add e.g. an email to a phone-only account.

```
POST /auth/email/send-otp  (authenticated; rate-limited)
POST /credentials
  Authorization: Bearer <valid_access_token>
  body: { type: 'email', identifier: 'foo@example.com', otp: '123456' }
   → verify OTP via verifications table (consumes it)
   → INSERT credentials(user_id=U, type=email, identifier=<normalised>)
   → APPEND trust_signals('email_verified' +10) if this is the first email credential
   → 201 { credential: {...} }
```

If the email is already in use by another user, respond `409 {code: "credential_in_use"}` — no merge.

---

## 5. Onboarding Flow

The prototype's 11 auth/onboarding screens map to `onboarding_progress` transitions. On every successful PATCH that advances state, the server updates `onboarding_progress` to the column value in the table below. On cold-start, if `onboarding_progress != 'complete'`, the mobile router redirects to the matching screen.

| # | Screen (prototype)     | Primary endpoint            | `onboarding_progress` set to |
|---|------------------------|-----------------------------|------------------------------|
| 1 | authWelcome            | —                           | `welcome` (default)          |
| 2 | authMethod             | —                           | `method`                     |
| 3 | authPhone              | `POST /auth/phone/send-otp` | `phone`                      |
| 4 | authOtp                | `POST /auth/phone/verify-otp` | `otp` → user row created   |
| 5 | authBirthday           | `PATCH /users/me` (dob OR skip) | `birthday`                |
| 6 | authProfile            | `PATCH /users/me` (display_name, username, avatar_url) | `profile` |
| 7 | authInterests          | `POST /users/me/interests` (bulk) | `interests`            |
| 8 | authTutorial (3 pages) | `POST /users/me/tutorial-complete` | `tutorial`            |
| 9 | (home)                 | —                           | `complete`                   |

Screens 10 and 11 in the prototype set are variant/dev screens not on the happy path (legal-consent slide and account-exists detour); both are covered by the OTP and attach-credential flows above.

**Resume behavior:** if the app is killed at step 5, `onboarding_progress='birthday'`; on relaunch, `GET /users/me` returns that value, and the router pushes directly to `authBirthday`. Data entered on previous screens is persisted at each PATCH, never batched.

---

## 6. Age & Dating Gate

Legal context: dating services under UK Online Safety Act and US state dating-app laws require a **hard 18+ gate**; other modules use age-appropriate feature gating (ICO AADC) but do not require blocking access. See [`REGULATORY_REQUIREMENTS.md`](./REGULATORY_REQUIREMENTS.md) §2.1 (OSA), §2.2 (AADC), §3.3 (state dating laws) for the legal details.

This contract specifies the mechanics:

- **Schema:** `users.date_of_birth date NULL` and `users.birthday_skipped bool DEFAULT false`. DOB can be set later via `PATCH /users/me`.
- **Hard gate:** every dating-module route carries `@DatingAgeGuard`:
  - `date_of_birth IS NULL` → `403 {code: "dob_required"}`
  - `age_from_dob < 18` → `403 {code: "under_18"}`
  - `age_verification_status = 'failed'` → `403 {code: "age_failed"}`
- **Soft gates (other modules):** where a feature benefits from age (e.g. marketplace age-restricted categories), the handler reads DOB and returns a `feature_locked` placeholder for the client to render a "Set your birthday to unlock" CTA, never a 403.
- **Provider verification (future):** Yoti integration will write `age_verification_status='provider_verified'` and a `trust_signals('age_provider_verified' +20)` row. Not in this phase.

---

## 7. Trust Score + Verification Badge

All weights and decay rules are defined in [`TRUST_ENGINE.md`](./TRUST_ENGINE.md) §2 and are not duplicated here. The "Verified" badge is displayed in all UIs when `users.trust_score >= 60`; it is **not** stored as a boolean.

**Signals this contract introduces / touches:** each is appended as one row in `trust_signals` when the triggering event occurs in flows described in section 4.

| Event                          | signal_type                      | delta | Source          | Trigger                              |
|--------------------------------|----------------------------------|-------|-----------------|--------------------------------------|
| Phone verified, carrier=mobile | `phone_verified_mobile`          | +40   | onboarding/auth | §4.1–4.2 success                    |
| Phone verified, carrier=voip   | `phone_verified_voip`            | -20   | onboarding/auth | §4.1 if carrier lookup returns voip |
| Email verified                 | `email_verified`                 | +10   | onboarding/auth | §4.3 and §4.8 (first email)         |
| Google SSO verified            | `sso_google_verified`            | +5    | onboarding/auth | §4.4 success                         |
| Apple SSO verified             | `sso_apple_verified`             | +5    | onboarding/auth | §4.6 success                         |
| Refresh-token reuse detected   | `refresh_reuse_detected`         | -10   | auth            | §4.7 revoked token replayed         |
| Account age ≥ 30 days          | `account_age_30d`                | +5    | decay worker    | scheduled                            |
| Selfie verification passed     | `selfie_verified`                | +30   | moderation      | future (covered by TRUST_ENGINE)    |

Weights for signals outside the sign-in / onboarding path (moderation reports, dormancy, device consistency) are owned by `TRUST_ENGINE.md` §2 and appended by their respective subsystems.

---

## 8. Profile Completeness

Denormalised `users.profile_completeness_pct` (0–100), recomputed inside the `PATCH /users/me` handler and on credential attach/revoke.

```
pct = (dob              ? 10 : 0)
    + (display_name     ? 15 : 0)
    + (username         ? 15 : 0)
    + (avatar_url       ? 15 : 0)
    + (interests >= 3   ? 15 : 0)
    + (primary_phone_verified ? 10 : 0)
    + (primary_email_verified ? 10 : 0)
    + (tutorial_completed_at  ? 10 : 0)
```

Maximum 100. **This is a soft nudge — never a gate.** The only hard gate in the product is the dating 18+ gate (section 6). Users below 70% get at most one FCM reminder per 7 days via the nightly BullMQ `profile-completeness-nudge` job (Phase D3a); this is throttled by `users.last_reminder_at`.

---

## 9. Interests: Declared + Behavioural

Two sources of interest data are blended at read time:

**Declared** — written synchronously when the user taps chips on `authInterests` or via `POST /users/me/interests`. Stored in `user_interests`. Changes infrequently.

**Behavioural** — written asynchronously by the `interest-signal` BullMQ worker (Phase D2d) consuming these events:

| Event              | Source module      | Payload shape                                  |
|--------------------|--------------------|-----------------------------------------------|
| `video.watched`    | video              | `{userId, videoId, interestIds, watchMs}`     |
| `content.liked`    | all content modules| `{userId, contentId, contentType, interestIds}` |
| `post.read`        | social_stumble, blog | `{userId, postId, interestIds, readMs}`     |
| `search.executed`  | search             | `{userId, query, resolvedInterestIds}`        |

The worker upserts into `interest_signals`, incrementing `weight` by event-specific deltas (video.watched +1.0, content.liked +0.5, post.read +0.3, search.executed +0.2) and `event_count` by 1, setting `last_seen_at=now()`.

**Decay:** weekly cron job (`0 3 * * 0`, Sunday 03:00 UTC) multiplies every row's `weight` by 0.9. Rows where `weight < 0.01` are deleted.

**Recommendation blend:**

```
if interest_signals.event_count >= 20 (warm):
    score = 0.6 * normalised(behavioural_weight) + 0.4 * declared_present(0|1)
else (cold):
    score = declared_present(0|1)
```

The warm-up threshold prevents a brand-new user's behavioural vector (dominated by noise) from drowning out their declared intent.

---

## 10. Admin Surface

The admin SPA (`apps/admin/`, React 19 + Vite, deployed to Vercel) consumes the same API with an `admin` scope on JWTs. This contract defines the admin-relevant surface; `apps/admin/` UI design is outside scope.

| Surface                | Capability                                                         | Endpoints (§11)                                           |
|------------------------|--------------------------------------------------------------------|-----------------------------------------------------------|
| Interests CRUD         | Create, rename, reorder, soft-delete interests                     | `POST|PATCH|DELETE /admin/interests`                      |
| User search            | Search users by username/email/phone/id                            | `GET /admin/users?q=...`                                  |
| User detail            | View profile, trust score, visibility tier, onboarding state       | `GET /admin/users/:id`                                    |
| Credentials list       | See all credentials on a user (active + revoked)                   | `GET /admin/users/:id/credentials`                        |
| Credential revoke      | Force-revoke a credential (e.g. stolen phone)                      | `POST /admin/credentials/:id/revoke`                      |
| Trust signal audit     | Read-only feed of signals for a user with source + delta + metadata | `GET /admin/users/:id/trust-signals`                     |

Admin endpoints are mounted under `/admin/*` and guarded by `@AdminGuard` (JWT claim `role=admin`). All admin writes append an `admin_action` audit row (separate table, outside this contract's scope).

---

## 11. API Endpoints Catalogue

This catalogue is the **contract D1 implements**. All paths are mounted at the module prefix shown; all responses are JSON. Rate limits are per-identifier + per-IP unless noted. Authenticated routes require `Authorization: Bearer <access_token>` with valid (non-expired) JWT; `POST /auth/refresh` is the exception.

### 11.1 Auth (public)

| Method | Path                         | Auth | Request body                                         | Response                                      | Rate limit                     |
|--------|------------------------------|------|------------------------------------------------------|-----------------------------------------------|--------------------------------|
| POST   | `/auth/phone/send-otp`       | —    | `{phone}`                                            | `{sent: true}`                                | 5/15m identifier, 20/15m IP    |
| POST   | `/auth/phone/verify-otp`     | —    | `{phone, code}`                                      | `{access, refresh, user, isNew}`              | 10/15m identifier              |
| POST   | `/auth/email/send-otp`       | —    | `{email}`                                            | `{sent: true}`                                | 5/15m identifier, 20/15m IP    |
| POST   | `/auth/email/verify-otp`     | —    | `{email, code}`                                      | `{access, refresh, user, isNew}`              | 10/15m identifier              |
| POST   | `/auth/google`               | —    | `{idToken}`                                          | `{access, refresh, user, isNew}` or `409 email_owned` | 30/15m IP             |
| POST   | `/auth/google/confirm`       | —    | `{idToken, email_otp, challenge_id}`                 | `{access, refresh, user, isNew: false}`       | 10/15m IP                      |
| POST   | `/auth/apple`                | —    | `{identityToken, authorizationCode, nonce}`          | `{access, refresh, user, isNew}` or `409 email_owned` | 30/15m IP             |
| POST   | `/auth/apple/confirm`        | —    | `{identityToken, email_otp, challenge_id}`           | `{access, refresh, user, isNew: false}`       | 10/15m IP                      |
| POST   | `/auth/refresh`              | expired-accepted | `{refresh_token}` + `Authorization` (expired OK) | `{access, refresh}`                           | 60/15m user                    |
| POST   | `/auth/logout`               | yes  | `{refresh_token}`                                    | `{ok: true}`                                  | 60/15m user                    |

### 11.2 Credentials (authenticated)

| Method | Path                    | Auth | Request body                               | Response                | Rate limit       |
|--------|-------------------------|------|--------------------------------------------|-------------------------|------------------|
| GET    | `/credentials`          | yes  | —                                          | `{credentials: [...]}`  | 120/15m user     |
| POST   | `/credentials`          | yes  | `{type, identifier, otp?}`                 | `201 {credential}`      | 10/15m user      |
| DELETE | `/credentials/:id`      | yes  | —                                          | `204`                   | 10/15m user      |

Rules: user cannot delete their last active credential (`409 last_credential`); deleting a primary promotes the oldest remaining credential of the same type to primary, or leaves the slot empty if no others.

### 11.3 Users (authenticated)

| Method | Path                             | Auth | Request body                                               | Response                                | Rate limit     |
|--------|----------------------------------|------|------------------------------------------------------------|-----------------------------------------|----------------|
| GET    | `/users/me`                      | yes  | —                                                          | `{user}` (full profile + onboarding_progress) | 240/15m user |
| PATCH  | `/users/me`                      | yes  | Partial `{display_name?, username?, avatar_url?, bio?, date_of_birth?, birthday_skipped?}` | `{user}` (with recomputed `profile_completeness_pct` + `onboarding_progress`) | 60/15m user |
| POST   | `/users/me/tutorial-complete`    | yes  | `{version}`                                                | `{user}`                                | 20/15m user    |
| GET    | `/users/username-available`      | yes  | query `?handle=foo`                                        | `{available: bool}`                     | 120/15m user   |
| GET    | `/users/me/interests`            | yes  | —                                                          | `{interests: [...]}`                    | 60/15m user    |
| POST   | `/users/me/interests`            | yes  | `{interest_ids: [uuid, ...]}`                              | `{interests: [...]}` (full set after write) | 20/15m user |
| DELETE | `/users/me/interests/:id`        | yes  | —                                                          | `204`                                   | 60/15m user    |

### 11.4 Interests taxonomy (public read)

| Method | Path               | Auth | Response               | Rate limit    |
|--------|--------------------|------|------------------------|---------------|
| GET    | `/interests`       | —    | `{interests: [...]}` (active only, ordered by display_order) | 240/15m IP |

### 11.5 Admin (admin-scoped)

| Method | Path                                      | Auth   | Request / Response                                   |
|--------|-------------------------------------------|--------|------------------------------------------------------|
| POST   | `/admin/interests`                        | admin  | `{slug, label, category, display_order}` → `{interest}` |
| PATCH  | `/admin/interests/:id`                    | admin  | Partial → `{interest}`                               |
| DELETE | `/admin/interests/:id`                    | admin  | → `204` (soft-delete: `is_active=false`)             |
| GET    | `/admin/users`                            | admin  | query `?q=...&limit=...&cursor=...` → `{users, next_cursor}` |
| GET    | `/admin/users/:id`                        | admin  | → `{user}` (extended with credentials summary)       |
| GET    | `/admin/users/:id/credentials`            | admin  | → `{credentials: [...]}` (includes revoked)          |
| POST   | `/admin/credentials/:id/revoke`           | admin  | `{reason}` → `{credential}`                          |
| GET    | `/admin/users/:id/trust-signals`          | admin  | query `?limit=...&cursor=...` → `{signals, next_cursor}` |

All admin writes emit an audit log row (admin_id, action, target_id, timestamp, metadata).

### 11.6 Shared error shape

```json
{ "error": { "code": "string_constant", "message": "human-readable", "details": { /* optional */ } } }
```

Canonical codes used by this contract: `rate_limited`, `invalid_otp`, `expired_otp`, `disposable_email`, `credential_in_use`, `last_credential`, `email_owned`, `dob_required`, `under_18`, `age_failed`, `refresh_reuse_detected`.

---

## 12. Open Items / Deferred

The following are deliberately **out of scope** for Phase D1–D3 and are not implemented against this contract. They are listed here so implementers do not attempt to pick them up opportunistically.

- **Cross-account merge** (one human, two accounts with different phones). v1 policy: support-team operation via admin revoke of one account's credentials and data export. No API path.
- **Yoti / provider-verified age assurance.** Schema column `age_verification_status` includes the `provider_verified` enum value; the integration itself is future work. See `REGULATORY_REQUIREMENTS.md` §2.2.
- **ID-check (selfie + document) validation.** `trust_signals.selfie_verified` weight is reserved but the moderation pipeline that produces it is not in this phase.
- **Biometric liveness (BIPA-sensitive).** Covered by `REGULATORY_REQUIREMENTS.md` §3.4; deferred.
- **Phone number re-assignment detection.** When a carrier reassigns a number, the previous owner's credential is still on file. Mitigation (re-verify prompts on long-dormant credentials) is deferred.

---

## 13. References

- [`TRUST_ENGINE.md`](./TRUST_ENGINE.md) — trust score weights, decay mechanics, visibility tiers A/B/C/D, BullMQ job definitions.
- [`REGULATORY_REQUIREMENTS.md`](./REGULATORY_REQUIREMENTS.md) — UK OSA, ICO AADC, UK GDPR, US COPPA/CCPA/BIPA, state dating laws, DMCA.
- [`TECHNICAL_DESIGN.md`](./TECHNICAL_DESIGN.md) — NestJS + Passport strategy stack, SES email, 32-entity schema, feed architecture.
- [`REALTIME_ARCHITECTURE.md`](./REALTIME_ARCHITECTURE.md) — Socket.io gateway contracts (consumes user identity from JWT per this doc).
- Identity execution plan — `~/.claude/plans/playful-snacking-ember.md` (Phases D0–D3b).
