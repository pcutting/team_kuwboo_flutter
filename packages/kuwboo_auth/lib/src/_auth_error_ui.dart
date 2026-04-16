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

/// Debug-only print helper used from catch blocks. Gated on `!kReleaseMode`
/// so release builds don't spam stdout. Crashlytics hookup lives elsewhere
/// (PR #120 and A3's patch).
void debugLogAuthError(String tag, Object error, StackTrace stack) {
  if (!kReleaseMode) {
    debugPrint('[$tag] $error\n$stack');
  }
}
