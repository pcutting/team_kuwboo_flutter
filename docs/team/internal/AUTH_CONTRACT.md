# AUTH_CONTRACT

Mapping of the prototype auth flow (product source of truth) against what the NestJS backend currently serves and what the two existing Dart clients assume.

## 1. Context / purpose

Kuwboo has three inconsistent views of authentication: the prototype screens in `packages/kuwboo_auth/` (the product source of truth, per Neil's direction), the NestJS controller in `apps/api/src/modules/auth/`, and two separate Dart HTTP clients (`packages/api_client/lib/src/auth_api.dart` and `apps/mobile/lib/features/auth/data/auth_api.dart`) that disagree on paths, payloads, and response shapes. This document is the "design-first" baseline for Phase C2 (consolidate clients) and Phase C3 (align backend). It catalogs what each layer currently does, highlights mismatches, and proposes a single target contract. No code changes in this phase.

## 2. Prototype flow diagram

```
                              ┌───────────────────┐
                              │   authWelcome     │
                              └─────────┬─────────┘
                 ┌─────────────────────┴──────────────────────┐
              "Create Account"                            "Log In"
                    │                                         │
                    ▼                                         ▼
           ┌───────────────────┐                   ┌───────────────────┐
           │    authMethod     │                   │    authLogin      │
           │ phone/email|G|A   │                   │ SSO or phone/email│
           └─────────┬─────────┘                   └────────┬──────────┘
            phone/email │    │  Google / Apple              │
                    ▼    └──────────────┐                    │
           ┌───────────────────┐         │                   │
           │    authPhone      │         │                   │
           │  (phone or email) │         │                   │
           └─────────┬─────────┘         │                   │
                    │                    │                   │
            Phone tab│   Email tab       │                   │
                    ▼          │         │                   │
           ┌───────────────────┐ │        │                   │
           │     authOtp       │ │        │                   │
           │   4-digit code    │ │        │                   │
           └─────────┬─────────┘ │        │                   │
                    │             └───────┤                   │
                    ▼                     ▼                   │
           ┌───────────────────┐  ┌───────────────────┐       │
           │   authBirthday    │  │   authProfile     │       │
           │ DOB picker; <13?  │  │ display name + @  │       │
           └────┬──────────┬───┘  └─────────┬─────────┘       │
              <13           ≥13              │                │
               ▼                             ▼                │
   ┌───────────────────┐            ┌───────────────────┐     │
   │   authAgeBlock    │            │  authOnboarding   │     │
   │  (terminal, 13+)  │            │  pick 3+ interests│     │
   └─────────┬─────────┘            └─────────┬─────────┘     │
            │ OK                               │              │
            └────→ authWelcome                 ▼              │
                                    ┌───────────────────┐     │
                                    │   authTutorial    │     │
                                    │  4-page tutorial  │     │
                                    └─────────┬─────────┘     │
                                              │               │
                                              ▼               ▼
                                       switchModule(video)  (app)
```

Notes:
- `authSignup` exists as a route constant but is not on the main path above. It is a legacy consolidated-form screen (phone + OTP + name + DOB on one screen) that routes directly to `authOnboarding`. It is reachable only if a client navigates to `/auth/signup` explicitly. Keep or retire is an open question.
- From `authMethod`, Google/Apple jump straight to `authProfile` (skipping OTP and birthday). The prototype does **not** re-prompt SSO users for DOB.
- `authLogin` SSO and the phone/email submit all call `state.switchModule(video)` directly — there is no intermediate screen.

## 3. Per-step table

| # | Screen | Route | User enters | Intended backend call | Expected response | Next on success | Next on failure |
|---|---|---|---|---|---|---|---|
| 1 | `authWelcome` | `/auth/welcome` | Nothing — chooses Create Account or Log In | None (pure nav) | — | `authMethod` or `authLogin` | n/a |
| 2 | `authOnboarding` | `/auth/onboarding` | Select ≥3 interests (tap chips) | None in prototype. **Open:** should send `PATCH /users/me { interests }` | — | `authTutorial` | n/a |
| 3 | `authTutorial` | `/auth/tutorial` | Nothing — 4-page swipe/skip | None (pure nav) | — | `switchModule(video)` (enters app) | n/a |
| 4 | `authMethod` | `/auth/method` | Tap one of: phone/email, Google, Apple | None (pure UI choice) | — | `authPhone` (phone/email) or `authProfile` (Google/Apple) | n/a |
| 5 | `authSignup` (legacy) | `/auth/signup` | Phone, OTP, name, DOB — all on one screen | Ambiguous — prototype is all mocked fields with a single Continue | — | `authOnboarding` | n/a |
| 6 | `authPhone` | `/auth/phone` | Phone (country + number) **or** email + password | **Phone tab:** `POST /auth/phone/send-otp`. **Email tab:** no call in prototype — navigates straight to `authBirthday` | Phone: `{ message: 'OTP sent' }`. Email: — | Phone tab → `authOtp`; Email tab → `authBirthday` | Error toast (not specified) |
| 7 | `authOtp` | `/auth/otp` | 4 digits (prototype shows 4 boxes; backend requires 6) | `POST /auth/phone/verify-otp` | `{ accessToken, refreshToken, user, isNewUser }` | `authBirthday` (unconditionally in prototype) | Shake / error (not specified) |
| 8 | `authBirthday` | `/auth/birthday` | DOB via wheel pickers | None in prototype. **Open:** should send `PATCH /users/me { dateOfBirth }` | — | `authAgeBlock` if <13, else `authProfile` | n/a |
| 9 | `authProfile` | `/auth/profile` | Avatar (placeholder), display name, username | None in prototype. **Open:** should send `PATCH /users/me { name, username, avatarUrl }` | — | `authOnboarding` | n/a |
| 10 | `authLogin` | `/auth/login` | Google/Apple SSO **or** phone **or** email+password | Prototype does not call backend — all buttons navigate straight to `switchModule(video)` | — | Enters app (video feed) | n/a |
| 11 | `authAgeBlock` | `/auth/age-block` | Nothing — informational terminal | None (pure UI) | — | `authWelcome` (OK button) | n/a |

## 4. Backend reality (`apps/api/src/modules/auth/`)

All routes are mounted under `/auth` and decorated `@Public()` except `logout`. Response envelope is the global transform interceptor (fields are as listed below, wrapped at the transport layer).

| Method | Path | Request body | Response body | Returns tokens? | `isNewUser`? | Guard |
|---|---|---|---|---|---|---|
| POST | `/auth/phone/send-otp` | `{ phone: string }` (E.164, validated) | `{ message: 'OTP sent' }` | No | No | Public |
| POST | `/auth/phone/verify-otp` | `{ phone: string, code: string }` (code is `length 6`) | `{ accessToken, refreshToken, user: User, isNewUser: boolean }` | Yes | Yes | Public |
| POST | `/auth/social/google` | `{ idToken: string }` | `{ accessToken, refreshToken, user, isNewUser }` | Yes | Yes | Public |
| POST | `/auth/social/apple` | `{ identityToken: string, authorizationCode: string, fullName?: string }` | `{ accessToken, refreshToken, user, isNewUser }` | Yes | Yes | Public |
| POST | `/auth/refresh` | `{ refreshToken: string }` + `Authorization: Bearer <expired-access-token>` header | `{ accessToken, refreshToken }` | Yes | No | Public (but reads `sub` from expired JWT) |
| POST | `/auth/logout` | — (empty) | `{ message: 'Logged out' }` | No | No | Default JWT (requires access token) |
| POST | `/auth/dev-login` | `{ phone: string }` | `{ accessToken, refreshToken, user, isNewUser }` | Yes | Yes | Public + env flag `DEV_LOGIN_ENABLED=1`, else 403 |

Supporting behavior:
- Refresh-token rotation: every successful `/auth/refresh` revokes the old session and creates a new one. Reusing an old refresh token triggers revoke-all-for-user.
- `verifyPhoneOtp` find-or-creates a user by phone; new users get `name = phone` as a placeholder, to be updated later.
- OTP length is enforced as exactly **6 characters** by `VerifyOtpDto` — the prototype's 4-box UI is inconsistent.
- Apple identity tokens are verified against Apple's JWKS (issuer, audience, signature, alg ES256, exp, nbf).

## 5. Client comparison

| Prototype need | `packages/api_client` (shared) | `apps/mobile/.../auth_api.dart` (mobile-local) | Match? |
|---|---|---|---|
| Send OTP to phone | `sendOtp({ phone })` → `POST /auth/otp/send` | `sendOtp(phone)` → `POST /auth/phone/send-otp` | **No.** Shared client uses wrong path `/auth/otp/send`; mobile matches backend. |
| Verify OTP | `verifyOtp({ phone, code })` → `POST /auth/otp/verify`, unwraps `AuthResponse` with top-level `user` and saves tokens | `verifyOtp(phone, code)` → `POST /auth/phone/verify-otp`, returns `AuthResponse { tokens, user, isNewUser }` | **No.** Shared uses wrong path; its `AuthResponse` has `accessToken`/`refreshToken` flat, mobile wraps them in a `tokens` sub-object. |
| Google SSO | `googleLogin({ idToken })` → `POST /auth/google` | Not implemented | **No.** Shared path `/auth/google` does not exist — backend is `/auth/social/google`. |
| Apple SSO | `appleLogin({ authorizationCode, identityToken? })` → `POST /auth/apple` | Not implemented | **No.** Backend is `/auth/social/apple` and requires both `identityToken` and `authorizationCode`. |
| Refresh token | `refreshToken()` → `POST /auth/refresh { refreshToken }` with **no** `Authorization` header | `refresh({ expiredAccessToken, refreshToken })` → same path, adds `Authorization: Bearer <expired>` header | **No.** Backend needs the expired access token header to extract `sub`. Shared client will 400 / "Authorization header required". |
| Dev login | Not implemented | `devLogin(phone)` → `POST /auth/dev-login` | Only on mobile. |
| Logout | `logout()` → `POST /auth/logout` and clears local tokens | `logout()` → `POST /auth/logout` (no token clearing — done elsewhere) | Partial. Both hit the right path; token cleanup differs. |
| Birthday / profile / interests upload | — (no methods) | — (no methods) | Both missing. Prototype never fires these, but real product will need them. |

Additional structural differences:
- Shared client keeps tokens inside `AuthResponse` alongside `user` as flat fields (`accessToken`, `refreshToken`, `user`, `isNewUser`). Mobile client nests tokens under `tokens: AuthTokens`. Backend returns the flat shape.
- Shared client uses freezed/json_serializable generated models (`packages/models`); mobile defines hand-rolled POJOs locally (`auth_models.dart`). These are not shared.
- Shared client auto-saves tokens after verify/google/apple/refresh via `_client.saveTokens`; mobile delegates to `token_storage.dart` via the provider layer.
- Mobile's `AuthUser` is a slim subset (id, phone, email, name, avatarUrl); shared `User` is the full freezed entity from `packages/models`.

## 6. Open questions / design ambiguities

1. **OTP length mismatch.** Prototype shows 4 boxes; backend requires exactly 6 characters. Which is authoritative? (Recommend: backend stays at 6 for security; prototype updates to 6 boxes in Phase C2.)
2. **Email-first signup path.** `authPhone` email tab navigates to `authBirthday` without any server call — is email signup actually supported by the backend? No `/auth/email/*` endpoints exist. Either add them or remove the email tab.
3. **Interests, DOB, display name, username — when do they get saved?** Prototype collects them but never sends them. Options: (a) one consolidated `PATCH /users/me` at end of onboarding; (b) progressive `PATCH /users/me` after each screen; (c) a dedicated `POST /onboarding/complete` atomic endpoint. Decision needed before C2.
4. **Username uniqueness check.** `authProfile` shows a check icon next to the username field but never calls the backend. Need `GET /users/username-available?handle=foo` or equivalent.
5. **AgeBlock path for SSO users.** SSO flow from `authMethod` skips birthday entirely — there is no age gate for Google/Apple signups. Is that intentional, or should SSO users also land on `authBirthday` before `authProfile`?
6. **`authSignup` (legacy consolidated form).** Not on the main flow but still a reachable route. Retire it or repurpose it?
7. **Tutorial completion.** Prototype drops the user directly into the video feed on tutorial-end. Should completion be persisted server-side (`POST /users/me/tutorial-complete`) to avoid re-showing on reinstall? Or is client-local enough?
8. **Interest chip state.** `ProtoDemoData.interests[].isSelected` is demo data, not wired to any real selection state. The `"3 of 3 selected"` counter is hard-coded. Real selection + server save is unimplemented.
9. **`authLogin` never calls the backend.** SSO and phone/email log in buttons both call `switchModule(video)` with no network call. In production this needs to fire `/auth/phone/send-otp` → `/auth/phone/verify-otp` (or the social endpoints), then tokens must be in storage before entering the app.
10. **Resend OTP endpoint.** `authOtp` has a resend button — is `POST /auth/phone/send-otp` idempotent and rate-limited, or do we need a distinct `/auth/phone/resend-otp`?

## 7. Recommended target contract

After Phase C2+C3, `kuwboo_api_client.AuthApi` should expose the following against a backend aligned on these exact paths. `AuthResponse` is the flat freezed shape (tokens as top-level fields alongside `user` and `isNewUser`).

```
POST /auth/phone/send-otp        { phone }                           → { message }
POST /auth/phone/verify-otp      { phone, code(6) }                  → AuthResponse
POST /auth/social/google         { idToken }                         → AuthResponse
POST /auth/social/apple          { identityToken, authorizationCode, fullName? } → AuthResponse
POST /auth/refresh               { refreshToken }  + Bearer <expired-access> header  → TokenPair
POST /auth/logout                —  (bearer access token)            → { message }
POST /auth/dev-login             { phone }  (DEV_LOGIN_ENABLED=1)    → AuthResponse

PATCH /users/me                  { name?, username?, dateOfBirth?, avatarUrl?, interests?[] } → User
GET   /users/username-available  ?handle=…                           → { available: boolean }
```

Dart surface:

```dart
class AuthApi {
  Future<void>         sendPhoneOtp(String phone);
  Future<AuthResponse> verifyPhoneOtp(String phone, String code);     // saves tokens
  Future<AuthResponse> googleLogin(String idToken);                   // saves tokens
  Future<AuthResponse> appleLogin({ required String identityToken,
                                    required String authorizationCode,
                                    String? fullName });              // saves tokens
  Future<TokenPair>    refresh();                                     // reads storage,
                                                                      // attaches bearer
  Future<void>         logout();                                      // clears tokens
  Future<AuthResponse> devLogin(String phone);                        // dev only
}

class UsersApi {
  Future<User>         getMe();
  Future<User>         patchMe({ String? name, String? username,
                                 DateTime? dateOfBirth, String? avatarUrl,
                                 List<String>? interests });
  Future<bool>         isUsernameAvailable(String handle);
}
```

## 8. What changes for each consumer (Phase C2 + C3 preview)

### Backend (`apps/api/src/modules/auth/`)

- **Leave alone:** `/auth/phone/send-otp`, `/auth/phone/verify-otp`, `/auth/social/google`, `/auth/social/apple`, `/auth/refresh`, `/auth/logout`, `/auth/dev-login`.
- **Add (for onboarding):** `PATCH /users/me` accepting `{ name, username, dateOfBirth, avatarUrl, interests[] }` as partial updates. `GET /users/username-available`. Decide on tutorial-complete storage.
- **Consider:** promote refresh-token `sub` extraction off the expired access token into a proper `jti`-indexed refresh table (current path decodes unverified JWT which is functional but unusual).

### `packages/api_client/lib/src/auth_api.dart`

- **Fix paths:** `/auth/otp/send` → `/auth/phone/send-otp`; `/auth/otp/verify` → `/auth/phone/verify-otp`; `/auth/google` → `/auth/social/google`; `/auth/apple` → `/auth/social/apple`.
- **Fix `refresh`:** attach `Authorization: Bearer <expired-access-token>` from storage before POST.
- **Fix `appleLogin` signature:** require `authorizationCode` and `identityToken` (backend needs both).
- **Add methods:** `devLogin(phone)`, plus `UsersApi.patchMe` and `UsersApi.isUsernameAvailable` on a sibling class.
- **Keep:** existing freezed `AuthResponse` / `TokenPair` shapes (they match backend).

### Mobile (`apps/mobile/lib/features/auth/`)

- **Delete:** `data/auth_api.dart`, `data/auth_models.dart`. Mobile consumes `packages/api_client` for everything.
- **Keep / move:** `data/token_storage.dart` → either kept as the concrete storage implementation injected into `KuwbooApiClient`, or promoted into `packages/api_client` as a pluggable `SecureTokenStore`. Prefer the latter so web (prototype) can use a stub.
- **Providers:** `providers/auth_provider.dart` and `providers/api_provider.dart` re-point to `AuthApi` from `kuwboo_api_client`. Swap `AuthResponse.tokens.accessToken` accesses for top-level `authResponse.accessToken`.
- **Screens:** `packages/kuwboo_auth` screens gain real state + submit handlers (currently all `state.push(nextRoute)`). Phone screen fires `sendPhoneOtp`, OTP screen fires `verifyPhoneOtp`, method/login SSO buttons fire `googleLogin`/`appleLogin`, birthday/profile/onboarding fire `patchMe`.
- **OTP digit count:** update `authOtp` to 6 boxes (or change backend DTO to accept 4 — not recommended).

---

**Next phase (C2):** PR that fixes `packages/api_client/lib/src/auth_api.dart` to match the backend, deletes `apps/mobile/.../auth_api.dart`, and re-wires mobile providers.

---

## 9. Resolutions (decisions)

Captured from product owner review of section 6.

| # | Question | Decision |
|---|---|---|
| 1 | OTP length (4 vs 6) | **6 digits** (industry standard). Update `authOtp` UI to 6 boxes. |
| 2 | Email signup | **Add** `/auth/email/send-otp` + `/auth/email/verify-otp` (parity with phone flow). |
| 3 | Profile-data save strategy | **Progressive `PATCH /users/me`** after each onboarding step (interests, dob, name, etc.). Profile fields are optional builders; access can be blocked downstream where a specific field is required. |
| 4 | Age gate for SSO users | **No skip of birthday step** for SSO. Add a "Skip" affordance for users who want to get on quickly. **Also capture App-Store age range** when SSO providers expose it (Apple's `realUserStatus` / age-bracket signals; Google's analogous data). Persist as `user.signup_age_bracket`. |
| 5 | Tutorial completion persisted server-side | **Yes.** Add `POST /users/me/tutorial-complete`; suppress tutorial on subsequent installs. |
| 6 | `authSignup` legacy consolidated form | **Delete.** Use the separate `authPhone` + `authOtp` screens. **Add a country-code prefix selector** to `authPhone`. |
| 7 | Username uniqueness check | **Yes.** Add `GET /users/username-available?handle=…`. |
| 8 | OTP resend endpoint | **Reuse `POST /auth/phone/send-otp`** with rate-limiting + idempotency-window — best practice, single endpoint surface. |
| 9 | `authLogin` is a pure mock | **Wire up in C3** to real OTP / SSO flow + token storage before app entry. |
| 10 | Interest list source | **Seed + admin-editable in DB.** See data-model below. |

### Interests data model (resolved from #10)

User concern: list must be admin-editable without breaking historical user selections or the recommendation engine.

```
interests
  id            uuid PK              -- immutable, referenced from user_interests
  slug          text UNIQUE NOT NULL -- immutable, used in code/seed
  label         text NOT NULL         -- admin-editable display name
  category      text?                  -- optional grouping (Sports, Music, …)
  display_order int DEFAULT 0
  is_active     bool DEFAULT true     -- soft-delete only
  created_at, updated_at

user_interests  (join)
  user_id     uuid FK -> users.id
  interest_id uuid FK -> interests.id
  selected_at timestamp
  PK (user_id, interest_id)
```

Rules:
- **No hard-deletes** of interests — `is_active=false` removes from onboarding chips but preserves user history and recommendation features.
- **Renames are free** — `label` is editable; `id`/`slug` never change.
- **Admin panel** does CRUD on `interests`, including reorder via `display_order`.
- **Seed** ~30 entries covering Music, Sports, Food, Travel, Tech, Arts, Wellness, Gaming, Pets, Outdoors. List finalised in C2.

### New backend work surfaced by these decisions

- `POST /auth/email/send-otp` + `POST /auth/email/verify-otp` (Q2)
- `PATCH /users/me` accepting partial profile fields: interests[], dob, name, displayName, username, avatarUrl (Q3)
- `POST /users/me/tutorial-complete` (Q5)
- `GET /users/username-available?handle=…` (Q7)
- New column `users.signup_age_bracket` populated from SSO provider data when available (Q4)
- New tables `interests` + `user_interests` with seed migration + admin CRUD (Q10)

These extend section 7's "Recommended target contract" — Phase C2 will sequence them.

---

## 10. Critique adjustments to section 9

Pushed back during product review; working defaults below.

| # | Original answer | Adjustment |
|---|---|---|
| 2 | Add email signup | **Deferred to v1.1.** Adding an email channel pulls in transactional-email infra (SES/SendGrid, DKIM/SPF, bounce + abuse handling, deliverability ops) and forces a phone↔email account-merge policy. Phone-only for v1; revisit when product needs warrant the cost. |
| 3 | Progressive PATCH | Keep progressive, but add **resume-from-step-N** logic: server tracks `onboarding_progress` (enum or last-completed step) so the app picks up where the user dropped off after a crash/uninstall. |
| 4 | Capture App-Store age bracket via SSO | **Wrong assumption — Apple/Google SSO do not expose user age.** Apple's `realUserStatus` is bot-detection, not an age signal. **Working default:** require `authBirthday` for SSO users too, with a Skip button (sets `birthday_skipped=true`); the Trust/Recommend engine treats unknown-age conservatively. Drop the `signup_age_bracket` column from the plan. |
| 5 | Persist tutorial completion | Also store `tutorial_version int` next to the boolean. New tutorial = bump version = existing users see it again. |
| 6 | Country-code prefix on phone screen | Use `intl_phone_field` (or similar Pub package) — don't roll your own picker. |
| 7 | Username uniqueness check | Client-side **debounce 300ms**; on submit, handle **409 Conflict** gracefully (race window is unavoidable without server-side reservation). Skip the reservation system. |
| 8 | OTP resend reuses send endpoint | Rate-limit **per-phone AND per-IP**. Same response shape for first-send and resend (let the client label the UI). |

### Updated backend deltas (final list for C2)

Replaces the list at end of section 9.

- ~~`POST /auth/email/send-otp` + `POST /auth/email/verify-otp`~~ — deferred to v1.1
- `PATCH /users/me` — partial profile fields; idempotent per-field
- `POST /users/me/tutorial-complete` — sets `tutorial_completed_at` + `tutorial_version`
- `GET /users/username-available?handle=…` — returns `{available: bool}`; client debounces; submit handles 409
- `POST /auth/phone/send-otp` — per-phone + per-IP rate limit; same response on first-send and resend
- `users` columns: `tutorial_version int default 0`, `tutorial_completed_at timestamptz null`, `onboarding_progress enum`, `birthday_skipped bool default false`
- ~~`users.signup_age_bracket`~~ — dropped (no source of truth)
- New tables: `interests`, `user_interests` (schema in section 9)
- Seed migration: ~30 default interests
