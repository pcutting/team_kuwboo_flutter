import 'package:flutter/material.dart';
import '../../proto_theme.dart';
import '../../shared/proto_image.dart';
import '../../../data/demo_data.dart';
import '../../prototype_state.dart';
import '../../prototype_routes.dart';
import '../../shared/proto_scaffold.dart';
import '../../shared/proto_press_button.dart';
import '../../shared/proto_dialogs.dart';

class DatingExpandedProfile extends StatefulWidget {
  const DatingExpandedProfile({super.key});

  @override
  State<DatingExpandedProfile> createState() => _DatingExpandedProfileState();
}

class _DatingExpandedProfileState extends State<DatingExpandedProfile> {
  int _currentPhoto = 0;

  void _openFullscreenGallery(List<String> photos, int index) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) =>
            _DatingFullscreenGallery(photos: photos, initialIndex: index),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 250),
        reverseTransitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);
    final profile = DemoData.mainProfile;
    final allPhotos = [profile.imageUrl, ...profile.additionalImages];

    return Container(
      color: theme.background,
      child: Column(
        children: [
          ProtoSubBar(
            title: profile.name,
            actions: [
              ProtoPressButton(
                onTap: () => ProtoShareSheet.show(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: theme.background,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(theme.icons.share, size: 18, color: theme.textSecondary),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Photo gallery — card-stack swipe
                SizedBox(
                  height: 320,
                  child: _PhotoCardSwiper(
                    photos: allPhotos,
                    currentIndex: _currentPhoto,
                    borderRadius: 0,
                    onIndexChanged: (i) => setState(() => _currentPhoto = i),
                    onTap: (i) => _openFullscreenGallery(allPhotos, i),
                    dotColor: Colors.white,
                    dotInactiveColor: Colors.white.withValues(alpha: 0.4),
                    showCounter: true,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + age + verified
                      Row(
                        children: [
                          Text('${profile.name}, ${profile.age}', style: theme.headline.copyWith(fontSize: 26)),
                          const SizedBox(width: 8),
                          if (profile.verified) Icon(theme.icons.verified, size: 22, color: theme.primary),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(theme.icons.locationOn, size: 16, color: theme.textTertiary),
                          const SizedBox(width: 4),
                          Text(profile.distance, style: theme.body),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: theme.secondary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                            child: Text('${profile.compatibility}% Match', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: theme.secondary)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Bio
                      Text('About', style: theme.title),
                      const SizedBox(height: 6),
                      Text(profile.bio, style: theme.body),
                      const SizedBox(height: 16),

                      // Interests
                      Text('Interests', style: theme.title),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: profile.tags.map((tag) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: theme.accentPillDecoration(theme.primary),
                          child: Text(tag, style: theme.caption.copyWith(color: theme.primary, fontWeight: FontWeight.w600)),
                        )).toList(),
                      ),
                      const SizedBox(height: 20),

                      // Basics section
                      Text('Basics', style: theme.title),
                      const SizedBox(height: 8),
                      _BasicRow(icon: theme.icons.height, label: 'Height', value: "5'7\""),
                      _BasicRow(icon: theme.icons.workOutline, label: 'Job', value: 'Designer'),
                      _BasicRow(icon: theme.icons.schoolOutline, label: 'Education', value: 'Central Saint Martins'),
                      _BasicRow(icon: theme.icons.localBarOutline, label: 'Drinks', value: 'Socially'),

                      const SizedBox(height: 16),

                      // Report link
                      Center(
                        child: GestureDetector(
                          onTap: () => ProtoToast.show(context, theme.icons.flag, 'Report dialog would open'),
                          child: Text('Report this profile', style: theme.caption.copyWith(color: theme.textTertiary)),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom action bar: Pass + Connect + Like
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: theme.surface,
              border: Border(top: BorderSide(color: theme.text.withValues(alpha: 0.06))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ProtoPressButton(
                  onTap: () {
                    ProtoToast.show(context, theme.icons.close, 'Passed');
                    state.pop();
                  },
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: theme.background,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: theme.text.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: Icon(theme.icons.close, size: 26, color: theme.textTertiary),
                  ),
                ),
                // Connect button
                ProtoPressButton(
                  onTap: () {
                    ProtoToast.show(context, theme.icons.personAdd, 'Connect request sent');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: theme.secondary,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: theme.secondary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 3))],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(theme.icons.personAdd, size: 18, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          'Connect',
                          style: theme.button.copyWith(fontSize: 14, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                ProtoPressButton(
                  onTap: () {
                    state.pop();
                    state.push(ProtoRoutes.datingMatch);
                  },
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: theme.accent.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: theme.accent.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: Icon(theme.icons.favoriteFilled, size: 26, color: theme.accent),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BasicRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _BasicRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.textTertiary),
          const SizedBox(width: 10),
          Text(label, style: theme.body.copyWith(color: theme.textTertiary)),
          const Spacer(),
          Text(value, style: theme.body.copyWith(color: theme.text)),
        ],
      ),
    );
  }
}

// ─── Reusable photo card-stack swiper ──────────────────────────────────────
// Matches the dating card-stack feel: translate + rotate front card,
// scale up back card. Bidirectional: swipe left = next, right = previous.

class _PhotoCardSwiper extends StatefulWidget {
  final List<String> photos;
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final ValueChanged<int>? onTap;
  final double borderRadius;
  final Color dotColor;
  final Color dotInactiveColor;
  final bool showCounter;
  final bool showDots;

  const _PhotoCardSwiper({
    required this.photos,
    required this.currentIndex,
    required this.onIndexChanged,
    this.onTap,
    this.borderRadius = 12,
    this.dotColor = Colors.white,
    this.dotInactiveColor = const Color(0x66FFFFFF),
    this.showCounter = false,
    this.showDots = true,
  });

  @override
  State<_PhotoCardSwiper> createState() => _PhotoCardSwiperState();
}

class _PhotoCardSwiperState extends State<_PhotoCardSwiper>
    with TickerProviderStateMixin {
  Offset _dragOffset = Offset.zero;
  int _dragDirection = 0; // -1 = swiping left (next), 1 = swiping right (prev)

  late final AnimationController _dismissController;
  late Animation<Offset> _dismissAnimation;

  late final AnimationController _springController;
  late Animation<Offset> _springAnimation;

  // Dot pulse
  late final AnimationController _dotPulseController;
  late final Animation<double> _dotPulseAnimation;

  static const double _swipeThreshold = 80.0;
  static const double _maxRotation = 0.18; // ~10°

  @override
  void initState() {
    super.initState();

    _dismissController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _commitSwipe();
        }
      });

    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _dismissAnimation = _dismissController.drive(
      Tween<Offset>(begin: Offset.zero, end: Offset.zero),
    );
    _springAnimation = _springController.drive(
      Tween<Offset>(begin: Offset.zero, end: Offset.zero),
    );

    _dotPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _dotPulseAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _dotPulseController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _dismissController.dispose();
    _springController.dispose();
    _dotPulseController.dispose();
    super.dispose();
  }

  int get _current => widget.currentIndex;
  int get _count => widget.photos.length;
  bool get _hasNext => _current < _count - 1;
  bool get _hasPrev => _current > 0;

  // Which photo appears behind the front card during a drag
  int get _backIndex {
    if (_dragDirection < 0 && _hasNext) return _current + 1;
    if (_dragDirection > 0 && _hasPrev) return _current - 1;
    // Default: show next if available, else previous
    if (_hasNext) return _current + 1;
    if (_hasPrev) return _current - 1;
    return _current;
  }

  Offset get _effectiveOffset {
    if (_dismissController.isAnimating) return _dismissAnimation.value;
    return _dragOffset;
  }

  double get _swipeProgress {
    final width = MediaQuery.sizeOf(context).width;
    if (width == 0) return 0;
    return (_effectiveOffset.dx / width).clamp(-1.0, 1.0);
  }

  double get _backCardScale {
    return 0.95 + 0.05 * _swipeProgress.abs().clamp(0.0, 1.0);
  }

  void _onDragStart(DragStartDetails details) {
    _springController.stop();
    _dismissController.stop();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += Offset(details.delta.dx, 0);
      // Track drag direction for back card selection
      if (_dragOffset.dx < -10) {
        _dragDirection = -1; // swiping left → next
      } else if (_dragOffset.dx > 10) {
        _dragDirection = 1; // swiping right → prev
      }
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final dx = _dragOffset.dx;

    if (dx < -_swipeThreshold && _hasNext) {
      _animateDismiss(-1);
    } else if (dx > _swipeThreshold && _hasPrev) {
      _animateDismiss(1);
    } else {
      _animateSpringBack();
    }
  }

  void _animateDismiss(int direction) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final target = Offset(direction * screenWidth * 1.2, 0);

    _dismissAnimation = _dismissController.drive(
      Tween<Offset>(begin: _dragOffset, end: target),
    );
    _dragDirection = direction < 0 ? -1 : 1;
    _dismissController.forward(from: 0);
  }

  void _commitSwipe() {
    final newIndex = _dragDirection < 0 ? _current + 1 : _current - 1;
    setState(() {
      _dragOffset = Offset.zero;
      _dragDirection = 0;
    });
    _dismissController.reset();
    widget.onIndexChanged(newIndex.clamp(0, _count - 1));
    _dotPulseController.forward(from: 0);
  }

  void _animateSpringBack() {
    _springAnimation = _springController.drive(
      Tween<Offset>(begin: _dragOffset, end: Offset.zero)
          .chain(CurveTween(curve: Curves.elasticOut)),
    );
    _springController.forward(from: 0);
    _springController.addListener(_onSpringTick);
  }

  void _onSpringTick() {
    if (_springController.isAnimating) {
      setState(() {
        _dragOffset = _springAnimation.value;
        if (_dragOffset.dx.abs() < 1) _dragDirection = 0;
      });
    } else {
      _springController.removeListener(_onSpringTick);
      setState(() {
        _dragOffset = Offset.zero;
        _dragDirection = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final offset = _effectiveOffset;
    final width = MediaQuery.sizeOf(context).width;
    final rotation = width > 0 ? (offset.dx / width) * _maxRotation : 0.0;
    final radius = BorderRadius.circular(widget.borderRadius);

    return Stack(
      children: [
        // Back card (next/prev photo, scales up)
        if (_backIndex != _current)
          Positioned.fill(
            child: Transform.scale(
              scale: _backCardScale,
              alignment: Alignment.center,
              child: ProtoNetworkImage(
                imageUrl: widget.photos[_backIndex],
                width: double.infinity,
                height: double.infinity,
                borderRadius: radius,
              ),
            ),
          ),

        // Front card (current photo, draggable)
        Positioned.fill(
          child: GestureDetector(
            onHorizontalDragStart: _onDragStart,
            onHorizontalDragUpdate: _onDragUpdate,
            onHorizontalDragEnd: _onDragEnd,
            onTap: () => widget.onTap?.call(_current),
            child: AnimatedBuilder(
              animation: Listenable.merge([_dismissController, _springController]),
              builder: (context, child) {
                final currentOffset = _effectiveOffset;
                final currentRotation =
                    width > 0 ? (currentOffset.dx / width) * _maxRotation : 0.0;

                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.translationValues(
                      currentOffset.dx, 0, 0)
                    ..rotateZ(currentRotation),
                  child: child,
                );
              },
              child: ProtoNetworkImage(
                imageUrl: widget.photos[_current],
                width: double.infinity,
                height: double.infinity,
                borderRadius: radius,
              ),
            ),
          ),
        ),

        // Dot indicators
        if (widget.showDots)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_count, (i) {
                final isActive = i == _current;
                return AnimatedBuilder(
                  animation: _dotPulseAnimation,
                  builder: (context, child) {
                    final scale = isActive ? _dotPulseAnimation.value : 1.0;
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isActive ? 20 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: isActive ? widget.dotColor : widget.dotInactiveColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
          ),

        // Counter badge
        if (widget.showCounter)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_current + 1}/$_count',
                style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Fullscreen gallery ────────────────────────────────────────────────────
// Same card-stack swipe + pinch-to-zoom + tap/X to dismiss.

class _DatingFullscreenGallery extends StatefulWidget {
  final List<String> photos;
  final int initialIndex;

  const _DatingFullscreenGallery({
    required this.photos,
    required this.initialIndex,
  });

  @override
  State<_DatingFullscreenGallery> createState() =>
      _DatingFullscreenGalleryState();
}

class _DatingFullscreenGalleryState extends State<_DatingFullscreenGallery> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Card-stack swiper (fills screen)
          Positioned.fill(
            child: _PhotoCardSwiper(
              photos: widget.photos,
              currentIndex: _currentIndex,
              borderRadius: 0,
              onIndexChanged: (i) => setState(() => _currentIndex = i),
              onTap: (_) => Navigator.of(context).pop(),
              dotColor: Colors.white,
              dotInactiveColor: Colors.white.withValues(alpha: 0.4),
              showCounter: false,
              showDots: false,
            ),
          ),

          // Close button (top-left)
          Positioned(
            top: statusBarHeight + 12,
            left: 12,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 20, color: Colors.white),
              ),
            ),
          ),

          // Counter badge (top-right)
          Positioned(
            top: statusBarHeight + 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_currentIndex + 1}/${widget.photos.length}',
                style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),

          // Dot indicators at bottom (override the swiper's built-in ones)
          Positioned(
            bottom: bottomPad + 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.photos.length, (i) {
                final isActive = i == _currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isActive ? 20 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
