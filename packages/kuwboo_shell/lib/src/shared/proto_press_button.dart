import 'package:flutter/material.dart';

/// Wraps any child with a springy scale-down animation on tap.
///
/// Animation sequence: 1.0 → 0.85 → 1.15 → 1.0 over 150ms.
/// Use this around any tappable element to give press feedback.
class ProtoPressButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  /// Duration of the full press animation.
  final Duration duration;

  const ProtoPressButton({
    super.key,
    required this.child,
    this.onTap,
    this.duration = const Duration(milliseconds: 150),
  });

  @override
  State<ProtoPressButton> createState() => _ProtoPressButtonState();
}

class _ProtoPressButtonState extends State<ProtoPressButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.85), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.15), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward(from: 0);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) {
          return Transform.scale(scale: _scale.value, child: child);
        },
        child: widget.child,
      ),
    );
  }
}
