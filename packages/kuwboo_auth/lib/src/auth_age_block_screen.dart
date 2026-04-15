import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

class AuthAgeBlockScreen extends StatelessWidget {
  const AuthAgeBlockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);

    return Material(
      type: MaterialType.transparency,
      child: Container(
      color: theme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            const Spacer(flex: 3),

            // Logo (smaller)
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  'K',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: theme.primary,
                    fontFamily: theme.displayFont,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),

            Text(
              'Thanks for your interest!',
              style: theme.headline.copyWith(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            Text(
              'Kuwboo is available for people\n13 and older.',
              style: theme.body.copyWith(
                color: theme.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const Spacer(flex: 2),

            // OK button
            Padding(
              padding: const EdgeInsets.only(bottom: 48),
              child: GestureDetector(
                onTap: () => context.go(ProtoRoutes.authWelcome),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: theme.primary,
                    borderRadius: BorderRadius.circular(theme.radiusFull),
                  ),
                  child: Center(
                    child: Text('OK', style: theme.button.copyWith(fontSize: 16)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
        ));
  }
}
