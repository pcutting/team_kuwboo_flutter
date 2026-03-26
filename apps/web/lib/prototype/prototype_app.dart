import 'package:flutter/material.dart';
import '../data/color_palettes.dart';
import '../data/icon_sets.dart';
import 'proto_theme.dart';
import 'prototype_state.dart';
import 'prototype_routes.dart';
import 'screens/yoyo/yoyo_nearby_screen.dart';

/// The root widget for the interactive prototype.
/// Contains its own Navigator and state management,
/// running inside the design viewer's phone frame.
class PrototypeApp extends StatefulWidget {
  /// Design index (0-8) matching Set B order. Controls theming.
  final int designIndex;

  /// Optional palette override index. null = use design's built-in colors.
  final int? paletteIndex;

  /// Optional icon set override index. null = use design's built-in icons.
  final int? iconSetIndex;

  /// YoYo variant (0 = V1, 1 = V2). Controlled by the viewer sidebar.
  final int yoyoVariant;

  /// Callback when YoYo variant changes from inside the prototype.
  final ValueChanged<int>? onYoyoVariantChanged;

  /// YoYo mode (0 = Social, 1 = Inner Circle). Controlled by viewer sidebar and header toggle.
  final int yoyoMode;

  /// Callback when YoYo mode changes.
  final ValueChanged<int>? onYoyoModeChanged;

  /// Optional notifier for external navigation requests (e.g. from the viewer sidebar).
  /// Set value to a route name to push it, then reset to null.
  final ValueNotifier<String?>? navigateNotifier;

  const PrototypeApp({super.key, this.designIndex = 6, this.paletteIndex, this.iconSetIndex, this.yoyoVariant = 0, this.onYoyoVariantChanged, this.yoyoMode = 0, this.onYoyoModeChanged, this.navigateNotifier});

  @override
  State<PrototypeApp> createState() => _PrototypeAppState();
}

class _PrototypeAppState extends State<PrototypeApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  ProtoModule _activeModule = ProtoModule.yoyo;
  bool _isYoyoAreaView = true;

  // YoYo radar & filter state
  double _yoyoRange = 1.0;
  bool _isYoyoHidden = true; // Hidden by default — privacy-first
  bool _yoyoFriendsOnly = false;
  Set<String> _yoyoSelectedInterests = {};

  // YoYo settings & connect state
  bool _yoyoShowOnline = true;
  bool _yoyoShowDistance = true;
  String _yoyoConnectFilter = 'All';

  // YoYo V2 state
  bool _yoyoV2SessionActive = false;
  int _yoyoV2SessionDuration = 1; // 0=15m, 1=30m, 2=1h, 3=2h
  int _yoyoV2DataRetentionHours = 32;
  int _yoyoV2VisibilityTier = 0; // 0=public..3=private
  String _yoyoV2EncounterFilter = 'all';
  String _yoyoV2RelationshipFilter = 'all';
  bool _yoyoV2EncounterTransparency = true;

  // YoYo Go Live state
  bool _yoyoLiveActive = false;
  int _yoyoLiveDuration = 0; // 0=30m, 1=2h, 2=8h, 3=Always

  // Global preferences
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    widget.navigateNotifier?.addListener(_onExternalNavigate);
  }

  @override
  void didUpdateWidget(covariant PrototypeApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.navigateNotifier != widget.navigateNotifier) {
      oldWidget.navigateNotifier?.removeListener(_onExternalNavigate);
      widget.navigateNotifier?.addListener(_onExternalNavigate);
    }
  }

  @override
  void dispose() {
    widget.navigateNotifier?.removeListener(_onExternalNavigate);
    super.dispose();
  }

  void _onExternalNavigate() {
    final route = widget.navigateNotifier?.value;
    if (route != null) {
      _navigatorKey.currentState?.pushNamed(route);
      // Reset after consuming
      widget.navigateNotifier!.value = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = ProtoTheme.fromDesignIndex(widget.designIndex);
    if (widget.paletteIndex != null) {
      theme = theme.withPalette(ColorPalette.visible[widget.paletteIndex!]);
    }
    if (widget.iconSetIndex != null) {
      theme = theme.withIconSet(ProtoIconSet.all[widget.iconSetIndex!]);
    }
    // Dark mode: light designs → toDark(), V4 (design 3, natively dark) → toLight()
    if (_isDarkMode && !theme.isDark) {
      theme = theme.toDark(designIndex: widget.designIndex);
    } else if (!_isDarkMode && widget.designIndex == 3 && theme.isDark) {
      // V4 is the only factory that starts dark — show its Streetlight companion
      theme = theme.toLight();
    }

    return ProtoThemeProvider(
      theme: theme,
      child: PrototypeStateProvider(
        activeModule: _activeModule,
        navigatorKey: _navigatorKey,
        isYoyoAreaView: _isYoyoAreaView,
        onYoyoViewToggle: () {
          setState(() => _isYoyoAreaView = !_isYoyoAreaView);
        },
        onModuleChanged: (module) {
          setState(() {
            _activeModule = module;
            if (module == ProtoModule.yoyo) {
              _isYoyoAreaView = true;
            }
          });
        },
        yoyoRange: _yoyoRange,
        onYoyoRangeChanged: (value) {
          setState(() => _yoyoRange = value);
        },
        isYoyoHidden: _isYoyoHidden,
        onYoyoHiddenToggle: () {
          setState(() => _isYoyoHidden = !_isYoyoHidden);
        },
        yoyoFriendsOnly: _yoyoFriendsOnly,
        onYoyoFriendsOnlyToggle: () {
          setState(() => _yoyoFriendsOnly = !_yoyoFriendsOnly);
        },
        yoyoSelectedInterests: _yoyoSelectedInterests,
        onYoyoInterestsChanged: (interests) {
          setState(() => _yoyoSelectedInterests = interests);
        },
        yoyoShowOnline: _yoyoShowOnline,
        onYoyoShowOnlineChanged: (value) {
          setState(() => _yoyoShowOnline = value);
        },
        yoyoShowDistance: _yoyoShowDistance,
        onYoyoShowDistanceChanged: (value) {
          setState(() => _yoyoShowDistance = value);
        },
        yoyoConnectFilter: _yoyoConnectFilter,
        onYoyoConnectFilterChanged: (value) {
          setState(() => _yoyoConnectFilter = value);
        },
        yoyoV2SessionActive: _yoyoV2SessionActive,
        onYoyoV2SessionToggle: () {
          setState(() => _yoyoV2SessionActive = !_yoyoV2SessionActive);
        },
        yoyoV2SessionDuration: _yoyoV2SessionDuration,
        onYoyoV2SessionDurationChanged: (value) {
          setState(() => _yoyoV2SessionDuration = value);
        },
        yoyoV2DataRetentionHours: _yoyoV2DataRetentionHours,
        onYoyoV2DataRetentionChanged: (value) {
          setState(() => _yoyoV2DataRetentionHours = value);
        },
        yoyoV2VisibilityTier: _yoyoV2VisibilityTier,
        onYoyoV2VisibilityTierChanged: (value) {
          setState(() => _yoyoV2VisibilityTier = value);
        },
        yoyoV2EncounterFilter: _yoyoV2EncounterFilter,
        onYoyoV2EncounterFilterChanged: (value) {
          setState(() => _yoyoV2EncounterFilter = value);
        },
        yoyoV2RelationshipFilter: _yoyoV2RelationshipFilter,
        onYoyoV2RelationshipFilterChanged: (value) {
          setState(() => _yoyoV2RelationshipFilter = value);
        },
        yoyoV2EncounterTransparency: _yoyoV2EncounterTransparency,
        onYoyoV2EncounterTransparencyChanged: (value) {
          setState(() => _yoyoV2EncounterTransparency = value);
        },
        yoyoLiveActive: _yoyoLiveActive,
        onYoyoLiveToggle: () {
          setState(() {
            _yoyoLiveActive = !_yoyoLiveActive;
            // When going live, un-hide; when ending, re-hide
            _isYoyoHidden = !_yoyoLiveActive;
          });
        },
        yoyoLiveDuration: _yoyoLiveDuration,
        onYoyoLiveDurationChanged: (value) {
          setState(() => _yoyoLiveDuration = value);
        },
        yoyoVariant: widget.yoyoVariant,
        onYoyoVariantChanged: (value) {
          widget.onYoyoVariantChanged?.call(value);
        },
        yoyoMode: widget.yoyoMode,
        onYoyoModeChanged: (value) {
          widget.onYoyoModeChanged?.call(value);
        },
        isDarkMode: _isDarkMode,
        onDarkModeChanged: (value) {
          setState(() => _isDarkMode = value);
        },
        child: Navigator(
          key: _navigatorKey,
          onGenerateRoute: generateRoute,
          onGenerateInitialRoutes: (NavigatorState navigator, String initialRoute) {
            return <Route<dynamic>>[
              MaterialPageRoute<void>(
                settings: const RouteSettings(name: '/yoyo/nearby'),
                builder: (context) => const YoyoNearbyScreen(),
              ),
            ];
          },
        ),
      ),
    );
  }
}
