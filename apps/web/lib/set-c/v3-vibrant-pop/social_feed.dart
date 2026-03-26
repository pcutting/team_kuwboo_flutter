import 'package:flutter/material.dart';
import '../../v3-vibrant-pop/theme.dart';
import '../../widgets/kuwboo_top_bar.dart';
import '../../widgets/bottom_nav_fab.dart';
import '../../data/demo_data.dart';

/// V3: Vibrant Pop Social Feed (Set C - Service Switcher FAB)
/// Colorful stories, gradient accents, bold cards with rounded shapes

class SocialFeed extends StatelessWidget {
  const SocialFeed({super.key});

  @override
  Widget build(BuildContext context) {
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
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      VibrantPopTheme.spacingMd,
                      0,
                      VibrantPopTheme.spacingMd,
                      80,
                    ),
                    children: [
                      _buildStoriesRow(),
                      const SizedBox(height: VibrantPopTheme.spacingSm),
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
      height: 96,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: users.length + 1,
        padding: const EdgeInsets.symmetric(
            vertical: VibrantPopTheme.spacingSm),
        itemBuilder: (context, index) {
          if (index == 0) return _buildAddStory();
          final user = users[index - 1];
          return _buildStoryAvatar(user);
        },
      ),
    );
  }

  Widget _buildAddStory() {
    return Container(
      width: 68,
      margin: const EdgeInsets.only(right: VibrantPopTheme.spacingSm),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: VibrantPopTheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: VibrantPopTheme.primary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Icon(Icons.add_rounded,
                size: 24, color: VibrantPopTheme.primary),
          ),
          const SizedBox(height: 4),
          Text(
            'Add',
            style: VibrantPopTheme.caption.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: VibrantPopTheme.primary,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildStoryAvatar(NearbyUser user) {
    return Container(
      width: 68,
      margin: const EdgeInsets.only(right: VibrantPopTheme.spacingSm),
      child: Column(
        children: [
          // Story ring with gradient border
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              gradient: user.isNew
                  ? VibrantPopTheme.funGradient
                  : VibrantPopTheme.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: VibrantPopTheme.background, width: 2),
              ),
              clipBehavior: Clip.antiAlias,
              child: ClipOval(
                child: Image.network(
                  user.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.person, size: 20),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.name,
            style: VibrantPopTheme.caption.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(DemoPost post) {
    return Container(
      margin: const EdgeInsets.only(bottom: VibrantPopTheme.spacingMd),
      decoration: VibrantPopTheme.cardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author row
          Padding(
            padding: const EdgeInsets.all(VibrantPopTheme.spacingSm),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: VibrantPopTheme.softShadow,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ClipOval(
                    child: Image.network(
                      post.avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: VibrantPopTheme.primary
                            .withValues(alpha: 0.2),
                        child: Center(
                          child: Text(post.author[0],
                              style: VibrantPopTheme.title),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: VibrantPopTheme.spacingSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.author,
                        style: VibrantPopTheme.title.copyWith(
                            fontSize: 14),
                      ),
                      Text(
                        post.timeAgo,
                        style: VibrantPopTheme.caption.copyWith(
                          color: VibrantPopTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: VibrantPopTheme.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.more_horiz_rounded,
                      size: 18, color: VibrantPopTheme.textSecondary),
                ),
              ],
            ),
          ),
          // Post text
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: VibrantPopTheme.spacingMd),
            child: Text(
              post.text,
              style: VibrantPopTheme.body.copyWith(
                color: VibrantPopTheme.text,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Post image
          if (post.imageUrl != null) ...[
            const SizedBox(height: VibrantPopTheme.spacingSm),
            Container(
              height: 180,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(
                  horizontal: VibrantPopTheme.spacingSm),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(VibrantPopTheme.radiusMd),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                post.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: VibrantPopTheme.surface,
                  child: const Center(
                    child: Icon(Icons.image_rounded, size: 32),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: VibrantPopTheme.spacingSm),
          // Reactions row
          Padding(
            padding: const EdgeInsets.fromLTRB(
              VibrantPopTheme.spacingMd,
              0,
              VibrantPopTheme.spacingMd,
              VibrantPopTheme.spacingSm,
            ),
            child: Row(
              children: [
                _buildReactionButton(
                  Icons.favorite_rounded,
                  '${post.reactions}',
                  VibrantPopTheme.secondary,
                ),
                const SizedBox(width: VibrantPopTheme.spacingMd),
                _buildReactionButton(
                  Icons.chat_bubble_outline_rounded,
                  '${post.comments}',
                  VibrantPopTheme.primary,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: VibrantPopTheme.primary
                        .withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.share_rounded,
                      size: 16, color: VibrantPopTheme.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactionButton(
      IconData icon, String count, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 4),
        Text(
          count,
          style: VibrantPopTheme.caption.copyWith(
            fontWeight: FontWeight.w700,
            color: VibrantPopTheme.text,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return BottomNavFab(
      currentService: ServiceType.social,
      backgroundColor: VibrantPopTheme.background,
      activeColor: VibrantPopTheme.primary,
      inactiveColor: VibrantPopTheme.textSecondary,
      fabColor: VibrantPopTheme.primary,
      fabIconColor: Colors.white,
      height: 52,
      fabSize: 50,
      labelStyle: VibrantPopTheme.caption.copyWith(fontSize: 8),
    );
  }
}
