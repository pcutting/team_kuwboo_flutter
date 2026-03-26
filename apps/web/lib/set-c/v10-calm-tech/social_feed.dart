import 'package:flutter/material.dart';
import '../../v10-calm-tech/theme.dart';
import '../../widgets/kuwboo_top_bar.dart';
import '../../widgets/bottom_nav_fab.dart';
import '../../data/demo_data.dart';

/// V10: Calm Tech Social Feed (Set C - Service Switcher FAB)
/// Gentle social browsing — no pressure, mindful design

class SocialFeed extends StatelessWidget {
  const SocialFeed({super.key});

  @override
  Widget build(BuildContext context) {
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
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      CalmTechTheme.spacingLg,
                      0,
                      CalmTechTheme.spacingLg,
                      80,
                    ),
                    children: [
                      // Gentle greeting
                      Text(
                        'What\'s happening nearby',
                        style: CalmTechTheme.subheadline,
                      ),
                      const SizedBox(height: CalmTechTheme.spacingSm),
                      Text(
                        'Take your time browsing',
                        style: CalmTechTheme.body,
                      ),
                      const SizedBox(height: CalmTechTheme.spacingLg),
                      // Posts
                      ...DemoDataExtended.posts.map(_buildPostCard),
                    ],
                  ),
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

  Widget _buildPostCard(DemoPost post) {
    return Container(
      margin: const EdgeInsets.only(bottom: CalmTechTheme.spacingMd),
      decoration: CalmTechTheme.softCardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(CalmTechTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author row
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: CalmTechTheme.primary.withValues(alpha: 0.15),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ClipOval(
                    child: Image.network(
                      post.avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text(
                          post.author[0],
                          style: CalmTechTheme.title.copyWith(
                            color: CalmTechTheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: CalmTechTheme.spacingSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.author,
                        style: CalmTechTheme.title.copyWith(fontSize: 14),
                      ),
                      Text(
                        post.timeAgo,
                        style: CalmTechTheme.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: CalmTechTheme.spacingSm),
            // Post text
            Text(
              post.text,
              style: CalmTechTheme.body.copyWith(fontSize: 14),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            // Image if present
            if (post.imageUrl != null) ...[
              const SizedBox(height: CalmTechTheme.spacingSm),
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(CalmTechTheme.radiusMd),
                child: SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: Image.network(
                    post.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: CalmTechTheme.primary.withValues(alpha: 0.1),
                      child: Center(
                        child: Icon(
                          Icons.image_rounded,
                          size: 32,
                          color: CalmTechTheme.textTertiary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: CalmTechTheme.spacingSm),
            // Gentle reactions (no counts to reduce anxiety)
            Row(
              children: [
                _ReactionPill(
                  icon: Icons.favorite_border_rounded,
                  label: '${post.reactions}',
                  color: CalmTechTheme.tertiary,
                ),
                const SizedBox(width: CalmTechTheme.spacingSm),
                _ReactionPill(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: '${post.comments}',
                  color: CalmTechTheme.primary,
                ),
                const Spacer(),
                Icon(
                  Icons.share_outlined,
                  size: 16,
                  color: CalmTechTheme.textTertiary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavFab(
      currentService: ServiceType.social,
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

class _ReactionPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ReactionPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CalmTechTheme.spacingSm,
        vertical: CalmTechTheme.spacingXs,
      ),
      decoration: CalmTechTheme.pillDecoration(color),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: CalmTechTheme.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
