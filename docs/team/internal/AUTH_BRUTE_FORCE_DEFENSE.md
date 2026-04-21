# Auth brute-force defence

Issue #174. Three defensive layers sit between the wire and the bcrypt
hash on `POST /auth/email/login`. Each is deliberately narrow so its
failure mode is well-understood.

## Layer 1 — per-(email, ip) exponential backoff

The cheapest, most common pass: one attacker, one IP, guessing a single
email. Driven by an `INCR` against
`login:fail:{sha256(email)}:{ip}` in Redis with a 15-minute TTL.

- Attempts 1–3: no added delay. Normal-typo territory.
- Attempts 4–9: the request sleeps `500 × 2^(attempt-4)` ms before
  returning 401 — so 500 / 1000 / 2000 / 4000 / 8000 / 16000 ms.
- Attempt 10+: short-circuit to a generic 429
  `too_many_attempts`. No bcrypt compare runs.

The sleep is applied via an injectable `DelayProvider`. Tests
substitute a zero-delay stub instead of reaching for
`jest.useFakeTimers()` — safer around `async/await + setTimeout`.

Counter reset: a successful login clears both the per-(email, ip) key
AND the per-email distinct-IP set (layer 2) so a user who typed their
password wrong four times then got it right on the fifth doesn't face
an 8-second wall on their next login.

## Layer 2 — cross-IP credential-stuffing detection

One email, rotating IPs. This is the credential-stuffing pattern: a
bot trying a pre-computed `(email, password)` list against a single
account from a pool of proxies. Per-IP backoff is useless against it
because each IP only fails once or twice.

Driven by a Redis SET keyed `login:distinct-ips:{sha256(email)}` with
a 30-minute TTL (longer than layer 1 so a slow sweep still trips).
Each failed attempt `SADD`s the source IP. When `SCARD ≥ 3` the
service tells the `AuthService` to set `users.auth_locked_at = now()`.

When `auth_locked_at` is populated, every subsequent `emailLogin`
collapses to the same generic 429 — regardless of IP, regardless of
password. Unknown-email, wrong-password, and locked-account paths are
all indistinguishable in the response body (code: `too_many_attempts`,
no message variant).

## Layer 3 — notifications + metrics

On a **freshly** tripped soft-lock (dedupe keyed on
`login:lock-notified:{sha256(email)}` with 24h TTL):

- User email via `EmailService.sendLoginThreatNotice()`, using the
  existing `renderLoginThreatEmail` template. Copy avoids suggesting
  any one-click action a phished email could hijack.
- Structured warn-level log with event key `AUTH_ACCOUNT_SOFT_LOCK`.
  A future Slack-webhook runner can scrape pino output without this
  service knowing about any notification destination.

Three in-memory counters exposed via `LoginMetricsService`:
`login_failures_total`, `login_throttled_total`,
`login_soft_lock_total`. A future metrics module can expose these
via a `/metrics` endpoint — out of scope for #174.

## Unlock path

**Locked accounts unlock only via a completed password reset.**

`AuthService.emailResetPassword()` clears `auth_locked_at` and resets
the per-(email, ip) Redis counter as part of the reset transaction.
There is no auto-unlock on timer by design: credential-stuffing is a
strong enough signal that handing the attacker a fresh window is
worse than making the legitimate user reset.

Email-verify OTP does not unlock — only password reset. This keeps
the policy simple for support ("was it you? reset your password").

## Audit trail

Every attempt — success + failure — writes one row to
`auth_login_attempts` (append-only).

| Column | Type | Notes |
|---|---|---|
| `id` | uuid | PK |
| `email_hash` | varchar(64) | sha256 hex of the normalised email. Never the raw address. |
| `ip_address` | varchar(45) null | Source IP as reported by Fastify's trust-proxy layer. |
| `user_agent` | text null | UA string. Truncated at client level if absurdly long. |
| `attempted_at` | timestamptz | `default now()`. |
| `outcome` | varchar(32) | `SUCCESS \| WRONG_PASSWORD \| UNKNOWN_EMAIL \| LOCKED_OUT \| THROTTLED` |

Indexes: `(email_hash, attempted_at DESC)` and
`(ip_address, attempted_at DESC)` — both lookup shapes forensics
needs. Rows are never updated; a cron can partition / archive by
month when the table grows.

## Known trade-offs

- **Fails open on Redis outage.** If `INCR` / `SADD` / `GET` throws,
  the service logs a warning and lets the request through. Inverting
  this would lock every user out when Redis blips; that's the worse
  tail. The audit-row write is the durable evidence — a slow Redis
  day still leaves a paper trail.
- **Users enumerating attacker IPs.** An attacker trying the same
  email from two different proxies of their own will eventually trip
  the lock themselves. Since the recovery path is a password reset
  they already know how to drive, this is a self-imposed time-out,
  not a lockout from the account.
- **Dedupe window hides repeated attacks.** If the same account gets
  locked three times inside 24 hours, the user gets exactly one email.
  This is deliberate: the ops log still records each event, and
  repeat-email fatigue would train users to ignore them.
- **2FA is not implemented by this PR.** 2FA would fix the
  credential-stuffing vulnerability upstream (attacker can't log in
  even with the right password). Scope for a follow-up.
- **CAPTCHA is not implemented.** Same reasoning — the composition
  with 2FA is cleaner; adding a CAPTCHA first would paint us into a
  corner on the UX.

## Files

- `apps/api/src/modules/auth/login-throttle/login-attempt.entity.ts`
- `apps/api/src/modules/auth/login-throttle/login-attempt-logger.service.ts`
- `apps/api/src/modules/auth/login-throttle/login-throttle.service.ts`
- `apps/api/src/modules/auth/login-throttle/delay.provider.ts`
- `apps/api/src/modules/auth/login-throttle/redis.provider.ts`
- `apps/api/src/modules/auth/login-throttle/login-notifier.service.ts`
- `apps/api/src/modules/auth/login-throttle/login-metrics.service.ts`
- `apps/api/src/database/migrations/Migration20260421_auth_login_attempts.ts`
- `apps/api/src/database/migrations/Migration20260421_user_auth_locked_at.ts`
- `apps/api/test/login-throttle.e2e-spec.ts`
- `apps/api/test/login-account-lock.e2e-spec.ts`
