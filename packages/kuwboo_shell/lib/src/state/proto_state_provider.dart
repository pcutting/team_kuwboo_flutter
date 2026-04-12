import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../routes/proto_routes.dart';
import 'proto_module.dart';
export 'proto_module.dart';

// ─── Shell State (global app-level) ─────────────────────────────────────

/// Global shell state: which module is active, dark mode, etc.
class ShellState {
  final ProtoModule activeModule;
  final int activeTab;
  final bool isDarkMode;

  const ShellState({
    this.activeModule = ProtoModule.yoyo,
    this.activeTab = 0,
    this.isDarkMode = false,
  });

  ShellState copyWith({
    ProtoModule? activeModule,
    int? activeTab,
    bool? isDarkMode,
  }) {
    return ShellState(
      activeModule: activeModule ?? this.activeModule,
      activeTab: activeTab ?? this.activeTab,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

class ShellStateNotifier extends StateNotifier<ShellState> {
  ShellStateNotifier() : super(const ShellState());

  void switchModule(ProtoModule module) {
    state = state.copyWith(activeModule: module, activeTab: 0);
  }

  void switchTab(int tabIndex) {
    state = state.copyWith(activeTab: tabIndex);
  }

  void setDarkMode(bool value) {
    state = state.copyWith(isDarkMode: value);
  }
}

final shellStateProvider =
    StateNotifierProvider<ShellStateNotifier, ShellState>(
  (ref) => ShellStateNotifier(),
);

// ─── YoYo State ─────────────────────────────────────────────────────────

/// YoYo-specific state: radar, hidden mode, Go Live, V2 session, etc.
class YoyoState {
  // Area view
  final bool isAreaView;

  // Radar & filter
  final double range;
  final bool isHidden;
  final bool friendsOnly;
  final Set<String> selectedInterests;

  // Settings & connect
  final bool showOnline;
  final bool showDistance;
  final String connectFilter;

  // V2 session
  final bool v2SessionActive;
  final int v2SessionDuration; // 0=15m, 1=30m, 2=1h, 3=2h
  final int v2DataRetentionHours;
  final int v2VisibilityTier; // 0=public..3=private
  final String v2EncounterFilter;
  final String v2RelationshipFilter;
  final bool v2EncounterTransparency;

  // Go Live (visibility timer)
  final bool liveActive;
  final int liveDuration; // 0=Always, 1=15m, 2=30m, 3=1h, 4=2h, 5=4h, 6=8h, 7=12h, 8=24h

  // Full-screen radar mode
  final bool isRadarFullscreen;

  // Mode (0 = Social, 1 = Inner Circle)
  final int mode;

  const YoyoState({
    this.isAreaView = true,
    this.range = 1.0,
    this.isHidden = true,
    this.friendsOnly = false,
    this.selectedInterests = const {},
    this.showOnline = true,
    this.showDistance = true,
    this.connectFilter = 'All',
    this.v2SessionActive = false,
    this.v2SessionDuration = 1,
    this.v2DataRetentionHours = 32,
    this.v2VisibilityTier = 0,
    this.v2EncounterFilter = 'all',
    this.v2RelationshipFilter = 'all',
    this.v2EncounterTransparency = true,
    this.liveActive = false,
    this.liveDuration = 0,
    this.isRadarFullscreen = false,
    this.mode = 0,
  });

  YoyoState copyWith({
    bool? isAreaView,
    double? range,
    bool? isHidden,
    bool? friendsOnly,
    Set<String>? selectedInterests,
    bool? showOnline,
    bool? showDistance,
    String? connectFilter,
    bool? v2SessionActive,
    int? v2SessionDuration,
    int? v2DataRetentionHours,
    int? v2VisibilityTier,
    String? v2EncounterFilter,
    String? v2RelationshipFilter,
    bool? v2EncounterTransparency,
    bool? liveActive,
    int? liveDuration,
    bool? isRadarFullscreen,
    int? mode,
  }) {
    return YoyoState(
      isAreaView: isAreaView ?? this.isAreaView,
      range: range ?? this.range,
      isHidden: isHidden ?? this.isHidden,
      friendsOnly: friendsOnly ?? this.friendsOnly,
      selectedInterests: selectedInterests ?? this.selectedInterests,
      showOnline: showOnline ?? this.showOnline,
      showDistance: showDistance ?? this.showDistance,
      connectFilter: connectFilter ?? this.connectFilter,
      v2SessionActive: v2SessionActive ?? this.v2SessionActive,
      v2SessionDuration: v2SessionDuration ?? this.v2SessionDuration,
      v2DataRetentionHours: v2DataRetentionHours ?? this.v2DataRetentionHours,
      v2VisibilityTier: v2VisibilityTier ?? this.v2VisibilityTier,
      v2EncounterFilter: v2EncounterFilter ?? this.v2EncounterFilter,
      v2RelationshipFilter: v2RelationshipFilter ?? this.v2RelationshipFilter,
      v2EncounterTransparency: v2EncounterTransparency ?? this.v2EncounterTransparency,
      liveActive: liveActive ?? this.liveActive,
      liveDuration: liveDuration ?? this.liveDuration,
      isRadarFullscreen: isRadarFullscreen ?? this.isRadarFullscreen,
      mode: mode ?? this.mode,
    );
  }
}

class YoyoStateNotifier extends StateNotifier<YoyoState> {
  YoyoStateNotifier() : super(const YoyoState());

  // Area view
  void toggleAreaView() {
    state = state.copyWith(isAreaView: !state.isAreaView);
  }

  // Radar & filter
  void setRange(double value) {
    state = state.copyWith(range: value);
  }

  void toggleHidden() {
    state = state.copyWith(isHidden: !state.isHidden);
  }

  void toggleFriendsOnly() {
    state = state.copyWith(friendsOnly: !state.friendsOnly);
  }

  void setSelectedInterests(Set<String> interests) {
    state = state.copyWith(selectedInterests: interests);
  }

  // Settings & connect
  void setShowOnline(bool value) {
    state = state.copyWith(showOnline: value);
  }

  void setShowDistance(bool value) {
    state = state.copyWith(showDistance: value);
  }

  void setConnectFilter(String value) {
    state = state.copyWith(connectFilter: value);
  }

  // V2 session
  void toggleV2Session() {
    state = state.copyWith(v2SessionActive: !state.v2SessionActive);
  }

  void setV2SessionDuration(int value) {
    state = state.copyWith(v2SessionDuration: value);
  }

  void setV2DataRetentionHours(int value) {
    state = state.copyWith(v2DataRetentionHours: value);
  }

  void setV2VisibilityTier(int value) {
    state = state.copyWith(v2VisibilityTier: value);
  }

  void setV2EncounterFilter(String value) {
    state = state.copyWith(v2EncounterFilter: value);
  }

  void setV2RelationshipFilter(String value) {
    state = state.copyWith(v2RelationshipFilter: value);
  }

  void setV2EncounterTransparency(bool value) {
    state = state.copyWith(v2EncounterTransparency: value);
  }

  // Go Live
  void toggleLive() {
    final newLiveActive = !state.liveActive;
    state = state.copyWith(
      liveActive: newLiveActive,
      isHidden: !newLiveActive,
    );
  }

  void setLiveDuration(int value) {
    state = state.copyWith(liveDuration: value);
  }

  void toggleRadarFullscreen() {
    state = state.copyWith(isRadarFullscreen: !state.isRadarFullscreen);
  }

  // Mode
  void setMode(int value) {
    state = state.copyWith(mode: value);
  }
}

final yoyoStateProvider =
    StateNotifierProvider<YoyoStateNotifier, YoyoState>(
  (ref) => YoyoStateNotifier(),
);

// ─── Legacy Bridge ──────────────────────────────────────────────────────

/// Temporary InheritedWidget bridge so existing screens that haven't been
/// migrated yet can still access state via `ProtoStateAccess.of(context)`.
///
/// Screens should prefer `ref.watch(shellStateProvider)` /
/// `ref.watch(yoyoStateProvider)` directly. This bridge will be removed
/// after all screens are converted to ConsumerWidget.
class ProtoStateAccess extends InheritedWidget {
  final ShellState shell;
  final YoyoState yoyo;
  final ShellStateNotifier shellNotifier;
  final YoyoStateNotifier yoyoNotifier;
  final GlobalKey<NavigatorState>? navigatorKey;

  const ProtoStateAccess({
    super.key,
    required this.shell,
    required this.yoyo,
    required this.shellNotifier,
    required this.yoyoNotifier,
    this.navigatorKey,
    required super.child,
  });

  static ProtoStateAccess of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ProtoStateAccess>()!;
  }

  static ProtoStateAccess? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ProtoStateAccess>();
  }

  // ── Convenience getters matching old PrototypeStateProvider API ──

  ProtoModule get activeModule => shell.activeModule;
  bool get isDarkMode => shell.isDarkMode;

  bool get isYoyoAreaView => yoyo.isAreaView;
  double get yoyoRange => yoyo.range;
  bool get isYoyoHidden => yoyo.isHidden;
  bool get yoyoFriendsOnly => yoyo.friendsOnly;
  Set<String> get yoyoSelectedInterests => yoyo.selectedInterests;
  bool get yoyoShowOnline => yoyo.showOnline;
  bool get yoyoShowDistance => yoyo.showDistance;
  String get yoyoConnectFilter => yoyo.connectFilter;
  bool get yoyoV2SessionActive => yoyo.v2SessionActive;
  int get yoyoV2SessionDuration => yoyo.v2SessionDuration;
  int get yoyoV2DataRetentionHours => yoyo.v2DataRetentionHours;
  int get yoyoV2VisibilityTier => yoyo.v2VisibilityTier;
  String get yoyoV2EncounterFilter => yoyo.v2EncounterFilter;
  String get yoyoV2RelationshipFilter => yoyo.v2RelationshipFilter;
  bool get yoyoV2EncounterTransparency => yoyo.v2EncounterTransparency;
  bool get yoyoLiveActive => yoyo.liveActive;
  int get yoyoLiveDuration => yoyo.liveDuration;
  bool get isRadarFullscreen => yoyo.isRadarFullscreen;
  int get yoyoMode => yoyo.mode;

  // ── Convenience setters matching old PrototypeStateProvider API ──

  void onYoyoViewToggle() => yoyoNotifier.toggleAreaView();
  void onYoyoRangeChanged(double v) => yoyoNotifier.setRange(v);
  void onYoyoHiddenToggle() => yoyoNotifier.toggleHidden();
  void onYoyoFriendsOnlyToggle() => yoyoNotifier.toggleFriendsOnly();
  void onYoyoInterestsChanged(Set<String> v) => yoyoNotifier.setSelectedInterests(v);
  void onYoyoShowOnlineChanged(bool v) => yoyoNotifier.setShowOnline(v);
  void onYoyoShowDistanceChanged(bool v) => yoyoNotifier.setShowDistance(v);
  void onYoyoConnectFilterChanged(String v) => yoyoNotifier.setConnectFilter(v);
  void onYoyoV2SessionToggle() => yoyoNotifier.toggleV2Session();
  void onYoyoV2SessionDurationChanged(int v) => yoyoNotifier.setV2SessionDuration(v);
  void onYoyoV2DataRetentionChanged(int v) => yoyoNotifier.setV2DataRetentionHours(v);
  void onYoyoV2VisibilityTierChanged(int v) => yoyoNotifier.setV2VisibilityTier(v);
  void onYoyoV2EncounterFilterChanged(String v) => yoyoNotifier.setV2EncounterFilter(v);
  void onYoyoV2RelationshipFilterChanged(String v) => yoyoNotifier.setV2RelationshipFilter(v);
  void onYoyoV2EncounterTransparencyChanged(bool v) => yoyoNotifier.setV2EncounterTransparency(v);
  void onYoyoLiveToggle() => yoyoNotifier.toggleLive();
  void onYoyoLiveDurationChanged(int v) => yoyoNotifier.setLiveDuration(v);
  void onRadarFullscreenToggle() => yoyoNotifier.toggleRadarFullscreen();
  void onYoyoModeChanged(int v) => yoyoNotifier.setMode(v);
  void onDarkModeChanged(bool v) => shellNotifier.setDarkMode(v);
  void onModuleChanged(ProtoModule m) => shellNotifier.switchModule(m);

  // ── Navigation (delegates to GoRouter via navigatorKey context) ──

  void push(String route) {
    final ctx = navigatorKey?.currentContext;
    if (ctx != null) GoRouter.of(ctx).push(route);
  }

  void pushWithArgs(String route, Object arguments) {
    final ctx = navigatorKey?.currentContext;
    if (ctx != null) GoRouter.of(ctx).push(route, extra: arguments);
  }

  void pop() {
    final ctx = navigatorKey?.currentContext;
    if (ctx != null) {
      final router = GoRouter.of(ctx);
      if (router.canPop()) {
        router.pop();
      } else {
        final home = _homeRoute(shell.activeModule);
        router.go(home);
      }
    }
  }

  void switchModule(ProtoModule module) {
    shellNotifier.switchModule(module);
    final ctx = navigatorKey?.currentContext;
    if (ctx != null) GoRouter.of(ctx).go(_homeRoute(module));
  }

  void switchTab(int tabIndex) {
    final route = ProtoRoutes.tabRoute(
      shell.activeModule.name,
      tabIndex,
    );
    if (route != null) {
      final ctx = navigatorKey?.currentContext;
      if (ctx != null) GoRouter.of(ctx).go(route);
    }
  }

  static String _homeRoute(ProtoModule module) {
    switch (module) {
      case ProtoModule.video:
        return ProtoRoutes.videoFeed;
      case ProtoModule.dating:
        return ProtoRoutes.datingCards;
      case ProtoModule.yoyo:
        return ProtoRoutes.yoyoNearby;
      case ProtoModule.social:
        return ProtoRoutes.socialFeed;
      case ProtoModule.shop:
        return ProtoRoutes.shopBrowse;
    }
  }

  @override
  bool updateShouldNotify(ProtoStateAccess oldWidget) =>
      shell != oldWidget.shell || yoyo != oldWidget.yoyo;
}

/// Backwards-compatible alias so screens that reference the old web-app name
/// continue to compile without changes.
typedef PrototypeStateProvider = ProtoStateAccess;
