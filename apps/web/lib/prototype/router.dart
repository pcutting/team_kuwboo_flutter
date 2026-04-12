import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';
import 'package:kuwboo_screens/kuwboo_screens.dart';
import 'package:kuwboo_chat/kuwboo_chat.dart';

// ─── Navigation Keys ─────────────────────────────────────────────────────

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

// ─── Shell Wrapper ───────────────────────────────────────────────────────

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
    if (loc == ProtoRoutes.yoyoNearby) return 0;
    if (loc == ProtoRoutes.yoyoConnect) return 1;
    if (loc == ProtoRoutes.yoyoWave) return 2;
    if (loc == ProtoRoutes.yoyoChat) return 3;
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
        routes: [
          // YoYo
          GoRoute(path: ProtoRoutes.yoyoNearby, pageBuilder: (c, s) => const NoTransitionPage(child: YoyoNearbyScreen())),
          GoRoute(path: ProtoRoutes.yoyoConnect, pageBuilder: (c, s) => const NoTransitionPage(child: YoyoConnectScreen())),
          GoRoute(path: ProtoRoutes.yoyoWave, pageBuilder: (c, s) => const NoTransitionPage(child: YoyoWaveScreen())),
          GoRoute(path: ProtoRoutes.yoyoChat, pageBuilder: (c, s) => const NoTransitionPage(child: ChatInboxScreen(moduleKey: 'YoYo'))),
          // Video
          GoRoute(path: ProtoRoutes.videoFeed, pageBuilder: (c, s) => const NoTransitionPage(child: VideoFeedScreen())),
          GoRoute(path: ProtoRoutes.videoFollowing, pageBuilder: (c, s) => const NoTransitionPage(child: VideoFeedScreen(isFollowingFeed: true))),
          GoRoute(path: ProtoRoutes.videoDiscover, pageBuilder: (c, s) => const NoTransitionPage(child: VideoDiscoverScreen())),
          GoRoute(path: ProtoRoutes.videoRecord, pageBuilder: (c, s) => const NoTransitionPage(child: VideoRecordingScreen())),
          // Dating
          GoRoute(path: ProtoRoutes.datingCards, pageBuilder: (c, s) => const NoTransitionPage(child: DatingCardStack())),
          GoRoute(path: ProtoRoutes.datingMatches, pageBuilder: (c, s) => const NoTransitionPage(child: DatingMatchesList())),
          GoRoute(path: ProtoRoutes.datingLikes, pageBuilder: (c, s) => const NoTransitionPage(child: DatingLikesScreen())),
          GoRoute(path: ProtoRoutes.datingChat, pageBuilder: (c, s) => const NoTransitionPage(child: ChatInboxScreen(moduleKey: 'Dating'))),
          // Social
          GoRoute(path: ProtoRoutes.socialFeed, pageBuilder: (c, s) => const NoTransitionPage(child: SocialFeedScreen())),
          GoRoute(path: ProtoRoutes.socialFriends, pageBuilder: (c, s) => const NoTransitionPage(child: SocialFriendsList())),
          GoRoute(path: ProtoRoutes.socialEvents, pageBuilder: (c, s) => const NoTransitionPage(child: SocialEventsScreen())),
          GoRoute(path: ProtoRoutes.socialCompose, pageBuilder: (c, s) => const NoTransitionPage(child: SocialComposerScreen())),
          // Shop
          GoRoute(path: ProtoRoutes.shopBrowse, pageBuilder: (c, s) => const NoTransitionPage(child: ShopBrowseScreen())),
          GoRoute(path: ProtoRoutes.shopDeals, pageBuilder: (c, s) => const NoTransitionPage(child: ShopDealsScreen())),
          GoRoute(path: ProtoRoutes.shopCreate, pageBuilder: (c, s) => const NoTransitionPage(child: ShopCreateListing())),
          GoRoute(path: ProtoRoutes.chatInbox, pageBuilder: (c, s) => const NoTransitionPage(child: ChatInboxScreen())),
        ],
      ),
      // Sub-screens (push on top of shell)
      GoRoute(path: ProtoRoutes.yoyoSettings, parentNavigatorKey: rootNavigatorKey, builder: (c, s) => const YoyoSettingsScreen()),
      GoRoute(path: ProtoRoutes.yoyoProfile, parentNavigatorKey: rootNavigatorKey, builder: (c, s) => const YoyoUserProfile()),
      GoRoute(path: ProtoRoutes.yoyoFilters, parentNavigatorKey: rootNavigatorKey, builder: (c, s) => const YoyoFilterSheet()),
      GoRoute(path: ProtoRoutes.videoComments, parentNavigatorKey: rootNavigatorKey, builder: (c, s) => const VideoCommentsSheet()),
      GoRoute(path: ProtoRoutes.videoEdit, parentNavigatorKey: rootNavigatorKey, builder: (c, s) => const VideoEditScreen()),
      GoRoute(path: ProtoRoutes.videoCreator, parentNavigatorKey: rootNavigatorKey, builder: (c, s) => const VideoCreatorProfile()),
      GoRoute(path: ProtoRoutes.videoSound, parentNavigatorKey: rootNavigatorKey, builder: (c, s) => const VideoSoundScreen()),
      GoRoute(path: ProtoRoutes.datingProfile, parentNavigatorKey: rootNavigatorKey, builder: (c, s) => const DatingExpandedProfile()),
      GoRoute(path: ProtoRoutes.datingMatch, parentNavigatorKey: rootNavigatorKey, builder: (c, s) => const DatingMatchOverlay()),
      GoRoute(path: ProtoRoutes.datingFilters, parentNavigatorKey: rootNavigatorKey, builder: (c, s) => const DatingFiltersSheet()),
      GoRoute(path: ProtoRoutes.shopProduct, parentNavigatorKey: rootNavigatorKey, builder: (c, s) => const ShopProductDetail()),
      GoRoute(path: ProtoRoutes.shopSeller, parentNavigatorKey: rootNavigatorKey, builder: (c, s) => const ShopSellerProfile()),
      GoRoute(path: ProtoRoutes.shopAuction, parentNavigatorKey: rootNavigatorKey, builder: (c, s) => const ShopAuctionDetail()),
      GoRoute(path: ProtoRoutes.chatConversation, parentNavigatorKey: rootNavigatorKey, builder: (c, s) => const ChatConversationScreen()),
      GoRoute(path: ProtoRoutes.profileMy, parentNavigatorKey: rootNavigatorKey, builder: (c, s) => const ProfileMyScreen()),
      GoRoute(path: ProtoRoutes.profileEdit, parentNavigatorKey: rootNavigatorKey, builder: (c, s) => const ProfileEditScreen()),
      GoRoute(path: ProtoRoutes.profileSettings, parentNavigatorKey: rootNavigatorKey, builder: (c, s) => const ProfileSettingsScreen()),
      GoRoute(path: ProtoRoutes.profileNotifications, parentNavigatorKey: rootNavigatorKey, builder: (c, s) => const ProfileNotificationsScreen()),
    ],
  );
});
