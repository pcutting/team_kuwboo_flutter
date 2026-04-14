import 'package:flutter/material.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

class AuthMethodScreen extends StatelessWidget {
  const AuthMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    final state = PrototypeStateProvider.of(context);

    return Material(
      type: MaterialType.transparency,
      child: Container(
      color: theme.surface,
      child: Column(
        children: [
          ProtoSubBar(title: 'Sign Up'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Text(
                    'How do you want to\ncreate your account?',
                    style: theme.headline.copyWith(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Use phone or email
                  _MethodButton(
                    icon: Icons.email_outlined,
                    label: 'Use phone or email',
                    onTap: () => state.push(ProtoRoutes.authPhone),
                    filled: true,
                  ),
                  const SizedBox(height: 12),

                  // Continue with Google
                  _MethodButton(
                    icon: Icons.g_mobiledata_rounded,
                    label: 'Continue with Google',
                    onTap: () => state.push(ProtoRoutes.authProfile),
                  ),
                  const SizedBox(height: 12),

                  // Continue with Apple
                  _MethodButton(
                    icon: Icons.apple_rounded,
                    label: 'Continue with Apple',
                    onTap: () => state.push(ProtoRoutes.authProfile),
                  ),

                  const Spacer(),

                  // Terms
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Text.rich(
                      TextSpan(
                        text: 'By continuing, you agree to our ',
                        children: [
                          TextSpan(
                            text: 'Terms of Service',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                      style: theme.caption.copyWith(
                        color: theme.textTertiary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
        ));
  }
}

class _MethodButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  const _MethodButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: filled ? theme.primary : null,
          border: filled ? null : Border.all(color: theme.text.withValues(alpha: 0.12)),
          borderRadius: BorderRadius.circular(theme.radiusFull),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: filled ? Colors.white : theme.text),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: filled ? Colors.white : theme.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
