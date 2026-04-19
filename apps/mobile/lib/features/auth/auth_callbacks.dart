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

    // ── Email + password ──────────────────────────────────────────────
    onEmailRegister: (req) async {
      await authNotifier.emailRegister(
        email: req.email,
        password: req.password,
        name: req.name,
        legalAccepted: req.legalAccepted,
        ageConfirmed: req.ageConfirmed,
      );
    },

    onEmailLogin: (email, password) async {
      await authNotifier.emailLogin(email: email, password: password);
    },

    onEmailPasswordForgot: (email) async {
      await authNotifier.emailPasswordForgot(email);
    },

    onEmailPasswordReset: (email, code, newPassword) async {
      await authNotifier.emailPasswordReset(
        email: email,
        code: code,
        newPassword: newPassword,
      );
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
      // Maps the on-screen chip into the backend's DobChoice enum. The
      // server applies the lockstep ageVerificationStatus + birthdaySkipped
      // transitions (see UsersService.applyDobChoice) — we just send the
      // choice and let the server decide the side-effects, so a future
      // enum value never needs a mobile-side client update.
      final wire = switch (choice) {
        AuthDobChoice.preferNotToSay => 'prefer_not_to_say',
        AuthDobChoice.adultSelfDeclared => 'adult_self_declared',
        AuthDobChoice.skipped => 'skipped',
      };
      await usersApi.patchMe(PatchMeDto(dobChoice: wire));
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
