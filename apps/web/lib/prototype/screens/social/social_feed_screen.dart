import 'package:flutter/material.dart';
import '../../proto_theme.dart';
import '../../shared/proto_image.dart';
import '../../../data/demo_data.dart';
import '../../prototype_state.dart';
import '../../prototype_routes.dart';
import '../../prototype_demo_data.dart';
import '../../shared/proto_scaffold.dart';
import '../../shared/proto_press_button.dart';
import '../../shared/proto_dialogs.dart';
import '../../shared/proto_media.dart';
import '../sponsored/sponsored_inline.dart';
import '../../shared/proto_states.dart';

class SocialFeedScreen extends StatefulWidget {
  const SocialFeedScreen({super.key});

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen> {
  ValueNotifier<int>? _variantCount;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_variantCount == null) {
      final provider = PrototypeStateProvider.maybeOf(context);
      if (provider != null) {
        _variantCount = provider.screenVariantCount;
        _variantCount!.value = 0;
      }
    }
  }

  @override
  void dispose() {
    _variantCount?.value = 0;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);

    return ProtoScaffold(
      activeModule: ProtoModule.social,
      showTopBar: false,
      body: Column(
        children: [
          const _SocialTopBar(),

          Expanded(
            child: Stack(
              children: [
                DemoDataExtended.posts.isEmpty
                    ? const ProtoEmptyState(
                        icon: Icons.dynamic_feed_rounded,
                        title: 'Nothing in your feed',
                        subtitle: 'Follow people to see their posts here',
                        actionLabel: 'Discover People',
                      )
                    : ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // Stories row — switches based on variant
                    _buildStoriesRow(context, state, theme),

                    Divider(height: 1, color: theme.text.withValues(alpha: 0.06)),

                    // Tab row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          _TabChip(label: 'Feed', isActive: true),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => state.push(ProtoRoutes.socialStumble),
                            child: _TabChip(label: 'Stumble', isActive: false),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => state.push(ProtoRoutes.socialEvents),
                            child: _TabChip(label: 'Events', isActive: false),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => state.push(ProtoRoutes.socialFriends),
                            child: Icon(theme.icons.peopleOutline, size: 22, color: theme.textSecondary),
                          ),
                        ],
                      ),
                    ),

                    // Mixed feed: posts, events, and sponsored content
                    ..._buildMixedFeed(state, theme),

                    // Bottom spacing for FAB
                    const SizedBox(height: 80),
                  ],
                ),

                // Create post FAB
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
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMixedFeed(PrototypeStateProvider state, ProtoTheme theme) {
    final posts = DemoDataExtended.posts;
    final events = ProtoDemoData.events;
    final items = <Widget>[];

    // Interleave: post, post, sponsored, post, EVENT, post, post, EVENT, ...
    int eventIdx = 0;
    for (var i = 0; i < posts.length; i++) {
      // Sponsored card after 2nd post
      if (i == 2) {
        items.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: SponsoredPostCard(
            brandName: 'Urban Threads',
            headline: 'New Season Streetwear',
            description: 'Discover the latest drops from independent designers. Free UK delivery.',
            ctaText: 'Shop Now',
          ),
        ));
      }

      // Insert an event card after every 3rd post (positions 3, 6, 9...)
      if (i > 0 && i % 3 == 0 && eventIdx < events.length) {
        items.add(_FeedEventCard(
          event: events[eventIdx],
          onTap: () => state.pushWithArgs(ProtoRoutes.socialEventDetail, events[eventIdx]),
        ));
        eventIdx++;
      }

      final post = posts[i];
      items.add(_PostCard(
        post: post,
        onTap: () => state.pushWithArgs(ProtoRoutes.socialPostDetail, post),
      ));
    }
    return items;
  }

  Widget _buildStoriesRow(BuildContext context, PrototypeStateProvider state, ProtoTheme theme) {
    return _StoriesRowCard(state: state, theme: theme);
  }
}

// ─── Custom top bar with variant toggle buttons ────────────────────────────

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
          // YoYo icon (same as ProtoTopBar)
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

          // Title
          Text(
            'SOCIAL',
            style: theme.label.copyWith(
              fontSize: 14,
              letterSpacing: 2,
              color: theme.text,
            ),
          ),

          const Spacer(),

          // Chat icon with badge
          GestureDetector(
            onTap: () => state.push(ProtoRoutes.chatInbox),
            child: SizedBox(
              width: 36,
              height: 36,
              child: Stack(
                children: [
                  Center(
                    child: Icon(theme.icons.chatBubbleOutline, size: 22, color: theme.textSecondary),
                  ),
                  Positioned(
                    right: 2,
                    top: 4,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: theme.accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.surface, width: 1.5),
                      ),
                      child: const Center(
                        child: Text('3', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Profile avatar
          GestureDetector(
            onTap: () => state.push(ProtoRoutes.profileMy),
            child: SizedBox(
              width: 36,
              height: 36,
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.primary.withValues(alpha: 0.3), width: 2),
                        image: const DecorationImage(
                          image: NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: theme.accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.surface, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Organic superelliptic border radius (matches YoYo radar avatars) ──────
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

// ─── Variant 1/2/3: Card-shaped thumbnails (original style) ───────────────
// bgColor=null uses theme background, or pass explicit white/black.

class _StoriesRowThumbnail extends StatelessWidget {
  final PrototypeStateProvider state;
  final ProtoTheme theme;
  final Color? bgColor;

  const _StoriesRowThumbnail({
    required this.state,
    required this.theme,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = bgColor != null &&
        ThemeData.estimateBrightnessForColor(bgColor!) == Brightness.dark;
    final textColor = isDark ? Colors.white : null;
    final borderBase = isDark ? Colors.white70 : null;

    return Container(
      color: bgColor,
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: ProtoDemoData.stories.length,
        itemBuilder: (context, i) {
          final story = ProtoDemoData.stories[i];
          return GestureDetector(
            onTap: i > 0 ? () => state.push(ProtoRoutes.socialStory) : null,
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
                        color: i == 0
                            ? (borderBase ?? theme.textTertiary)
                            : story.isLive
                                ? theme.accent
                                : theme.primary,
                        width: 2.5,
                      ),
                      image: DecorationImage(
                        image: NetworkImage(story.avatarUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: i == 0
                        ? Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: 22,
                              height: 22,
                              transform: Matrix4.translationValues(0, 6, 0),
                              decoration: BoxDecoration(
                                color: theme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: bgColor ?? theme.background,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(Icons.add, size: 12, color: Colors.white),
                            ),
                          )
                        : story.isLive
                            ? Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: theme.accent,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('LIVE',
                                      style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Colors.white)),
                                ),
                              )
                            : null,
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 64,
                    child: Text(
                      story.author,
                      style: theme.caption.copyWith(
                        fontSize: 10,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Variant 4/5: YoYo-style card layout ──────────────────────────────────
// Surface-colored cards with avatar, name, LIVE badge — on white or dark bg.

class _StoriesRowCard extends StatelessWidget {
  final PrototypeStateProvider state;
  final ProtoTheme theme;
  final bool darkCards; // true = dark card surfaces on theme background

  const _StoriesRowCard({
    required this.state,
    required this.theme,
    this.darkCards = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = darkCards ? const Color(0xFF2A2A2A) : theme.surface;
    final textColor = darkCards ? Colors.white : theme.text;
    final subtextColor = darkCards ? Colors.white60 : theme.textTertiary;
    final shadowColor = darkCards
        ? Colors.black.withValues(alpha: 0.3)
        : theme.text.withValues(alpha: 0.06);

    return Container(
      // Theme background shows through (no explicit color)
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: ProtoDemoData.stories.length,
        itemBuilder: (context, i) {
          final story = ProtoDemoData.stories[i];
          return GestureDetector(
            onTap: i > 0 ? () => state.push(ProtoRoutes.socialStory) : null,
            child: Container(
              width: 82,
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Elongated rounded-rect avatar with ring
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 52,
                        height: 66,
                        decoration: BoxDecoration(
                          borderRadius: _organicRadius(52),
                          border: Border.all(
                            color: i == 0
                                ? subtextColor
                                : story.isLive
                                    ? theme.accent
                                    : theme.primary,
                            width: 2.5,
                          ),
                          image: DecorationImage(
                            image: NetworkImage(story.avatarUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                      ),
                      // Add button for "Your Story"
                      if (i == 0)
                        Positioned(
                          right: -2,
                          bottom: -4,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: theme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: cardBg, width: 2),
                            ),
                            child: const Icon(Icons.add, size: 10, color: Colors.white),
                          ),
                        ),
                      // LIVE badge
                      if (i > 0 && story.isLive)
                        Positioned(
                          top: -4,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: theme.accent,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('LIVE',
                                  style: TextStyle(fontSize: 7, fontWeight: FontWeight.w700, color: Colors.white)),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  // Name
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      story.author,
                      style: theme.caption.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Segment count as subtle subtext
                  if (story.segmentCount > 0)
                    Text(
                      '${story.segmentCount} new',
                      style: theme.caption.copyWith(fontSize: 9, color: subtextColor),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Shared widgets (unchanged) ────────────────────────────────────────────

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

class _PostCard extends StatefulWidget {
  final DemoPost post;
  final VoidCallback? onTap;
  const _PostCard({required this.post, this.onTap});

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  bool _isLiked = false;
  int _currentImage = 0;

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    final post = widget.post;
    final likeCount = post.reactions + (_isLiked ? 1 : 0);

    const hp = EdgeInsets.symmetric(horizontal: 14);

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: theme.cardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 14),
          // Author row
          Padding(
            padding: hp,
            child: Row(
              children: [
                ProtoAvatar(radius: 18, imageUrl: post.avatarUrl),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.author, style: theme.title.copyWith(fontSize: 14)),
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
          ),
          const SizedBox(height: 10),
          Padding(
            padding: hp,
            child: Text(post.text, style: theme.body),
          ),

          // Video repost embed card
          if (post.repostVideoCreator != null) ...[
            const SizedBox(height: 10),
            Padding(
              padding: hp,
              child: _VideoRepostEmbed(
                creator: post.repostVideoCreator!,
                caption: post.repostVideoCaption ?? '',
                gradientIndex: post.repostVideoIndex ?? 0,
              ),
            ),
          ],

          // Text repost card (embedded original post)
          if (post.repostAuthor != null && post.repostVideoCreator == null) ...[
            const SizedBox(height: 10),
            Padding(
              padding: hp,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.text.withValues(alpha: 0.08)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.repeat_rounded, size: 16, color: theme.textTertiary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(post.repostAuthor!, style: theme.title.copyWith(fontSize: 12)),
                          const SizedBox(height: 2),
                          Text(post.repostText ?? '', style: theme.body.copyWith(fontSize: 13), maxLines: 3, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Media: edge-to-edge within the card
          if (post.media.isNotEmpty) ...[
            const SizedBox(height: 10),
            if (post.media.length > 1)
              ProtoMediaCarousel(
                items: post.media,
                theme: theme,
                currentIndex: _currentImage,
                onPageChanged: (i) => setState(() => _currentImage = i),
                borderRadius: BorderRadius.zero,
              )
            else
              ProtoSingleMedia(item: post.media.first, theme: theme, borderRadius: BorderRadius.zero),
          ],

          const SizedBox(height: 10),
          // Action row: like, comment, repost, share
          Padding(
            padding: hp,
            child: Row(
              children: [
                // Like button (interactive)
                ProtoPressButton(
                  onTap: () => setState(() => _isLiked = !_isLiked),
                  child: Row(
                    children: [
                      Icon(
                        _isLiked ? theme.icons.favoriteFilled : theme.icons.favoriteOutline,
                        size: 20,
                        color: _isLiked ? theme.accent : theme.textTertiary,
                      ),
                      const SizedBox(width: 6),
                      Text('$likeCount', style: theme.caption.copyWith(
                        color: _isLiked ? theme.accent : theme.textTertiary,
                      )),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Comment
                ProtoPressButton(
                  onTap: () => ProtoToast.show(context, theme.icons.chatBubbleOutline, 'Comments'),
                  child: Row(
                    children: [
                      Icon(theme.icons.chatBubbleOutline, size: 18, color: theme.textTertiary),
                      const SizedBox(width: 6),
                      Text('${post.comments}', style: theme.caption),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Repost
                ProtoPressButton(
                  onTap: () => ProtoToast.show(context, Icons.repeat_rounded, 'Reposted'),
                  child: Icon(Icons.repeat_rounded, size: 18, color: theme.textTertiary),
                ),
                const Spacer(),
                // Share
                ProtoPressButton(
                  onTap: () => ProtoShareSheet.show(context),
                  child: Icon(theme.icons.share, size: 18, color: theme.textTertiary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
      ),
      ),
    );
  }
}

// ─── Video gradients (mirrors video_feed_screen.dart's private list) ─────
const _repostVideoGradients = <List<Color>>[
  [Color(0xFF1a1a2e), Color(0xFF16213e)],
  [Color(0xFF2d1b69), Color(0xFF11001c)],
  [Color(0xFF4a0e2e), Color(0xFF1a0a1a)],
  [Color(0xFF0d3b3b), Color(0xFF0a1628)],
  [Color(0xFF1b3a2d), Color(0xFF0a1a12)],
  [Color(0xFF3b1a0d), Color(0xFF1a0e08)],
  [Color(0xFF1a2e4a), Color(0xFF0c1220)],
  [Color(0xFF2e1a3b), Color(0xFF120a1a)],
  [Color(0xFF3b3a1a), Color(0xFF1a1808)],
  [Color(0xFF1a3b3b), Color(0xFF081a1a)],
  [Color(0xFF3b1a2e), Color(0xFF1a0a14)],
  [Color(0xFF1a2e1a), Color(0xFF0a180a)],
];

// ─── Video repost embed card ────────────────────────────────────────────

class _VideoRepostEmbed extends StatelessWidget {
  final String creator;
  final String caption;
  final int gradientIndex;

  const _VideoRepostEmbed({
    required this.creator,
    required this.caption,
    required this.gradientIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    final state = PrototypeStateProvider.of(context);
    final colors = _repostVideoGradients[gradientIndex % _repostVideoGradients.length];

    return GestureDetector(
      onTap: () => state.push(ProtoRoutes.videoFeed),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colors[0], colors[1]],
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Dark overlay
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
              ),
            ),

            // Repost badge (top-left)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.repeat_rounded, size: 12, color: Colors.white70),
                    SizedBox(width: 3),
                    Text(
                      'Repost',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),

            // Play icon (centered)
            Center(
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                ),
                child: const Icon(Icons.play_arrow_rounded, size: 28, color: Colors.white),
              ),
            ),

            // Bottom strip: creator + caption
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.6),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    // Small avatar circle
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1),
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                      child: const Icon(Icons.person, size: 14, color: Colors.white70),
                    ),
                    const SizedBox(width: 8),
                    // Creator handle
                    Text(
                      creator,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Caption (fills remaining space)
                    Expanded(
                      child: Text(
                        caption,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Compact event card for mixed feed ──────────────────────────────────────

class _FeedEventCard extends StatelessWidget {
  final DemoEvent event;
  final VoidCallback onTap;
  const _FeedEventCard({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    final costLabel = event.cost ?? 'Free';
    final isFree = event.cost == null;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: theme.cardDecoration,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image with badges
            SizedBox(
              height: 130,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ProtoNetworkImage(imageUrl: event.imageUrl, height: 130, width: double.infinity),
                  // Date pill
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(event.date, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                  // Cost pill
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isFree ? const Color(0xFF2E7D32).withValues(alpha: 0.85) : Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(costLabel, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                  // "Event" label bottom-left
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: theme.primary.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.event_rounded, size: 11, color: Colors.white),
                          const SizedBox(width: 4),
                          const Text('Event', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, style: theme.title.copyWith(fontSize: 15)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(theme.icons.locationOn, size: 13, color: theme.textTertiary),
                      const SizedBox(width: 4),
                      Expanded(child: Text(event.location, style: theme.caption, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Avatar stack
                      if (event.attendeeAvatars.isNotEmpty) ...[
                        SizedBox(
                          width: 18.0 + (event.attendeeAvatars.take(3).length - 1) * 12.0,
                          height: 18,
                          child: Stack(
                            children: [
                              for (var j = 0; j < event.attendeeAvatars.take(3).length; j++)
                                Positioned(
                                  left: j * 12.0,
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: theme.surface, width: 1.5),
                                      image: DecorationImage(
                                        image: NetworkImage(event.attendeeAvatars[j]),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text('${event.goingCount} going', style: theme.caption.copyWith(color: theme.primary, fontSize: 11)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: theme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text('Interested', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: theme.primary)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

