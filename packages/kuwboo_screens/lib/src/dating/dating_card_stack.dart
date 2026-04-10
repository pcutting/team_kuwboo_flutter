import 'package:flutter/material.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

class DatingCardStack extends StatefulWidget {
  const DatingCardStack({super.key});

  @override
  State<DatingCardStack> createState() => _DatingCardStackState();
}

class _DatingCardStackState extends State<DatingCardStack>
    with TickerProviderStateMixin {
  final List<DemoProfile> _profiles = DemoData.allProfiles;
  int _currentIndex = 0;

  // Drag state
  Offset _dragOffset = Offset.zero;

  // Card dismiss animation
  late final AnimationController _dismissController;
  late Animation<Offset> _dismissAnimation;

  // Spring-back animation
  late final AnimationController _springController;
  late Animation<Offset> _springAnimation;

  // Callback after dismiss animation (e.g. show match overlay)
  VoidCallback? _onDismissComplete;

  // Threshold for swipe commit (pixels)
  static const double _swipeThreshold = 100.0;

  // Max rotation in radians (~15°)
  static const double _maxRotation = 0.26;

  DemoProfile get _currentProfile => _profiles[_currentIndex % _profiles.length];
  DemoProfile get _nextProfile => _profiles[(_currentIndex + 1) % _profiles.length];

  @override
  void initState() {
    super.initState();

    _dismissController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          final callback = _onDismissComplete;
          _onDismissComplete = null;
          _advanceCard();
          callback?.call();
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
  }

  @override
  void dispose() {
    _dismissController.dispose();
    _springController.dispose();
    super.dispose();
  }

  void _advanceCard() {
    setState(() {
      _currentIndex++;
      _dragOffset = Offset.zero;
    });
    _dismissController.reset();
  }

  void _onPanStart(DragStartDetails details) {
    _springController.stop();
    _dismissController.stop();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final dx = _dragOffset.dx;

    if (dx.abs() > _swipeThreshold) {
      // Commit swipe
      _animateDismiss(dx > 0 ? 1 : -1);
    } else {
      // Spring back
      _animateSpringBack();
    }
  }

  void _animateDismiss(int direction, {bool vertical = false}) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final target = vertical
        ? Offset(0, -screenWidth)
        : Offset(direction * screenWidth * 1.5, _dragOffset.dy);

    _dismissAnimation = _dismissController.drive(
      Tween<Offset>(begin: _dragOffset, end: target),
    );
    _dismissController.forward(from: 0);
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
      setState(() => _dragOffset = _springAnimation.value);
    } else {
      _springController.removeListener(_onSpringTick);
    }
  }

  Offset get _effectiveOffset {
    if (_dismissController.isAnimating) return _dismissAnimation.value;
    return _dragOffset;
  }

  double get _swipeProgress {
    final screenWidth = MediaQuery.sizeOf(context).width;
    if (screenWidth == 0) return 0;
    return (_effectiveOffset.dx / screenWidth).clamp(-1.0, 1.0);
  }

  double get _backCardScale {
    return 0.95 + 0.05 * _swipeProgress.abs().clamp(0.0, 1.0);
  }

  // --- Button actions ---

  void _onDislike() {
    setState(() => _dragOffset = const Offset(-30, 0));
    _animateDismiss(-1);
  }

  void _onSuperLike() {
    setState(() => _dragOffset = const Offset(0, -30));
    _animateDismiss(0, vertical: true);
  }

  void _onLike(PrototypeStateProvider state) {
    _onDismissComplete = () => state.push(ProtoRoutes.datingMatch);
    setState(() => _dragOffset = const Offset(30, 0));
    _animateDismiss(1);
  }

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);
    final profile = _currentProfile;
    final offset = _effectiveOffset;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final rotation = (offset.dx / screenWidth) * _maxRotation;

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            // Top row: Matches + Filter
            _buildTopRow(context, state, theme),
            const SizedBox(height: 8),

            // Card stack
            Expanded(
              child: Stack(
                children: [
                  // Back card (next profile)
                  _buildBackCard(context, theme),

                  // Front card (current profile, interactive)
                  _buildFrontCard(context, state, theme, profile, offset, rotation),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Action buttons — bolder, heart slightly bigger
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _CircleButton(
                  icon: theme.icons.replay,
                  size: 40,
                  color: theme.tertiary,
                  bgColor: theme.tertiary.withValues(alpha: 0.12),
                  semanticLabel: 'Rewind to previous profile',
                  onTap: () {
                    if (_currentIndex > 0) {
                      setState(() => _currentIndex--);
                      ProtoToast.show(context, theme.icons.replay, 'Rewound to previous profile');
                    }
                  },
                ),
                _CircleButton(
                  icon: theme.icons.close,
                  size: 52,
                  color: theme.textTertiary,
                  bgColor: theme.background,
                  semanticLabel: 'Pass on this profile',
                  onTap: _onDislike,
                ),
                _CircleButton(
                  icon: Icons.star_rounded,
                  size: 44,
                  color: theme.tertiary,
                  bgColor: theme.tertiary.withValues(alpha: 0.12),
                  semanticLabel: 'Super like this profile',
                  onTap: _onSuperLike,
                ),
                _CircleButton(
                  icon: theme.icons.favoriteFilled,
                  size: 56,
                  color: theme.accent,
                  bgColor: theme.accent.withValues(alpha: 0.12),
                  semanticLabel: 'Like this profile',
                  onTap: () => _onLike(state),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
        ),
      );
  }

  Widget _buildTopRow(BuildContext context, PrototypeStateProvider state, ProtoTheme theme) {
    return Row(
      children: [
        ProtoPressButton(
          onTap: () => state.push(ProtoRoutes.datingMatches),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(theme.icons.favoriteFilled, size: 16, color: theme.primary),
                const SizedBox(width: 6),
                Text('3 Matches',
                    style: theme.caption.copyWith(
                        color: theme.primary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
        const Spacer(),
        ProtoPressButton(
          onTap: () => state.push(ProtoRoutes.datingFilters),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.background,
              shape: BoxShape.circle,
            ),
            child: Icon(theme.icons.tune, size: 18, color: theme.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildBackCard(BuildContext context, ProtoTheme theme) {
    final nextProfile = _nextProfile;
    return Positioned.fill(
      child: Transform.scale(
        scale: _backCardScale,
        alignment: Alignment.bottomCenter,
        child: Transform.translate(
          offset: Offset(0, -8 * (1 - (_backCardScale - 0.95) / 0.05)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(theme.radiusLg),
              image: DecorationImage(
                image: NetworkImage(nextProfile.imageUrl),
                fit: BoxFit.cover,
                onError: (_, __) {},
              ),
              boxShadow: theme.warmShadow,
            ),
            child: _buildCardGradient(theme),
          ),
        ),
      ),
    );
  }

  Widget _buildFrontCard(
    BuildContext context,
    PrototypeStateProvider state,
    ProtoTheme theme,
    DemoProfile profile,
    Offset offset,
    double rotation,
  ) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Positioned.fill(
      child: GestureDetector(
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        onTap: () {
          if (_dragOffset.distance < 5) {
            state.push(ProtoRoutes.datingProfile);
          }
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([_dismissController, _springController]),
          builder: (context, child) {
            final currentOffset = _effectiveOffset;
            final currentRotation = (currentOffset.dx / screenWidth) * _maxRotation;
            final currentLikeOpacity =
                (currentOffset.dx / _swipeThreshold).clamp(0.0, 1.0);
            final currentNopeOpacity =
                (-currentOffset.dx / _swipeThreshold).clamp(0.0, 1.0);

            return Transform(
              alignment: Alignment.bottomCenter,
              transform: Matrix4.translationValues(
                      currentOffset.dx, currentOffset.dy * 0.3, 0)
                ..rotateZ(currentRotation),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(theme.radiusLg),
                  image: DecorationImage(
                    image: NetworkImage(profile.imageUrl),
                    fit: BoxFit.cover,
                    onError: (_, __) {},
                  ),
                  boxShadow: theme.warmShadow,
                ),
                child: Stack(
                  children: [
                    // Gradient overlay
                    _buildCardGradientOverlay(theme),

                    // LIKE stamp
                    if (currentLikeOpacity > 0)
                      Positioned(
                        top: 40,
                        left: 24,
                        child: Transform.rotate(
                          angle: -0.26,
                          child: Opacity(
                            opacity: currentLikeOpacity,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.green, width: 3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'LIKE',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // NOPE stamp
                    if (currentNopeOpacity > 0)
                      Positioned(
                        top: 40,
                        right: 24,
                        child: Transform.rotate(
                          angle: 0.26,
                          child: Opacity(
                            opacity: currentNopeOpacity,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.red, width: 3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'NOPE',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Match percentage badge
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.secondary,
                          borderRadius:
                              BorderRadius.circular(theme.radiusFull),
                        ),
                        child: Text(
                          '${profile.compatibility}% Match',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                      ),
                    ),

                    // Verified badge
                    if (profile.verified)
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(theme.icons.verified,
                                  size: 14, color: theme.primary),
                              const SizedBox(width: 4),
                              Text('Verified',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: theme.text)),
                            ],
                          ),
                        ),
                      ),

                    // Profile info
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${profile.name}, ${profile.age}',
                            style: theme.headline
                                .copyWith(color: Colors.white, fontSize: 28),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(theme.icons.locationOn,
                                  size: 14, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text(profile.distance,
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.white70)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: profile.tags
                                .map((tag) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.white.withValues(alpha: 0.2),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: Text(tag,
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500)),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCardGradientOverlay(ProtoTheme theme) {
    return Positioned.fill(child: _buildCardGradient(theme));
  }

  Widget _buildCardGradient(ProtoTheme theme) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(theme.radiusLg),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.transparent,
            Colors.black.withValues(alpha: 0.7),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}

// --- Circle button with press feedback ---

class _CircleButton extends StatefulWidget {
  final IconData icon;
  final double size;
  final Color color;
  final Color bgColor;
  final VoidCallback? onTap;
  final String? semanticLabel;

  const _CircleButton({
    required this.icon,
    required this.size,
    required this.color,
    required this.bgColor,
    this.onTap,
    this.semanticLabel,
  });

  @override
  State<_CircleButton> createState() => _CircleButtonState();
}

class _CircleButtonState extends State<_CircleButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.85), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.15), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _scaleController.forward(from: 0);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel,
      button: true,
      child: GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.bgColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(widget.icon, size: widget.size * 0.5, color: widget.color),
        ),
      ),
    ),
    );
  }
}
