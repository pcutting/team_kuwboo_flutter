import 'package:flutter/material.dart';
import '../../v10-calm-tech/theme.dart';
import '../../widgets/kuwboo_top_bar.dart';
import '../../widgets/bottom_nav_fab.dart';
import '../../data/demo_data.dart';

/// V10: Calm Tech Dating Profile Card (Set C - Service Switcher FAB)
/// Gentle, anxiety-free, mindful design

class DatingProfileCard extends StatelessWidget {
  const DatingProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = DemoData.mainProfile;

    return Container(
      color: CalmTechTheme.background,
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                KuwbooTopBar(
                  backgroundColor: CalmTechTheme.background,
                  accentColor: CalmTechTheme.primary,
                  textColor: CalmTechTheme.text,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      CalmTechTheme.spacingMd,
                      CalmTechTheme.spacingSm,
                      CalmTechTheme.spacingMd,
                      CalmTechTheme.spacingSm,
                    ),
                    child: _buildProfileCard(profile),
                  ),
                ),
                const SizedBox(height: 30),
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

  Widget _buildProfileCard(DemoProfile profile) {
    return Container(
      decoration: CalmTechTheme.cardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Photo area
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Profile image
                Image.network(
                  profile.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          CalmTechTheme.primary.withValues(alpha: 0.2),
                          CalmTechTheme.secondary.withValues(alpha: 0.2),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.person_rounded,
                        size: 80,
                        color: CalmTechTheme.textTertiary,
                      ),
                    ),
                  ),
                ),
                // Photo dots - no progress pressure
                Positioned(
                  top: CalmTechTheme.spacingMd,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (i) {
                      return Container(
                        width: i == 0 ? 24 : 8,
                        height: 8,
                        margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                        decoration: BoxDecoration(
                          color: i == 0
                              ? CalmTechTheme.primary
                              : CalmTechTheme.surface.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ),
                // Gentle verified indicator
                if (profile.verified)
                  Positioned(
                    top: CalmTechTheme.spacingMd + 20,
                    right: CalmTechTheme.spacingMd,
                    child: Container(
                      padding: const EdgeInsets.all(CalmTechTheme.spacingSm),
                      decoration: CalmTechTheme.softCardDecoration,
                      child: Icon(
                        Icons.verified_rounded,
                        size: 18,
                        color: CalmTechTheme.secondary,
                      ),
                    ),
                  ),
                // Match indicator - gentle
                Positioned(
                  top: CalmTechTheme.spacingMd + 20,
                  left: CalmTechTheme.spacingMd,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: CalmTechTheme.spacingMd,
                      vertical: CalmTechTheme.spacingSm,
                    ),
                    decoration: CalmTechTheme.softCardDecoration,
                    child: Text(
                      '${profile.compatibility}% compatible',
                      style: CalmTechTheme.caption.copyWith(
                        color: CalmTechTheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Info section - breathing room
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(CalmTechTheme.spacingMd, 10, CalmTechTheme.spacingMd, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name with gentle styling
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          profile.name,
                          style: CalmTechTheme.headline,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: CalmTechTheme.spacingSm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: CalmTechTheme.spacingSm,
                          vertical: CalmTechTheme.spacingXs,
                        ),
                        decoration:
                            CalmTechTheme.pillDecoration(CalmTechTheme.primary),
                        child: Text(
                          '${profile.age}',
                          style: CalmTechTheme.title.copyWith(
                            color: CalmTechTheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: CalmTechTheme.spacingSm),
                      _buildDistancePill(profile.distance),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Gentle bio - no pressure
                  Text(
                    profile.bio,
                    style: CalmTechTheme.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Soft tags
                  Wrap(
                    spacing: CalmTechTheme.spacingSm,
                    runSpacing: CalmTechTheme.spacingSm,
                    children: [
                      if (profile.tags.isNotEmpty)
                        _buildTag(profile.tags[0], CalmTechTheme.primary),
                      if (profile.tags.length > 1)
                        _buildTag(profile.tags[1], CalmTechTheme.secondary),
                      if (profile.tags.length > 2)
                        _buildTag(profile.tags[2], CalmTechTheme.tertiary),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistancePill(String distance) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CalmTechTheme.spacingMd,
        vertical: CalmTechTheme.spacingSm,
      ),
      decoration: CalmTechTheme.pillDecoration(CalmTechTheme.secondary),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.near_me_rounded,
            size: 14,
            color: CalmTechTheme.secondary,
          ),
          const SizedBox(width: 4),
          Text(
            distance,
            style: CalmTechTheme.caption.copyWith(
              color: CalmTechTheme.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CalmTechTheme.spacingMd,
        vertical: CalmTechTheme.spacingSm,
      ),
      decoration: CalmTechTheme.pillDecoration(color),
      child: Text(
        text,
        style: CalmTechTheme.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavFab(
      currentService: ServiceType.dating,
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
