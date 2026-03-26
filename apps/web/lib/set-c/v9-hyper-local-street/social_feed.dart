import 'package:flutter/material.dart';
import '../../v9-hyper-local-street/theme.dart';
import '../../widgets/kuwboo_top_bar.dart';
import '../../widgets/bottom_nav_fab.dart';
import '../../data/demo_data.dart';

/// V9: Hyper-Local Street Social Feed (Set C - Service Switcher FAB)
/// Posts as neighborhood bulletins, poster borders, condensed type, wheat-paste tags

class SocialFeed extends StatelessWidget {
  const SocialFeed({super.key});

  @override
  Widget build(BuildContext context) {
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
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      HyperLocalStreetTheme.spacingMd,
                      0,
                      HyperLocalStreetTheme.spacingMd,
                      80,
                    ),
                    children: [
                      _buildStoriesRow(),
                      Container(
                          height: 2,
                          color: HyperLocalStreetTheme.text),
                      const SizedBox(
                          height: HyperLocalStreetTheme.spacingMd),
                      // Section header
                      Text(
                        'NEIGHBORHOOD BULLETIN',
                        style: HyperLocalStreetTheme.subheadline.copyWith(
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(
                          height: HyperLocalStreetTheme.spacingSm),
                      ...DemoDataExtended.posts.map(_buildPostCard),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
                left: 0, right: 0, bottom: 0, child: _buildBottomNav()),
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
            vertical: HyperLocalStreetTheme.spacingSm),
        itemBuilder: (context, index) {
          final user = users[index];
          return Container(
            width: 68,
            margin: const EdgeInsets.only(
                right: HyperLocalStreetTheme.spacingSm),
            child: Column(
              children: [
                // Stories with concrete-colored borders (new = primary)
                Container(
                  width: 50,
                  height: 50,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: user.isNew
                          ? HyperLocalStreetTheme.primary
                          : HyperLocalStreetTheme.concrete,
                      width: 2,
                    ),
                  ),
                  child: Image.network(
                    user.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.person, size: 20),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.name.toUpperCase(),
                  style: HyperLocalStreetTheme.label
                      .copyWith(fontSize: 9),
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
      margin:
          const EdgeInsets.only(bottom: HyperLocalStreetTheme.spacingMd),
      decoration: HyperLocalStreetTheme.posterDecoration,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author header
          Padding(
            padding:
                const EdgeInsets.all(HyperLocalStreetTheme.spacingSm),
            child: Row(
              children: [
                // Avatar with poster border
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: HyperLocalStreetTheme.text, width: 2),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(
                    post.avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(post.author[0],
                          style: HyperLocalStreetTheme.label),
                    ),
                  ),
                ),
                const SizedBox(width: HyperLocalStreetTheme.spacingSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Author in Bebas condensed
                      Text(
                        post.author.toUpperCase(),
                        style: HyperLocalStreetTheme.subheadline
                            .copyWith(fontSize: 16),
                      ),
                      Text(
                        post.timeAgo.toUpperCase(),
                        style: HyperLocalStreetTheme.caption
                            .copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.more_horiz_rounded,
                    size: 18,
                    color: HyperLocalStreetTheme.textSecondary),
              ],
            ),
          ),
          // Post text
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: HyperLocalStreetTheme.spacingSm),
            child: Text(
              post.text,
              style: HyperLocalStreetTheme.body.copyWith(fontSize: 13),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Tags as tagDecoration chips
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: HyperLocalStreetTheme.spacingSm,
              vertical: HyperLocalStreetTheme.spacingXs,
            ),
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: _extractTags(post.text)
                  .map((tag) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: HyperLocalStreetTheme.tagDecoration,
                        child: Text(
                          tag.toUpperCase(),
                          style: HyperLocalStreetTheme.label
                              .copyWith(fontSize: 9),
                        ),
                      ))
                  .toList(),
            ),
          ),
          // Image if present
          if (post.imageUrl != null) ...[
            Container(height: 2, color: HyperLocalStreetTheme.text),
            SizedBox(
              height: 160,
              width: double.infinity,
              child: Image.network(
                post.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: HyperLocalStreetTheme.surface,
                  child: const Center(
                      child: Icon(Icons.image_rounded, size: 32)),
                ),
              ),
            ),
          ],
          // Divider
          Container(height: 2, color: HyperLocalStreetTheme.text),
          // Reactions row
          Padding(
            padding:
                const EdgeInsets.all(HyperLocalStreetTheme.spacingSm),
            child: Row(
              children: [
                Icon(Icons.favorite_border_rounded,
                    size: 18, color: HyperLocalStreetTheme.text),
                const SizedBox(width: 4),
                Text(
                  '${post.reactions}',
                  style: HyperLocalStreetTheme.label
                      .copyWith(fontSize: 11),
                ),
                const SizedBox(
                    width: HyperLocalStreetTheme.spacingMd),
                Icon(Icons.chat_bubble_outline_rounded,
                    size: 16, color: HyperLocalStreetTheme.text),
                const SizedBox(width: 4),
                Text(
                  '${post.comments}',
                  style: HyperLocalStreetTheme.label
                      .copyWith(fontSize: 11),
                ),
                const Spacer(),
                Icon(Icons.share_outlined,
                    size: 16, color: HyperLocalStreetTheme.text),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Extract pseudo-tags from post text for visual interest
  List<String> _extractTags(String text) {
    final words = text.split(' ');
    if (words.length < 3) return ['LOCAL'];
    return [
      words.length > 5 ? words[4] : 'LOCAL',
      'NEARBY',
    ];
  }

  Widget _buildBottomNav() {
    return BottomNavFab(
      currentService: ServiceType.social,
      backgroundColor: HyperLocalStreetTheme.surface,
      activeColor: HyperLocalStreetTheme.primary,
      inactiveColor: HyperLocalStreetTheme.textSecondary,
      fabColor: HyperLocalStreetTheme.secondary,
      fabIconColor: HyperLocalStreetTheme.surface,
      borderColor: HyperLocalStreetTheme.text,
      height: 52,
      fabSize: 50,
      labelStyle: HyperLocalStreetTheme.label.copyWith(fontSize: 8),
    );
  }
}
