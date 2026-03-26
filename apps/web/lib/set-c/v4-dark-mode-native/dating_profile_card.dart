import 'package:flutter/material.dart';
import '../../v4-dark-mode-native/theme.dart';
import '../../widgets/kuwboo_top_bar.dart';
import '../../widgets/bottom_nav_fab.dart';
import '../../data/demo_data.dart';

/// V4: Dark Mode Native Dating Profile Card (Set B - Notched FAB Nav)
/// OLED black, glowing accents, tech-forward aesthetic

class DatingProfileCard extends StatelessWidget {
  const DatingProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = DemoData.mainProfile;
    return Container(color: DarkModeNativeTheme.background, child: SafeArea(child: Stack(children: [Column(children: [KuwbooTopBar(backgroundColor: DarkModeNativeTheme.background, accentColor: DarkModeNativeTheme.primary, textColor: DarkModeNativeTheme.text), Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: DarkModeNativeTheme.spacingMd, vertical: 8), child: _buildProfileCard(profile))), const SizedBox(height: 30)]), Positioned(left: 0, right: 0, bottom: 0, child: _buildBottomNav())])));
  }

  Widget _buildProfileCard(DemoProfile profile) {
    return Container(decoration: DarkModeNativeTheme.glowingCardDecoration(DarkModeNativeTheme.primary), clipBehavior: Clip.antiAlias, child: Column(children: [
      Expanded(flex: 5, child: Stack(fit: StackFit.expand, children: [
        Image.network(profile.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: DarkModeNativeTheme.surfaceElevated, child: Center(child: Icon(Icons.person_rounded, size: 80, color: DarkModeNativeTheme.textTertiary)))),
        Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, DarkModeNativeTheme.background.withValues(alpha: 0.8)], stops: const [0.5, 1.0]))),
        Positioned(top: DarkModeNativeTheme.spacingMd, left: DarkModeNativeTheme.spacingMd, right: DarkModeNativeTheme.spacingMd,
          child: Row(children: List.generate(4, (i) => Expanded(child: Container(height: 3, margin: EdgeInsets.only(right: i < 3 ? 4 : 0), decoration: BoxDecoration(color: i == 0 ? DarkModeNativeTheme.primary : DarkModeNativeTheme.border, borderRadius: BorderRadius.circular(1.5))))))),
        Positioned(top: DarkModeNativeTheme.spacingMd + 16, right: DarkModeNativeTheme.spacingMd,
          child: Container(padding: const EdgeInsets.symmetric(horizontal: DarkModeNativeTheme.spacingSm, vertical: DarkModeNativeTheme.spacingXs),
            decoration: BoxDecoration(color: DarkModeNativeTheme.secondary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(DarkModeNativeTheme.radiusSm), border: Border.all(color: DarkModeNativeTheme.secondary.withValues(alpha: 0.5), width: 1)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 6, height: 6, decoration: BoxDecoration(color: DarkModeNativeTheme.secondary, shape: BoxShape.circle, boxShadow: DarkModeNativeTheme.glowShadow(DarkModeNativeTheme.secondary))), const SizedBox(width: 4), Text('ONLINE', style: DarkModeNativeTheme.caption.copyWith(color: DarkModeNativeTheme.secondary, letterSpacing: 1))]))),
        if (profile.compatibility > 80) Positioned(top: DarkModeNativeTheme.spacingMd + 16, left: DarkModeNativeTheme.spacingMd,
          child: Container(padding: const EdgeInsets.symmetric(horizontal: DarkModeNativeTheme.spacingSm, vertical: DarkModeNativeTheme.spacingXs),
            decoration: BoxDecoration(color: DarkModeNativeTheme.primary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(DarkModeNativeTheme.radiusSm), border: Border.all(color: DarkModeNativeTheme.primary.withValues(alpha: 0.5), width: 1)),
            child: Text('${profile.compatibility}% MATCH', style: DarkModeNativeTheme.caption.copyWith(color: DarkModeNativeTheme.primary, letterSpacing: 1)))),
      ])),
      Expanded(flex: 3, child: Container(padding: const EdgeInsets.fromLTRB(DarkModeNativeTheme.spacingLg, 12, DarkModeNativeTheme.spacingLg, 10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Flexible(child: Text(profile.name, style: DarkModeNativeTheme.headline, overflow: TextOverflow.ellipsis)),
          const SizedBox(width: DarkModeNativeTheme.spacingSm),
          Container(padding: const EdgeInsets.symmetric(horizontal: DarkModeNativeTheme.spacingSm, vertical: DarkModeNativeTheme.spacingXs), decoration: BoxDecoration(color: DarkModeNativeTheme.surfaceElevated, borderRadius: BorderRadius.circular(DarkModeNativeTheme.radiusSm)), child: Text('${profile.age}', style: DarkModeNativeTheme.title)),
          const SizedBox(width: DarkModeNativeTheme.spacingSm),
          if (profile.verified) Icon(Icons.verified_rounded, size: 20, color: DarkModeNativeTheme.primary),
          const Spacer(), _buildDistanceBadge(profile.distance),
        ]),
        const SizedBox(height: 4),
        Text(profile.bio, style: DarkModeNativeTheme.body, maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Wrap(spacing: DarkModeNativeTheme.spacingSm, runSpacing: DarkModeNativeTheme.spacingXs, children: [
          if (profile.tags.isNotEmpty) _buildTag(profile.tags[0], DarkModeNativeTheme.primary),
          if (profile.tags.length > 1) _buildTag(profile.tags[1], DarkModeNativeTheme.secondary),
          if (profile.tags.length > 2) _buildTag(profile.tags[2], DarkModeNativeTheme.tertiary),
        ]),
        const Spacer(),
      ]))),
    ]));
  }

  Widget _buildDistanceBadge(String distance) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: DarkModeNativeTheme.spacingSm, vertical: DarkModeNativeTheme.spacingXs),
      decoration: BoxDecoration(color: DarkModeNativeTheme.surfaceElevated, borderRadius: BorderRadius.circular(DarkModeNativeTheme.radiusSm), border: Border.all(color: DarkModeNativeTheme.border, width: 1)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.location_on_outlined, size: 12, color: DarkModeNativeTheme.textTertiary), const SizedBox(width: 4), Text(distance, style: DarkModeNativeTheme.mono)]));
  }

  Widget _buildTag(String text, Color color) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: DarkModeNativeTheme.spacingMd, vertical: DarkModeNativeTheme.spacingSm),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(DarkModeNativeTheme.radiusSm), border: Border.all(color: color.withValues(alpha: 0.3), width: 1)),
      child: Text(text, style: DarkModeNativeTheme.caption.copyWith(color: color, fontWeight: FontWeight.w600)));
  }

  Widget _buildBottomNav() {
    return BottomNavFab(
      currentService: ServiceType.dating,
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
