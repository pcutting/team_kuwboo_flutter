#!/usr/bin/env bash
# Local smoke test for the kuwboo-slack-runner bridge.
#
# Run from Phil's laptop:
#   bash infrastructure/slack-runner/scripts/smoke.sh
#
# Checks:
#   1. https://runner.kuwboo.com/healthz returns 200
#   2. POST /internal/agent-runs without a bearer → 401 (auth is wired)
#   3. TLS cert has > 7 days until expiry
#   4. /smoke (with bearer fetched from AWS Secrets Manager) returns ok=true
#
# Exits non-zero on first failure so `bash smoke.sh && echo green` is useful.
# Requires: curl, openssl, python3, aws CLI with profile `neil-douglas-kuwboo`.

set -euo pipefail

PROFILE="${AWS_PROFILE:-neil-douglas-kuwboo}"
REGION="${AWS_REGION:-eu-west-2}"
RUNNER_URL="${RUNNER_URL:-https://runner.kuwboo.com}"
HOSTNAME="${RUNNER_URL#https://}"
HOSTNAME="${HOSTNAME%%/*}"

red()   { printf '\033[31m%s\033[0m\n' "$*"; }
green() { printf '\033[32m%s\033[0m\n' "$*"; }
blue()  { printf '\033[34m%s\033[0m\n' "$*"; }

fail() { red "❌ $*"; exit 1; }

blue "==> 1/4 healthz"
body=$(curl -fsS "$RUNNER_URL/healthz") || fail "healthz failed"
[[ "$body" == *'"ok":true'* ]] || fail "healthz returned: $body"
green "   $body"

blue "==> 2/4 unauthorized POST (expect 401)"
status=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$RUNNER_URL/internal/agent-runs")
[[ "$status" == "401" ]] || fail "expected 401, got $status"
green "   401 (auth enforced)"

blue "==> 3/4 TLS expiry"
expiry=$(echo | openssl s_client -connect "$HOSTNAME:443" -servername "$HOSTNAME" 2>/dev/null \
  | openssl x509 -noout -enddate | cut -d= -f2)
# Cross-platform date parsing: BSD date (macOS) needs -j, GNU date (Linux) uses -d.
if expiry_ts=$(date -j -f "%b %d %T %Y %Z" "$expiry" +%s 2>/dev/null); then :
else expiry_ts=$(date -d "$expiry" +%s); fi
days=$(( (expiry_ts - $(date +%s)) / 86400 ))
[[ $days -gt 7 ]] || fail "cert expires in $days days — run certbot"
green "   $days days remaining ($expiry)"

blue "==> 4/4 /smoke with bearer"
shared_secret=$(aws secretsmanager get-secret-value \
  --secret-id /kuwboo/slack-runner \
  --profile "$PROFILE" --region "$REGION" \
  --query SecretString --output text \
  | python3 -c 'import json,sys;print(json.load(sys.stdin)["shared_secret"])')

smoke_json=$(curl -fsS -H "Authorization: Bearer $shared_secret" "$RUNNER_URL/smoke") \
  || fail "/smoke returned non-2xx"

python3 <<PY
import json, sys
data = json.loads("""$smoke_json""")
ok = data.get("ok")
for c in data.get("checks", []):
    mark = "\033[32m✓\033[0m" if c["ok"] else "\033[31m✗\033[0m"
    tail = ""
    if c.get("detail"): tail = f" — {c['detail']}"
    elif c.get("error"): tail = f" — {c['error']}"
    print(f"   {mark} {c['name']:<17}{c['ms']:>5}ms{tail}")
sys.exit(0 if ok else 1)
PY

green "✅ smoke passed"
