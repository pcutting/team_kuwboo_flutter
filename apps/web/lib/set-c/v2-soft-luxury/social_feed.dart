import 'package:flutter/material.dart';
import '../../v2-soft-luxury/theme.dart';
import '../../widgets/kuwboo_top_bar.dart';
import '../../widgets/bottom_nav_fab.dart';
import '../../data/demo_data.dart';

/// V2: Soft Luxury Social Feed (Set C - Service Switcher FAB)
/// Elegant social posts with editorial photography feel

class SocialFeed extends StatelessWidget {
  const SocialFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SoftLuxuryTheme.background,
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                KuwbooTopBar(
                  backgroundColor: SoftLuxuryTheme.background,
                  accentColor: SoftLuxuryTheme.primary,
                  textColor: SoftLuxuryTheme.text,
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      SoftLuxuryTheme.spacingMd,
                      0,
                      SoftLuxuryTheme.spacingMd,
                      80,
                    ),
                    children: [
                      // Stories row
                      _buildStoriesRow(),
                      SoftLuxuryTheme.hairlineDivider,
                      const SizedBox(height: SoftLuxuryTheme.spacingMd),
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
      height: 88,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: users.length,
        padding: const EdgeInsets.symmetric(vertical: SoftLuxuryTheme.spacingSm),
        itemBuilder: (context, index) {
          final user = users[index];
          return Container(
            width: 64,
            margin: const EdgeInsets.only(right: SoftLuxuryTheme.spacingSm),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: user.isNew
                          ? SoftLuxuryTheme.primary
                          : SoftLuxuryTheme.divider,
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      user.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.person,
                        size: 20,
                        color: SoftLuxuryTheme.textTertiary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.name,
                  style: SoftLuxuryTheme.caption.copyWith(
                    fontSize: 10,
                    color: SoftLuxuryTheme.text,
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
      margin: const EdgeInsets.only(bottom: SoftLuxuryTheme.spacingMd),
      decoration: SoftLuxuryTheme.cardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author row
          Padding(
            padding: const EdgeInsets.all(SoftLuxuryTheme.spacingSm),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(
                    post.avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => CircleAvatar(
                      backgroundColor:
                          SoftLuxuryTheme.primary.withValues(alpha: 0.2),
                      child: Text(
                        post.author[0],
                        style: SoftLuxuryTheme.caption,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: SoftLuxuryTheme.spacingSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.author,
                        style: SoftLuxuryTheme.title.copyWith(fontSize: 13),
                      ),
                      Text(
                        post.timeAgo,
                        style: SoftLuxuryTheme.caption.copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.more_horiz_rounded,
                  size: 18,
                  color: SoftLuxuryTheme.textTertiary,
                ),
              ],
            ),
          ),
          // Text content
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SoftLuxuryTheme.spacingSm,
            ),
            child: Text(
              post.text,
              style: SoftLuxuryTheme.body.copyWith(fontSize: 13),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Image if present
          if (post.imageUrl != null) ...[
            const SizedBox(height: SoftLuxuryTheme.spacingSm),
            SizedBox(
              height: 160,
              width: double.infinity,
              child: Image.network(
                post.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: SoftLuxuryTheme.divider,
                  child: Center(
                    child: Icon(
                      Icons.image_rounded,
                      size: 32,
                      color: SoftLuxuryTheme.textTertiary,
                    ),
                  ),
                ),
              ),
            ),
          ],
          // Reactions bar
          Padding(
            padding: const EdgeInsets.all(SoftLuxuryTheme.spacingSm),
            child: Row(
              children: [
                Icon(
                  Icons.favorite_border_rounded,
                  size: 18,
                  color: SoftLuxuryTheme.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${post.reactions}',
                  style: SoftLuxuryTheme.caption.copyWith(
                    color: SoftLuxuryTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: SoftLuxuryTheme.spacingMd),
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 16,
                  color: SoftLuxuryTheme.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${post.comments}',
                  style: SoftLuxuryTheme.caption.copyWith(
                    color: SoftLuxuryTheme.textSecondary,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.share_outlined,
                  size: 16,
                  color: SoftLuxuryTheme.textSecondary,
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
