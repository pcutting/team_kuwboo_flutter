import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_auth/kuwboo_auth.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import '../features/auth/auth_callbacks.dart';
import 'router.dart';

/// Root widget for the Kuwboo web prototype.
///
/// Mirrors the mobile app architecture (Riverpod-backed state + GoRouter
/// routing) so the web prototype and mobile app consume the same shared
/// packages without divergence.
class PrototypeApp extends ConsumerWidget {
  const PrototypeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return ProtoThemeProvider(
      theme: ProtoTheme.v0UrbanWarmth(),
      child: MaterialApp.router(
        title: 'Kuwboo',
        debugShowCheckedModeBanner: false,
        routerConfig: router,
        builder: (context, child) => _ProtoStateBridge(child: child ?? const SizedBox()),
      ),
    );
  }
}

/// Bridges Riverpod state into the [ProtoStateAccess] InheritedWidget so
/// screens that still read via `PrototypeStateProvider.of(context)` pick up
/// updates. Scoped to `MaterialApp.builder` to keep yoyo state changes
/// from rebuilding the router and its shell Navigator.
class _ProtoStateBridge extends ConsumerWidget {
  final Widget child;
  const _ProtoStateBridge({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shell = ref.watch(shellStateProvider);
    final yoyo = ref.watch(yoyoStateProvider);
    final shellNotifier = ref.read(shellStateProvider.notifier);
    final yoyoNotifier = ref.read(yoyoStateProvider.notifier);

    final authCallbacks = ref.watch(authCallbacksProvider);

    return ProtoStateAccess(
      shell: shell,
      yoyo: yoyo,
      shellNotifier: shellNotifier,
      yoyoNotifier: yoyoNotifier,
      navigatorKey: rootNavigatorKey,
      child: KuwbooAuthFlow(
        callbacks: authCallbacks,
        child: child,
      ),
    );
  }
}
