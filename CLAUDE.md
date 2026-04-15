# team_kuwboo — Monorepo Instructions

Instructions for AI agents (Claude, Cursor, etc.) working in this repository.

## What this repo is

Kuwboo multi-platform app monorepo. Flutter for mobile (iOS + Android), NestJS for the backend API, and shared packages. Managed with Melos + pub workspaces. Primary active product is the Flutter mobile app shipping to TestFlight.

| Path | Purpose | Deploy |
|---|---|---|
| `apps/mobile/` | Flutter iOS + Android app (**primary focus**) | iOS: local `fastlane beta`; Android: `android-play.yml` |
| `apps/api/` | NestJS backend | EC2 (`35.177.230.139`, eu-west-2) |
| `apps/admin/` | React 19 + Vite SPA (client-side only) | Vercel static — `team_kuwboo_admin` |
| `apps/web/` | Flutter web prototype + design viewer | Vercel static — `team_kuwboo_flutter` (prebuilt `build/web`) |
| `packages/kuwboo_shell/` | Shared theme, scaffold, nav, state providers | — |
| `packages/kuwboo_screens/` | Shared feature screens (yoyo, video, dating, social, shop, profile, sponsored) | — |
| `packages/kuwboo_chat/` | Shared chat module (inbox, conversation, card atom) | — |
| `packages/kuwboo_auth/` | Shared auth screens (welcome, OTP, signup, etc.) | — |
| `packages/models/` | Shared data models | — |
| `packages/api_client/` | Dio HTTP client + auth interceptor | — |
| `docs/` | Project documentation — see `docs/README.md` for the index | — |
| `keys/` | **Gitignored.** Local Apple signing material (`.p12`, `.mobileprovision`, `.key`, CSR, password). Never commit. | — |
| `.github/workflows/` | CI — Android only (`android-play.yml`). iOS ships locally per CI Offload Policy (see `~/.claude/CLAUDE.md`). | — |

### Archived features

- **Inner Circle** (family-tracking mode, pending $66K SOW, ~1yr horizon) — archived 2026-04-14. Full source + screenshots + restoration recipe in [`docs/team/internal/inner_circle_archive/`](docs/team/internal/inner_circle_archive/README.md). Do not reintroduce `YoyoState.mode`, `inner_circle_*` files, or `DemoFamilyMember` without reading that archive first — they were deliberately removed from `packages/`.

### Deployment architecture (read this before suggesting SSR/Functions/middleware)

All web hosting is **static on Vercel**. No SSR, no Next.js, no Vercel Functions, no middleware, no edge compute in this repo today.
- `apps/web` — prebuilt Flutter web bundle; root `vercel.json` has empty `buildCommand` and serves `apps/web/build/web`.
- `apps/admin` — Vite SPA; Vercel builds from source with the project's root dir set to `apps/admin`.
- `apps/api` — NestJS on EC2 (PM2 + Nginx). Not on Vercel.

If the current task involves server rendering, API routes, or middleware, **stop and confirm with the user** — that's a deliberate architectural change, not an extension of what's here.

#### Vercel project reference

| Project | ID | Prod URL |
|---|---|---|
| `team_kuwboo_flutter` | `prj_MDdvTr6oesYSHnX0ftH1KFXOSNiB` | https://teamkuwbooflutter.vercel.app |
| `team_kuwboo_admin` | `prj_VsJKIEkqT1F2WojX4bzGprfY1lQb` | https://teamkuwbooadmin.vercel.app |

Scope: `cuttingphilipgmailcoms-projects` · Org ID: `team_TW4qL9Ys2A7v8aNY4EH3Jic0` · Auth: `cuttingphilip@gmail.com` Google SSO.

Both apps are CLI-linked (`.vercel/project.json` gitignored). Run `vercel env pull`, `vercel logs <url>`, etc. from inside `apps/web/` or `apps/admin/`. Deploys happen automatically via the Vercel ↔ GitHub App integration — do not run `vercel deploy` manually unless instructed.

## Critical conventions

### PR-driven development
**Every change goes through a pull request.** No direct pushes to `main`. Branch → commit → push → `gh pr create` → merge (squash) → delete branch. See the parent workspace `CLAUDE.md` for the full rule.

### No AI attribution in commits or code
**Never include** markers identifying automated tools, "Generated", or "Co-Authored-By" tool tags in commits, code, comments, or PR descriptions. Use professional, human-authored voice. A pre-commit hook rejects commits containing such references.

### Flutter CI is stricter than local `flutter analyze`
**Before pushing any Flutter change, run in `apps/mobile/`:**
```bash
dart fix --apply
flutter analyze --fatal-infos
```
Local `flutter analyze` reports info-level lints but exits 0, so "No issues found" is misleading. `dart fix --apply` auto-resolves virtually all of them. Burned on PR #54 (one lint) and PR #66 (16 lints → PR #67 cleanup). The same discipline applies before a local `fastlane beta` — a failed `flutter build ipa` eats 5+ minutes and the fix is usually one `dart fix --apply` run away.

### Reproducibility
- `pubspec.lock` and `Podfile.lock` are **tracked** (re-included from the broad `*.lock` gitignore pattern via negation rules)
- Flutter is pinned to **3.41.4** locally and in `.github/workflows/android-play.yml` — this must satisfy the workspace Dart SDK constraint `^3.11.1`. Bumping Flutter requires checking Dart SDK compatibility first.
- iOS builds run on the local developer Mac (Xcode 26+). Android continues on Linux CI. Per the CI Offload Policy in `~/.claude/CLAUDE.md`, native Mac builds are not run on hosted runners.

### Signing material is local only
- Apple Distribution cert, provisioning profile, API key — all live in `keys/` (gitignored)
- **Never** commit `.p8`, `.key`, `.cer`, `.p12`, `.mobileprovision`, or `.certSigningRequest` files (all are in `.gitignore` as extension patterns)
- Rotation procedure is fully automated via the App Store Connect API — see `docs/team/internal/TESTFLIGHT_RUNBOOK.md`

## Deploying to TestFlight

iOS ships from the local developer Mac via `fastlane beta`. Hosted iOS CI was retired on 2026-04-15 per the CI Offload Policy (`~/.claude/CLAUDE.md`). The full runbook lives at [`docs/team/internal/TESTFLIGHT_RUNBOOK.md`](docs/team/internal/TESTFLIGHT_RUNBOOK.md) — read the "iOS 26 SDK migration" section at the top of that doc before the first local build.

### Prerequisite

Xcode 26+ installed locally (App Store Connect now rejects builds compiled with older SDKs — deadline was 2026-04-28, warning 90725).

### One-time keychain prep

```bash
security import keys/kuwboo_distribution.p12 \
  -k ~/Library/Keychains/login.keychain-db \
  -P "$(cat keys/.p12_password.txt)" \
  -T /usr/bin/codesign -T /usr/bin/security -T /usr/bin/xcodebuild
```

### One-time profile install

```bash
UUID=$(security cms -D -i keys/Kuwboo_Mobile_App_Store.mobileprovision | plutil -extract UUID raw -)
cp keys/Kuwboo_Mobile_App_Store.mobileprovision \
  "$HOME/Library/MobileDevice/Provisioning Profiles/$UUID.mobileprovision"
```

### Ship command

```bash
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export APP_STORE_CONNECT_API_KEY_ID=3B764CRX7S
export APP_STORE_CONNECT_API_ISSUER_ID=6461be03-feb0-432f-9a9d-8e074ac2ffec
export APP_STORE_CONNECT_API_KEY_CONTENT="$(cat /Users/philipcutting/Projects/clients/active/neil_douglas/AuthKey_3B764CRX7S.p8)"
cd apps/mobile/ios && bundle exec fastlane beta
```

Build appears in App Store Connect → Kuwboo Mobile → TestFlight within ~5 minutes of the lane finishing.

### Key facts for iOS deployment

| Fact | Value |
|---|---|
| Bundle ID | `com.kuwboo.mobile` |
| Apple Team ID | `5GQA38WHMY` (Lion MGT LLC) |
| App Store Connect app ID | `6761923318` (name: "Kuwboo Mobile") |
| Active cert SHA-1 | `96CE08EF9B19A6E0CCAFC056614110177901E6CE` (matches `keys/kuwboo_distribution.p12`) |
| Active profile | `keys/Kuwboo_Mobile_App_Store.mobileprovision` |
| Fastfile lane | `bundle exec fastlane beta` from `apps/mobile/ios/` |
| Signing | Manual — cert + profile installed into the login keychain once; `ExportOptions.plist` pins the cert SHA-1 |
| Upload auth | App Store Connect API key `.p8` (Key ID `3B764CRX7S`, Issuer ID `6461be03-feb0-432f-9a9d-8e074ac2ffec`) |

The older GitHub Secrets (`APPLE_KEY_ID`, `APPLE_ISSUER_ID`, `APPLE_KEY_P8_BASE64`, `APPLE_CERT_P12_BASE64`, `APPLE_CERT_P12_PASSWORD`, `APPLE_PROVISIONING_PROFILE_BASE64`, `APPLE_PROVISIONING_PROFILE_UUID`, `APPLE_TEAM_ID`) are no longer referenced by any workflow after this retirement. They can be deleted from the repo once the stale `Flutter analyze + iOS simulator build` branch-protection required check is cleared.

Cert rotation (emergency or annual renewal) is a fully automated Python script that runs against the App Store Connect API. See the runbook's "Emergency cert rotation" section.

## Deploying to Play Store (Android)

### One-line trigger

```bash
gh workflow run android-play.yml --ref main -f environment=prod -f track=internal --repo pcutting/team_kuwboo
```

Wait ~6-9 minutes. Build appears in Play Console → Kuwboo → Testing → Internal testing as a draft release (promote manually).

### Key facts for Android deployment

| Fact | Value |
|---|---|
| Package name | `com.kuwboo.mobile` (matches iOS bundle ID) |
| Workflow | `.github/workflows/android-play.yml` |
| Fastfile lane | `bundle exec fastlane internal` from `apps/mobile/android/` |
| Runner | `ubuntu-latest` (no macOS needed) |
| Java | Temurin 17 |
| Flutter | 3.41.4 (same pin as iOS) |
| Signing | Upload keystore (JKS) decoded from `ANDROID_KEYSTORE_BASE64` into a temp file |
| Upload auth | Play Developer API service account JSON |
| Track | `internal` (promote to production manually from Play Console) |
| Artifact | AAB (Android App Bundle) at `build/app/outputs/bundle/release/app-release.aab` |

### GitHub Secrets required by the workflow

| Secret | Purpose |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | Upload keystore (`.jks`) contents, base64 |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password |
| `ANDROID_KEY_ALIAS` | Key alias inside the keystore |
| `ANDROID_KEY_PASSWORD` | Key password (same as keystore when generated via our script) |
| `ANDROID_PLAY_SERVICE_ACCOUNT_JSON_BASE64` | Play Console service account JSON, base64 |

See [`docs/team/internal/ANDROID_PLAY_RUNBOOK.md`](docs/team/internal/ANDROID_PLAY_RUNBOOK.md) for first-time setup (keystore generation via `scripts/generate-android-keystore.sh`, Play Console service account creation, Play App Signing enrollment, and rotation procedures).

**First-run note:** The Play Developer API cannot create the very first release for an app. Upload one AAB manually via Play Console before the CI workflow can succeed. The runbook covers this in detail.

## Backend deployment

See `docs/team/internal/INFRASTRUCTURE.md` for AWS resource inventory and backend deployment procedures.

## Useful commands reference

```bash
# Branch and commit
git checkout main && git pull origin main --ff-only
git checkout -b type/short-description
# ... edit ...
git add <specific files>  # not 'git add .' — avoid accidentally including gitignored things
git commit -m "type(scope): description"
git push -u origin type/short-description
gh pr create --repo pcutting/team_kuwboo --title "..." --body "..."

# Merge (only after review)
gh pr merge <N> --repo pcutting/team_kuwboo --squash --delete-branch

# iOS local flutter
cd apps/mobile
flutter pub get
flutter run -d "iPhone 15 Pro"

# iOS local ship to TestFlight (see "Deploying to TestFlight" above for env vars)
cd apps/mobile/ios && bundle exec fastlane beta
```

## Common traps

- **`git add .` is dangerous here** — the `keys/` folder has signing material. Always `git add` specific files.
- **The workspace root `pubspec.lock` is the authoritative lock file**. Don't generate lock files in individual packages.
- **CocoaPods Podfile.lock is tracked** (explicit negation of the broad `*.lock` pattern). Commit it when it changes.
- **Lock file changes need a matching pod/pub run** — if you bump a dependency, run `pub get` and `pod install` locally and commit both lock files together.
- **Don't modify `apps/mobile/ios/Runner.xcodeproj/project.pbxproj`** unless you know what you're doing. The "iPhone Developer" → "Apple Distribution" rename we did during the debug session was a red herring fix that didn't actually help; if you see references to similar "fixes" for code signing, check the runbook first.
- **Multiple "Apple Distribution: Lion MGT LLC" certs in the login keychain** will make xcodebuild silently pick the wrong one and `-exportArchive` fails with "Provisioning profile doesn't include signing certificate". Fix: pin the cert SHA-1 in `apps/mobile/ios/ExportOptions.plist` (or delete the duplicate from Keychain Access).
