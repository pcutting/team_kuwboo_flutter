import 'package:flutter/material.dart';
import 'badge_config.dart';

class BadgeConfigProvider extends InheritedNotifier<ValueNotifier<BadgeConfig>> {
  const BadgeConfigProvider({
    super.key,
    required ValueNotifier<BadgeConfig> notifier,
    required super.child,
  }) : super(notifier: notifier);

  static BadgeConfig of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<BadgeConfigProvider>();
    return provider?.notifier?.value ?? const BadgeConfig();
  }

  static ValueNotifier<BadgeConfig> notifierOf(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<BadgeConfigProvider>();
    return provider?.notifier ?? ValueNotifier(const BadgeConfig());
  }
}
