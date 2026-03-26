import 'package:flutter/material.dart';
import 'design_nav.dart' show ScreenChangeNotification, ScreenType;

/// Which Kuwboo service is active (determines FAB icon + highlighted popup item)
enum ServiceType { video, dating, yoyo, social, market }

/// A single sub-feature tab within a service
class FeatureTab {
  final IconData icon;
  final String label;
  const FeatureTab({required this.icon, required this.label});
}

/// Bottom navigation with sub-feature tabs + bottom-right FAB service switcher (Set C)
///
/// Layout: 4 feature tabs in the bottom bar (right-padded for FAB space)
/// plus a FAB at bottom-right that opens a vertical popup menu of 5 services.
///
/// Pattern: "Service Switcher FAB" — bottom nav shows per-service features,
/// FAB lets you jump between services.
class BottomNavFab extends StatefulWidget {
  final ServiceType currentService;
  final int activeTab;
  final Color backgroundColor;
  final Color activeColor;
  final Color inactiveColor;
  final Color fabColor;
  final Color fabIconColor;
  final Color? borderColor;
  final double height;
  final double fabSize;
  final double notchMargin;
  final TextStyle? labelStyle;
  final bool showPopupLabels;

  const BottomNavFab({
    super.key,
    required this.currentService,
    this.activeTab = 0,
    required this.backgroundColor,
    required this.activeColor,
    required this.inactiveColor,
    required this.fabColor,
    this.fabIconColor = Colors.white,
    this.borderColor,
    this.height = 56,
    this.fabSize = 50,
    this.notchMargin = 6,
    this.labelStyle,
    this.showPopupLabels = true,
  });

  @override
  State<BottomNavFab> createState() => _BottomNavFabState();
}

class _BottomNavFabState extends State<BottomNavFab>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animController;
  late Animation<double> _expandAnimation;

  static const _serviceFeatures = <ServiceType, List<FeatureTab>>{
    ServiceType.video: [
      FeatureTab(icon: Icons.smart_display_rounded, label: 'For You'),
      FeatureTab(icon: Icons.people_rounded, label: 'Following'),
      FeatureTab(icon: Icons.travel_explore_rounded, label: 'Discover'),
      FeatureTab(icon: Icons.add_circle_rounded, label: 'Create'),
    ],
    ServiceType.dating: [
      FeatureTab(icon: Icons.travel_explore_rounded, label: 'Discover'),
      FeatureTab(icon: Icons.handshake_rounded, label: 'Matches'),
      FeatureTab(icon: Icons.thumb_up_rounded, label: 'Likes'),
      FeatureTab(icon: Icons.chat_bubble_rounded, label: 'Chat'),
    ],
    ServiceType.social: [
      FeatureTab(icon: Icons.shuffle_rounded, label: 'Stumble'),
      FeatureTab(icon: Icons.group_rounded, label: 'Friends'),
      FeatureTab(icon: Icons.event_rounded, label: 'Events'),
      FeatureTab(icon: Icons.create_rounded, label: 'Post'),
    ],
    ServiceType.market: [
      FeatureTab(icon: Icons.shopping_bag_rounded, label: 'Browse'),
      FeatureTab(icon: Icons.local_offer_rounded, label: 'Deals'),
      FeatureTab(icon: Icons.sell_rounded, label: 'Sell'),
      FeatureTab(icon: Icons.forum_rounded, label: 'Messages'),
    ],
    ServiceType.yoyo: [
      FeatureTab(icon: Icons.near_me_rounded, label: 'Nearby'),
      FeatureTab(icon: Icons.link_rounded, label: 'Connect'),
      FeatureTab(icon: Icons.waving_hand_rounded, label: 'Wave'),
      FeatureTab(icon: Icons.chat_rounded, label: 'Chat'),
    ],
  };

  static const _serviceIcons = <ServiceType, IconData>{
    ServiceType.video: Icons.play_circle_rounded,
    ServiceType.market: Icons.storefront_rounded,
    ServiceType.dating: Icons.favorite_rounded,
    ServiceType.yoyo: Icons.explore_rounded,
    ServiceType.social: Icons.people_rounded,
  };

  static const _serviceLabels = <ServiceType, String>{
    ServiceType.video: 'Video',
    ServiceType.market: 'Market',
    ServiceType.dating: 'Dating',
    ServiceType.yoyo: 'Yoyo',
    ServiceType.social: 'Social',
  };

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

  static ScreenType _serviceToScreen(ServiceType s) {
    switch (s) {
      case ServiceType.video:  return ScreenType.video;
      case ServiceType.dating: return ScreenType.dating;
      case ServiceType.social: return ScreenType.social;
      case ServiceType.market: return ScreenType.market;
      case ServiceType.yoyo:   return ScreenType.yoyo;
    }
  }

  List<FeatureTab> get _tabs =>
      _serviceFeatures[widget.currentService] ?? _serviceFeatures[ServiceType.dating]!;

  IconData get _fabIcon =>
      _serviceIcons[widget.currentService] ?? Icons.apps_rounded;

  /// FAB center X position relative to bar width
  double _fabCenterX(double barWidth) =>
      barWidth - 16 - widget.fabSize / 2;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height + (widget.fabSize / 2) + widget.notchMargin,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Layer A: Transparent full-area dismiss target (no visual)
          if (_isExpanded)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              top: -(MediaQuery.sizeOf(context).height),
              child: GestureDetector(
                onTap: _dismiss,
                behavior: HitTestBehavior.translucent,
                child: const SizedBox.expand(),
              ),
            ),

          // Layer B: Bounded scrim panel behind popup items only
          if (_isExpanded || _animController.isAnimating)
            _buildScrimPanel(),

          // Service popup menu (above FAB)
          if (_isExpanded || _animController.isAnimating)
            ..._buildServicePopup(),

          // Bottom bar with notch (fills full root height so notch area is painted)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            top: 0,
            child: _buildBar(),
          ),

          // FAB sitting in the notch
          Positioned(
            bottom: widget.height - widget.fabSize / 2,
            right: 16,
            child: _buildFab(),
          ),
        ],
      ),
    );
  }

  Widget _buildBar() {
    final tabs = _tabs;
    final totalHeight = widget.height + widget.fabSize / 2 + widget.notchMargin;

    return CustomPaint(
      painter: _RightNotchedBarPainter(
        backgroundColor: widget.backgroundColor,
        notchRadius: widget.fabSize / 2 + widget.notchMargin,
        fabRightOffset: 16,
        fabSize: widget.fabSize,
        borderColor: widget.borderColor,
        topInset: totalHeight - widget.height,
      ),
      child: Column(
        children: [
          // Spacer above the bar (notch area — painted by CustomPaint)
          SizedBox(height: totalHeight - widget.height),
          // Tab content in the bottom portion
          SizedBox(
            height: widget.height,
            child: Padding(
              padding: EdgeInsets.only(right: widget.fabSize + 28),
              child: Row(
                children: List.generate(tabs.length, (i) {
                  final tab = tabs[i];
                  final isActive = i == widget.activeTab;
                  final color =
                      isActive ? widget.activeColor : widget.inactiveColor;

                  return Expanded(
                    child: SizedBox(
                      height: widget.height - 8,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(tab.icon, size: 20, color: color),
                          const SizedBox(height: 1),
                          Text(
                            tab.label,
                            style: widget.labelStyle?.copyWith(color: color) ??
                                TextStyle(
                                  fontSize: 9,
                                  fontWeight: isActive
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: color,
                                  height: 1.0,
                                ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFab() {
    return GestureDetector(
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
          width: widget.fabSize,
          height: widget.fabSize,
          decoration: BoxDecoration(
            color: widget.fabColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.fabColor.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            _isExpanded ? Icons.close_rounded : _fabIcon,
            size: 24,
            color: widget.fabIconColor,
          ),
        ),
      ),
    );
  }

  Widget _buildScrimPanel() {
    final services = ServiceType.values;
    final itemCount = services.length;
    final popupHeight = (itemCount - 1) * 52.0 + 44.0;
    // Width depends on whether labels are shown
    final popupWidth = widget.showPopupLabels ? 108.0 : 44.0;
    const padding = 8.0;
    // FAB overhang: items float above the bar by fabSize/2 + notchMargin + 8px gap
    final fabOverhang = widget.fabSize / 2 + widget.notchMargin + 8;

    return Positioned(
      bottom: widget.height,
      right: 16 + (widget.fabSize - 44) / 2 - padding,
      child: AnimatedBuilder(
        animation: _expandAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _expandAnimation.value.clamp(0.0, 1.0),
            child: child,
          );
        },
        child: Container(
          width: popupWidth + padding * 2,
          height: fabOverhang + popupHeight + padding,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildServicePopup() {
    final services = ServiceType.values;
    final List<Widget> widgets = [];

    for (int i = 0; i < services.length; i++) {
      final service = services[i];
      final isCurrent = service == widget.currentService;
      // Stack items from bottom to top: index 0 is highest
      final bottomOffset =
          widget.height + (widget.fabSize / 2) + widget.notchMargin +
          8 + (services.length - 1 - i) * 52.0;

      widgets.add(
        Positioned(
          bottom: bottomOffset,
          right: 16 + (widget.fabSize - 44) / 2,
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
            child: GestureDetector(
              onTap: () {
                _dismiss();
                ScreenChangeNotification(_serviceToScreen(service)).dispatch(context);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Label (conditionally shown)
                  if (widget.showPopupLabels) ...[
                    Container(
                      width: 56,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: widget.backgroundColor,
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
                        style: widget.labelStyle?.copyWith(
                              fontSize: 11,
                              color: isCurrent
                                  ? widget.activeColor
                                  : widget.inactiveColor,
                              fontWeight: isCurrent
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ) ??
                            TextStyle(
                              fontSize: 11,
                              color: isCurrent
                                  ? widget.activeColor
                                  : widget.inactiveColor,
                              fontWeight: isCurrent
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  // Icon bubble
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? widget.fabColor
                          : widget.backgroundColor,
                      shape: BoxShape.circle,
                      border: isCurrent
                          ? null
                          : Border.all(
                              color: widget.inactiveColor.withValues(alpha: 0.3),
                            ),
                      boxShadow: [
                        BoxShadow(
                          color: (isCurrent ? widget.fabColor : Colors.black)
                              .withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      _serviceIcons[service],
                      size: 20,
                      color: isCurrent
                          ? widget.fabIconColor
                          : widget.inactiveColor,
                    ),
                  ),
                ],
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
/// for the docked FAB — mirrors the centered notch from Set B but right-aligned.
class _RightNotchedBarPainter extends CustomPainter {
  final Color backgroundColor;
  final double notchRadius;
  final double fabRightOffset;
  final double fabSize;
  final Color? borderColor;
  final double topInset;

  _RightNotchedBarPainter({
    required this.backgroundColor,
    required this.notchRadius,
    required this.fabRightOffset,
    required this.fabSize,
    this.borderColor,
    this.topInset = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildNotchedPath(size);
    canvas.drawPath(path, Paint()..color = backgroundColor);

    if (borderColor != null) {
      final borderPaint = Paint()
        ..color = borderColor!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawPath(_buildTopEdgePath(size), borderPaint);
    }
  }

  Path _buildNotchedPath(Size size) {
    final path = Path();
    final cx = size.width - fabRightOffset - fabSize / 2;
    final r = notchRadius;
    final y0 = topInset; // where the bar's top edge sits

    // Fill from top of widget, dipping into notch cutout at y0
    path.moveTo(0, 0);
    path.lineTo(cx - r - 10, 0);
    // Drop down to bar top edge, then into notch
    path.lineTo(cx - r - 10, y0);
    path.quadraticBezierTo(cx - r, y0, cx - r, y0 + r * 0.25);
    path.arcToPoint(
      Offset(cx + r, y0 + r * 0.25),
      radius: Radius.circular(r * 0.65),
      clockwise: false,
    );
    path.quadraticBezierTo(cx + r, y0, cx + r + 10, y0);
    // Back up to top edge, then across to right
    path.lineTo(cx + r + 10, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  Path _buildTopEdgePath(Size size) {
    final path = Path();
    final cx = size.width - fabRightOffset - fabSize / 2;
    final r = notchRadius;
    final y0 = topInset;

    // Border follows the notch contour (not the top of widget)
    path.moveTo(0, y0);
    path.lineTo(cx - r - 10, y0);
    path.quadraticBezierTo(cx - r, y0, cx - r, y0 + r * 0.25);
    path.arcToPoint(
      Offset(cx + r, y0 + r * 0.25),
      radius: Radius.circular(r * 0.65),
      clockwise: false,
    );
    path.quadraticBezierTo(cx + r, y0, cx + r + 10, y0);
    path.lineTo(size.width, y0);

    return path;
  }

  @override
  bool shouldRepaint(covariant _RightNotchedBarPainter oldDelegate) =>
      backgroundColor != oldDelegate.backgroundColor ||
      notchRadius != oldDelegate.notchRadius ||
      borderColor != oldDelegate.borderColor ||
      fabRightOffset != oldDelegate.fabRightOffset ||
      topInset != oldDelegate.topInset;
}
