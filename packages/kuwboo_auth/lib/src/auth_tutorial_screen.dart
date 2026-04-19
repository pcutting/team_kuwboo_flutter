import 'package:flutter/material.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import '_auth_error_ui.dart';
import '_step_chip.dart';
import 'auth_callbacks.dart';
import 'auth_test_ids.dart';

/// Single interactive tutorial screen. Each tile is the gesture itself —
/// try-it-in-place teaches tap / hold / switch / swipe without the user
/// swiping through four static slides.
class AuthTutorialScreen extends StatefulWidget {
  const AuthTutorialScreen({super.key});

  @override
  State<AuthTutorialScreen> createState() => _AuthTutorialScreenState();
}

enum _Gesture { tap, hold, switchModules, swipe }

class _AuthTutorialScreenState extends State<AuthTutorialScreen> {
  final Set<_Gesture> _completed = <_Gesture>{};

  Future<void> _enterApp() async {
    final callbacks = AuthCallbacksScope.maybeOf(context);
    if (callbacks?.onCompleteTutorial != null) {
      try {
        await callbacks!.onCompleteTutorial!();
      } catch (e, st) {
        debugLogAuthError('auth/tutorial-complete', e, st);
      }
    }
    if (callbacks?.onCompleteOnboarding != null) {
      try {
        await callbacks!.onCompleteOnboarding!();
      } catch (e, st) {
        debugLogAuthError('auth/onboarding-complete', e, st);
      }
    }
    if (!mounted) return;
    PrototypeStateProvider.of(context).switchModule(ProtoModule.video);
  }

  void _markDone(_Gesture g) {
    if (_completed.contains(g)) return;
    setState(() => _completed.add(g));
  }

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    final allDone = _completed.length == _Gesture.values.length;
    final ctaLabel = allDone ? 'Get Started' : 'Skip for now';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Material(
        type: MaterialType.transparency,
        child: Container(
          color: theme.surface,
          child: SafeArea(
            child: Column(
              children: [
                const StepChip(step: 6, almostDone: true),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Text(
                        'Try each gesture',
                        style: theme.headline.copyWith(fontSize: 26),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Kuwboo feels best once your thumbs know the moves.',
                        style: theme.body.copyWith(color: theme.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      physics: const NeverScrollableScrollPhysics(),
                      // Taller tiles so the Switch tile (icon + label column)
                      // doesn't clip, and the other tiles feel less cramped.
                      childAspectRatio: 0.78,
                      children: [
                        _TapTile(
                          done: _completed.contains(_Gesture.tap),
                          onDone: () => _markDone(_Gesture.tap),
                        ),
                        _HoldTile(
                          done: _completed.contains(_Gesture.hold),
                          onDone: () => _markDone(_Gesture.hold),
                        ),
                        _SwitchTile(
                          done: _completed.contains(_Gesture.switchModules),
                          onDone: () => _markDone(_Gesture.switchModules),
                        ),
                        _SwipeTile(
                          done: _completed.contains(_Gesture.swipe),
                          onDone: () => _markDone(_Gesture.swipe),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _ProgressPips(completed: _completed.length),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Semantics(
                    identifier: AuthIds.tutorialNext,
                    button: true,
                    label: ctaLabel,
                    child: GestureDetector(
                      onTap: _enterApp,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: allDone
                              ? theme.primary
                              : theme.text.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(theme.radiusFull),
                        ),
                        child: Center(
                          child: Text(
                            ctaLabel,
                            style: theme.button.copyWith(
                              fontSize: 16,
                              color: allDone
                                  ? theme.button.color
                                  : theme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dot-pips under the grid that fill in as each gesture is completed.
class _ProgressPips extends StatelessWidget {
  const _ProgressPips({required this.completed});
  final int completed;

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_Gesture.values.length, (i) {
        final isDone = i < completed;
        return Semantics(
          identifier: AuthIds.tutorialDot(i),
          selected: isDone,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isDone ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: isDone
                  ? theme.primary
                  : theme.text.withValues(alpha: 0.15),
            ),
          ),
        );
      }),
    );
  }
}

/// Base tile: rounded surface card with title, caption, body child, and a
/// check badge that lights up once [done] flips true.
class _TileFrame extends StatelessWidget {
  const _TileFrame({
    required this.title,
    required this.caption,
    required this.done,
    required this.child,
  });

  final String title;
  final String caption;
  final bool done;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: BorderRadius.circular(theme.radiusLg),
        border: Border.all(
          color: done
              ? theme.primary.withValues(alpha: 0.35)
              : theme.text.withValues(alpha: 0.06),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.title.copyWith(fontSize: 14)),
              const SizedBox(height: 2),
              Text(
                caption,
                style: theme.caption.copyWith(color: theme.textTertiary),
              ),
              const SizedBox(height: 8),
              Expanded(child: Center(child: child)),
            ],
          ),
          if (done)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: theme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Tap ──────────────────────────────────────────────────────────────
class _TapTile extends StatefulWidget {
  const _TapTile({required this.done, required this.onDone});
  final bool done;
  final VoidCallback onDone;

  @override
  State<_TapTile> createState() => _TapTileState();
}

class _TapTileState extends State<_TapTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  int _taps = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      lowerBound: 0.9,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTap() {
    setState(() => _taps++);
    _ctrl.reverse().then((_) => _ctrl.forward());
    if (_taps >= 1) widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    return _TileFrame(
      title: 'Tap',
      caption: 'Most things respond to a single tap.',
      done: widget.done,
      child: GestureDetector(
        onTap: _onTap,
        child: ScaleTransition(
          scale: _ctrl,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.touch_app_rounded,
              size: 32,
              color: theme.primary,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Hold ─────────────────────────────────────────────────────────────
class _HoldTile extends StatefulWidget {
  const _HoldTile({required this.done, required this.onDone});
  final bool done;
  final VoidCallback onDone;

  @override
  State<_HoldTile> createState() => _HoldTileState();
}

class _HoldTileState extends State<_HoldTile> {
  bool _revealed = false;

  void _onHold() {
    setState(() => _revealed = true);
    widget.onDone();
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _revealed = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    return _TileFrame(
      title: 'Hold',
      caption: 'Long-press to open menus.',
      done: widget.done,
      child: GestureDetector(
        onLongPress: _onHold,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 88,
          height: 60,
          decoration: BoxDecoration(
            color: _revealed
                ? theme.secondary.withValues(alpha: 0.15)
                : theme.text.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(theme.radiusMd),
            border: Border.all(
              color: _revealed
                  ? theme.secondary.withValues(alpha: 0.4)
                  : theme.text.withValues(alpha: 0.08),
            ),
          ),
          alignment: Alignment.center,
          child: _revealed
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.reply_rounded,
                      size: 18,
                      color: theme.textSecondary,
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      Icons.bookmark_border_rounded,
                      size: 18,
                      color: theme.textSecondary,
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      Icons.flag_outlined,
                      size: 18,
                      color: theme.textSecondary,
                    ),
                  ],
                )
              : Icon(
                  Icons.back_hand_rounded,
                  size: 28,
                  color: theme.textSecondary,
                ),
        ),
      ),
    );
  }
}

// ─── Switch ───────────────────────────────────────────────────────────
class _SwitchTile extends StatefulWidget {
  const _SwitchTile({required this.done, required this.onDone});
  final bool done;
  final VoidCallback onDone;

  @override
  State<_SwitchTile> createState() => _SwitchTileState();
}

class _SwitchTileState extends State<_SwitchTile> {
  static const _icons = <IconData>[
    Icons.play_circle_fill_rounded,
    Icons.favorite_rounded,
    Icons.people_rounded,
    Icons.explore_rounded,
    Icons.storefront_rounded,
  ];
  static const _labels = <String>['Video', 'Dating', 'Social', 'YoYo', 'Shop'];
  int _idx = 0;

  void _onTap() {
    setState(() => _idx = (_idx + 1) % _icons.length);
    if (_idx != 0) widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    return _TileFrame(
      title: 'Switch',
      caption: 'Jump between Kuwboo worlds.',
      done: widget.done,
      child: GestureDetector(
        onTap: _onTap,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, anim) => ScaleTransition(
            scale: anim,
            child: FadeTransition(opacity: anim, child: child),
          ),
          child: Column(
            key: ValueKey(_idx),
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: theme.accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(_icons[_idx], size: 32, color: theme.accent),
              ),
              const SizedBox(height: 6),
              Text(
                _labels[_idx],
                style: theme.caption.copyWith(
                  color: theme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Swipe ────────────────────────────────────────────────────────────
class _SwipeTile extends StatefulWidget {
  const _SwipeTile({required this.done, required this.onDone});
  final bool done;
  final VoidCallback onDone;

  @override
  State<_SwipeTile> createState() => _SwipeTileState();
}

class _SwipeTileState extends State<_SwipeTile> {
  double _offset = 0;
  bool _animating = false;

  void _onDragUpdate(DragUpdateDetails d) {
    if (_animating) return;
    setState(() => _offset += d.delta.dx);
  }

  void _onDragEnd(DragEndDetails _) {
    if (_offset.abs() > 30) {
      widget.onDone();
    }
    setState(() {
      _animating = true;
      _offset = 0;
    });
    Future.delayed(const Duration(milliseconds: 220), () {
      if (mounted) setState(() => _animating = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    final tilt = (_offset / 12).clamp(-8.0, 8.0) * 0.01;
    return _TileFrame(
      title: 'Swipe',
      caption: 'Drag cards to browse.',
      done: widget.done,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: _onDragUpdate,
        onHorizontalDragEnd: _onDragEnd,
        child: SizedBox(
          width: 96,
          height: 72,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ghost card below
              Transform.translate(
                offset: const Offset(0, 6),
                child: Container(
                  width: 80,
                  height: 60,
                  decoration: BoxDecoration(
                    color: theme.text.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(theme.radiusMd),
                  ),
                ),
              ),
              // Top draggable card
              AnimatedContainer(
                duration: _animating
                    ? const Duration(milliseconds: 220)
                    : Duration.zero,
                curve: Curves.easeOut,
                transform: Matrix4.identity()
                  ..translateByDouble(_animating ? 0 : _offset, 0, 0, 1)
                  ..rotateZ(tilt),
                width: 80,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.primary.withValues(alpha: 0.9),
                      theme.accent.withValues(alpha: 0.9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(theme.radiusMd),
                ),
                child: const Center(
                  child: Icon(
                    Icons.swipe_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
