import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import 'auth_callbacks.dart';

/// Tracks whether the user tapped Skip on the birthday step during onboarding.
///
/// Prototype-local state only. The real backend wiring lands in D2b, which
/// will PATCH /users/me with `birthday_skipped=true` on the server. Until
/// then, this provider is a stub so the UI can branch on the skipped state
/// without any HTTP call.
final onboardingSkippedProvider = StateProvider<bool>((ref) => false);

class AuthOnboardingScreen extends ConsumerStatefulWidget {
  const AuthOnboardingScreen({super.key});

  @override
  ConsumerState<AuthOnboardingScreen> createState() =>
      _AuthOnboardingScreenState();
}

class _AuthOnboardingScreenState extends ConsumerState<AuthOnboardingScreen> {
  /// Interest identifiers the user has tapped. Users start with an empty
  /// set so the "X of 3 selected" counter reflects actual progress — the
  /// demo catalogue's `isSelected` flags were pre-seeding interests and
  /// making the step look complete before the user picked anything.
  final Set<String> _selectedIds = <String>{};

  void _onToggle(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _onContinue(BuildContext context) async {
    final callbacks = AuthCallbacksScope.maybeOf(context);
    if (callbacks?.onSaveInterests != null && _selectedIds.isNotEmpty) {
      // Best-effort save — never block onboarding nav on a backend write.
      unawaited(
        callbacks!.onSaveInterests!(_selectedIds.toList()).catchError(
          (Object e) {
            debugPrint('[onboarding] save interests failed: $e');
          },
        ),
      );
    }
    if (!context.mounted) return;
    context.go(ProtoRoutes.authTutorial);
  }

  void _onSkip() {
    // D2b: call /users/me with birthday_skipped=true
    ref.read(onboardingSkippedProvider.notifier).state = true;
    context.go(ProtoRoutes.authTutorial);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    final selectedCount = _selectedIds.length;
    final reachedMin = selectedCount >= 3;

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
                    onPressed: _onSkip,
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
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: ProtoDemoData.interests.map((interest) {
                      final isSelected = _selectedIds.contains(interest.name);
                      return GestureDetector(
                        onTap: () => _onToggle(interest.name),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.primary
                                : theme.background,
                            borderRadius:
                                BorderRadius.circular(theme.radiusFull),
                            border: isSelected
                                ? null
                                : Border.all(
                                    color:
                                        theme.text.withValues(alpha: 0.12),
                                  ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSelected) ...[
                                Icon(theme.icons.check,
                                    size: 16, color: Colors.white),
                                const SizedBox(width: 6),
                              ],
                              Text(
                                interest.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : theme.text,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            // Counter + Continue
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    '$selectedCount of 3 selected',
                    style: theme.caption.copyWith(
                      color: reachedMin ? theme.primary : theme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: reachedMin ? () => _onContinue(context) : null,
                    child: Opacity(
                      opacity: reachedMin ? 1 : 0.45,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: theme.primary,
                          borderRadius:
                              BorderRadius.circular(theme.radiusFull),
                        ),
                        child: Center(
                          child: Text(
                            "Let's Go!",
                            style: theme.button.copyWith(fontSize: 16),
                          ),
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
