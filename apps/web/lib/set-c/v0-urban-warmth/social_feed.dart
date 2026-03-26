import 'package:flutter/material.dart';
import '../../v0-urban-warmth/theme.dart';
import '../../widgets/kuwboo_top_bar.dart';
import '../../widgets/bottom_nav_fab.dart';
import '../../data/demo_data.dart';

/// V0: Urban Warmth Social Feed (Set C - Service Switcher FAB)
/// Warm cards with terracotta story borders, Bebas Neue section headers, organic posts

class SocialFeed extends StatelessWidget {
  const SocialFeed({super.key});

  @override
  Widget build(BuildContext context) {
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
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      UrbanWarmthTheme.spacingMd, 0, UrbanWarmthTheme.spacingMd, 80,
                    ),
                    children: [
                      _buildStoriesRow(),
                      const SizedBox(height: UrbanWarmthTheme.spacingSm),
                      // Section header in Bebas Neue
                      Padding(
                        padding: const EdgeInsets.only(bottom: UrbanWarmthTheme.spacingSm),
                        child: Text(
                          'YOUR FEED',
                          style: UrbanWarmthTheme.label.copyWith(
                            color: UrbanWarmthTheme.textTertiary,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
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
        padding: const EdgeInsets.symmetric(vertical: UrbanWarmthTheme.spacingSm),
        itemBuilder: (context, index) {
          final user = users[index];
          return Container(
            width: 66,
            margin: const EdgeInsets.only(right: UrbanWarmthTheme.spacingSm),
            child: Column(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: user.isNew
                          ? UrbanWarmthTheme.primary
                          : UrbanWarmthTheme.textTertiary.withValues(alpha: 0.3),
                      width: 2.5,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      user.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.person,
                        size: 20,
                        color: UrbanWarmthTheme.textTertiary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.name,
                  style: UrbanWarmthTheme.caption.copyWith(
                    fontSize: 10,
                    color: UrbanWarmthTheme.text,
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
      margin: const EdgeInsets.only(bottom: UrbanWarmthTheme.spacingMd),
      decoration: UrbanWarmthTheme.cardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author row
          Padding(
            padding: const EdgeInsets.all(UrbanWarmthTheme.spacingSm),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: UrbanWarmthTheme.primary.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(
                    post.avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => CircleAvatar(
                      backgroundColor: UrbanWarmthTheme.primary.withValues(alpha: 0.2),
                      child: Text(
                        post.author[0],
                        style: UrbanWarmthTheme.caption,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: UrbanWarmthTheme.spacingSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.author,
                        style: UrbanWarmthTheme.title.copyWith(fontSize: 13),
                      ),
                      Text(
                        post.timeAgo,
                        style: UrbanWarmthTheme.caption.copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.more_horiz_rounded,
                  size: 18,
                  color: UrbanWarmthTheme.textTertiary,
                ),
              ],
            ),
          ),
          // Text content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: UrbanWarmthTheme.spacingSm),
            child: Text(
              post.text,
              style: UrbanWarmthTheme.body.copyWith(fontSize: 13),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Image
          if (post.imageUrl != null) ...[
            const SizedBox(height: UrbanWarmthTheme.spacingSm),
            ClipRRect(
              borderRadius: BorderRadius.circular(UrbanWarmthTheme.radiusMd),
              child: SizedBox(
                height: 160,
                width: double.infinity,
                child: Image.network(
                  post.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: UrbanWarmthTheme.primary.withValues(alpha: 0.1),
                    child: Center(
                      child: Icon(
                        Icons.image_rounded,
                        size: 32,
                        color: UrbanWarmthTheme.textTertiary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
          // Reactions bar
          Padding(
            padding: const EdgeInsets.all(UrbanWarmthTheme.spacingSm),
            child: Row(
              children: [
                Icon(
                  Icons.favorite_border_rounded,
                  size: 18,
                  color: UrbanWarmthTheme.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${post.reactions}',
                  style: UrbanWarmthTheme.caption.copyWith(
                    color: UrbanWarmthTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: UrbanWarmthTheme.spacingMd),
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 16,
                  color: UrbanWarmthTheme.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${post.comments}',
                  style: UrbanWarmthTheme.caption.copyWith(
                    color: UrbanWarmthTheme.textSecondary,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.share_outlined,
                  size: 16,
                  color: UrbanWarmthTheme.textSecondary,
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
      backgroundColor: UrbanWarmthTheme.surface,
      activeColor: UrbanWarmthTheme.primary,
      inactiveColor: UrbanWarmthTheme.textSecondary,
      fabColor: UrbanWarmthTheme.secondary,
      fabIconColor: UrbanWarmthTheme.surface,
      borderColor: UrbanWarmthTheme.text.withValues(alpha: 0.1),
      height: 52,
      fabSize: 50,
      labelStyle: UrbanWarmthTheme.caption.copyWith(fontSize: 8),
    );
  }
}
