import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwboo_screens/kuwboo_screens.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

// ─── Navigation Keys ─────────────────────────────────────────────────────

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

// ─── Shell Wrapper ───────────────────────────────────────────────────────

class _ProtoShellWrapper extends ConsumerWidget {
  final Widget child;
  const _ProtoShellWrapper({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final activeModule = _moduleFor(location);
    final activeTab = _tabFor(location);
    final isYoyoNearby = activeModule == ProtoModule.yoyo && activeTab == 0;

    // Sync the global shell state with the URL-derived module/tab so any
    // consumer that reads `state.activeModule` (popup labels, top-bar
    // titles in screens not yet migrated, etc.) stays coherent with the
    // current route. Done in a post-frame callback to avoid mutating
    // providers during a build.
    final shell = ref.read(shellStateProvider);
    if (shell.activeModule != activeModule || shell.activeTab != activeTab) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final notifier = ref.read(shellStateProvider.notifier);
        final current = ref.read(shellStateProvider);
        // switchModule resets activeTab to 0, so run it first then set the
        // correct tab unconditionally if it differs from the URL-derived one.
        if (current.activeModule != activeModule) {
          notifier.switchModule(activeModule);
        }
        if (ref.read(shellStateProvider).activeTab != activeTab) {
          notifier.switchTab(activeTab);
        }
      });
    }

    return ProtoScaffold(
      activeModule: activeModule,
      activeTab: activeTab,
      tabBadges: isYoyoNearby ? const {2: 2} : null,
      body: child,
    );
  }

  static ProtoModule _moduleFor(String loc) {
    if (loc.startsWith('/yoyo')) return ProtoModule.yoyo;
    if (loc.startsWith('/video')) return ProtoModule.video;
    if (loc.startsWith('/dating')) return ProtoModule.dating;
    if (loc.startsWith('/social')) return ProtoModule.social;
    if (loc.startsWith('/shop')) return ProtoModule.shop;
    return ProtoModule.yoyo;
  }

  static int _tabFor(String loc) {
    for (final routes in ProtoRoutes.tabRoutes.values) {
      final idx = routes.indexOf(loc);
      if (idx >= 0) return idx;
    }
    return 0;
  }
}

// ─── Router Provider ─────────────────────────────────────────────────────

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: ProtoRoutes.yoyoNearby,
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => _ProtoShellWrapper(child: child),
        routes: buildProtoShellRoutes(),
      ),
      ...buildProtoModalRoutes(rootNavigatorKey: rootNavigatorKey),
    ],
  );
});
