import 'package:flutter/material.dart';
import '../../v5-organic-warmth/theme.dart';
import '../../widgets/kuwboo_top_bar.dart';
import '../../widgets/bottom_nav_fab.dart';
import '../../data/demo_data.dart';

/// V5: Organic Warmth Dating Profile Card (Set B - Notched FAB Nav)
/// Soft blobs, warm colors, approachable feel

class DatingProfileCard extends StatelessWidget {
  const DatingProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = DemoData.mainProfile;
    return Container(color: OrganicWarmthTheme.background, child: SafeArea(child: Stack(children: [Column(children: [KuwbooTopBar(backgroundColor: OrganicWarmthTheme.background, accentColor: OrganicWarmthTheme.primary, textColor: OrganicWarmthTheme.text), Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: OrganicWarmthTheme.spacingMd, vertical: 8), child: _buildProfileCard(profile))), const SizedBox(height: 30)]), Positioned(left: 0, right: 0, bottom: 0, child: _buildBottomNav())])));
  }

  Widget _buildProfileCard(DemoProfile profile) {
    return Container(decoration: OrganicWarmthTheme.cardDecoration, clipBehavior: Clip.antiAlias, child: Column(children: [
      Expanded(flex: 5, child: Stack(fit: StackFit.expand, children: [
        Image.network(profile.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(decoration: BoxDecoration(color: OrganicWarmthTheme.tertiary.withValues(alpha: 0.3)), child: Center(child: Icon(Icons.person_rounded, size: 80, color: OrganicWarmthTheme.textTertiary)))),
        Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, OrganicWarmthTheme.primary.withValues(alpha: 0.2)]))),
        Positioned(top: OrganicWarmthTheme.spacingMd, left: OrganicWarmthTheme.spacingMd, right: OrganicWarmthTheme.spacingMd,
          child: Row(children: List.generate(4, (i) => Expanded(child: Container(height: 4, margin: EdgeInsets.only(right: i < 3 ? 6 : 0), decoration: BoxDecoration(color: i == 0 ? OrganicWarmthTheme.surface : OrganicWarmthTheme.surface.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(2))))))),
        if (profile.verified) Positioned(top: OrganicWarmthTheme.spacingMd + 20, right: OrganicWarmthTheme.spacingMd,
          child: Container(padding: const EdgeInsets.symmetric(horizontal: OrganicWarmthTheme.spacingMd, vertical: OrganicWarmthTheme.spacingSm), decoration: BoxDecoration(color: OrganicWarmthTheme.surface, borderRadius: BorderRadius.circular(OrganicWarmthTheme.radiusMd), boxShadow: OrganicWarmthTheme.softShadow),
            child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.verified_rounded, size: 16, color: OrganicWarmthTheme.secondary), const SizedBox(width: 4), Text('Verified', style: OrganicWarmthTheme.caption.copyWith(color: OrganicWarmthTheme.secondary))]))),
        Positioned(top: OrganicWarmthTheme.spacingMd + 20, left: OrganicWarmthTheme.spacingMd,
          child: Container(padding: const EdgeInsets.symmetric(horizontal: OrganicWarmthTheme.spacingMd, vertical: OrganicWarmthTheme.spacingSm), decoration: BoxDecoration(color: OrganicWarmthTheme.primary.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(OrganicWarmthTheme.radiusMd), boxShadow: OrganicWarmthTheme.softShadow),
            child: Text('${profile.compatibility}% match', style: OrganicWarmthTheme.caption.copyWith(color: OrganicWarmthTheme.surface, fontWeight: FontWeight.w600)))),
      ])),
      Expanded(flex: 3, child: Container(padding: const EdgeInsets.fromLTRB(OrganicWarmthTheme.spacingMd, 10, OrganicWarmthTheme.spacingMd, 8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Flexible(child: Text(profile.name, style: OrganicWarmthTheme.headline, overflow: TextOverflow.ellipsis)), const SizedBox(width: OrganicWarmthTheme.spacingSm),
          Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('${profile.age}', style: OrganicWarmthTheme.subheadline.copyWith(color: OrganicWarmthTheme.textSecondary))),
          const Spacer(), _buildDistancePill(profile.distance),
        ]),
        const SizedBox(height: 4),
        Text(profile.bio, style: OrganicWarmthTheme.body, maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Wrap(spacing: OrganicWarmthTheme.spacingSm, runSpacing: OrganicWarmthTheme.spacingSm, children: [
          if (profile.tags.isNotEmpty) _buildTag(profile.tags[0], isAccent: true),
          if (profile.tags.length > 1) _buildTag(profile.tags[1]),
          if (profile.tags.length > 2) _buildTag(profile.tags[2]),
        ]),
        const Spacer(),
      ]))),
    ]));
  }

  Widget _buildDistancePill(String distance) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: OrganicWarmthTheme.spacingMd, vertical: OrganicWarmthTheme.spacingSm), decoration: OrganicWarmthTheme.pillDecoration,
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.near_me_rounded, size: 14, color: OrganicWarmthTheme.primary), const SizedBox(width: 4), Text(distance, style: OrganicWarmthTheme.caption.copyWith(color: OrganicWarmthTheme.text))]));
  }

  Widget _buildTag(String text, {bool isAccent = false}) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: OrganicWarmthTheme.spacingMd, vertical: OrganicWarmthTheme.spacingSm),
      decoration: isAccent ? OrganicWarmthTheme.accentPillDecoration(OrganicWarmthTheme.primary) : OrganicWarmthTheme.pillDecoration,
      child: Text(text, style: OrganicWarmthTheme.caption.copyWith(color: isAccent ? OrganicWarmthTheme.primary : OrganicWarmthTheme.textSecondary)));
  }

  Widget _buildBottomNav() {
    return BottomNavFab(
      currentService: ServiceType.dating,
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
