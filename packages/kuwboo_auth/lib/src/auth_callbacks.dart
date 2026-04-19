import 'package:flutter/widgets.dart';
import 'package:kuwboo_api_client/kuwboo_api_client.dart';
import 'package:kuwboo_models/kuwboo_models.dart';

/// Channel an OTP was sent on — tells the OTP screen whether to verify
/// via `onVerifyPhoneOtp` or `onVerifyEmailOtp`, and labels the UI
/// ("sent to +44 7…" vs "sent to phil@…").
enum AuthOtpChannel { phone, email }

/// Tiered non-DOB choice the user can make on the birthday screen.
/// Mirrors the backend's tracked credibility-lowering signals: the user
/// either declines to share ([preferNotToSay]), self-declares as an
/// adult without providing a date ([adultSelfDeclared]), or skips the
/// step entirely ([skipped]).
enum AuthDobChoice {
  /// "I prefer not to say" — user declined to share. Locks dating and
  /// age-gated content, lowers credibility.
  preferNotToSay,

  /// "I'm 18+" — user self-declares as an adult. Dating matches and the
  /// verified badge still need an exact birthday; they can add it later.
  adultSelfDeclared,

  /// "Skip for now" — user skipped. Dating, age-rated content, and
  /// premium visibility stay locked; credibility is low.
  skipped,
}

/// Arguments passed to [AuthOtpScreen] via route-push extra when the
/// method/phone screen has triggered a real OTP send.
class AuthOtpArgs {
  const AuthOtpArgs({
    required this.identifier,
    required this.channel,
    this.displayIdentifier,
    this.devCode,
  });

  /// Canonical identifier used for verification calls (E.164 phone or
  /// lower-cased email). Server sees this value.
  final String identifier;

  final AuthOtpChannel channel;

  /// Optional formatted variant shown to the user on the OTP screen —
  /// e.g. `+44 7XXX XXX XX3` vs the canonical `+447xxxxxxxx3`. Falls
  /// back to [identifier] when null.
  final String? displayIdentifier;

  /// Plaintext OTP code returned by the backend in local-dev / demo mode
  /// (Twilio not configured AND `NODE_ENV != 'production'`). When
  /// non-null, the OTP screen renders it in the test-build banner so the
  /// user can read the rolling code on-screen. Null in production.
  final String? devCode;
}

/// Arguments the email-register screen supplies to
/// [AuthCallbacks.onEmailRegister]. Wraps the form values so the callback
/// contract stays stable as the screen grows (e.g. future marketing
/// opt-in, referral code, etc.).
class EmailRegisterRequest {
  const EmailRegisterRequest({
    required this.email,
    required this.password,
    required this.legalAccepted,
    required this.ageConfirmed,
    this.name,
  });

  /// User-supplied email — lower-cased / trimmed before being passed in.
  final String email;

  /// Plaintext password — caller is expected to enforce client-side
  /// strength (8+ chars, non-blocklisted) before invoking.
  final String password;

  /// Optional display name. Null or empty means "skip" — the mobile
  /// profile screen collects the definitive value later.
  final String? name;

  /// Must be true. The form blocks submission otherwise; kept on the
  /// request payload so the backend has an audit trail for the consent
  /// check.
  final bool legalAccepted;

  /// Must be true. Same contract as [legalAccepted].
  final bool ageConfirmed;
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
    this.onEmailRegister,
    this.onEmailLogin,
    this.onEmailPasswordForgot,
    this.onEmailPasswordReset,
    this.onSaveBirthday,
    this.onSaveDobChoice,
    this.onSaveProfile,
    this.onSaveInterests,
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
  ///
  /// Returns the plaintext OTP code in local-dev / demo mode (Twilio not
  /// configured AND `NODE_ENV != 'production'`), or null in production.
  /// The phone screen threads this value into [AuthOtpArgs.devCode] so
  /// the OTP banner can display the rolling code.
  final Future<String?> Function(String phone)? onSendPhoneOtp;

  /// Request an email OTP. Same dev-code contract as [onSendPhoneOtp].
  final Future<String?> Function(String email)? onSendEmailOtp;

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

  // ─── Email + password ────────────────────────────────────────────────

  /// Create a new account with email + password. Throws on duplicate
  /// email, weak password, or rate-limit. On success the host persists
  /// the returned tokens and updates auth state so the router redirect
  /// carries the user into the onboarding flow.
  final Future<void> Function(EmailRegisterRequest req)? onEmailRegister;

  /// Authenticate an existing email + password pair. Throws on unknown
  /// email, wrong password, or locked account. On success the host
  /// persists tokens + updates auth state.
  final Future<void> Function(String email, String password)? onEmailLogin;

  /// Request a password-reset code by email. Backend always returns 2xx
  /// regardless of whether the email is on file, so this callback never
  /// throws on "unknown email" — it only throws on genuine failures
  /// (network, rate-limit). The UI must advance to a neutral success
  /// state rather than leaking the existence check.
  final Future<void> Function(String email)? onEmailPasswordForgot;

  /// Submit a password-reset code alongside the user's chosen new
  /// password. Throws on invalid / expired code so the screen can show
  /// an inline error. On success the host persists the returned tokens
  /// and updates auth state — the router redirect advances the user.
  final Future<void> Function(
    String email,
    String code,
    String newPassword,
  )? onEmailPasswordReset;

  // ─── Onboarding progress ─────────────────────────────────────────────

  /// Save birthday. Caller enforces 13+ locally before invoking.
  final Future<void> Function(DateTime dateOfBirth)? onSaveBirthday;

  /// Record a non-DOB birthday choice ("I prefer not to say",
  /// "I'm 18+", "Skip for now"). The [choice] value is one of the
  /// [AuthDobChoice] constants; the provider layer translates this
  /// into the appropriate backend patch (e.g. `birthdaySkipped: true`
  /// + `ageVerificationStatus: self_declared`).
  ///
  /// If the backend endpoint for the granular choice is not yet
  /// available, the mobile provider can stub this with a TODO —
  /// the screens still get a deterministic callback to navigate on.
  final Future<void> Function(AuthDobChoice choice)? onSaveDobChoice;

  /// Save profile fields (patch /users/me). [photoPath] is a local
  /// filesystem path to a freshly picked image (gallery or camera).
  /// Upload to S3 happens separately at the first media request on
  /// the resulting User — the host app wires this through to a later
  /// avatar-upload flow. When [photoPath] is null, no avatar change
  /// is implied.
  final Future<void> Function({
    String? displayName,
    String? username,
    String? avatarUrl,
    String? bio,
    String? photoPath,
  })? onSaveProfile;

  /// Persist onboarding interest selections (`POST /users/me/interests`).
  /// [interestIds] replaces the caller's declared interest set.
  final Future<void> Function(List<String> interestIds)? onSaveInterests;

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
