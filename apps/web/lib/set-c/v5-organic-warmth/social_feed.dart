import 'package:flutter/material.dart';
import '../../v5-organic-warmth/theme.dart';
import '../../widgets/kuwboo_top_bar.dart';
import '../../widgets/bottom_nav_fab.dart';
import '../../data/demo_data.dart';

/// V5: Organic Warmth Social Feed (Set C - Service Switcher FAB)
/// Warm, natural social posts with soft card styling

class SocialFeed extends StatelessWidget {
  const SocialFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: OrganicWarmthTheme.background,
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                KuwbooTopBar(
                  backgroundColor: OrganicWarmthTheme.background,
                  accentColor: OrganicWarmthTheme.primary,
                  textColor: OrganicWarmthTheme.text,
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      OrganicWarmthTheme.spacingMd, 0, OrganicWarmthTheme.spacingMd, 80,
                    ),
                    children: [
                      _buildStoriesRow(),
                      const SizedBox(height: OrganicWarmthTheme.spacingMd),
                      ...DemoDataExtended.posts.map(_buildPostCard),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0, right: 0, bottom: 0,
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
        padding: const EdgeInsets.symmetric(vertical: OrganicWarmthTheme.spacingSm),
        itemBuilder: (context, index) {
          final user = users[index];
          return Container(
            width: 64,
            margin: const EdgeInsets.only(right: OrganicWarmthTheme.spacingSm),
            child: Column(
              children: [
                Container(
                  width: 48, height: 48,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: user.isNew ? OrganicWarmthTheme.primary : OrganicWarmthTheme.textTertiary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.network(user.imageUrl, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(Icons.person, size: 20, color: OrganicWarmthTheme.textTertiary),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(user.name, style: OrganicWarmthTheme.caption.copyWith(fontSize: 10, color: OrganicWarmthTheme.text), overflow: TextOverflow.ellipsis, maxLines: 1),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostCard(DemoPost post) {
    return Container(
      margin: const EdgeInsets.only(bottom: OrganicWarmthTheme.spacingMd),
      decoration: OrganicWarmthTheme.cardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(OrganicWarmthTheme.spacingSm),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(post.avatarUrl, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => CircleAvatar(
                      backgroundColor: OrganicWarmthTheme.primary.withValues(alpha: 0.2),
                      child: Text(post.author[0], style: OrganicWarmthTheme.caption),
                    ),
                  ),
                ),
                const SizedBox(width: OrganicWarmthTheme.spacingSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.author, style: OrganicWarmthTheme.title.copyWith(fontSize: 13)),
                      Text(post.timeAgo, style: OrganicWarmthTheme.caption.copyWith(fontSize: 10)),
                    ],
                  ),
                ),
                Icon(Icons.more_horiz_rounded, size: 18, color: OrganicWarmthTheme.textTertiary),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: OrganicWarmthTheme.spacingSm),
            child: Text(post.text, style: OrganicWarmthTheme.body.copyWith(fontSize: 13), maxLines: 3, overflow: TextOverflow.ellipsis),
          ),
          if (post.imageUrl != null) ...[
            const SizedBox(height: OrganicWarmthTheme.spacingSm),
            SizedBox(
              height: 160,
              width: double.infinity,
              child: Image.network(post.imageUrl!, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: OrganicWarmthTheme.tertiary.withValues(alpha: 0.2),
                  child: Center(child: Icon(Icons.image_rounded, size: 32, color: OrganicWarmthTheme.textTertiary)),
                ),
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.all(OrganicWarmthTheme.spacingSm),
            child: Row(
              children: [
                Icon(Icons.favorite_border_rounded, size: 18, color: OrganicWarmthTheme.textSecondary),
                const SizedBox(width: 4),
                Text('${post.reactions}', style: OrganicWarmthTheme.caption.copyWith(color: OrganicWarmthTheme.textSecondary)),
                const SizedBox(width: OrganicWarmthTheme.spacingMd),
                Icon(Icons.chat_bubble_outline_rounded, size: 16, color: OrganicWarmthTheme.textSecondary),
                const SizedBox(width: 4),
                Text('${post.comments}', style: OrganicWarmthTheme.caption.copyWith(color: OrganicWarmthTheme.textSecondary)),
                const Spacer(),
                Icon(Icons.share_outlined, size: 16, color: OrganicWarmthTheme.textSecondary),
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
      backgroundColor: OrganicWarmthTheme.surface,
      activeColor: OrganicWarmthTheme.primary,
      inactiveColor: OrganicWarmthTheme.textSecondary,
      fabColor: OrganicWarmthTheme.primary,
      fabIconColor: OrganicWarmthTheme.surface,
      borderColor: OrganicWarmthTheme.text.withValues(alpha: 0.1),
      height: 52,
      fabSize: 50,
      labelStyle: OrganicWarmthTheme.caption.copyWith(fontSize: 8),
    );
  }
}
