import 'package:flutter/material.dart';
import '../widgets/kuwboo_top_bar.dart';
import '../data/demo_data.dart';

/// Generic social feed — parameterized by colors + nav widget.
/// Stories row + post cards with author/text/image/reactions.

class GenericSocialFeed extends StatelessWidget {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color text;
  final Widget bottomNav;

  const GenericSocialFeed({
    super.key,
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.text,
    required this.bottomNav,
  });

  Color get _textSecondary => text.withValues(alpha: 0.6);
  Color get _textTertiary => text.withValues(alpha: 0.4);
  Color get _divider => text.withValues(alpha: 0.1);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: background,
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                KuwbooTopBar(
                  backgroundColor: background,
                  accentColor: primary,
                  textColor: text,
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    children: [
                      _buildStoriesRow(),
                      Divider(height: 1, color: _divider),
                      const SizedBox(height: 16),
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
              child: bottomNav,
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
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          final user = users[index];
          return Container(
            width: 64,
            margin: const EdgeInsets.only(right: 8),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: user.isNew ? primary : _divider,
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
                        color: _textTertiary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.name,
                  style: TextStyle(
                    fontSize: 10,
                    color: text,
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
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author row
          Padding(
            padding: const EdgeInsets.all(10),
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
                      backgroundColor: primary.withValues(alpha: 0.2),
                      child: Text(
                        post.author[0],
                        style: TextStyle(color: text, fontSize: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.author,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: text,
                        ),
                      ),
                      Text(
                        post.timeAgo,
                        style: TextStyle(fontSize: 10, color: _textTertiary),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.more_horiz_rounded,
                  size: 18,
                  color: _textTertiary,
                ),
              ],
            ),
          ),
          // Text content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              post.text,
              style: TextStyle(fontSize: 13, color: text),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Image
          if (post.imageUrl != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 160,
              width: double.infinity,
              child: Image.network(
                post.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: _divider,
                  child: Center(
                    child: Icon(
                      Icons.image_rounded,
                      size: 32,
                      color: _textTertiary,
                    ),
                  ),
                ),
              ),
            ),
          ],
          // Reactions bar
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Icon(Icons.favorite_border_rounded, size: 18, color: _textSecondary),
                const SizedBox(width: 4),
                Text(
                  '${post.reactions}',
                  style: TextStyle(fontSize: 11, color: _textSecondary),
                ),
                const SizedBox(width: 16),
                Icon(Icons.chat_bubble_outline_rounded, size: 16, color: _textSecondary),
                const SizedBox(width: 4),
                Text(
                  '${post.comments}',
                  style: TextStyle(fontSize: 11, color: _textSecondary),
                ),
                const Spacer(),
                Icon(Icons.share_outlined, size: 16, color: _textSecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
