import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/login_screen.dart';
import '../features/auth/onboarding_screen.dart';
import '../features/auth/otp_screen.dart';
import '../features/chat/chat_conversation_screen.dart';
import '../features/chat/chat_inbox_screen.dart';
import '../features/home/home_shell.dart';
import '../features/profile/profile_screen.dart';
import '../features/shop/auction_detail_screen.dart';
import '../features/shop/create_listing_screen.dart';
import '../features/shop/product_detail_screen.dart';
import '../features/shop/shop_browse_screen.dart';
import '../features/social/social_feed_screen.dart';
import '../features/video/video_feed_screen.dart';
import '../features/yoyo/yoyo_screen.dart';
import '../providers/auth_provider.dart';

// ─── Navigation Keys ─────────────────────────────────────────────────────

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

// ─── Router Provider ─────────────────────────────────────────────────────

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/video',
    redirect: (context, state) {
      if (authState.isLoading) return null;

      final isAuth = authState.isAuthenticated;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/otp' ||
          state.matchedLocation == '/onboarding';

      if (!isAuth && !isAuthRoute) return '/login';
      if (isAuth && authState.isNewUser) return '/onboarding';
      if (isAuth && isAuthRoute) return '/video';

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

      // ── Main Shell (Bottom Nav) ──────────────────────────────────────
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: '/video',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: VideoFeedScreen(),
            ),
          ),
          GoRoute(
            path: '/social',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SocialFeedScreen(),
            ),
          ),
          GoRoute(
            path: '/shop',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ShopBrowseScreen(),
            ),
          ),
          GoRoute(
            path: '/yoyo',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: YoyoScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),

      // ── Shop Detail Routes ───────────────────────────────────────────
      GoRoute(
        path: '/shop/product/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProductDetailScreen(productId: id);
        },
      ),
      GoRoute(
        path: '/shop/create',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CreateListingScreen(),
      ),
      GoRoute(
        path: '/shop/auction/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AuctionDetailScreen(auctionId: id);
        },
      ),

      // ── Chat Routes ──────────────────────────────────────────────────
      GoRoute(
        path: '/chat',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ChatInboxScreen(),
      ),
      GoRoute(
        path: '/chat/:threadId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final threadId = state.pathParameters['threadId']!;
          return ChatConversationScreen(threadId: threadId);
        },
      ),
    ],
  );
});
