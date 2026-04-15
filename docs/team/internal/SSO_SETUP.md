# SSO Setup — Apple + Google

**Phase 3 of mobile rebuild — 2026-04-15**

Backend is already done. Backend endpoints `/auth/apple`, `/auth/apple/confirm`, `/auth/google`, `/auth/google/confirm` + token verification via JWKs + email-ownership challenge flow all exist in `apps/api/src/modules/auth/`. This doc covers the client and config work only.

## Status summary

| Item | Status |
|---|---|
| `sign_in_with_apple: ^7.0.1` in `apps/mobile/pubspec.yaml` | ✅ done (Phase 3) |
| `google_sign_in: ^7.2.0` in `apps/mobile/pubspec.yaml` | ✅ done (Phase 3) |
| `apps/mobile/ios/Runner/Runner.entitlements` with AppleSignIn | ✅ done (Phase 3) |
| `CODE_SIGN_ENTITLEMENTS` wired into Debug/Release/Profile of Runner target | ✅ done (Phase 3) |
| Backend `/auth/apple` + `/auth/google` endpoints | ✅ pre-existing |
| Backend `/auth/{provider}/confirm` for email-ownership challenge | ✅ pre-existing |
| **AppleSignIn capability enabled on `com.kuwboo.mobile` App ID** | ⏸ BLOCKED — Neil to approve script run |
| **Provisioning profile regenerated with AppleSignIn** | ⏸ BLOCKED — cascades from above |
| **Apple Services ID** registered for server-side identity token verification | ⏸ BLOCKED — Neil manual (Dev Portal UI) |
| **Apple client-secret JWT** generated + stored in AWS Secrets Manager | ⏸ BLOCKED — cascades from Services ID |
| **Firebase Google provider** enabled for project `kuwboo-mobile` | ⏸ BLOCKED — Neil manual (Firebase Console) |
| `GoogleService-Info.plist` regenerated with `REVERSED_CLIENT_ID` | ⏸ BLOCKED — needs Google provider on first |
| `google-services.json` regenerated | ⏸ BLOCKED — needs Google provider on first |
| Android SHA-1 fingerprint added to Firebase | ⏸ BLOCKED — needs production keystore available |
| **OAuth consent screen** configured in GCP Console | ⏸ BLOCKED — Neil manual; needs production domain |
| Privacy policy URL | 🚨 MISSING — no kuwboo domain yet |

---

## Neil's manual hot list

These cannot be scripted. Please work through them in order. Each is 2-5 minutes.

### 1. Enable Apple SSO capability (Apple Developer Portal)

**URL:** https://developer.apple.com/account/resources/identifiers/list

1. Find App ID `com.kuwboo.mobile` in the list.
2. Click into it, enable "Sign In with Apple" checkbox.
3. Save. (The portal will prompt you to regenerate any profiles that reference this App ID — say yes.)

Alternative: run `scripts/sso/enable_apple_signin.py` (see below) to do this via the ASC API — I've written the script but left it un-run until you approve. The script also regenerates the provisioning profile and updates the two relevant GitHub Secrets.

### 2. Register an Apple Services ID

**URL:** https://developer.apple.com/account/resources/identifiers/list/serviceId

This is a separate identifier from the App ID, required for server-side identity-token verification on `/auth/apple`.

1. Click **+** → **Services IDs** → Continue.
2. Description: `Kuwboo Sign in with Apple`
3. Identifier: `com.kuwboo.signin.service` (must differ from the App ID).
4. Enable "Sign In with Apple".
5. Configure → Primary App ID: `com.kuwboo.mobile`.
6. Domains and Return URLs: leave blank for now (only needed if we ever add web Sign in with Apple).
7. Save. Note the Services ID — we'll need it in step 3.

### 3. Generate Apple client-secret JWT + add AWS secrets

Apple requires the backend to sign a short-lived JWT as proof of authority when calling Apple's token endpoint. The secret rotates every ≤ 6 months.

Run (after step 2 is done):

```bash
scripts/sso/generate_apple_client_secret.py \
  --team-id 5GQA38WHMY \
  --services-id com.kuwboo.signin.service \
  --key-id 3B764CRX7S \
  --key-file /Users/philipcutting/Projects/clients/active/neil_douglas/AuthKey_3B764CRX7S.p8 \
  --aws-profile neil-douglas \
  --region eu-west-2
```

It will:
1. Mint an ES256 JWT valid for 180 days with the claims Apple requires (iss/iat/exp/aud/sub).
2. Upsert AWS Secrets Manager secrets under `/kuwboo/apple/`:
   - `/kuwboo/apple/team-id`
   - `/kuwboo/apple/services-id`
   - `/kuwboo/apple/key-id`
   - `/kuwboo/apple/private-key` (the raw `.p8`)
   - `/kuwboo/apple/client-secret-jwt` (the signed JWT; rotate on expiry)
3. Print the expiry date so we can schedule the rotation cron.

### 4. Enable Google provider in Firebase Authentication

**URL:** https://console.firebase.google.com/project/kuwboo-mobile/authentication/providers

1. Click **Sign-in method** tab.
2. Click **Google** → toggle "Enable".
3. Public-facing name: `Kuwboo`.
4. Project support email: `cuttingphilip@gmail.com` (or your admin-visible alias).
5. Save.

This auto-provisions a web OAuth 2.0 client in the linked GCP project. That web client's client ID is what the backend will use for `audience` verification on incoming Google ID tokens.

### 5. Configure OAuth consent screen (GCP Console)

**URL:** https://console.cloud.google.com/apis/credentials/consent?project=kuwboo-mobile

Required before non-testing Google sign-ins will work outside `@kuwboo.com` domains.

Fields:
- App name: `Kuwboo`
- User support email: (your email)
- App logo: (skip for now, add before public launch)
- App domain: **BLOCKED on us having a real domain.** `teamkuwbooflutter.vercel.app` may not pass review. Use `kuwboo.com` / `kuwboo.app` if registered; otherwise skip this field for now and revisit pre-launch.
- Authorized domains: same.
- Developer contact info: (your email).
- Scopes: `openid`, `email`, `profile` (default — no sensitive scopes needed).
- Test users: add your gmail + any internal testers while in "Testing" status.

Leave publishing status as **Testing** until launch.

### 6. Regenerate Firebase config files

After step 4 is done, regenerate the iOS and Android config files so they include the new Google OAuth web-client ID (as `REVERSED_CLIENT_ID` on iOS, `oauth_client[].client_id` on Android).

```bash
# Install flutterfire_cli if needed
dart pub global activate flutterfire_cli

# Regenerate (from apps/mobile)
cd apps/mobile
flutterfire configure \
  --project=kuwboo-mobile \
  --platforms=ios,android \
  --ios-bundle-id=com.kuwboo.mobile \
  --android-package-name=com.kuwboo.mobile \
  --yes
```

This overwrites:
- `apps/mobile/ios/Runner/GoogleService-Info.plist` (adds `REVERSED_CLIENT_ID`)
- `apps/mobile/android/app/google-services.json` (adds oauth_client entries)
- `apps/mobile/lib/firebase_options.dart` (no functional change unless Firebase options have moved)

Commit the three regenerated files.

### 7. Add Android SHA-1 fingerprint to Firebase

Google Sign-In on Android requires the SHA-1 of your signing keystore to be registered on the Firebase Android app.

```bash
# Debug keystore fingerprint (for local dev)
keytool -list -v -keystore ~/.android/debug.keystore \
  -alias androiddebugkey -storepass android -keypass android \
  | grep "SHA1:"

# Release keystore fingerprint (from the kuwboo-upload.jks)
keytool -list -v -keystore /Users/philipcutting/Projects/clients/active/neil_douglas/flutter/keys/kuwboo-upload.jks \
  -alias <your-alias-here> | grep "SHA1:"
```

Then either:
- Paste the SHA-1 into Firebase Console → Project settings → Your apps → Android → **Add fingerprint**,
- OR run `mcp__plugin_firebase_firebase__firebase_create_android_sha` via the Firebase MCP plugin.

### 8. Xcode: verify entitlements in Signing & Capabilities

Open `apps/mobile/ios/Runner.xcworkspace` in Xcode.

1. Select the Runner target → **Signing & Capabilities** tab.
2. You should see **Sign In with Apple** listed (we've already wired the .entitlements file in Phase 3; Xcode will surface it automatically).
3. If it doesn't appear, click **+ Capability** and add it manually — it'll merge with the existing Runner.entitlements content.

No further pbxproj edits should be needed.

### 9. Trigger a fresh TestFlight build after step 1 completes

```bash
gh workflow run ios-testflight.yml --ref feat/mobile-rebuild \
  -f environment=prod --repo pcutting/team_kuwboo
```

Verify the build completes with the new provisioning profile (which now includes AppleSignIn entitlement). If signing fails, the cert rotation pattern in `docs/team/internal/TESTFLIGHT_RUNBOOK.md` still applies.

---

## What the mobile app needs (Phase 5)

When Phases 4 and 5 land, the mobile app will have:

```dart
// apps/mobile/lib/features/auth/auth_callbacks.dart
AuthCallbacks(
  onSignInWithApple: () async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
    );
    final result = await authApi.signInWithApple(
      AppleLoginDto(
        identityToken: credential.identityToken!,
        authorizationCode: credential.authorizationCode!,
        fullName: credential.givenName != null
          ? '${credential.givenName} ${credential.familyName ?? ''}'
          : null,
      ),
    );
    return _handleSsoResult(result);  // success or challenge
  },
  onSignInWithGoogle: () async {
    final account = await GoogleSignIn().signIn();
    final auth = await account!.authentication;
    final result = await authApi.signInWithGoogle(
      GoogleLoginDto(idToken: auth.idToken!, accessToken: auth.accessToken),
    );
    return _handleSsoResult(result);
  },
  // ... phone/email/tutorial/etc
);
```

The `_handleSsoResult` helper dispatches between `AuthResponse` (login successful) and `PendingSsoChallenge` (email already owned by a different credential, UI should prompt for OTP via that other channel and then call `/auth/{provider}/confirm`).

---

## Known blockers summary

- ⚠ **Kuwboo production domain** — required for Google OAuth consent screen approval. Current `teamkuwbooflutter.vercel.app` may not pass Google review for public-facing apps. Acquire `kuwboo.com` / `kuwboo.app` pre-launch.
- ⚠ **Apple Services ID** — one-time manual Developer Portal step; no API.
- ⚠ **Privacy policy URL** — needs to be hosted on the production domain. Placeholder acceptable for internal testing.

## Verification gate

Before Phase 5 (mobile auth integration) can complete end-to-end:

- [ ] Fresh iOS TestFlight build contains AppleSignIn entitlement (visible in `Payload/Runner.app/embedded.mobileprovision` via `security cms -D`).
- [ ] Apple Services ID + client secret JWT stored in AWS Secrets Manager.
- [ ] Firebase Google provider is enabled; `GoogleService-Info.plist` contains `REVERSED_CLIENT_ID`.
- [ ] Release keystore SHA-1 registered on Firebase Android app.
- [ ] OAuth consent screen at least partially configured (can leave in Testing status with test users allowlist).
