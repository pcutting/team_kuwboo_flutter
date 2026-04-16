import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_models/kuwboo_models.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import '../screens_test_ids.dart';
import '../sponsored/sponsored_inline.dart';
import 'social_providers.dart';

class SocialFeedScreen extends ConsumerWidget {
  const SocialFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);
    final feed = ref.watch(socialFeedProvider);

    return Column(
      children: [
        const _SocialTopBar(),
        Expanded(
          child: feed.when(
            loading: () => const ProtoLoadingState(itemCount: 6),
            error: (err, _) => ProtoErrorState(
              message: 'Could not load feed',
              onRetry: () => ref.invalidate(socialFeedProvider),
            ),
            data: (feedResponse) {
              final posts = feedResponse.items;
              if (posts.isEmpty) {
                return ProtoEmptyState(
                  icon: Icons.dynamic_feed_rounded,
                  title: 'Nothing in your feed',
                  subtitle: 'Follow people to see their posts here',
                  actionLabel: 'Discover People',
                  onAction: () => state.push(ProtoRoutes.socialStumble),
                );
              }
              return Stack(
                children: [
                  ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _StoriesRow(posts: posts, theme: theme, state: state),
                      Divider(height: 1, color: theme.text.withValues(alpha: 0.06)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            _TabChip(label: 'Feed', isActive: true),
                            const SizedBox(width: 8),
                            Semantics(
                              identifier: ScreensIds.socialFeedTabStumble,
                              button: true,
                              label: 'Stumble',
                              child: GestureDetector(
                                onTap: () => state.push(ProtoRoutes.socialStumble),
                                child: _TabChip(label: 'Stumble', isActive: false),
                              ),
                            ),
                            const Spacer(),
                            Semantics(
                              identifier: ScreensIds.socialFeedIconFriends,
                              button: true,
                              label: 'Friends',
                              child: GestureDetector(
                                onTap: () => state.push(ProtoRoutes.socialFriends),
                                child: Icon(theme.icons.peopleOutline, size: 22, color: theme.textSecondary),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Semantics(
                              identifier: ScreensIds.socialFeedIconEvents,
                              button: true,
                              label: 'Events',
                              child: GestureDetector(
                                onTap: () => state.push(ProtoRoutes.socialEvents),
                                child: Icon(Icons.event_outlined, size: 22, color: theme.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...List.generate(posts.length + 1, (i) {
                        if (i == 2) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: SponsoredPostCard(
                              brandName: 'Urban Threads',
                              headline: 'New Season Streetwear',
                              description: 'Discover the latest drops from independent designers. Free UK delivery.',
                              ctaText: 'Shop Now',
                            ),
                          );
                        }
                        final postIndex = i < 2 ? i : i - 1;
                        if (postIndex >= posts.length) return const SizedBox.shrink();
                        return _PostCard(
                          content: posts[postIndex],
                          index: postIndex,
                        );
                      }),
                      const SizedBox(height: 80),
                    ],
                  ),
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: ProtoPressButton(
                      onTap: () => state.push(ProtoRoutes.socialCompose),
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: theme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: theme.primary.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.edit_rounded, size: 22, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Top bar ────────────────────────────────────────────────────────────

class _SocialTopBar extends StatelessWidget {
  const _SocialTopBar();

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);

    return Container(
      padding: const EdgeInsets.only(top: 14, left: 16, right: 16, bottom: 8),
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(
          bottom: BorderSide(color: theme.text.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (state.activeModule == ProtoModule.yoyo) {
                state.onYoyoViewToggle();
              } else {
                state.switchModule(ProtoModule.yoyo);
              }
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.background,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.explore_rounded, size: 20, color: theme.textSecondary),
            ),
          ),
          const Spacer(),
          Text(
            'SOCIAL',
            style: theme.label.copyWith(
              fontSize: 14,
              letterSpacing: 2,
              color: theme.text,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => state.push(ProtoRoutes.chatInbox),
            child: SizedBox(
              width: 36,
              height: 36,
              child: Icon(theme.icons.chatBubbleOutline, size: 22, color: theme.textSecondary),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => state.push(ProtoRoutes.profileMy),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: theme.primary.withValues(alpha: 0.3), width: 2),
              ),
              child: Icon(Icons.person, size: 18, color: theme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stories row (built from first 5 feed items, since no stories API) ─

BorderRadius _organicRadius(double size) {
  final tight = size * 0.33;
  final loose = size * 0.5;
  return BorderRadius.only(
    topLeft: Radius.circular(tight),
    topRight: Radius.circular(loose),
    bottomLeft: Radius.circular(loose),
    bottomRight: Radius.circular(tight),
  );
}

class _StoriesRow extends StatelessWidget {
  const _StoriesRow({
    required this.posts,
    required this.theme,
    required this.state,
  });

  final List<Content> posts;
  final ProtoTheme theme;
  final PrototypeStateProvider state;

  @override
  Widget build(BuildContext context) {
    // Build story slots: index 0 is always "your story" (add button),
    // followed by up to 5 creators from the feed.
    final seenCreators = <String>{};
    final storyCreators = <FeedCreator>[];
    for (final c in posts) {
      final creator = c.creator;
      if (creator == null) continue;
      if (!seenCreators.add(creator.id)) continue;
      storyCreators.add(creator);
      if (storyCreators.length >= 5) break;
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: storyCreators.length + 1,
        itemBuilder: (context, i) {
          if (i == 0) {
            return _StoryBubble(
              imageUrl: null,
              label: 'Your story',
              showAdd: true,
              onTap: null,
              theme: theme,
            );
          }
          final creator = storyCreators[i - 1];
          return _StoryBubble(
            imageUrl: creator.avatarUrl,
            label: creator.name,
            showAdd: false,
            onTap: () => state.push(ProtoRoutes.socialStory),
            theme: theme,
          );
        },
      ),
    );
  }
}

class _StoryBubble extends StatelessWidget {
  const _StoryBubble({
    required this.imageUrl,
    required this.label,
    required this.showAdd,
    required this.onTap,
    required this.theme,
  });

  final String? imageUrl;
  final String label;
  final bool showAdd;
  final VoidCallback? onTap;
  final ProtoTheme theme;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: _organicRadius(64),
                border: Border.all(
                  color: showAdd ? theme.textTertiary : theme.primary,
                  width: 2.5,
                ),
                color: theme.surface,
                image: imageUrl != null && imageUrl!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              clipBehavior: Clip.antiAlias,
              child: showAdd
                  ? Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: 22,
                        height: 22,
                        transform: Matrix4.translationValues(0, 6, 0),
                        decoration: BoxDecoration(
                          color: theme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.background, width: 2),
                        ),
                        child: const Icon(Icons.add, size: 12, color: Colors.white),
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 64,
              child: Text(
                label,
                style: theme.caption.copyWith(fontSize: 10),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tab chip ───────────────────────────────────────────────────────────

class _TabChip extends StatelessWidget {
  final String label;
  final bool isActive;
  const _TabChip({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? ProtoTheme.of(context).primary : ProtoTheme.of(context).background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: ProtoTheme.of(context).caption.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.white : ProtoTheme.of(context).textSecondary,
        ),
      ),
    );
  }
}

// ─── Post card (live) ───────────────────────────────────────────────────

class _PostCard extends ConsumerStatefulWidget {
  final Content content;
  final int index;
  const _PostCard({required this.content, required this.index});

  @override
  ConsumerState<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<_PostCard> {
  bool? _optimisticLiked;
  int _likeDelta = 0;
  bool _likeInFlight = false;

  Future<void> _onLike() async {
    if (_likeInFlight) return;
    final contentId = widget.content.id;
    // Guard against Content rows the backend returned without an id.
    // Mobile feed filters these upstream; the web prototype still
    // reads the unfiltered response — fail quietly rather than crash.
    if (contentId == null) return;
    final currentlyLiked = _optimisticLiked ?? false;
    final nextLiked = !currentlyLiked;
    setState(() {
      _optimisticLiked = nextLiked;
      _likeDelta += nextLiked ? 1 : -1;
      _likeInFlight = true;
    });
    try {
      final serverLiked = await togglePostLike(ref, contentId);
      if (!mounted) return;
      setState(() {
        _optimisticLiked = serverLiked;
        _likeInFlight = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        // Roll back on failure.
        _optimisticLiked = currentlyLiked;
        _likeDelta += nextLiked ? -1 : 1;
        _likeInFlight = false;
      });
      if (mounted) {
        ProtoToast.show(context, Icons.error_outline, 'Could not update like');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    final post = widget.content;
    final liked = _optimisticLiked ?? false;
    final likeCount = post.likeCount + _likeDelta;
    final creatorName = post.creator?.name ?? 'Someone';
    final avatarUrl = post.creator?.avatarUrl ?? '';
    final bodyText = post.text ?? post.caption ?? '';

    final i = widget.index;
    final preview = bodyText.length > 80 ? bodyText.substring(0, 80) : bodyText;
    return Semantics(
      identifier: ScreensIds.socialFeedCard(i),
      label: 'Post by $creatorName',
      value: '$creatorName: $preview',
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: theme.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ProtoAvatar(radius: 18, imageUrl: avatarUrl),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(creatorName,
                          style: theme.title.copyWith(fontSize: 14)),
                      Text(_relativeTime(post.createdAt),
                          style: theme.caption),
                    ],
                  ),
                ),
                Icon(theme.icons.moreHoriz, size: 20, color: theme.textTertiary),
              ],
            ),
            if (bodyText.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(bodyText, style: theme.body),
            ],
            if (post.thumbnailUrl != null) ...[
              const SizedBox(height: 10),
              ProtoNetworkImage(
                imageUrl: post.thumbnailUrl!,
                height: 160,
                width: double.infinity,
                borderRadius: BorderRadius.circular(theme.radiusMd),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Semantics(
                  identifier: ScreensIds.socialFeedLike(i),
                  button: true,
                  selected: liked,
                  label: 'Like',
                  value: '$likeCount',
                  child: ProtoPressButton(
                    onTap: _onLike,
                    child: Row(
                      children: [
                        Icon(
                          liked
                              ? theme.icons.favoriteFilled
                              : theme.icons.favoriteOutline,
                          size: 20,
                          color: liked ? theme.accent : theme.textTertiary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$likeCount',
                          style: theme.caption.copyWith(
                            color: liked ? theme.accent : theme.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Semantics(
                  identifier: ScreensIds.socialFeedComment(i),
                  button: true,
                  label: 'Comment',
                  value: '${post.commentCount}',
                  child: ProtoPressButton(
                    onTap: () => ProtoToast.show(
                        context, theme.icons.chatBubbleOutline, 'Comments'),
                    child: Row(
                      children: [
                        Icon(theme.icons.chatBubbleOutline,
                            size: 18, color: theme.textTertiary),
                        const SizedBox(width: 6),
                        Text('${post.commentCount}', style: theme.caption),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                ProtoPressButton(
                  onTap: () =>
                      ProtoToast.show(context, Icons.repeat_rounded, 'Reposted'),
                  child:
                      Icon(Icons.repeat_rounded, size: 18, color: theme.textTertiary),
                ),
                const Spacer(),
                Semantics(
                  identifier: ScreensIds.socialFeedShare(i),
                  button: true,
                  label: 'Share',
                  child: ProtoPressButton(
                    onTap: () => ProtoShareSheet.show(context),
                    child: Icon(theme.icons.share,
                        size: 18, color: theme.textTertiary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _relativeTime(DateTime? d) {
    if (d == null) return '';
    final diff = DateTime.now().difference(d);
    if (diff.isNegative) return '';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo';
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'now';
  }
}
