import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';
import 'package:kuwboo_screens/kuwboo_screens.dart';
import 'package:kuwboo_chat/kuwboo_chat.dart';

import '../features/auth/login_screen.dart';
import '../features/auth/onboarding_screen.dart';
import '../features/auth/otp_screen.dart';
import '../providers/auth_provider.dart';

// ─── Navigation Keys ─────────────────────────────────────────────────────

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

// ─── Proto Shell Widget ─────────────────────────────────────────────────

/// Wraps the active screen in ProtoScaffold with the right-side notched FAB
/// service switcher and 4 per-service sub-tabs.
class _ProtoShellWrapper extends StatelessWidget {
  final Widget child;
  const _ProtoShellWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    // Derive module + tab from the current GoRouter location instead of
    // watching a Riverpod provider. Watching here would make the shell rebuild
    // in the same frame as GoRouter's own ShellRoute rebuild, leaving two
    // copies of the child Navigator (with its GlobalKey) in the tree.
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
    // YoYo: 0=nearby 1=connect 2=wave 3=chat
    if (loc == ProtoRoutes.yoyoNearby) return 0;
    if (loc == ProtoRoutes.yoyoConnect) return 1;
    if (loc == ProtoRoutes.yoyoWave) return 2;
    if (loc == ProtoRoutes.yoyoChat) return 3;
    return 0;
  }
}

// ─── Router Provider ─────────────────────────────────────────────────────

final routerProvider = Provider<GoRouter>((ref) {
  // Refresh the router whenever auth state changes, instead of rebuilding
  // the entire GoRouter. Rebuilding would recreate the shell navigator and
  // collide with the existing `_shellNavigatorKey` still mounted.
  final refresh = ValueNotifier<int>(0);
  ref.listen(authProvider, (_, __) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: ProtoRoutes.yoyoNearby,
    refreshListenable: refresh,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      if (authState.isLoading) return null;

      final isAuth = authState.isAuthenticated;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/otp' ||
          state.matchedLocation == '/onboarding';

      if (!isAuth && !isAuthRoute) return '/login';
      if (isAuth && authState.isNewUser) return '/onboarding';
      if (isAuth && isAuthRoute) return ProtoRoutes.yoyoNearby;

      return null;
    },
    routes: [
      // ── Auth Routes ──────────────────────────────────────────────────
      GoRoute(
        path: '/login',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/otp',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final phone = state.extra as String? ?? '';
          return OtpScreen(phone: phone);
        },
      ),
      GoRoute(
        path: '/onboarding',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // ── Main Shell (ProtoScaffold with notched FAB) ─────────────────
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => _ProtoShellWrapper(child: child),
        routes: [
          // ── YoYo ──────────────────────────────────────────────────
          GoRoute(
            path: ProtoRoutes.yoyoNearby,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: YoyoNearbyScreen(),
            ),
          ),
          GoRoute(
            path: ProtoRoutes.yoyoConnect,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: YoyoConnectScreen(),
            ),
          ),
          GoRoute(
            path: ProtoRoutes.yoyoWave,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: YoyoWaveScreen(),
            ),
          ),
          GoRoute(
            path: ProtoRoutes.yoyoChat,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ChatInboxScreen(moduleKey: 'YoYo'),
            ),
          ),

          // ── Video ─────────────────────────────────────────────────
          GoRoute(
            path: ProtoRoutes.videoFeed,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: VideoFeedScreen(),
            ),
          ),
          GoRoute(
            path: ProtoRoutes.videoFollowing,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: VideoFeedScreen(isFollowingFeed: true),
            ),
          ),
          GoRoute(
            path: ProtoRoutes.videoDiscover,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: VideoDiscoverScreen(),
            ),
          ),
          GoRoute(
            path: ProtoRoutes.videoRecord,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: VideoRecordingScreen(),
            ),
          ),

          // ── Dating ────────────────────────────────────────────────
          GoRoute(
            path: ProtoRoutes.datingCards,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DatingCardStack(),
            ),
          ),
          GoRoute(
            path: ProtoRoutes.datingMatches,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DatingMatchesList(),
            ),
          ),
          GoRoute(
            path: ProtoRoutes.datingLikes,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DatingLikesScreen(),
            ),
          ),
          GoRoute(
            path: ProtoRoutes.datingChat,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ChatInboxScreen(moduleKey: 'Dating'),
            ),
          ),

          // ── Social ────────────────────────────────────────────────
          GoRoute(
            path: ProtoRoutes.socialFeed,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SocialFeedScreen(),
            ),
          ),
          GoRoute(
            path: ProtoRoutes.socialFriends,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SocialFriendsList(),
            ),
          ),
          GoRoute(
            path: ProtoRoutes.socialEvents,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SocialEventsScreen(),
            ),
          ),
          GoRoute(
            path: ProtoRoutes.socialCompose,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SocialComposerScreen(),
            ),
          ),

          // ── Shop ──────────────────────────────────────────────────
          GoRoute(
            path: ProtoRoutes.shopBrowse,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ShopBrowseScreen(),
            ),
          ),
          GoRoute(
            path: ProtoRoutes.shopDeals,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ShopDealsScreen(),
            ),
          ),
          GoRoute(
            path: ProtoRoutes.shopCreate,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ShopCreateListing(),
            ),
          ),
          GoRoute(
            path: ProtoRoutes.chatInbox,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ChatInboxScreen(),
            ),
          ),
        ],
      ),

      // ── Sub-screens (push on top of shell) ──────────────────────────
      GoRoute(
        path: ProtoRoutes.yoyoSettings,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const YoyoSettingsScreen(),
      ),
      GoRoute(
        path: ProtoRoutes.yoyoProfile,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const YoyoUserProfile(),
      ),
      GoRoute(
        path: ProtoRoutes.yoyoFilters,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const YoyoFilterSheet(),
      ),
      GoRoute(
        path: ProtoRoutes.videoComments,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const VideoCommentsSheet(),
      ),
      GoRoute(
        path: ProtoRoutes.videoEdit,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const VideoEditScreen(),
      ),
      GoRoute(
        path: ProtoRoutes.videoCreator,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const VideoCreatorProfile(),
      ),
      GoRoute(
        path: ProtoRoutes.videoSound,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const VideoSoundScreen(),
      ),
      GoRoute(
        path: ProtoRoutes.datingProfile,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const DatingExpandedProfile(),
      ),
      GoRoute(
        path: ProtoRoutes.datingMatch,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const DatingMatchOverlay(),
      ),
      GoRoute(
        path: ProtoRoutes.datingFilters,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const DatingFiltersSheet(),
      ),
      GoRoute(
        path: ProtoRoutes.shopProduct,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ShopProductDetail(),
      ),
      GoRoute(
        path: ProtoRoutes.shopSeller,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ShopSellerProfile(),
      ),
      GoRoute(
        path: ProtoRoutes.shopAuction,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ShopAuctionDetail(),
      ),
      GoRoute(
        path: ProtoRoutes.chatConversation,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ChatConversationScreen(),
      ),
      GoRoute(
        path: ProtoRoutes.profileMy,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ProfileMyScreen(),
      ),
      GoRoute(
        path: ProtoRoutes.profileEdit,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ProfileEditScreen(),
      ),
      GoRoute(
        path: ProtoRoutes.profileSettings,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ProfileSettingsScreen(),
      ),
      GoRoute(
        path: ProtoRoutes.profileNotifications,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ProfileNotificationsScreen(),
      ),
    ],
  );
});
