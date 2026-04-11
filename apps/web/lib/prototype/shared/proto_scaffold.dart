import 'package:flutter/material.dart';
import '../proto_theme.dart';
import '../prototype_state.dart';
import 'proto_top_bar.dart';
import 'proto_bottom_nav.dart';

/// Convenience wrapper providing top bar + body + bottom nav (Set C).
/// Handles sub-feature tab taps and service switching via PrototypeStateProvider.
class ProtoScaffold extends StatelessWidget {
  final ProtoModule activeModule;
  final Widget body;
  final bool showTopBar;
  final bool showBottomNav;
  final bool overlayTopBar;
  final Color? backgroundColor;
  final int activeTab;
  final Map<int, int>? tabBadges;

  const ProtoScaffold({
    super.key,
    required this.activeModule,
    required this.body,
    this.showTopBar = true,
    this.showBottomNav = true,
    this.overlayTopBar = false,
    this.backgroundColor,
    this.activeTab = 0,
    this.tabBadges,
  });

  /// Bar height used for body bottom padding (just the bar, not FAB overhang).
  static const _barHeight = 52.0;

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.maybeOf(context);
    final theme = ProtoTheme.of(context);
    final bg = backgroundColor ?? theme.background;

    // Overlay mode: top bar floats over the body (transparent, radar shows through)
    if (overlayTopBar && showTopBar) {
      return Container(
        color: bg,
        child: Stack(
          children: [
            // Body fills entire space (extends behind top bar)
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: showBottomNav ? _barHeight : 0,
                ),
                child: body,
              ),
            ),
            // Transparent top bar floats on top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ProtoTopBar(activeModule: activeModule, transparent: true),
            ),
            // Bottom nav
            if (showBottomNav)
              Positioned.fill(
                child: ProtoBottomNavC(
                  activeModule: activeModule,
                  activeTab: activeTab,
                  tabBadges: tabBadges,
                  onTabTapped: (tabIndex) {
                    if (state != null) state.switchTab(tabIndex);
                  },
                  onServiceSelected: (module) {
                    if (state != null) state.switchModule(module);
                  },
                ),
              ),
          ],
        ),
      );
    }

    // Standard mode: top bar in Column above body
    return Container(
      color: bg,
      child: Column(
        children: [
          if (showTopBar) ProtoTopBar(activeModule: activeModule),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: showBottomNav ? _barHeight : 0,
                    ),
                    child: body,
                  ),
                ),
                if (showBottomNav)
                  Positioned.fill(
                    child: ProtoBottomNavC(
                      activeModule: activeModule,
                      activeTab: activeTab,
                      tabBadges: tabBadges,
                      onTabTapped: (tabIndex) {
                        if (state != null) {
                          state.switchTab(tabIndex);
                        }
                      },
                      onServiceSelected: (module) {
                        if (state != null) {
                          state.switchModule(module);
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple back-button top bar for sub-screens
class ProtoSubBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;

  const ProtoSubBar({
    super.key,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);

    return Container(
      padding: const EdgeInsets.only(top: 14, left: 8, right: 16, bottom: 8),
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.text.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => state.pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.background,
                shape: BoxShape.circle,
              ),
              child: Icon(
                theme.icons.arrowBack,
                size: 16,
                color: theme.text,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: theme.title,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}
