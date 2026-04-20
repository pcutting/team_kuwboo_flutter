#!/usr/bin/env bash
# delete_user.ssm.sh — convenience wrapper: run delete_user.sh on the EC2
# instance via SSM from your Mac.
#
# WHY THIS EXISTS:
#   RDS is inside the VPC and not reachable from the developer Mac. The ops
#   script `delete_user.sh` must run on the API EC2 instance. This wrapper
#   base64-encodes the script body and the args, ships them via
#   `aws ssm send-command`, and streams the output back.
#
# USAGE:
#   bash delete_user.ssm.sh --by phone --value "+16142856112"
#   bash delete_user.ssm.sh --by phone --value "+16142856112" --confirm
#   bash delete_user.ssm.sh --by email --value "x@y.z" --confirm --allow-email-users
#
# All flags are forwarded verbatim to delete_user.sh.
#
# REQUIREMENTS (on your Mac):
#   - aws CLI with profile neil-douglas-kuwboo
#   - The companion file `delete_user.sh` sitting next to this file.

set -euo pipefail

INSTANCE_ID="${INSTANCE_ID:-i-0766e373b3147a2aa}"
AWS_PROFILE_NAME="${AWS_PROFILE:-neil-douglas-kuwboo}"
AWS_REGION_NAME="${AWS_REGION:-eu-west-2}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INNER_SCRIPT="${SCRIPT_DIR}/delete_user.sh"
[[ -r "$INNER_SCRIPT" ]] || { echo "ERROR: cannot read $INNER_SCRIPT" >&2; exit 1; }

# Forward all args to inner script, quoted.
INNER_ARGS=""
for a in "$@"; do
  # shell-quote each arg safely
  printf -v q '%q' "$a"
  INNER_ARGS+=" $q"
done

# Compose the remote invocation: decode the script to a temp file, then run it
# as ubuntu with the forwarded args.
SCRIPT_B64=$(base64 -i "$INNER_SCRIPT" | tr -d '\n')

REMOTE_CMD=$(cat <<REMOTE
set -euo pipefail
TMP=\$(mktemp /tmp/delete_user.XXXXXX.sh)
trap 'rm -f "\$TMP"' EXIT
echo '${SCRIPT_B64}' | base64 -d > "\$TMP"
chmod +x "\$TMP"
sudo -u ubuntu -H bash "\$TMP"${INNER_ARGS}
REMOTE
)

REMOTE_B64=$(printf '%s' "$REMOTE_CMD" | base64 | tr -d '\n')

echo "==> Sending SSM command to ${INSTANCE_ID} (profile=${AWS_PROFILE_NAME}, region=${AWS_REGION_NAME})"
CMD_ID=$(aws --profile "$AWS_PROFILE_NAME" --region "$AWS_REGION_NAME" \
  ssm send-command \
  --instance-ids "$INSTANCE_ID" \
  --document-name AWS-RunShellScript \
  --comment "delete_user.sh $*" \
  --parameters "commands=[\"echo ${REMOTE_B64} | base64 -d | bash\"]" \
  --query 'Command.CommandId' --output text)

echo "==> CommandId: $CMD_ID"
echo "==> Polling for completion..."

while true; do
  sleep 3
  STATUS=$(aws --profile "$AWS_PROFILE_NAME" --region "$AWS_REGION_NAME" \
    ssm get-command-invocation \
    --command-id "$CMD_ID" --instance-id "$INSTANCE_ID" \
    --query 'Status' --output text 2>/dev/null || echo "Pending")
  case "$STATUS" in
    Pending|InProgress|Delayed) printf '.'; continue ;;
    Success|Failed|Cancelled|TimedOut) echo; break ;;
    *) printf '.'; continue ;;
  esac
done

echo "==> Final status: $STATUS"
echo "==> --- stdout ---"
aws --profile "$AWS_PROFILE_NAME" --region "$AWS_REGION_NAME" \
  ssm get-command-invocation \
  --command-id "$CMD_ID" --instance-id "$INSTANCE_ID" \
  --query 'StandardOutputContent' --output text
echo "==> --- stderr ---"
aws --profile "$AWS_PROFILE_NAME" --region "$AWS_REGION_NAME" \
  ssm get-command-invocation \
  --command-id "$CMD_ID" --instance-id "$INSTANCE_ID" \
  --query 'StandardErrorContent' --output text

[[ "$STATUS" == "Success" ]] || exit 1
