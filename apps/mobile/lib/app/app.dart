import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_auth/kuwboo_auth.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import '../features/auth/auth_callbacks.dart';
import 'router.dart';
import 'theme.dart';

/// Root widget for the Kuwboo mobile application.
///
/// Only watches the router here. State propagation happens in
/// [_ProtoStateBridge] below — scoping the Riverpod watch to a subtree
/// prevents the entire MaterialApp.router (and its nested Navigator with
/// GlobalKey) from rebuilding on every yoyo state change.
class KuwbooApp extends ConsumerWidget {
  const KuwbooApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return ProtoThemeProvider(
      theme: ProtoTheme.v0UrbanWarmth(),
      child: MaterialApp.router(
        title: 'Kuwboo',
        debugShowCheckedModeBanner: false,
        theme: KuwbooTheme.light,
        routerConfig: router,
        builder: (context, child) => _ProtoStateBridge(child: child ?? const SizedBox()),
      ),
    );
  }
}

/// Bridges Riverpod state into the legacy [ProtoStateAccess] InheritedWidget
/// so downstream screens (which still use `PrototypeStateProvider.of(context)`)
/// receive updates. Scoped to `MaterialApp.builder` so rebuilds don't
/// cascade to the router's child Navigator.
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
