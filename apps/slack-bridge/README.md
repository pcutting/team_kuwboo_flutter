# kuwboo-slack-bridge

Vercel webhook that relays Slack replies into the EC2-hosted Claude Agent SDK runner.

## Routes

| Route | Purpose |
|---|---|
| `POST /api/slack/events` | Slack Events API webhook. Verifies signature, ACKs under 3s, reads the thread root message via `conversations.replies`, parses the `<!-- kuwboo-session: ... -->` marker, fires-and-forgets to the runner. |

Session state lives in the thread root message itself — no external KV needed. The local Claude Code session must prefix its root post with:

```
<!-- kuwboo-session: runId=<id> branch=<branch> repo=pcutting/team_kuwboo cwd=<dir> -->
<human-readable question text>
```

## Environment variables (set in Vercel)

| Var | Source |
|---|---|
| `SLACK_SIGNING_SECRET` | AWS Secrets Manager `/kuwboo/slack` → `signing_secret` |
| `SLACK_BOT_TOKEN` | AWS Secrets Manager `/kuwboo/slack` → `bot_token` |
| `RUNNER_URL` | Cloudflare Tunnel URL for the EC2 runner, e.g. `https://kuwboo-runner-<hash>.trycloudflare.com/internal/agent-runs` |
| `RUNNER_SHARED_SECRET` | AWS Secrets Manager `/kuwboo/slack-runner` → `shared_secret` (same value set on EC2 runner) |

## Deploy

```bash
cd apps/slack-bridge
vercel link --scope cuttingphilipgmailcoms-projects
vercel env add SLACK_SIGNING_SECRET production
vercel env add SLACK_BOT_TOKEN production
vercel env add RUNNER_URL production
vercel env add RUNNER_SHARED_SECRET production
vercel deploy --prod
```

## Slack app Events URL

After first deploy, set the Events Request URL in the Slack app to:

```
https://<your-vercel-project>.vercel.app/api/slack/events
```

Slack will POST a `url_verification` challenge the first time — the route handler echoes back the `challenge` field automatically.

## Security notes

- Signing secret verification uses `crypto.timingSafeEqual` against the `v0=sha256(…)` header. Timestamps older than 5 minutes are rejected for replay protection.
- `bot_id`-tagged events (our own postMessage replies) are dropped to prevent feedback loops.
- Only thread replies (`thread_ts` present) trigger a runner dispatch — root messages are session anchors posted by the local Claude Code session.
- `RUNNER_SHARED_SECRET` protects the runner endpoint; it's checked on the EC2 side before any agent work runs.
