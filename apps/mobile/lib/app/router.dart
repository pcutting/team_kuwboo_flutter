import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwboo_models/kuwboo_models.dart';
import 'package:kuwboo_screens/kuwboo_screens.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import '../features/feed/presentation/shop_feed_mobile_screen.dart';
import '../features/feed/presentation/social_feed_mobile_screen.dart';
import '../features/feed/presentation/video_feed_mobile_screen.dart';
import '../features/feed/presentation/yoyo_nearby_mobile_screen.dart';
import '../providers/auth_provider.dart';

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
  // Rebuild redirects whenever auth state changes, WITHOUT rebuilding the
  // router itself (which would collide with the already-mounted shell
  // navigator's GlobalKey).
  final refresh = ValueNotifier<int>(0);
  ref.listen(authProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: ProtoRoutes.yoyoNearby,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      if (auth.isLoading) return null;

      final loc = state.matchedLocation;
      final onAuthRoute = loc.startsWith('/auth/');

      if (!auth.isAuthenticated) {
        // Unauthenticated users only see the auth sub-tree. Any other path
        // bounces them to the welcome screen.
        return onAuthRoute ? null : ProtoRoutes.authWelcome;
      }

      if (auth.isNewUser) {
        // Authenticated but mid-onboarding — let them roam inside /auth/*
        // so they can finish the flow. If they try to escape, push them
        // back to the step they were on (resume onboarding rather than
        // restarting at the method picker).
        if (onAuthRoute) return null;
        return _onboardingResumeRoute(auth.user?.onboardingProgress);
      }

      // Fully onboarded — route out of /auth/* into the main shell.
      if (onAuthRoute) return ProtoRoutes.yoyoNearby;
      return null;
    },
    routes: [
      // Auth sub-tree — screens + route builders live in kuwboo_auth via
      // buildProtoModalRoutes(). AuthCallbacksScope (provided by
      // KuwbooAuthFlow in app.dart) wraps the whole tree so screens can
      // reach the mobile-side AuthCallbacks.
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

/// Maps the authenticated user's [OnboardingProgress] to the auth route
/// that resumes them at the right step. Called from the router redirect
/// when an onboarding-in-progress user lands on a non-/auth path.
String _onboardingResumeRoute(OnboardingProgress? progress) {
  switch (progress) {
    case OnboardingProgress.complete:
      // Defensive — isNewUser should be false here. Fall back to the shell.
      return ProtoRoutes.yoyoNearby;
    case OnboardingProgress.tutorial:
      return ProtoRoutes.authTutorial;
    case OnboardingProgress.profile:
      return ProtoRoutes.authProfile;
    case OnboardingProgress.birthday:
      return ProtoRoutes.authBirthday;
    case OnboardingProgress.welcome:
    case OnboardingProgress.method:
    case OnboardingProgress.phone:
    case OnboardingProgress.otp:
    case OnboardingProgress.interests:
    case null:
      return ProtoRoutes.authMethod;
  }
}
