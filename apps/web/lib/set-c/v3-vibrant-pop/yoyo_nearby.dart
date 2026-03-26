import 'package:flutter/material.dart';
import '../../v3-vibrant-pop/theme.dart';
import '../../widgets/kuwboo_top_bar.dart';
import '../../widgets/bottom_nav_fab.dart';
import '../../data/demo_data.dart';

/// V3: Vibrant Pop Yoyo Nearby Screen (Set B - Notched FAB Nav)
/// MATURE VARIANT: Photo avatars, deeper tones, no emojis

class YoyoNearby extends StatelessWidget {
  const YoyoNearby({super.key});

  static const Color _matureAccent = Color(0xFF0052CC);
  static const Color _maturePink = Color(0xFFCC0066);
  static const Color _matureGreen = Color(0xFF00B366);
  static const Color _matureOrange = Color(0xFFCC6600);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: VibrantPopTheme.background,
      child: SafeArea(
        child: Column(
          children: [
            KuwbooTopBar(
              backgroundColor: VibrantPopTheme.background,
              accentColor: VibrantPopTheme.primary,
              textColor: VibrantPopTheme.text,
            ),
            Expanded(child: _buildMapArea()),
            _buildNearbyPeople(),
            _buildWaveButton(),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildMapArea() {
    final nearbyUsers = DemoData.nearbyUsers;
    return Container(
      margin: const EdgeInsets.all(VibrantPopTheme.spacingMd),
      decoration: BoxDecoration(
        color: VibrantPopTheme.surface,
        borderRadius: BorderRadius.circular(VibrantPopTheme.radiusXl),
        boxShadow: VibrantPopTheme.softShadow,
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
                  _matureAccent.withValues(alpha: 0.03),
                  _maturePink.withValues(alpha: 0.03),
                  _matureGreen.withValues(alpha: 0.03),
                ],
              ),
            ),
          ),
          CustomPaint(painter: _MapPainter()),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_matureAccent, const Color(0xFF0088CC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: VibrantPopTheme.colorShadow(_matureAccent),
                  ),
                  child: const Center(
                    child: Icon(Icons.person_rounded, size: 36, color: Colors.white),
                  ),
                ),
                const SizedBox(height: VibrantPopTheme.spacingSm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: VibrantPopTheme.spacingMd,
                    vertical: VibrantPopTheme.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color: VibrantPopTheme.text,
                    borderRadius: BorderRadius.circular(VibrantPopTheme.radiusFull),
                  ),
                  child: Text(
                    'You',
                    style: VibrantPopTheme.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (nearbyUsers.isNotEmpty)
            _buildNearbyMarker(left: 40, top: 60, user: nearbyUsers[0], color: _maturePink),
          if (nearbyUsers.length > 1)
            _buildNearbyMarker(right: 50, top: 100, user: nearbyUsers[1], color: _matureGreen),
          if (nearbyUsers.length > 2)
            _buildNearbyMarker(left: 70, bottom: 120, user: nearbyUsers[2], color: _matureOrange),
          if (nearbyUsers.length > 3)
            _buildNearbyMarker(right: 40, bottom: 80, user: nearbyUsers[3], color: _matureAccent),
          Positioned(
            bottom: VibrantPopTheme.spacingMd,
            left: VibrantPopTheme.spacingMd,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: VibrantPopTheme.spacingMd,
                vertical: VibrantPopTheme.spacingSm,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(VibrantPopTheme.radiusFull),
                boxShadow: VibrantPopTheme.softShadow,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.near_me_rounded, size: 14, color: _matureAccent),
                  const SizedBox(width: 4),
                  Text(
                    '2km range',
                    style: VibrantPopTheme.caption.copyWith(color: VibrantPopTheme.text),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyMarker({
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
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(VibrantPopTheme.radiusMd),
              boxShadow: VibrantPopTheme.colorShadow(color),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              user.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Center(
                child: Icon(Icons.person_rounded, size: 28, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: VibrantPopTheme.spacingSm,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(VibrantPopTheme.radiusSm),
              boxShadow: VibrantPopTheme.softShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user.name,
                  style: VibrantPopTheme.caption.copyWith(
                    color: VibrantPopTheme.text,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
                Text(
                  user.distance,
                  style: VibrantPopTheme.caption.copyWith(fontSize: 9),
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
        padding: const EdgeInsets.symmetric(horizontal: VibrantPopTheme.spacingMd),
        itemCount: nearbyUsers.length,
        itemBuilder: (context, index) {
          final colors = [_maturePink, _matureGreen, _matureOrange, _matureAccent];
          return _buildPersonCard(nearbyUsers[index], colors[index % colors.length]);
        },
      ),
    );
  }

  Widget _buildPersonCard(NearbyUser user, Color color) {
    return Container(
      width: 85,
      margin: const EdgeInsets.only(right: VibrantPopTheme.spacingSm),
      padding: const EdgeInsets.all(VibrantPopTheme.spacingSm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(VibrantPopTheme.radiusMd),
        boxShadow: VibrantPopTheme.softShadow,
        border: user.isNew ? Border.all(color: color, width: 2) : null,
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
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(VibrantPopTheme.radiusSm),
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
                      borderRadius: BorderRadius.circular(VibrantPopTheme.radiusSm),
                    ),
                    child: Text(
                      'NEW',
                      style: VibrantPopTheme.caption.copyWith(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: VibrantPopTheme.spacingXs),
          Text(
            user.name,
            style: VibrantPopTheme.caption.copyWith(
              color: VibrantPopTheme.text,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            user.distance,
            style: VibrantPopTheme.caption.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveButton() {
    return Padding(
      padding: const EdgeInsets.all(VibrantPopTheme.spacingMd),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_maturePink, const Color(0xFFCC4444)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(VibrantPopTheme.radiusFull),
          boxShadow: VibrantPopTheme.colorShadow(_maturePink),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.waving_hand_rounded, size: 22, color: Colors.white),
            const SizedBox(width: VibrantPopTheme.spacingSm),
            Text('Wave to everyone!', style: VibrantPopTheme.button),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavFab(
      currentService: ServiceType.yoyo,
      backgroundColor: VibrantPopTheme.surface,
      activeColor: _matureGreen,
      inactiveColor: VibrantPopTheme.textSecondary,
      fabColor: _maturePink,
      fabIconColor: Colors.white,
      borderColor: VibrantPopTheme.text.withValues(alpha: 0.1),
      height: 52,
      fabSize: 50,
      labelStyle: VibrantPopTheme.caption.copyWith(fontSize: 8),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (int i = 1; i <= 3; i++) {
      final radius = i * size.width * 0.15;
      final paint = Paint()
        ..color = const Color(0xFF0052CC).withValues(alpha: 0.08 - (i * 0.02))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(center, radius, paint);
    }
    final dotPaint = Paint()
      ..color = const Color(0xFF00B366).withValues(alpha: 0.15);
    for (int i = 0; i < 20; i++) {
      final x = (i * 37.0) % size.width;
      final y = (i * 47.0) % size.height;
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
