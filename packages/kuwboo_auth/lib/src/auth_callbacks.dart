import 'package:flutter/widgets.dart';
import 'package:kuwboo_api_client/kuwboo_api_client.dart';
import 'package:kuwboo_models/kuwboo_models.dart';

/// Channel an OTP was sent on — tells the OTP screen whether to verify
/// via `onVerifyPhoneOtp` or `onVerifyEmailOtp`, and labels the UI
/// ("sent to +44 7…" vs "sent to phil@…").
enum AuthOtpChannel { phone, email }

/// Arguments passed to [AuthOtpScreen] via route-push extra when the
/// method/phone screen has triggered a real OTP send.
class AuthOtpArgs {
  const AuthOtpArgs({
    required this.identifier,
    required this.channel,
    this.displayIdentifier,
  });

  /// Canonical identifier used for verification calls (E.164 phone or
  /// lower-cased email). Server sees this value.
  final String identifier;

  final AuthOtpChannel channel;

  /// Optional formatted variant shown to the user on the OTP screen —
  /// e.g. `+44 7XXX XXX XX3` vs the canonical `+447xxxxxxxx3`. Falls
  /// back to [identifier] when null.
  final String? displayIdentifier;
}

/// Callbacks the host app (mobile) supplies to drive real auth API calls
/// out of the prototype auth flow. When null (web prototype), the screen
/// falls back to the existing mock-navigation behaviour.
///
/// Every callback returns a [Future] so screens can show progress and
/// handle errors inline. Throwing propagates to the screen's local
/// catch block which surfaces a SnackBar / inline error.
///
/// Constructor-injected once at [KuwbooAuthFlow], then read via
/// [AuthCallbacksScope.maybeOf] by individual screens.
class AuthCallbacks {
  const AuthCallbacks({
    this.onSignInWithApple,
    this.onSignInWithGoogle,
    this.onConfirmSsoChallenge,
    this.onSendPhoneOtp,
    this.onSendEmailOtp,
    this.onVerifyOtp,
    this.onResendOtp,
    this.onSaveBirthday,
    this.onSaveProfile,
    this.onCompleteTutorial,
    this.onCompleteOnboarding,
    this.onLogout,
  });

  // ─── SSO ─────────────────────────────────────────────────────────────

  /// Triggers Sign in with Apple; returns success or an email-owned
  /// challenge that the UI must resolve via [onConfirmSsoChallenge].
  final Future<SsoLoginResult> Function()? onSignInWithApple;

  /// Triggers Google Sign-In; same challenge contract as Apple.
  final Future<SsoLoginResult> Function()? onSignInWithGoogle;

  /// Completes an SSO email-ownership challenge by supplying the OTP
  /// the user received on the already-known email channel.
  final Future<AuthResponse> Function(
    PendingSsoChallenge challenge,
    String otp,
  )? onConfirmSsoChallenge;

  // ─── Phone / Email OTP ───────────────────────────────────────────────

  /// Request a phone OTP. Throws on rate-limit or invalid phone.
  final Future<void> Function(String phone)? onSendPhoneOtp;

  /// Request an email OTP.
  final Future<void> Function(String email)? onSendEmailOtp;

  /// Verify an OTP on either channel. Returns tokens + user on success;
  /// throws on invalid/expired code.
  final Future<AuthResponse> Function(
    String identifier,
    String code,
    AuthOtpChannel channel,
  )? onVerifyOtp;

  /// Re-trigger sending an OTP (re-uses the appropriate channel).
  final Future<void> Function(String identifier, AuthOtpChannel channel)?
      onResendOtp;

  // ─── Onboarding progress ─────────────────────────────────────────────

  /// Save birthday. Caller enforces 13+ locally before invoking.
  final Future<void> Function(DateTime dateOfBirth)? onSaveBirthday;

  /// Save profile fields (patch /users/me).
  final Future<void> Function({
    String? displayName,
    String? username,
    String? avatarUrl,
    String? bio,
  })? onSaveProfile;

  /// Mark tutorial complete.
  final Future<void> Function()? onCompleteTutorial;

  /// Final onboarding step — host app usually clears the `isNewUser`
  /// flag and routes into the main shell.
  final Future<void> Function()? onCompleteOnboarding;

  // ─── Session ─────────────────────────────────────────────────────────

  /// Revoke session on server + clear local tokens (used by the login
  /// screen's "not you?" affordance).
  final Future<void> Function()? onLogout;
}

/// Provides [AuthCallbacks] to descendant auth screens. Call
/// `AuthCallbacksScope.maybeOf(context)` inside a screen to read them;
/// null means web-prototype / no callbacks supplied.
class AuthCallbacksScope extends InheritedWidget {
  const AuthCallbacksScope({
    super.key,
    required this.callbacks,
    required super.child,
  });

  final AuthCallbacks callbacks;

  static AuthCallbacks? maybeOf(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AuthCallbacksScope>();
    return scope?.callbacks;
  }

  @override
  bool updateShouldNotify(AuthCallbacksScope oldWidget) =>
      callbacks != oldWidget.callbacks;
}

/// Host wrapper for the auth flow. The mobile app instantiates this once
/// at the root of its `/auth/*` sub-tree, passing a real [AuthCallbacks].
/// Web prototype can skip this widget entirely — screens then see a null
/// scope and fall back to mock navigation.
class KuwbooAuthFlow extends StatelessWidget {
  const KuwbooAuthFlow({
    super.key,
    required this.callbacks,
    required this.child,
  });

  final AuthCallbacks callbacks;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AuthCallbacksScope(callbacks: callbacks, child: child);
  }
}
