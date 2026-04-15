import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import 'auth_callbacks.dart';

class AuthProfileScreen extends StatelessWidget {
  const AuthProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);

    return Material(
      type: MaterialType.transparency,
      child: Container(
      color: theme.surface,
      child: Column(
        children: [
          ProtoSubBar(title: 'Create Profile'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                const SizedBox(height: 32),

                // Avatar placeholder
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: theme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          size: 48,
                          color: theme.primary.withValues(alpha: 0.4),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: theme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: theme.surface, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Add a photo',
                    style: theme.caption.copyWith(color: theme.primary, fontWeight: FontWeight.w600),
                  ),
                ),

                const SizedBox(height: 32),

                // Display Name
                _ProfileField(
                  label: 'Display Name',
                  hint: 'Your name',
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 20),

                // Username
                Text('Username', style: theme.caption.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: theme.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.text.withValues(alpha: 0.08)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '@',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'username',
                        style: theme.body.copyWith(color: theme.textTertiary),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.check_circle_outline,
                        size: 20,
                        color: theme.textTertiary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'This is how others will find you',
                  style: theme.caption.copyWith(color: theme.textTertiary, fontSize: 12),
                ),
              ],
            ),
          ),
          // Continue button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
            child: GestureDetector(
              onTap: () => _onContinue(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: theme.primary,
                  borderRadius: BorderRadius.circular(theme.radiusFull),
                ),
                child: Center(
                  child: Text('Continue', style: theme.button.copyWith(fontSize: 16)),
                ),
              ),
            ),
          ),
        ],
      ),
        ));
  }

  Future<void> _onContinue(BuildContext context) async {
    final callbacks = AuthCallbacksScope.maybeOf(context);
    if (callbacks?.onSaveProfile != null) {
      try {
        // Prototype screen has placeholder fields only — mobile form will
        // wire real displayName/username/avatarUrl. For now, invoke the
        // callback with no fields so the host can at least record the step.
        await callbacks!.onSaveProfile!();
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save profile: $e')),
        );
        return;
      }
    }
    if (!context.mounted) return;
    context.go(ProtoRoutes.authOnboarding);
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  const _ProfileField({required this.label, required this.hint, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.caption.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: theme.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.text.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: theme.textTertiary),
              const SizedBox(width: 12),
              Text(hint, style: theme.body.copyWith(color: theme.textTertiary)),
            ],
          ),
        ),
      ],
    );
  }
}
