import 'package:flutter/material.dart';

/// The five main modules in Kuwboo, mapped to bottom nav tabs
enum ProtoModule { video, dating, yoyo, social, shop }

/// Provides the current prototype state (active module, navigator key)
/// down through the widget tree via InheritedWidget.
class PrototypeStateProvider extends InheritedWidget {
  final ProtoModule activeModule;
  final GlobalKey<NavigatorState> navigatorKey;
  final ValueChanged<ProtoModule> onModuleChanged;
  final bool isYoyoAreaView;
  final VoidCallback onYoyoViewToggle;

  // YoYo radar & filter state
  final double yoyoRange;
  final ValueChanged<double> onYoyoRangeChanged;
  final bool isYoyoHidden;
  final VoidCallback onYoyoHiddenToggle;
  final bool yoyoFriendsOnly;
  final VoidCallback onYoyoFriendsOnlyToggle;
  final Set<String> yoyoSelectedInterests;
  final ValueChanged<Set<String>> onYoyoInterestsChanged;

  // YoYo settings & connect state
  final bool yoyoShowOnline;
  final ValueChanged<bool> onYoyoShowOnlineChanged;
  final bool yoyoShowDistance;
  final ValueChanged<bool> onYoyoShowDistanceChanged;
  final String yoyoConnectFilter;
  final ValueChanged<String> onYoyoConnectFilterChanged;

  // YoYo V2 state
  final bool yoyoV2SessionActive;
  final VoidCallback onYoyoV2SessionToggle;
  final int yoyoV2SessionDuration;
  final ValueChanged<int> onYoyoV2SessionDurationChanged;
  final int yoyoV2DataRetentionHours;
  final ValueChanged<int> onYoyoV2DataRetentionChanged;
  final int yoyoV2VisibilityTier;
  final ValueChanged<int> onYoyoV2VisibilityTierChanged;
  final String yoyoV2EncounterFilter;
  final ValueChanged<String> onYoyoV2EncounterFilterChanged;
  final String yoyoV2RelationshipFilter;
  final ValueChanged<String> onYoyoV2RelationshipFilterChanged;
  final bool yoyoV2EncounterTransparency;
  final ValueChanged<bool> onYoyoV2EncounterTransparencyChanged;

  // YoYo Go Live state (visibility timer)
  final bool yoyoLiveActive;
  final VoidCallback onYoyoLiveToggle;
  final int yoyoLiveDuration; // 0=30m, 1=2h, 2=8h, 3=Always
  final ValueChanged<int> onYoyoLiveDurationChanged;

  // YoYo full-screen radar
  final bool isRadarFullscreen;
  final VoidCallback onRadarFullscreenToggle;

  // YoYo mode (0 = Social, 1 = Inner Circle) — toggles context for all tabs
  final int yoyoMode;
  final ValueChanged<int> onYoyoModeChanged;

  // Global preferences
  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeChanged;

  const PrototypeStateProvider({
    super.key,
    required this.activeModule,
    required this.navigatorKey,
    required this.onModuleChanged,
    required this.isYoyoAreaView,
    required this.onYoyoViewToggle,
    required this.yoyoRange,
    required this.onYoyoRangeChanged,
    required this.isYoyoHidden,
    required this.onYoyoHiddenToggle,
    required this.yoyoFriendsOnly,
    required this.onYoyoFriendsOnlyToggle,
    required this.yoyoSelectedInterests,
    required this.onYoyoInterestsChanged,
    required this.yoyoShowOnline,
    required this.onYoyoShowOnlineChanged,
    required this.yoyoShowDistance,
    required this.onYoyoShowDistanceChanged,
    required this.yoyoConnectFilter,
    required this.onYoyoConnectFilterChanged,
    required this.yoyoV2SessionActive,
    required this.onYoyoV2SessionToggle,
    required this.yoyoV2SessionDuration,
    required this.onYoyoV2SessionDurationChanged,
    required this.yoyoV2DataRetentionHours,
    required this.onYoyoV2DataRetentionChanged,
    required this.yoyoV2VisibilityTier,
    required this.onYoyoV2VisibilityTierChanged,
    required this.yoyoV2EncounterFilter,
    required this.onYoyoV2EncounterFilterChanged,
    required this.yoyoV2RelationshipFilter,
    required this.onYoyoV2RelationshipFilterChanged,
    required this.yoyoV2EncounterTransparency,
    required this.onYoyoV2EncounterTransparencyChanged,
    required this.yoyoLiveActive,
    required this.onYoyoLiveToggle,
    required this.yoyoLiveDuration,
    required this.onYoyoLiveDurationChanged,
    required this.isRadarFullscreen,
    required this.onRadarFullscreenToggle,
    required this.yoyoMode,
    required this.onYoyoModeChanged,
    required this.isDarkMode,
    required this.onDarkModeChanged,
    required super.child,
  });

  static PrototypeStateProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PrototypeStateProvider>()!;
  }

  static PrototypeStateProvider? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PrototypeStateProvider>();
  }

  /// Navigate to a module's home screen, clearing the stack.
  void switchModule(ProtoModule module) {
    onModuleChanged(module);
    final route = _homeRoute(module);
    navigatorKey.currentState?.pushNamedAndRemoveUntil(route, (_) => false);
  }

  /// Navigate to a sub-feature tab within the current module.
  void switchTab(int tabIndex) {
    final route = _tabRoute(activeModule, tabIndex);
    if (route != null) {
      navigatorKey.currentState?.pushNamedAndRemoveUntil(route, (_) => false);
    }
  }

  /// Push a sub-screen onto the current module's stack
  void push(String routeName) {
    navigatorKey.currentState?.pushNamed(routeName);
  }

  void pushWithArgs(String routeName, Object arguments) {
    navigatorKey.currentState?.pushNamed(routeName, arguments: arguments);
  }

  /// Pop the current screen. If the stack is empty (e.g. after switchTab
  /// cleared it), navigate to the current module's home screen instead.
  void pop() {
    if (navigatorKey.currentState?.canPop() ?? false) {
      navigatorKey.currentState?.pop();
    } else {
      final route = _homeRoute(activeModule);
      navigatorKey.currentState?.pushReplacementNamed(route);
    }
  }

  static String _homeRoute(ProtoModule module) {
    switch (module) {
      case ProtoModule.video:
        return '/video/feed';
      case ProtoModule.dating:
        return '/dating/cards';
      case ProtoModule.yoyo:
        return '/yoyo/nearby';
      case ProtoModule.social:
        return '/social/feed';
      case ProtoModule.shop:
        return '/shop/browse';
    }
  }

  /// Maps (module, tabIndex) to the corresponding route.
  static String? _tabRoute(ProtoModule module, int tabIndex) {
    const routes = <ProtoModule, List<String>>{
      ProtoModule.video: [
        '/video/feed',      // Tab 0: For You
        '/video/following', // Tab 1: Following
        '/video/discover',  // Tab 2: Discover
        '/video/record',    // Tab 3: Create
      ],
      ProtoModule.dating: [
        '/dating/cards',    // Tab 0: Discover
        '/dating/matches',  // Tab 1: Matches
        '/dating/likes',    // Tab 2: Likes
        '/dating/chat',     // Tab 3: Chat
      ],
      ProtoModule.yoyo: [
        '/yoyo/nearby',     // Tab 0: Nearby
        '/yoyo/connect',    // Tab 1: Connect
        '/yoyo/wave',       // Tab 2: Wave
        '/yoyo/chat',       // Tab 3: Chat
      ],
      ProtoModule.social: [
        '/social/feed',     // Tab 0: Stumble
        '/social/friends',  // Tab 1: Friends
        '/social/events',   // Tab 2: Events
        '/social/compose',  // Tab 3: Post
      ],
      ProtoModule.shop: [
        '/shop/browse',     // Tab 0: Browse
        '/shop/deals',      // Tab 1: Deals
        '/shop/create',     // Tab 2: Sell
        '/chat/inbox',      // Tab 3: Messages (unified chat)
      ],
    };

    final moduleRoutes = routes[module];
    if (moduleRoutes == null || tabIndex < 0 || tabIndex >= moduleRoutes.length) {
      return null;
    }
    return moduleRoutes[tabIndex];
  }

  @override
  bool updateShouldNotify(PrototypeStateProvider oldWidget) =>
      activeModule != oldWidget.activeModule ||
      isYoyoAreaView != oldWidget.isYoyoAreaView ||
      yoyoRange != oldWidget.yoyoRange ||
      isYoyoHidden != oldWidget.isYoyoHidden ||
      yoyoFriendsOnly != oldWidget.yoyoFriendsOnly ||
      yoyoSelectedInterests != oldWidget.yoyoSelectedInterests ||
      yoyoShowOnline != oldWidget.yoyoShowOnline ||
      yoyoShowDistance != oldWidget.yoyoShowDistance ||
      yoyoConnectFilter != oldWidget.yoyoConnectFilter ||
      yoyoV2SessionActive != oldWidget.yoyoV2SessionActive ||
      yoyoV2SessionDuration != oldWidget.yoyoV2SessionDuration ||
      yoyoV2DataRetentionHours != oldWidget.yoyoV2DataRetentionHours ||
      yoyoV2VisibilityTier != oldWidget.yoyoV2VisibilityTier ||
      yoyoV2EncounterFilter != oldWidget.yoyoV2EncounterFilter ||
      yoyoV2RelationshipFilter != oldWidget.yoyoV2RelationshipFilter ||
      yoyoV2EncounterTransparency != oldWidget.yoyoV2EncounterTransparency ||
      yoyoLiveActive != oldWidget.yoyoLiveActive ||
      yoyoLiveDuration != oldWidget.yoyoLiveDuration ||
      isRadarFullscreen != oldWidget.isRadarFullscreen ||
      yoyoMode != oldWidget.yoyoMode ||
      isDarkMode != oldWidget.isDarkMode;
}
