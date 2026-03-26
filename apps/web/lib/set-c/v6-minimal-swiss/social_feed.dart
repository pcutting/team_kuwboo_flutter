import 'package:flutter/material.dart';
import '../../v6-minimal-swiss/theme.dart';
import '../../widgets/kuwboo_top_bar.dart';
import '../../widgets/bottom_nav_fab.dart';
import '../../data/demo_data.dart';

/// V6: Minimal Swiss Social Feed (Set C - Service Switcher FAB)
/// Clean cards separated by horizontal dividers, no rounded corners

class SocialFeed extends StatelessWidget {
  const SocialFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MinimalSwissTheme.background,
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                KuwbooTopBar(
                  backgroundColor: MinimalSwissTheme.background,
                  accentColor: MinimalSwissTheme.primary,
                  textColor: MinimalSwissTheme.text,
                  padding: const EdgeInsets.symmetric(
                    horizontal: MinimalSwissTheme.spacingMd,
                    vertical: MinimalSwissTheme.spacingSm,
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 80),
                    children: [
                      _buildStoriesRow(),
                      MinimalSwissTheme.horizontalDivider,
                      ...DemoDataExtended.posts.expand((post) => [
                        _buildPostCard(post),
                        MinimalSwissTheme.horizontalDivider,
                      ]),
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
        padding: const EdgeInsets.symmetric(
          horizontal: MinimalSwissTheme.spacingMd,
          vertical: MinimalSwissTheme.spacingSm,
        ),
        itemBuilder: (context, index) {
          final user = users[index];
          return Container(
            width: 64,
            margin: const EdgeInsets.only(
                right: MinimalSwissTheme.spacingSm),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: user.isNew
                          ? MinimalSwissTheme.primary
                          : MinimalSwissTheme.divider,
                      width: 1,
                    ),
                  ),
                  child: Image.network(
                    user.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.person, size: 20,
                            color: MinimalSwissTheme.textTertiary),
                  ),
                ),
                const SizedBox(height: MinimalSwissTheme.spacingXs),
                Text(user.name,
                    style: MinimalSwissTheme.caption
                        .copyWith(color: MinimalSwissTheme.text),
                    overflow: TextOverflow.ellipsis, maxLines: 1),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostCard(DemoPost post) {
    return Container(
      color: MinimalSwissTheme.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author row
          Padding(
            padding: const EdgeInsets.all(MinimalSwissTheme.spacingMd),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: MinimalSwissTheme.borderedDecoration,
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(
                    post.avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(post.author[0],
                          style: MinimalSwissTheme.caption),
                    ),
                  ),
                ),
                const SizedBox(width: MinimalSwissTheme.spacingSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.author, style: MinimalSwissTheme.title),
                      Text(post.timeAgo,
                          style: MinimalSwissTheme.caption),
                    ],
                  ),
                ),
                Icon(Icons.more_horiz_rounded,
                    size: 18, color: MinimalSwissTheme.textTertiary),
              ],
            ),
          ),
          // Post text
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: MinimalSwissTheme.spacingMd),
            child: Text(post.text,
                style: MinimalSwissTheme.body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis),
          ),
          // Post image
          if (post.imageUrl != null) ...[
            const SizedBox(height: MinimalSwissTheme.spacingSm),
            SizedBox(
              height: 180,
              width: double.infinity,
              child: Image.network(
                post.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: MinimalSwissTheme.surface,
                  child: const Center(child: Icon(
                      Icons.image_rounded, size: 32,
                      color: MinimalSwissTheme.textTertiary)),
                ),
              ),
            ),
          ],
          // Action row
          Padding(
            padding: const EdgeInsets.all(MinimalSwissTheme.spacingMd),
            child: Row(
              children: [
                const Icon(Icons.favorite_outline_rounded,
                    size: 18, color: MinimalSwissTheme.textSecondary),
                const SizedBox(width: 4),
                Text('${post.reactions}',
                    style: MinimalSwissTheme.caption
                        .copyWith(color: MinimalSwissTheme.textSecondary)),
                const SizedBox(width: MinimalSwissTheme.spacingMd),
                const Icon(Icons.chat_bubble_outline_rounded,
                    size: 16, color: MinimalSwissTheme.textSecondary),
                const SizedBox(width: 4),
                Text('${post.comments}',
                    style: MinimalSwissTheme.caption
                        .copyWith(color: MinimalSwissTheme.textSecondary)),
                const Spacer(),
                const Icon(Icons.share_outlined,
                    size: 16, color: MinimalSwissTheme.textSecondary),
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
      backgroundColor: MinimalSwissTheme.background,
      activeColor: MinimalSwissTheme.primary,
      inactiveColor: MinimalSwissTheme.textTertiary,
      fabColor: MinimalSwissTheme.primary,
      fabIconColor: MinimalSwissTheme.background,
      borderColor: MinimalSwissTheme.divider,
      height: 52,
      fabSize: 50,
      labelStyle: MinimalSwissTheme.label.copyWith(fontSize: 8),
    );
  }
}
