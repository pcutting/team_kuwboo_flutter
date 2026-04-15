# TestFlight Runbook

**Last updated:** 2026-04-15
**Owner:** Philip Cutting (LionPro Dev)
**App:** Kuwboo Mobile (iOS)

This runbook covers everything needed to ship Kuwboo iOS builds to TestFlight.

> **New runbook location (2026-04-15):** day-to-day ship commands now live in the root `CLAUDE.md` under §"Deploying to TestFlight". iOS builds run locally, not in GitHub Actions, per the CI Offload Policy in `~/.claude/CLAUDE.md`. The hosted `ios-testflight.yml` and `ios-pr-validation.yml` workflows have been retired. This runbook retains the full one-time setup, signing background, and troubleshooting lessons.

---

## iOS 26 SDK migration (2026-04-15)

App Store Connect began emitting warning **ITMS-90725** ("SDK version issue") on uploads built with pre-iOS-26 SDKs, with a deadline of **2026-04-28** after which those uploads would be rejected. Kuwboo's hosted macOS CI runner did not yet have Xcode 26 available, so this triggered the move to local-only iOS builds.

The proven fix was local **Xcode 26.4** with the existing **Flutter 3.41.4** toolchain. No `pubspec.yaml`, `Podfile`, or deployment-target changes were required — the bump is purely in the build toolchain. Deployment target remains iOS 15.0.

Build **2604150937** was the first iOS 26 SDK upload and went through cleanly. It was produced from a clean `flutter clean && flutter pub get && pod install && bundle exec fastlane beta` run on the local Mac.

**Signing gotcha encountered during this migration.** The local login keychain accumulated two "Apple Distribution: Lion MGT LLC" certificates (the old one with SHA-1 `E7168B0FF8690BCF8099464BDB665F839B5933EE`, and the current one with SHA-1 `96CE08EF9B19A6E0CCAFC056614110177901E6CE` matching the active `keys/kuwboo_distribution.p12`). With two certs of the same Common Name present, xcodebuild picks the first one it finds, which is often the stale one. The archive step succeeds, but `-exportArchive` fails with the misleading error "Provisioning profile 'Kuwboo Mobile App Store' doesn't include signing certificate 'Apple Distribution: Lion MGT LLC'". The fix is to pin `signingCertificate` in `apps/mobile/ios/ExportOptions.plist` to the SHA-1 `96CE08EF9B19A6E0CCAFC056614110177901E6CE`. Alternative fix: open Keychain Access, filter "My Certificates" for "Apple Distribution", and delete the older duplicate so only the currently-active one remains.

---

## Key facts

| Item | Value |
|------|-------|
| Bundle ID | `com.kuwboo.mobile` |
| Apple Team ID | `5GQA38WHMY` (Lion MGT LLC) |
| App Store Connect Key ID | `3B764CRX7S` |
| App Store Connect Issuer ID | `6461be03-feb0-432f-9a9d-8e074ac2ffec` |
| Distribution certificate | Apple Distribution: Lion MGT LLC (SHA-1 `E7168B0FF8690BCF8099464BDB665F839B5933EE`, expires 2027-04-09) |
| Provisioning profile name | `Kuwboo Mobile App Store` (UUID `a404a1d7-40a7-492f-ad0f-6ba52007c03e`) |
| Minimum iOS version | 15.0 |
| Flutter version (CI) | 3.41.4 (must match the Dart SDK constraint `^3.11.1` in workspace pubspec.yaml) |
| Xcode version (CI) | Runner default (**do not pin** — pinning to 16.0 causes "iOS 18 not installed" errors; see Troubleshooting) |
| Signing style | **Manual**. Cert + profile are installed into a temp keychain by the workflow from GitHub Secrets. `ExportOptions.plist` uses `signingStyle=manual` with explicit `provisioningProfiles` mapping. |
| Upload auth | App Store Connect API key (`.p8`) — used by `upload_to_testflight` only, not during archive/export. |

---

## One-time setup

### 1. Apple Developer / App Store Connect

These must be done in a browser by a team admin:

1. **Confirm Apple Developer Program membership** is active (Guess This Ltd, team `5GQA38WHMY`)
2. **Register the Bundle ID** `com.kuwboo.mobile`:
   - Go to [developer.apple.com/account/resources/identifiers](https://developer.apple.com/account/resources/identifiers/list)
   - Click "+" → App IDs → App → Continue
   - Description: "Kuwboo Mobile"
   - Bundle ID: Explicit → `com.kuwboo.mobile`
   - Enable capabilities if needed (Push Notifications, Associated Domains, Sign in with Apple)
3. **Create the app in App Store Connect**:
   - Go to [appstoreconnect.apple.com/apps](https://appstoreconnect.apple.com/apps)
   - "+" → New App → iOS
   - Name: "Kuwboo"
   - Primary language: English (UK)
   - Bundle ID: select `com.kuwboo.mobile`
   - SKU: `kuwboo-mobile-ios` (or any unique string)
   - User Access: Full Access
4. **Complete the App Store Connect privacy questionnaire** (required before first TestFlight upload)
5. **Add internal TestFlight testers**:
   - App Store Connect → My Apps → Kuwboo → TestFlight → Internal Testing
   - Create a group, add team member Apple IDs

### 2. GitHub Secrets (8 total)

The GitHub Actions workflow needs 8 secrets. Manage them at:
**https://github.com/pcutting/team_kuwboo/settings/secrets/actions**

The `gh` CLI is the fastest way to set them (keeps sensitive values off the clipboard):

```bash
gh secret set <NAME> --repo pcutting/team_kuwboo --body "<value>"
# or from a file (stdin, never in argv):
gh secret set <NAME> --repo pcutting/team_kuwboo < path/to/file
```

| Secret name | Purpose | How to generate |
|-------------|---------|-----------------|
| `APPLE_KEY_ID` | App Store Connect API key ID | Hardcode: `3B764CRX7S` |
| `APPLE_ISSUER_ID` | App Store Connect issuer UUID | Hardcode: `6461be03-feb0-432f-9a9d-8e074ac2ffec` |
| `APPLE_TEAM_ID` | Apple Developer Team ID | Hardcode: `5GQA38WHMY` (currently unused by workflow but kept for completeness; also hardcoded in Appfile and ExportOptions.plist) |
| `APPLE_KEY_P8_BASE64` | App Store Connect API key (for `upload_to_testflight`) | `base64 -i keys/AuthKey_3B764CRX7S.p8` then upload via `gh secret set < file` |
| `APPLE_CERT_P12_BASE64` | Apple Distribution certificate + private key, PKCS#12 bundle | See [certificate generation](#generating-the-signing-cert-and-profile) |
| `APPLE_CERT_P12_PASSWORD` | Password for unlocking the `.p12` | Generated random 32-char string, stored in `keys/.p12_password.txt` for local reference |
| `APPLE_PROVISIONING_PROFILE_BASE64` | App Store provisioning profile (`.mobileprovision`) | See [certificate generation](#generating-the-signing-cert-and-profile) |
| `APPLE_PROVISIONING_PROFILE_UUID` | Profile UUID (used as the on-disk filename) | Hardcode: `a404a1d7-40a7-492f-ad0f-6ba52007c03e` |

> **All signing material lives in `keys/`** (gitignored via `/keys/` + extension patterns `*.p8 *.key *.cer *.p12 *.mobileprovision *.certSigningRequest`). Never commit anything from that directory.

### Generating the signing cert and profile

This is a one-time process (repeat annually when the cert expires). All output lands in `flutter/keys/`, which is gitignored.

**Step 1: Generate a CSR (Certificate Signing Request)**

```bash
cd /Users/philipcutting/Projects/clients/active/neil_douglas/flutter
mkdir -p keys && chmod 700 keys

openssl genrsa -out keys/kuwboo_distribution.key 2048
chmod 600 keys/kuwboo_distribution.key

openssl req -new \
  -key keys/kuwboo_distribution.key \
  -out keys/kuwboo_distribution.csr \
  -subj "/CN=Apple Distribution: Lion MGT LLC/O=Lion MGT LLC/C=US/emailAddress=your@email.com"
```

**Step 2: Upload the CSR to Apple Developer portal**

1. Go to https://developer.apple.com/account/resources/certificates/list
2. **Switch to the Lion MGT LLC team** in the top-right dropdown (critical — most common mistake is staying on a different team)
3. Click **"+"** → **Software** → **"Apple Distribution"** → Continue
4. Upload `keys/kuwboo_distribution.csr` → Continue → **Download** the resulting `distribution.cer`
5. Move it: `mv ~/Downloads/distribution.cer keys/`

**Step 3: Bundle cert + key into a `.p12` (with legacy encryption for macOS `security` compatibility)**

```bash
# Convert the DER cert to PEM
openssl x509 -in keys/distribution.cer -inform DER -out keys/distribution.pem -outform PEM

# Generate a random password and save it
openssl rand -hex 16 > keys/.p12_password.txt
chmod 600 keys/.p12_password.txt

# Create the .p12 with LEGACY encryption (PBE-SHA1-3DES + SHA1 MAC)
# macOS `security import` cannot read modern PBES2/AES-256 .p12 files,
# which is what openssl 3.x produces by default. The `-certpbe`, `-keypbe`,
# and `-macalg` flags force the old format that `security import` understands.
PASS=$(cat keys/.p12_password.txt)
openssl pkcs12 -export \
  -inkey keys/kuwboo_distribution.key \
  -in keys/distribution.pem \
  -name "Apple Distribution: Lion MGT LLC" \
  -out keys/kuwboo_distribution.p12 \
  -passout "pass:$PASS" \
  -certpbe PBE-SHA1-3DES \
  -keypbe PBE-SHA1-3DES \
  -macalg SHA1

# Verify it reads correctly with the tool CI will use
security create-keychain -p testpass /tmp/verify.keychain-db
security import keys/kuwboo_distribution.p12 -P "$PASS" -k /tmp/verify.keychain-db
security delete-keychain /tmp/verify.keychain-db
# Should print "1 identity imported."
```

**Step 4: Create the provisioning profile in Apple Developer portal**

1. Go to https://developer.apple.com/account/resources/profiles/list (switch to Lion MGT team)
2. **"+"** → Distribution → **App Store** → Continue
3. App ID: select `com.kuwboo.mobile` → Continue
4. Certificate: select the Apple Distribution cert you just created → Continue
5. Name: `Kuwboo Mobile App Store` → Generate → **Download**
6. Move it: `mv ~/Downloads/Kuwboo_Mobile_App_Store.mobileprovision keys/`

**Step 5: Upload everything to GitHub Secrets**

```bash
# Base64 files for secrets that need it
base64 -i keys/kuwboo_distribution.p12 > keys/kuwboo_distribution.p12.base64
base64 -i keys/Kuwboo_Mobile_App_Store.mobileprovision > keys/provisioning_profile.base64
base64 -i /path/to/AuthKey_3B764CRX7S.p8 > keys/apple_key_p8.base64

# Set secrets (from stdin to keep contents out of argv and shell history)
gh secret set APPLE_KEY_ID              --repo pcutting/team_kuwboo --body "3B764CRX7S"
gh secret set APPLE_ISSUER_ID           --repo pcutting/team_kuwboo --body "6461be03-feb0-432f-9a9d-8e074ac2ffec"
gh secret set APPLE_TEAM_ID             --repo pcutting/team_kuwboo --body "5GQA38WHMY"
gh secret set APPLE_KEY_P8_BASE64       --repo pcutting/team_kuwboo < keys/apple_key_p8.base64
gh secret set APPLE_CERT_P12_BASE64     --repo pcutting/team_kuwboo < keys/kuwboo_distribution.p12.base64
gh secret set APPLE_CERT_P12_PASSWORD   --repo pcutting/team_kuwboo --body "$(cat keys/.p12_password.txt)"
gh secret set APPLE_PROVISIONING_PROFILE_BASE64 --repo pcutting/team_kuwboo < keys/provisioning_profile.base64
gh secret set APPLE_PROVISIONING_PROFILE_UUID   --repo pcutting/team_kuwboo --body "a404a1d7-40a7-492f-ad0f-6ba52007c03e"

# Verify all 8 are set
gh secret list --repo pcutting/team_kuwboo
```

> **GitHub secrets are write-only.** You can see the name and last-updated time, but not the value. If you need to check a secret, rotate it by re-uploading.

**Do not commit anything from `keys/`.** The `.gitignore` excludes:
- `/keys/` directory (primary defense)
- `*.p8`, `*.key`, `*.cer`, `*.p12`, `*.mobileprovision`, `*.certSigningRequest` (extension safety net)

---

## Triggering a TestFlight build

### Option A: GitHub Actions (recommended)

1. Go to [Actions tab](https://github.com/pcutting/team_kuwboo/actions/workflows/ios-testflight.yml)
2. Click **"Run workflow"**
3. Choose:
   - **Environment**: `prod` (or `staging`)
   - **Build number**: leave blank for auto (uses GitHub run number)
4. Click "Run workflow"
5. Monitor the build (~15-25 min on `macos-latest`)
6. On success: build appears in App Store Connect → TestFlight within ~5 minutes (Apple processing)
7. Once Apple processing completes, add testers (if not already added to a group) and distribute

### Option B: Local Fastlane

On any Mac with the `.p8` file:

```bash
cd apps/mobile/ios
bundle install
export APP_STORE_CONNECT_API_KEY_ID=3B764CRX7S
export APP_STORE_CONNECT_API_ISSUER_ID=6461be03-feb0-432f-9a9d-8e074ac2ffec
export APP_STORE_CONNECT_API_KEY_CONTENT="$(cat /Users/philipcutting/Projects/clients/active/neil_douglas/AuthKey_3B764CRX7S.p8)"
export KUWBOO_ENV=prod
bundle exec fastlane beta
```

### Option C: Tag-triggered release

```bash
git tag ios-v1.0.0
git push origin ios-v1.0.0
```

This triggers the `push` tag filter in `.github/workflows/ios-testflight.yml`.

---

## Version and build number strategy

| Field | Source | Format |
|-------|--------|--------|
| `CFBundleShortVersionString` (marketing version) | `pubspec.yaml` `version:` field (before `+`) | `1.0.0` |
| `CFBundleVersion` (build number) | `GITHUB_RUN_NUMBER` in CI, timestamp locally | Integer, monotonic |

To bump the marketing version before a release:

```yaml
# apps/mobile/pubspec.yaml
version: 1.0.0
```

The build number auto-increments on every GitHub Actions run. If you need to reset it (e.g., after a marketing version bump), pass `build_number` explicitly when triggering the workflow.

---

## Troubleshooting

### Hard-won lessons from the initial setup debug session (2026-04-09)

The first TestFlight build took **8+ workflow runs** to get green. Each fix unblocked the next hidden error. The list below captures every non-obvious gotcha so future runs don't re-learn these the hard way. They are listed in the order they were encountered during debug; earlier items are also earlier in the CI pipeline.

> **Meta-lesson**: when Flutter's iOS tooling prints a "No valid code signing certificates" or "Development Team missing" error, **do not trust that message at face value**. Both are fallback messages printed whenever something upstream fails silently. Always get the verbose output (`flutter -v build ipa` or add `-v` to the Fastfile's `sh(...)` calls) to find the real error, which is typically hidden earlier in the xcodebuild stderr.

#### 1. `flutter pub get` fails: "Dart SDK version is X, kuwboo_workspace requires ^3.11.1"

**Cause:** The workflow pins `FLUTTER_VERSION`, but the pinned version ships with a Dart SDK older than the workspace `pubspec.yaml` constraint.

**Fix:** Set `FLUTTER_VERSION` to a Flutter release whose bundled Dart satisfies the constraint. For `sdk: ^3.11.1`, that's Flutter 3.41.x or newer. For reproducibility, pin to an exact minor version that matches local dev.

```yaml
# .github/workflows/ios-testflight.yml
env:
  FLUTTER_VERSION: "3.41.4"  # Dart 3.11.1 — must satisfy workspace ^3.11.1 constraint
```

Run `flutter --version` locally and use that exact version on CI.

#### 2. `security import` fails with "MAC verification failed during PKCS12 import (wrong password?)"

**Cause:** This error is **misleading**. The password is actually correct. The real issue is that `openssl pkcs12 -export` in OpenSSL 3.x / LibreSSL 3.x on macOS defaults to the modern PBES2 + AES-256-CBC encryption format, which Apple's `security` command cannot read. The MAC verification error is `security`'s generic "I can't parse this .p12" response.

**Fix:** Always generate `.p12` files with legacy encryption:

```bash
openssl pkcs12 -export \
  -inkey keys/kuwboo_distribution.key \
  -in keys/distribution.pem \
  -out keys/kuwboo_distribution.p12 \
  -passout "pass:$PASS" \
  -certpbe PBE-SHA1-3DES \
  -keypbe PBE-SHA1-3DES \
  -macalg SHA1
```

**Verification:** Always test the `.p12` against `security import` on a throwaway keychain **before** uploading to GitHub Secrets:

```bash
security create-keychain -p test /tmp/test.keychain-db
security import keys/kuwboo_distribution.p12 -P "$PASS" -k /tmp/test.keychain-db
security delete-keychain /tmp/test.keychain-db
# Should print: "1 identity imported."
```

Do not use `openssl pkcs12 -passout file:path` — its behavior is inconsistent across openssl versions (some read the whole file including the trailing newline as the password, others stop at the first newline). Always use `-passout "pass:$VAR"` with the literal string.

#### 3. CI step A correctly sets the keychain, but CI step B doesn't see it

**Symptom:** `Install Apple signing certificate` step logs `1 valid identities found`, but the next step (`Run Fastlane beta`) errors with "No valid code signing certificates".

**Initial (wrong) diagnosis:** macOS `cfprefsd` caching. Tempting theory; not correct.

**Real cause:** Flutter's `xcodebuild -showBuildSettings` call was failing for a completely different reason (iOS SDK missing — see #4), returning an empty `buildSettings` map. Flutter's `_missingDevelopmentTeam` helper then checked the empty map for `DEVELOPMENT_TEAM`, found nothing, and printed its generic "no dev team" fallback. The keychain was fine all along.

**How to tell:** Add a diagnostic step before the failing one that runs `security list-keychains -d user`, `security default-keychain -d user`, and `security find-identity -p codesigning -v`. If these show the cert, the state IS persisted — look elsewhere for the real error.

**Real fix:** See #4 below. The Flutter/keychain interaction is fine; fixing the upstream xcodebuild error made all the "keychain invisible" symptoms disappear.

#### 4. ★ The big one: "iOS 18.0 is not installed" — hidden behind every other error

**Symptom(s) (all misleading):**
- Flutter: "No valid code signing certificates were found"
- Flutter: "Building a deployable iOS app requires a selected Development Team"
- Fastlane summary: "`Xcode archive done. 2.3s`" (impossibly fast; actually a 2-second fail)

**How to find the real error:** Add `-v` to `flutter build ipa` in the Fastfile. This disables xcpretty filtering and dumps raw xcodebuild stderr. The actual error is:

```
xcodebuild: error: Could not configure request to show build settings:
Unable to find a destination matching the provided destination specifier:
{ platform:iOS, id:dvtdevice-DVTiPhonePlaceholder-iphoneos:placeholder,
  name:Any iOS Device,
  error:iOS 18.0 is not installed. To use with Xcode, first download and install the platform }
```

**Cause:** The workflow pinned `XCODE_VERSION: "16.0"` and selected `/Applications/Xcode_16.0.app`. Xcode 16.0 defaults to iOS 18.0 SDK for device builds (`generic/platform=iOS` → "Any iOS Device"), but **GitHub's macOS runners ship Xcode 16.0 without iOS 18.0 pre-installed**. Every `xcodebuild -showBuildSettings` failed at destination resolution, returning empty build settings, and all downstream errors (dev team, signing, etc.) were fallback messages printed when Flutter couldn't find `DEVELOPMENT_TEAM` in the empty settings map.

**Fix:** Don't pin Xcode. Let the runner use its default Xcode, which ships with matching SDKs pre-installed. On `macos-latest` in April 2026 that was Xcode 16.4 + iOS 18.5 SDK.

```yaml
# .github/workflows/ios-testflight.yml
env:
  FLUTTER_VERSION: "3.41.4"
  # Do NOT pin XCODE_VERSION — let the runner use its default Xcode.
  # Pinning to Xcode 16.0 selects an Xcode whose default iOS SDK (18.0)
  # is not pre-installed on GitHub runners, causing silent xcodebuild
  # failures that cascade into misleading Flutter error messages.
```

If you must pin Xcode for reproducibility, verify the SDK is available first by adding a diagnostic step:

```yaml
- name: Log Xcode + iOS SDK versions
  working-directory: .
  run: |
    ls -1 /Applications | grep -i "^Xcode"
    xcode-select -p
    xcodebuild -version
    xcodebuild -showsdks | grep -iE "iOS|iphoneos"
    xcrun simctl list runtimes | grep -i iOS
```

This step is already in the workflow as of PR #43. Check its output whenever a new class of iOS build error appears on CI.

#### 5. Flutter's codesign preflight regex only matches "Develop(ment|er)" CNs

**Symptom:** Even with a valid Apple Distribution cert in the keychain and `DEVELOPMENT_TEAM` properly set in the project, `flutter build ipa` prints "No valid code signing certificates were found" and aborts.

**Cause:** Flutter 3.41.4's `packages/flutter_tools/lib/src/ios/code_signing.dart` has this filter:

```dart
final _securityFindIdentityDeveloperIdentityExtractionPattern = RegExp(
  r'^\s*\d+\).+"(.+Develop(ment|er).+)"$',
);
```

The regex only matches certificate Common Names containing `"Develop(ment|er)"`. Apple **Distribution** certs (CN = `"Apple Distribution: ..."`) never match, so Flutter's preflight list is always empty for distribution-only signing setups.

There's an early-exit in `getCodeSigningIdentityDevelopmentTeamBuildSetting` that skips this check if `buildSettings['DEVELOPMENT_TEAM']` is non-empty — but if the `xcodebuild -showBuildSettings` call that populates that map fails (as in #4), the early-exit never fires and the broken regex bites.

**Fix:** Bypass the preflight entirely with `--no-codesign`. Flutter treats this as "don't try to sign", passes `CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGNING_IDENTITY=""` to xcodebuild during archive, and skips its own preflight. The archive is produced unsigned, and we then sign it with a separate `xcodebuild -exportArchive` call.

This is the pattern in our `Fastfile`:

```ruby
# Step 1: Flutter compiles Dart + archives WITHOUT signing
sh("flutter build ipa --release --no-codesign " \
   "--build-number=#{build_number} " \
   "--dart-define=KUWBOO_ENV=#{kuwboo_env}")

# Step 2: Sign and export the unsigned xcarchive with xcodebuild directly
sh("xcodebuild -exportArchive " \
   "-archivePath '#{archive_path}' " \
   "-exportPath '#{export_dir}' " \
   "-exportOptionsPlist '#{export_plist}' " \
   "-allowProvisioningUpdates")
```

> **Do not "fix" this by changing `CODE_SIGN_IDENTITY` in `project.pbxproj`**. We tried this (sedding "iPhone Developer" → "Apple Distribution"); it doesn't help because Flutter's preflight regex is applied to `security find-identity` output, not to the project setting.

#### 6. `xcodebuild -exportArchive` fails: "No Accounts" / "No profiles for 'com.kuwboo.mobile' were found"

**Cause:** `ExportOptions.plist` had `signingStyle: automatic`. With automatic signing, xcodebuild ignores pre-installed provisioning profiles and tries to fetch them fresh from Apple. On a CI runner there's no logged-in Apple ID and no API key passed via command-line auth flags, so Apple authentication fails and no profile is found.

**Fix:** Use **manual** signing in `ExportOptions.plist` with an explicit `provisioningProfiles` dict:

```xml
<key>signingStyle</key>
<string>manual</string>
<key>signingCertificate</key>
<string>Apple Distribution</string>
<key>provisioningProfiles</key>
<dict>
    <key>com.kuwboo.mobile</key>
    <string>Kuwboo Mobile App Store</string>
</dict>
```

With manual signing, xcodebuild reads the profile by name from the local profiles directory and uses the cert from the temporary keychain. No cloud authentication is required during export. The App Store Connect API key (`.p8`) is only needed later, in `upload_to_testflight`, which uses it over HTTPS to push the finished `.ipa` to Apple.

**The profile name must exactly match** what you named it when creating the profile in the Apple Developer portal (case-sensitive, spaces matter). You can also reference the profile by UUID instead of name if you prefer — both work.

#### 7. Root `.gitignore` has `*.lock` which blocks `Podfile.lock` and `pubspec.lock`

**Cause:** Broad `*.lock` pattern catches everything.

**Impact:** CocoaPods and Dart pub can resolve to slightly different versions on CI vs local, because CI has to re-resolve from scratch every time.

**Fix (not yet applied):** Add explicit exception lines:
```
!apps/mobile/ios/Podfile.lock
!**/pubspec.lock
```

This was flagged during the debug session but deferred. Do it when you get a chance — it'll make CI builds more reproducible.

---

### Common recurring issues

### "Build number already used" error from Apple

Apple requires strictly increasing build numbers. Options:
1. Re-run the workflow (GitHub run number will be higher)
2. Manually specify a higher build number when triggering the workflow
3. If you've exhausted the range, bump the marketing version in `pubspec.yaml`

### `pod install` fails on CI

Usually a transient CocoaPods CDN issue. Re-run the workflow. If persistent:
- Clear the CocoaPods cache: add `pod cache clean --all` to the workflow
- Pin the CocoaPods version in `ios/Gemfile`

### Export compliance banner on TestFlight

Info.plist sets `ITSAppUsesNonExemptEncryption=false` because the app only uses standard HTTPS. This avoids the manual compliance questionnaire. If you add custom encryption (e.g., for E2E messaging), you must:
1. Change this to `true` in `Info.plist`
2. Complete the export compliance questionnaire in App Store Connect
3. Potentially file an annual self-classification report with BIS

### App rejected for privacy string

Review `ios/Runner/Info.plist` — every permission the app requests must have a usage description. The current set covers:
- Camera, Microphone, Photo Library (read + add)
- Location (when in use)
- Contacts
- User Tracking (iOS 14.5+)
- Face ID

If you add a new plugin that requests something else (HealthKit, Bluetooth, Motion, Calendar, Reminders, HomeKit, etc.), add the corresponding `NS*UsageDescription` key.

### TestFlight build stuck "Processing" for over an hour

Normal processing is 5-15 min. Over an hour usually means:
- Missing export compliance info (check the build in App Store Connect)
- Missing required icon size (check `ios/Runner/Assets.xcassets/AppIcon.appiconset/`)
- Invalid bitcode (we disable bitcode in ExportOptions.plist, should be fine)

Check the App Store Connect → TestFlight → Builds page for specific warnings.

---

## Security notes

- **The `.p8` file is a private key** with significant privileges. Anyone with it can upload builds, read app data, and manage certificates.
- **Only store it in:**
  1. The original download location on the owner's Mac (never shared)
  2. GitHub Secrets (encrypted at rest, only decrypted at workflow runtime)
- **Rotate the key** from App Store Connect → Users & Access → Keys if it's ever been exposed in a log, chat, or commit.
- **The key has no expiry** — rotate annually as good hygiene.
- **`.gitignore` blocks `*.p8` files** at the repo root to prevent accidents.

---

## Next steps after first TestFlight build

1. [ ] First build uploaded and visible in App Store Connect
2. [ ] Complete privacy questionnaire
3. [ ] Add internal testers
4. [ ] Install Kuwboo from TestFlight on a physical iPhone
5. [ ] Test the full sign-up flow
6. [ ] Test each feature (video, social, shop, yoyo)
7. [ ] Submit for external TestFlight review (if beta will include non-team members)
8. [ ] Prepare App Store listing assets (screenshots, description, keywords)
