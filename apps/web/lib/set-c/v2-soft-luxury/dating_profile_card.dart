import 'package:flutter/material.dart';
import '../../v2-soft-luxury/theme.dart';
import '../../widgets/kuwboo_top_bar.dart';
import '../../widgets/bottom_nav_fab.dart';
import '../../data/demo_data.dart';

/// V2: Soft Luxury Dating Profile Card (Set C - Service Switcher FAB)
/// Elegant, spacious, editorial photography feel

class DatingProfileCard extends StatelessWidget {
  const DatingProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = DemoData.mainProfile;

    return Container(
      color: SoftLuxuryTheme.background,
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Minimal header
                KuwbooTopBar(
                  backgroundColor: SoftLuxuryTheme.background,
                  accentColor: SoftLuxuryTheme.primary,
                  textColor: SoftLuxuryTheme.text,
                ),
                // Main card
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      SoftLuxuryTheme.spacingMd,
                      0,
                      SoftLuxuryTheme.spacingMd,
                      SoftLuxuryTheme.spacingSm,
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
      decoration: SoftLuxuryTheme.cardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Photo area
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Photo with warm overlay
                Image.network(
                  profile.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: SoftLuxuryTheme.divider,
                  ),
                ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        SoftLuxuryTheme.text.withValues(alpha: 0.5),
                      ],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
                // Photo indicators
                Positioned(
                  top: SoftLuxuryTheme.spacingSm,
                  left: SoftLuxuryTheme.spacingSm,
                  right: SoftLuxuryTheme.spacingSm,
                  child: Row(
                    children: List.generate(4, (i) {
                      return Expanded(
                        child: Container(
                          height: 2,
                          margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                          decoration: BoxDecoration(
                            color: i == 0
                                ? SoftLuxuryTheme.surface
                                : SoftLuxuryTheme.surface.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                // Verification badge
                if (profile.verified)
                  Positioned(
                    top: SoftLuxuryTheme.spacingMd,
                    right: SoftLuxuryTheme.spacingSm,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: SoftLuxuryTheme.surface,
                        borderRadius: BorderRadius.circular(SoftLuxuryTheme.radiusSm),
                        boxShadow: SoftLuxuryTheme.subtleShadow,
                      ),
                      child: Icon(
                        Icons.verified_rounded,
                        size: 14,
                        color: SoftLuxuryTheme.primary,
                      ),
                    ),
                  ),
                // Name overlay
                Positioned(
                  bottom: SoftLuxuryTheme.spacingMd,
                  left: SoftLuxuryTheme.spacingMd,
                  right: SoftLuxuryTheme.spacingMd,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            profile.name,
                            style: SoftLuxuryTheme.headline.copyWith(
                              color: SoftLuxuryTheme.surface,
                              fontSize: 26,
                            ),
                          ),
                          const SizedBox(width: SoftLuxuryTheme.spacingSm),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Text(
                              '${profile.age}',
                              style: SoftLuxuryTheme.subheadline.copyWith(
                                color: SoftLuxuryTheme.surface.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: SoftLuxuryTheme.surface.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            profile.distance,
                            style: SoftLuxuryTheme.bodySmall.copyWith(
                              color: SoftLuxuryTheme.surface.withValues(alpha: 0.8),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Info section
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(SoftLuxuryTheme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bio with elegant typography
                  Text(
                    '"${profile.bio}"',
                    style: SoftLuxuryTheme.body.copyWith(
                      fontFamily: SoftLuxuryTheme.serifFont,
                      fontStyle: FontStyle.italic,
                      fontSize: 13,
                      color: SoftLuxuryTheme.text,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: SoftLuxuryTheme.spacingSm),
                  SoftLuxuryTheme.hairlineDivider,
                  const SizedBox(height: SoftLuxuryTheme.spacingSm),
                  // Elegant tags
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: profile.tags.take(3).map((tag) {
                      return _buildTag(tag, isAccent: tag == profile.tags.first);
                    }).toList(),
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

  Widget _buildTag(String text, {bool isAccent = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SoftLuxuryTheme.spacingSm,
        vertical: 4,
      ),
      decoration: isAccent
          ? SoftLuxuryTheme.accentTagDecoration
          : SoftLuxuryTheme.tagDecoration,
      child: Text(
        text,
        style: SoftLuxuryTheme.caption.copyWith(
          fontSize: 10,
          color: isAccent
              ? SoftLuxuryTheme.primary
              : SoftLuxuryTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavFab(
      currentService: ServiceType.dating,
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
