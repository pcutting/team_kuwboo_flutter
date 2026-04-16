import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_models/kuwboo_models.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';
import '../screens_test_ids.dart';
import '../sponsored/sponsored_inline.dart';
import 'video_providers.dart';

/// Adapter: map an API [Content] (STI row, ContentType.video) onto the
/// lightweight display tuple the feed UI consumes. Preserves the existing
/// widget tree 1:1 while the data source switches to the live backend.
DemoVideo _contentToDemoVideo(Content c) {
  return DemoVideo(
    creator: c.creator?.name ?? 'Creator',
    caption: c.caption ?? '',
    // Music track is not on Content yet — fall back to a neutral label so
    // the marquee still renders.
    musicTrack: 'Original sound',
    likes: c.likeCount,
    comments: c.commentCount,
    shares: c.shareCount,
    avatarUrl: c.creator?.avatarUrl ??
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop',
  );
}

/// Per-video interaction state (independent for each video in the feed).
class _VideoInteractionState {
  bool isLiked = false;
  bool isSaved = false;
  bool isFollowing = false;
}

/// 12 unique dark gradient pairs — one per video index.
const _videoGradients = <List<Color>>[
  [Color(0xFF1a1a2e), Color(0xFF16213e)], // deep navy
  [Color(0xFF2d1b69), Color(0xFF11001c)], // purple night
  [Color(0xFF4a0e2e), Color(0xFF1a0a1a)], // dark magenta
  [Color(0xFF0d3b3b), Color(0xFF0a1628)], // teal dark
  [Color(0xFF1b3a2d), Color(0xFF0a1a12)], // forest deep
  [Color(0xFF3b1a0d), Color(0xFF1a0e08)], // burnt umber
  [Color(0xFF1a2e4a), Color(0xFF0c1220)], // steel blue
  [Color(0xFF2e1a3b), Color(0xFF120a1a)], // plum night
  [Color(0xFF3b3a1a), Color(0xFF1a1808)], // olive dark
  [Color(0xFF1a3b3b), Color(0xFF081a1a)], // dark cyan
  [Color(0xFF3b1a2e), Color(0xFF1a0a14)], // wine dark
  [Color(0xFF1a2e1a), Color(0xFF0a180a)], // evergreen
];

class VideoFeedScreen extends ConsumerStatefulWidget {
  final bool isFollowingFeed;
  const VideoFeedScreen({super.key, this.isFollowingFeed = false});

  @override
  ConsumerState<VideoFeedScreen> createState() => _VideoFeedScreenState();
}

class _VideoFeedScreenState extends ConsumerState<VideoFeedScreen>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  int _currentPage = 0;

  // Per-video interaction state
  final Map<int, _VideoInteractionState> _videoStates = {};

  // Global mute state (persists across videos)
  bool _isMuted = false;

  // Heart burst animation
  bool _showHeartBurst = false;
  Offset _heartPosition = Offset.zero;

  // Mute icon overlay
  bool _showMuteIcon = false;
  Timer? _muteIconTimer;

  // Overlay entry animation
  late AnimationController _overlayController;
  late Animation<double> _overlayFade;
  late Animation<double> _overlaySlide;
  late Animation<double> _actionScale;

  // Spinning music disc
  late AnimationController _discController;

  // Music track marquee
  late AnimationController _marqueeController;

  // Like count bounce
  late AnimationController _likeBounceController;
  late Animation<double> _likeBounceScale;

  // Video lists — populated from the live backend in build().
  List<Content> _contents = const [];
  List<DemoVideo> _videos = const [];

  bool get _hasEndCard => widget.isFollowingFeed;
  int get _totalPages => _videos.length + (_hasEndCard ? 1 : 0);

  @override
  void initState() {
    super.initState();

    _pageController = PageController();

    // Overlay entry
    _overlayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _overlayFade = CurvedAnimation(
      parent: _overlayController,
      curve: const Interval(0.15, 0.8, curve: Curves.easeOut),
    );
    _overlaySlide = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(
        parent: _overlayController,
        curve: const Interval(0.1, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _actionScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _overlayController,
        curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
      ),
    );
    _overlayController.forward();

    // Spinning disc
    _discController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Marquee
    _marqueeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    // Like bounce
    _likeBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _likeBounceScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(
      parent: _likeBounceController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _muteIconTimer?.cancel();
    _pageController.dispose();
    _overlayController.dispose();
    _discController.dispose();
    _marqueeController.dispose();
    _likeBounceController.dispose();
    super.dispose();
  }

  _VideoInteractionState _stateFor(int index) {
    return _videoStates.putIfAbsent(index, () => _VideoInteractionState());
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    _overlayController.reset();
    _overlayController.forward();
    // Log a view for the newly visible video. Fire-and-forget.
    if (page < _contents.length) {
      final id = _contents[page].id;
      if (id != null) {
        unawaited(ref.read(interactionsApiProvider).logView(id));
      }
    }
  }

  void _handleDoubleTap(TapDownDetails details) {
    if (_currentPage >= _videos.length) return;
    final state = _stateFor(_currentPage);
    final wasLiked = state.isLiked;
    setState(() {
      state.isLiked = true;
      _showHeartBurst = true;
      _heartPosition = details.localPosition;
    });
    _likeBounceController.forward(from: 0);
    // Only fire the like API if this is a new like (double-tap is always
    // a like-on, never an unlike).
    if (!wasLiked && _currentPage < _contents.length) {
      final id = _contents[_currentPage].id;
      if (id != null) {
        unawaited(ref.read(interactionsApiProvider).likeContent(id));
      }
    }
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _showHeartBurst = false);
    });
  }

  void _handleSingleTap() {
    setState(() {
      _isMuted = !_isMuted;
      _showMuteIcon = true;
    });
    _muteIconTimer?.cancel();
    _muteIconTimer = Timer(const Duration(milliseconds: 1000), () {
      if (mounted) setState(() => _showMuteIcon = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final kind = widget.isFollowingFeed
        ? VideoFeedKind.following
        : VideoFeedKind.forYou;
    final feedAsync = ref.watch(videoFeedProvider(kind));

    return feedAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Couldn\'t load videos.\n$err',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ),
      data: (feed) {
        _contents = feed.items;
        _videos = feed.items.map(_contentToDemoVideo).toList();
        if (widget.isFollowingFeed && _videos.isEmpty) {
          return const ProtoEmptyState(
            icon: Icons.people_outline_rounded,
            title: 'No followed creators yet',
            subtitle: 'Follow creators to see their videos here',
            actionLabel: 'Discover Creators',
          );
        }
        return Stack(
        children: [
          // Vertical swipeable feed
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: _totalPages,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              if (index >= _videos.length && _hasEndCard) {
                return _buildEndCard(context);
              }
              return Semantics(
                identifier: ScreensIds.videoFeedCard(index),
                label: 'Video ${index + 1}',
                child: _buildVideoPage(context, index),
              );
            },
          ),

          // Position dots (left edge)
          if (_totalPages > 1) _buildPositionDots(),

          // YoYo icon (left) + chat & profile (right) — at bevel level
          _buildTopBar(context),
        ],
      );
      },
    );
  }

  Widget _buildVideoPage(BuildContext context, int index) {
    final theme = ProtoTheme.of(context);
    final video = _videos[index];
    final videoState = _stateFor(index);
    final gradientIndex = index % _videoGradients.length;
    final colors = _videoGradients[gradientIndex];
    final likeCount = video.likes + (videoState.isLiked ? 100 : 0);
    final isSponsored = !widget.isFollowingFeed && index == 0;

    return Stack(
      children: [
        // Unique gradient background per video
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colors[0],
                colors[1],
                Colors.black.withValues(alpha: 0.9),
              ],
            ),
          ),
        ),

        // Tappable video area
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _handleSingleTap,
            onDoubleTapDown: _handleDoubleTap,
            onDoubleTap: () {},
            child: Center(
              child: Icon(
                theme.icons.playCircleOutline,
                size: 64,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),

        // Heart burst animation
        if (_showHeartBurst && _currentPage == index)
          Positioned(
            left: _heartPosition.dx - 80,
            top: _heartPosition.dy - 80,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.3, end: 1.8),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOut,
              builder: (context, scale, child) {
                final opacity =
                    (1.0 - ((scale - 0.3) / 1.5)).clamp(0.0, 1.0);
                return Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: opacity,
                    child: Icon(theme.icons.favoriteFilled,
                        size: 160, color: theme.accent),
                  ),
                );
              },
            ),
          ),

        // Mute icon overlay (center)
        if (_showMuteIcon && _currentPage == index)
          Center(
            child: Semantics(
              identifier: ScreensIds.videoFeedMute,
              label: _isMuted ? 'Muted' : 'Unmuted',
              child: AnimatedOpacity(
                opacity: _showMuteIcon ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isMuted
                        ? Icons.volume_off_rounded
                        : Icons.volume_up_rounded,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

        // Sponsored overlay (For You feed, first video only)
        if (isSponsored)
          SponsoredVideoOverlay(
            brandName: 'StyleBox UK',
            caption:
                'Your wardrobe refresh starts here. New arrivals every week.',
            ctaText: 'Shop Collection',
          ),

        // Creator info + caption (bottom left)
        if (!isSponsored)
          Positioned(
            left: 16,
            bottom: 20,
            right: 80,
            child: AnimatedBuilder(
              animation: _overlayController,
              builder: (context, child) => _currentPage == index
                  ? Opacity(
                      opacity: _overlayFade.value,
                      child: Transform.translate(
                        offset: Offset(0, _overlaySlide.value),
                        child: child,
                      ),
                    )
                  : child!,
              child: _buildCreatorInfo(context, video, videoState, index),
            ),
          ),

        // Action column (right side)
        Positioned(
          right: 12,
          top: 0,
          bottom: 0,
          child: AnimatedBuilder(
            animation: _overlayController,
            builder: (context, child) => _currentPage == index
                ? Transform.scale(
                    scale: _actionScale.value,
                    child: child,
                  )
                : child!,
            child: _buildActionColumn(
                context, video, videoState, likeCount, index),
          ),
        ),

        // Spinning music disc (bottom right, below action column)
        if (!isSponsored) _buildMusicDisc(context, video),
      ],
    );
  }

  Widget _buildCreatorInfo(BuildContext context, DemoVideo video,
      _VideoInteractionState videoState, int index) {
    final theme = ProtoTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => PrototypeStateProvider.of(context)
              .push(ProtoRoutes.videoCreator),
          child: Row(
            children: [
              ProtoAvatar(
                radius: 18,
                imageUrl: video.avatarUrl,
              ),
              const SizedBox(width: 10),
              Text(
                video.creator,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Semantics(
                identifier: ScreensIds.videoFeedFollowCreator,
                button: true,
                selected: videoState.isFollowing,
                label: videoState.isFollowing ? 'Following' : 'Follow',
                child: ProtoPressButton(
                  onTap: () => setState(
                      () => videoState.isFollowing = !videoState.isFollowing),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: videoState.isFollowing
                          ? theme.primary
                          : Colors.transparent,
                      border: Border.all(
                        color: videoState.isFollowing
                            ? theme.primary
                            : Colors.white54,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      videoState.isFollowing ? 'Following' : 'Follow',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          video.caption,
          style:
              const TextStyle(fontSize: 13, color: Colors.white, height: 1.4),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        // Music track with marquee
        GestureDetector(
          onTap: () => PrototypeStateProvider.of(context)
              .push(ProtoRoutes.videoSound),
          child: Row(
            children: [
              const Icon(Icons.music_note_rounded,
                  size: 14, color: Colors.white70),
              const SizedBox(width: 6),
              Expanded(child: _buildMarqueeText(video.musicTrack)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMarqueeText(String text) {
    return SizedBox(
      height: 16,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final textPainter = TextPainter(
            text: TextSpan(
              text: text,
              style:
                  const TextStyle(fontSize: 12, color: Colors.white70),
            ),
            maxLines: 1,
            textDirection: TextDirection.ltr,
          )..layout();

          if (textPainter.width <= constraints.maxWidth) {
            return Text(
              text,
              style:
                  const TextStyle(fontSize: 12, color: Colors.white70),
              overflow: TextOverflow.ellipsis,
            );
          }

          final totalWidth = textPainter.width + 40;
          return ClipRect(
            child: AnimatedBuilder(
              animation: _marqueeController,
              builder: (context, child) {
                final offset = _marqueeController.value * totalWidth;
                return Transform.translate(
                  offset: Offset(-offset, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(text,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white70)),
                      const SizedBox(width: 40),
                      Text(text,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionColumn(BuildContext context, DemoVideo video,
      _VideoInteractionState videoState, int likeCount, int index) {
    final theme = ProtoTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Like button
            Semantics(
              identifier: ScreensIds.videoFeedLike,
              label: videoState.isLiked ? 'Unlike, ${_formatCount(likeCount)} likes' : 'Like, ${_formatCount(likeCount)} likes',
              button: true,
              selected: videoState.isLiked,
              child: ProtoPressButton(
                onTap: () {
                  setState(() => videoState.isLiked = !videoState.isLiked);
                  if (videoState.isLiked) {
                    _likeBounceController.forward(from: 0);
                  }
                  // Fire-and-forget toggleLike on the backend. Optimistic
                  // UI has already flipped local state.
                  if (index < _contents.length) {
                    final id = _contents[index].id;
                    if (id != null) {
                      unawaited(ref
                          .read(interactionsApiProvider)
                          .likeContent(id));
                    }
                  }
                },
                child: Column(
                  children: [
                    Icon(
                      videoState.isLiked
                          ? theme.icons.favoriteFilled
                          : theme.icons.favoriteOutline,
                      size: 36,
                      color:
                          videoState.isLiked ? theme.accent : Colors.white,
                    ),
                    const SizedBox(height: 4),
                    // Like count with bounce
                    _currentPage == index
                        ? AnimatedBuilder(
                            animation: _likeBounceScale,
                            builder: (context, child) => Transform.scale(
                              scale: _likeBounceScale.value,
                              child: child,
                            ),
                            child: Text(
                              _formatCount(likeCount),
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                            ),
                          )
                        : Text(
                            _formatCount(likeCount),
                            style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                          ),
                  ],
                ),
              ),
              ),
              const SizedBox(height: 20),
              // Comment button
              Semantics(
                identifier: ScreensIds.videoFeedComment,
                label: 'Comments, ${_formatCount(video.comments)}',
                button: true,
                child: ProtoPressButton(
                onTap: () {
                  final contentId = index < _contents.length
                      ? _contents[index].id
                      : null;
                  if (contentId != null) {
                    PrototypeStateProvider.of(context).pushWithArgs(
                      ProtoRoutes.videoComments,
                      {'contentId': contentId},
                    );
                  } else {
                    PrototypeStateProvider.of(context)
                        .push(ProtoRoutes.videoComments);
                  }
                },
                child: Column(
                  children: [
                    Icon(theme.icons.chatBubbleOutline,
                        size: 28, color: Colors.white),
                    const SizedBox(height: 4),
                    Text(
                      _formatCount(video.comments),
                      style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              ),
              const SizedBox(height: 20),
              // Repost button
              Semantics(
                label: 'Repost video',
                button: true,
                child: ProtoPressButton(
                onTap: () => _showRepostSheet(context, video, index % _videoGradients.length),
                child: const Column(
                  children: [
                    Icon(Icons.repeat_rounded, size: 28, color: Colors.white),
                    SizedBox(height: 4),
                    Text(
                      'Repost',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              ),
              const SizedBox(height: 20),
              // Share button
              Semantics(
                identifier: ScreensIds.videoFeedShare,
                label: 'Share, ${_formatCount(video.shares)} shares',
                button: true,
                child: ProtoPressButton(
                onTap: () {
                  ProtoShareSheet.show(context);
                  if (index < _contents.length) {
                    final id = _contents[index].id;
                    if (id != null) {
                      unawaited(ref
                          .read(interactionsApiProvider)
                          .logShare(id));
                    }
                  }
                },
                child: Column(
                  children: [
                    Icon(theme.icons.share, size: 28, color: Colors.white),
                    const SizedBox(height: 4),
                    Text(
                      _formatCount(video.shares),
                      style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              ),
              const SizedBox(height: 20),
              // Save/bookmark button
              Semantics(
                label: videoState.isSaved ? 'Remove from saved' : 'Save to favorites',
                button: true,
                child: ProtoPressButton(
                onTap: () {
                  setState(() {
                    videoState.isSaved = !videoState.isSaved;
                    if (videoState.isSaved) {
                      ProtoToast.show(
                          context, theme.icons.bookmarkFilled, 'Saved to favorites');
                    }
                  });
                  if (index < _contents.length) {
                    final id = _contents[index].id;
                    if (id != null) {
                      unawaited(ref
                          .read(interactionsApiProvider)
                          .saveContent(id));
                    }
                  }
                },
                child: Column(
                  children: [
                    Icon(
                      videoState.isSaved
                          ? theme.icons.bookmarkFilled
                          : theme.icons.bookmarkOutline,
                      size: 28,
                      color:
                          videoState.isSaved ? theme.primary : Colors.white,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      videoState.isSaved ? 'Saved' : 'Save',
                      style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
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

  Widget _buildMusicDisc(BuildContext context, DemoVideo video) {
    return Positioned(
      right: 16,
      bottom: 16,
      child: GestureDetector(
        onTap: () =>
            PrototypeStateProvider.of(context).push(ProtoRoutes.videoSound),
        child: AnimatedBuilder(
          animation: _discController,
          builder: (context, child) => Transform.rotate(
            angle: _discController.value * 2 * math.pi,
            child: child,
          ),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(video.avatarUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5), width: 1),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPositionDots() {
    return Positioned(
      left: 6,
      top: 0,
      bottom: 0,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_totalPages, (i) {
            final isActive = i == _currentPage;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 4,
                height: isActive ? 18 : 4,
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white.withValues(alpha: 0.9)
                      : Colors.white.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final theme = ProtoTheme.of(context);
    return Positioned(
      top: 12,
      left: 12,
      right: 12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // YoYo compass icon
          GestureDetector(
            onTap: () => PrototypeStateProvider.of(context)
                .switchModule(ProtoModule.yoyo),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.explore_rounded,
                  size: 20, color: Colors.white70),
            ),
          ),

          // Chat + Profile cluster
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Chat icon with badge
              GestureDetector(
                onTap: () => PrototypeStateProvider.of(context)
                    .push(ProtoRoutes.chatInbox),
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(theme.icons.chatBubbleOutline,
                            size: 22, color: Colors.white70),
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
                            border: Border.all(
                                color: Colors.black.withValues(alpha: 0.5),
                                width: 1.5),
                          ),
                          child: const Center(
                            child: Text('3',
                                style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Profile avatar with notification dot
              GestureDetector(
                onTap: () => PrototypeStateProvider.of(context)
                    .push(ProtoRoutes.profileMy),
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
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 2),
                            image: const DecorationImage(
                              image: NetworkImage(
                                  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop'),
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
                            border: Border.all(
                                color: Colors.black.withValues(alpha: 0.5),
                                width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEndCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1a1a2e),
            const Color(0xFF16213e),
            Colors.black.withValues(alpha: 0.95),
          ],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline_rounded,
                size: 48, color: Colors.white),
            SizedBox(height: 16),
            Text(
              "You're all caught up!",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Follow more creators to see\ntheir videos here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRepostSheet(BuildContext context, DemoVideo video, int gradientIndex) {
    final theme = ProtoTheme.of(context);
    final state = PrototypeStateProvider.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(theme.radiusLg)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.textTertiary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Repost', style: theme.title),
                const SizedBox(height: 4),
                Text(
                  '${video.creator} \u2022 ${video.caption}',
                  style: theme.caption.copyWith(color: theme.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),

                // Repost to Feed (instant repost)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Navigator.pop(ctx);
                    ProtoToast.show(context, Icons.repeat_rounded,
                        'Reposted to your social feed');
                    // Switch to social feed to show the repost
                    Future.delayed(const Duration(milliseconds: 600), () {
                      if (mounted) state.switchModule(ProtoModule.social);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: theme.text.withValues(alpha: 0.06)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: theme.primary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.repeat_rounded, color: theme.primary, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Repost to Feed',
                                  style: theme.body.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: theme.text)),
                              const SizedBox(height: 2),
                              Text('Share instantly to your social feed',
                                  style: theme.caption.copyWith(
                                      color: theme.textSecondary, fontSize: 12)),
                            ],
                          ),
                        ),
                        Icon(theme.icons.chevronRight, size: 18, color: theme.textTertiary),
                      ],
                    ),
                  ),
                ),

                // Quote & Repost (opens composer)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Navigator.pop(ctx);
                    state.pushWithArgs(ProtoRoutes.socialCompose, {
                      'creator': video.creator,
                      'caption': video.caption,
                      'gradientIndex': gradientIndex,
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: theme.secondary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.edit_note_rounded,
                              color: theme.secondary, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Quote & Repost',
                                  style: theme.body.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: theme.text)),
                              const SizedBox(height: 2),
                              Text('Add your thoughts with the video',
                                  style: theme.caption.copyWith(
                                      color: theme.textSecondary, fontSize: 12)),
                            ],
                          ),
                        ),
                        Icon(theme.icons.chevronRight, size: 18, color: theme.textTertiary),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}
