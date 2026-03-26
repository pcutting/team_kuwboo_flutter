import 'package:flutter/material.dart';
import '../../v9-hyper-local-street/theme.dart';
import '../../widgets/kuwboo_top_bar.dart';
import '../../widgets/bottom_nav_fab.dart';
import '../../data/demo_data.dart';

/// V9: Hyper-Local Street Dating Profile Card (Set B - Notched FAB Nav)
/// Street poster aesthetic, condensed type, location-forward

class DatingProfileCard extends StatelessWidget {
  const DatingProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = DemoData.mainProfile;

    return Container(
      color: HyperLocalStreetTheme.background,
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                KuwbooTopBar(
                  backgroundColor: HyperLocalStreetTheme.background,
                  accentColor: HyperLocalStreetTheme.primary,
                  textColor: HyperLocalStreetTheme.text,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(HyperLocalStreetTheme.spacingMd),
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
      decoration: HyperLocalStreetTheme.posterDecoration,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Photo area - poster style
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Photo with texture overlay
                Image.network(
                  profile.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: HyperLocalStreetTheme.concrete,
                    child: Center(
                      child: Icon(
                        Icons.person,
                        size: 80,
                        color: HyperLocalStreetTheme.textTertiary,
                      ),
                    ),
                  ),
                ),
                // Location prominently featured
                Positioned(
                  top: HyperLocalStreetTheme.spacingMd,
                  left: HyperLocalStreetTheme.spacingMd,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: HyperLocalStreetTheme.spacingMd,
                      vertical: HyperLocalStreetTheme.spacingSm,
                    ),
                    decoration: HyperLocalStreetTheme.locationTagDecoration,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: HyperLocalStreetTheme.surface,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          profile.distance.toUpperCase(),
                          style: HyperLocalStreetTheme.label.copyWith(
                            color: HyperLocalStreetTheme.surface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Verified
                if (profile.verified)
                  Positioned(
                    top: HyperLocalStreetTheme.spacingMd,
                    right: HyperLocalStreetTheme.spacingMd,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: HyperLocalStreetTheme.spacingSm,
                        vertical: HyperLocalStreetTheme.spacingXs,
                      ),
                      color: HyperLocalStreetTheme.primary,
                      child: Text(
                        '\u2713 VERIFIED',
                        style: HyperLocalStreetTheme.label.copyWith(
                          color: HyperLocalStreetTheme.surface,
                        ),
                      ),
                    ),
                  ),
                // Match badge
                Positioned(
                  bottom: HyperLocalStreetTheme.spacingMd + 20,
                  right: HyperLocalStreetTheme.spacingMd,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: HyperLocalStreetTheme.spacingSm,
                      vertical: HyperLocalStreetTheme.spacingXs,
                    ),
                    color: HyperLocalStreetTheme.secondary,
                    child: Text(
                      '${profile.compatibility}% MATCH',
                      style: HyperLocalStreetTheme.label.copyWith(
                        color: HyperLocalStreetTheme.surface,
                      ),
                    ),
                  ),
                ),
                // Photo count
                Positioned(
                  bottom: HyperLocalStreetTheme.spacingMd,
                  left: HyperLocalStreetTheme.spacingMd,
                  right: HyperLocalStreetTheme.spacingMd,
                  child: Row(
                    children: List.generate(4, (i) {
                      return Expanded(
                        child: Container(
                          height: 4,
                          margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                          color: i == 0
                              ? HyperLocalStreetTheme.primary
                              : HyperLocalStreetTheme.surface.withValues(alpha: 0.5),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          // Border
          Container(
            height: 2,
            color: HyperLocalStreetTheme.text,
          ),
          // Info section - poster typography
          Expanded(
            flex: 3,
            child: Container(
              color: HyperLocalStreetTheme.tertiary.withValues(alpha: 0.3),
              padding: const EdgeInsets.fromLTRB(HyperLocalStreetTheme.spacingMd, 10, HyperLocalStreetTheme.spacingMd, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name - huge condensed type
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          profile.name.toUpperCase(),
                          style: HyperLocalStreetTheme.display,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: HyperLocalStreetTheme.spacingSm),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '${profile.age}',
                          style: HyperLocalStreetTheme.subheadline,
                        ),
                      ),
                      const SizedBox(width: HyperLocalStreetTheme.spacingSm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: HyperLocalStreetTheme.spacingMd,
                          vertical: HyperLocalStreetTheme.spacingSm,
                        ),
                        decoration: HyperLocalStreetTheme.outlineButtonDecoration,
                        child: Text(
                          profile.distance.toUpperCase(),
                          style: HyperLocalStreetTheme.label,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Bio
                  Text(
                    profile.bio,
                    style: HyperLocalStreetTheme.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Local tags
                  Wrap(
                    spacing: HyperLocalStreetTheme.spacingSm,
                    runSpacing: HyperLocalStreetTheme.spacingSm,
                    children: [
                      if (profile.tags.isNotEmpty)
                        _buildTag(profile.tags[0].toUpperCase(), isLocation: true),
                      if (profile.tags.length > 1)
                        _buildTag(profile.tags[1].toUpperCase()),
                      if (profile.tags.length > 2)
                        _buildTag(profile.tags[2].toUpperCase()),
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

  Widget _buildTag(String text, {bool isLocation = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: HyperLocalStreetTheme.spacingMd,
        vertical: HyperLocalStreetTheme.spacingSm,
      ),
      decoration: isLocation
          ? HyperLocalStreetTheme.locationTagDecoration
          : HyperLocalStreetTheme.tagDecoration,
      child: Text(
        text,
        style: HyperLocalStreetTheme.label.copyWith(
          color: isLocation
              ? HyperLocalStreetTheme.surface
              : HyperLocalStreetTheme.text,
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavFab(
      currentService: ServiceType.dating,
      backgroundColor: HyperLocalStreetTheme.surface,
      activeColor: HyperLocalStreetTheme.primary,
      inactiveColor: HyperLocalStreetTheme.textSecondary,
      fabColor: HyperLocalStreetTheme.primary,
      fabIconColor: HyperLocalStreetTheme.surface,
      borderColor: HyperLocalStreetTheme.text.withValues(alpha: 0.2),
      labelStyle: HyperLocalStreetTheme.label.copyWith(fontSize: 8),
    );
  }
}
