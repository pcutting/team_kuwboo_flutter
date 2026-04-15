# Kuwboo API Surface — Canonical Reference

**Audited:** 2026-04-15 (Phase 1 of mobile rebuild)
**Source:** `apps/api/src/modules/` — 26 NestJS modules
**Purpose:** Single source of truth for `packages/api_client` and `packages/models` alignment. If this doc and the backend disagree, the backend wins — update this doc.

## Global configuration

- **Base URL:** no global `/api` prefix. Routes mount at root (`/auth/...`, `/users/...`, `/feed`).
- **Swagger:** `/api/docs`
- **Global guards (APP_GUARD):** `JwtAuthGuard`, `RolesGuard`, `ThrottlerGuard` — JWT is required by default; use `@Public()` to opt out.
- **Validation:** global `ValidationPipe` with `whitelist + forbidNonWhitelisted + transform`.
- **CORS:** enabled; **Helmet:** enabled.
- **WebSocket namespaces:** `/proximity` (yoyo), `/chat` (messaging), `/presence` — all require JWT in handshake via `WsJwtGuard`.
- **Realtime revocation:** `RealtimeRevocationService` can emit `client:state = "killed"` across all gateways and force-disconnect sockets.

---

## Module index

| Module | HTTP routes | WS events | Models in packages/models |
|---|---|---|---|
| [auth](#auth) | 11 | — | `auth.dart` ✅ |
| [users](#users) | 7 | — | `user.dart` ✅ |
| [consent](#consent) | 3 | — | **MISSING** |
| [verification](#verification) | 0 (internal) | — | — |
| [sessions](#sessions) | 0 (internal) | — | — |
| [feed](#feed) | 4 | — | `feed.dart` ✅ |
| [content](#content) | 9 | — | `content.dart` ✅ |
| [comments](#comments) | 4 | — | `comment.dart` ✅ |
| [interactions](#interactions) | 5 | — | — (inline payloads) |
| [marketplace](#marketplace) | 9 | — | `product.dart`, `auction.dart` ✅; **Bid / SellerRating MISSING** |
| [credentials](#credentials) | 5 | — | `credential.dart` ✅ |
| [sponsored](#sponsored) | 3 | — | **SponsoredCampaign MISSING** |
| [yoyo](#yoyo) | 8 | 6 | `yoyo.dart` ✅ |
| [connections](#connections) | 10 | — | `connection.dart` ✅ |
| [messaging](#messaging) | 5 | 12 | `thread.dart` ✅ |
| [presence](#presence) | 0 | 4 | — |
| [realtime](#realtime) | 0 | 0 (coord only) | — |
| [interests](#interests) | 8 | — | `interest.dart` ✅ |
| [notifications](#notifications) | 6 | WS gateway | `notification_model.dart` ✅; **NotificationPreference MISSING** |
| [devices](#devices) | 2 | — | **MISSING** |
| [reports](#reports) | 3 | — | **MISSING** |
| [trust](#trust) | 0 (internal) | — | `trust_signal.dart` ✅ |
| [media](#media) | 2 | — | **MISSING** |
| [bots](#bots) | 15 (admin) | — | **MISSING** |
| [admin](#admin) | 41 | — | many (admin DTOs; not client-facing) |
| [health](#health) | 1 | — | — |

**Totals:** ~130 HTTP routes, 3 WebSocket namespaces with 22 events, 9 missing client models.

---

## auth

All routes `@Public()`. Throttled per-route.

| Method | Path | Guards | Req DTO | Resp | Notes |
|---|---|---|---|---|---|
| POST | `/auth/phone/send-otp` | `@Throttle(5/15m)` | `SendOtpDto` | `{ sent: boolean }` | SMS trigger |
| POST | `/auth/phone/verify-otp` | `@Throttle(10/15m)` | `VerifyOtpDto` | `AuthResponse` | Returns tokens + user + `isNewUser` |
| POST | `/auth/email/send-otp` | `@Throttle(5/15m)` | `SendEmailOtpDto` | `{ sent: boolean }` | Email OTP path |
| POST | `/auth/email/verify-otp` | `@Throttle(10/15m)` | `VerifyEmailOtpDto` | `AuthResponse` | Normalizes email |
| POST | `/auth/google` | `@Throttle(30/15m)` | `GoogleLoginDto` | `AuthResponse \| PendingSsoChallenge` | **Already implemented.** May 409 with `email_owned` challenge |
| POST | `/auth/google/confirm` | `@Throttle(10/15m)` | `GoogleConfirmDto` | `AuthResponse` | Confirms after email-ownership challenge |
| POST | `/auth/apple` | `@Throttle(30/15m)` | `AppleLoginDto` | `AuthResponse \| PendingSsoChallenge` | **Already implemented.** May 409 with `email_owned` challenge |
| POST | `/auth/apple/confirm` | `@Throttle(10/15m)` | `AppleConfirmDto` | `AuthResponse` | |
| POST | `/auth/refresh` | `@Throttle(60/15m)` | `RefreshTokenDto` | `TokenPair` | Extracts userId from expired access token in Authorization header |
| POST | `/auth/dev-login` | gated by `DEV_LOGIN_ENABLED=1` | `SendOtpDto` | `AuthResponse` | Dev-only OTP bypass |
| POST | `/auth/logout` | JWT required | — | `{ ok: boolean }` | |

**Plan impact:** Phase 3 (SSO setup) only needs client-side work (plugins + Firebase/Apple config). No backend work for token verification — it exists.

## users

All routes require Bearer token.

| Method | Path | Req | Resp | Notes |
|---|---|---|---|---|
| GET | `/users/me` | — | `User` | |
| PATCH | `/users/me` | `PatchMeDto` | `User` | Updates `displayName`, `username`, `avatarUrl`, `bio`, `dateOfBirth`, `onboardingProgress` |
| POST | `/users/me/tutorial-complete` | `TutorialCompleteDto` | `User?` | Tracks tutorial version |
| GET | `/users/username-available?handle=x` | — | `{ available: boolean }` | |
| GET | `/users/:id` | `ParseUUIDPipe` | `User` | Any user by UUID |
| PATCH | `/users/:id` | `UpdateUserDto` | `User` | Authorization in service |
| PATCH | `/users/:id/preferences` | `UpdatePreferencesDto` | `User?` | |

## consent

All routes require Bearer token. **Model MISSING — create `consent.dart`.**

| Method | Path | Req | Resp | Notes |
|---|---|---|---|---|
| GET | `/consent` | — | `Consent[]` | |
| POST | `/consent` | `GrantConsentDto` | `Consent` | Captures IP; includes `type` + `version` + `source` |
| DELETE | `/consent/:consentType` | path enum | `{ message }` | |

## verification

No HTTP. Internal service for OTP generation, validation, rate-limiting. Consumed by `auth` only.

## sessions

No HTTP. Internal JWT session lifecycle service. Consumed by `auth`.

---

## feed

All routes under `/feed`. JWT required unless noted.

| Method | Path | Guards | Query | Resp | Notes |
|---|---|---|---|---|---|
| GET | `/feed` | JWT | `tab=home`, `cursor?`, `limit?=20` | `FeedResponse` | Cursor pagination |
| GET | `/feed/following` | JWT | `tab`, `cursor?`, `limit?`, `moduleScope?` | `FeedResponse` | |
| GET | `/feed/trending` | `@Public()` | `tab`, `limit?` | `FeedResponse` | Public readable |
| GET | `/feed/discover` | JWT | `tab`, `limit?` | `FeedResponse` | Personalized |

## content

JWT required unless noted. STI discriminator `moduleKey` ∈ {`video_making`, `buy_sell`, `dating`, `social_stumble`, `blog`, `notice_board`, `vip_page`, `find_discount`, `lost_and_found`, `missing_person`}.

| Method | Path | Guards | Req | Resp | Notes |
|---|---|---|---|---|---|
| POST | `/content/videos` | JWT | `CreateVideoDto` | `Content` | `moduleKey=video_making`; videoUrl, thumbnailUrl, durationSeconds, caption, musicId, visibility, location, tags |
| POST | `/content/posts` | JWT | `CreatePostDto` | `Content` | `moduleKey=social_stumble` or per subType |
| GET | `/content/:id` | `@Public()` | — | `Content` | |
| PATCH | `/content/:id/hide` | JWT | — | `Content` | Creator-only; sets status HIDDEN |
| PATCH | `/content/:id/unhide` | JWT | — | `Content` | |
| DELETE | `/content/:id` | JWT | — | `{ message }` | Soft delete |
| GET | `/content/:id/interest-tags` | `@Public()` | — | `{ interest_tags: [...] }` | |
| POST | `/content/:id/interest-tags` | JWT | `SetInterestTagsDto` | `{ interest_ids: string[] }` | Creator-only; max 20 |
| POST | `/admin/content/:id/interest-tags` | `@Roles(ADMIN)` | `SetInterestTagsDto` | `{ interest_ids: string[] }` | |

## comments

| Method | Path | Guards | Req | Resp | Notes |
|---|---|---|---|---|---|
| POST | `/content/:contentId/comments` | JWT | `CreateCommentDto { text<=2000, parentCommentId? }` | `Comment` | |
| GET | `/content/:contentId/comments` | `@Public()` | `cursor?`, `limit?=20` | `{ comments, nextCursor, hasMore }` | |
| POST | `/comments/:id/like` | JWT | — | `{ liked }` | Toggle |
| DELETE | `/comments/:id` | JWT | — | `{ message }` | Author-only |

## interactions

All `/content/:id/*`; JWT required.

| Method | Path | Resp | Notes |
|---|---|---|---|
| POST | `/content/:id/like` | `{ liked, likeCount }` | Toggle |
| POST | `/content/:id/save` | `{ saved, saveCount }` | Toggle |
| POST | `/content/:id/view` | `{ message }` | Log (async) |
| POST | `/content/:id/share` | `{ message }` | Log (async) |
| GET | `/content/:id/interactions` | `{ liked, saved, viewCount? }` | Current user's state |

---

## marketplace

No controller prefix. JWT required unless noted. Prices in cents; currency defaults GBP.

| Method | Path | Req | Resp | Notes |
|---|---|---|---|---|
| POST | `/products` | `CreateProductDto` | `Product` | condition enum LIKE_NEW/GOOD/FAIR/POOR; `isDeal`; `originalPriceCents` |
| GET | `/products` | Query: `category?`, `minPrice?`, `maxPrice?`, `condition?`, `cursor?`, `limit?=20` | `{ items: Product[], nextCursor? }` | |
| GET | `/products/deals` | `cursor?`, `limit?=20` | `{ items, nextCursor? }` | `isDeal=true` filter |
| GET | `/products/:id` | — | `Product` | |
| POST | `/auctions` | `CreateAuctionDto` | `Auction` | State machine SCHEDULED→ACTIVE→CLOSED; `antiSnipeMinutes` |
| GET | `/auctions/:id` | — | `Auction & { bids: Bid[] }` | |
| POST | `/auctions/:id/bid` | `PlaceBidDto { amountCents }` | `Bid` | **`Bid` model MISSING** |
| POST | `/users/:userId/ratings` | `CreateSellerRatingDto` | `SellerRating` | **Model MISSING** — 1-5 stars + review; unique on (buyer, product) |
| GET | `/users/:userId/ratings` | `cursor?`, `limit?=20` | `{ items, nextCursor? }` | |

## credentials

Covers federated auth tokens (`google`, `apple` with `providerData`) AND phone/email records (`providerData=null`).

### user-scoped

| Method | Path | Req | Resp | Notes |
|---|---|---|---|---|
| GET | `/credentials` | — | `{ credentials: Credential[] }` | `isPrimary` flag |
| POST | `/credentials` | `AttachCredentialDto` | `{ credential }` | Phone/email need prior OTP verify; SSO via `/auth/google` etc. |
| DELETE | `/credentials/:id` | — | 204 | Cannot revoke last active (IDENTITY_CONTRACT §11.2) |

### admin-scoped

| Method | Path | Guards | Resp | Notes |
|---|---|---|---|---|
| GET | `/admin/users/:userId/credentials` | `@Roles(ADMIN, SUPER_ADMIN)` | `{ credentials }` | |
| DELETE | `/admin/users/:userId/credentials/:credentialId` | `@Roles(ADMIN, SUPER_ADMIN)` | 204 | Appends `trust_signal { signal_type='credential_revoked_by_admin' }` |

## sponsored

`/sponsored/campaigns`. **`SponsoredCampaign` model MISSING.** Ad-serving surface is **separate** (not in this doc).

| Method | Path | Req | Resp | Notes |
|---|---|---|---|---|
| POST | `/sponsored/campaigns` | `CreateCampaignDto { contentId, budgetCents>=100, targeting, startsAt, endsAt }` | `SponsoredCampaign` | status=DRAFT |
| GET | `/sponsored/campaigns` | `cursor?`, `limit?=20` | `{ items, nextCursor? }` | Own campaigns |
| PATCH | `/sponsored/campaigns/:id` | `UpdateCampaignStatusDto { status: CampaignStatus }` | `SponsoredCampaign` | Ownership enforced |

---

## yoyo

### HTTP

| Method | Path | Req | Resp | Notes |
|---|---|---|---|---|
| POST | `/yoyo/location` | `UpdateLocationDto { lat, lng }` | `{ message }` | lat ∈ [-90,90], lng ∈ [-180,180] |
| GET | `/yoyo/nearby` | Query: `lat`, `lng`, `radius?` | `NearbyUser[]` | Geospatial |
| GET | `/yoyo/settings` | — | Settings | isVisible, radiusKm 1-500, ageMin/Max 13-120, genderFilter |
| PATCH | `/yoyo/settings` | `UpdateYoyoSettingsDto` | Settings | |
| POST | `/yoyo/overrides` | `CreateOverrideDto { targetUserId, action }` | `Override` | Block/allow visibility |
| POST | `/yoyo/wave` | `SendWaveDto { toUserId, message?<=255 }` | `Wave` | |
| GET | `/yoyo/waves` | — | `Wave[]` | Incoming |
| POST | `/yoyo/waves/:id/respond` | `RespondWaveDto { accept }` | Response | |

### WebSocket (`/proximity`)

| Event | Direction | Payload |
|---|---|---|
| `location:update` | c→s | `{ latitude, longitude }` |
| `location:ack` | s→c | `{ received: boolean }` |
| `location:error` | s→c | `{ received: false }` |
| `nearby:entered` | s→c | `{ id, name, distanceKm }` |
| `nearby:left` | s→c | `{ userId }` |
| `wave:received` | s→c | `{ id, fromUserId, fromUserName, message? }` |

## connections

| Method | Path | Req | Resp | Notes |
|---|---|---|---|---|
| POST | `/connections/follow` | `FollowDto { userId, moduleScope? }` | `Follow` | Per-module follow |
| DELETE | `/connections/follow/:userId` | Query: `moduleScope?` | `{ message }` | |
| POST | `/connections/friend-request` | `FollowDto` | `FriendRequest` | |
| POST | `/connections/friend-request/:id/accept` | — | Accepted | |
| POST | `/connections/friend-request/:id/reject` | — | `{ message }` | |
| GET | `/connections/followers` | `limit?=20`, `offset?=0` | Paginated | Offset pagination (not cursor) |
| GET | `/connections/following` | `limit?`, `offset?` | Paginated | |
| POST | `/connections/block` | `BlockDto` | `Block` | |
| DELETE | `/connections/block/:userId` | — | `{ message }` | |
| GET | `/connections/blocks` | — | `Block[]` | |

## messaging

### HTTP

| Method | Path | Req | Resp | Notes |
|---|---|---|---|---|
| POST | `/threads` | `CreateThreadDto { recipientId, moduleKey?, contextId? }` | `Thread` | `moduleKey` for marketplace/content threads |
| GET | `/threads` | `cursor?`, `limit?=20` | Paginated | |
| GET | `/threads/:id/messages` | `cursor?`, `limit?=50` | Paginated | |
| POST | `/threads/:id/messages` | `SendMessageDto { text<=5000, mediaId? }` | `Message` | |
| PATCH | `/threads/:id/read` | — | `{ message }` | |

### WebSocket (`/chat`)

| Event | Direction | Payload |
|---|---|---|
| `message:send` | c→s | `{ threadId, text }` |
| `message:new` | s→c | `{ threadId, senderId, text, createdAt }` |
| `thread:join` | c→s | `{ threadId }` |
| `thread:joined` | s→c | `{ threadId, joined: true }` |
| `thread:error` | s→c | `{ threadId, joined: false }` |
| `thread:leave` | c→s | `{ threadId }` |
| `thread:left` | s→c | `{ threadId, left: true }` |
| `typing:start` | c→s | `{ threadId }` |
| `typing:update` | s→c | `{ threadId, userId, isTyping }` |
| `typing:stop` | c→s | `{ threadId }` |
| `client:state` | s→c | `{ state: 'killed', reason? }` |

## presence

No HTTP. WebSocket `/presence` only.

| Event | Direction | Payload |
|---|---|---|
| `presence:query` | c→s | `{ userIds: string[] }` |
| `presence:status` | s→c | `[{ userId, status: 'ONLINE' \| 'OFFLINE' }]` |
| `presence:update` | s→c | `{ userId, status }` |
| `client:state` | s→c | `{ state: 'killed', reason? }` |

Scale note: in-memory presence map today. Redis adapter when scaling.

## realtime

No controllers, no gateway. `RealtimeRevocationService.killUser()` coordinates session termination across messaging/presence/notifications gateways, emitting `client:state = "killed"` then force-disconnecting.

---

## interests

### user-scoped

| Method | Path | Guards | Req | Resp | Notes |
|---|---|---|---|---|---|
| GET | `/interests` | `@Public()` | — | `{ interests }` | For onboarding picker |
| GET | `/users/me/interests` | JWT | — | `{ interests: UserInterest[] }` | |
| POST | `/users/me/interests` | JWT | `SelectInterestsDto` | `{ interests }` | Upsert up to 100 UUIDs |
| DELETE | `/users/me/interests/:id` | JWT | — | 204 | |

### admin

| Method | Path | Guards | Req | Resp |
|---|---|---|---|---|
| GET | `/admin/interests` | `@Roles(ADMIN)` | — | `{ interests }` |
| POST | `/admin/interests` | `@Roles(ADMIN)` | `CreateInterestDto` | `Interest` |
| PATCH | `/admin/interests/:id` | `@Roles(ADMIN)` | `UpdateInterestDto` | `Interest` |
| DELETE | `/admin/interests/:id` | `@Roles(ADMIN)` | — | 204 |
| POST | `/admin/interests/reorder` | `@Roles(ADMIN)` | `ReorderInterestsDto` | `{ interests }` |

## notifications

| Method | Path | Req | Resp | Notes |
|---|---|---|---|---|
| GET | `/notifications` | `cursor?`, `limit?=20` | `{ notifications, cursor? }` | Paginated feed |
| GET | `/notifications/unread-count` | — | `{ count }` | Badge |
| PATCH | `/notifications/:id/read` | — | `{ message }` | |
| PATCH | `/notifications/read-all` | — | `{ message }` | |
| GET | `/notifications/preferences` | — | `NotificationPreference` | **Model MISSING** |
| PATCH | `/notifications/preferences` | `UpdatePreferencesDto` | `NotificationPreference` | Per moduleKey + eventType toggles |

Also has a WebSocket gateway for real-time push (uses `WsAuthGuard`).

## devices

Push token registration. **`Device` model MISSING.**

| Method | Path | Req | Resp | Notes |
|---|---|---|---|---|
| POST | `/devices` | `RegisterDeviceDto` | `Device` | FCM token + platform (iOS/Android/Web) + appVersion/deviceModel/osVersion |
| DELETE | `/devices/:fcmToken` | — | `{ message }` | On logout/uninstall |

## reports

**`Report` model MISSING.**

| Method | Path | Guards | Req | Resp |
|---|---|---|---|---|
| POST | `/reports` | JWT | `CreateReportDto { targetType: USER\|CONTENT\|COMMENT, targetId, reason: HARASSMENT\|SPAM\|EXPLICIT\|…, description<=1000 }` | `Report` |
| GET | `/reports` | `@Roles(MODERATOR)` | `page?`, `limit?=20` | `{ reports }` |
| PATCH | `/reports/:id/review` | `@Roles(MODERATOR)` | `ReviewReportDto { status: DISMISSED\|RESOLVED, notes<=1000 }` | `Report` |

## trust

No HTTP. Internal service.

```ts
TrustService.append({ userId, type, delta, source?, metadata?, expiresAt? }) -> TrustSignal
```

Append-only log; `score = SUM(delta)` over active (unexpired) signals, clamped [0,100] by external decay worker. Model `trust_signal.dart` ✅.

---

## media

S3 presigned upload flow. **`Media` model MISSING.**

| Method | Path | Req | Resp | Notes |
|---|---|---|---|---|
| POST | `/media/presigned-url` | `PresignedUrlRequestDto { fileName, contentType, type: IMAGE\|VIDEO\|AUDIO, sizeBytes }` | `{ uploadUrl, mediaId, s3Key }` | Max 100MB; whitelist image/* 10MB, video/* 100MB, audio/* 20MB |
| POST | `/media/:id/confirm` | — | `Media` | Validates S3 object; sets `MediaStatus.READY`; returns CDN URL |

Flow: client → presigned-url → `PUT s3://…` → `POST /media/:id/confirm`.

## bots (admin-only)

`@Controller('admin/bots')` + `@Roles(ADMIN)` at controller level. **`Bot` model MISSING.** 15 routes covering CRUD, simulation control (start/pause/stop), bulk ops (1-100), activity logs, stats, reset, trigger. Not needed by mobile client.

## admin

41 routes under `/admin/*` for moderation: users, content, comments, marketplace, auctions, sponsored campaigns, notifications broadcast, audit log, analytics, system health, sessions. Not needed by mobile client.

## health

| Method | Path | Guards | Resp |
|---|---|---|---|
| GET | `/health` | `@Public()` | `{ status, uptime, timestamp }` |

---

## Gaps — models to add in Phase 2

**HIGH priority (used by user-facing routes):**

| Model | Fields (from backend shape) | Used by |
|---|---|---|
| `consent.dart` | `type`, `version`, `source`, `grantedAt`, `revokedAt?`, `ip?` | consent module |
| `bid.dart` | `auctionId`, `bidderId`, `amountCents`, `placedAt` | marketplace auction |
| `seller_rating.dart` | `buyerId`, `sellerId`, `productId`, `stars`, `review?`, `createdAt` | marketplace ratings |
| `sponsored_campaign.dart` | `id`, `advertiserId`, `contentId`, `budgetCents`, `spentCents`, `targeting`, `startsAt`, `endsAt`, `status` | sponsored CRUD |
| `report.dart` | `targetType`, `targetId`, `reason`, `description?`, `status`, `reporterId`, `reviewedBy?`, `reviewedAt?`, `notes?` | reports |
| `device.dart` | `fcmToken`, `platform`, `appVersion`, `deviceModel`, `osVersion`, `isActive`, `lastSeenAt` | devices |
| `notification_preference.dart` | `userId`, `moduleKey`, `eventType`, `pushEnabled`, `inAppEnabled` | notifications |
| `media.dart` | `id`, `ownerId`, `type`, `s3Key`, `cdnUrl`, `contentType`, `sizeBytes`, `status`, `createdAt` | media upload |

**LOW priority (admin-only, not needed for mobile rebuild):** `bot.dart`, admin DTOs.

---

## Plan corrections based on audit

These adjust the approved `dynamic-wondering-nova.md` plan:

1. **Phase 3 simplified — SSO backend is done.** `POST /auth/apple` and `POST /auth/google` are already implemented with email-ownership challenge flow. Phase 3 becomes client-only: install `sign_in_with_apple` + `google_sign_in`, configure Firebase Google provider, add AppleSignIn entitlement, update `GoogleService-Info.plist` via `flutterfire configure`. No new backend endpoints needed.

2. **Email OTP is a first-class alternative** — `/auth/email/send-otp` + `/auth/email/verify-otp` exist. The method picker in `kuwboo_auth` should offer "Phone or Email" as a single button that then branches (matches the existing prototype UX).

3. **Phase 2 scope up** — 8 missing models, not the 4-ish implied in the original plan. `NotificationPreference`, `Device`, `Report`, `Media`, `Consent`, `Bid`, `SellerRating`, `SponsoredCampaign` all need to be created from scratch.

4. **WebSocket surface is bigger than expected** — 3 namespaces with 22 events. Phase 8 socket.io agent needs to know about `/proximity` + `/chat` + `/presence` and the `client:state=killed` revocation event.

5. **`/auth/apple\|google` return `PendingSsoChallenge` on email-owned 409** — the `kuwboo_auth` callback signature needs to handle this branching. `AuthCallbacks.onSignInWithApple` should return a sum type (success | challenge), not just success.

6. **No global `/api` prefix** — the plan's earlier mention of "including any global `/api` prefix" was wrong; routes mount at root.

7. **`connections` uses offset pagination, not cursor** — everywhere else is cursor-based. Client must handle both patterns.

8. **`NotificationPreference` is per-module + per-event** — not a flat boolean pair. Client `profile_notifications_screen.dart` UX may need revising.

9. **No dedicated "events" module** — `events` in the prototype's social module has no backend counterpart. Either stub it out or add `EventsApi` as a new backend surface (probably a post-PR punch-list item).

10. **Products and auctions live at `/products`, `/auctions` — not `/marketplace/products`.** Paths in any earlier mobile code / docs referring to `/marketplace/*` need updating.
