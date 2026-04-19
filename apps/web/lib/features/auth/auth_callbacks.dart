import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_auth/kuwboo_auth.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import '../../providers/auth_provider.dart';
import '../../prototype/router.dart';

/// Web-side [AuthCallbacks] wired to the prototype's Riverpod auth
/// provider. Mirrors `apps/mobile/lib/features/auth/auth_callbacks.dart`
/// in shape, but with most onboarding/SSO callbacks stubbed because
/// the web prototype does not exercise those flows — only `onLogout`
/// is load-bearing (driven by the Settings screen's logout button).
///
/// Do not add Firebase / Apple / Google sign-in dependencies to this
/// file; the web prototype deliberately ships without them.
AuthCallbacks buildWebAuthCallbacks(Ref ref) {
  final authNotifier = ref.read(authProvider.notifier);

  return AuthCallbacks(
    // Web has no router-level auth guard (mobile does), so the
    // callback itself owns the post-logout navigation.
    onLogout: () async {
      await authNotifier.logout();
      ref.read(routerProvider).go(ProtoRoutes.authWelcome);
    },

    // ── SSO ───────────────────────────────────────────────────────────
    // Apple / Google sign-in are platform-only flows. The web prototype
    // does not render the SSO buttons in a way that would reach these,
    // but the callback must exist if the screen is ever shown — a
    // debugPrint + thrown UnimplementedError surfaces the gap loudly
    // rather than returning a bogus success.
    onSignInWithApple: () async {
      debugPrint('[web auth] onSignInWithApple invoked — not wired on web');
      throw UnimplementedError('Sign in with Apple is not available on web');
    },
    onSignInWithGoogle: () async {
      debugPrint('[web auth] onSignInWithGoogle invoked — not wired on web');
      throw UnimplementedError('Google sign-in is not available on web');
    },
    onConfirmSsoChallenge: (challenge, otp) async {
      debugPrint('[web auth] onConfirmSsoChallenge invoked — not wired on web');
      throw UnimplementedError('SSO challenge confirmation not wired on web');
    },

    // ── Phone / Email OTP ─────────────────────────────────────────────
    // Agent C owns the mock interceptor; until those endpoints are
    // stubbed we log + no-op so the phone/OTP screens can still be
    // navigated in the prototype without raising.
    onSendPhoneOtp: (phone) async {
      debugPrint('[web auth] onSendPhoneOtp($phone) — mock path not wired');
      return null;
    },
    onSendEmailOtp: (email) async {
      debugPrint('[web auth] onSendEmailOtp($email) — mock path not wired');
      return null;
    },
    onVerifyOtp: (identifier, code, channel) async {
      debugPrint('[web auth] onVerifyOtp($identifier, …, $channel) — mock path not wired');
      throw UnimplementedError('OTP verification not wired on web prototype');
    },
    onResendOtp: (identifier, channel) async {
      debugPrint('[web auth] onResendOtp($identifier, $channel) — no-op on web');
    },

    // ── Onboarding progress ───────────────────────────────────────────
    // Onboarding screens in the prototype are visual-only; these
    // callbacks exist so the screens' own post-save navigation still
    // fires without hitting a null callback branch.
    onSaveBirthday: (dob) async {
      debugPrint('[web auth] onSaveBirthday($dob) — no-op on web');
    },
    onSaveDobChoice: (choice) async {
      debugPrint('[web auth] onSaveDobChoice($choice) — no-op on web');
    },
    onSaveProfile: ({displayName, username, avatarUrl, bio, photoPath}) async {
      debugPrint('[web auth] onSaveProfile(displayName=$displayName, username=$username) — no-op on web');
    },
    onSaveInterests: (interestIds) async {
      debugPrint('[web auth] onSaveInterests(${interestIds.length} ids) — no-op on web');
    },
    onCompleteTutorial: () async {
      debugPrint('[web auth] onCompleteTutorial — no-op on web');
    },
    onCompleteOnboarding: () async {
      debugPrint('[web auth] onCompleteOnboarding — no-op on web');
    },
  );
}

/// Factory provider — identity is stable because the returned
/// [AuthCallbacks] closes over the [authProvider] notifier, which is a
/// StateNotifierProvider (stable across rebuilds).
final authCallbacksProvider = Provider<AuthCallbacks>(buildWebAuthCallbacks);
