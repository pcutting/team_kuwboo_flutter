import 'package:flutter/material.dart';
import '../../v0-urban-warmth/theme.dart';
import '../../widgets/kuwboo_top_bar.dart';
import '../../widgets/bottom_nav_fab.dart';
import '../../data/demo_data.dart';

/// V0: Urban Warmth Dating Profile Card (Set B - Notched FAB Nav)
/// FULL-BLEED PHOTO — image fills the entire screen below header.
/// Warm terracotta gradient overlay, bold condensed type, organic badges.
/// Hybrid of V5 Organic Warmth + V9 Hyper-Local Street.

class DatingProfileCard extends StatelessWidget {
  const DatingProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = DemoData.mainProfile;

    return Container(
      color: UrbanWarmthTheme.background,
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                KuwbooTopBar(
                  backgroundColor: UrbanWarmthTheme.background,
                  accentColor: UrbanWarmthTheme.primary,
                  textColor: UrbanWarmthTheme.text,
                ),
                Expanded(
                  child: _buildFullBleedCard(profile),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomNav(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullBleedCard(DemoProfile profile) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        UrbanWarmthTheme.spacingMd,
        0,
        UrbanWarmthTheme.spacingMd,
        0,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(UrbanWarmthTheme.radiusLg),
        boxShadow: UrbanWarmthTheme.warmShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Full-bleed photo
          Image.network(
            profile.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: UrbanWarmthTheme.tertiary.withValues(alpha: 0.3),
              child: Center(
                child: Icon(
                  Icons.person_rounded,
                  size: 80,
                  color: UrbanWarmthTheme.textTertiary,
                ),
              ),
            ),
          ),
          // Warm gradient overlay — terracotta tinted, not cold black
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    UrbanWarmthTheme.primary.withValues(alpha: 0.15),
                    const Color(0xFF2D1A0E).withValues(alpha: 0.85),
                  ],
                  stops: const [0.0, 0.35, 0.6, 1.0],
                ),
              ),
            ),
          ),
          // Photo indicators — top
          Positioned(
            top: UrbanWarmthTheme.spacingMd,
            left: UrbanWarmthTheme.spacingMd,
            right: UrbanWarmthTheme.spacingMd,
            child: Row(
              children: List.generate(5, (i) {
                return Expanded(
                  child: Container(
                    height: 3,
                    margin: EdgeInsets.only(right: i < 4 ? 4 : 0),
                    decoration: BoxDecoration(
                      color: i == 0
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          // Match badge — top left, organic pill (V5 style)
          Positioned(
            top: UrbanWarmthTheme.spacingMd + 16,
            left: UrbanWarmthTheme.spacingMd,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: UrbanWarmthTheme.spacingMd,
                vertical: UrbanWarmthTheme.spacingSm,
              ),
              decoration: BoxDecoration(
                color: UrbanWarmthTheme.primary.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(UrbanWarmthTheme.radiusFull),
                boxShadow: UrbanWarmthTheme.colorShadow(UrbanWarmthTheme.primary),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite_rounded, size: 14, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    '${profile.compatibility}% match',
                    style: UrbanWarmthTheme.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Verified + featured badges — top right (V5 organic rounded)
          Positioned(
            top: UrbanWarmthTheme.spacingMd + 16,
            right: UrbanWarmthTheme.spacingMd,
            child: Column(
              children: [
                if (profile.verified)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: UrbanWarmthTheme.spacingSm + 2,
                      vertical: UrbanWarmthTheme.spacingSm,
                    ),
                    decoration: BoxDecoration(
                      color: UrbanWarmthTheme.secondary,
                      borderRadius: BorderRadius.circular(UrbanWarmthTheme.radiusMd),
                      boxShadow: UrbanWarmthTheme.colorShadow(UrbanWarmthTheme.secondary),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_rounded, size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          'Verified',
                          style: UrbanWarmthTheme.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Info section — overlaid at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(UrbanWarmthTheme.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name — V9 bold condensed display
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        profile.name.toUpperCase(),
                        style: UrbanWarmthTheme.display,
                      ),
                      const SizedBox(width: UrbanWarmthTheme.spacingSm),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: UrbanWarmthTheme.spacingSm + 2,
                            vertical: UrbanWarmthTheme.spacingXs,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(UrbanWarmthTheme.radiusSm),
                          ),
                          child: Text(
                            '${profile.age}',
                            style: UrbanWarmthTheme.subheadline.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: UrbanWarmthTheme.spacingSm),
                  // Distance — V9 location-forward style
                  Row(
                    children: [
                      Icon(
                        Icons.near_me_rounded,
                        size: 14,
                        color: UrbanWarmthTheme.tertiary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        profile.distance,
                        style: UrbanWarmthTheme.body.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: UrbanWarmthTheme.spacingSm),
                  // Bio
                  Text(
                    profile.bio,
                    style: UrbanWarmthTheme.body.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: UrbanWarmthTheme.spacingMd),
                  // Interest tags — V5 organic pills with warm colors
                  Wrap(
                    spacing: UrbanWarmthTheme.spacingSm,
                    runSpacing: UrbanWarmthTheme.spacingSm,
                    children: [
                      if (profile.tags.isNotEmpty)
                        _buildTag(profile.tags[0], UrbanWarmthTheme.primary),
                      if (profile.tags.length > 1)
                        _buildTag(profile.tags[1], UrbanWarmthTheme.secondary),
                      if (profile.tags.length > 2)
                        _buildTag(profile.tags[2], UrbanWarmthTheme.accent),
                    ],
                  ),
                  const SizedBox(height: UrbanWarmthTheme.spacingLg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UrbanWarmthTheme.spacingMd,
        vertical: UrbanWarmthTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(UrbanWarmthTheme.radiusFull),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: UrbanWarmthTheme.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavFab(
      currentService: ServiceType.dating,
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
