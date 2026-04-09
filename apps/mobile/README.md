# Kuwboo Mobile

Flutter cross-platform mobile app (iOS + Android) for Kuwboo.

> **Shipping to TestFlight?** See [**Deploy to TestFlight**](#deploy-to-testflight) below for the one-line trigger. Full setup and troubleshooting details are in [`docs/team/internal/TESTFLIGHT_RUNBOOK.md`](../../docs/team/internal/TESTFLIGHT_RUNBOOK.md).

## Requirements

- **Flutter 3.41.4** (must satisfy the workspace Dart SDK constraint `^3.11.1` — older Flutter ships older Dart and will fail `pub get`)
- **Xcode** — whatever the CI macOS runner defaults to (currently Xcode 16.4 with iOS 18.5 SDK). **Do not pin Xcode 16.0** — it defaults to iOS 18.0 SDK which is not pre-installed on GitHub runners and causes silent `xcodebuild` failures that cascade into misleading errors.
- **CocoaPods 1.15+** (`sudo gem install cocoapods`)
- **Ruby 3.2+** (for Fastlane)

## Local development

```bash
# From the monorepo root
cd apps/mobile

# Install dependencies
flutter pub get

# Run on an iOS simulator (uses dev environment by default)
flutter run -d "iPhone 15 Pro"

# Run against staging API
flutter run --dart-define=KUWBOO_ENV=staging

# Run against production API
flutter run --dart-define=KUWBOO_ENV=prod
```

## Environment configuration

The API base URL is selected at build time via `--dart-define=KUWBOO_ENV=<env>`:

| Env | API URL |
|-----|---------|
| `dev` (default) | `https://kuwboo-api.codiantdev.com` |
| `staging` | `https://kuwboo-api.codiantdev.com` |
| `prod` | `https://api.kuwboo.com` |

You can also override the URL directly with `--dart-define=KUWBOO_API_URL=https://...`.

See `lib/config/environment.dart` for the full configuration.

## iOS build and signing

| Setting | Value |
|---|---|
| Bundle ID | `com.kuwboo.mobile` |
| Apple Team | Lion MGT LLC (`5GQA38WHMY`) |
| Minimum iOS version | 15.0 |
| Distribution cert | Apple Distribution: Lion MGT LLC (rotated 2026-04-09, expires 2027-04-09) |
| Provisioning profile | `Kuwboo Mobile App Store` (UUID in GitHub Secrets `APPLE_PROVISIONING_PROFILE_UUID`) |
| Signing style | **Manual** — cert + profile installed from GitHub Secrets into a temp keychain by the workflow |
| Upload auth | App Store Connect API key `.p8` (Secret: `APPLE_KEY_P8_BASE64`), used only by `upload_to_testflight` |

> **Why manual signing?** Earlier versions of this README said "automatic signing" but that's not how the pipeline works anymore. Flutter's built-in `flutter build ipa` codesign preflight has a broken regex that only matches Development certs, not Distribution ones. The Fastfile works around it by running `flutter build ipa --release --no-codesign` to produce an unsigned archive, then signing it with a separate `xcodebuild -exportArchive -allowProvisioningUpdates` call. `ExportOptions.plist` uses `signingStyle: manual` with an explicit `provisioningProfiles` dict. Full backstory: [`TESTFLIGHT_RUNBOOK.md` "Hard-won lessons"](../../docs/team/internal/TESTFLIGHT_RUNBOOK.md#hard-won-lessons-from-the-initial-setup-debug-session-2026-04-09).

### Deploy to TestFlight

**Fastest path — trigger the workflow from the CLI:**

```bash
gh workflow run ios-testflight.yml --ref main -f environment=prod --repo pcutting/team_kuwboo
```

Wait ~9-11 minutes (~90s flutter build + ~5s export + ~7 min Apple upload). Then check:

```bash
gh run list --workflow=ios-testflight.yml --repo pcutting/team_kuwboo --limit 3
```

Or trigger from the browser: https://github.com/pcutting/team_kuwboo/actions/workflows/ios-testflight.yml → **Run workflow** → Branch `main`, Environment `prod`, Build number blank.

On success, the build appears in App Store Connect → Kuwboo Mobile → TestFlight within ~5 minutes (Apple server-side processing).

### Tag-triggered release

```bash
git tag ios-v1.0.0
git push origin ios-v1.0.0
```

This fires the same workflow via the `push: tags: ['ios-v*']` trigger.

### Building locally (without uploading)

Local builds don't use the GitHub Secrets path; they need your login keychain to already have a matching Apple Distribution cert for team `5GQA38WHMY` and the provisioning profile in `~/Library/MobileDevice/Provisioning Profiles/`. If you're set up, the Fastfile's `build` lane produces an `.ipa` without uploading:

```bash
cd apps/mobile/ios
bundle install
bundle exec fastlane build  # builds only, no upload
```

### Uploading to TestFlight locally (alternative to CI)

If you want to mimic the CI flow from your Mac (useful for emergency hotfixes when CI is down):

```bash
cd apps/mobile/ios
bundle install
bundle exec pod install --repo-update

export APP_STORE_CONNECT_API_KEY_ID=3B764CRX7S
export APP_STORE_CONNECT_API_ISSUER_ID=6461be03-feb0-432f-9a9d-8e074ac2ffec
export APP_STORE_CONNECT_API_KEY_CONTENT="$(cat /Users/philipcutting/Projects/clients/active/neil_douglas/AuthKey_3B764CRX7S.p8)"
export KUWBOO_ENV=prod

bundle exec fastlane beta
```

Prerequisites for the local flow: Apple Distribution cert for `5GQA38WHMY` installed in your login keychain, and `Kuwboo Mobile App Store.mobileprovision` in `~/Library/MobileDevice/Provisioning Profiles/`. Both are in the gitignored `keys/` folder at the repo root (`keys/kuwboo_distribution.p12` and `keys/Kuwboo_Mobile_App_Store.mobileprovision`); you can import the `.p12` into Keychain Access by double-clicking it and entering the password from `keys/.p12_password.txt`.

## Android

Android scaffolding exists but TestFlight is iOS-only. For Google Play setup, see (TODO: Android runbook).

```bash
flutter build apk --release --dart-define=KUWBOO_ENV=prod
```

## Project structure

```
apps/mobile/
├── lib/
│   ├── main.dart              # Entry point
│   ├── app/                   # Router, theme, root widget
│   ├── config/
│   │   └── environment.dart   # Build-time env config
│   ├── providers/             # Riverpod providers (auth, API, yoyo)
│   └── features/              # Feature modules (auth, video, social, etc.)
├── ios/
│   ├── Runner/                # iOS app target
│   │   └── Info.plist         # Bundle config, privacy strings
│   ├── Runner.xcodeproj       # Xcode project
│   ├── Runner.xcworkspace     # CocoaPods workspace (open this in Xcode)
│   ├── Podfile                # CocoaPods dependencies
│   ├── ExportOptions.plist    # App Store export config
│   ├── Gemfile                # Ruby dependencies (Fastlane, CocoaPods)
│   └── fastlane/              # CI lanes
│       ├── Fastfile           # Lane definitions (beta, build, tests)
│       └── Appfile            # Bundle ID + Team ID
├── android/                   # Android scaffolding
├── pubspec.yaml               # Flutter dependencies
└── README.md                  # This file
```

## Testing

```bash
flutter test
```

## Troubleshooting

**`pod install` fails with SSL errors**
Try `pod repo update` first, then `pod install`.

**`flutter build ios` fails with "No valid code signing certificates"**
This error is **misleading** — see [TESTFLIGHT_RUNBOOK.md "Hard-won lessons"](../../docs/team/internal/TESTFLIGHT_RUNBOOK.md#4--the-big-one-ios-180-is-not-installed--hidden-behind-every-other-error) for the full diagnosis. The most common real causes:
- You're pinning an Xcode version that's missing the iOS SDK it defaults to (don't pin; use runner default).
- Flutter's codesign preflight regex doesn't match Distribution certs. Use `flutter build ipa --release --no-codesign` instead and sign via `xcodebuild -exportArchive` separately.
- For local device builds specifically, open `ios/Runner.xcworkspace` in Xcode, select the Runner target, Signing & Capabilities, and set Team to **Lion MGT LLC (`5GQA38WHMY`)**. This requires your Apple ID to be a member of that team in Xcode → Settings → Accounts.

**Build number conflict on TestFlight upload**
The workflow auto-increments using GitHub run number. If you're uploading manually, set `BUILD_NUMBER=<higher>` before running fastlane.

**Deployment target mismatch on pod install**
The `Podfile` `post_install` hook forces all pods to iOS 15.0. If a pod requires a higher version, bump `IPHONEOS_DEPLOYMENT_TARGET` in both `project.pbxproj` and `Podfile`.
