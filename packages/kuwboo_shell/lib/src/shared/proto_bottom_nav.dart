import 'package:flutter/material.dart';
import '../state/proto_state_provider.dart';
import '../testing/shell_test_ids.dart';
import '../theme/proto_theme.dart';

/// Sub-feature tab definition for Set C bottom nav.
/// [icon] is the outlined variant shown when inactive.
/// [activeIcon] is the filled variant shown when active/selected.
class _FeatureTab {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _FeatureTab({required this.icon, required this.activeIcon, required this.label});
}

/// Set C bottom nav: sub-feature tabs per service + right-side service switcher FAB.
///
/// Layout: 4 feature tabs in the bottom bar (right-padded for FAB space)
/// plus a FAB at bottom-right that opens a vertical popup menu of 5 services.
class ProtoBottomNavC extends StatefulWidget {
  final ProtoModule activeModule;
  final int activeTab;
  final ValueChanged<int>? onTabTapped;
  final ValueChanged<ProtoModule>? onServiceSelected;
  final Map<int, int>? tabBadges;

  const ProtoBottomNavC({
    super.key,
    required this.activeModule,
    this.activeTab = 0,
    this.onTabTapped,
    this.onServiceSelected,
    this.tabBadges,
  });

  @override
  State<ProtoBottomNavC> createState() => _ProtoBottomNavCState();
}

class _ProtoBottomNavCState extends State<ProtoBottomNavC>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animController;
  late Animation<double> _expandAnimation;

  // Sub-feature tabs per service, derived from the active icon set
  static Map<ProtoModule, List<_FeatureTab>> _serviceFeatures(ProtoTheme theme) {
    final icons = theme.icons;
    return {
      ProtoModule.video: [
        _FeatureTab(icon: icons.videoForYou.inactive, activeIcon: icons.videoForYou.active, label: 'For You'),
        _FeatureTab(icon: icons.videoFollowing.inactive, activeIcon: icons.videoFollowing.active, label: 'Following'),
        _FeatureTab(icon: icons.videoDiscover.inactive, activeIcon: icons.videoDiscover.active, label: 'Discover'),
        _FeatureTab(icon: icons.videoCreate.inactive, activeIcon: icons.videoCreate.active, label: 'Create'),
      ],
      ProtoModule.dating: [
        _FeatureTab(icon: icons.datingDiscover.inactive, activeIcon: icons.datingDiscover.active, label: 'Discover'),
        _FeatureTab(icon: icons.datingMatches.inactive, activeIcon: icons.datingMatches.active, label: 'Matches'),
        _FeatureTab(icon: icons.datingLikes.inactive, activeIcon: icons.datingLikes.active, label: 'Likes'),
        _FeatureTab(icon: icons.datingChat.inactive, activeIcon: icons.datingChat.active, label: 'Chat'),
      ],
      ProtoModule.yoyo: [
        _FeatureTab(icon: icons.yoyoNearby.inactive, activeIcon: icons.yoyoNearby.active, label: 'Nearby'),
        _FeatureTab(icon: icons.yoyoConnect.inactive, activeIcon: icons.yoyoConnect.active, label: 'Connect'),
        _FeatureTab(icon: icons.yoyoWave.inactive, activeIcon: icons.yoyoWave.active, label: 'Wave'),
        _FeatureTab(icon: icons.yoyoChat.inactive, activeIcon: icons.yoyoChat.active, label: 'Chat'),
      ],
      ProtoModule.social: [
        _FeatureTab(icon: icons.socialStumble.inactive, activeIcon: icons.socialStumble.active, label: 'Stumble'),
        _FeatureTab(icon: icons.socialFriends.inactive, activeIcon: icons.socialFriends.active, label: 'Friends'),
        _FeatureTab(icon: icons.socialEvents.inactive, activeIcon: icons.socialEvents.active, label: 'Events'),
        _FeatureTab(icon: icons.socialPost.inactive, activeIcon: icons.socialPost.active, label: 'Post'),
      ],
      ProtoModule.shop: [
        _FeatureTab(icon: icons.shopBrowse.inactive, activeIcon: icons.shopBrowse.active, label: 'Browse'),
        _FeatureTab(icon: icons.shopDeals.inactive, activeIcon: icons.shopDeals.active, label: 'Deals'),
        _FeatureTab(icon: icons.shopSell.inactive, activeIcon: icons.shopSell.active, label: 'Sell'),
        _FeatureTab(icon: icons.shopMessages.inactive, activeIcon: icons.shopMessages.active, label: 'Messages'),
      ],
    };
  }

  // Service icons derived from the active icon set
  static Map<ProtoModule, IconData> _serviceIcons(ProtoTheme theme) {
    final icons = theme.icons;
    return {
      ProtoModule.video: icons.serviceVideo.active,
      ProtoModule.dating: icons.serviceDating.active,
      ProtoModule.yoyo: icons.serviceYoyo.active,
      ProtoModule.social: icons.serviceSocial.active,
      ProtoModule.shop: icons.serviceShop.active,
    };
  }

  // Outlined service icons for non-current services in popup
  static Map<ProtoModule, IconData> _serviceOutlinedIcons(ProtoTheme theme) {
    final icons = theme.icons;
    return {
      ProtoModule.video: icons.serviceVideo.inactive,
      ProtoModule.dating: icons.serviceDating.inactive,
      ProtoModule.yoyo: icons.serviceYoyo.inactive,
      ProtoModule.social: icons.serviceSocial.inactive,
      ProtoModule.shop: icons.serviceShop.inactive,
    };
  }

  static const _serviceLabels = <ProtoModule, String>{
    ProtoModule.video: 'Video',
    ProtoModule.dating: 'Dating',
    ProtoModule.yoyo: 'Yoyo',
    ProtoModule.social: 'Social',
    ProtoModule.shop: 'Buy & Sell',
  };

  static const _height = 56.0;
  static const _fabSize = 42.0;
  static const _notchMargin = 2.0;
  static const _fabRightOffset = 15.0;
  static const _fabOverhang = 0.0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    });
  }

  void _dismiss() {
    if (_isExpanded) _toggleExpand();
  }

  List<_FeatureTab> _tabs(ProtoTheme theme) =>
      _serviceFeatures(theme)[widget.activeModule] ?? _serviceFeatures(theme)[ProtoModule.video]!;

  IconData _fabIcon(ProtoTheme theme) =>
      _serviceIcons(theme)[widget.activeModule] ?? Icons.apps_rounded;

  /// Height of the nav bar area including FAB overhang, used by ProtoScaffold
  /// for body bottom padding. Safe-area (home indicator) is added by consumers.
  static double get totalHeight => _height + _fabOverhang + _notchMargin;

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final isMenuActive = _isExpanded || _animController.isAnimating;

    // Idle (popup closed): nav is bounded to just the bar + FAB so the
    // parent Stack's hit tests fall through to the body above for scroll
    // and tap gestures. A full-bleed Stack here previously swallowed
    // those gestures even though all of its direct children were bounded
    // Positioned widgets — issue #146.
    //
    // Active (popup open / animating): grow to the full viewport height
    // so the dismiss target, scrim and stacked service items all lay out
    // and hit-test correctly.
    if (!isMenuActive) {
      return SizedBox(
        height: _height + bottomInset,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBar(theme, bottomInset),
            ),
            Positioned(
              bottom: bottomInset + _height - _fabSize + _fabOverhang,
              right: _fabRightOffset,
              child: _buildFab(theme),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = MediaQuery.sizeOf(context).height;
        return SizedBox(
          height: screenHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Layer A: Transparent full-area dismiss target (no visual)
              if (_isExpanded)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _dismiss,
                    behavior: HitTestBehavior.translucent,
                    child: const SizedBox.expand(),
                  ),
                ),

              // Layer B: Bounded scrim panel behind popup items only
              _buildScrimPanel(theme),

              // Service popup menu (above FAB)
              ..._buildServicePopup(theme),

              // Bottom bar with right-side notch
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBar(theme, bottomInset),
              ),

              // FAB sitting in the right-side notch (inline with bar)
              Positioned(
                bottom: bottomInset + _height - _fabSize + _fabOverhang,
                right: _fabRightOffset,
                child: _buildFab(theme),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBar(ProtoTheme theme, double bottomInset) {
    final tabs = _tabs(theme);
    final borderColor = theme.text.withValues(alpha: 0.08);

    return SizedBox(
      height: _height + bottomInset,
      child: CustomPaint(
        painter: _RightNotchedBarPainter(
          backgroundColor: theme.surface,
          notchMargin: _notchMargin,
          fabRightOffset: _fabRightOffset,
          fabSize: _fabSize,
          fabOverhang: _fabOverhang,
          barHeight: _height,
          borderColor: borderColor,
        ),
        child: Padding(
          // Right padding to make room for the FAB notch,
          // bottom padding for home indicator on modern iPhones
          padding: EdgeInsets.only(right: _fabSize + 20, bottom: bottomInset),
          child: Stack(
            children: [
              // Sliding pill indicator — tweens behind the active tab.
              Positioned.fill(
                child: _TabIndicatorPill(
                  tabCount: tabs.length,
                  activeIndex: widget.activeTab,
                  color: theme.primary.withValues(alpha: 0.16),
                ),
              ),
              Row(
            children: List.generate(tabs.length, (i) {
              final tab = tabs[i];
              final isActive = i == widget.activeTab;
              final color = isActive ? theme.primary : theme.textTertiary;

              final badgeCount = widget.tabBadges?[i];

              return Expanded(
                child: Semantics(
                  identifier: ShellIds.bottomnavTab(tab.label),
                  label: '${tab.label} tab${isActive ? ', selected' : ''}${badgeCount != null && badgeCount > 0 ? ', $badgeCount notifications' : ''}',
                  button: true,
                  selected: isActive,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => widget.onTabTapped?.call(i),
                    child: SizedBox(
                      height: _height - 8,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 28,
                          height: 22,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Center(child: Icon(isActive ? tab.activeIcon : tab.icon, size: 24, color: color)),
                              if (badgeCount != null && badgeCount > 0)
                                Positioned(
                                  right: -2,
                                  top: -2,
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: theme.accent,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: theme.surface, width: 1.5),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$badgeCount',
                                        style: const TextStyle(
                                          fontSize: 8,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          tab.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                            color: color,
                            height: 1.0,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ),
                ),
              );
            }),
          ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFab(ProtoTheme theme) {
    return Semantics(
      identifier: ShellIds.bottomnavFab,
      label: _isExpanded ? 'Close service menu' : 'Open service menu, current: ${_serviceLabels[widget.activeModule]}',
      button: true,
      child: GestureDetector(
      onTap: _toggleExpand,
      child: AnimatedBuilder(
        animation: _expandAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _expandAnimation.value * 0.75,
            child: child,
          );
        },
        child: Container(
          width: _fabSize,
          height: _fabSize,
          decoration: BoxDecoration(
            color: ProtoTheme.kuwbooBlue,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: ProtoTheme.kuwbooBlue.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            _isExpanded ? theme.icons.close : _fabIcon(theme),
            size: 20,
            color: Colors.white,
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildScrimPanel(ProtoTheme theme) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: _height + bottomInset,
      child: AnimatedBuilder(
        animation: _expandAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _expandAnimation.value.clamp(0.0, 1.0),
            child: child,
          );
        },
        child: Container(
          color: Colors.black.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  List<Widget> _buildServicePopup(ProtoTheme theme) {
    final services = ProtoModule.values;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final List<Widget> widgets = [];

    for (int i = 0; i < services.length; i++) {
      final service = services[i];
      final isCurrent = service == widget.activeModule;
      // Stack items from bottom to top: index 0 is highest
      final bottomOffset =
          bottomInset + _height + _fabOverhang + _notchMargin +
          8 + (services.length - 1 - i) * 52.0;

      widgets.add(
        Positioned(
          bottom: bottomOffset,
          right: _fabRightOffset + (_fabSize - 44) / 2,
          child: AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              final itemDelay = i * 0.12;
              final clampedMax = (1.0 - itemDelay).clamp(0.01, 1.0);
              final itemProgress =
                  ((_expandAnimation.value - itemDelay) / clampedMax)
                      .clamp(0.0, 1.0);
              return Transform.scale(
                scale: itemProgress,
                child: Opacity(
                  opacity: itemProgress,
                  child: child,
                ),
              );
            },
            child: Semantics(
              identifier: ShellIds.bottomnavService(service.name),
              label: '${_serviceLabels[service]} service${isCurrent ? ', currently active' : ''}',
              button: true,
              selected: isCurrent,
              child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                widget.onServiceSelected?.call(service);
                _dismiss();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Label — fixed width so all boxes are uniform
                  Container(
                    width: 80,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: theme.surface,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      _serviceLabels[service] ?? '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: isCurrent ? theme.primary : theme.textTertiary,
                        fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Icon bubble
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isCurrent ? ProtoTheme.kuwbooBlue : theme.surface,
                      shape: BoxShape.circle,
                      border: isCurrent
                          ? null
                          : Border.all(
                              color: theme.textTertiary.withValues(alpha: 0.3),
                            ),
                      boxShadow: [
                        BoxShadow(
                          color: (isCurrent ? ProtoTheme.kuwbooBlue : Colors.black)
                              .withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      isCurrent ? _serviceIcons(theme)[service] : _serviceOutlinedIcons(theme)[service],
                      size: 20,
                      color: isCurrent ? Colors.white : theme.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            ),
          ),
        ),
      );
    }
    return widgets;
  }
}

/// Paints the bottom bar background with a semicircular notch on the right side
/// for the docked FAB. Uses Flutter's built-in CircularNotchedRectangle for
/// mathematically correct notch geometry, then fills the safe-area (home
/// indicator) region with a flat bottom strip.
class _RightNotchedBarPainter extends CustomPainter {
  final Color backgroundColor;
  final double notchMargin;
  final double fabRightOffset;
  final double fabSize;
  final double fabOverhang;
  final double barHeight;
  final Color? borderColor;

  _RightNotchedBarPainter({
    required this.backgroundColor,
    required this.notchMargin,
    required this.fabRightOffset,
    required this.fabSize,
    required this.barHeight,
    this.fabOverhang = 0.0,
    this.borderColor,
  });

  /// FAB's bounding rect inside the painter's coordinate space, positioned
  /// near the top of the visual bar (ignores safe-area padding at the bottom).
  /// Shifted up 2px to tighten the notch — matches the empirical value we
  /// landed on in the web prototype.
  Rect _guestRect(Size size) {
    final fabLeft = size.width - fabRightOffset - fabSize;
    final fabTop = -fabOverhang + (barHeight - fabSize) / 2 - 2;
    return Rect.fromLTWH(fabLeft, fabTop, fabSize, fabSize);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final host = Offset.zero & size;
    final guest = _guestRect(size).inflate(notchMargin);
    final path = const CircularNotchedRectangle().getOuterPath(host, guest);

    canvas.drawPath(path, Paint()..color = backgroundColor);

    if (borderColor != null) {
      final borderPaint = Paint()
        ..color = borderColor!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawPath(path, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RightNotchedBarPainter oldDelegate) =>
      backgroundColor != oldDelegate.backgroundColor ||
      notchMargin != oldDelegate.notchMargin ||
      borderColor != oldDelegate.borderColor ||
      fabRightOffset != oldDelegate.fabRightOffset ||
      fabSize != oldDelegate.fabSize ||
      fabOverhang != oldDelegate.fabOverhang ||
      barHeight != oldDelegate.barHeight;
}

/// Sliding pill indicator that tweens behind the active tab when the
/// selection changes. Draws a rounded rectangle filling one tab slot
/// and animates horizontally between slots.
class _TabIndicatorPill extends StatelessWidget {
  final int tabCount;
  final int activeIndex;
  final Color color;

  const _TabIndicatorPill({
    required this.tabCount,
    required this.activeIndex,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Map activeIndex [0..tabCount-1] to Alignment.x in [-1..1].
    final double x = tabCount > 1
        ? (activeIndex / (tabCount - 1)) * 2 - 1
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: AnimatedAlign(
        alignment: Alignment(x, 0),
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        child: FractionallySizedBox(
          widthFactor: 1 / tabCount,
          heightFactor: 1,
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }
}
