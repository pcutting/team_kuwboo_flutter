import 'package:flutter/material.dart';
import '../../v3-vibrant-pop/theme.dart';
import '../../widgets/kuwboo_top_bar.dart';
import '../../widgets/bottom_nav_fab.dart';
import '../../data/demo_data.dart';

/// V3: Vibrant Pop Dating Profile Card (Set B - Notched FAB Nav)
/// MATURE VARIANT: No emojis, deeper tones, same energetic layout

class DatingProfileCard extends StatelessWidget {
  const DatingProfileCard({super.key});

  // Mature color overrides — richer, deeper variants of the originals
  static const Color _matureAccent = Color(0xFF0052CC); // Deeper blue
  static const Color _maturePink = Color(0xFFCC0066); // Deeper pink
  static const Color _matureGreen = Color(0xFF00B366); // Richer green

  @override
  Widget build(BuildContext context) {
    final profile = DemoData.mainProfile;

    return Container(
      color: VibrantPopTheme.background,
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                KuwbooTopBar(
                  backgroundColor: VibrantPopTheme.background,
                  accentColor: VibrantPopTheme.primary,
                  textColor: VibrantPopTheme.text,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      VibrantPopTheme.spacingMd,
                      0,
                      VibrantPopTheme.spacingMd,
                      VibrantPopTheme.spacingSm,
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
      decoration: VibrantPopTheme.cardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Photo
          Positioned.fill(
            child: Image.network(
              profile.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: VibrantPopTheme.surface,
                child: Center(
                  child: Icon(
                    Icons.person_rounded,
                    size: 64,
                    color: VibrantPopTheme.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          // Gradient overlay — solid warm tone instead of pure black fade
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF1A1A2E).withValues(alpha: 0.75),
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
          ),
          // Photo indicators
          Positioned(
            top: VibrantPopTheme.spacingMd,
            left: VibrantPopTheme.spacingMd,
            right: VibrantPopTheme.spacingMd,
            child: Row(
              children: List.generate(5, (i) {
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: i < 4 ? 4 : 0),
                    decoration: BoxDecoration(
                      color: i == 0
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          // Verified + featured badges — icons instead of emojis
          Positioned(
            top: VibrantPopTheme.spacingMd + 16,
            right: VibrantPopTheme.spacingMd,
            child: Column(
              children: [
                if (profile.verified)
                  _buildIconBadge(Icons.verified_rounded, _matureGreen),
                const SizedBox(height: VibrantPopTheme.spacingSm),
                _buildIconBadge(Icons.star_rounded, const Color(0xFFCC8800)),
              ],
            ),
          ),
          // Match badge — solid color instead of gradient
          Positioned(
            top: VibrantPopTheme.spacingMd + 16,
            left: VibrantPopTheme.spacingMd,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: VibrantPopTheme.spacingMd,
                vertical: VibrantPopTheme.spacingSm,
              ),
              decoration: BoxDecoration(
                color: _maturePink,
                borderRadius: BorderRadius.circular(VibrantPopTheme.radiusFull),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite_rounded, size: 14, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    '${profile.compatibility}% match',
                    style: VibrantPopTheme.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Info section — same energetic layout
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(VibrantPopTheme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        profile.name,
                        style: VibrantPopTheme.headline.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: VibrantPopTheme.spacingSm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: VibrantPopTheme.spacingSm,
                          vertical: VibrantPopTheme.spacingXs,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(
                            VibrantPopTheme.radiusSm,
                          ),
                        ),
                        child: Text(
                          '${profile.age}',
                          style: VibrantPopTheme.title.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: VibrantPopTheme.spacingSm),
                  // Distance — icon instead of emoji
                  Row(
                    children: [
                      Icon(
                        Icons.near_me_rounded,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        profile.distance,
                        style: VibrantPopTheme.body.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: VibrantPopTheme.spacingSm),
                  Text(
                    profile.bio,
                    style: VibrantPopTheme.body.copyWith(color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: VibrantPopTheme.spacingSm),
                  // Interest chips — text only, no emojis, deeper colors
                  Wrap(
                    spacing: VibrantPopTheme.spacingSm,
                    runSpacing: VibrantPopTheme.spacingSm,
                    children: [
                      if (profile.tags.isNotEmpty)
                        _buildChip(profile.tags[0], _matureAccent),
                      if (profile.tags.length > 1)
                        _buildChip(profile.tags[1], _maturePink),
                      if (profile.tags.length > 2)
                        _buildChip(profile.tags[2], _matureGreen),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconBadge(IconData icon, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(VibrantPopTheme.radiusMd),
        boxShadow: VibrantPopTheme.colorShadow(color),
      ),
      child: Center(
        child: Icon(icon, size: 20, color: Colors.white),
      ),
    );
  }

  Widget _buildChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: VibrantPopTheme.spacingMd,
        vertical: VibrantPopTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(VibrantPopTheme.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        text,
        style: VibrantPopTheme.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavFab(
      currentService: ServiceType.dating,
      backgroundColor: VibrantPopTheme.surface,
      activeColor: VibrantPopTheme.primary,
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
