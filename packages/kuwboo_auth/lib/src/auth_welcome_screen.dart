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
          child: Stack(
            children: [
              // Test-build banner — remove before production launch.
              Positioned(
                top: 8,
                left: 12,
                right: 12,
                child: _TestBuildBanner(),
              ),
              // Logo at top 1/3, button stack at 2/3.
              LayoutBuilder(
                builder: (context, constraints) {
                  final h = constraints.maxHeight;
                  return Stack(
                    children: [
                      Positioned(
                        top: h * 0.33 - 90,
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
                        top: h * 0.66 - 24,
                        left: 32,
                        right: 32,
                        child: Column(
                          children: [
                            _PrimaryButton(
                              label: 'Create Account',
                              onTap: () =>
                                  context.go(ProtoRoutes.authMethod),
                            ),
                            const SizedBox(height: 12),
                            _OutlineButton(
                              label: 'Log In',
                              onTap: () =>
                                  context.go(ProtoRoutes.authLogin),
                            ),
                            const SizedBox(height: 20),
                            const _OrDivider(),
                            const SizedBox(height: 16),
                            _SsoButton(
                              icon: Icons.apple,
                              label: 'Continue with Apple',
                              background: Colors.black,
                              foreground: Colors.white,
                              onTap: callbacks?.onSignInWithApple == null
                                  ? null
                                  : () async {
                                      try {
                                        await callbacks!
                                            .onSignInWithApple!();
                                      } catch (e) {
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    'Apple sign-in failed: $e')));
                                      }
                                    },
                            ),
                            const SizedBox(height: 10),
                            _SsoButton(
                              icon: Icons.g_mobiledata,
                              iconSize: 28,
                              label: 'Continue with Google',
                              background: Colors.white,
                              foreground: Colors.black87,
                              onTap: callbacks?.onSignInWithGoogle == null
                                  ? null
                                  : () async {
                                      try {
                                        await callbacks!
                                            .onSignInWithGoogle!();
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
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TestBuildBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.amber.shade700,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade900, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.science_outlined, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'TEST BUILD — use OTP 000000 to sign in',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
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
            child:
                Container(height: 1, color: Colors.white.withValues(alpha: 0.4))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('or',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
        ),
        Expanded(
            child:
                Container(height: 1, color: Colors.white.withValues(alpha: 0.4))),
      ],
    );
  }
}

class _SsoButton extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback? onTap;
  const _SsoButton({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    this.onTap,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: disabled ? 0.5 : 1,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(theme.radiusFull),
            border: background == Colors.white
                ? Border.all(color: Colors.black12)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: iconSize, color: foreground),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: foreground)),
            ],
          ),
        ),
      ),
    );
  }
}
