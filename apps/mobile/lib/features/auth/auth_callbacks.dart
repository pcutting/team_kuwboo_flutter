import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kuwboo_auth/kuwboo_auth.dart';
import 'package:kuwboo_models/kuwboo_models.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../providers/api_provider.dart';
import '../../providers/auth_provider.dart';

/// Builds an [AuthCallbacks] wired to the real backend via the mobile
/// app's providers. The returned object is passed to [KuwbooAuthFlow]
/// wrapping the `/auth/*` router sub-tree.
AuthCallbacks buildMobileAuthCallbacks(Ref ref) {
  final authNotifier = ref.read(authProvider.notifier);
  final usersApi = ref.read(usersApiProvider);
  final interestsApi = ref.read(interestsApiProvider);

  return AuthCallbacks(
    // ── SSO ───────────────────────────────────────────────────────────
    onSignInWithApple: () async {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final identityToken = credential.identityToken;
      final authorizationCode = credential.authorizationCode;
      if (identityToken == null) {
        throw StateError('Apple did not return an identity token');
      }
      final given = credential.givenName;
      final family = credential.familyName;
      final fullName = (given == null && family == null)
          ? null
          : '${given ?? ''} ${family ?? ''}'.trim();
      return authNotifier.signInWithApple(
        identityToken: identityToken,
        authorizationCode: authorizationCode,
        fullName: fullName?.isEmpty == true ? null : fullName,
      );
    },

    onSignInWithGoogle: () async {
      // Lazy-initialize; safe to call multiple times (plugin is idempotent).
      await GoogleSignIn.instance.initialize();
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw StateError('Google did not return an ID token');
      }
      return authNotifier.signInWithGoogle(idToken: idToken);
    },

    onConfirmSsoChallenge: authNotifier.confirmSsoChallenge,

    // ── Phone / Email OTP ─────────────────────────────────────────────
    //
    // The screen-facing callback returns just the devCode string (if any);
    // the full SendOtpResult stays inside the provider.
    onSendPhoneOtp: (phone) async {
      final result = await authNotifier.sendPhoneOtp(phone);
      return result.devCode;
    },
    onSendEmailOtp: (email) async {
      final result = await authNotifier.sendEmailOtp(email);
      return result.devCode;
    },

    onVerifyOtp: (identifier, code, channel) async {
      return authNotifier.verifyOtp(
        identifier: identifier,
        code: code,
        isPhone: channel == AuthOtpChannel.phone,
      );
    },

    onResendOtp: (identifier, channel) async {
      if (channel == AuthOtpChannel.phone) {
        await authNotifier.sendPhoneOtp(identifier);
      } else {
        await authNotifier.sendEmailOtp(identifier);
      }
    },

    // ── Onboarding progress ───────────────────────────────────────────
    onSaveBirthday: (dob) async {
      // Backend's PatchMeDto accepts an ISO-8601 date string.
      final iso = '${dob.year.toString().padLeft(4, '0')}-'
          '${dob.month.toString().padLeft(2, '0')}-'
          '${dob.day.toString().padLeft(2, '0')}';
      await usersApi.patchMe(PatchMeDto(dateOfBirth: iso));
      await authNotifier.refreshUser();
    },

    onSaveDobChoice: (choice) async {
      // TODO(backend): the granular DOB-choice endpoint is being added
      // in parallel. The backend will need to distinguish between
      // "prefer not to say", "adult self-declared", and "skipped" and
      // drive the matching credibility / age-verification state. Until
      // then we fall back to the existing `birthdaySkipped` flag which
      // at least locks dating on its own.
      //
      // When the dedicated endpoint lands, swap this for a POST /users/me/
      // dob-choice (or similar) call carrying the full AuthDobChoice
      // value so the server can score credibility distinctly.
      await usersApi.patchMe(const PatchMeDto(birthdaySkipped: true));
      await authNotifier.refreshUser();
    },

    onSaveProfile: ({displayName, username, avatarUrl, bio, photoPath}) async {
      // TODO(backend): wire the photo upload flow. For now the local
      // [photoPath] is only used by the auth_profile_screen to render
      // an instant preview; actual S3 upload + PATCH /users/me with the
      // resulting avatarUrl happens in a separate feature because
      // MediaApi.presignUpload + the confirm step aren't on the
      // onboarding critical path yet.
      await usersApi.patchMe(PatchMeDto(
        displayName: displayName,
        username: username,
        avatarUrl: avatarUrl,
        bio: bio,
      ));
      await authNotifier.refreshUser();
    },

    onSaveInterests: (interestIds) async {
      // Replace the authenticated user's declared interest set. The
      // backend returns the resulting full selection; we ignore the
      // response here and let downstream providers re-fetch on demand.
      await interestsApi.selectMany(
        SelectInterestsDto(interestIds: interestIds),
      );
    },

    onCompleteTutorial: () async {
      // Version 1 matches backend's current tutorial set. Bump when the
      // tutorial content ships a new iteration.
      await usersApi.completeTutorial(const TutorialCompleteDto(version: 1));
      await authNotifier.refreshUser();
    },

    onCompleteOnboarding: () async {
      authNotifier.markOnboardingComplete();
    },

    // ── Session ───────────────────────────────────────────────────────
    onLogout: authNotifier.logout,
  );
}

/// Riverpod exposes the callbacks so router-level widgets can grab them
/// without rebuilding when auth state changes (this provider is a simple
/// factory — the callbacks close over the notifier, which is a
/// StateNotifierProvider, so identity is stable).
final authCallbacksProvider = Provider<AuthCallbacks>(buildMobileAuthCallbacks);
