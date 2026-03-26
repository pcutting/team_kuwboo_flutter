import 'package:flutter/material.dart';
import '../../v0-urban-warmth/theme.dart';
import '../../widgets/kuwboo_top_bar.dart';
import '../../widgets/bottom_nav_fab.dart';
import '../../data/demo_data.dart';

/// V0: Urban Warmth Yoyo Nearby Screen (Set B - Notched FAB Nav)
/// Hybrid of V5 organic map blobs + V9 location-forward banner.
/// Warm earth tones, bold condensed labels, organic marker shapes.

class YoyoNearby extends StatelessWidget {
  const YoyoNearby({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: UrbanWarmthTheme.background,
      child: SafeArea(
        child: Column(
          children: [
            KuwbooTopBar(
              backgroundColor: UrbanWarmthTheme.background,
              accentColor: UrbanWarmthTheme.primary,
              textColor: UrbanWarmthTheme.text,
            ),
            _buildLocationBanner(),
            Expanded(child: _buildMapArea()),
            _buildNearbyPeople(),
            _buildActionBar(),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  /// V9-style location banner with V5 warm colors
  Widget _buildLocationBanner() {
    final nearbyUsers = DemoData.nearbyUsers;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UrbanWarmthTheme.spacingMd,
        vertical: UrbanWarmthTheme.spacingSm,
      ),
      color: UrbanWarmthTheme.secondary,
      child: Row(
        children: [
          const Icon(
            Icons.near_me_rounded,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: UrbanWarmthTheme.spacingSm),
          Text(
            'YOUR AREA',
            style: UrbanWarmthTheme.label.copyWith(color: Colors.white),
          ),
          const Spacer(),
          Text(
            '${nearbyUsers.length} NEARBY',
            style: UrbanWarmthTheme.label.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  /// V5-style organic map with warm gradient background
  Widget _buildMapArea() {
    final nearbyUsers = DemoData.nearbyUsers;
    return Container(
      margin: const EdgeInsets.all(UrbanWarmthTheme.spacingMd),
      decoration: UrbanWarmthTheme.cardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Warm gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  UrbanWarmthTheme.tertiary.withValues(alpha: 0.08),
                  UrbanWarmthTheme.secondary.withValues(alpha: 0.06),
                  UrbanWarmthTheme.primary.withValues(alpha: 0.05),
                ],
              ),
            ),
          ),
          // Organic radar rings (V5 style)
          CustomPaint(painter: _OrganicMapPainter()),
          // Center marker — you
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [UrbanWarmthTheme.primary, UrbanWarmthTheme.accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(UrbanWarmthTheme.radiusMd),
                    boxShadow: UrbanWarmthTheme.colorShadow(UrbanWarmthTheme.primary),
                  ),
                  child: const Center(
                    child: Icon(Icons.person_rounded, size: 32, color: Colors.white),
                  ),
                ),
                const SizedBox(height: UrbanWarmthTheme.spacingSm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: UrbanWarmthTheme.spacingMd,
                    vertical: UrbanWarmthTheme.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color: UrbanWarmthTheme.text,
                    borderRadius: BorderRadius.circular(UrbanWarmthTheme.radiusFull),
                  ),
                  child: Text(
                    'YOU',
                    style: UrbanWarmthTheme.label.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Nearby markers — organic rounded (V5) with photo
          if (nearbyUsers.isNotEmpty)
            _buildMarker(left: 40, top: 50, user: nearbyUsers[0], color: UrbanWarmthTheme.accent),
          if (nearbyUsers.length > 1)
            _buildMarker(right: 50, top: 90, user: nearbyUsers[1], color: UrbanWarmthTheme.secondary),
          if (nearbyUsers.length > 2)
            _buildMarker(left: 60, bottom: 120, user: nearbyUsers[2], color: UrbanWarmthTheme.primary),
          if (nearbyUsers.length > 3)
            _buildMarker(right: 40, bottom: 70, user: nearbyUsers[3], color: UrbanWarmthTheme.secondary),
          // Range label — V9 condensed type, V5 warm pill
          Positioned(
            bottom: UrbanWarmthTheme.spacingMd,
            left: UrbanWarmthTheme.spacingMd,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: UrbanWarmthTheme.spacingMd,
                vertical: UrbanWarmthTheme.spacingSm,
              ),
              decoration: BoxDecoration(
                color: UrbanWarmthTheme.surface,
                borderRadius: BorderRadius.circular(UrbanWarmthTheme.radiusFull),
                boxShadow: UrbanWarmthTheme.softShadow,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.near_me_rounded, size: 12, color: UrbanWarmthTheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    '2 KM RADIUS',
                    style: UrbanWarmthTheme.label.copyWith(
                      color: UrbanWarmthTheme.text,
                      fontSize: 10,
                    ),
                  ),
                ],
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
    required Color color,
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
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(UrbanWarmthTheme.radiusMd),
              boxShadow: UrbanWarmthTheme.colorShadow(color),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              user.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Center(
                child: Icon(Icons.person_rounded, size: 26, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: UrbanWarmthTheme.spacingSm,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: UrbanWarmthTheme.surface,
              borderRadius: BorderRadius.circular(UrbanWarmthTheme.radiusSm),
              boxShadow: UrbanWarmthTheme.softShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user.name,
                  style: UrbanWarmthTheme.caption.copyWith(
                    color: UrbanWarmthTheme.text,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
                Text(
                  user.distance.toUpperCase(),
                  style: UrbanWarmthTheme.label.copyWith(
                    fontSize: 9,
                    color: UrbanWarmthTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyPeople() {
    final nearbyUsers = DemoData.nearbyUsers;
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: UrbanWarmthTheme.spacingMd),
        itemCount: nearbyUsers.length,
        itemBuilder: (context, index) {
          final colors = [
            UrbanWarmthTheme.accent,
            UrbanWarmthTheme.secondary,
            UrbanWarmthTheme.primary,
            UrbanWarmthTheme.secondary,
          ];
          return _buildPersonCard(nearbyUsers[index], colors[index % colors.length]);
        },
      ),
    );
  }

  Widget _buildPersonCard(NearbyUser user, Color color) {
    return Container(
      width: 85,
      margin: const EdgeInsets.only(right: UrbanWarmthTheme.spacingSm),
      padding: const EdgeInsets.all(UrbanWarmthTheme.spacingSm),
      decoration: BoxDecoration(
        color: UrbanWarmthTheme.surface,
        borderRadius: BorderRadius.circular(UrbanWarmthTheme.radiusMd),
        boxShadow: UrbanWarmthTheme.softShadow,
        border: user.isNew
            ? Border.all(color: color, width: 2)
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(UrbanWarmthTheme.radiusSm),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  user.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(
                    child: Icon(Icons.person_rounded, size: 24, color: color),
                  ),
                ),
              ),
              if (user.isNew)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(UrbanWarmthTheme.radiusSm),
                    ),
                    child: Text(
                      'NEW',
                      style: UrbanWarmthTheme.caption.copyWith(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: UrbanWarmthTheme.spacingXs),
          Text(
            user.name,
            style: UrbanWarmthTheme.caption.copyWith(
              color: UrbanWarmthTheme.text,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            user.distance,
            style: UrbanWarmthTheme.caption.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: UrbanWarmthTheme.spacingMd,
        vertical: UrbanWarmthTheme.spacingSm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [UrbanWarmthTheme.primary, UrbanWarmthTheme.accent],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(UrbanWarmthTheme.radiusFull),
                boxShadow: UrbanWarmthTheme.colorShadow(UrbanWarmthTheme.primary),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.waving_hand_rounded, size: 20, color: Colors.white),
                  const SizedBox(width: UrbanWarmthTheme.spacingSm),
                  Text('WAVE', style: UrbanWarmthTheme.button),
                ],
              ),
            ),
          ),
          const SizedBox(width: UrbanWarmthTheme.spacingSm),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: UrbanWarmthTheme.surface,
              borderRadius: BorderRadius.circular(UrbanWarmthTheme.radiusFull),
              boxShadow: UrbanWarmthTheme.softShadow,
            ),
            child: Icon(
              Icons.tune_rounded,
              size: 20,
              color: UrbanWarmthTheme.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavFab(
      currentService: ServiceType.yoyo,
      backgroundColor: UrbanWarmthTheme.surface,
      activeColor: UrbanWarmthTheme.primary,
      inactiveColor: UrbanWarmthTheme.textSecondary,
      fabColor: UrbanWarmthTheme.primary,
      fabIconColor: UrbanWarmthTheme.surface,
      borderColor: UrbanWarmthTheme.text.withValues(alpha: 0.1),
      height: 52,
      fabSize: 50,
      labelStyle: UrbanWarmthTheme.caption.copyWith(fontSize: 8),
    );
  }
}

class _OrganicMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Organic radar rings — slightly irregular like V5
    for (int i = 1; i <= 3; i++) {
      final radius = i * size.width * 0.14;
      final paint = Paint()
        ..color = const Color(0xFFCB6843).withValues(alpha: 0.08 - (i * 0.02))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(center, radius, paint);
    }

    // Scattered warm dots
    final dotPaint = Paint()
      ..color = const Color(0xFF7B9E6B).withValues(alpha: 0.12);
    for (int i = 0; i < 15; i++) {
      final x = (i * 41.0) % size.width;
      final y = (i * 53.0) % size.height;
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
