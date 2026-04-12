#!/usr/bin/env bash
#
# generate-android-keystore.sh
#
# Creates a reproducible Android upload keystore for Play Store signing.
#
# Outputs (all gitignored, under <repo-root>/keys/):
#   kuwboo-upload.jks                    Android keystore (JKS format)
#   .android_keystore_password.txt       Keystore + key password (32 chars)
#   .android_key_alias.txt               Key alias (default: kuwboo-upload)
#
# At the end, prints the `gh secret set` commands to wire the keystore into CI.
#
# Usage:
#   ./scripts/generate-android-keystore.sh
#
# Requires: keytool (bundled with JDK 17+), openssl.

set -euo pipefail

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
REPO_ROOT="$( cd -- "$SCRIPT_DIR/.." &> /dev/null && pwd )"
KEYS_DIR="$REPO_ROOT/keys"

KEYSTORE_PATH="$KEYS_DIR/kuwboo-upload.jks"
PASSWORD_FILE="$KEYS_DIR/.android_keystore_password.txt"
ALIAS_FILE="$KEYS_DIR/.android_key_alias.txt"
KEY_ALIAS="${KEY_ALIAS:-kuwboo-upload}"

command -v keytool >/dev/null 2>&1 || { echo "error: keytool not on PATH. Install JDK 17+." >&2; exit 1; }
command -v openssl >/dev/null 2>&1 || { echo "error: openssl not on PATH." >&2; exit 1; }

mkdir -p "$KEYS_DIR"

if [ -f "$KEYSTORE_PATH" ]; then
  echo "refusing to overwrite existing keystore at $KEYSTORE_PATH"
  echo "move or delete it first if you really want to rotate."
  exit 1
fi

# 32-char URL-safe password
PASSWORD="$(openssl rand -base64 32 | tr -d '=+/' | cut -c1-32)"

echo "Generating upload keystore at $KEYSTORE_PATH"
echo "Alias: $KEY_ALIAS"
echo ""

# Non-interactive keytool run. 10000 days ~ 27 years (Play requires 25+).
# DName can be adjusted, but values don't need to match real metadata for
# upload-only keys when using Play App Signing.
keytool -genkeypair \
  -v \
  -keystore "$KEYSTORE_PATH" \
  -storetype JKS \
  -storepass "$PASSWORD" \
  -keypass "$PASSWORD" \
  -alias "$KEY_ALIAS" \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -dname "CN=Kuwboo, OU=Mobile, O=Guess This Ltd, L=London, ST=England, C=GB"

# Save companion metadata (gitignored by /keys/ rule)
printf '%s' "$PASSWORD" > "$PASSWORD_FILE"
printf '%s' "$KEY_ALIAS" > "$ALIAS_FILE"
chmod 600 "$PASSWORD_FILE" "$ALIAS_FILE" "$KEYSTORE_PATH"

echo ""
echo "=== Keystore fingerprint (share with Play Console / back up somewhere safe) ==="
keytool -list -v -keystore "$KEYSTORE_PATH" -storepass "$PASSWORD" -alias "$KEY_ALIAS" \
  | grep -E "SHA1:|SHA256:|Valid from:" || true

# Base64-encode for GitHub Secret (single line; no platform-specific flags)
KEYSTORE_B64="$(base64 < "$KEYSTORE_PATH" | tr -d '\n')"

cat <<EOF

=======================================================================
Keystore ready. Now wire the following into GitHub Secrets.

Set these from this machine (requires gh auth login):

  gh secret set ANDROID_KEYSTORE_BASE64 --repo pcutting/team_kuwboo --body "\$(base64 < "$KEYSTORE_PATH" | tr -d '\\n')"
  gh secret set ANDROID_KEYSTORE_PASSWORD --repo pcutting/team_kuwboo --body "$PASSWORD"
  gh secret set ANDROID_KEY_PASSWORD --repo pcutting/team_kuwboo --body "$PASSWORD"
  gh secret set ANDROID_KEY_ALIAS --repo pcutting/team_kuwboo --body "$KEY_ALIAS"

Still to do (one-time) — Play Console service account JSON:

  1. Go to Play Console -> Setup -> API access -> Create new service account.
  2. In Google Cloud, grant the service account the Service Account User role
     and download the JSON key to $KEYS_DIR/kuwboo-play-ci.json.
  3. In Play Console -> Users and permissions, invite the service account
     email with "Release manager" permissions for the app.
  4. Then run:

       gh secret set ANDROID_PLAY_SERVICE_ACCOUNT_JSON_BASE64 \\
         --repo pcutting/team_kuwboo \\
         --body "\$(base64 < $KEYS_DIR/kuwboo-play-ci.json | tr -d '\\n')"

See docs/team/internal/ANDROID_PLAY_RUNBOOK.md for full context.
=======================================================================
EOF
