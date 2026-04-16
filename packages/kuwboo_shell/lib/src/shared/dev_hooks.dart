import 'package:flutter/widgets.dart';

/// Carries debug-only callbacks down the widget tree so shared widgets in
/// `kuwboo_shell` (which cannot import Riverpod or the mobile auth provider)
/// can wire up debug affordances without every caller having to plumb them
/// through manually.
///
/// The only current consumer is [ProtoProfileMenu] (via [ProtoTopBar]), which
/// reads [onResetOnboarding] and surfaces a "Reset onboarding (dev)" item
/// when both this widget is present AND `kDebugMode` is true. Release builds
/// should simply not wrap the tree with a `DevHooks` — but `kDebugMode` is a
/// belt-and-braces gate inside the consumer too.
class DevHooks extends InheritedWidget {
  /// Clears auth tokens + provider state and routes back to `/auth/welcome`.
  /// Null when the host app does not expose a reset affordance (production
  /// builds, or the web prototype which has no real auth state).
  final VoidCallback? onResetOnboarding;

  const DevHooks({
    super.key,
    required this.onResetOnboarding,
    required super.child,
  });

  static DevHooks? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DevHooks>();
  }

  @override
  bool updateShouldNotify(DevHooks oldWidget) =>
      onResetOnboarding != oldWidget.onResetOnboarding;
}
