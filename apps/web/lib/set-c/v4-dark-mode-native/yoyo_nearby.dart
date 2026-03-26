import 'package:flutter/material.dart';
import '../../v4-dark-mode-native/theme.dart';
import '../../widgets/kuwboo_top_bar.dart';
import '../../widgets/bottom_nav_fab.dart';
import '../../data/demo_data.dart';

/// V4: Dark Mode Native Yoyo Nearby Screen (Set B - Notched FAB Nav)
/// OLED black with glowing elements and tech aesthetic

class YoyoNearby extends StatelessWidget {
  const YoyoNearby({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(color: DarkModeNativeTheme.background, child: SafeArea(child: Column(children: [KuwbooTopBar(backgroundColor: DarkModeNativeTheme.background, accentColor: DarkModeNativeTheme.primary, textColor: DarkModeNativeTheme.text), Expanded(child: _buildMapArea()), _buildNearbyList(), _buildBottomBar(), _buildBottomNav()])));
  }

  Widget _buildMapArea() {
    final nearbyUsers = DemoData.nearbyUsers;
    return Container(margin: const EdgeInsets.all(DarkModeNativeTheme.spacingMd), decoration: DarkModeNativeTheme.cardDecoration, clipBehavior: Clip.antiAlias,
      child: Stack(fit: StackFit.expand, children: [
        CustomPaint(painter: _DarkMapPainter()),
        Center(child: _buildRadarEffect()),
        Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 64, height: 64, decoration: BoxDecoration(color: DarkModeNativeTheme.primary, shape: BoxShape.circle, boxShadow: DarkModeNativeTheme.glowShadow(DarkModeNativeTheme.primary)), child: Icon(Icons.person_rounded, size: 28, color: DarkModeNativeTheme.text)),
          const SizedBox(height: DarkModeNativeTheme.spacingSm),
          Container(padding: const EdgeInsets.symmetric(horizontal: DarkModeNativeTheme.spacingMd, vertical: DarkModeNativeTheme.spacingXs), decoration: BoxDecoration(color: DarkModeNativeTheme.surfaceElevated, borderRadius: BorderRadius.circular(DarkModeNativeTheme.radiusSm), border: Border.all(color: DarkModeNativeTheme.border, width: 1)), child: Text('YOU', style: DarkModeNativeTheme.caption.copyWith(color: DarkModeNativeTheme.text, letterSpacing: 1))),
        ])),
        if (nearbyUsers.isNotEmpty) _buildMarker(left: 50, top: 70, user: nearbyUsers[0], color: DarkModeNativeTheme.secondary),
        if (nearbyUsers.length > 1) _buildMarker(right: 60, top: 110, user: nearbyUsers[1], color: DarkModeNativeTheme.tertiary),
        if (nearbyUsers.length > 2) _buildMarker(left: 80, bottom: 130, user: nearbyUsers[2], color: DarkModeNativeTheme.primary),
        if (nearbyUsers.length > 3) _buildMarker(right: 50, bottom: 90, user: nearbyUsers[3], color: DarkModeNativeTheme.secondary),
        Positioned(bottom: DarkModeNativeTheme.spacingMd, left: DarkModeNativeTheme.spacingMd,
          child: Container(padding: const EdgeInsets.symmetric(horizontal: DarkModeNativeTheme.spacingMd, vertical: DarkModeNativeTheme.spacingSm), decoration: BoxDecoration(color: DarkModeNativeTheme.surfaceElevated.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(DarkModeNativeTheme.radiusSm), border: Border.all(color: DarkModeNativeTheme.border, width: 1)), child: Text('2.0 km radius', style: DarkModeNativeTheme.mono))),
      ]));
  }

  Widget _buildRadarEffect() { return SizedBox(width: 200, height: 200, child: CustomPaint(painter: _RadarPainter())); }

  Widget _buildMarker({double? left, double? right, double? top, double? bottom, required NearbyUser user, required Color color}) {
    return Positioned(left: left, right: right, top: top, bottom: bottom,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(DarkModeNativeTheme.radiusSm), border: Border.all(color: color.withValues(alpha: 0.5), width: 1), boxShadow: DarkModeNativeTheme.subtleGlow(color)), clipBehavior: Clip.antiAlias,
          child: Image.network(user.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Center(child: Text(user.name[0], style: DarkModeNativeTheme.title.copyWith(color: color))))),
        const SizedBox(height: 4),
        Text(user.distance, style: DarkModeNativeTheme.mono.copyWith(fontSize: 10, color: DarkModeNativeTheme.textTertiary)),
      ]));
  }

  Widget _buildNearbyList() {
    final nearbyUsers = DemoData.nearbyUsers;
    final colors = [DarkModeNativeTheme.secondary, DarkModeNativeTheme.tertiary, DarkModeNativeTheme.primary, DarkModeNativeTheme.secondary];
    return Container(height: 100, padding: const EdgeInsets.symmetric(vertical: DarkModeNativeTheme.spacingSm),
      child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: DarkModeNativeTheme.spacingMd), itemCount: nearbyUsers.length,
        itemBuilder: (context, index) => _buildNearbyCard(nearbyUsers[index], colors[index % colors.length])));
  }

  Widget _buildNearbyCard(NearbyUser user, Color color) {
    return Container(width: 80, margin: const EdgeInsets.only(right: DarkModeNativeTheme.spacingSm),
      decoration: BoxDecoration(color: DarkModeNativeTheme.surfaceElevated, borderRadius: BorderRadius.circular(DarkModeNativeTheme.radiusMd), border: Border.all(color: user.isNew ? color.withValues(alpha: 0.3) : DarkModeNativeTheme.border, width: 1)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Stack(clipBehavior: Clip.none, children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(DarkModeNativeTheme.radiusSm), border: Border.all(color: color.withValues(alpha: 0.3), width: 1)), clipBehavior: Clip.antiAlias,
            child: Image.network(user.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.person_rounded, size: 20, color: color))),
          if (user.isNew) Positioned(top: -4, right: -4, child: Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: DarkModeNativeTheme.subtleGlow(color)))),
        ]),
        const SizedBox(height: DarkModeNativeTheme.spacingSm),
        Text(user.name, style: DarkModeNativeTheme.caption.copyWith(color: DarkModeNativeTheme.text, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(user.distance, style: DarkModeNativeTheme.mono.copyWith(fontSize: 10)),
      ]));
  }

  Widget _buildBottomBar() {
    return Padding(padding: const EdgeInsets.all(DarkModeNativeTheme.spacingMd), child: Row(children: [
      Expanded(child: Container(height: 52, decoration: DarkModeNativeTheme.primaryButtonDecoration(DarkModeNativeTheme.primary),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.waving_hand_rounded, size: 20, color: DarkModeNativeTheme.text), const SizedBox(width: DarkModeNativeTheme.spacingSm), Text('Wave to all', style: DarkModeNativeTheme.button)]))),
      const SizedBox(width: DarkModeNativeTheme.spacingSm),
      Container(width: 52, height: 52, decoration: DarkModeNativeTheme.outlineButtonDecoration, child: Icon(Icons.visibility_off_rounded, size: 22, color: DarkModeNativeTheme.textSecondary)),
    ]));
  }

  Widget _buildBottomNav() {
    return BottomNavFab(
      currentService: ServiceType.yoyo,
      backgroundColor: DarkModeNativeTheme.surfaceElevated,
      activeColor: DarkModeNativeTheme.primary,
      inactiveColor: DarkModeNativeTheme.textSecondary,
      fabColor: DarkModeNativeTheme.primary,
      fabIconColor: DarkModeNativeTheme.text,
      borderColor: DarkModeNativeTheme.border,
      labelStyle: DarkModeNativeTheme.caption.copyWith(fontSize: 8),
    );
  }
}

class _DarkMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()..color = DarkModeNativeTheme.border.withValues(alpha: 0.5)..strokeWidth = 0.5;
    const spacing = 30.0;
    for (double x = 0; x < size.width; x += spacing) { canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint); }
    for (double y = 0; y < size.height; y += spacing) { canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint); }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RadarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (int i = 1; i <= 3; i++) {
      final radius = i * 30.0;
      final paint = Paint()..color = DarkModeNativeTheme.primary.withValues(alpha: 0.1)..style = PaintingStyle.stroke..strokeWidth = 1;
      canvas.drawCircle(center, radius, paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
