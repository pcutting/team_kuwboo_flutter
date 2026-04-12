# Android Play Store Runbook

Operational runbook for shipping Kuwboo Android builds to the Play Store internal track. Mirrors the iOS `TESTFLIGHT_RUNBOOK.md` structure.

**Audience:** anyone who needs to push a new Android build, rotate signing material, or debug a failing CI run.

---

## One-line trigger (most common path)

Once GitHub Secrets are configured (see [First-time setup](#first-time-setup)):

```bash
gh workflow run android-play.yml --ref main -f environment=prod -f track=internal --repo pcutting/team_kuwboo
```

Check status:

```bash
gh run list --workflow=android-play.yml --repo pcutting/team_kuwboo --limit 3
gh run watch <run-id> --repo pcutting/team_kuwboo
```

On success, the build appears in **Play Console → Kuwboo → Testing → Internal testing** as a draft release. Review + promote to the track from the Play Console UI.

Expected runtime: ~6–9 minutes.

---

## Key facts

| Fact | Value |
|---|---|
| Package name | `com.kuwboo.mobile` |
| Play Console app ID | `TBD` — fill in after the app is created in Play Console |
| Workflow | `.github/workflows/android-play.yml` |
| Fastfile lane | `bundle exec fastlane internal` from `apps/mobile/android/` |
| Signing format | Android upload keystore (JKS), decoded from `ANDROID_KEYSTORE_BASE64` into a temp file on the runner |
| Upload auth | Play Developer API service account JSON, decoded from `ANDROID_PLAY_SERVICE_ACCOUNT_JSON_BASE64` |
| Runner | `ubuntu-latest` (iOS uses `macos-latest`; Android needs neither macOS nor Xcode) |
| Flutter on CI | **3.41.4** (same pin as iOS — must satisfy workspace Dart SDK `^3.11.1`) |
| Java on CI | **Temurin 17** (required by modern AGP) |
| Gradle signing | `apps/mobile/android/app/build.gradle.kts` reads env vars. Falls back to debug signing if absent so `flutter run --release` keeps working locally. |
| Artifact | `build/app/outputs/bundle/release/app-release.aab` (Android App Bundle — required by Play Store) |
| Play track | `internal` (4-step promotion path: internal → closed → open → production) |
| Release status | `draft` — a human must click Promote in Play Console. Change to `completed` in `Fastfile` if you want auto-publish. |

---

## Required GitHub Secrets

Set all of these before the first run. The workflow **will fail** with a clear error message on the first trigger if any is missing — that is expected during first-time setup.

| Secret | Purpose |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | `kuwboo-upload.jks` contents, base64-encoded (single line) |
| `ANDROID_KEYSTORE_PASSWORD` | Password for the keystore |
| `ANDROID_KEY_ALIAS` | Key alias inside the keystore (e.g. `kuwboo-upload`) |
| `ANDROID_KEY_PASSWORD` | Password for the private key (same as keystore by default when generated via our script) |
| `ANDROID_PLAY_SERVICE_ACCOUNT_JSON_BASE64` | Play Console service account JSON, base64-encoded |

Inspect / set:

```bash
gh secret list --repo pcutting/team_kuwboo
gh secret set ANDROID_KEYSTORE_BASE64 --repo pcutting/team_kuwboo < keystore.b64
gh secret set ANDROID_KEY_ALIAS --repo pcutting/team_kuwboo --body "kuwboo-upload"
```

---

## First-time setup

Do these in order. The whole process is ~30 minutes assuming a Play Console account already exists.

### 1. Generate the upload keystore

```bash
./scripts/generate-android-keystore.sh
```

The script creates:

- `keys/kuwboo-upload.jks` — the upload keystore (JKS format, 2048-bit RSA, 10000-day validity)
- `keys/.android_keystore_password.txt` — 32-char random password
- `keys/.android_key_alias.txt` — key alias (default `kuwboo-upload`)

All three are gitignored via the root `/keys/` rule.

At the end it prints ready-to-paste `gh secret set` commands for four of the five required secrets. Run them.

**Back up `keys/kuwboo-upload.jks` and the password somewhere safe** (1Password, etc.). If you lose them *and* haven't enrolled in Play App Signing, you cannot ship updates to the existing app. With Play App Signing (recommended, see next step), the upload key can always be reset via Play Console.

### 2. Enroll in Play App Signing (strongly recommended)

Play App Signing lets Google manage the actual app-signing key. You only hold an **upload** key, which can be reset via Play Console if lost — unlike the legacy model where losing the signing key was terminal.

- Create the app in Play Console: **All apps → Create app**. Package name: `com.kuwboo.mobile`.
- When first uploading an AAB, Play Console will ask how you want to sign. Choose **Google-generated key** (default) or upload your own. Either way, your `kuwboo-upload.jks` becomes the *upload* key.
- Note the Play Console app ID from the URL and fill it into this runbook.

### 3. Create a Play Developer API service account

This is what fastlane uses to authenticate when uploading the AAB.

1. **Play Console → Setup → API access → Choose a Google Cloud project → Create new service account** (opens Google Cloud Console in a new tab).
2. In Google Cloud Console: name it `kuwboo-play-ci`, click **Create and continue**. Grant it the **Service Account User** role. Click **Done**.
3. Click the newly-created service account → **Keys → Add key → Create new key → JSON**. Download to `keys/kuwboo-play-ci.json`.
4. Back in Play Console → API access → find the service account row → click **Grant access**. Select the Kuwboo app, grant **Admin (all permissions)** or specifically **Release manager** + **View app information**. Click **Invite user → Send invitation**.
5. Base64-encode and push to GitHub Secrets:

   ```bash
   gh secret set ANDROID_PLAY_SERVICE_ACCOUNT_JSON_BASE64 \
     --repo pcutting/team_kuwboo \
     --body "$(base64 < keys/kuwboo-play-ci.json | tr -d '\n')"
   ```

### 4. First upload must be manual

The Play Developer API cannot create the *first* release for an app — it can only upload additional releases to an app that already has a manual first release.

**For the very first release:**

1. Build an AAB locally:

   ```bash
   cd apps/mobile
   export ANDROID_KEYSTORE_PATH="$PWD/../../keys/kuwboo-upload.jks"
   export ANDROID_KEYSTORE_PASSWORD="$(cat ../../keys/.android_keystore_password.txt)"
   export ANDROID_KEY_PASSWORD="$ANDROID_KEYSTORE_PASSWORD"
   export ANDROID_KEY_ALIAS="$(cat ../../keys/.android_key_alias.txt)"
   flutter build appbundle --release
   ```

2. Upload `build/app/outputs/bundle/release/app-release.aab` manually via Play Console → Internal testing → Create new release.
3. Once that release exists, all subsequent releases can go through the CI workflow.

### 5. Run the workflow

```bash
gh workflow run android-play.yml --ref main -f environment=prod -f track=internal --repo pcutting/team_kuwboo
```

---

## Local release builds

For a local release build using the same signing material as CI:

Option A — env vars (matches CI):

```bash
cd apps/mobile
export ANDROID_KEYSTORE_PATH="$PWD/../../keys/kuwboo-upload.jks"
export ANDROID_KEYSTORE_PASSWORD="$(cat ../../keys/.android_keystore_password.txt)"
export ANDROID_KEY_PASSWORD="$ANDROID_KEYSTORE_PASSWORD"
export ANDROID_KEY_ALIAS="$(cat ../../keys/.android_key_alias.txt)"
flutter build appbundle --release
```

Option B — `key.properties` file (more convenient, **gitignored**):

```bash
cat > apps/mobile/android/key.properties <<EOF
storeFile=$PWD/keys/kuwboo-upload.jks
storePassword=$(cat keys/.android_keystore_password.txt)
keyAlias=$(cat keys/.android_key_alias.txt)
keyPassword=$(cat keys/.android_keystore_password.txt)
EOF
```

Then `flutter build appbundle --release` from `apps/mobile/` will pick it up.

If neither env vars nor `key.properties` is present, Gradle falls back to the debug signing config — useful for dev machines without distribution material.

---

## Upload key rotation

Unlike iOS Apple Distribution certs (which expire annually), Android upload keys **do not expire** — the validity on our keystore is ~27 years. However, you may want to rotate if:

- The keystore password is compromised.
- The keystore file is accidentally committed or leaked.
- A developer with access leaves the team.

### Rotation procedure (only works with Play App Signing enrolled)

1. Generate a new upload keystore:

   ```bash
   mv keys/kuwboo-upload.jks keys/kuwboo-upload.jks.OLD
   ./scripts/generate-android-keystore.sh
   ```

2. Extract the upload certificate from the new keystore:

   ```bash
   keytool -export -rfc \
     -keystore keys/kuwboo-upload.jks \
     -storepass "$(cat keys/.android_keystore_password.txt)" \
     -alias "$(cat keys/.android_key_alias.txt)" \
     -file keys/kuwboo-upload.pem
   ```

3. Play Console → App → **Setup → App integrity → App signing → Request upload key reset**. Upload `keys/kuwboo-upload.pem`. Google manually approves within ~48 hours.

4. Once approved, update the four GitHub Secrets (`ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`).

5. Delete `keys/kuwboo-upload.jks.OLD`.

**Without Play App Signing**, there is no rotation path — the key that signed the first release is the only key that can sign updates, forever. This is the primary reason to always enroll in Play App Signing.

---

## Service account key rotation

The Play Developer API service account JSON has no hard expiry but should be rotated if compromised or every 12 months as hygiene.

1. Google Cloud Console → IAM & Admin → Service Accounts → `kuwboo-play-ci` → Keys → Add key → Create new key (JSON). Download to `keys/kuwboo-play-ci.json` (overwrite).
2. Update the GitHub Secret:

   ```bash
   gh secret set ANDROID_PLAY_SERVICE_ACCOUNT_JSON_BASE64 \
     --repo pcutting/team_kuwboo \
     --body "$(base64 < keys/kuwboo-play-ci.json | tr -d '\n')"
   ```

3. In Google Cloud Console, delete the old key (Keys tab → three-dot menu → Delete).

---

## Troubleshooting

### "ANDROID_KEYSTORE_BASE64 secret is not set"

Expected on first run. Complete the [First-time setup](#first-time-setup) and retry.

### "keytool error: java.io.IOException: keystore password was incorrect"

Password mismatch between `ANDROID_KEYSTORE_PASSWORD` and what the keystore was created with. Re-set the secret from `keys/.android_keystore_password.txt`.

### "Package not found" from `upload_to_play_store`

The Play Developer API can't see the app. Either:
- The app hasn't been created in Play Console yet (see [First-time setup step 2](#2-enroll-in-play-app-signing-strongly-recommended)).
- The first release hasn't been uploaded manually yet (see [step 4](#4-first-upload-must-be-manual)).
- The service account doesn't have permissions on this app (Play Console → Users and permissions → check that `kuwboo-play-ci@*.iam.gserviceaccount.com` appears with Release manager or higher).

### "Version code X has already been used"

Play Store rejects AABs whose `versionCode` is ≤ the largest version code ever uploaded to *any* track. The workflow uses `GITHUB_RUN_NUMBER` as the build number (which becomes `versionCode` via Flutter's `--build-number`). If a manual upload pushed a higher number, pass an explicit override:

```bash
gh workflow run android-play.yml --ref main \
  -f environment=prod -f track=internal -f build_number=1000 \
  --repo pcutting/team_kuwboo
```

### AAB too large (>150 MB)

Play Store limits AABs to 150 MB. If exceeded, enable Play Asset Delivery for large assets, or split by ABI (`--split-per-abi`). Not expected for Kuwboo at current scope.

### Gradle says "SigningConfig has no storeFile"

Means the workflow env vars weren't propagated. Check the "Decode signing material and run Fastlane internal" step ran before the Fastlane step (they are the same step in this workflow — exports persist across the script).

---

## Why internal track only?

Mirrors the iOS TestFlight internal-only strategy:

- Internal track distributes to up to 100 testers instantly, no Play review required.
- Closed / open testing and production all require Play review (1–7 days) and cannot be turned into an iteration loop.
- Promotion from internal → production is a one-click step in Play Console when a build is ready.

When Kuwboo goes to production, either (a) extend this workflow with a `production` track choice and bump `release_status` to `completed`, or (b) keep CI on internal and always promote manually from Play Console (safer).

---

## References

- [Fastlane supply (upload_to_play_store) docs](https://docs.fastlane.tools/actions/upload_to_play_store/)
- [Play Developer API setup](https://developers.google.com/android-publisher)
- [Play App Signing overview](https://support.google.com/googleplay/android-developer/answer/9842756)
- iOS counterpart: [`TESTFLIGHT_RUNBOOK.md`](./TESTFLIGHT_RUNBOOK.md)
