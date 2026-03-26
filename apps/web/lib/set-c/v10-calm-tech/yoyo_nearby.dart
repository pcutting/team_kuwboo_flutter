import 'package:flutter/material.dart';
import '../../v10-calm-tech/theme.dart';
import '../../widgets/kuwboo_top_bar.dart';
import '../../widgets/bottom_nav_fab.dart';
import '../../data/demo_data.dart';

/// V10: Calm Tech Yoyo Nearby Screen (Set C - Service Switcher FAB)
/// Gentle discovery, no pressure, mindful design

class YoyoNearby extends StatelessWidget {
  const YoyoNearby({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CalmTechTheme.background,
      child: SafeArea(
        child: Column(
          children: [
            KuwbooTopBar(
              backgroundColor: CalmTechTheme.background,
              accentColor: CalmTechTheme.primary,
              textColor: CalmTechTheme.text,
            ),
            Expanded(child: _buildContent()),
            _buildActionBar(),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final nearbyUsers = DemoData.nearbyUsers;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: CalmTechTheme.spacingLg,
      ),
      child: Column(
        children: [
          // Gentle map area
          Expanded(
            child: Container(
              decoration: CalmTechTheme.cardDecoration,
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Soft gradient background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          CalmTechTheme.primary.withValues(alpha: 0.05),
                          CalmTechTheme.secondary.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                    child: CustomPaint(
                      painter: _CalmMapPainter(),
                    ),
                  ),
                  // Center - you
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                CalmTechTheme.primary,
                                CalmTechTheme.secondary,
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: CalmTechTheme.gentleShadow,
                          ),
                          child: Icon(
                            Icons.person_rounded,
                            size: 28,
                            color: CalmTechTheme.surface,
                          ),
                        ),
                        const SizedBox(height: CalmTechTheme.spacingSm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: CalmTechTheme.spacingMd,
                            vertical: CalmTechTheme.spacingXs,
                          ),
                          decoration: CalmTechTheme.softCardDecoration,
                          child: Text(
                            'You',
                            style: CalmTechTheme.caption.copyWith(
                              color: CalmTechTheme.text,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Nearby - soft markers
                  if (nearbyUsers.isNotEmpty)
                    _buildMarker(
                      left: 50,
                      top: 70,
                      user: nearbyUsers[0],
                      color: CalmTechTheme.primary,
                    ),
                  if (nearbyUsers.length > 1)
                    _buildMarker(
                      right: 60,
                      top: 110,
                      user: nearbyUsers[1],
                      color: CalmTechTheme.secondary,
                    ),
                  if (nearbyUsers.length > 2)
                    _buildMarker(
                      left: 70,
                      bottom: 120,
                      user: nearbyUsers[2],
                      color: CalmTechTheme.tertiary,
                    ),
                  if (nearbyUsers.length > 3)
                    _buildMarker(
                      right: 50,
                      bottom: 80,
                      user: nearbyUsers[3],
                      color: CalmTechTheme.primary,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: CalmTechTheme.spacingLg),
          // Nearby list - gentle
          _buildNearbyList(),
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: ClipOval(
              child: Image.network(
                user.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Text(
                    user.name[0],
                    style: CalmTechTheme.title.copyWith(
                      color: color,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.distance,
            style: CalmTechTheme.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyList() {
    final nearbyUsers = DemoData.nearbyUsers;
    final colors = [
      CalmTechTheme.primary,
      CalmTechTheme.secondary,
      CalmTechTheme.tertiary,
      CalmTechTheme.primary,
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: nearbyUsers.length,
        itemBuilder: (context, index) {
          final user = nearbyUsers[index];
          final color = colors[index % colors.length];
          return _buildNearbyCard(user, color);
        },
      ),
    );
  }

  Widget _buildNearbyCard(NearbyUser user, Color color) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: CalmTechTheme.spacingMd),
      decoration: CalmTechTheme.softCardDecoration,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.antiAlias,
                child: ClipOval(
                  child: Image.network(
                    user.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.person_rounded,
                      size: 22,
                      color: color,
                    ),
                  ),
                ),
              ),
              if (user.isNew)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: CalmTechTheme.surface,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: CalmTechTheme.spacingSm),
          Text(
            user.name,
            style: CalmTechTheme.caption.copyWith(
              color: CalmTechTheme.text,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            user.distance,
            style: CalmTechTheme.caption.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar() {
    return Padding(
      padding: const EdgeInsets.all(CalmTechTheme.spacingLg),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 52,
              decoration: CalmTechTheme.primaryButtonDecoration(
                CalmTechTheme.primary,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.waving_hand_rounded,
                    size: 20,
                    color: CalmTechTheme.surface,
                  ),
                  const SizedBox(width: CalmTechTheme.spacingSm),
                  Text('Say hi', style: CalmTechTheme.button),
                ],
              ),
            ),
          ),
          const SizedBox(width: CalmTechTheme.spacingSm),
          Container(
            width: 52,
            height: 52,
            decoration: CalmTechTheme.outlineButtonDecoration,
            child: Icon(
              Icons.visibility_off_rounded,
              size: 22,
              color: CalmTechTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavFab(
      currentService: ServiceType.yoyo,
      backgroundColor: CalmTechTheme.surface,
      activeColor: CalmTechTheme.primary,
      inactiveColor: CalmTechTheme.textSecondary,
      fabColor: CalmTechTheme.primary,
      fabIconColor: CalmTechTheme.surface,
      borderColor: CalmTechTheme.primary.withValues(alpha: 0.1),
      height: 52,
      fabSize: 50,
      labelStyle: CalmTechTheme.caption.copyWith(fontSize: 8),
    );
  }
}

class _CalmMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Soft concentric circles
    for (int i = 1; i <= 3; i++) {
      final radius = i * size.width * 0.15;
      final paint = Paint()
        ..color = CalmTechTheme.primary.withValues(alpha: 0.06 - (i * 0.015))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius, paint);
    }

    // Soft border for range
    final borderPaint = Paint()
      ..color = CalmTechTheme.primary.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(center, size.width * 0.35, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
