import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Displays a user-visible error from any auth screen.
///
/// Tries `ScaffoldMessenger.of(context).showSnackBar(...)` first, which is
/// the preferred affordance. If no `ScaffoldMessenger` / `Scaffold` ancestor
/// is present (which throws `NoSuchWidgetError` — a `dart:core` `Error`, not
/// an `Exception`) it falls back to an `AlertDialog` so the user still sees
/// the failure instead of the button silently resetting.
///
/// The silent-error mode that motivated this helper: every auth screen was
/// calling `ScaffoldMessenger.of(context).showSnackBar(...)` inside a bare
/// `catch (e) { ... }`. Bare `catch` clauses only catch `Exception` by
/// default, so `NoSuchWidgetError` from a missing `Scaffold` ancestor
/// bypassed the handler entirely and the user saw nothing.
void showAuthError(BuildContext context, String message) {
  try {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 5)),
    );
  } catch (_) {
    // No Scaffold/ScaffoldMessenger ancestor — fall back to a dialog, which
    // doesn't need one.
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// Logs an auth-flow exception to the right place for the current build mode.
///
/// - Debug / profile builds: `debugPrint` to stdout so the developer sees it
///   in the attached console. Gated on `!kReleaseMode` so release builds
///   don't spam stdout.
/// - Release builds: forwarded to Firebase Crashlytics with `reason` set to
///   the catch-block tag (e.g. `auth/otp-verify`) so TestFlight / App Store
///   failures are debuggable post-hoc. Wrapped in try/catch because
///   `FirebaseCrashlytics.instance` throws if Firebase wasn't initialised —
///   which can happen on dev simulator builds that intentionally skip
///   `google-services.json`. We never want diagnostic code to crash the app.
void debugLogAuthError(String tag, Object error, StackTrace stack) {
  if (!kReleaseMode) {
    debugPrint('[$tag] $error\n$stack');
    return;
  }
  try {
    FirebaseCrashlytics.instance.recordError(error, stack, reason: tag);
  } catch (_) {
    // Firebase not initialised (or plugin missing) — swallow so a logging
    // failure never masks the original error the caller is handling.
  }
}
