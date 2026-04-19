# Milestone 2 — Gap Analysis

**Date:** 2026-04-19
**Auditor:** Read-only code audit against `docs/client/CONTRACT_KUWBOO_REBUILD.md` §Milestone 2.
**Scope of audit:** `apps/api/src/` (NestJS backend) and `apps/admin/src/` (React admin panel).

## Legend
- DONE — implemented, tested, running in prod
- PARTIAL — scaffolded; core path works but something material is stubbed/untested
- MISSING — no code found
- UNCLEAR — scope ambiguous, needs Neil/Phil to define

---

## Contract Milestone 2 line items (verbatim)

> - Backend API framework and database setup
> - User registration, login, and profile management
> - JWT authentication with refresh token rotation
> - Media upload and processing pipeline (photos, videos)
> - Push notification service integration
> - Admin panel foundation
>
> **Acceptance criteria:**
> - User can register, login, and manage profile
> - Media upload and retrieval functional
> - Push notifications deliverable to test devices

---

## 1. Backend API framework and database setup — DONE

- NestJS 11 on EC2 `35.177.230.139` (eu-west-2), PM2 + Nginx (`apps/api/`).
- MikroORM + PostgreSQL 16 on RDS (`kuwboo-greenfield-db`).
- 8 migrations applied (`apps/api/src/database/migrations/Migration20260403_init.ts` through `Migration20260417_auth_and_credibility.ts`).
- Swagger/OpenAPI enabled (`@ApiTags`, `@ApiBearerAuth` present across controllers).
- Health endpoint module (`apps/api/src/modules/health/`).
- **Evidence:** `apps/api/src/app.module.ts`, `nest-cli.json`, `docs/team/internal/INFRASTRUCTURE.md`.

**Effort to close:** None — shipped.

---

## 2. User registration, login, profile management — DONE (minor gap)

### Auth methods — DONE
| Flow | Endpoint | Status |
|---|---|---|
| Phone OTP send | `POST /auth/phone/send-otp` | DONE |
| Phone OTP verify | `POST /auth/phone/verify-otp` | DONE |
| Email OTP send/verify | `POST /auth/email/send-otp`, `verify-otp` | DONE |
| Email + password register | `POST /auth/email/register` | DONE |
| Email + password login | `POST /auth/email/login` | DONE |
| Forgot/reset password | `POST /auth/email/password/forgot`, `/reset` | DONE |
| Verify email address | `POST /auth/email/verify/send`, `/confirm` | DONE |
| Google SSO + confirm | `POST /auth/google`, `/google/confirm` | DONE |
| Apple SSO + confirm | `POST /auth/apple`, `/apple/confirm` | DONE |
| Refresh w/ reuse detection | `POST /auth/refresh` | DONE |
| Logout | `POST /auth/logout` | DONE |

**Evidence:** `apps/api/src/modules/auth/auth.controller.ts` (265 LoC), `auth.service.ts` (793 LoC). Throttling via `@Throttle`. Apple S2S webhook + JWKS (`auth/apple/`). Password handling has a spec (`auth.password.spec.ts`).

### Profile management — DONE
- `GET /users/me`, `PATCH /users/me`, `POST /users/me/tutorial-complete`, `GET /users/username-available`, `GET /users/:id`, `PATCH /users/:id`, `PATCH /users/:id/preferences`.
- **Evidence:** `apps/api/src/modules/users/users.controller.ts`, `users.service.ts` (327 LoC), `users.service.spec.ts`.

### Account deletion — PARTIAL
- **Gap:** No `DELETE /users/me` or `POST /auth/account/delete` endpoint. Grepped `deleteAccount|deletion|delete-account` across `apps/api/src` — zero matches.
- Apple S2S account-delete webhook IS wired (`SessionsService.revokeAllForUser(..., 'apple_account_delete')` — see `sessions.service.ts:72-73`), but user-initiated deletion is not exposed.
- **Regulatory context:** GDPR Art. 17 "right to erasure" and Apple App Store Review Guideline 5.1.1(v) (since June 2022) require an in-app account-deletion path for any app that supports account creation.
- **Effort:** S — add controller route, cascade/soft-delete service method, `PATCH users` trigger on cascade. ~0.5 day.

### Email OTP transport — PARTIAL
- `verification.service.ts:137` TODO: `// TODO(D3): replace with SES transport once the infra is wired.`
- Dev path logs to stdout and returns the code in `devCode` when `NODE_ENV != production`. Production email delivery is not wired.
- **Effort:** S — provision SES, add transport class, swap dev fallback. ~0.5 day.

---

## 3. JWT authentication with refresh token rotation — DONE

- Access JWT issued via Nest `JwtService`; refresh token is a `randomUUID()`, bcrypt-hashed at rest in `sessions` table (`sessions.service.ts:25`).
- 7-day refresh token expiry.
- **Rotation on refresh:** old session revoked, new pair issued (`auth.service.ts:416-418`).
- **Reuse detection:** replayed refresh token revokes the entire session family + appends a `REFRESH_REUSE_DETECTED` trust signal (`auth.service.ts:401-413`).
- **Realtime revocation:** `SessionsService.revokeAllForUser()` also kicks live Socket.io connections via `RealtimeRevocationService` (`sessions.service.ts:96`).
- **Role guards:** `RolesGuard` with hierarchy USER < MODERATOR < ADMIN < SUPER_ADMIN (`common/guards/roles.guard.ts`). `@Roles(Role.ADMIN)` applied at `AdminController` class level; `@Roles(Role.SUPER_ADMIN)` on `PATCH users/:id/role` (`admin.controller.ts:135`).
- Tests: `sessions.service.spec.ts`, `auth.password.spec.ts`.

**Effort to close:** None — shipped.

---

## 4. Media upload and processing pipeline — PARTIAL

### Upload flow — DONE
- `POST /media/presigned-url` → validates type + size, creates `Media` row (status=PROCESSING), returns S3 presigned PUT URL.
- `POST /media/:id/confirm` → verifies S3 object exists, sets `url`, flips status to READY.
- CloudFront domain read from `AWS_CLOUDFRONT_DOMAIN` env; fallback to direct S3 URL.
- Size + MIME whitelist: IMAGE 10 MB (jpeg/png/webp/gif), VIDEO 100 MB (mp4/quicktime/webm), AUDIO 20 MB.
- **Evidence:** `apps/api/src/modules/media/media.service.ts` (90 LoC), `providers/s3.provider.ts`, `media.controller.ts`.

### Processing pipeline — MISSING
- `media.service.ts:77` explicit comment: `// Set URL and mark as ready (skip BullMQ processing for now — add in future PR)`.
- No thumbnail generation, no video transcoding, no duration/dimension extraction, no image re-encoding. Grepped `ffmpeg|transcode|thumbnail.*generate` — zero processor code.
- BullMQ IS present in the repo (used by `bot-action.processor.ts`, `interest-signal.processor.ts`, `profile-completeness-nudge.processor.ts`), so the infra exists; just no media processor has been written.
- No `apps/api/src/modules/media/*.processor.ts`, no `*.queue.ts`, no `*.spec.ts`.

### CloudFront — UNCLEAR
- Code reads `AWS_CLOUDFRONT_DOMAIN`, but `.env.example:68` shows it blank. `docs/team/internal/INFRASTRUCTURE.md` does not list a CloudFront distribution for the greenfield VPC.
- Needs confirmation: is a CloudFront distribution provisioned and set in prod secrets? If not, media is served direct-from-S3 today.

### No tests
- No `media.service.spec.ts`, no `media.controller.spec.ts`.

**Effort to close:**
- M — media processor (thumbnails for video, EXIF strip for image, dimension extraction) on BullMQ. Needs `sharp` + `fluent-ffmpeg` (or AWS MediaConvert). ~2-3 days + infra for ffmpeg.
- S — CloudFront distribution + env wiring. ~0.5 day if not already done.
- S — spec coverage. ~0.5 day.

---

## 5. Push notification service — DONE (caveat)

### FCM wiring — DONE
- Firebase Admin SDK initialised lazily from `FIREBASE_PROJECT_ID` / `FIREBASE_CLIENT_EMAIL` / `FIREBASE_PRIVATE_KEY` env vars (`notifications.service.ts:22-40`).
- Graceful no-op if Firebase creds absent (logs nothing — silent disable).
- Stale-token eviction: `messaging/registration-token-not-registered` and `messaging/invalid-registration-token` errors trigger `DevicesService.deactivate()` (`notifications.service.ts:135-143`).

### Device registration — DONE
- `POST /devices` (upsert on `fcmToken`), `DELETE /devices/:fcmToken`.
- Tracks platform, appVersion, deviceModel, osVersion, lastActiveAt, isActive.
- **Evidence:** `devices.controller.ts`, `devices.service.ts` (45 LoC), `devices` table in `Migration20260413_baseline_schema.ts:43-44`.

### Notification inbox + preferences — DONE
- DB-first: every push also writes to `notifications` table (inbox source of truth). `notifications.service.ts:50-57`.
- `GET /notifications` (cursor-paginated), `GET /notifications/unread-count`, `PATCH /notifications/:id/read`, `PATCH /notifications/read-all`, `GET/PATCH /notifications/preferences`.
- `NotificationPreference` per moduleKey × eventType (push/inApp toggles). `notifications.service.ts:147-180`.
- **Evidence:** `notifications.controller.ts`, `notifications.service.ts` (199 LoC).

### Topic subscriptions — MISSING (scope question)
- Contract says "push notification service integration" — it does not explicitly demand FCM topic subscriptions. Current code uses direct token sends (`messaging.send({ token, ... })`), not `messaging.subscribeToTopic()`.
- `moduleKey` + `eventType` preferences give equivalent per-user per-module gating without needing FCM topics, which is the more scalable approach (topics don't respect per-user preferences).
- **UNCLEAR:** Confirm with Neil whether "topic subscriptions" is in scope. Recommended answer: no — preferences are the right abstraction.

### No tests
- No `notifications.service.spec.ts`, no `devices.service.spec.ts`.

### Deliverability verification — UNCLEAR
- Acceptance criterion says "Push notifications deliverable to test devices." No evidence in the repo that an end-to-end send has been verified on a real iOS/Android TestFlight build. `FIREBASE_*` secrets' presence in Secrets Manager is not confirmed in `INFRASTRUCTURE.md`.
- **Needs Neil's input:** has a push notification been received on a TestFlight device? If yes, we're DONE; if no, we need to verify before invoicing.

**Effort to close:**
- S — spec coverage. ~0.5 day.
- S — E2E push verification on TestFlight. ~1 hour if Firebase creds are live.

---

## 6. Admin panel foundation — DONE (and then some)

### Backend admin surface — DONE
`AdminController` (`admin.controller.ts`, 381 LoC) exposes:

| Area | Endpoints | Status |
|---|---|---|
| User mgmt | list, detail, content, reports, suspend, warn, force-logout, search, status, role | DONE |
| Content moderation | list, flagged, status, restore | DONE |
| Comment moderation | list, delete | DONE |
| Reports enforcement | `POST /admin/reports/:id/enforce` | DONE |
| Audit log | `GET /admin/audit-log` | DONE |
| Analytics | growth, engagement, content breakdown, active users | DONE |
| Sessions | stats | DONE |
| System health | `GET /admin/system/health` | DONE |
| Marketplace | products list + status, auctions list + cancel | DONE |
| Sponsored | campaigns list + status | DONE |
| Broadcast | `POST /admin/notifications/broadcast` | DONE |

`AdminAuditService` writes audit rows for every admin action (`admin-audit-log` table). `AdminAnalyticsService` has its own file.

**Evidence:** `admin.controller.ts`, `admin.service.ts` (694 LoC — real queries, not stubs; uses `@InjectQueue('bot-actions')`, `EntityManager`, real FK joins). `admin-audit.service.ts`, `admin-analytics.service.ts`. Grepped `TODO|FIXME|stub` across `apps/api/src/modules/admin/` — zero matches.

### Frontend admin panel — DONE
19 pages in `apps/admin/src/pages/` (Dashboard, Users, UserDetail, Content, Comments via Reports, Bots, BotDetail, Marketplace, Sponsored, Interests, Analytics, Sessions, AuditLog, Broadcast, SystemHealth, Login, ForgotPassword, ResetPassword, Landing).

`apps/admin/src/api/client.ts` (541 LoC) wires 50+ real endpoints. Login flow uses `emailLogin` (PRs #164-#167 shipped 2026-04-18). `enforceAdminRole()` blocks USER/MODERATOR at the client (defence in depth; primary enforcement is `RolesGuard`).

Deployed at `https://admin.kuwboo.com` (Vercel project `team_kuwboo_admin`, prj_VsJKIEkqT1F2WojX4bzGprfY1lQb).

### Admin seed — DONE
`apps/api/src/scripts/seed-admin.ts` — `phil_admin` + `neil_admin` SUPER_ADMIN accounts seeded (per MEMORY.md 2026-04-18).

**Effort to close:** None — shipped. Admin panel significantly exceeds "foundation" — this looks more like M3-level moderation tooling delivered early.

---

## 7. Items not named in contract but relevant to M2

- **Apple S2S Sign-in-with-Apple server-to-server notifications** (consent revoked, account delete) — DONE (`auth/apple/`, `apple_notification_events` migration).
- **Trust engine signals on auth events** — DONE (`REFRESH_REUSE_DETECTED` etc.).
- **Realtime session kill via Socket.io** — DONE (`RealtimeRevocationService`).
- **Password strength spec** — DONE (`auth.password.spec.ts`).

These are bonus — they materially harden the auth story beyond what the contract requires.

---

## Summary scoreboard

| Contract line item | Status |
|---|---|
| Backend API framework + DB | DONE |
| User registration + login | DONE |
| Profile management | DONE |
| **Account deletion (implied by registration + regulatory)** | **PARTIAL** — user-initiated deletion endpoint missing |
| JWT with refresh rotation | DONE |
| Role guards | DONE (USER/MODERATOR/ADMIN/SUPER_ADMIN) |
| Media upload | DONE |
| **Media processing pipeline** | **PARTIAL** — BullMQ processor not written; upload-only today |
| **CloudFront delivery** | **UNCLEAR** — env hook exists, distribution provisioning not documented |
| Push notifications — FCM | DONE |
| Device registration | DONE |
| Notification inbox + preferences | DONE |
| **Push deliverability verified on TestFlight** | **UNCLEAR** — needs Neil to confirm |
| Admin panel — backend | DONE (over-delivered) |
| Admin panel — frontend | DONE |
| **Email OTP production transport (SES)** | **PARTIAL** — dev stdout fallback; SES not wired |

### Top 3 gaps blocking M2 invoice (if strict)

1. **Media processing pipeline is not implemented.** The contract line reads "Media upload **and processing** pipeline (photos, videos)". Upload works; no thumbnailing, transcoding, or dimension extraction exists. This is the single biggest delta between what's shipped and what's named in the contract.
2. **Account deletion endpoint missing.** Not called out verbatim in M2 scope, but "user registration" without a deletion path fails App Store Guideline 5.1.1(v) and GDPR Art. 17. Safer to ship now than ship later under audit pressure.
3. **Production email transport (SES) is a dev stdout stub.** Email OTP send + forgot-password are both wired to the same `verification.service.ts:137` stub. Flipping `NODE_ENV=production` without wiring SES means those flows silently fail for real users.

### Unclear items needing Neil + Phil to confirm

- Is CloudFront provisioned for media delivery, or are we serving direct S3 URLs today?
- Has a push notification been confirmed delivered to a TestFlight device? (If no, FCM creds in Secrets Manager need verifying.)
- Are "FCM topic subscriptions" in contract scope, or does the current `NotificationPreference` per-module gating satisfy "notification preferences configurable per module"? (Note: that wording is in M5 acceptance, not M2 — so strictly out of scope here.)

### Ready to invoice for M2? — CONDITIONAL

All six named deliverables are at least partially shipped; acceptance criteria 1 (register/login/profile) and 3 (admin foundation) are fully met. Criterion 2 ("Media upload and retrieval functional") and the push deliverability criterion are the open questions.

**Recommended close-out before invoicing (estimated 3-4 days):**
- S — Add `DELETE /users/me` with audit + session revocation.
- S — Wire SES production transport for verification emails.
- M — Ship a minimal media processor (image thumbnail + dimension extract via `sharp`; video thumbnail via ffmpeg Lambda or server-side). Can defer full video transcoding if Neil agrees to soft-launch with raw-mp4 playback.
- S — Verify FCM push delivery on a TestFlight build; document in runbook.

If Neil is comfortable invoicing M2 with the processing pipeline and account-deletion items carried into M3 as known debt, the invoice can go today — but that should be explicit in the milestone sign-off note.
