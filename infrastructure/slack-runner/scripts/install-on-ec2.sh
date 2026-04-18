#!/usr/bin/env bash
# One-time bootstrap on the EC2 box (kuwboo-greenfield-api, i-0766e373b3147a2aa).
# Run via SSM:
#   aws ssm start-session --target i-0766e373b3147a2aa --profile neil-douglas-kuwboo
# Then on the box:
#   curl -s https://raw.githubusercontent.com/pcutting/team_kuwboo/main/infrastructure/slack-runner/scripts/install-on-ec2.sh | bash
#
# Idempotent: re-running is safe.

set -euo pipefail

RUNNER_DIR=/home/ubuntu/kuwboo-slack-runner
LOGS_DIR=/home/ubuntu/logs
RUNS_DIR=/home/ubuntu/agent-runs
REPO=https://github.com/pcutting/team_kuwboo.git

echo "==> Ensuring Node 22 + PM2 + gh CLI"
if ! command -v node >/dev/null || [[ "$(node -v)" != v22* ]]; then
  curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
  sudo apt-get install -y nodejs
fi
if ! command -v pm2 >/dev/null; then
  sudo npm install -g pm2
fi
if ! command -v gh >/dev/null; then
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
  sudo apt-get update
  sudo apt-get install -y gh
fi

echo "==> Installing cloudflared"
if ! command -v cloudflared >/dev/null; then
  curl -fsSL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /tmp/cloudflared
  sudo install -m 0755 /tmp/cloudflared /usr/local/bin/cloudflared
fi

echo "==> Cloning runner code"
mkdir -p "$LOGS_DIR" "$RUNS_DIR"
if [[ ! -d "$RUNNER_DIR/.git" ]]; then
  # Sparse-checkout just the runner subtree from the monorepo
  git clone --depth=1 --no-checkout "$REPO" "$RUNNER_DIR"
  git -C "$RUNNER_DIR" sparse-checkout init --cone
  git -C "$RUNNER_DIR" sparse-checkout set infrastructure/slack-runner
  git -C "$RUNNER_DIR" checkout main
  # Move runner files up so PM2's cwd is straight forward
  mv "$RUNNER_DIR/infrastructure/slack-runner"/* "$RUNNER_DIR/"
  rm -rf "$RUNNER_DIR/infrastructure"
else
  git -C "$RUNNER_DIR" pull --ff-only
fi

echo "==> npm install"
cd "$RUNNER_DIR"
npm install --no-audit --no-fund

echo "==> Authenticating gh CLI from /kuwboo/github secret"
GH_PAT=$(aws secretsmanager get-secret-value \
  --secret-id /kuwboo/github \
  --query SecretString --output text \
  --region eu-west-2 | python3 -c "import json,sys;print(json.load(sys.stdin)['pat'])")
echo "$GH_PAT" | gh auth login --with-token

echo "==> Starting PM2 process"
pm2 delete kuwboo-slack-runner 2>/dev/null || true
pm2 start ecosystem.config.cjs
pm2 save
sudo env PATH=$PATH:/usr/bin pm2 startup systemd -u ubuntu --hp /home/ubuntu

echo "==> Done. Health check:"
sleep 2
curl -s http://localhost:4100/healthz | python3 -m json.tool
