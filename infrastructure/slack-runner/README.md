# kuwboo-slack-runner

Standalone PM2 process on the Kuwboo EC2 box (`i-0766e373b3147a2aa`) that:

1. Listens on `:4100` for dispatches from the Vercel Slack bridge
2. Clones `pcutting/team_kuwboo` into a per-run workdir
3. Runs the Claude Agent SDK with the user's Slack reply as the prompt
4. Commits, pushes, opens a PR (does **not** auto-merge — human review is the policy)
5. Posts the PR URL back into the Slack thread with a ✅ reaction

## Why standalone (not part of kuwboo-api)?

An agent crash should not take down the production API. Separate PM2 process, separate port, separate logs. Communicates with Vercel via a shared bearer token (`RUNNER_SHARED_SECRET`).

## Deploy

```bash
# From your laptop, into EC2 via SSM
aws ssm start-session --target i-0766e373b3147a2aa --profile neil-douglas-kuwboo

# On the box (one-time bootstrap — installs Node 22, PM2, gh, cloudflared, the runner code, then starts PM2)
curl -s https://raw.githubusercontent.com/pcutting/team_kuwboo/main/infrastructure/slack-runner/scripts/install-on-ec2.sh | bash

# Start the Cloudflare quick-tunnel and grab the public HTTPS URL
bash /home/ubuntu/kuwboo-slack-runner/scripts/cloudflared-tunnel.sh
```

The cloudflared script prints a URL like `https://kuwboo-runner-xxxxx.trycloudflare.com`. Append `/internal/agent-runs` and paste that into Vercel as `RUNNER_URL`.

## Required AWS Secrets Manager entries

| Secret name | Keys |
|---|---|
| `/kuwboo/slack` | `bot_token`, `signing_secret`, `app_id`, `client_id` |
| `/kuwboo/anthropic` | `api_key` (dedicated Anthropic account, not personal) |
| `/kuwboo/github` | `pat` (fine-grained, scoped to `pcutting/team_kuwboo`, Contents r/w + PRs r/w) |
| `/kuwboo/slack-runner` | `shared_secret` (`openssl rand -hex 32`) |

The runner pulls all five at boot via `secrets.ts`. No secrets are baked into PM2 env or the systemd unit.

## Local dev

```bash
cd infrastructure/slack-runner
npm install
LOCAL_DEV=1 \
  SLACK_BOT_TOKEN=… \
  SLACK_SIGNING_SECRET=… \
  ANTHROPIC_API_KEY=… \
  GITHUB_PAT=… \
  RUNNER_SHARED_SECRET=… \
  npm run dev
```

Then point a tunnel (ngrok / cloudflared) at `localhost:4100` and use that URL in your dev Vercel project's `RUNNER_URL`.

## Cloudflare Tunnel — temporary vs persistent

The bootstrap script uses Cloudflare's **quick tunnel** (no account login, free, hostname is ephemeral on restart). Once Phil updates DNS for `kuwboo.com`, swap to a persistent named tunnel:

```bash
cloudflared tunnel login   # browser auth
cloudflared tunnel create kuwboo-runner
cloudflared tunnel route dns kuwboo-runner runner.kuwboo.com
# Stop the quick tunnel, start the named one
pm2 delete cloudflared-runner
pm2 start cloudflared --name cloudflared-runner -- tunnel run kuwboo-runner
```

Update `RUNNER_URL` in Vercel to `https://runner.kuwboo.com/internal/agent-runs` and the bridge keeps working with no other changes.
