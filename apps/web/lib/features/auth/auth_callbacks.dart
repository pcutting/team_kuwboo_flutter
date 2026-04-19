import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_auth/kuwboo_auth.dart';
import 'package:kuwboo_models/kuwboo_models.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import '../../providers/api_provider.dart';
import '../../providers/auth_provider.dart';
import '../../prototype/router.dart';

/// Web-side [AuthCallbacks] wired to the real backend at `api.kuwboo.com`.
///
/// Mirrors `apps/mobile/lib/features/auth/auth_callbacks.dart`. Apple /
/// Google SSO are deliberately unwired on web — the web build ships
/// without the platform SDKs. All other flows (phone OTP, email,
/// onboarding patches) hit the real backend.
AuthCallbacks buildWebAuthCallbacks(Ref ref) {
  final authNotifier = ref.read(authProvider.notifier);
  final usersApi = ref.read(realUsersApiProvider);
  final interestsApi = ref.read(interestsApiProvider);

  return AuthCallbacks(
    // ── SSO (not wired on web) ────────────────────────────────────────
    onSignInWithApple: () async {
      debugPrint('[web auth] onSignInWithApple — not wired on web');
      throw UnimplementedError('Sign in with Apple is not available on web');
    },
    onSignInWithGoogle: () async {
      debugPrint('[web auth] onSignInWithGoogle — not wired on web');
      throw UnimplementedError('Google sign-in is not available on web');
    },
    onConfirmSsoChallenge: (challenge, otp) async {
      throw UnimplementedError('SSO challenge confirmation not wired on web');
    },

    // ── Phone / Email OTP ─────────────────────────────────────────────
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
      final iso =
          '${dob.year.toString().padLeft(4, '0')}-'
          '${dob.month.toString().padLeft(2, '0')}-'
          '${dob.day.toString().padLeft(2, '0')}';
      await usersApi.patchMe(PatchMeDto(dateOfBirth: iso));
      await authNotifier.refreshUser();
    },
    onSaveDobChoice: (choice) async {
      final wire = switch (choice) {
        AuthDobChoice.preferNotToSay => 'prefer_not_to_say',
        AuthDobChoice.adultSelfDeclared => 'adult_self_declared',
        AuthDobChoice.skipped => 'skipped',
      };
      await usersApi.patchMe(PatchMeDto(dobChoice: wire));
      await authNotifier.refreshUser();
    },
    onSaveProfile: ({displayName, username, avatarUrl, bio, photoPath}) async {
      await usersApi.patchMe(
        PatchMeDto(
          displayName: displayName,
          username: username,
          avatarUrl: avatarUrl,
          bio: bio,
        ),
      );
      await authNotifier.refreshUser();
    },
    onSaveInterests: (interestIds) async {
      await interestsApi.selectMany(
        SelectInterestsDto(interestIds: interestIds),
      );
    },
    onCompleteTutorial: () async {
      await usersApi.completeTutorial(const TutorialCompleteDto(version: 1));
      await authNotifier.refreshUser();
    },
    onCompleteOnboarding: () async {
      authNotifier.markOnboardingComplete();
    },

    // ── Session ───────────────────────────────────────────────────────
    onLogout: () async {
      await authNotifier.logout();
      ref.read(routerProvider).go(ProtoRoutes.authWelcome);
    },
  );
}

/// Factory provider — identity is stable because the returned
/// [AuthCallbacks] closes over the [authProvider] notifier.
final authCallbacksProvider = Provider<AuthCallbacks>(buildWebAuthCallbacks);
