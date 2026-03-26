import 'package:flutter/material.dart';
import '../../v4-dark-mode-native/theme.dart';
import '../../widgets/kuwboo_top_bar.dart';
import '../../widgets/bottom_nav_fab.dart';
import '../../data/demo_data.dart';

/// V4: Dark Mode Native Social Feed (Set C - Service Switcher FAB)
/// OLED-optimized social posts with glowing story borders and elevated dark cards

class SocialFeed extends StatelessWidget {
  const SocialFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DarkModeNativeTheme.background,
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                KuwbooTopBar(
                  backgroundColor: DarkModeNativeTheme.background,
                  accentColor: DarkModeNativeTheme.primary,
                  textColor: DarkModeNativeTheme.text,
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      DarkModeNativeTheme.spacingMd,
                      0,
                      DarkModeNativeTheme.spacingMd,
                      80,
                    ),
                    children: [
                      // Stories row with glowing borders
                      _buildStoriesRow(),
                      Container(
                        height: 1,
                        color: DarkModeNativeTheme.border,
                      ),
                      const SizedBox(height: DarkModeNativeTheme.spacingMd),
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

  Widget _buildStoriesRow() {
    final users = DemoData.nearbyUsers;
    return SizedBox(
      height: 92,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: users.length,
        padding: const EdgeInsets.symmetric(
          vertical: DarkModeNativeTheme.spacingSm,
        ),
        itemBuilder: (context, index) {
          final user = users[index];
          // Cycle through accent colors for glowing borders
          final glowColors = [
            DarkModeNativeTheme.primary,
            DarkModeNativeTheme.secondary,
            DarkModeNativeTheme.tertiary,
            DarkModeNativeTheme.primary,
            DarkModeNativeTheme.secondary,
          ];
          final glowColor = user.isNew
              ? glowColors[index % glowColors.length]
              : DarkModeNativeTheme.border;

          return Container(
            width: 66,
            margin:
                const EdgeInsets.only(right: DarkModeNativeTheme.spacingSm),
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: glowColor,
                      width: 2,
                    ),
                    boxShadow: user.isNew
                        ? DarkModeNativeTheme.subtleGlow(glowColor)
                        : null,
                  ),
                  child: ClipOval(
                    child: Image.network(
                      user.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: DarkModeNativeTheme.surface,
                        child: Icon(
                          Icons.person,
                          size: 20,
                          color: DarkModeNativeTheme.textTertiary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.name,
                  style: DarkModeNativeTheme.caption.copyWith(
                    fontSize: 10,
                    color: DarkModeNativeTheme.text,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostCard(DemoPost post) {
    return Container(
      margin: const EdgeInsets.only(bottom: DarkModeNativeTheme.spacingMd),
      decoration: DarkModeNativeTheme.elevatedCardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author row
          Padding(
            padding: const EdgeInsets.all(DarkModeNativeTheme.spacingSm),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: DarkModeNativeTheme.primary
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(
                    post.avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => CircleAvatar(
                      backgroundColor: DarkModeNativeTheme.primary
                          .withValues(alpha: 0.2),
                      child: Text(
                        post.author[0],
                        style: DarkModeNativeTheme.caption.copyWith(
                          color: DarkModeNativeTheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: DarkModeNativeTheme.spacingSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.author,
                        style: DarkModeNativeTheme.title.copyWith(
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        post.timeAgo,
                        style: DarkModeNativeTheme.caption.copyWith(
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.more_horiz_rounded,
                  size: 18,
                  color: DarkModeNativeTheme.textTertiary,
                ),
              ],
            ),
          ),
          // Text content
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DarkModeNativeTheme.spacingSm,
            ),
            child: Text(
              post.text,
              style: DarkModeNativeTheme.body.copyWith(fontSize: 13),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Image if present
          if (post.imageUrl != null) ...[
            const SizedBox(height: DarkModeNativeTheme.spacingSm),
            SizedBox(
              height: 160,
              width: double.infinity,
              child: Image.network(
                post.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: DarkModeNativeTheme.surface,
                  child: Center(
                    child: Icon(
                      Icons.image_rounded,
                      size: 32,
                      color: DarkModeNativeTheme.textTertiary,
                    ),
                  ),
                ),
              ),
            ),
          ],
          // Reactions bar
          Padding(
            padding: const EdgeInsets.all(DarkModeNativeTheme.spacingSm),
            child: Row(
              children: [
                // Heart with glow on hover state
                Icon(
                  Icons.favorite_border_rounded,
                  size: 18,
                  color: DarkModeNativeTheme.tertiary.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  '${post.reactions}',
                  style: DarkModeNativeTheme.caption.copyWith(
                    color: DarkModeNativeTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: DarkModeNativeTheme.spacingMd),
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 16,
                  color: DarkModeNativeTheme.secondary.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  '${post.comments}',
                  style: DarkModeNativeTheme.caption.copyWith(
                    color: DarkModeNativeTheme.textSecondary,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.share_outlined,
                  size: 16,
                  color: DarkModeNativeTheme.primary.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavFab(
      currentService: ServiceType.social,
      backgroundColor: DarkModeNativeTheme.surfaceElevated,
      activeColor: DarkModeNativeTheme.primary,
      inactiveColor: DarkModeNativeTheme.textTertiary,
      fabColor: DarkModeNativeTheme.primary,
      fabIconColor: DarkModeNativeTheme.text,
      borderColor: DarkModeNativeTheme.border,
      height: 52,
      fabSize: 50,
      labelStyle: DarkModeNativeTheme.caption.copyWith(fontSize: 8),
    );
  }
}
