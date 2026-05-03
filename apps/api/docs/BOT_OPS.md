# Bot operations runbook

End-to-end ops guide for the Kuwboo bot system: NPC users that emit lifelike
feed traffic so the prototype web feed and the mobile feed have something to
render in dev / staging / demo environments.

The system is composed of:

- **`BotProfile`** (entity) — persona + behaviour config + simulation status,
  one-to-one with a `User` (`isBot=true`)
- **`BotsService`** — CRUD over `BotProfile`s
- **`BotEngineService`** — given a `BotProfile`, picks one weighted action and
  executes it (creates a video / post / like / comment / view / follow / wave /
  message / location move)
- **`BotSchedulerService`** — schedules a BullMQ `bot-action` job per bot at a
  random delay drawn from the persona's interval window (or the demo-mode
  override)
- **`BotActionProcessor`** — the BullMQ worker. Picks up the job, asks the
  engine for an action, then schedules the next job to keep the loop alive.
  Wrapped in `RequestContext.create` so the engine and downstream services
  get a forked EM
- **`BotSimulationBootstrap`** — `OnModuleInit` hook that auto-starts every
  IDLE / PAUSED bot when `BOT_SIMULATION_ENABLED` is truthy

## Environment flags

| Flag | Default | Purpose |
|---|---|---|
| `BOT_SIMULATION_ENABLED` | unset (off) | When truthy the bootstrap hook auto-starts every IDLE/PAUSED `BotProfile` on app boot. Leave unset in production. |
| `BOT_SIMULATION_MAX_BOTS` | unset (no cap) | Optional integer cap on how many bots the bootstrap auto-starts. Bots beyond the cap stay in their current state and can be started later via the admin API. |
| `BOT_DEMO_MODE` | unset (off) | When truthy the scheduler ignores persona-defined `minActionIntervalMs` / `maxActionIntervalMs` and `activeHoursStart` / `activeHoursEnd` and uses the demo interval window below instead. |
| `BOT_DEMO_MIN_INTERVAL_MS` | `10000` | Lower bound of the demo cadence window. Read on every schedule call so an operator can tune cadence by `pm2 restart` without redeploy. |
| `BOT_DEMO_MAX_INTERVAL_MS` | `60000` | Upper bound. |

Truthy means `1`, `true`, `yes`, or `on` (case-insensitive).

## Seeding

`npm run seed:demo` (or `seed:demo:force`) seeds users + content **and** runs
the bot seeder as the tail step. The bot seeder creates 12 distinct bots
spread across the 5 personas and scattered around central London.

| Command | What it does |
|---|---|
| `npm run seed:demo` | Idempotent — skips if any seed bots exist |
| `npm run seed:demo:force` | Wipes seed users + bots, re-inserts |
| `npm run seed:demo -- --no-bots` | Skip the bot tail (run only the user/content seed) |
| `npm run seed:bots` | Run the bot seeder standalone |
| `npm run seed:bots:force` | Wipe and re-insert the bot population |

The bot seeder gates idempotency by name prefix (`Kuwboo Bot ___`) so it never
touches bots created via the admin UI / API.

## Starting and stopping the simulation

### Local dev — auto-start

```bash
# 1. seed once
cd apps/api
npm run build && npm run seed:demo

# 2. boot with demo flags
BOT_SIMULATION_ENABLED=1 BOT_DEMO_MODE=1 npm run start:dev
```

You should see `BotSimulationBootstrap` log on boot:

```
[BotSimulationBootstrap] Bot simulation auto-start: 12/12 bots started (BOT_DEMO_MODE=1).
```

…and `BotEngineService` / `BotActionProcessor` log activity every ~10–60 s.

### Local dev — manual

If you want to keep the bootstrap quiet and start bots interactively:

```bash
# leave BOT_SIMULATION_ENABLED unset
BOT_DEMO_MODE=1 npm run start:dev

# then either
curl -X POST http://localhost:3000/admin/bots/start-all -H "Authorization: Bearer <admin-jwt>"
# or one bot at a time
curl -X POST http://localhost:3000/admin/bots/<id>/start ...
```

### Pause / stop

```bash
curl -X POST http://localhost:3000/admin/bots/stop-all   ...   # all bots → IDLE
curl -X POST http://localhost:3000/admin/bots/<id>/pause ...   # one bot   → PAUSED
curl -X POST http://localhost:3000/admin/bots/<id>/stop  ...   # one bot   → IDLE
```

`stop-all` and `stop` both remove pending BullMQ jobs from the `bot-actions`
queue, so no further activity emits until the bot is re-started.

### Single-shot trigger (debugging)

```bash
curl -X POST http://localhost:3000/admin/bots/<id>/trigger ...   # one action, no scheduling
```

Useful when investigating why a particular bot's action keeps failing — the
response body is the `BotActionResult` (`{actionType, success, errorMessage}`).

## Inspecting activity

The scheduler writes a `bot_activity_logs` row for every action attempted
(success or failure). Three windows into that data:

| Endpoint | Purpose |
|---|---|
| `GET /admin/bots/stats` | Process-wide counts: total, running, paused, idle, error, actions today |
| `GET /admin/bots/:id/activity` | Cursor-paginated log per bot |
| `GET /admin/bots/:id/activity/stats` | Total actions, success rate, last-24 h count, breakdown by `actionType` |

Or run directly against Postgres:

```sql
-- Last 50 bot actions across all bots
SELECT
  b.display_persona,
  u.name AS bot_name,
  l.action_type,
  l.success,
  l.error_message,
  l.executed_at
FROM bot_activity_logs l
JOIN bot_profiles b ON b.id = l.bot_profile_id
JOIN users u ON u.id = b.user_id
ORDER BY l.executed_at DESC
LIMIT 50;

-- Hourly action volume across the last 6 h
SELECT date_trunc('hour', executed_at) AS hour,
       action_type,
       count(*) AS n
FROM bot_activity_logs
WHERE executed_at > now() - interval '6 hours'
GROUP BY 1, 2
ORDER BY 1 DESC, 3 DESC;

-- Confirm feed-vertical content exists
SELECT type, count(*) FROM contents WHERE deleted_at IS NULL GROUP BY 1;
```

## Expected activity rates

With the seeded 12-bot population:

| Mode | Cadence | ~Actions / minute | ~Actions / hour |
|---|---|---|---|
| `BOT_DEMO_MODE=1` (10–60 s) | every bot fires every ~30 s | ~24 | ~1500 |
| Persona defaults (30–600 s by persona) | mixed | ~3–8 | ~200–500 |

Of the action mix in demo mode, expect roughly:

- **~30 %** view / like (cheap reads on existing content)
- **~20 %** comment (writes to `comments`)
- **~15 %** create video / post (new feed-vertical content)
- **~10 %** follow (new connection edges)
- **remainder** waves / messages / movement / wave responses

The actual mix is biased by the persona of each bot — `content_creator` posts
much more than `lurker`, `explorer` moves more than the rest, etc.

## Feed-vertical priority

The web feed (`apps/web/`, video tab) and the mobile feed render `Content`
rows of `type=VIDEO` and `type=POST`. The feed-vertical bot actions are:

- `createVideo` — emits a `Video` row using `BOT_VIDEO_LIBRARY` (Google CDN
  sample clips + Pexels thumbnails)
- `createPost` — emits a `Post` row from the persona's `postTemplates`
- `likeContent`, `commentOnContent`, `viewContent` — drive the
  `like_count` / `comment_count` / `view_count` counters on existing content
- `followUser` — populates the connection graph so a user's "following" feed
  has content

`sendWave`, `respondToWave`, `moveLocation`, `sendMessage` are lower priority
and don't surface in the feed; they exist to keep yoyo / messaging /
geospatial features alive when those screens are exercised.

## Troubleshooting

### "BotActionProcessor reports `Using global EntityManager` errors"
The processor must be wrapped in `RequestContext.create`. If you see this
error in logs, check `bot-action.processor.ts` is calling
`RequestContext.create(this.orm.em, ...)` around the job body (this fix
landed in the bot-feed-traffic PR). Bullmq workers run outside the Nest
request lifecycle so the global EM has no AsyncLocalStorage context.

### "Bot moves to ERROR after 10 consecutive failures"
The processor counts consecutive failures per bot and forces ERROR after 10.
Common causes:

- **`No content to like` / `No content to comment on`** — DB has no `Content`
  rows of an `ACTIVE` status the bot hasn't already interacted with. Run
  `npm run seed:demo` to backfill content.
- **`No nearby users` (sendWave)** — bot has no `lastLocation` or no other
  users have lat/lng set. Set locations on users via the seed scripts.
- **`No threads` (sendMessage)** — bot has never been added to a thread.
  Reduces noise in logs but otherwise harmless.

To recover an ERROR'd bot:

```bash
curl -X POST http://localhost:3000/admin/bots/<id>/reset ...   # → IDLE then re-start
```

### "BullMQ jobs stuck in delayed state"
Run `redis-cli` inside the API host and check the queue:

```bash
redis-cli
> KEYS bull:bot-actions:*
> LLEN bull:bot-actions:wait
> ZCARD bull:bot-actions:delayed
```

If `delayed` is large but `wait` is empty and no jobs are completing, the
worker is not consuming. Check `BotActionProcessor` is registered (it should
log `[BotActionProcessor] Worker initialized` on boot). PR #63 was the first
time this broke — DI for `MikroORM` resolved against the wrong token and the
processor never instantiated.

### "Bots never fire outside active hours (production)"
Persona defaults define `activeHoursStart` / `activeHoursEnd` so bots go quiet
overnight (process-local time). To override for staging demos, set
`BOT_DEMO_MODE=1` — the scheduler bypasses the active-hours gate entirely.

## Production safety

- **Default off** — `BOT_SIMULATION_ENABLED` and `BOT_DEMO_MODE` are unset by
  default. Production deploys never auto-start bot traffic.
- **Bot users are tagged** — `users.is_bot = true`. Feed and recommendation
  queries can exclude bots via `?excludeBots=true` or the equivalent `where`
  clause.
- **Activity is auditable** — every action has a `bot_activity_logs` row with
  the bot ID, action type, target ID, success flag, and error message.
- **Rate-limited by design** — every bot action goes through the same service
  layer as a human user (`ContentService.createPost` etc.), so any rate
  limits, validation, or trust signals apply equally.

## Adding a new persona

1. Append a new entry to `apps/api/src/modules/bots/presets/persona-presets.ts`.
   Action weights must sum to 1.0; templates can be empty arrays (the engine
   falls back gracefully).
2. Add the persona name to the seed script's `SEED_BOTS` array if you want
   seeded bots of that persona out of the box.
3. The admin DTO accepts free-form persona strings (validated via
   `getPreset()`), so `POST /admin/bots` with a new persona name works once
   the preset is registered.
4. There is no DB schema change — `BotProfile.behaviorConfig` is JSONB.

## Adding a new action type

1. Add a case to `BotEngineService.executeRandomAction`'s switch, plus a
   `doXxx(profile)` method that returns `BotActionResult`.
2. Add the new action key to `BotBehaviorConfig['actionWeights']` in the
   entity, default it to `0` for existing personas, and bump the relevant
   personas' weights.
3. Add an integration assertion in `apps/api/test/bot-simulation.e2e-spec.ts`
   that the new action either succeeds or has an explanatory `errorMessage`
   under realistic seeded data.
