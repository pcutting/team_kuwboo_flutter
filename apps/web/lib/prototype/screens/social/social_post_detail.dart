import 'package:flutter/material.dart';
import '../../proto_theme.dart';
import '../../shared/proto_image.dart';
import '../../shared/proto_media.dart';
import '../../../data/demo_data.dart';
import '../../prototype_state.dart';
import '../../shared/proto_scaffold.dart';
import '../../shared/proto_press_button.dart';
import '../../shared/proto_dialogs.dart';

class SocialPostDetail extends StatefulWidget {
  final DemoPost post;
  const SocialPostDetail({super.key, required this.post});

  @override
  State<SocialPostDetail> createState() => _SocialPostDetailState();
}

class _SocialPostDetailState extends State<SocialPostDetail> {
  bool _isLiked = false;
  int _currentImage = 0;

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    final post = widget.post;
    final likeCount = post.reactions + (_isLiked ? 1 : 0);

    return Container(
      color: theme.background,
      child: Column(
        children: [
          ProtoSubBar(
            title: 'Post',
            actions: [
              ProtoPressButton(
                onTap: () => ProtoShareSheet.show(context),
                child: Icon(theme.icons.share, size: 20, color: theme.text),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Author row
                      Row(
                        children: [
                          ProtoAvatar(radius: 22, imageUrl: post.avatarUrl),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(post.author, style: theme.title.copyWith(fontSize: 15)),
                                Text(post.timeAgo, style: theme.caption),
                              ],
                            ),
                          ),
                          ProtoPressButton(
                            onTap: () => ProtoPostMenu.show(context, authorName: post.author),
                            child: Icon(theme.icons.moreHoriz, size: 20, color: theme.textTertiary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Post text
                      Text(post.text, style: theme.body.copyWith(fontSize: 15)),

                      // Media
                      if (post.media.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        if (post.media.length > 1)
                          ProtoMediaCarousel(
                            items: post.media,
                            theme: theme,
                            currentIndex: _currentImage,
                            onPageChanged: (i) => setState(() => _currentImage = i),
                          )
                        else
                          ProtoSingleMedia(item: post.media.first, theme: theme),
                      ],

                      const SizedBox(height: 14),

                      // Action row
                      Row(
                        children: [
                          ProtoPressButton(
                            onTap: () => setState(() => _isLiked = !_isLiked),
                            child: Row(
                              children: [
                                Icon(
                                  _isLiked ? theme.icons.favoriteFilled : theme.icons.favoriteOutline,
                                  size: 22,
                                  color: _isLiked ? theme.accent : theme.textTertiary,
                                ),
                                const SizedBox(width: 6),
                                Text('$likeCount', style: theme.caption.copyWith(
                                  color: _isLiked ? theme.accent : theme.textTertiary,
                                )),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          ProtoPressButton(
                            onTap: () => ProtoToast.show(context, theme.icons.chatBubbleOutline, 'Comments'),
                            child: Row(
                              children: [
                                Icon(theme.icons.chatBubbleOutline, size: 20, color: theme.textTertiary),
                                const SizedBox(width: 6),
                                Text('${post.comments}', style: theme.caption),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          ProtoPressButton(
                            onTap: () => ProtoToast.show(context, Icons.repeat_rounded, 'Reposted'),
                            child: Icon(Icons.repeat_rounded, size: 20, color: theme.textTertiary),
                          ),
                          const Spacer(),
                          ProtoPressButton(
                            onTap: () => ProtoShareSheet.show(context),
                            child: Icon(theme.icons.share, size: 20, color: theme.textTertiary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Divider
                Divider(height: 1, color: theme.text.withValues(alpha: 0.08)),

                // Comments section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${post.comments} Comments', style: theme.title.copyWith(fontSize: 15)),
                      const SizedBox(height: 16),
                      ..._demoComments.map((c) => _CommentTile(comment: c, theme: theme)),
                    ],
                  ),
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Demo comments ───────────────────────────────────────────────────────

class _DemoComment {
  final String author;
  final String avatarUrl;
  final String text;
  final String timeAgo;
  final int likes;

  const _DemoComment({
    required this.author,
    required this.avatarUrl,
    required this.text,
    required this.timeAgo,
    this.likes = 0,
  });
}

const _demoComments = [
  _DemoComment(
    author: 'Jordan Lee',
    avatarUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=100&h=100&fit=crop',
    text: 'This is amazing! Love this so much.',
    timeAgo: '1h ago',
    likes: 5,
  ),
  _DemoComment(
    author: 'Priya Sharma',
    avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop',
    text: 'Where was this taken? Need to check it out!',
    timeAgo: '45m ago',
    likes: 2,
  ),
  _DemoComment(
    author: 'Kai Nakamura',
    avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&h=100&fit=crop',
    text: 'Definitely need to try this myself.',
    timeAgo: '30m ago',
    likes: 1,
  ),
  _DemoComment(
    author: 'Luna Park',
    avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&h=100&fit=crop',
    text: 'Saved for later!',
    timeAgo: '15m ago',
    likes: 0,
  ),
];

// ─── Comment tile ────────────────────────────────────────────────────────

class _CommentTile extends StatelessWidget {
  final _DemoComment comment;
  final ProtoTheme theme;

  const _CommentTile({required this.comment, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProtoAvatar(radius: 16, imageUrl: comment.avatarUrl),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(comment.author, style: theme.title.copyWith(fontSize: 13)),
                    const SizedBox(width: 8),
                    Text(comment.timeAgo, style: theme.caption.copyWith(fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.text, style: theme.body.copyWith(fontSize: 13)),
                if (comment.likes > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(theme.icons.favoriteOutline, size: 12, color: theme.textTertiary),
                      const SizedBox(width: 4),
                      Text('${comment.likes}', style: theme.caption.copyWith(fontSize: 11)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
