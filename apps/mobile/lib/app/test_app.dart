import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import 'router.dart';
import 'theme.dart';

/// Test-friendly version of KuwbooApp that skips Firebase initialization.
/// Used by integration tests to avoid Firebase blocking on simulators.
class KuwbooTestApp extends ConsumerWidget {
  const KuwbooTestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final shell = ref.watch(shellStateProvider);
    final yoyo = ref.watch(yoyoStateProvider);
    final shellNotifier = ref.read(shellStateProvider.notifier);
    final yoyoNotifier = ref.read(yoyoStateProvider.notifier);

    return ProtoThemeProvider(
      theme: ProtoTheme.v0UrbanWarmth(),
      child: ProtoStateAccess(
        shell: shell,
        yoyo: yoyo,
        shellNotifier: shellNotifier,
        yoyoNotifier: yoyoNotifier,
        navigatorKey: rootNavigatorKey,
        child: MaterialApp.router(
          title: 'Kuwboo',
          debugShowCheckedModeBanner: false,
          theme: KuwbooTheme.light,
          routerConfig: router,
        ),
      ),
    );
  }
}
