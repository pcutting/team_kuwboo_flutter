# Backend seed data

**Phase 6 of mobile rebuild — 2026-04-15**

## Why

Both the mobile app and the web prototype now read the same live backend. No `showDemoData` dual code path survives — there is one source of truth and it is the seeded database. Prototype UI that used to render hardcoded `DemoEncounter` / `DemoConnection` / `DemoComment` arrays from `packages/kuwboo_shell/lib/src/data/` will (once Phase 7 wires real APIs) render whatever the backend returns.

## Entry point

```bash
# Build, then seed once (safe no-op if already seeded)
cd apps/api
npm run build
npm run seed:demo

# Re-seed from scratch (deletes our sample users + cascades, then re-inserts)
npm run seed:demo:force
```

## What's covered today (`seed-demo-data.ts`)

| Domain | Count | Source |
|---|---|---|
| Users (human + bot) | 10 | `SAMPLE_USERS` — phones in `+44791…` range |
| Videos | 15 | `SAMPLE_VIDEOS` — googleapis.com sample clips + Pexels thumbnails |
| Posts | 10 | `SAMPLE_POSTS` — text-only London-flavoured copy |
| Products | 8 | `SAMPLE_PRODUCTS` — GBP prices, real-ish condition mix |
| Waves | 5 | YoYo encounters between distinct user pairs |
| User locations | 6 | `LONDON_POINTS` geospatial, set on first N users |

## Idempotency

The seed gate is `phone LIKE '+44791%'` — our entire sample-user phone range. Re-running `seed:demo` is a safe no-op. `seed:demo:force` deletes those users and everything that FK-cascades off them (videos, posts, products, waves), then reinserts.

## Connected test user (`seed-test-user.ts`)

A second seed script wires `cuttingphilip+test@gmail.com` into the demo graph so that — when this email is used at sign-in (it bypasses rate limiting via `KuwbooThrottlerGuard.reservedEmails`) — every feed has content visible to the logged-in user.

```bash
# Standalone (after seed:demo has populated the base content)
cd apps/api
npm run build
npm run seed:test-user

# Auto-run as the tail of seed:demo (default)
npm run seed:demo

# Suppress the test-user seed inside seed:demo
node -r dotenv/config dist/scripts/seed-demo-data.js --no-test-user
```

| Domain | What it adds |
|---|---|
| User + credential | `Phil (Test)` / `phil_test`, EMAIL credential, `emailVerified=true` |
| Consent | TERMS + PRIVACY granted (no consent-gate friction on authed endpoints) |
| Connections | follows all 8 non-bot seeded humans; 3 follow back; 1 mutual FRIEND edge |
| Comments | 6 by Phil on a mix of videos + posts; 6 replies back from seeded users |
| Interactions | 10 LIKEs (videos + posts), 3 SAVEs, 1 VIEW per video (15 events) |
| Threads + Messages | 3 threads — DM, BUY_SELL, YOYO — 5–6 messages each, mixed senders |
| Waves | 1 outbound (PENDING), 1 inbound (ACCEPTED) |

### Idempotency

Gate is `email = 'cuttingphilip+test@gmail.com'`. If the user exists, the script logs and exits 0 — no upsert / merge. To re-run from scratch: delete the user manually (`DELETE FROM users WHERE email = '…+test@…'` cascades through credentials/connections/comments/interactions/messages/waves/consents).

### Why a separate file

- `seed-demo-data.ts` is the **content-creator seed** — it gives the database a population of users + content for unauthenticated browsing and rendering.
- `seed-test-user.ts` is the **subject seed** — it gives one logged-in user a populated graph (followers, threads, likes) so signed-in screens have something to render. Splitting keeps each script's idempotency gate single-purpose and lets the test user be re-seeded independently of the content seed.

## Bot population (`seed-bots.ts`)

Seeds 12 `BotProfile` rows + their backing `User` records spread across the 5
preset personas (`social_butterfly`, `content_creator`, `lurker`, `explorer`,
`shopper`). Wired into `seed-demo-data.ts` as the tail step so the scheduler
has both a graph of users to follow and a corpus of content to interact with
on the very first tick once started.

```bash
# Standalone (after seed:demo has populated base content)
cd apps/api
npm run build
npm run seed:bots
npm run seed:bots:force      # wipe + re-insert

# Auto-run as the tail of seed:demo (default)
npm run seed:demo
npm run seed:demo -- --no-bots   # skip the bot tail
```

| Domain | What it adds |
|---|---|
| Users (bots) | 12, all `isBot=true`, with `lastLocation` scattered across central London |
| BotProfiles | 12, one per bot user, persona round-robin |
| YoyoSettings | 12 (created by `BotsService.createBot`) |

### Idempotency

Gate is `User.name LIKE 'Kuwboo Bot ___'`. If any rows match, the function
logs and returns. To re-run from scratch, pass `force=true` (or
`seed:bots:force`) — the script deletes the matching `User` rows and the
`BotProfile` cascades follow.

### Operating the seeded bots

`seed-bots.ts` only **creates** bots in `IDLE` state — it does not start the
simulation. Either set `BOT_SIMULATION_ENABLED=1` on the API process to
auto-start them on boot, or call `POST /admin/bots/start-all` against the
running API. See `apps/api/docs/BOT_OPS.md` for the full runbook (env flags,
demo cadence, troubleshooting).

## Admin users (`seed-admin.ts`)

Creates (or upserts) two `SUPER_ADMIN` users with email + bcrypt password credentials so the admin dashboard at `admin.kuwboo.com` can be reached via email+password login. Passwords are never hard-coded — they are read from env vars at seed time.

```bash
cd apps/api
npm run build
ADMIN_PHIL_PASSWORD='...' ADMIN_NEIL_PASSWORD='...' \
  npm run seed:admin
```

| Env var | Purpose | Default |
|---|---|---|
| `ADMIN_PHIL_EMAIL` | Phil's admin email | `cuttingphilip@gmail.com` |
| `ADMIN_PHIL_PASSWORD` | Phil's password (required) | — |
| `ADMIN_PHIL_USERNAME` | Phil's username (unique across `users`) | `phil_admin` |
| `ADMIN_NEIL_EMAIL` | Neil's admin email | `neildouglas33@hotmail.co.uk` |
| `ADMIN_NEIL_PASSWORD` | Neil's password (required) | — |
| `ADMIN_NEIL_USERNAME` | Neil's username (unique across `users`) | `neil_admin` |

### Idempotency

If a user with the target email already exists, the script rotates `passwordHash`, elevates `role` to `SUPER_ADMIN` (if lower), and ensures an `EMAIL` credential row. No other user fields are touched. Re-running with a new password is the intended way to rotate.

## Extending in Phase 7

Phase 7 agents wiring each module's screens to live APIs should add their domain seed data here or in a sibling file. Preferred pattern:

1. Append a new `seedXxx()` async function in this file that upserts into its domain's tables using the existing `users` array as creator refs.
2. Gate with a domain-specific count or seed-id prefix so re-running without `--force` is safe.
3. Call it after the `await tem.flush()` for products in the transactional block.
4. Add the domain's row to the `summary` table printed at the end.

### Domains that still need seed data

These are **not yet covered** and become real work inside Phase 7's per-module agents:

- **Comments** — on seeded videos + posts. Key pattern: author = users[i % len], parentCommentId cycles every 3rd.
- **Interactions** — likes / saves / views on seeded videos + posts. A handful per item is enough to exercise counter UI.
- **Connections** — follow + friend graph between seeded users. Every user follows the next 2 in the list; bots stay isolated.
- **Threads + Messages** — 2-3 threads per moduleKey (VIDEO_MAKING / BUY_SELL / DATING / SOCIAL_STUMBLE / YOYO) with 5-10 messages each.
- **Dating** (module from PR #98) — matches + swipes on seeded users. Respect DatingAgeGuard age gate.
- **Notifications** — synthesized from the above (one per like/match/follow).
- **Interests** — existing migration already seeds these — no work needed.
- **Auctions + Bids** — 2-3 auctions on seeded products with a bid history.
- **Sponsored campaigns** — 2 DRAFT + 1 ACTIVE, pointing at seeded videos.
- **Consent** — blanket TERMS + PRIVACY grants for every seeded user (so they can call authenticated endpoints without consent-modal friction).
- **Devices** — skip; FCM tokens change too frequently to seed meaningfully.
- **Reports** — 1 dismissed report to exercise the moderator surface.
- **Media** — skip; presigned-URL flow has no meaningful seed payload (binaries would bloat the seed).

## Prototype demo-data files (not yet deleted)

`packages/kuwboo_shell/lib/src/data/demo_data.dart` and `proto_demo_data.dart` are **still imported** by prototype screens. They stay until Phase 7 rewires each screen against the live backend — at which point the corresponding imports can be deleted and the Dart files pruned. Do **not** delete them in Phase 6.

## Gotchas

- **FK order** — users must flush before videos/posts/products (already handled via the single transactional block).
- **PostGIS points** — `u.lastLocation` uses `{latitude, longitude}` shape, which MikroORM serializes via our Point type adapter. Ensure Postgres has PostGIS enabled on the target DB (CREATE EXTENSION postgis; — already in the greenfield migrations).
- **`seed-demo-data.js` lives in `dist/`** — the script runs against compiled output, so `npm run build` must precede any seed invocation.
- **Env** — the script uses `dotenv/config` to pick up DB creds from `apps/api/.env`. Running against a Secrets-Manager-backed env (staging/prod) requires a different bootstrap; currently local-dev only.
