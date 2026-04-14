import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwboo_models/kuwboo_models.dart';
import 'package:kuwboo_screens/kuwboo_screens.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import '../features/auth/login_screen.dart';
import '../features/auth/onboarding_screen.dart';
import '../features/auth/otp_screen.dart';
import '../features/feed/presentation/shop_feed_mobile_screen.dart';
import '../features/feed/presentation/social_feed_mobile_screen.dart';
import '../features/feed/presentation/video_feed_mobile_screen.dart';
import '../features/feed/presentation/yoyo_nearby_mobile_screen.dart';
import '../providers/auth_provider.dart';

// ─── Onboarding resume ──────────────────────────────────────────────────

/// Canonical route for each [OnboardingProgress] step per the prototype
/// route table in `ProtoRoutes`. Returns `null` when the user has completed
/// onboarding and should proceed into the shell.
///
/// Mobile currently only implements three of these screens (`/login`,
/// `/otp`, `/onboarding`); the helper exposes the full prototype mapping
/// for callers that want it, and [_mobileOnboardingRoute] below collapses
/// the unimplemented steps onto the nearest mobile equivalent.
String? onboardingRouteFor(OnboardingProgress progress) {
  switch (progress) {
    case OnboardingProgress.welcome:
      return ProtoRoutes.authWelcome;
    case OnboardingProgress.method:
      return ProtoRoutes.authMethod;
    case OnboardingProgress.phone:
      return ProtoRoutes.authPhone;
    case OnboardingProgress.otp:
      return ProtoRoutes.authOtp;
    case OnboardingProgress.birthday:
      return ProtoRoutes.authBirthday;
    case OnboardingProgress.interests:
      return ProtoRoutes.authOnboarding;
    case OnboardingProgress.profile:
      return ProtoRoutes.authProfile;
    case OnboardingProgress.tutorial:
      return ProtoRoutes.authTutorial;
    case OnboardingProgress.complete:
      return null;
  }
}

/// Resolve the onboarding route to a concrete mobile route. Mobile only
/// ships `/login`, `/otp`, and `/onboarding` today — anything that would
/// land on a not-yet-implemented step falls back to the closest available
/// screen so the redirect never loops.
String? _mobileOnboardingRoute(OnboardingProgress progress) {
  switch (progress) {
    case OnboardingProgress.welcome:
    case OnboardingProgress.method:
    case OnboardingProgress.phone:
      return '/login';
    case OnboardingProgress.otp:
      return '/otp';
    case OnboardingProgress.birthday:
    case OnboardingProgress.interests:
    case OnboardingProgress.profile:
    case OnboardingProgress.tutorial:
      return '/onboarding';
    case OnboardingProgress.complete:
      return null;
  }
}

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
    for (final routes in ProtoRoutes.tabRoutes.values) {
      final idx = routes.indexOf(loc);
      if (idx >= 0) return idx;
    }
    return 0;
  }
}

// ─── Router Provider ─────────────────────────────────────────────────────

final routerProvider = Provider<GoRouter>((ref) {
  // Refresh the router whenever auth state changes, instead of rebuilding
  // the entire GoRouter. Rebuilding would recreate the shell navigator and
  // collide with the existing `_shellNavigatorKey` still mounted.
  final refresh = ValueNotifier<int>(0);
  ref.listen(authProvider, (_, next) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: ProtoRoutes.yoyoNearby,
    refreshListenable: refresh,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      if (authState.isLoading) return null;

      final isAuth = authState.isAuthenticated;
      final currentLoc = state.matchedLocation;
      final isAuthRoute = currentLoc == '/login' ||
          currentLoc == '/otp' ||
          currentLoc == '/onboarding';

      if (!isAuth && !isAuthRoute) return '/login';

      if (isAuth) {
        // Onboarding resume — honour `user.onboardingProgress` if the server
        // says the user is mid-flow. Falls back to the legacy `isNewUser`
        // flag when the user snapshot is not yet hydrated (e.g. fresh
        // verify-otp response that preceded the /users/me round-trip).
        final user = authState.user;
        final progress = user?.onboardingProgress;
        final resumeRoute = progress == null
            ? (authState.isNewUser ? '/onboarding' : null)
            : _mobileOnboardingRoute(progress);

        if (resumeRoute != null && currentLoc != resumeRoute) {
          return resumeRoute;
        }
        if (resumeRoute == null && isAuthRoute) {
          return ProtoRoutes.yoyoNearby;
        }
      }

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
        routes: buildProtoShellRoutes(
          yoyoNearbyOverride: () => const YoyoNearbyMobileScreen(),
          videoFeedOverride: () => const VideoFeedMobileScreen(),
          socialFeedOverride: () => const SocialFeedMobileScreen(),
          shopBrowseOverride: () => const ShopFeedMobileScreen(),
        ),
      ),

      // ── Sub-screens (push on top of shell) ──────────────────────────
      ...buildProtoModalRoutes(rootNavigatorKey: rootNavigatorKey),
    ],
  );
});
