import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwboo_models/kuwboo_models.dart';
import 'package:kuwboo_screens/kuwboo_screens.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import '../providers/auth_provider.dart';

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

    // Video module uses an overlay (transparent) top bar so the feed
    // stays edge-to-edge and the gradient shows through behind the
    // frosted YoYo / chat / profile icons.
    final useOverlayTopBar = activeModule == ProtoModule.video;

    return ProtoScaffold(
      activeModule: activeModule,
      activeTab: activeTab,
      tabBadges: isYoyoNearby ? const {2: 2} : null,
      overlayTopBar: useOverlayTopBar,
      backgroundColor: useOverlayTopBar ? Colors.black : null,
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
  // Rebuild redirects whenever auth state changes, without recreating
  // the router (which would collide with the mounted shell navigator's
  // GlobalKey).
  final refresh = ValueNotifier<int>(0);
  ref.listen(authProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    // Start in the auth sub-tree so unauthenticated refreshes don't
    // briefly mount shell screens that fire authenticated API calls.
    // The redirect below bounces authenticated users out to the shell.
    initialLocation: ProtoRoutes.authWelcome,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      if (auth.isLoading) return null;

      final loc = state.matchedLocation;
      final onAuthRoute = loc.startsWith('/auth/');

      if (!auth.isAuthenticated) {
        return onAuthRoute ? null : ProtoRoutes.authWelcome;
      }

      if (auth.isNewUser) {
        if (onAuthRoute) return null;
        return _onboardingResumeRoute(auth.user?.onboardingProgress);
      }

      if (onAuthRoute) return ProtoRoutes.yoyoNearby;
      return null;
    },
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

/// Resume users at the auth step matching their saved onboarding progress.
String _onboardingResumeRoute(OnboardingProgress? progress) {
  switch (progress) {
    case OnboardingProgress.complete:
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
