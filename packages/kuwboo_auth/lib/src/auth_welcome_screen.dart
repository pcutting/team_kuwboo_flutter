import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import 'auth_callbacks.dart';

class AuthWelcomeScreen extends StatelessWidget {
  const AuthWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    final callbacks = AuthCallbacksScope.maybeOf(context);

    return Material(
      type: MaterialType.transparency,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.primary,
              theme.primary.withValues(alpha: 0.85),
              theme.background,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, c) {
              // Logo centered at ~33%, button stack centered at ~66%.
              return Stack(
                children: [
                  Positioned(
                    top: c.maxHeight * 0.33 - 90,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: theme.warmShadow,
                          ),
                          child: Image.asset(
                            'assets/images/kuwboo-logo.png',
                            package: 'kuwboo_shell',
                            height: 88,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Connect. Discover. Be You.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: c.maxHeight * 0.62,
                    left: 32,
                    right: 32,
                    child: Column(
                      children: [
                        _PrimaryButton(
                          label: 'Create Account',
                          onTap: () => context.go(ProtoRoutes.authMethod),
                        ),
                        const SizedBox(height: 12),
                        _OutlineButton(
                          label: 'Log In',
                          onTap: () => context.go(ProtoRoutes.authLogin),
                        ),
                        const SizedBox(height: 18),
                        const _OrDivider(),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _SsoIconButton(
                              icon: _AppleGlyph(),
                              background: Colors.black,
                              tooltip: 'Continue with Apple',
                              onTap: callbacks?.onSignInWithApple == null
                                  ? null
                                  : () async {
                                      try {
                                        await callbacks!.onSignInWithApple!();
                                      } catch (e) {
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    'Apple sign-in failed: $e')));
                                      }
                                    },
                            ),
                            const SizedBox(width: 20),
                            _SsoIconButton(
                              icon: const _GoogleGlyph(),
                              background: Colors.white,
                              border: Colors.black12,
                              tooltip: 'Continue with Google',
                              onTap: callbacks?.onSignInWithGoogle == null
                                  ? null
                                  : () async {
                                      try {
                                        await callbacks!.onSignInWithGoogle!();
                                      } catch (e) {
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    'Google sign-in failed: $e')));
                                      }
                                    },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(theme.radiusFull),
        ),
        child: Center(
          child: Text(label,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: theme.primary)),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _OutlineButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
          borderRadius: BorderRadius.circular(theme.radiusFull),
        ),
        child: Center(
          child: Text(label,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
              height: 1, color: Colors.white.withValues(alpha: 0.4)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('or',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75), fontSize: 12)),
        ),
        Expanded(
          child: Container(
              height: 1, color: Colors.white.withValues(alpha: 0.4)),
        ),
      ],
    );
  }
}

class _SsoIconButton extends StatelessWidget {
  final Widget icon;
  final Color background;
  final Color? border;
  final String tooltip;
  final VoidCallback? onTap;
  const _SsoIconButton({
    required this.icon,
    required this.background,
    required this.tooltip,
    this.border,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return Semantics(
      label: tooltip,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Opacity(
          opacity: disabled ? 0.5 : 1,
          child: Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
              border: border != null ? Border.all(color: border!) : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: icon,
          ),
        ),
      ),
    );
  }
}

/// Apple's official glyph per HIG — white on black. Using Material's apple
/// icon matches Apple's trademark mark shape.
class _AppleGlyph extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.apple, size: 30, color: Colors.white);
  }
}

/// Google "G" in the four brand colors. Painted inline so we don't ship an
/// SVG loader for one button. Replace with the official SVG before production.
class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26,
      height: 26,
      child: CustomPaint(painter: _GoogleGPainter()),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  static const _blue = Color(0xFF4285F4);
  static const _red = Color(0xFFEA4335);
  static const _yellow = Color(0xFFFBBC05);
  static const _green = Color(0xFF34A853);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.48;
    final stroke = size.width * 0.18;
    final rect = Rect.fromCircle(center: c, radius: r - stroke / 2);

    void arc(double startDeg, double sweepDeg, Color color) {
      final paint = Paint()
        ..color = color
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt
        ..style = PaintingStyle.stroke;
      canvas.drawArc(
        rect,
        startDeg * 3.14159 / 180,
        sweepDeg * 3.14159 / 180,
        false,
        paint,
      );
    }

    // Four brand-color arc segments.
    arc(-90, 90, _red);       // top → right (red)
    arc(0, 90, _yellow);      // right → bottom (yellow)
    arc(90, 90, _green);      // bottom → left (green)
    arc(180, 90, _blue);      // left → top (blue)

    // Inner horizontal bar (the "G" crossbar).
    final barPaint = Paint()
      ..color = _blue
      ..style = PaintingStyle.fill;
    final barHeight = stroke * 0.95;
    canvas.drawRect(
      Rect.fromLTWH(c.dx, c.dy - barHeight / 2, r - stroke / 2, barHeight),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
