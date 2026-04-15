import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwboo_screens/kuwboo_screens.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import '../features/feed/presentation/shop_feed_mobile_screen.dart';
import '../features/feed/presentation/social_feed_mobile_screen.dart';
import '../features/feed/presentation/video_feed_mobile_screen.dart';
import '../features/feed/presentation/yoyo_nearby_mobile_screen.dart';

// ─── Navigation Keys ─────────────────────────────────────────────────────

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

// ─── Proto Shell Widget ─────────────────────────────────────────────────

class _ProtoShellWrapper extends StatelessWidget {
  final Widget child;
  const _ProtoShellWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final activeModule = _moduleFor(location);
    final activeTab = _tabFor(location);
    final isYoyoNearby = activeModule == ProtoModule.yoyo && activeTab == 0;

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
        routes: buildProtoShellRoutes(
          yoyoNearbyOverride: () => const YoyoNearbyMobileScreen(),
          videoFeedOverride: () => const VideoFeedMobileScreen(),
          socialFeedOverride: () => const SocialFeedMobileScreen(),
          shopBrowseOverride: () => const ShopFeedMobileScreen(),
        ),
      ),
      ...buildProtoModalRoutes(rootNavigatorKey: rootNavigatorKey),
    ],
  );
});
