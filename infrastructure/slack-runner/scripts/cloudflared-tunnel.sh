#!/usr/bin/env bash
# Sets up a Cloudflare Tunnel that exposes the local :4100 runner over HTTPS.
# This lets the Vercel Slack bridge reach the EC2 runner without us having to
# wire up DNS / Let's Encrypt yet (deferred per the user's request).
#
# Prereq: a Cloudflare account exists. Free tier is fine.
# Usage on EC2:
#   bash cloudflared-tunnel.sh
# Then copy the printed `https://<tunnel>.trycloudflare.com` URL into Vercel's
# RUNNER_URL env var (append `/internal/agent-runs`).
#
# This script uses the "quick tunnel" mode — no Cloudflare account login
# required. Persistent tunnels with custom hostnames need `cloudflared tunnel
# login + create + route` which is the next step once a domain is in place.

set -euo pipefail

if ! command -v cloudflared >/dev/null; then
  echo "cloudflared not installed — run install-on-ec2.sh first"
  exit 1
fi

if ! curl -fs http://localhost:4100/healthz >/dev/null; then
  echo "Runner not responding on :4100 — start it first (pm2 start ecosystem.config.cjs)"
  exit 1
fi

echo "==> Starting persistent quick-tunnel under PM2"
# Quick tunnels are ephemeral by design — the URL changes on every restart.
# For stability we run cloudflared under PM2 and parse the URL from logs once.
pm2 delete cloudflared-runner 2>/dev/null || true
pm2 start cloudflared --name cloudflared-runner -- tunnel --url http://localhost:4100
pm2 save

echo "==> Tunnel starting — waiting up to 30s for the hostname..."
for i in {1..30}; do
  URL=$(pm2 logs cloudflared-runner --nostream --lines 50 2>/dev/null | grep -oE 'https://[a-z0-9-]+\.trycloudflare\.com' | head -1 || true)
  if [[ -n "${URL:-}" ]]; then
    echo "==> Tunnel URL: $URL"
    echo "==> Set RUNNER_URL in Vercel to: $URL/internal/agent-runs"
    exit 0
  fi
  sleep 1
done

echo "Could not find tunnel URL in logs — check 'pm2 logs cloudflared-runner'."
exit 1
