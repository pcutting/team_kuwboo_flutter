import 'package:flutter/material.dart';
import '../../v5-organic-warmth/theme.dart';
import '../../widgets/kuwboo_top_bar.dart';
import '../../widgets/bottom_nav_fab.dart';
import '../../data/demo_data.dart';

/// V5: Organic Warmth Yoyo Nearby Screen (Set B - Notched FAB Nav)
/// Soft blobs, earth tones, friendly and approachable

class YoyoNearby extends StatelessWidget {
  const YoyoNearby({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(color: OrganicWarmthTheme.background, child: SafeArea(child: Column(children: [KuwbooTopBar(backgroundColor: OrganicWarmthTheme.background, accentColor: OrganicWarmthTheme.primary, textColor: OrganicWarmthTheme.text), Expanded(child: _buildMapArea()), _buildNearbySection(), _buildActionBar(), _buildBottomNav()])));
  }

  Widget _buildMapArea() {
    final nearbyUsers = DemoData.nearbyUsers;
    return Container(margin: const EdgeInsets.all(OrganicWarmthTheme.spacingMd), decoration: OrganicWarmthTheme.cardDecoration, clipBehavior: Clip.antiAlias,
      child: Stack(fit: StackFit.expand, children: [
        Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [OrganicWarmthTheme.tertiary.withValues(alpha: 0.1), OrganicWarmthTheme.secondary.withValues(alpha: 0.1)])), child: CustomPaint(painter: _OrganicMapPainter())),
        Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 64, height: 64, decoration: BoxDecoration(color: OrganicWarmthTheme.primary, borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(32), bottomLeft: Radius.circular(32), bottomRight: Radius.circular(24)), boxShadow: OrganicWarmthTheme.warmShadow), child: Icon(Icons.person_rounded, size: 28, color: OrganicWarmthTheme.surface)),
          const SizedBox(height: OrganicWarmthTheme.spacingSm),
          Container(padding: const EdgeInsets.symmetric(horizontal: OrganicWarmthTheme.spacingMd, vertical: OrganicWarmthTheme.spacingXs), decoration: BoxDecoration(color: OrganicWarmthTheme.surface, borderRadius: BorderRadius.circular(OrganicWarmthTheme.radiusMd), boxShadow: OrganicWarmthTheme.softShadow), child: Text('You', style: OrganicWarmthTheme.caption.copyWith(color: OrganicWarmthTheme.text))),
        ])),
        if (nearbyUsers.isNotEmpty) _buildMarker(left: 50, top: 60, user: nearbyUsers[0]),
        if (nearbyUsers.length > 1) _buildMarker(right: 60, top: 100, user: nearbyUsers[1]),
        if (nearbyUsers.length > 2) _buildMarker(left: 70, bottom: 130, user: nearbyUsers[2]),
        if (nearbyUsers.length > 3) _buildMarker(right: 50, bottom: 90, user: nearbyUsers[3]),
      ]));
  }

  Widget _buildMarker({double? left, double? right, double? top, double? bottom, required NearbyUser user}) {
    return Positioned(left: left, right: right, top: top, bottom: bottom,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(color: OrganicWarmthTheme.surface, borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(24), bottomLeft: Radius.circular(24), bottomRight: Radius.circular(16)), border: Border.all(color: OrganicWarmthTheme.secondary.withValues(alpha: 0.3), width: 2), boxShadow: OrganicWarmthTheme.softShadow), clipBehavior: Clip.antiAlias,
          child: Image.network(user.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Center(child: Text(user.name[0], style: OrganicWarmthTheme.title.copyWith(color: OrganicWarmthTheme.secondary))))),
        const SizedBox(height: 4), Text(user.distance, style: OrganicWarmthTheme.caption),
      ]));
  }

  Widget _buildNearbySection() {
    final nearbyUsers = DemoData.nearbyUsers;
    return Container(height: 110, padding: const EdgeInsets.symmetric(vertical: OrganicWarmthTheme.spacingSm),
      child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: OrganicWarmthTheme.spacingMd), itemCount: nearbyUsers.length, itemBuilder: (context, index) => _buildNearbyCard(nearbyUsers[index])));
  }

  Widget _buildNearbyCard(NearbyUser user) {
    return Container(width: 85, margin: const EdgeInsets.only(right: OrganicWarmthTheme.spacingMd), padding: const EdgeInsets.all(OrganicWarmthTheme.spacingSm),
      decoration: OrganicWarmthTheme.blobDecoration.copyWith(border: user.isNew ? Border.all(color: OrganicWarmthTheme.primary.withValues(alpha: 0.3), width: 2) : null),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Stack(clipBehavior: Clip.none, children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: OrganicWarmthTheme.tertiary.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(OrganicWarmthTheme.radiusSm)), clipBehavior: Clip.antiAlias,
            child: Image.network(user.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.person_rounded, size: 22, color: OrganicWarmthTheme.textTertiary))),
          if (user.isNew) Positioned(top: -4, right: -4, child: Container(width: 14, height: 14, decoration: BoxDecoration(color: OrganicWarmthTheme.primary, shape: BoxShape.circle, border: Border.all(color: OrganicWarmthTheme.surface, width: 2)))),
        ]),
        const SizedBox(height: 2),
        Text(user.name, style: OrganicWarmthTheme.caption.copyWith(color: OrganicWarmthTheme.text, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(user.distance, style: OrganicWarmthTheme.caption.copyWith(fontSize: 10)),
      ]));
  }

  Widget _buildActionBar() {
    return Padding(padding: const EdgeInsets.all(OrganicWarmthTheme.spacingMd), child: Row(children: [
      Expanded(child: Container(height: 54, decoration: OrganicWarmthTheme.primaryButtonDecoration(OrganicWarmthTheme.primary),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.waving_hand_rounded, size: 22, color: OrganicWarmthTheme.surface), const SizedBox(width: OrganicWarmthTheme.spacingSm), Text('Say hello', style: OrganicWarmthTheme.button)]))),
      const SizedBox(width: OrganicWarmthTheme.spacingSm),
      Container(width: 54, height: 54, decoration: OrganicWarmthTheme.blobDecoration, child: Icon(Icons.visibility_off_rounded, size: 22, color: OrganicWarmthTheme.textSecondary)),
    ]));
  }

  Widget _buildBottomNav() {
    return BottomNavFab(
      currentService: ServiceType.yoyo,
      backgroundColor: OrganicWarmthTheme.surface,
      activeColor: OrganicWarmthTheme.primary,
      inactiveColor: OrganicWarmthTheme.textSecondary,
      fabColor: OrganicWarmthTheme.primary,
      fabIconColor: OrganicWarmthTheme.surface,
      borderColor: OrganicWarmthTheme.text.withValues(alpha: 0.1),
      labelStyle: OrganicWarmthTheme.caption.copyWith(fontSize: 8),
    );
  }
}

class _OrganicMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = OrganicWarmthTheme.secondary.withValues(alpha: 0.1)..style = PaintingStyle.fill;
    final path1 = Path()..moveTo(0, size.height * 0.3)..quadraticBezierTo(size.width * 0.2, size.height * 0.4, size.width * 0.3, size.height * 0.25)..quadraticBezierTo(size.width * 0.4, size.height * 0.1, size.width * 0.5, size.height * 0.2)..lineTo(size.width * 0.5, 0)..lineTo(0, 0)..close();
    final path2 = Path()..moveTo(size.width, size.height * 0.6)..quadraticBezierTo(size.width * 0.8, size.height * 0.7, size.width * 0.7, size.height * 0.55)..quadraticBezierTo(size.width * 0.6, size.height * 0.4, size.width * 0.5, size.height * 0.5)..lineTo(size.width * 0.5, size.height)..lineTo(size.width, size.height)..close();
    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint..color = OrganicWarmthTheme.tertiary.withValues(alpha: 0.1));
    final center = Offset(size.width / 2, size.height / 2);
    final circlePaint = Paint()..color = OrganicWarmthTheme.primary.withValues(alpha: 0.08)..style = PaintingStyle.fill;
    canvas.drawCircle(center, size.width * 0.35, circlePaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
