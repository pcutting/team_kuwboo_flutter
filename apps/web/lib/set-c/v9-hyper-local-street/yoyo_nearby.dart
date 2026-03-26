import 'package:flutter/material.dart';
import '../../v9-hyper-local-street/theme.dart';
import '../../widgets/kuwboo_top_bar.dart';
import '../../widgets/bottom_nav_fab.dart';
import '../../data/demo_data.dart';

/// V9: Hyper-Local Street Yoyo Nearby Screen (Set B - Notched FAB Nav)
/// Street poster aesthetic, location-focused

class YoyoNearby extends StatelessWidget {
  const YoyoNearby({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: HyperLocalStreetTheme.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KuwbooTopBar(
              backgroundColor: HyperLocalStreetTheme.background,
              accentColor: HyperLocalStreetTheme.primary,
              textColor: HyperLocalStreetTheme.text,
            ),
            _buildLocationBanner(),
            Expanded(child: _buildContent()),
            _buildActionBar(),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationBanner() {
    final nearbyUsers = DemoData.nearbyUsers;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: HyperLocalStreetTheme.spacingMd,
        vertical: HyperLocalStreetTheme.spacingSm,
      ),
      color: HyperLocalStreetTheme.secondary,
      child: Row(
        children: [
          const Icon(
            Icons.location_on,
            size: 16,
            color: HyperLocalStreetTheme.surface,
          ),
          const SizedBox(width: HyperLocalStreetTheme.spacingSm),
          Text(
            'YOUR AREA',
            style: HyperLocalStreetTheme.label.copyWith(
              color: HyperLocalStreetTheme.surface,
            ),
          ),
          const Spacer(),
          Text(
            '${nearbyUsers.length} PEOPLE NEARBY',
            style: HyperLocalStreetTheme.label.copyWith(
              color: HyperLocalStreetTheme.surface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final nearbyUsers = DemoData.nearbyUsers;

    return Container(
      margin: const EdgeInsets.all(HyperLocalStreetTheme.spacingMd),
      decoration: HyperLocalStreetTheme.posterDecoration,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Grid background
          CustomPaint(
            painter: _StreetGridPainter(),
          ),
          // Center marker
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: HyperLocalStreetTheme.primary,
                    border: Border.all(
                      color: HyperLocalStreetTheme.text,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 28,
                    color: HyperLocalStreetTheme.surface,
                  ),
                ),
                const SizedBox(height: HyperLocalStreetTheme.spacingSm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: HyperLocalStreetTheme.spacingMd,
                    vertical: HyperLocalStreetTheme.spacingXs,
                  ),
                  color: HyperLocalStreetTheme.text,
                  child: Text(
                    'YOU',
                    style: HyperLocalStreetTheme.label.copyWith(
                      color: HyperLocalStreetTheme.surface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Nearby markers
          if (nearbyUsers.isNotEmpty)
            _buildMarker(
              left: 50,
              top: 60,
              user: nearbyUsers[0],
            ),
          if (nearbyUsers.length > 1)
            _buildMarker(
              right: 60,
              top: 100,
              user: nearbyUsers[1],
            ),
          if (nearbyUsers.length > 2)
            _buildMarker(
              left: 70,
              bottom: 130,
              user: nearbyUsers[2],
            ),
          if (nearbyUsers.length > 3)
            _buildMarker(
              right: 50,
              bottom: 90,
              user: nearbyUsers[3],
            ),
          // Range label
          Positioned(
            bottom: HyperLocalStreetTheme.spacingMd,
            left: HyperLocalStreetTheme.spacingMd,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: HyperLocalStreetTheme.spacingMd,
                vertical: HyperLocalStreetTheme.spacingSm,
              ),
              color: HyperLocalStreetTheme.tertiary,
              child: Text(
                '2 KM RADIUS',
                style: HyperLocalStreetTheme.label,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarker({
    double? left,
    double? right,
    double? top,
    double? bottom,
    required NearbyUser user,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: HyperLocalStreetTheme.surface,
              border: Border.all(
                color: HyperLocalStreetTheme.text,
                width: 2,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              user.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Center(
                child: Text(
                  user.name[0],
                  style: HyperLocalStreetTheme.subheadline,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            color: user.isNew
                ? HyperLocalStreetTheme.primary
                : HyperLocalStreetTheme.secondary,
            child: Text(
              user.distance.toUpperCase(),
              style: HyperLocalStreetTheme.caption.copyWith(
                color: HyperLocalStreetTheme.surface,
                fontSize: 9,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar() {
    return Padding(
      padding: const EdgeInsets.all(HyperLocalStreetTheme.spacingMd),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 52,
              decoration: HyperLocalStreetTheme.primaryButtonDecoration,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.waving_hand,
                    size: 20,
                    color: HyperLocalStreetTheme.surface,
                  ),
                  const SizedBox(width: HyperLocalStreetTheme.spacingSm),
                  Text('WAVE', style: HyperLocalStreetTheme.button),
                ],
              ),
            ),
          ),
          const SizedBox(width: HyperLocalStreetTheme.spacingSm),
          Container(
            width: 52,
            height: 52,
            decoration: HyperLocalStreetTheme.outlineButtonDecoration,
            child: const Icon(
              Icons.visibility_off,
              size: 22,
              color: HyperLocalStreetTheme.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavFab(
      currentService: ServiceType.yoyo,
      backgroundColor: HyperLocalStreetTheme.surface,
      activeColor: HyperLocalStreetTheme.primary,
      inactiveColor: HyperLocalStreetTheme.textSecondary,
      fabColor: HyperLocalStreetTheme.primary,
      fabIconColor: HyperLocalStreetTheme.surface,
      borderColor: HyperLocalStreetTheme.text.withValues(alpha: 0.2),
      labelStyle: HyperLocalStreetTheme.label.copyWith(fontSize: 8),
    );
  }
}

class _StreetGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = HyperLocalStreetTheme.concrete.withValues(alpha: 0.3)
      ..strokeWidth = 1;

    const spacing = 40.0;

    // Draw grid
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw some "street" lines
    final streetPaint = Paint()
      ..color = HyperLocalStreetTheme.text.withValues(alpha: 0.1)
      ..strokeWidth = 3;

    // Horizontal "street"
    canvas.drawLine(
      Offset(0, size.height * 0.4),
      Offset(size.width, size.height * 0.4),
      streetPaint,
    );

    // Vertical "street"
    canvas.drawLine(
      Offset(size.width * 0.6, 0),
      Offset(size.width * 0.6, size.height),
      streetPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
