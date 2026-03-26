import 'package:flutter/material.dart';
import '../../v2-soft-luxury/theme.dart';
import '../../widgets/kuwboo_top_bar.dart';
import '../../widgets/bottom_nav_fab.dart';
import '../../data/demo_data.dart';

/// V2: Soft Luxury Yoyo Nearby Screen (Set C - Service Switcher FAB)
/// Elegant map with sophisticated user markers

class YoyoNearby extends StatelessWidget {
  const YoyoNearby({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SoftLuxuryTheme.background,
      child: SafeArea(
        child: Column(
          children: [
            KuwbooTopBar(
              backgroundColor: SoftLuxuryTheme.background,
              accentColor: SoftLuxuryTheme.primary,
              textColor: SoftLuxuryTheme.text,
            ),
            Expanded(child: _buildMapArea()),
            _buildBottomSheet(),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildMapArea() {
    final nearbyUsers = DemoData.nearbyUsers;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: SoftLuxuryTheme.spacingMd,
      ),
      decoration: BoxDecoration(
        color: SoftLuxuryTheme.surface,
        borderRadius: BorderRadius.circular(SoftLuxuryTheme.radiusXl),
        boxShadow: SoftLuxuryTheme.softShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  SoftLuxuryTheme.background,
                  SoftLuxuryTheme.divider.withValues(alpha: 0.5),
                ],
              ),
            ),
            child: CustomPaint(
              painter: _SoftMapPainter(),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 52,
                  decoration: BoxDecoration(
                    color: SoftLuxuryTheme.text,
                    shape: BoxShape.circle,
                    boxShadow: SoftLuxuryTheme.softShadow,
                  ),
                  child: Icon(
                    Icons.person,
                    color: SoftLuxuryTheme.surface,
                    size: 24,
                  ),
                ),
                const SizedBox(height: SoftLuxuryTheme.spacingSm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SoftLuxuryTheme.spacingMd,
                    vertical: SoftLuxuryTheme.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color: SoftLuxuryTheme.surface,
                    borderRadius:
                        BorderRadius.circular(SoftLuxuryTheme.radiusMd),
                    boxShadow: SoftLuxuryTheme.subtleShadow,
                  ),
                  child: Text(
                    'You',
                    style: SoftLuxuryTheme.caption.copyWith(
                      color: SoftLuxuryTheme.text,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (nearbyUsers.isNotEmpty)
            _buildNearbyMarker(left: 50, top: 80, user: nearbyUsers[0]),
          if (nearbyUsers.length > 1)
            _buildNearbyMarker(right: 60, top: 120, user: nearbyUsers[1]),
          if (nearbyUsers.length > 2)
            _buildNearbyMarker(left: 80, bottom: 140, user: nearbyUsers[2]),
          if (nearbyUsers.length > 3)
            _buildNearbyMarker(right: 50, bottom: 100, user: nearbyUsers[3]),
        ],
      ),
    );
  }

  Widget _buildNearbyMarker({
    double? left, double? right, double? top, double? bottom,
    required NearbyUser user,
  }) {
    return Positioned(
      left: left, right: right, top: top, bottom: bottom,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: SoftLuxuryTheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: SoftLuxuryTheme.primary.withValues(alpha: 0.3), width: 2),
              boxShadow: SoftLuxuryTheme.subtleShadow,
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(user.imageUrl, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Center(
                child: Text(user.name[0], style: SoftLuxuryTheme.title.copyWith(color: SoftLuxuryTheme.primary)),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(user.distance, style: SoftLuxuryTheme.label.copyWith(color: SoftLuxuryTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildBottomSheet() {
    final nearbyUsers = DemoData.nearbyUsers;

    return Container(
      margin: const EdgeInsets.all(SoftLuxuryTheme.spacingMd),
      padding: const EdgeInsets.all(SoftLuxuryTheme.spacingMd),
      decoration: BoxDecoration(
        color: SoftLuxuryTheme.surface,
        borderRadius: BorderRadius.circular(SoftLuxuryTheme.radiusXl),
        boxShadow: SoftLuxuryTheme.softShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Recently Nearby', style: SoftLuxuryTheme.title),
              const Spacer(),
              Text('See all', style: SoftLuxuryTheme.caption.copyWith(color: SoftLuxuryTheme.primary)),
            ],
          ),
          const SizedBox(height: SoftLuxuryTheme.spacingSm),
          SizedBox(
            height: 88,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: nearbyUsers.length,
              itemBuilder: (context, index) => _buildNearbyPerson(nearbyUsers[index]),
            ),
          ),
          const SizedBox(height: SoftLuxuryTheme.spacingSm),
          SoftLuxuryTheme.hairlineDivider,
          const SizedBox(height: SoftLuxuryTheme.spacingSm),
          Container(
            width: double.infinity, height: 44,
            decoration: SoftLuxuryTheme.primaryButtonDecoration,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.waving_hand_rounded, size: 16, color: SoftLuxuryTheme.surface),
                  const SizedBox(width: SoftLuxuryTheme.spacingSm),
                  Text('Send a greeting', style: SoftLuxuryTheme.button),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyPerson(NearbyUser user) {
    return Container(
      width: 72,
      margin: const EdgeInsets.only(right: SoftLuxuryTheme.spacingSm),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: SoftLuxuryTheme.background, shape: BoxShape.circle,
                  border: Border.all(color: user.isNew ? SoftLuxuryTheme.primary : SoftLuxuryTheme.divider, width: user.isNew ? 2 : 1),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(user.imageUrl, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(Icons.person, size: 24, color: SoftLuxuryTheme.textTertiary),
                ),
              ),
              if (user.isNew)
                Positioned(top: -2, right: -2,
                  child: Container(width: 14, height: 14,
                    decoration: BoxDecoration(color: SoftLuxuryTheme.primary, shape: BoxShape.circle,
                      border: Border.all(color: SoftLuxuryTheme.surface, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: SoftLuxuryTheme.spacingXs),
          Text(user.name, style: SoftLuxuryTheme.caption.copyWith(color: SoftLuxuryTheme.text), overflow: TextOverflow.ellipsis, maxLines: 1),
          Text(user.distance, style: SoftLuxuryTheme.label),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavFab(
      currentService: ServiceType.yoyo,
      backgroundColor: SoftLuxuryTheme.surface,
      activeColor: SoftLuxuryTheme.primary,
      inactiveColor: SoftLuxuryTheme.textSecondary,
      fabColor: SoftLuxuryTheme.secondary,
      fabIconColor: SoftLuxuryTheme.surface,
      borderColor: SoftLuxuryTheme.divider,
      height: 52,
      fabSize: 50,
      labelStyle: SoftLuxuryTheme.caption.copyWith(fontSize: 8),
    );
  }
}

class _SoftMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SoftLuxuryTheme.divider.withValues(alpha: 0.5)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final path1 = Path()..moveTo(0, size.height * 0.3)..quadraticBezierTo(size.width * 0.3, size.height * 0.35, size.width * 0.5, size.height * 0.25)..quadraticBezierTo(size.width * 0.7, size.height * 0.15, size.width, size.height * 0.2);
    final path2 = Path()..moveTo(0, size.height * 0.7)..quadraticBezierTo(size.width * 0.4, size.height * 0.65, size.width * 0.6, size.height * 0.75)..quadraticBezierTo(size.width * 0.8, size.height * 0.85, size.width, size.height * 0.8);
    final path3 = Path()..moveTo(size.width * 0.3, 0)..quadraticBezierTo(size.width * 0.35, size.height * 0.4, size.width * 0.25, size.height);
    final path4 = Path()..moveTo(size.width * 0.7, 0)..quadraticBezierTo(size.width * 0.65, size.height * 0.5, size.width * 0.75, size.height);

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
    canvas.drawPath(path3, paint);
    canvas.drawPath(path4, paint);

    final center = Offset(size.width / 2, size.height / 2);
    final rangePaint = Paint()..color = SoftLuxuryTheme.primary.withValues(alpha: 0.1)..style = PaintingStyle.fill;
    canvas.drawCircle(center, size.width * 0.35, rangePaint);

    final rangeBorderPaint = Paint()..color = SoftLuxuryTheme.primary.withValues(alpha: 0.2)..strokeWidth = 1..style = PaintingStyle.stroke;
    canvas.drawCircle(center, size.width * 0.35, rangeBorderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
