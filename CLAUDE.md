# team_kuwboo — Monorepo Instructions

Instructions for AI agents (Claude, Cursor, etc.) working in this repository.

## What this repo is

Kuwboo multi-platform app monorepo. Flutter for mobile (iOS + Android), NestJS for the backend API, and shared packages. Managed with Melos + pub workspaces. Primary active product is the Flutter mobile app shipping to TestFlight.

| Path | Purpose | Deploy |
|---|---|---|
| `apps/mobile/` | Flutter iOS + Android app (**primary focus**) | TestFlight via GH Actions |
| `apps/api/` | NestJS backend | EC2 (`35.177.230.139`, eu-west-2) |
| `apps/admin/` | React 19 + Vite SPA (client-side only) | Vercel static — `team_kuwboo_admin` |
| `apps/web/` | Flutter web prototype + design viewer | Vercel static — `team_kuwboo_flutter` (prebuilt `build/web`) |
| `packages/ui/` | Shared Flutter theme + widgets | — |
| `packages/models/` | Shared data models | — |
| `packages/api_client/` | Generated API client | — |
| `docs/` | Project documentation — see `docs/README.md` for the index | — |
| `keys/` | **Gitignored.** Local Apple signing material (`.p12`, `.mobileprovision`, `.key`, CSR, password). Never commit. | — |
| `.github/workflows/` | CI — includes `ios-testflight.yml` and `ios-pr-validation.yml` | — |

### Deployment architecture (read this before suggesting SSR/Functions/middleware)

All web hosting is **static**. No SSR, no Next.js, no Vercel Functions, no middleware, no edge compute in this repo today.
- `apps/web` — prebuilt Flutter web bundle; root `vercel.json` has empty `buildCommand` and serves `apps/web/build/web`.
- `apps/admin` — Vite SPA; Vercel builds from source with the project's root dir set to `apps/admin`.
- `apps/api` — NestJS on EC2 (PM2 + Nginx). Not on Vercel.

If the current task involves server rendering, API routes, or middleware, **stop and confirm with the user** — that's a deliberate architectural change, not an extension of what's here.

## Critical conventions

### PR-driven development
**Every change goes through a pull request.** No direct pushes to `main`. Branch → commit → push → `gh pr create` → merge (squash) → delete branch. See the parent workspace `CLAUDE.md` for the full rule.

### No AI attribution in commits or code
**Never include** "Claude", "AI", "Generated", or "Co-Authored-By: Claude" in commits, code, comments, or PR descriptions. Use professional, human-authored voice. A pre-commit hook rejects commits containing AI references.

### Reproducibility
- `pubspec.lock` and `Podfile.lock` are **tracked** (re-included from the broad `*.lock` gitignore pattern via negation rules)
- Flutter version is **pinned to 3.41.4** in `.github/workflows/ios-testflight.yml` — this must satisfy the workspace Dart SDK constraint `^3.11.1`. Bumping Flutter requires checking Dart SDK compatibility first.
- **Do not pin Xcode** in workflows. Let the runner use its default Xcode. Pinning to Xcode 16.0 causes "iOS 18.0 is not installed" failures because the runner's Xcode 16.0 doesn't include iOS 18 SDK pre-installed.

### Signing material is local + secrets only
- Apple Distribution cert, provisioning profile, API key — all live in `keys/` (gitignored) and in GitHub Secrets
- **Never** commit `.p8`, `.key`, `.cer`, `.p12`, `.mobileprovision`, or `.certSigningRequest` files (all are in `.gitignore` as extension patterns)
- Rotation procedure is fully automated via the App Store Connect API — see `docs/team/internal/TESTFLIGHT_RUNBOOK.md`

## Deploying to TestFlight

### One-line trigger (most common path)

```bash
gh workflow run ios-testflight.yml --ref main -f environment=prod --repo pcutting/team_kuwboo
```

Wait ~9-11 minutes. Check status:

```bash
gh run list --workflow=ios-testflight.yml --repo pcutting/team_kuwboo --limit 3
gh run watch <run-id> --repo pcutting/team_kuwboo
```

### Key facts for iOS deployment

| Fact | Value |
|---|---|
| Bundle ID | `com.kuwboo.mobile` |
| Apple Team ID | `5GQA38WHMY` (Lion MGT LLC) |
| App Store Connect app ID | `6761923318` (name: "Kuwboo Mobile") |
| Workflow | `.github/workflows/ios-testflight.yml` |
| Fastfile lane | `bundle exec fastlane beta` from `apps/mobile/ios/` |
| Signing | Manual — cert + profile installed from GitHub Secrets into a temp keychain by the workflow step |
| Upload auth | App Store Connect API key `.p8` (Key ID `3B764CRX7S`, Issuer ID `6461be03-feb0-432f-9a9d-8e074ac2ffec`) |

### GitHub Secrets required by the workflow

| Secret | Purpose |
|---|---|
| `APPLE_KEY_ID` | App Store Connect API key ID |
| `APPLE_ISSUER_ID` | App Store Connect issuer UUID |
| `APPLE_KEY_P8_BASE64` | API key `.p8` contents (base64) |
| `APPLE_CERT_P12_BASE64` | Apple Distribution cert + private key, PKCS#12 |
| `APPLE_CERT_P12_PASSWORD` | Password for the `.p12` |
| `APPLE_PROVISIONING_PROFILE_BASE64` | App Store provisioning profile contents (base64) |
| `APPLE_PROVISIONING_PROFILE_UUID` | Profile UUID (used as the on-disk filename in the runner) |
| `APPLE_TEAM_ID` | Team ID (currently unused by the workflow but kept for completeness) |

Manage via `gh secret set NAME --repo pcutting/team_kuwboo < path/to/base64/file` or `--body "value"`. View via `gh secret list --repo pcutting/team_kuwboo`.

### If things go wrong

**Always read the full troubleshooting section** in [`docs/team/internal/TESTFLIGHT_RUNBOOK.md`](docs/team/internal/TESTFLIGHT_RUNBOOK.md) before iterating. The runbook has 7 specific debug lessons from the initial setup, including several red-herring error messages where Flutter's output is misleading. The meta-lesson: **add `flutter -v` to see raw xcodebuild stderr** when Flutter errors are unclear — many "no cert" / "no dev team" messages are actually downstream fallbacks from an upstream xcodebuild failure.

Cert rotation (emergency or annual renewal) is a fully automated Python script that runs against the App Store Connect API. See the runbook's "Emergency cert rotation" section (if added) or the chat history from 2026-04-09 for the proven procedure.

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

# iOS CI trigger
gh workflow run ios-testflight.yml --ref main -f environment=prod --repo pcutting/team_kuwboo

# Inspect a failing CI run
gh run view <run-id> --repo pcutting/team_kuwboo --log-failed

# Check GitHub Secrets
gh secret list --repo pcutting/team_kuwboo
```

## Common traps

- **`git add .` is dangerous here** — the `keys/` folder has signing material. Always `git add` specific files.
- **The workspace root `pubspec.lock` is the authoritative lock file**. Don't generate lock files in individual packages.
- **CocoaPods Podfile.lock is tracked** (explicit negation of the broad `*.lock` pattern). Commit it when it changes.
- **Lock file changes need a matching pod/pub run** — if you bump a dependency, run `pub get` and `pod install` locally and commit both lock files together.
- **Don't modify `apps/mobile/ios/Runner.xcodeproj/project.pbxproj`** unless you know what you're doing. The "iPhone Developer" → "Apple Distribution" rename we did during the debug session was a red herring fix that didn't actually help; if you see references to similar "fixes" for code signing, check the runbook first.
