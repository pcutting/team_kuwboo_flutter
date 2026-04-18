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

# On the box (one-time bootstrap — installs Node 22, PM2, gh, the runner code, then starts PM2)
curl -s https://raw.githubusercontent.com/pcutting/team_kuwboo/main/infrastructure/slack-runner/scripts/install-on-ec2.sh | bash
```

The runner listens on `127.0.0.1:4100`. It's fronted by Nginx + Let's Encrypt at `https://runner.kuwboo.com` (see "Public endpoint" below). Vercel's `RUNNER_URL` is set to `https://runner.kuwboo.com/internal/agent-runs`.

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

Then point a tunnel (ngrok / cloudflared quick tunnel) at `localhost:4100` and use that URL in your dev Vercel project's `RUNNER_URL`.

## Smoke test

Two layers:

**Bash probe (from laptop):**
```bash
bash infrastructure/slack-runner/scripts/smoke.sh
```
Checks `/healthz`, enforces 401 on unauthenticated dispatches, verifies TLS cert has >7 days left, and calls `/smoke` with the bearer fetched from AWS Secrets Manager.

**From Slack:**
```
@Kuwboo Claude status
```
The webhook's status command fans out to `/smoke` and reports per-dependency health in-channel.

`/smoke` (bearer-auth protected) probes each external dep the runner needs for a real run: Slack API (`auth.test`), GitHub API (`/user` with the PAT), Anthropic API (`/v1/models`), AWS Secrets Manager, the agent-runs dir, and the `gh` CLI. Returns `{ok, checks: [{name, ok, ms, detail|error}]}`. 503 if any check fails.

## Public endpoint

`runner.kuwboo.com` is an A record in Route 53 (hosted zone `Z00630163C9Z42EHND9NG`) pointing at the EC2 EIP `35.177.230.139`. On the box, Nginx terminates TLS with a Let's Encrypt cert and proxies to `127.0.0.1:4100`.

Vhost: `/etc/nginx/sites-available/slack-runner`. Cert renewal is handled by the certbot systemd timer — no manual action needed.

To reissue or swap hostnames:

```bash
sudo certbot --nginx -d runner.kuwboo.com
```
