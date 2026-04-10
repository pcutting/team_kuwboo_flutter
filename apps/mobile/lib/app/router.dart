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

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

// ─── Proto Shell Widget ─────────────────────────────────────────────────

/// Wraps the active screen in ProtoScaffold with the right-side notched FAB
/// service switcher and 4 per-service sub-tabs.
class _ProtoShellWrapper extends ConsumerWidget {
  final Widget child;
  const _ProtoShellWrapper({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shell = ref.watch(shellStateProvider);

    return ProtoScaffold(
      activeModule: shell.activeModule,
      activeTab: shell.activeTab,
      body: child,
    );
  }
}

// ─── Router Provider ─────────────────────────────────────────────────────

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: ProtoRoutes.yoyoNearby,
    redirect: (context, state) {
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
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/otp',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final phone = state.extra as String? ?? '';
          return OtpScreen(phone: phone);
        },
      ),
      GoRoute(
        path: '/onboarding',
        parentNavigatorKey: _rootNavigatorKey,
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
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const YoyoSettingsScreen(),
      ),
      GoRoute(
        path: ProtoRoutes.yoyoProfile,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const YoyoUserProfile(),
      ),
      GoRoute(
        path: ProtoRoutes.yoyoFilters,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const YoyoFilterSheet(),
      ),
      GoRoute(
        path: ProtoRoutes.videoComments,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const VideoCommentsSheet(),
      ),
      GoRoute(
        path: ProtoRoutes.videoEdit,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const VideoEditScreen(),
      ),
      GoRoute(
        path: ProtoRoutes.videoCreator,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const VideoCreatorProfile(),
      ),
      GoRoute(
        path: ProtoRoutes.videoSound,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const VideoSoundScreen(),
      ),
      GoRoute(
        path: ProtoRoutes.datingProfile,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DatingExpandedProfile(),
      ),
      GoRoute(
        path: ProtoRoutes.datingMatch,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DatingMatchOverlay(),
      ),
      GoRoute(
        path: ProtoRoutes.datingFilters,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DatingFiltersSheet(),
      ),
      GoRoute(
        path: ProtoRoutes.shopProduct,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ShopProductDetail(),
      ),
      GoRoute(
        path: ProtoRoutes.shopSeller,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ShopSellerProfile(),
      ),
      GoRoute(
        path: ProtoRoutes.shopAuction,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ShopAuctionDetail(),
      ),
      GoRoute(
        path: ProtoRoutes.chatConversation,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ChatConversationScreen(),
      ),
      GoRoute(
        path: ProtoRoutes.profileMy,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ProfileMyScreen(),
      ),
      GoRoute(
        path: ProtoRoutes.profileEdit,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ProfileEditScreen(),
      ),
      GoRoute(
        path: ProtoRoutes.profileSettings,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ProfileSettingsScreen(),
      ),
      GoRoute(
        path: ProtoRoutes.profileNotifications,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ProfileNotificationsScreen(),
      ),
    ],
  );
});
