import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

/// Tracks whether the user tapped Skip on the birthday step during onboarding.
///
/// Prototype-local state only. The real backend wiring lands in D2b, which
/// will PATCH /users/me with `birthday_skipped=true` on the server. Until
/// then, this provider is a stub so the UI can branch on the skipped state
/// without any HTTP call.
final onboardingSkippedProvider = StateProvider<bool>((ref) => false);

class AuthOnboardingScreen extends ConsumerWidget {
  const AuthOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ProtoTheme.of(context);

    void onSkip() {
      // D2b: call /users/me with birthday_skipped=true
      ref.read(onboardingSkippedProvider.notifier).state = true;
      context.go(ProtoRoutes.authTutorial);
    }

    return Material(
      type: MaterialType.transparency,
      child: Container(
        color: theme.surface,
        child: Column(
          children: [
            // Simple header with Skip link.
            Padding(
              padding: const EdgeInsets.only(
                  top: 56, left: 24, right: 24, bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pick your interests',
                          style: theme.headline.copyWith(fontSize: 24),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Choose at least 3 to personalize your experience.',
                          style: theme.body,
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: onSkip,
                    child: Text(
                      'Skip',
                      style: theme.caption.copyWith(
                        color: theme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: ProtoDemoData.interests.map((interest) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        color: interest.isSelected
                            ? theme.primary
                            : theme.background,
                        borderRadius: BorderRadius.circular(theme.radiusFull),
                        border: interest.isSelected
                            ? null
                            : Border.all(
                                color: theme.text.withValues(alpha: 0.12),
                              ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (interest.isSelected) ...[
                            Icon(theme.icons.check,
                                size: 16, color: Colors.white),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            interest.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: interest.isSelected
                                  ? Colors.white
                                  : theme.text,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Counter + Continue
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    '3 of 3 selected',
                    style: theme.caption.copyWith(color: theme.primary),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => context.go(ProtoRoutes.authTutorial),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: theme.primary,
                        borderRadius: BorderRadius.circular(theme.radiusFull),
                      ),
                      child: Center(
                        child: Text(
                          "Let's Go!",
                          style: theme.button.copyWith(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
