import 'package:flutter/material.dart';
import '../../v6-minimal-swiss/theme.dart';
import '../../widgets/kuwboo_top_bar.dart';
import '../../widgets/bottom_nav_fab.dart';
import '../../data/demo_data.dart';

/// V6: Minimal Swiss Dating Profile Card (Set B - Notched FAB Nav)
/// Grid-based, typography-focused, extreme whitespace

class DatingProfileCard extends StatelessWidget {
  const DatingProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = DemoData.mainProfile;

    return Container(
      color: MinimalSwissTheme.background,
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                KuwbooTopBar(
                  backgroundColor: MinimalSwissTheme.background,
                  accentColor: MinimalSwissTheme.primary,
                  textColor: MinimalSwissTheme.text,
                ),
                MinimalSwissTheme.horizontalDivider,
                Expanded(child: _buildContent(profile)),
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

  Widget _buildContent(DemoProfile profile) {
    return Column(
      children: [
        // Photo area - dominates
        Expanded(
          flex: 5,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                profile.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: MinimalSwissTheme.surface,
                  child: Center(
                    child: Icon(
                      Icons.person_outline,
                      size: 80,
                      color: MinimalSwissTheme.divider,
                    ),
                  ),
                ),
              ),
              // Photo count - minimal
              Positioned(
                top: MinimalSwissTheme.spacingMd,
                left: MinimalSwissTheme.spacingMd,
                child: Text(
                  '1/4',
                  style: MinimalSwissTheme.caption.copyWith(
                    color: MinimalSwissTheme.text,
                  ),
                ),
              ),
              // Verification - just text
              if (profile.verified)
                Positioned(
                  top: MinimalSwissTheme.spacingMd,
                  right: MinimalSwissTheme.spacingMd,
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: MinimalSwissTheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'VERIFIED',
                        style: MinimalSwissTheme.label.copyWith(
                          color: MinimalSwissTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        MinimalSwissTheme.horizontalDivider,
        // Info section - text-focused
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(MinimalSwissTheme.spacingMd, 10, MinimalSwissTheme.spacingMd, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name - large and dominant
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Text(
                        profile.name,
                        style: MinimalSwissTheme.headline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text('${profile.age}', style: MinimalSwissTheme.subheadline),
                  ],
                ),
                const SizedBox(height: 4),
                // Location - simple
                Row(
                  children: [
                    Text(
                      profile.distance,
                      style: MinimalSwissTheme.body,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                MinimalSwissTheme.horizontalDivider,
                const SizedBox(height: 4),
                // Bio - clean typography
                Expanded(
                  child: Text(
                    profile.bio,
                    style: MinimalSwissTheme.body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return BottomNavFab(
      currentService: ServiceType.dating,
      backgroundColor: MinimalSwissTheme.background,
      activeColor: MinimalSwissTheme.primary,
      inactiveColor: MinimalSwissTheme.textSecondary,
      fabColor: MinimalSwissTheme.primary,
      fabIconColor: MinimalSwissTheme.background,
      borderColor: MinimalSwissTheme.divider,
      labelStyle: MinimalSwissTheme.caption.copyWith(fontSize: 8),
    );
  }
}
